#!/usr/bin/env python3
"""Instance generator for the flood-rescue domain (CS3263 Group 11).

Each instance is written twice:
  instances/<id>.json  ground truth (map, people, cars) used to write the
                       field reports, check LLM-only plans and score results
  instances/<id>.pddl  the PDDL problem for Fast Downward (domain.pddl)

People are generated as groups (one age band each) and then counted per
location and age band ("people" in the JSON), since the domain lets people
at one location be split across cars. The "groups" list is kept so that the
no-split comparison version (no-split/) can use the same instances.

Usage:
  python3 generate.py                        # default set: 3 sizes x 15 seeds
  python3 generate.py --sizes small --count 5 --seed 100
  python3 generate.py --lambda 40 --out instances-lambda40   # same instances, other penalties
"""

import argparse
import json
import math
import random
from pathlib import Path

# Deferral penalty per person = LAMBDA x RISK[band].
#   RISK:   urgency of each group relative to an adult (triage order: injured first).
#   LAMBDA: driving minutes worth spending to rescue one adult now rather than next wave.
# LAMBDA = 20 gives injured 80, child 60, elderly 50, adult 20. Change it with --lambda.
# Penalties are rounded to whole minutes (Fast Downward needs integer costs), so use an even LAMBDA.
RISK = {"injured": 4, "child": 3, "elderly": 2.5, "adult": 1}
LAMBDA = 20


def penalties(lam):
    return {b: round(lam * r) for b, r in RISK.items()}


PENALTY_PER_PERSON = penalties(LAMBDA)
BANDS = ["injured", "child", "elderly", "adult"]
CAR_SEATS = 4

# Size presets. Ranges are inclusive.
SIZES = {
    "small":  dict(locations=(5, 6),   evac=(1, 1), cars=(1, 1), groups=(3, 4),  damaged=0.15, extra_edges=0.3),
    "medium": dict(locations=(7, 9),   evac=(1, 2), cars=(1, 2), groups=(5, 7),  damaged=0.20, extra_edges=0.4),
    "large":  dict(locations=(10, 14), evac=(2, 2), cars=(2, 2), groups=(8, 12), damaged=0.25, extra_edges=0.5),
}

# Nepal-inspired place names (Nuwakot / Rasuwa / Dhading area).
PLACE_NAMES = [
    "Trishuli", "Bidur", "Kakani", "Belkot", "Dupcheshwar", "Tadi", "Likhu",
    "Kispang", "Myagang", "Tarkeshwar", "Panchakanya", "Shivapuri", "Suryagadhi",
    "Dhunche", "Syaphru", "Gosaikunda", "Naukunda", "Uttargaya", "Kalika",
    "Gajuri", "Galchhi", "Benighat", "Nilkantha", "Thakre", "Jwalamukhi",
]

# Non-evacuation location kinds and the age mix of people found there
# (weights for injured / child / elderly / adult).
KINDS = {
    "school":      (0.10, 0.65, 0.00, 0.25),
    "village":     (0.10, 0.27, 0.23, 0.40),
    "care-home":   (0.10, 0.00, 0.72, 0.18),
    "farm":        (0.10, 0.13, 0.13, 0.64),
    "temple":      (0.10, 0.09, 0.36, 0.45),
    "market":      (0.15, 0.13, 0.12, 0.60),
}
EVAC_KINDS = ["shelter", "hospital", "army-camp"]


def slug(text):
    return text.lower().replace(" ", "-")


def build_map(rng, n_locations, n_evac, damaged_frac, extra_frac):
    """Random geometric map: spanning tree plus some short extra roads.
    Travel time is Euclidean distance on a 60x60 km grid at ~1 min/km
    (slow, flood-damaged roads), rounded to whole minutes."""
    names = rng.sample(PLACE_NAMES, n_locations)
    kinds = EVAC_KINDS[:n_evac] + [rng.choice(list(KINDS)) for _ in range(n_locations - n_evac)]
    pts = [(rng.uniform(0, 60), rng.uniform(0, 60)) for _ in range(n_locations)]
    locs = [
        {"id": f"{slug(n)}-{k}", "name": n, "kind": k, "evac": k in EVAC_KINDS,
         "x": round(p[0], 1), "y": round(p[1], 1)}
        for n, k, p in zip(names, kinds, pts)
    ]

    def dist(i, j):
        return max(5, round(math.dist(pts[i], pts[j])))

    # Random spanning tree (each new node joins its nearest already-placed node).
    order = list(range(n_locations))
    rng.shuffle(order)
    edges = set()
    for k in range(1, n_locations):
        i = order[k]
        j = min(order[:k], key=lambda o: math.dist(pts[i], pts[o]))
        edges.add(tuple(sorted((i, j))))
    # Extra short roads so there are alternative routes around damage.
    candidates = sorted(
        (math.dist(pts[i], pts[j]), i, j)
        for i in range(n_locations) for j in range(i + 1, n_locations)
        if (i, j) not in edges
    )
    n_extra = round(extra_frac * n_locations)
    for _, i, j in candidates[: n_extra * 2]:
        if len(edges) >= n_locations - 1 + n_extra:
            break
        if rng.random() < 0.6:
            edges.add((i, j))

    roads = []
    for i, j in sorted(edges):
        roads.append({"from": locs[i]["id"], "to": locs[j]["id"],
                      "minutes": dist(i, j), "damaged": rng.random() < damaged_frac})
    return locs, roads


