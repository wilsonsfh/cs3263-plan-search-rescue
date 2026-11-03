#!/usr/bin/env python3
"""Write natural-language field reports for each instance.

People are in four bands: injured, child, elderly, adult.

Two difficulty levels per instance:
  explicit  facts stated plainly ("Road A - B (23 min): impassable",
            "3 children at X", "X is an evacuation point")
  implicit  the same facts phrased the way a journalist might write them,
            so the model has to infer them ("the bridge on the A road was
            washed away", "an elderly couple", "the army has set up a relief
            camp at X"). Some harmless distractors are added
            ("muddy but passable", "high ground but no supplies").

Every location and car carries an identifier in square brackets, e.g.
"Bidur school [bidur-school]", so both pipelines can refer to them
unambiguously. People are described per location and age band; they can be
split across cars. Travel times are always given, so the ground truth is
recoverable from either version.

Writes reports/<id>-<level>.txt.

These are a templated baseline: Wilson can edit or replace the text files,
as long as the bracketed identifiers stay.
"""

import argparse
import json
import random
from pathlib import Path

HERE = Path(__file__).parent
INSTANCES = HERE.parent / "pddl" / "instances"
OUT = HERE / "reports"

NUM = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
       "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen",
       "nineteen", "twenty"]

KIND_LABEL = {
    "school": "school", "village": "village", "care-home": "care home",
    "farm": "farm", "temple": "temple", "market": "market",
    "shelter": "shelter", "hospital": "hospital", "army-camp": "army camp",
}


def place(loc):
    return f"{loc['name']} {KIND_LABEL[loc['kind']]} [{loc['id']}]"


# ---------- implicit phrasings ----------

def implicit_people(rng, band, n):
    w = NUM[n]
    options = {
        "injured": {1: ["a man with a broken leg", "a woman with a deep head wound",
                        "a teenager pulled from the rubble with crush injuries", "a farmer with a badly cut arm"],
                    "n": [f"{w} people injured when their house collapsed", f"{w} residents with fractures and cuts",
                          f"{w} people hurt by falling debris", f"{w} wounded villagers"]},
        "child": {1: ["a young boy", "a schoolgirl", "a seven-year-old child", "a toddler"],
                  "n": [f"{w} pupils", f"{w} young children", f"{w} kids from the nursery class",
                        f"{w} schoolchildren"]},
        "elderly": {1: ["an elderly widow", "an old man who cannot walk unaided",
                        "a grandmother in her eighties"],
                    2: ["an elderly couple", "two pensioners"],
                    "n": [f"{w} elderly residents", f"{w} people in their late seventies and eighties",
                          f"{w} frail senior citizens"]},
        "adult": {1: ["a farmer", "a shopkeeper", "a young woman in her twenties", "a bus driver"],
                  "n": [f"{w} adult labourers", f"{w} shopkeepers", f"{w} working-age adults",
                        f"{w} men and women from the cooperative"]},
    }[band]
    pool = options.get(n) or options["n"]
    return rng.choice(pool)


def implicit_road(rng, a, b, minutes, damaged):
    if damaged:
        return rng.choice([
            f"A landslide has buried the road between {a} and {b} (normally a {minutes}-minute drive).",
            f"The bridge on the {a} to {b} road ({minutes} minutes in normal conditions) was washed away last night.",
            f"Floodwater is running fast over the {a} to {b} road; a truck was swept off it this morning. "
            f"The drive usually takes {minutes} minutes.",
            f"Police have closed the {a} to {b} road after part of it collapsed into the river. "
            f"It is normally {minutes} minutes by car.",
        ])
    return rng.choice([
        f"The drive from {a} to {b} takes about {minutes} minutes.",
        f"The {a} to {b} road is muddy but passable, about {minutes} minutes by car.",
        f"Drivers report the road between {a} and {b} is clear; it takes roughly {minutes} minutes.",
        f"It is a {minutes}-minute drive between {a} and {b}, with some debris but no blockages.",
    ])


def implicit_evac(rng, loc):
    return rng.choice({
        "shelter": [f"Volunteers at {place(loc)} say they have room for more families.",
                    f"{place(loc)} is above the flood line and is taking in evacuees."],
        "hospital": [f"{place(loc)} is on high ground and its staff are receiving evacuees.",
                     f"{place(loc)} is accepting people brought in from the flooded areas."],
        "army-camp": [f"The army has set up a relief camp at {place(loc)} with tents and medics.",
                      f"Soldiers at {place(loc)} are registering and housing displaced people."],
    }[loc["kind"]])


