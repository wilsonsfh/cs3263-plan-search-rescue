#!/usr/bin/env python3
"""lambda sweep with ../exact.py (handles medium and large; sweep.py only managed small).

  python3 sweep_exact.py --size medium --out sweep-medium.csv
  python3 sweep_exact.py --size large --lambdas 10 40 80 --out sweep-large.csv
"""
import argparse, copy, csv, json, sys, time
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
import exact  # noqa: E402

RISK = {"injured": 4, "child": 3, "elderly": 2.5, "adult": 1}
BANDS = ("injured", "child", "elderly", "adult")

ap = argparse.ArgumentParser()
ap.add_argument("--size", required=True)
ap.add_argument("--lambdas", nargs="+", type=float, default=[0, 5, 10, 15, 20, 30, 40, 60, 80, 120])
ap.add_argument("--out", required=True)
args = ap.parse_args()

rows = []
for f in sorted((HERE.parent / "instances").glob(f"{args.size}-*.json")):
    base = json.loads(f.read_text())
    for lam in args.lambdas:
        inst = copy.deepcopy(base)
        inst["penalty_per_person"] = {b: lam * r for b, r in RISK.items()}
        t = time.time()
        cost, plan, _ = exact.solve(inst)
        tt = {}
        for r in inst["roads"]:
            tt[(r["from"], r["to"])] = tt[(r["to"], r["from"])] = r["minutes"]
        drive = sum(tt[(w[2], w[3])] for w in map(str.split, plan) if w and w[0] == "drive")
        dfr = {b: sum(int(w[3]) for w in map(str.split, plan) if w and w[0] == "defer" and w[2] == b) for b in BANDS}
        rows.append({"id": base["id"], "lambda": lam, "cost": round(cost, 1), "driving": drive,
                     "deferred": sum(dfr.values()), **{f"deferred_{b}": dfr[b] for b in BANDS},
                     "seconds": round(time.time() - t, 1), "status": "ok"})
        print(rows[-1], flush=True)
        with open(HERE / args.out, "w", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
