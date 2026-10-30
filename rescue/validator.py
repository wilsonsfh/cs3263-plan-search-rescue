"""Deterministic plan validator (the shared judge for every pipeline).

It replays a plan against the ground-truth Instance, step by step, the way the
rescue would actually unfold, and never trusts anything the plan claims about
itself (claimed travel time, claimed unreachability). Errors are typed so the
evaluation can say *why* a plan failed, not just that it failed.

Severity:
  physical   the plan cannot be carried out in the real world (stuck team)
  goal       executable, but people that could be saved are left behind
  priority   executable and complete, but breaks the vulnerability-tier rule
  info       harmless for the rescue; recorded for analysis
Coverage and wait times are counted only up to the first physical error,
because after that point the real team would be stuck.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field

from .graph import reachable
from .schema import GROUPS, Instance

PHYSICAL = {"UNKNOWN_LOCATION", "UNKNOWN_ACTION", "WRONG_ORIGIN", "NO_ROAD", "BLOCKED_ROAD",
            "NOT_AT_LOCATION", "CAPACITY", "WRONG_DROPOFF"}
GOAL = {"NOT_DELIVERED", "FALSE_UNREACHABLE"}
PRIORITY = {"PRIORITY"}
INFO = {"UNREPORTED_UNREACHABLE", "EMPTY_PICKUP", "DUPLICATE_PICKUP", "UNKNOWN_UNREACHABLE_NAME"}


@dataclass(frozen=True)
class Step:
    action: str  # move | pickup | dropoff
    args: tuple[str, ...]


@dataclass
class Plan:
    steps: list[Step]
    unreachable: list[str] = field(default_factory=list)
    claimed_minutes: float | None = None


@dataclass
class PlanError:
    code: str
    step: int | None
    message: str

    @property
    def severity(self) -> str:
        if self.code in PHYSICAL:
            return "physical"
        if self.code in GOAL:
            return "goal"
        if self.code in PRIORITY:
            return "priority"
        return "info"


@dataclass
class ValidationResult:
    executable: bool
    complete: bool
    priority_ok: bool
    valid: bool
    cost: float  # travel minutes actually charged
    claimed_cost_error: float | None  # claimed - actual (None if no claim)
    coverage: float  # delivered / rescuable, up to first physical error
    delivered: dict[str, int]
    rescuable: dict[str, int]
    pickup_minutes_by_group: dict[str, list[float]]
    first_error_step: int | None
    errors: list[PlanError]

    def summary(self) -> dict:
        return {
            "executable": self.executable, "complete": self.complete, "priority_ok": self.priority_ok,
            "valid": self.valid, "cost": self.cost, "claimed_cost_error": self.claimed_cost_error,
            "coverage": self.coverage, "delivered": self.delivered, "rescuable": self.rescuable,
            "first_error_step": self.first_error_step,
            "error_codes": [e.code for e in self.errors],
            "errors": [{"code": e.code, "step": e.step, "message": e.message} for e in self.errors],
            "pickup_minutes_by_group": self.pickup_minutes_by_group,
        }


# ------------------------------------------------------------------ names
_KIND_WORDS = ("village", "school", "healthpost", "post", "hospital", "temple", "junction",
               "base", "camp", "ground", "bazaar", "ward", "office", "settlement")


def _norm(s: str) -> str:
    return re.sub(r"[^a-z0-9]", "", s.lower())


class NameResolver:
    """Maps the free-text names a plan uses onto location ids."""

    def __init__(self, inst: Instance):
        self.names = {_norm(l.name): l.id for l in inst.locations}
        self.exact = dict(self.names)
        for l in inst.locations:
            self.exact.setdefault(_norm(l.id), l.id)

    def __call__(self, raw: str) -> str | None:
        n = _norm(raw)
        if n in self.exact:
            return self.exact[n]
        # "Chautara Health Post" -> "Chautara": accept only an unambiguous name
        # match whose leftover characters are generic kind words.
        hits = [(k, i) for k, i in self.names.items() if len(k) >= 3 and k in n]
        if len(hits) == 1:
            key, loc = hits[0]
            rest = n.replace(key, "", 1)
            for w in _KIND_WORDS + ("the", "of", "at"):
                rest = rest.replace(w, "")
            if rest == "":
                return loc
        return None


# ------------------------------------------------------------- validation
def validate(inst: Instance, plan: Plan) -> ValidationResult:
    resolve = NameResolver(inst)
    reach = reachable(inst)
    goal_locs = {l for l in inst.occupied() if l in reach}
    rescuable = {g: sum(inst.people.get(l, {}).get(g, 0) for l in goal_locs) for g in GROUPS}

    roads: dict[frozenset, list] = {}
    for r in inst.roads:
        roads.setdefault(r.key(), []).append(r)

    errors: list[PlanError] = []
    first_phys: int | None = None

    def err(code: str, step: int | None, msg: str) -> None:
        nonlocal first_phys
        errors.append(PlanError(code, step, msg))
        if code in PHYSICAL and first_phys is None:
            first_phys = step

    pos = inst.start
    t = 0.0
    onboard = {g: 0 for g in GROUPS}
    picked: set[str] = set()
    delivered = {g: 0 for g in GROUPS}
    waits: dict[str, list[float]] = {g: [] for g in GROUPS}

    for i, st in enumerate(plan.steps):
        a = st.action.lower()
        ids = [resolve(x) for x in st.args]
        for raw, rid in zip(st.args, ids):
            if rid is None:
                err("UNKNOWN_LOCATION", i, f"unknown location '{raw}'")
        if None in ids:
            if a == "move" and ids and ids[-1] is not None:
                pos = ids[-1]
            continue

        if a == "move":
            if len(ids) != 2:
                err("UNKNOWN_ACTION", i, f"move needs 2 locations, got {st.args}")
                continue
            src, dst = ids
            if src != pos:
                err("WRONG_ORIGIN", i, f"team is at {inst.name_of(pos)}, not {inst.name_of(src)}")
            rs = roads.get(frozenset((src, dst)), [])
            open_rs = [r for r in rs if r.open]
            if not rs:
                err("NO_ROAD", i, f"no road between {inst.name_of(src)} and {inst.name_of(dst)}")
            elif not open_rs:
                err("BLOCKED_ROAD", i, f"road {inst.name_of(src)}-{inst.name_of(dst)} is impassable")
            else:
                t += min(r.minutes for r in open_rs)
            pos = dst

        elif a == "pickup":
            if len(ids) != 1:
                err("UNKNOWN_ACTION", i, f"pickup needs 1 location, got {st.args}")
                continue
            (loc,) = ids
            if loc != pos:
                err("NOT_AT_LOCATION", i, f"cannot pick up at {inst.name_of(loc)}: team is at {inst.name_of(pos)}")
                continue
            if loc in picked:
                err("DUPLICATE_PICKUP", i, f"{inst.name_of(loc)} already evacuated")
                continue
            n = inst.headcount(loc)
            if n == 0:
                err("EMPTY_PICKUP", i, f"nobody is waiting at {inst.name_of(loc)}")
                continue
            load = sum(onboard.values())
            if inst.capacity is not None and load + n > inst.capacity:
                err("CAPACITY", i, f"{load} on board + {n} at {inst.name_of(loc)} exceeds capacity {inst.capacity}")
            if inst.priority == "tiered":
                k = inst.tier(loc)
                waiting = [l for l in goal_locs if l not in picked and (inst.tier(l) or 9) < k]
                if waiting:
                    names = ", ".join(sorted(inst.name_of(l) for l in waiting))
                    err("PRIORITY", i, f"picked up tier-{k} {inst.name_of(loc)} while higher-priority {names} still waiting")
            picked.add(loc)
            for g in GROUPS:
                c = inst.people[loc].get(g, 0)
                onboard[g] += c
                if first_phys is None:
                    waits[g].extend([t] * c)

        elif a == "dropoff":
            loc = ids[0] if len(ids) == 1 else None
            if loc is None:
                err("UNKNOWN_ACTION", i, f"dropoff needs 1 location, got {st.args}")
                continue
            if loc != pos:
                err("NOT_AT_LOCATION", i, f"cannot drop off at {inst.name_of(loc)}: team is at {inst.name_of(pos)}")
                continue
            if loc != inst.shelter:
                err("WRONG_DROPOFF", i, f"{inst.name_of(loc)} is not the shelter")
                continue
            if first_phys is None:
                for g in GROUPS:
                    delivered[g] += onboard[g]
            onboard = {g: 0 for g in GROUPS}
        else:
            err("UNKNOWN_ACTION", i, f"unknown action '{st.action}'")

    executable = first_phys is None
    total = sum(rescuable.values())
    got = sum(delivered.values())
    left = [l for l in goal_locs if l not in picked]
    if got < total:
        detail = []
        if left:
            detail.append("never picked up: " + ", ".join(sorted(inst.name_of(l) for l in left)))
        if sum(onboard.values()):
            detail.append(f"{sum(onboard.values())} people still on board at the end")
        err("NOT_DELIVERED", None, f"{total - got} of {total} rescuable people not delivered to shelter"
            + (" (" + "; ".join(detail) + ")" if detail else ""))
    complete = got >= total

    claimed = {}
    for raw in plan.unreachable:
        rid = resolve(raw)
        if rid is None:
            err("UNKNOWN_UNREACHABLE_NAME", None, f"unreachable list names unknown location '{raw}'")
        else:
            claimed[rid] = raw
    for rid in claimed:
        if rid in goal_locs:
            err("FALSE_UNREACHABLE", None, f"{inst.name_of(rid)} was declared unreachable but can be reached")
    truly_unreach = [l for l in inst.occupied() if l not in reach]
    for l in truly_unreach:
        if l not in claimed:
            err("UNREPORTED_UNREACHABLE", None, f"{inst.name_of(l)} is cut off but was not reported")

    priority_ok = not any(e.code == "PRIORITY" for e in errors)
    false_unreach = any(e.code == "FALSE_UNREACHABLE" for e in errors)
    valid = executable and complete and priority_ok and not false_unreach

    return ValidationResult(
        executable=executable,
        complete=complete,
        priority_ok=priority_ok,
        valid=valid,
        cost=t,
        claimed_cost_error=None if plan.claimed_minutes is None else plan.claimed_minutes - t,
        coverage=1.0 if total == 0 else got / total,
        delivered=delivered,
        rescuable=rescuable,
        pickup_minutes_by_group=waits,
        first_error_step=first_phys,
        errors=errors,
    )


# ---------------------------------------------------------------- parsing
class PlanParseError(ValueError):
    pass


def _candidate_objects(text: str):
    for block in reversed(re.findall(r"```(?:json)?\s*(.*?)```", text, flags=re.S)):
        try:
            yield json.loads(block)
        except json.JSONDecodeError:
            pass
    dec = json.JSONDecoder()
    for m in re.finditer(r"\{", text):
        try:
            obj, _ = dec.raw_decode(text[m.start():])
            yield obj
        except json.JSONDecodeError:
            continue


def plan_from_obj(obj: dict) -> Plan:
    steps = []
    for k, s in enumerate(obj["steps"]):
        a = str(s.get("action", "")).lower().strip()
        if a == "move":
            args = (s.get("from"), s.get("to"))
        elif a in ("pickup", "dropoff"):
            args = (s.get("location") or s.get("at"),)
        else:
            args = tuple(s.get("args", ()))
        if any(x is None for x in args):
            raise PlanParseError(f"step {k} is missing a location: {s}")
        steps.append(Step(a, tuple(str(x) for x in args)))
    claimed = obj.get("claimed_total_minutes")
    try:
        claimed = None if claimed is None else float(claimed)
    except (TypeError, ValueError):
        claimed = None
    return Plan(steps=steps, unreachable=[str(x) for x in obj.get("unreachable", []) or []],
                claimed_minutes=claimed)


def plan_to_obj(plan: Plan) -> dict:
    """Inverse of plan_from_obj: the canonical JSON plan format (docs/INTERFACE.md)."""
    steps = []
    for st in plan.steps:
        if st.action == "move":
            steps.append({"action": "move", "from": st.args[0], "to": st.args[1]})
        else:
            steps.append({"action": st.action, "location": st.args[0]})
    return {"steps": steps, "unreachable": plan.unreachable, "claimed_total_minutes": plan.claimed_minutes}


def parse_plan_json(text: str) -> Plan:
    last_err: Exception | None = None
    for obj in _candidate_objects(text):
        if isinstance(obj, dict) and isinstance(obj.get("steps"), list):
            try:
                return plan_from_obj(obj)
            except (PlanParseError, AttributeError, KeyError) as e:
                last_err = e
    raise PlanParseError(f"no JSON object with a 'steps' list found ({last_err})")


_MOVE = ("move", "drive", "travel", "go")
_PICK = ("pickup", "pick-up", "pick_up", "rescue", "load", "board", "evacuate")
_DROP = ("dropoff", "drop-off", "drop_off", "unload", "deliver", "disembark")


def parse_pddl_plan(text: str, name_map: dict[str, str] | None = None) -> Plan:
    """Adapter for planner output such as Fast Downward's sas_plan.

    Convention (see docs/INTERFACE.md): locations are the LAST argument(s) of each
    action, e.g. (move team from to), (pickup team loc), (dropoff team shelter).
    Extra arguments (the team/vehicle, groups) are ignored. `name_map` maps PDDL
    object names to instance ids/names if they differ.
    """
    name_map = {k.lower(): v for k, v in (name_map or {}).items()}
    steps = []
    for line in text.splitlines():
        line = line.split(";", 1)[0].strip()
        if not line.startswith("("):
            continue
        toks = line.strip("()").split()
        act, args = toks[0].lower(), [name_map.get(a.lower(), a) for a in toks[1:]]
        if any(act.startswith(m) for m in _PICK):
            steps.append(Step("pickup", tuple(args[-1:])))
        elif any(act.startswith(m) for m in _DROP):
            steps.append(Step("dropoff", tuple(args[-1:])))
        elif any(act.startswith(m) for m in _MOVE):
            steps.append(Step("move", tuple(args[-2:])))
        else:
            steps.append(Step(act, tuple(args)))
    return Plan(steps=steps)
