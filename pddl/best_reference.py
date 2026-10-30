#!/usr/bin/env python3
"""Pick the best known reference plan for each instance.

Any no-split plan is also a valid plan when people may be split, so the true
optimum with splitting is never worse than the no-split one. When the search
on the splitting domain times out, its LAMA plan can be worse than the
no-split plan, so the reference is the cheaper of the two.

Writes instances/<id>.best-plan (in the checker's plain format) and
results/best_reference.csv with best_cost, best_source and whether it is
proven optimal for the splitting domain.

Run after solve.py (and after solving no-split/ with the same tools).
"""

import csv
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent / "pipelines"))
from checker import check, normalise  # noqa: E402


def plain(lines):
    return [" ".join(map(str, [a] + args)) for a, args in
            (normalise(l) for l in lines if l.startswith("("))]


def nosplit_to_plain(lines, inst):
    groups = {g["id"]: g for g in inst["groups"]}
    out = []
    for l in lines:
        if not l.startswith("("):
            continue
        w = l.strip("()").split()
        if w[0] == "drive":
            out.append(" ".join(w))
        elif w[0] in ("load", "unload"):
            g = groups[w[2]]
            out.append(f"{w[0]} {w[1]} {g['band']} {g['size']}")
        elif w[0] == "defer-rescue":
            g = groups[w[1]]
            out.append(f"defer {g['location']} {g['band']} {g['size']}")
    return out


def main():
    split = {r["id"]: r for r in csv.DictReader(open(HERE / "results" / "reference.csv"))}
    rows = []
    for jid in sorted(split):
        inst = json.loads((HERE / "instances" / f"{jid}.json").read_text())
        cands = []
        p = HERE / "instances" / f"{jid}.plan"
        if p.exists():
            cands.append(("split-" + split[jid]["search"], plain(p.read_text().splitlines())))
        q = HERE / "no-split" / "instances" / f"{jid}.plan"
        if q.exists():
            cands.append(("no-split", nosplit_to_plain(q.read_text().splitlines(), inst)))
        scored = []
        for src, lines in cands:
            r = check(inst, lines)
            if r["valid"]:
                scored.append((r["cost"], src, lines))
        cost, src, lines = min(scored, key=lambda t: t[0])
        (HERE / "instances" / f"{jid}.best-plan").write_text("\n".join(lines) + "\n")
        rows.append({"id": jid, "best_cost": cost, "best_source": src,
                     "proven_optimal": split[jid]["optimal"] == "True" and src.startswith("split-optimal"),
                     "split_cost": split[jid]["cost"], "split_search": split[jid]["search"],
                     "split_seconds": split[jid]["seconds"]})
    with open(HERE / "results" / "best_reference.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {len(rows)} rows to results/best_reference.csv")


if __name__ == "__main__":
    main()
