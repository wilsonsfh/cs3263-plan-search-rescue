"""Exact optimal solver used as the reference ("oracle") for optimality gaps.

Uniform-cost search over macro-states (position, set picked up, load) on the
metric closure of the open road network: from any state the only decisions that
matter are "drive (by a shortest path) to an unvisited stranded location and
pick everyone up" or "drive to the shelter and drop off". Driving *through* a
location without stopping is already covered by the shortest paths, so this is
exact for the formal model in schema.py.

State space bound: |K| * 2^k * (C+1) where k = rescuable locations and
K = k + {start, shelter}; this is the quantity discussed in the report's
complexity analysis. Independent of PDDL, so it also cross-checks the
planner pipeline.
"""
from __future__ import annotations

import heapq
import itertools
import time
from dataclasses import dataclass

from .graph import adjacency, dijkstra, path, reachable
from .schema import Instance
from .validator import Plan, Step


@dataclass
class OracleResult:
    cost: float | None  # None if no plan exists (e.g. a group larger than the vehicle)
    plan: Plan | None
    expanded: int
    state_bound: int
    seconds: float


def solve(inst: Instance, priority: str | None = None) -> OracleResult:
    t0 = time.perf_counter()
    priority = priority or inst.priority
    adj = adjacency(inst)
    reach = reachable(inst)
    goals = [l for l in inst.occupied() if l in reach]
    unreachable = [inst.name_of(l) for l in inst.occupied() if l not in reach]
    k = len(goals)
    cap = inst.capacity
    n = [inst.headcount(g) for g in goals]
    tiers = [inst.tier(g) for g in goals]
    full = (1 << k) - 1
    bound = (k + 2) * (1 << k) * ((cap + 1) if cap else 2)

    if cap is not None and any(x > cap for x in n):
        return OracleResult(None, None, 0, bound, time.perf_counter() - t0)

    keys = list(dict.fromkeys([inst.start, inst.shelter, *goals]))
    sp = {u: dijkstra(adj, u) for u in keys}  # u -> (dist, prev)

    def d(u: str, v: str) -> float:
        return sp[u][0].get(v, float("inf"))

    def allowed(j: int, mask: int) -> bool:
        if priority != "tiered":
            return True
        return all(mask >> i & 1 or tiers[i] >= tiers[j] for i in range(k))

    start = (inst.start, 0, 0)
    best = {start: 0.0}
    parent: dict[tuple, tuple[tuple, str, int | None]] = {}
    tie = itertools.count()
    pq = [(0.0, next(tie), start)]
    expanded = 0
    goal_state = None
    while pq:
        g, _, s = heapq.heappop(pq)
        if g > best.get(s, float("inf")):
            continue
        expanded += 1
        pos, mask, load = s
        if mask == full and load == 0:
            goal_state = s
            break
        succ = []
        for j in range(k):
            if mask >> j & 1 or not allowed(j, mask):
                continue
            nl = load + n[j]
            if cap is not None and nl > cap:
                continue
            succ.append(((goals[j], mask | 1 << j, nl if cap is not None else 1), d(pos, goals[j]), "pickup", j))
        if load > 0:
            succ.append(((inst.shelter, mask, 0), d(pos, inst.shelter), "dropoff", None))
        for ns, c, act, j in succ:
            ng = g + c
            if ng < best.get(ns, float("inf")):
                best[ns] = ng
                parent[ns] = (s, act, j)
                heapq.heappush(pq, (ng, next(tie), ns))

    secs = time.perf_counter() - t0
    if goal_state is None:
        return OracleResult(None, None, expanded, bound, secs)

    macro = []
    s = goal_state
    while s != start:
        ps, act, j = parent[s]
        macro.append((ps[0], s[0], act))
        s = ps
    macro.reverse()

    steps: list[Step] = []
    for src, dst, act in macro:
        nodes = path(sp[src][1], src, dst) if src != dst else [src]
        steps += [Step("move", (inst.name_of(a), inst.name_of(b))) for a, b in zip(nodes, nodes[1:])]
        steps.append(Step(act, (inst.name_of(dst),)))
    plan = Plan(steps=steps, unreachable=unreachable, claimed_minutes=best[goal_state])
    return OracleResult(best[goal_state], plan, expanded, bound, secs)
