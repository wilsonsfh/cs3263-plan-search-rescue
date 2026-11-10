#!/usr/bin/env python3
"""Report figures for the effect of lambda (penalty = lambda x r_b).

Reads sweep-small.csv, sweep-medium.csv and sweep-large.csv,
writes figures/*.pdf and *.png:
  tradeoff.*   driving vs reachable people left behind, one point per lambda
  who-left.*   reachable people left behind per group, by lambda (all 45 instances)

  pip install matplotlib && python3 figures.py
"""

import csv
import json
from collections import defaultdict
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = Path(__file__).parent
INST = HERE.parent / "instances"
OUT = HERE / "figures"
BANDS = ["injured", "child", "elderly", "adult"]
COLOR = {"injured": "#2a78d6", "child": "#eb6834", "elderly": "#1baf7a", "adult": "#eda100"}
INK, MUTED, GRID = "#1f1f1e", "#6b6a63", "#e4e3de"
HIGHLIGHT = 20

plt.rcParams.update({"font.size": 9, "axes.edgecolor": MUTED, "axes.labelcolor": INK,
                     "xtick.color": MUTED, "ytick.color": MUTED, "axes.spines.top": False,
                     "axes.spines.right": False, "pdf.fonttype": 42})


def unreachable_by_band(iid):
    """People no car can reach (damaged roads cut them off), per band."""
    inst = json.loads((INST / f"{iid}.json").read_text())
    adj = defaultdict(list)
    for r in inst["roads"]:
        if not r["damaged"]:
            adj[r["from"]].append(r["to"]); adj[r["to"]].append(r["from"])
    seen = {c["start"] for c in inst["cars"]}
    stack = list(seen)
    while stack:
        for v in adj[stack.pop()]:
            if v not in seen:
                seen.add(v); stack.append(v)
    out = dict.fromkeys(BANDS, 0)
    for p in inst["people"]:
        if p["location"] not in seen:
            out[p["band"]] += p["count"]
    return out


def ref20(iid):
    """Driving and deferrals per band of the lambda = 20 Fast Downward reference."""
    inst = json.loads((INST / f"{iid}.json").read_text())
    tt = {}
    for r in inst["roads"]:
        tt[(r["from"], r["to"])] = tt[(r["to"], r["from"])] = r["minutes"]
    row = {"driving": 0, **{f"deferred_{b}": 0 for b in BANDS}}
    for line in (INST / f"{iid}.best-plan").read_text().splitlines():
        w = line.split()
        if w and w[0] == "drive":
            row["driving"] += tt[(w[2], w[3])]
        elif w and w[0] == "defer":
            row[f"deferred_{w[2]}"] += int(w[3])
    return row


def load(name, add20):
    rows = [r for r in csv.DictReader(open(HERE / name)) if r.get("status", "ok") == "ok"]
    ok_ids = {r["id"] for r in rows}
    full = sorted(i for i in ok_ids if sum(r["id"] == i for r in rows) ==
                  max(sum(r["id"] == j for r in rows) for j in ok_ids))
    if add20:
        rows += [{"id": i, "lambda": "20", **{k: str(v) for k, v in ref20(i).items()}} for i in full]
    agg = defaultdict(lambda: {"driving": 0, **dict.fromkeys(BANDS, 0)})
    unr = {i: unreachable_by_band(i) for i in full}
    for r in rows:
        if r["id"] not in unr:
            continue
        a = agg[float(r["lambda"])]
        a["driving"] += int(float(r["driving"]))
        for b in BANDS:
            a[b] += int(float(r[f"deferred_{b}"])) - unr[r["id"]][b]
    return len(full), dict(sorted(agg.items()))


