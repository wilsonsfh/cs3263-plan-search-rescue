"""Seeded generator of Nepal-inspired post-flood rescue instances.

Design choices (each is a knob so the evaluation can vary difficulty on purpose):
  * k occupied locations + a few junctions / already-evacuated villages, laid out in
    2-D; roads = Euclidean MST + nearest-neighbour shortcuts (sparse, hilly-road-like).
  * Travel minutes = distance x terrain factor, rounded to 5 minutes.
  * Flood damage is placed *where it matters*: blocked roads are drawn first from the
    pre-flood shortest-path tree out of the base, so a planner that misses a
    blockage will actually try to use the road.
  * Some open roads are slowed (waterlogged); their pre-flood time is kept so the
    report can say "twice the usual time".
  * Optional cut-off location (all its roads blocked) -> must be reported unreachable.
  * Capacity either unlimited or tight enough to force several shelter trips.
Place names are real Nepali toponyms used as labels only: the geography, roads
and people are synthetic. The name-swap probe in probes.py controls for the model
"knowing" real geography.
"""
from __future__ import annotations

import math
import random

from .graph import adjacency, dijkstra
from .schema import Instance, Location, Road

NAMES = [
    "Bidur", "Trishuli", "Betrawati", "Kakani", "Battar", "Ramche", "Kalikasthan", "Samundratar",
    "Taruka", "Likhu", "Belkot", "Tupche", "Khanigaun", "Thansing", "Gerkhu", "Chaughada",
    "Okharpauwa", "Kispang", "Meghang", "Tadi", "Suryagadhi", "Panchakanya", "Dupcheshwar",
    "Shikharbesi", "Bageshwari", "Lachyang", "Jiling", "Sundaradevi", "Ghyangphedi", "Madanpur",
    "Kumari", "Narjamandap", "Thaprek", "Chhap", "Rautbesi", "Bhalche", "Salme", "Haku",
    "Dhaibung", "Laharepauwa", "Bhorle", "Syaphru", "Goljung", "Thulogaun", "Kaule", "Dandagaun",
]
OCCUPIED_KINDS = ["village"] * 5 + ["school", "health_post", "temple", "ward_office"]
CAUSES = ["landslide", "bridge", "submerged", "debris"]


def _round5(x: float) -> int:
    return max(5, int(round(x / 5.0)) * 5)


