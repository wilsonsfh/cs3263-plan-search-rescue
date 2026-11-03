#!/usr/bin/env python3
"""Solve every generated instance with Fast Downward and check plans with VAL.

Tries two optimal searches first (A* with LM-cut, then A* with
merge-and-shrink, which copes better with the people counts). If both time
out, falls back to anytime LAMA (seq-sat-lama-2011), which keeps improving its plan until the
time limit, so large instances still get a good reference plan. Those
results are marked as not proven optimal.

Writes <instances>/<id>.plan and <instances>/../results/reference.csv.

Usage:
  FD=/path/to/downward/fast-downward.py VAL=/path/to/VAL/bin/Validate \
    python3 solve.py [--timeout 300] [--jobs 4] [instance ids...]
  # no-split comparison:
  python3 solve.py --domain no-split/domain.pddl --instances no-split/instances
"""

import argparse
import csv
import os
import re
import subprocess
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).parent
DOMAIN = HERE / "domain.pddl"
FD = os.environ.get("FD", "fast-downward.py")
VAL = os.environ.get("VAL", "Validate")

MS = ("astar(merge_and_shrink(shrink_strategy=shrink_bisimulation(greedy=false),"
      "merge_strategy=merge_sccs(order_of_sccs=topological,merge_selector=score_based_filtering("
      "scoring_functions=[goal_relevance(),dfp(),total_order()])),"
      "label_reduction=exact(before_shrinking=true,before_merging=false),"
      "max_states=50000,threshold_before_merge=1))")

SEARCHES = [
    ("optimal-lmcut", ["--search", "astar(lmcut())"]),
    ("optimal-ms", ["--search", MS]),
    ("lama-anytime", ["--alias", "seq-sat-lama-2011"]),
]


def run_fd(domain, problem, args, timeout, workdir):
    cmd = ["python3", FD, "--overall-time-limit", f"{timeout}s"]
    if args[0] == "--alias":
        cmd += args + [str(domain), str(problem)]
    else:
        cmd += [str(domain), str(problem)] + args
    t0 = time.time()
    out = subprocess.run(cmd, cwd=workdir, capture_output=True, text=True,
                         timeout=timeout + 60).stdout
    elapsed = time.time() - t0
    # Anytime search writes sas_plan.1, sas_plan.2, ... (each better); take the last.
    plans = sorted(Path(workdir).glob("sas_plan*"),
                   key=lambda p: int(p.suffix[1:]) if p.suffix[1:].isdigit() else 0)
    if not plans:
        return None, elapsed, None
    expanded = re.findall(r"Expanded (\d+) state", out)
    return plans[-1].read_text(), elapsed, int(expanded[-1]) if expanded else None


def validate(domain, problem, plan_file):
    out = subprocess.run([VAL, str(domain), str(problem), str(plan_file)],
                         capture_output=True, text=True).stdout
    m = re.search(r"Value: (\d+)", out)
    return "Plan valid" in out, int(m.group(1)) if m else None


def solve_one(job):
    domain, prob, timeout = job
    row = {"id": prob.stem, "search": "none", "optimal": False, "cost": "",
           "seconds": "", "expanded": "", "valid": False, "deferred": "", "actions": ""}
    for name, fd_args in SEARCHES:
        with tempfile.TemporaryDirectory() as tmp:
            plan, secs, expanded = run_fd(domain, prob, fd_args, timeout, tmp)
        if plan is None:
            continue
        plan_file = prob.with_suffix(".plan")
        plan_file.write_text(plan)
        valid, cost = validate(domain, prob, plan_file)
        steps = [l for l in plan.splitlines() if l.startswith("(")]
        row.update(search=name, optimal=name.startswith("optimal"), cost=cost,
                   seconds=round(secs, 2), expanded=expanded, valid=valid,
                   deferred=sum(s.startswith("(defer-rescue") for s in steps),
                   actions=len(steps))
        break
    print(", ".join(f"{k}={v}" for k, v in row.items()), flush=True)
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ids", nargs="*")
    ap.add_argument("--timeout", type=int, default=300, help="seconds per search")
    ap.add_argument("--jobs", type=int, default=1, help="instances solved in parallel")
    ap.add_argument("--domain", default=str(DOMAIN))
    ap.add_argument("--instances", default=str(HERE / "instances"))
    args = ap.parse_args()

    domain, inst_dir = Path(args.domain).resolve(), Path(args.instances).resolve()
    problems = sorted(inst_dir.glob("*.pddl"))
    if args.ids:
        problems = [p for p in problems if p.stem in args.ids]
    jobs = [(domain, p, args.timeout) for p in problems]
    if args.jobs > 1:
        from multiprocessing import Pool
        with Pool(args.jobs) as pool:
            rows = pool.map(solve_one, jobs, chunksize=1)
    else:
        rows = [solve_one(j) for j in jobs]

    res = inst_dir.parent / "results"
    res.mkdir(exist_ok=True)
    with open(res / "reference.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)


if __name__ == "__main__":
    main()