def build_groups(rng, locs, n_groups):
    """Place n_groups groups at random non-evacuation locations. Each group is
    one age band (drawn from the location kind's age mix) of 1..CAR_SEATS people."""
    sites = [l for l in locs if not l["evac"]]
    groups, seen = [], {}
    for _ in range(n_groups):
        loc = rng.choice(sites)
        band = rng.choices(BANDS, weights=KINDS[loc["kind"]])[0]
        size = rng.randint(1, CAR_SEATS)
        base = f"{loc['id']}-{band}"
        seen[base] = seen.get(base, 0) + 1
        gid = base if seen[base] == 1 else f"{base}-{seen[base]}"
        groups.append({"id": gid, "location": loc["id"], "band": band, "size": size,
                       "penalty": PENALTY_PER_PERSON[band] * size})
    return groups


def generate(size, seed):
    cfg = SIZES[size]
    rng = random.Random(f"{size}-{seed}")
    n_loc = rng.randint(*cfg["locations"])
    n_evac = rng.randint(*cfg["evac"])
    locs, roads = build_map(rng, n_loc, n_evac, cfg["damaged"], cfg["extra_edges"])
    groups = build_groups(rng, locs, rng.randint(*cfg["groups"]))
    evac_ids = [l["id"] for l in locs if l["evac"]]
    n_cars = rng.randint(*cfg["cars"])
    cars = [{"id": f"car{i + 1}", "start": evac_ids[i % len(evac_ids)], "seats": CAR_SEATS}
            for i in range(n_cars)]
    counts = {}
    for g in groups:
        counts[(g["location"], g["band"])] = counts.get((g["location"], g["band"]), 0) + g["size"]
    people = [{"location": l, "band": b, "count": n} for (l, b), n in counts.items()]
    return {
        "id": f"{size}-{seed:02d}", "size": size, "seed": seed,
        "lambda": LAMBDA, "risk": RISK,
        "penalty_per_person": PENALTY_PER_PERSON,
        "locations": locs, "roads": roads, "people": people, "cars": cars,
        "groups": groups,
    }


def to_pddl(inst):
    seats = max(c["seats"] for c in inst["cars"])
    top = max([seats] + [p["count"] for p in inst["people"]])
    levels = [f"n{i}" for i in range(1, top + 1)]          # n0 is a domain constant
    bands = BANDS
    L = []
    L.append(f";; Generated instance {inst['id']} (see {inst['id']}.json)")
    L.append(f"(define (problem flood-{inst['id']})")
    L.append("  (:domain flood-rescue)")
    L.append("  (:objects")
    L.append("    " + " ".join(l["id"] for l in inst["locations"]) + " - location")
    L.append("    " + " ".join(c["id"] for c in inst["cars"]) + " - car")
    L.append("    " + " ".join(levels) + " - level)")
    L.append("  (:init")
    for l in inst["locations"]:
        if l["evac"]:
            L.append(f"    (evac-point {l['id']})")
    for c in inst["cars"]:
        L.append(f"    (car-at {c['id']} {c['start']}) (free-seats {c['id']} n{c['seats']})"
                 + "".join(f" (carrying {c['id']} {b} n0)" for b in bands))
    for r in inst["roads"]:
        for a, b in ((r["from"], r["to"]), (r["to"], r["from"])):
            line = f"    (road {a} {b}) (= (travel-time {a} {b}) {r['minutes']})"
            if r["damaged"]:
                line += f" (damaged {a} {b})"
            L.append(line)
    for p in inst["people"]:
        L.append(f"    (waiting {p['location']} {p['band']} n{p['count']})")
    L.append("    " + " ".join(f"(sum n{a} n{b} n{a + b})"
                               for a in range(top + 1) for b in range(top + 1) if a + b <= top))
    L.append("    " + " ".join(f"(positive n{i})" for i in range(1, top + 1)))
    for b in bands:
        L.append("    " + " ".join(f"(= (defer-cost {b} n{n}) {inst['penalty_per_person'][b] * n})"
                                   for n in range(1, top + 1)))
    L.append("    (= (total-cost) 0))")
    goal = [f"(waiting {p['location']} {p['band']} n0)" for p in inst["people"]]
    goal += [f"(carrying {c['id']} {b} n0)" for c in inst["cars"] for b in bands]
    L.append("  (:goal (and " + " ".join(goal) + "))")
    L.append("  (:metric minimize (total-cost)))")
    return "\n".join(L) + "\n"


def set_lambda(lam):
    global LAMBDA, PENALTY_PER_PERSON
    LAMBDA = int(lam) if float(lam).is_integer() else lam
    PENALTY_PER_PERSON = penalties(lam)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sizes", nargs="+", default=list(SIZES), choices=list(SIZES))
    ap.add_argument("--count", type=int, default=15, help="instances per size")
    ap.add_argument("--seed", type=int, default=1, help="first seed")
    ap.add_argument("--out", default=str(Path(__file__).parent / "instances"))
    ap.add_argument("--lambda", dest="lam", type=float, default=LAMBDA,
                    help="minutes one adult rescue is worth (penalty = lambda x risk)")
    args = ap.parse_args()
    set_lambda(args.lam)

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    for size in args.sizes:
        for seed in range(args.seed, args.seed + args.count):
            inst = generate(size, seed)
            (out / f"{inst['id']}.json").write_text(json.dumps(inst, indent=2))
            (out / f"{inst['id']}.pddl").write_text(to_pddl(inst))
            print(f"{inst['id']}: {len(inst['locations'])} locations, {len(inst['roads'])} roads "
                  f"({sum(r['damaged'] for r in inst['roads'])} damaged), "
                  f"{sum(p['count'] for p in inst['people'])} people, {len(inst['cars'])} car(s)")


if __name__ == "__main__":
    main()
