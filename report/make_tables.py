#!/usr/bin/env python3
"""Build the LaTeX tables for the optimal-reference section from the result CSVs.

  python3 report/make_tables.py

Reads pddl/results/best_reference.csv, pddl/results/reference.csv (Fast Downward, splitting
domain), report/exact-timings.csv and report/old_best_reference.csv (see report/README.md),
and writes report/tables/*.tex. Checks every exact.py cost against best_reference.csv.
"""
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "report" / "tables"
SIZES = ("small", "medium", "large")


def rows(p):
    return {r["id"]: r for r in csv.DictReader(open(p))}


best = rows(ROOT / "pddl/results/best_reference.csv")
fd = rows(ROOT / "pddl/results/reference.csv")
old = rows(ROOT / "report/old_best_reference.csv")
ex = rows(ROOT / "report/exact-timings.csv")
ids = sorted(best, key=lambda i: (SIZES.index(i.split("-")[0]), i))
for i in ids:
    assert int(ex[i]["cost"]) == int(best[i]["best_cost"]), i
    if fd[i]["optimal"] == "True":
        assert int(fd[i]["cost"]) == int(best[i]["best_cost"]), i


def proof(i):
    return {"optimal-lmcut": "LM-cut", "optimal-ms": "M\\&S"}.get(fd[i]["search"], "\\textbf{exact.py}")


OUT.mkdir(parents=True, exist_ok=True)

# 1. Summary per size
lines = [r"\begin{tabular}{lrrrrr}", r"\toprule",
         r" & \multicolumn{2}{c}{Fast Downward} & \multicolumn{3}{c}{\texttt{exact.py}} \\",
         r"\cmidrule(lr){2-3}\cmidrule(lr){4-6}",
         r"Size & proven & by LM-cut / M\&S & proven & max time (s) & max states \\", r"\midrule"]
for s in SIZES:
    I = [i for i in ids if i.startswith(s)]
    pr = [i for i in I if fd[i]["optimal"] == "True"]
    lm = sum(fd[i]["search"] == "optimal-lmcut" for i in I)
    ms = sum(fd[i]["search"] == "optimal-ms" for i in I)
    et = max(float(ex[i]["seconds"]) for i in I)
    st = max(int(ex[i]["states"]) for i in I)
    ets = "$<$0.1" if et < 0.1 else f"{et:.1f}"
    lines.append(f"{s.capitalize()} & {len(pr)}/15 & {lm} / {ms} & 15/15 & {ets} & {st:,} \\\\".replace(",", "{,}"))
tot = sum(fd[i]["optimal"] == "True" for i in ids)
lines += [r"\midrule", f"All & {tot}/45 & & 45/45 & & \\\\", r"\bottomrule", r"\end{tabular}"]
(OUT / "proof-summary.tex").write_text("\n".join(lines) + "\n")

# 2. The instances Fast Downward could not prove
lines = [r"\begin{tabular}{lrrrrr}", r"\toprule",
         r"Instance & Optimum & FD split (LAMA) & gap & Old reference & gap \\", r"\midrule"]
gaps_l, gaps_o = [], []
for i in ids:
    if fd[i]["optimal"] == "True":
        continue
    o = int(best[i]["best_cost"]); l = int(fd[i]["cost"]); b = int(old[i]["best_cost"])
    gl, go = 100 * (l / o - 1), 100 * (b / o - 1)
    gaps_l.append(gl); gaps_o.append(go)
    lines.append(f"{i} & {o} & {l} & {gl:.0f}\\% & {b} & {go:.0f}\\% \\\\")
lines += [r"\midrule",
          f"Mean & & & {sum(gaps_l)/len(gaps_l):.0f}\\% & & {sum(gaps_o)/len(gaps_o):.0f}\\% \\\\",
          r"\bottomrule", r"\end{tabular}"]
(OUT / "unproven.tex").write_text("\n".join(lines) + "\n")

# 3. All 45 optimal costs, three blocks side by side (appendix)
lines = [r"\begin{tabular}{lrl@{\hspace{1.2em}}lrl@{\hspace{1.2em}}lrl}", r"\toprule",
         " & ".join([r"Instance & Cost & Proof"] * 3) + r" \\", r"\midrule"]
for k in range(15):
    cells = []
    for s in SIZES:
        i = f"{s}-{k+1:02d}"
        cells += [i, best[i]["best_cost"], proof(i)]
    lines.append(" & ".join(cells) + r" \\")
lines += [r"\bottomrule", r"\end{tabular}"]
(OUT / "all-optima.tex").write_text("\n".join(lines) + "\n")
print("wrote", *sorted(p.name for p in OUT.glob("*.tex")))
