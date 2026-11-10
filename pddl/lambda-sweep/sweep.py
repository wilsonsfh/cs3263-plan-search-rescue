#!/usr/bin/env python3
"""Trade-off curve for the penalty  lambda x r_b  (main objective, no Fast Downward).

Cost = driving minutes + lambda x r_b per deferred person, where
r_b = relative risk of waiting (adult = 1) and lambda = driving minutes one
adult rescue is worth. The current penalties 80/60/50/20 are lambda = 20.

Solves each instance exactly by Dijkstra (fast for one-car instances) for a
range of lambda values and writes sweep-<size>.csv. lambda = 20 must reproduce the
Fast Downward references in ../results/best_reference.csv.

  python3 sweep.py                       # small-01..15, default lambdas
  python3 sweep.py --size medium --lambdas 10 40 80 --out sweep-medium.csv   # ~1-2 min per solve
  python3 sweep.py --lambdas 10 20 40 --ids small-01 small-02
"""

import argparse
import csv
import heapq
import json
from pathlib import Path

HERE = Path(__file__).parent
INST = HERE.parent / "instances"
BANDS = ("injured", "child", "elderly", "adult")
R = {"injured": 4, "child": 3, "elderly": 2.5, "adult": 1}
LAMBDAS = [0, 5, 10, 15, 20, 30, 40, 60, 80, 120, 1000]


def solve(inst, lam):
    """Optimal plan for driving + lam x r_b per deferred person."""
    adj = {}
    for r in inst["roads"]:
        if not r["damaged"]:
            adj.setdefault(r["from"], []).append((r["to"], r["minutes"]))
            adj.setdefault(r["to"], []).append((r["from"], r["minutes"]))
    evac = {l["id"] for l in inst["locations"] if l["evac"]}
    cars = [c["id"] for c in inst["cars"]]
    seats = [c["seats"] for c in inst["cars"]]
    keys = [(p["location"], p["band"]) for p in inst["people"]]
    start = (tuple(c["start"] for c in inst["cars"]),
             tuple(p["count"] for p in inst["people"]),
             tuple((0,) * 4 for _ in cars))
    dist, prev, pq, tie = {start: 0}, {}, [(0, 0, start)], 0
    while pq:
        d, _, s = heapq.heappop(pq)
        if d > dist[s]:
            continue
        pos, wt, ins = s
        if not any(wt) and not any(any(c) for c in ins):
            plan = []
            while s in prev:
                s, step = prev[s]
                plan.append(step)
            return d, plan[::-1]
        nxt = []
        for ci, car in enumerate(cars):
            here = pos[ci]
            for to, m in adj.get(here, []):
                nxt.append(((pos[:ci] + (to,) + pos[ci + 1:], wt, ins), m, ("drive", car, m)))
            free = seats[ci] - sum(ins[ci])
            for ki, (loc, b) in enumerate(keys):
                if loc == here and wt[ki]:
                    for n in range(1, min(wt[ki], free) + 1):
                        c2 = list(ins[ci]); c2[BANDS.index(b)] += n
                        nxt.append(((pos, wt[:ki] + (wt[ki] - n,) + wt[ki + 1:],
                                     ins[:ci] + (tuple(c2),) + ins[ci + 1:]), 0, ("load",)))
            if here in evac:
                for bi, n in enumerate(ins[ci]):
                    if n:
                        c2 = list(ins[ci]); c2[bi] = 0
                        nxt.append(((pos, wt, ins[:ci] + (tuple(c2),) + ins[ci + 1:]), 0,
                                    ("unload", BANDS[bi], n)))
        for ki, (loc, b) in enumerate(keys):
            if wt[ki]:
                nxt.append(((pos, wt[:ki] + (0,) + wt[ki + 1:], ins), lam * R[b] * wt[ki],
                            ("defer", b, wt[ki])))
        for s2, c, step in nxt:
            if d + c < dist.get(s2, float("inf")):
                dist[s2] = d + c
                prev[s2] = (s, step)
                tie += 1
                heapq.heappush(pq, (d + c, tie, s2))
    return None, []


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ids", nargs="+")
    ap.add_argument("--lambdas", nargs="+", type=float, default=LAMBDAS)
    ap.add_argument("--size", default="small")
    ap.add_argument("--out", default="sweep-small.csv")
    args = ap.parse_args()
    ids = args.ids or sorted(p.stem for p in INST.glob(f"{args.size}-*.json"))
    rows = []
    for iid in ids:
        inst = json.loads((INST / f"{iid}.json").read_text())
        for lam in args.lambdas:
            cost, plan = solve(inst, lam)
            drive = sum(s[2] for s in plan if s[0] == "drive")
            dfr = {b: sum(s[2] for s in plan if s[0] == "defer" and s[1] == b) for b in BANDS}
            rows.append({"id": iid, "lambda": lam, "cost": round(cost, 1), "driving": drive,
                         "deferred": sum(dfr.values()), **{f"deferred_{b}": dfr[b] for b in BANDS}})
            print(rows[-1], flush=True)
    with open(HERE / args.out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)


if __name__ == "__main__":
    main()
