"""Render an Instance into the natural-language inputs a field coordinator receives.

What is given at every level (a realistic split of information):
  * MISSION SHEET - what the team already knows about itself: base, shelter,
    vehicle capacity, and the list of places on the district map.
  * ROAD REGISTER - the pre-flood road network with usual travel times
    (e.g. from OpenStreetMap / the district office). Not affected by the flood.
  * FIELD REPORTS - what changed: road damage and who is stranded where. This is
    the part whose linguistic difficulty we vary:

    L1 explicit  one structured bulletin: "Bidur - Ramche: BLOCKED", "Ramche: 2 injured, ..."
    L2 implicit  one narrative dispatch: causes instead of statuses ("the suspension bridge
                 was swept away"), relative times ("twice the usual time"), number words,
                 people described by condition (an injured child counts as injured),
                 a muddy-but-passable trap road, already-evacuated villages.
    L3 noisy     several time-stamped dispatches from different sources, printed out of
                 order: superseded statuses (cleared debris, fresh landslides), unconfirmed
                 rumours later refuted, estimated headcounts later confirmed, distractors.

Every rendering is generated from the Instance, so the gold meaning of each
sentence is known; the final confirmed statement about every fact always agrees
with the Instance.
"""
from __future__ import annotations

import json
import random
from dataclasses import dataclass

from .schema import GROUPS, Instance, Road

KIND_LABEL = {
    "base": "evacuation point", "village": "village", "school": "school", "health_post": "health post",
    "temple": "temple", "ward_office": "ward office", "junction": "road junction",
    "evacuated_village": "village",
}
WORDS = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
         "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen",
         "nineteen", "twenty"]


@dataclass
class Rendered:
    level: str
    mission: str
    register: str
    reports: str

    @property
    def text(self) -> str:
        return f"{self.mission}\n\n{self.register}\n\n{self.reports}"


# ------------------------------------------------------------------ helpers
def _num(n: int, rng: random.Random) -> str:
    if n == 12 and rng.random() < 0.5:
        return "a dozen"
    if n == 6 and rng.random() < 0.3:
        return "half a dozen"
    if n <= 20 and rng.random() < 0.8:
        return WORDS[n]
    return str(n)


def _minutes(m: int, rng: random.Random) -> str:
    special = {15: "a quarter of an hour", 30: "half an hour", 60: "an hour", 90: "an hour and a half",
               120: "two hours", 45: "three quarters of an hour"}
    if m in special and rng.random() < 0.5:
        return special[m]
    if m > 60 and m % 60 and rng.random() < 0.5:
        h, r = divmod(m, 60)
        return f"{WORDS[h]} hour{'s' if h > 1 else ''} and {r} minutes"
    return f"{m} minutes"


def _road(inst: Instance, r: Road) -> str:
    return f"{inst.name_of(r.u)}–{inst.name_of(r.v)}"


def _pre_flood(r: Road) -> int:
    return r.base_minutes if r.base_minutes is not None else r.minutes


INJURED_DESC = [
    "an elderly woman with a broken hip", "a child with a deep gash on his leg", "a man with a crushed foot",
    "a woman with burns on her arms", "a teenage girl with a fractured arm", "an old man with a head wound",
    "a young boy with a badly sprained ankle", "a pregnant woman who was hit by debris",
]


def describe_people(p: dict[str, int], rng: random.Random) -> str:
    parts = []
    ni = p.get("injured", 0)
    if ni:
        descs = rng.sample(INJURED_DESC, ni)
        if ni == 1:
            parts.append(f"one injured person ({descs[0]})")
        else:
            parts.append(f"{_num(ni, rng)} injured people ({', '.join(descs[:-1])} and {descs[-1]})")
    nc = p.get("children", 0)
    if nc:
        parts.append(rng.choice(["a baby", "one child", "one schoolchild"] if nc == 1 else
                                [f"{_num(nc, rng)} children", f"{_num(nc, rng)} schoolchildren"]))
    ne = p.get("elderly", 0)
    if ne:
        opts = (["an old man", "one elderly resident", "one senior citizen"] if ne == 1 else
                [f"{_num(ne, rng)} elderly residents", f"{_num(ne, rng)} senior citizens"])
        if ne == 2:
            opts.append("an elderly couple")
        parts.append(rng.choice(opts))
    na = p.get("adults", 0)
    if na:
        adj = rng.choice(["other ", "able-bodied ", "uninjured "]) if parts else ""
        parts.append(f"{_num(na, rng)} {adj}{'adult' if na == 1 else 'adults'}")
    if len(parts) == 1:
        return parts[0]
    return ", ".join(parts[:-1]) + " and " + parts[-1]