def tradeoff(sets):
    fig, axes = plt.subplots(1, len(sets), figsize=(7.2, 2.6))
    for ax, (title, (n, agg)) in zip(axes, sets):
        lams = [l for l in agg if l <= 120]
        x = [agg[l]["driving"] for l in lams]
        y = [sum(agg[l][b] for b in BANDS) for l in lams]
        ax.plot(x, y, color=COLOR["injured"], lw=2, zorder=2)
        ax.scatter(x, y, s=28, color=COLOR["injured"], edgecolor="white", lw=1.5, zorder=3)
        for l, xi, yi in zip(lams, x, y):
            hot = l == HIGHLIGHT
            if hot:
                ax.scatter([xi], [yi], s=90, facecolor="none", edgecolor=INK, lw=1.2, zorder=4)
            crowded = l == 40 and yi < 0.06 * max(y)   # too close to the lambda = 80 label
            if hot or (l in (0, 10, 40, 80) and not crowded):
                ax.annotate(f"λ = {l:g}", (xi, yi), xytext=(7, 4), textcoords="offset points",
                            color=INK if hot else MUTED, fontsize=8.5 if hot else 8,
                            fontweight="bold" if hot else "normal")
        ax.set_title(f"{title} ({n} instances)", loc="left", color=INK, fontsize=9.5)
        ax.set_xlabel("Total driving (minutes)")
        ax.grid(color=GRID, lw=0.6); ax.set_axisbelow(True)
        ax.set_ylim(0, max(y) * 1.12); ax.set_xlim(0, max(x) * 1.1)
    axes[0].set_ylabel("Reachable people left behind")
    fig.tight_layout()
    return fig


def who_left(n, agg):
    lams = [l for l in agg if l <= 80]
    fig, ax = plt.subplots(figsize=(6.6, 2.8))
    xs = range(len(lams))
    bottom = [0] * len(lams)
    for b in BANDS:
        vals = [agg[l][b] for l in lams]
        ax.bar(xs, vals, bottom=bottom, color=COLOR[b], width=0.62, edgecolor="white", lw=1,
               label=b.capitalize())
        bottom = [p + v for p, v in zip(bottom, vals)]
    for i, (l, t) in enumerate(zip(lams, bottom)):
        ax.text(i, t + 1.2, str(t), ha="center", va="bottom", fontsize=8,
                color=INK, fontweight="bold" if l == HIGHLIGHT else "normal")
    ax.set_xticks(list(xs), [f"{l:g}" + (" (used)" if l == HIGHLIGHT else "") for l in lams])
    ax.set_xlabel("λ (driving minutes one adult rescue is worth)")
    ax.set_ylabel("Reachable people left behind")
    ax.set_title(f"Who is left behind as λ grows (all sizes, {n} instances)", loc="left",
                 color=INK, fontsize=9.5)
    ax.grid(axis="y", color=GRID, lw=0.6); ax.set_axisbelow(True)
    ax.set_ylim(0, max(bottom) * 1.12)
    ax.legend(frameon=False, ncol=4, loc="upper right", fontsize=8)
    fig.tight_layout()
    return fig


def combine(*sets):
    agg = defaultdict(lambda: {"driving": 0, **dict.fromkeys(BANDS, 0)})
    common = set.intersection(*(set(a) for _, a in sets))
    for _, a in sets:
        for l in common:
            for k, v in a[l].items():
                agg[l][k] += v
    return sum(n for n, _ in sets), dict(sorted(agg.items()))


def main():
    OUT.mkdir(exist_ok=True)
    small = load("sweep-small.csv", add20=False)
    medium = load("sweep-medium.csv", add20=False)
    large = load("sweep-large.csv", add20=False)
    for name, fig in (("tradeoff", tradeoff([("Small", small), ("Medium", medium), ("Large", large)])),
                      ("who-left", who_left(*combine(small, medium, large)))):
        for ext in ("pdf", "png"):
            fig.savefig(OUT / f"{name}.{ext}", dpi=200)
        print("wrote", OUT / f"{name}.pdf")
    with open(OUT / "data.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["set", "lambda", "driving_minutes"] + [f"left_behind_{b}" for b in BANDS])
        for label, (n, agg) in (("small", small), ("medium", medium), ("large", large)):
            for l, a in agg.items():
                w.writerow([label, l, a["driving"]] + [a[b] for b in BANDS])


if __name__ == "__main__":
    main()