def generate(k: int, seed: int, *, extra_nodes: int | None = None, capacity: str = "auto",
             unreachable: bool = False, n_blocked: int | None = None, n_slowed: int | None = None,
             priority: str = "tiered") -> Instance:
    rng = random.Random(f"{k}-{seed}-{capacity}-{unreachable}")
    extra = extra_nodes if extra_nodes is not None else rng.randint(1, 2 + k // 4)
    n_nodes = 1 + k + extra
    names = rng.sample(NAMES, n_nodes)
    ids = [n.lower() for n in names]

    pts = {ids[0]: (50.0, 50.0)}
    for i in ids[1:]:
        while True:
            p = (rng.uniform(0, 100), rng.uniform(0, 100))
            if all(math.dist(p, q) > 12 for q in pts.values()):
                pts[i] = p
                break

    kinds = {ids[0]: "base"}
    occ = ids[1:1 + k]
    for i in occ:
        kinds[i] = rng.choice(OCCUPIED_KINDS)
    for i in ids[1 + k:]:
        kinds[i] = rng.choice(["junction", "evacuated_village"])

    # --- road network: MST (Prim) + nearest-neighbour shortcuts
    edges: dict[frozenset, int] = {}

    def add(a: str, b: str) -> None:
        key = frozenset((a, b))
        if a != b and key not in edges:
            edges[key] = _round5(0.5 * math.dist(pts[a], pts[b]) * rng.uniform(0.9, 1.6))

    in_tree = {ids[0]}
    while len(in_tree) < n_nodes:
        a, b = min(((a, b) for a in in_tree for b in ids if b not in in_tree),
                   key=lambda e: math.dist(pts[e[0]], pts[e[1]]))
        add(a, b)
        in_tree.add(b)
    for a in ids:
        near = sorted((b for b in ids if b != a), key=lambda b: math.dist(pts[a], pts[b]))[:3]
        for b in near:
            if rng.random() < 0.45:
                add(a, b)

    roads = {key: Road(*sorted(key), minutes=m) for key, m in edges.items()}

    # --- people (each person in exactly one group; injured takes precedence)
    people: dict[str, dict[str, int]] = {}
    for i in occ:
        p = {"injured": 0, "children": 0, "elderly": 0, "adults": 0}
        kind = kinds[i]
        if rng.random() < (0.7 if kind == "health_post" else 0.3):
            p["injured"] = rng.randint(1, 3)
        p["children"] = rng.randint(3, 9) if kind == "school" else rng.choice([0, 0, 1, 2, 3, 4])
        p["elderly"] = rng.choice([0, 0, 1, 2, 3])
        p["adults"] = rng.randint(1, 6) if kind != "school" else rng.randint(1, 2)
        people[i] = {g: c for g, c in p.items() if c}

    inst = Instance(id=f"k{k}-s{seed}" + ("-cut" if unreachable else ""), locations=[
        Location(i, n, kinds[i]) for i, n in zip(ids, names)
    ], roads=[], people=people, start=ids[0], shelter=ids[0], priority=priority)

    # --- flood damage
    def connected_after(blocked: set[frozenset], must: list[str]) -> bool:
        inst.roads = [Road(r.u, r.v, r.minutes, open=key not in blocked) for key, r in roads.items()]
        dist, _ = dijkstra(adjacency(inst), inst.start)
        return all(m in dist for m in must)

    blocked: set[frozenset] = set()
    cut_loc = None
    if unreachable:
        # Cut off the occupied location with the fewest roads.
        deg = {i: sum(1 for key in roads if i in key) for i in occ}
        cut_loc = min(occ, key=lambda i: (deg[i], rng.random()))
        blocked |= {key for key in roads if cut_loc in key}
    must = [i for i in occ if i != cut_loc]

    inst.roads = [Road(r.u, r.v, r.minutes) for r in roads.values()]
    _, prev = dijkstra(adjacency(inst), inst.start)
    tree = [frozenset((v, u)) for v, u in prev.items()]
    rng.shuffle(tree)
    others = [key for key in roads if key not in tree]
    rng.shuffle(others)
    target = n_blocked if n_blocked is not None else 1 + k // 3
    added = 0
    for key in tree + others:
        if added >= target:
            break
        if key in blocked:
            continue
        if connected_after(blocked | {key}, must):
            blocked.add(key)
            added += 1

    open_keys = [key for key in roads if key not in blocked]
    rng.shuffle(open_keys)
    slowed = set(open_keys[: (n_slowed if n_slowed is not None else 1 + k // 4)])

    final = []
    for key, r in roads.items():
        if key in blocked:
            final.append(Road(r.u, r.v, r.minutes, open=False, cause=rng.choice(CAUSES)))
        elif key in slowed:
            new = r.minutes * 2 if rng.random() < 0.5 else r.minutes + rng.choice([10, 15, 20])
            final.append(Road(r.u, r.v, new, open=True, base_minutes=r.minutes, cause="waterlogged"))
        else:
            final.append(Road(r.u, r.v, r.minutes))
    # L3 history: some open roads were blocked earlier and since cleared; some
    # blocked roads were passable earlier; one intact road is the subject of a rumour.
    hist = []
    for r in final:
        roll = rng.random()
        if r.open and r.cause is None and roll < 0.2:
            r = Road(r.u, r.v, r.minutes, True, r.base_minutes, "debris", ("blocked", "cleared"))
        elif r.open and r.cause is None and roll < 0.3:
            r = Road(r.u, r.v, r.minutes, True, r.base_minutes, None, ("rumour",))
        elif not r.open and roll < 0.35:
            r = Road(r.u, r.v, r.minutes, False, r.base_minutes, r.cause, ("open", "blocked"))
        hist.append(r)
    inst.roads = sorted(hist, key=lambda r: (r.u, r.v))

    # --- capacity
    if capacity == "unlimited":
        inst.capacity = None
    else:
        biggest = max(inst.headcount(i) for i in occ)
        total = sum(inst.headcount(i) for i in occ)
        if capacity == "tight" or (capacity == "auto" and rng.random() < 0.5):
            inst.capacity = max(biggest, min(total - 1, biggest + rng.randint(0, biggest)))
        else:
            inst.capacity = None

    inst.meta = {"k": k, "seed": seed, "extra_nodes": extra, "n_roads": len(roads),
                 "n_blocked": len(blocked), "n_slowed": len(slowed), "cut_off": cut_loc,
                 "capacity_mode": "tight" if inst.capacity else "unlimited"}
    return inst


CONDITIONS = [("unlimited", False), ("tight", False), ("unlimited", True), ("tight", True)]


def suite(sizes=(4, 8, 12, 16), reps: int = 3) -> list[Instance]:
    """Default experimental suite: every size crossed with every condition
    {unlimited, tight capacity} x {all reachable, one place cut off}, replicated.
    Replicate 0 is the prompt-development split ('dev'); the rest is held-out 'test'
    (TA feedback: tune prompts on dev only, report numbers on test)."""
    out = []
    for k in sizes:
        for rep in range(reps):
            for c, (cap, cut) in enumerate(CONDITIONS):
                seed = rep * len(CONDITIONS) + c
                inst = generate(k, seed, unreachable=cut, capacity=cap)
                inst.id = f"k{k}-s{seed}-{'cap' if cap == 'tight' else 'inf'}{'-cut' if cut else ''}"
                inst.meta.update(split="dev" if rep == 0 else "test", rep=rep, condition=f"{cap}{'-cut' if cut else ''}")
                out.append(inst)
    return out