def _people_sentence(inst: Instance, loc: str, rng: random.Random) -> str:
    name, kind = inst.name_of(loc), KIND_LABEL[inst.loc(loc).kind]
    desc = describe_people(inst.people[loc], rng)
    where = name if kind == "village" else f"the {kind} in {name}"
    v = "is" if inst.headcount(loc) == 1 else "are"
    t = rng.choice([
        "At {w}, {d} {v} waiting to be rescued.",
        "Stranded at {w}: {d}.",
        "Residents at {w} say {d} {v} still there, sheltering on upper floors.",
        "Our team counted {d} at {w}, all needing evacuation.",
    ])
    return t.format(w=where, d=desc, v=v)


def _blocked_sentence(inst: Instance, r: Road, rng: random.Random) -> str:
    a, b = inst.name_of(r.u), inst.name_of(r.v)
    return rng.choice({
        "landslide": [f"A landslide has buried the road between {a} and {b} under metres of mud.",
                      f"Hillside collapse: the {a}–{b} road disappeared under a landslide overnight."],
        "bridge": [f"The suspension bridge on the {a}–{b} route was swept away by the river.",
                   f"The only bridge linking {a} and {b} has collapsed."],
        "submerged": [f"The {a}–{b} road is under two metres of fast-flowing floodwater.",
                      f"Floodwater has turned the road from {a} to {b} into a river."],
        "debris": [f"Boulders and fallen trees make the {a}–{b} road impassable for any vehicle.",
                   f"Debris has completely choked the road between {a} and {b}."],
    }[r.cause or "debris"])


def _slowed_sentence(inst: Instance, r: Road, rng: random.Random) -> str:
    a, b = inst.name_of(r.u), inst.name_of(r.v)
    base = _pre_flood(r)
    if r.minutes == 2 * base:
        how = rng.choice(["takes twice the usual time", "now takes double the normal journey time"])
    else:
        how = f"adds {_minutes(r.minutes - base, rng)} to the usual journey"
    return f"The {a}–{b} road is open but badly waterlogged; driving it {how}."


def _cleared_sentence(inst: Instance, r: Road, rng: random.Random) -> str:
    a, b = inst.name_of(r.u), inst.name_of(r.v)
    return rng.choice([f"Army engineers have cleared the debris on the {a}–{b} road; it is open again at normal speed.",
                       f"The {a}–{b} road has been reopened after bulldozers removed the debris; travel times are back to normal."])


def _trap_sentence(inst: Instance, r: Road, rng: random.Random) -> str:
    a, b = inst.name_of(r.u), inst.name_of(r.v)
    return rng.choice([f"The {a}–{b} road is muddy and frightening to drive, but our jeep got through in the usual time.",
                       f"Locals warned us about the {a}–{b} road, yet it is intact and passable at normal speed."])


def _evacuated_sentence(inst: Instance, loc: str, rng: random.Random) -> str:
    n = inst.name_of(loc)
    return rng.choice([f"{n} was fully evacuated by the army yesterday; no one remains there.",
                       f"Everyone from {n} has already been airlifted out."])


DISTRACTORS = [
    "Heavy rain is forecast to continue through the evening.",
    "Livestock losses across the district are reported to be severe.",
    "The Home Ministry says relief funds will be released next week.",
    "Mobile networks remain patchy across the district.",
    "In Kathmandu, schools have been closed for three days as a precaution.",
    "A government helicopter was seen flying north this morning but did not land.",
]


# ------------------------------------------------------------------- render
def mission_sheet(inst: Instance) -> str:
    cap = (f"{inst.capacity} people at a time" if inst.capacity
           else "no practical limit (enough vehicles to carry everyone at once)")
    places = ", ".join(f"{l.name} ({KIND_LABEL[l.kind]})" for l in inst.locations)
    return (
        "MISSION SHEET\n"
        f"- Team base and starting point: {inst.name_of(inst.start)}\n"
        f"- Shelter where evacuees must be delivered: {inst.name_of(inst.shelter)}\n"
        f"- Vehicle capacity: {cap}\n"
        f"- Places on the district map: {places}"
    )


def road_register(inst: Instance) -> str:
    lines = [f"- {_road(inst, r)}: {_pre_flood(r)} min" for r in inst.roads]
    return ("ROAD REGISTER (pre-flood network; usual one-way driving times, roads are two-way)\n"
            + "\n".join(lines))


def _l1(inst: Instance, rng: random.Random) -> str:
    lines = ["FIELD REPORT (district control room, 12:00)", "Road status changes since the flood:"]
    for r in inst.roads:
        if not r.open:
            lines.append(f"- {_road(inst, r)}: BLOCKED")
        elif r.minutes != _pre_flood(r):
            lines.append(f"- {_road(inst, r)}: open, travel time now {r.minutes} min")
    lines.append("All other roads: open, usual travel time.")
    lines.append("People waiting for rescue:")
    for l in inst.occupied():
        p = inst.people[l]
        lines.append(f"- {inst.name_of(l)}: " + ", ".join(f"{p.get(g, 0)} {g}" for g in GROUPS))
    lines.append("No one is waiting at any other location.")
    return "\n".join(lines)


