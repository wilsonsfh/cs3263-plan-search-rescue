#!/usr/bin/env python3
"""Plan checker shared by both pipelines.

Replays a plan against an instance's ground-truth JSON and reports whether it
is valid, its total cost (driving minutes + deferral penalties), and the first
error if it is not valid. Both pipelines are scored with this one checker, so
their numbers are directly comparable.

Plan format (one action per line, ground-truth ids, band = injured/child/elderly/adult):
    drive <car> <from> <to>
    load <car> <band> <count>          picks up at the car's current location
    unload <car> <band> <count>        drops off at the car's current location
    defer <location> <band> <count>
Fast Downward plan lines for domain.pddl, e.g. "(load car1 loc child n2 ...)"
or "(defer-rescue loc adult n3)", are accepted too and converted.
"""

import json
import re
import sys

BANDS = ("injured", "child", "elderly", "adult")


def num(tok):
    return int(re.sub(r"^n", "", tok))


def normalise(line):
    """Turn one plan line into (action, args) or None for blank/comment lines."""
    line = line.strip()
    if not line or line.startswith(";") or line.startswith("#"):
        return None
    pddl = line.startswith("(")
    parts = line.strip("()").lower().replace(",", " ").split()
    act, args = parts[0], parts[1:]
    if pddl:
        # Fast Downward / domain.pddl argument orders
        if act == "load":            # car loc band m w rest k k2 f f2
            return "load", [args[0], args[2], num(args[3])]
        if act == "unload":          # car loc band k f f2
            return "unload", [args[0], args[2], num(args[3])]
        if act == "defer-rescue":    # loc band w
            return "defer", [args[0], args[1], num(args[2])]
        return act, args
    if act in ("load", "unload", "defer") and args:
        try:
            args = args[:-1] + [num(args[-1])]
        except ValueError:
            pass
    return act, args


def check(instance, plan_lines):
    roads = {}
    for r in instance["roads"]:
        roads[(r["from"], r["to"])] = r
        roads[(r["to"], r["from"])] = r
    evac = {l["id"] for l in instance["locations"] if l["evac"]}
    pen = instance["penalty_per_person"]
    car_at = {c["id"]: c["start"] for c in instance["cars"]}
    seats = {c["id"]: c["seats"] for c in instance["cars"]}
    waiting = {(p["location"], p["band"]): p["count"] for p in instance["people"]}
    inside = {(c, b): 0 for c in car_at for b in BANDS}
    rescued = {b: 0 for b in BANDS}
    deferred = {b: 0 for b in BANDS}
    travel = 0

    def finish(valid, error=""):
        penalty = sum(deferred[b] * pen[b] for b in BANDS)
        return {
            "valid": valid, "error": error,
            "cost": travel + penalty if valid else None,
            "travel_minutes": travel, "deferred_penalty": penalty,
            "rescued": dict(rescued), "deferred": dict(deferred),
            "people_rescued": sum(rescued.values()),
            "priority_people_rescued": rescued["injured"] + rescued["child"] + rescued["elderly"],
        }

    def fail(i, msg):
        return finish(False, f"step {i}: {msg}")

    try:
        steps = [s for s in (normalise(l) for l in plan_lines) if s]
    except (IndexError, ValueError) as e:
        return finish(False, f"could not read plan: {e}")

    for i, (act, args) in enumerate(steps, 1):
        if act == "drive":
            if len(args) != 3:
                return fail(i, f"drive needs 3 arguments, got {args}")
            car, a, b = args
            if car not in car_at:
                return fail(i, f"unknown car {car}")
            if car_at[car] != a:
                return fail(i, f"{car} is at {car_at[car]}, not {a}")
            r = roads.get((a, b))
            if r is None:
                return fail(i, f"no road between {a} and {b}")
            if r["damaged"]:
                return fail(i, f"road {a}-{b} is damaged")
            car_at[car] = b
            travel += r["minutes"]
        elif act in ("load", "unload"):
            if len(args) != 3 or not isinstance(args[2], int):
                return fail(i, f"{act} needs <car> <band> <count>, got {args}")
            car, band, n = args
            if car not in car_at or band not in BANDS or n <= 0:
                return fail(i, f"bad {act} arguments {args}")
            loc = car_at[car]
            if act == "load":
                if waiting.get((loc, band), 0) < n:
                    return fail(i, f"only {waiting.get((loc, band), 0)} {band} waiting at {loc}, cannot load {n}")
                free = seats[car] - sum(inside[(car, b)] for b in BANDS)
                if n > free:
                    return fail(i, f"{car} has {free} free seats, cannot load {n}")
                waiting[(loc, band)] -= n
                inside[(car, band)] += n
            else:
                if inside[(car, band)] < n:
                    return fail(i, f"{car} carries {inside[(car, band)]} {band}, cannot unload {n}")
                if loc not in evac:
                    return fail(i, f"{loc} is not an evacuation point")
                inside[(car, band)] -= n
                rescued[band] += n
        elif act == "defer":
            if len(args) != 3 or not isinstance(args[2], int):
                return fail(i, f"defer needs <location> <band> <count>, got {args}")
            loc, band, n = args
            if band not in BANDS or n <= 0 or waiting.get((loc, band), 0) < n:
                return fail(i, f"cannot defer {n} {band} at {loc} ({waiting.get((loc, band), 0)} waiting)")
            waiting[(loc, band)] -= n
            deferred[band] += n
        else:
            return fail(i, f"unknown action '{act}'")

    left = [f"{n} {b} at {l}" for (l, b), n in waiting.items() if n] + \
           [f"{n} {b} in {c}" for (c, b), n in inside.items() if n]
    if left:
        return finish(False, "plan ends with people unresolved: " + ", ".join(left))
    return finish(True)


if __name__ == "__main__":
    # python3 checker.py instance.json plan.txt
    inst = json.load(open(sys.argv[1]))
    print(json.dumps(check(inst, open(sys.argv[2]).read().splitlines()), indent=2))
