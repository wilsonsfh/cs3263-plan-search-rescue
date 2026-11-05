#!/usr/bin/env python3
"""Exact solver for the splittable flood-rescue domain (same semantics as pddl/domain.pddl).

Reduction (all exact):
- Cars never interact except through who is picked up, and the cost is a plain sum,
  so we plan car 1's whole route, then car 2's, and so on.
- Unloading is free, so a car's route splits into trips: start/evac -> pickup sites -> evac.
  Driving between stops uses shortest paths on undamaged roads.
- At one site, taking a higher-penalty person instead of a lower one is never worse,
  so the state only needs how many people have been taken from each site.
- Taking one more person on a trip that already visits the site is never worse,
  so each trip fills min(seats, people available at its sites).
Dijkstra over (car, position, taken-per-site); whatever is left at the end is deferred.
"""
import json, sys, heapq, itertools

BANDS = ("injured", "child", "elderly", "adult")

def solve(inst):
    locs = [l["id"] for l in inst["locations"]]
    idx = {l: i for i, l in enumerate(locs)}
    n = len(locs); INF = float("inf")
    d = [[INF]*n for _ in range(n)]; nxt = [[None]*n for _ in range(n)]
    for i in range(n): d[i][i] = 0; nxt[i][i] = i
    for r in inst["roads"]:
        if r["damaged"]: continue
        a, b, m = idx[r["from"]], idx[r["to"]], r["minutes"]
        if m < d[a][b]: d[a][b] = d[b][a] = m; nxt[a][b] = b; nxt[b][a] = a
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]; nxt[i][j] = nxt[i][k]
    def path(a, b):
        p = [a]
        while a != b: a = nxt[a][b]; p.append(a)
        return p
    evac = [idx[l["id"]] for l in inst["locations"] if l["evac"]]
    pen = inst["penalty_per_person"]
    # people per site, sorted by penalty (highest first)
    site_people = {}
    for p in inst["people"]:
        site_people.setdefault(idx[p["location"]], []).extend([p["band"]] * p["count"])
    sites = sorted(site_people)
    for s in sites: site_people[s].sort(key=lambda b: -pen[b])
    cap = [len(site_people[s]) for s in sites]
    # suffix penalty if `t` people already taken from site s
    rem_pen = [[sum(pen[b] for b in site_people[s][t:]) for t in range(len(site_people[s])+1)] for s in sites]
    cars = inst["cars"]
    # trip routing: best order over a subset of sites from p to e
    route_cache = {}
    def best_route(p, S, e):
        key = (p, S, e)
        if key not in route_cache:
            best = (INF, None)
            for perm in itertools.permutations(S):
                c = d[p][sites[perm[0]]]
                for a, b in zip(perm, perm[1:]): c += d[sites[a]][sites[b]]
                c += d[sites[perm[-1]]][e]
                if c < best[0]: best = (c, perm)
            route_cache[key] = best
        return route_cache[key]
    def allocations(S, avail, k):
        # c_s >= 1 for s in S, sum = k, c_s <= avail_s
        def rec(i, left):
            if i == len(S) - 1:
                if 1 <= left <= avail[i]: yield (left,)
                return
            for c in range(1, min(avail[i], left - (len(S)-1-i)) + 1):
                for rest in rec(i+1, left - c): yield (c,) + rest
        yield from rec(0, k)
    nsites = len(sites)
    start = (0, idx[cars[0]["start"]], (0,)*nsites)
    dist = {start: 0}; parent = {start: None}
    GOAL = (-1, -1, ()); cnt = itertools.count(); pq = [(0, next(cnt), start)]
    while pq:
        g, _, st = heapq.heappop(pq)
        if st == GOAL: break
        if g > dist.get(st, INF): continue
        ci, pos, taken = st
        succ = []
        # finish this car
        if ci + 1 < len(cars):
            succ.append(((ci+1, idx[cars[ci+1]["start"]], taken), 0, ("next",)))
        else:
            succ.append((GOAL, sum(rem_pen[i][taken[i]] for i in range(nsites)), ("defer",)))
        open_sites = [i for i in range(nsites) if taken[i] < cap[i] and d[pos][sites[i]] < INF]
        seats = cars[ci]["seats"]
        for size in range(1, seats + 1):
            for S in itertools.combinations(open_sites, size):
                avail = [cap[i] - taken[i] for i in S]
                k = min(seats, sum(avail))
                for e in evac:
                    c, perm = best_route(pos, S, e)
                    if c == INF: continue
                    for alloc in allocations(S, avail, k):
                        nt = list(taken)
                        for i, a in zip(S, alloc): nt[i] += a
                        succ.append(((ci, e, tuple(nt)), c, ("trip", perm, dict(zip(S, alloc)), e)))
        for ns, c, act in succ:
            ng = g + c
            if ng < dist.get(ns, INF):
                dist[ns] = ng; parent[ns] = (st, act); heapq.heappush(pq, (ng, next(cnt), ns))
    # rebuild plan
    acts = []; st = GOAL
    while parent[st] is not None:
        st, act = parent[st]; acts.append((st, act))
    acts.reverse()
    plan = []; taken = [0]*nsites
    for (ci, pos, _), act in acts:
        car = cars[ci]["id"]
        if act[0] == "trip":
            _, perm, alloc, e = act
            cur = pos; load = {}
            for i in perm:
                for a, b in zip(path(cur, sites[i]), path(cur, sites[i])[1:]):
                    plan.append(f"drive {car} {locs[a]} {locs[b]}")
                cur = sites[i]
                got = {}
                for b in site_people[sites[i]][taken[i]:taken[i]+alloc[i]]: got[b] = got.get(b, 0) + 1
                taken[i] += alloc[i]
                for b in BANDS:
                    if b in got:
                        plan.append(f"load {car} {b} {got[b]}"); load[b] = load.get(b, 0) + got[b]
            for a, b in zip(path(cur, e), path(cur, e)[1:]):
                plan.append(f"drive {car} {locs[a]} {locs[b]}")
            for b in BANDS:
                if b in load: plan.append(f"unload {car} {b} {load[b]}")
        elif act[0] == "defer":
            for i in range(nsites):
                left = {}
                for b in site_people[sites[i]][taken[i]:]: left[b] = left.get(b, 0) + 1
                for b in BANDS:
                    if b in left: plan.append(f"defer {locs[sites[i]]} {b} {left[b]}")
    return dist[GOAL], plan, len(dist)

if __name__ == "__main__":
    # usage: python3 exact.py instances/*.json   -> writes instances/<id>.exact-plan
    import time
    for f in sys.argv[1:]:
        t = time.time(); inst = json.load(open(f))
        cost, plan, ns = solve(inst)
        open(f.replace(".json", ".exact-plan"), "w").write("\n".join(plan) + "\n")
        print(inst["id"], "cost", cost, "states", ns, "seconds", round(time.time() - t, 1), flush=True)