def _l2(inst: Instance, rng: random.Random) -> str:
    s = []
    for r in inst.roads:
        if not r.open:
            s.append(_blocked_sentence(inst, r, rng))
        elif r.minutes != _pre_flood(r):
            s.append(_slowed_sentence(inst, r, rng))
        elif "cleared" in r.history:
            s.append(_cleared_sentence(inst, r, rng))
        elif "rumour" in r.history:
            s.append(_trap_sentence(inst, r, rng))
    for l in inst.occupied():
        s.append(_people_sentence(inst, l, rng))
    for l in inst.locations:
        if l.kind == "evacuated_village":
            s.append(_evacuated_sentence(inst, l.id, rng))
    rng.shuffle(s)
    return ("FIELD DISPATCH (Prakash Thapa, Kantipur correspondent, filed 12:10)\n"
            + " ".join(s)
            + " Apart from what is described here, roads are in their usual condition and no one else is known to be stranded.")


def _l3(inst: Instance, rng: random.Random) -> str:
    early, mid, late = [], [], []  # (sentence) lists, final truth must be stated last
    for r in inst.roads:
        a, b = inst.name_of(r.u), inst.name_of(r.v)
        if not r.open and "open" in r.history:
            early.append(f"The {a}–{b} road is still passable this morning, drivers say.")
            late.append(_blocked_sentence(inst, r, rng).rstrip(".") + ", cutting a road that was open earlier today.")
        elif not r.open:
            rng.choice([mid, late]).append(_blocked_sentence(inst, r, rng))
        elif r.minutes != _pre_flood(r):
            rng.choice([mid, late]).append(_slowed_sentence(inst, r, rng))
        elif "cleared" in r.history:
            early.append(f"Debris is blocking the {a}–{b} road.")
            late.append(_cleared_sentence(inst, r, rng))
        elif "rumour" in r.history:
            mid.append(f"Unconfirmed posts on social media claim the {a}–{b} road has been washed away.")
            late.append(f"Police have checked the {a}–{b} road: the social media reports were false and the road is open as normal.")
    for l in inst.occupied():
        if rng.random() < 0.5:
            approx = max(1, inst.headcount(l) + rng.choice([-3, -2, 2, 3, 4]))
            early.append(f"Around {approx} people are believed to be stranded in {inst.name_of(l)} (unconfirmed estimate).")
            late.append("Confirmed headcount: " + _people_sentence(inst, l, rng))
        else:
            rng.choice([mid, late]).append(_people_sentence(inst, l, rng))
    for l in inst.locations:
        if l.kind == "evacuated_village":
            early.append(f"Residents of {l.name} were seen on rooftops last night.")
            late.append(_evacuated_sentence(inst, l.id, rng))
    pool = DISTRACTORS[:]
    rng.shuffle(pool)
    for bucket in (early, mid, late):
        bucket.append(pool.pop())
        rng.shuffle(bucket)
    blocks = [
        ("06:45", "Radio Nuwakot FM (local radio, early bulletin)", early),
        ("09:30", "District Police Office (situation report)", mid),
        ("13:15", "Sunita Lama, The Himalayan Times (on the ground)", late),
    ]
    rng.shuffle(blocks)  # printed out of chronological order; timestamps decide
    out = ["FIELD DISPATCHES (several sources; listed in the order they reached the control room)"]
    for ts, src, sent in blocks:
        out.append(f"[{ts}] {src}: " + " ".join(sent))
    out.append("Anything not mentioned in these dispatches is in its usual condition, and no one else is known to be stranded.")
    return "\n".join(out)


def render(inst: Instance, level: str, seed: int = 0) -> Rendered:
    rng = random.Random(f"{inst.id}-{level}-{seed}")
    body = {"L1": _l1, "L2": _l2, "L3": _l3}[level](inst, rng)
    return Rendered(level, mission_sheet(inst), road_register(inst), body)


def gold_facts(inst: Instance) -> str:
    """The perfectly-translated post-flood problem, for the gold-facts ablation."""
    return json.dumps({
        "start": inst.name_of(inst.start),
        "shelter": inst.name_of(inst.shelter),
        "capacity": inst.capacity,
        "locations": [{"name": l.name, "kind": KIND_LABEL[l.kind]} for l in inst.locations],
        "roads": [{"between": [inst.name_of(r.u), inst.name_of(r.v)], "minutes": r.minutes,
                   "status": "open" if r.open else "blocked"} for r in inst.roads],
        "people": {inst.name_of(l): {g: inst.people[l].get(g, 0) for g in GROUPS} for l in inst.occupied()},
    }, indent=1)