# ---------- report writers ----------

def write_report(inst, level, rng):
    locs = {l["id"]: l for l in inst["locations"]}
    cars = inst["cars"]
    lines = []

    lines.append(f"FIELD REPORT - Nuwakot district flood response (scenario {inst['id']})")
    lines.append("")

    # Fleet
    starts = {}
    for c in cars:
        starts.setdefault(c["start"], []).append(c["id"])
    fleet = "; ".join(f"{', '.join(f'[{c}]' for c in cs)} at {place(locs[s])}" for s, cs in starts.items())
    if level == "explicit":
        lines.append(f"VEHICLES: {len(cars)} car(s), {cars[0]['seats']} passenger seats each. Positions: {fleet}.")
    else:
        lines.append(f"Our team has {NUM[len(cars)]} car{'s' if len(cars) > 1 else ''} available, "
                     f"{'each ' if len(cars) > 1 else ''}able to carry {NUM[cars[0]['seats']]} passengers. "
                     f"Currently: {fleet}.")
    lines.append("")

    # Evacuation points (and a distractor for implicit)
    evacs = [l for l in inst["locations"] if l["evac"]]
    if level == "explicit":
        lines.append("EVACUATION POINTS (people may only be dropped off here): "
                     + ", ".join(place(l) for l in evacs) + ".")
    else:
        lines.append("SAFE LOCATIONS")
        for l in evacs:
            lines.append(implicit_evac(rng, l))
        others = [l for l in inst["locations"] if not l["evac"] and l["kind"] in ("temple", "school")]
        if others:
            d = rng.choice(others)
            lines.append(f"{place(d)} sits on higher ground, but it has no food, water or medical staff "
                         f"and the authorities have not designated it as a place to bring people.")
    lines.append("")

    # Roads
    lines.append("ROADS" if level == "explicit" else "ROAD CONDITIONS")
    road_list = list(inst["roads"])
    if level == "implicit":
        rng.shuffle(road_list)
    for r in road_list:
        a, b = place(locs[r["from"]]), place(locs[r["to"]])
        if level == "explicit":
            status = "IMPASSABLE (damaged)" if r["damaged"] else "open"
            lines.append(f"- {a} <-> {b}: {r['minutes']} min, {status}")
        else:
            lines.append("- " + implicit_road(rng, a, b, r["minutes"], r["damaged"]))
    lines.append("Any road not listed here does not exist or cannot be used.")
    lines.append("")

    # People
    lines.append("PEOPLE AWAITING RESCUE" if level == "explicit" else "STRANDED CIVILIANS")
    by_loc = {}
    for p in inst["people"]:
        by_loc.setdefault(p["location"], []).append(p)
    noun = {"injured": ("injured person", "injured people"), "child": ("child", "children"), "elderly": ("elderly person", "elderly people"),
            "adult": ("adult", "adults")}
    for lid, ps in by_loc.items():
        if level == "explicit":
            parts = [f"{p['count']} {noun[p['band']][p['count'] > 1]}" for p in ps]
            lines.append(f"- {place(locs[lid])}: " + ", ".join(parts))
        else:
            parts = [implicit_people(rng, p["band"], p["count"]) for p in ps]
            joined = ", ".join(parts[:-1]) + " and " + parts[-1] if len(parts) > 1 else parts[0]
            lines.append(f"- At {place(locs[lid])}, residents report {joined} waiting for help.")
    if level == "explicit":
        lines.append("People at the same location may be split between cars or trips.")
    else:
        lines.append("Families have said they are willing to travel separately if needed.")
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ids", nargs="*")
    args = ap.parse_args()
    OUT.mkdir(exist_ok=True)
    for j in sorted(INSTANCES.glob("*.json")):
        inst = json.loads(j.read_text())
        if args.ids and inst["id"] not in args.ids:
            continue
        for level in ("explicit", "implicit"):
            rng = random.Random(f"{inst['id']}-{level}")
            (OUT / f"{inst['id']}-{level}.txt").write_text(write_report(inst, level, rng))
    print(f"wrote reports to {OUT}")


if __name__ == "__main__":
    main()
