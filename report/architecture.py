#!/usr/bin/env python3
"""Figure 1: benchmark construction, the two pipelines and the two evaluation routes.

  python3 report/architecture.py   ->  report/figures/architecture.{pdf,png}
"""
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

OUT = Path(__file__).parent / "figures"
INK, MUTED = "#1f1f1e", "#6b6a63"
FILL = {"data": "#eef2f8", "llm": "#fbeee6", "tool": "#e8f4ee", "eval": "#f4f1e6"}
EDGE = {"data": "#2a78d6", "llm": "#eb6834", "tool": "#1baf7a", "eval": "#b08600"}
plt.rcParams.update({"font.size": 8.5, "pdf.fonttype": 42})

fig, ax = plt.subplots(figsize=(7.2, 3.3))
ax.set_xlim(0, 100); ax.set_ylim(0, 50); ax.axis("off")
W, H = 15, 6.4


def box(x, y, text, kind, w=W, h=H, bold=False):
    ax.add_patch(FancyBboxPatch((x - w / 2, y - h / 2), w, h, boxstyle="round,pad=0.25,rounding_size=1.2",
                                fc=FILL[kind], ec=EDGE[kind], lw=1.1))
    ax.text(x, y, text, ha="center", va="center", color=INK, fontsize=8, linespacing=1.15,
            fontweight="bold" if bold else "normal")
    return (x, y, w, h)


def arrow(a, b, label=None, dashed=False, side="right", off=(0, 0)):
    (x1, y1, w1, h1), (x2, y2, w2, h2) = a, b
    if side == "right":
        p, q = (x1 + w1 / 2 + 0.6, y1), (x2 - w2 / 2 - 0.6, y2)
    elif side == "down":
        p, q = (x1, y1 - h1 / 2 - 0.5), (x2, y2 + h2 / 2 + 0.5)
    else:  # up
        p, q = (x1, y1 + h1 / 2 + 0.5), (x2, y2 - h2 / 2 - 0.5)
    ax.annotate("", xy=q, xytext=p, arrowprops=dict(arrowstyle="-|>", color=MUTED, lw=1,
                linestyle=(0, (3, 2)) if dashed else "-", shrinkA=0, shrinkB=0,
                connectionstyle="arc3,rad=0"))
    if label:
        ax.text((p[0] + q[0]) / 2 + off[0], (p[1] + q[1]) / 2 + off[1], label, ha="center", va="bottom",
                color=MUTED, fontsize=7)


def line(pts, dashed=False):
    """Orthogonal arrow through the given points; arrowhead at the last one."""
    ls = (0, (3, 2)) if dashed else "-"
    xs, ys = zip(*pts)
    ax.plot(xs[:-1] + (xs[-1],), ys[:-1] + (ys[-1],), color=MUTED, lw=1, linestyle=ls, solid_capstyle="butt")
    ax.annotate("", xy=pts[-1], xytext=pts[-2],
                arrowprops=dict(arrowstyle="-|>", color=MUTED, lw=1, shrinkA=0, shrinkB=0))


R = [42, 31, 20, 8]          # row y: LLM-only, LLM+PDDL, exact, control
cx = [9, 27, 46, 65, 88]      # column x
js = box(cx[0], 25, "Scenario JSON\n(45 seeded\ninstances)", "data", h=10, bold=True)
rep = box(cx[1], 36.5, "Field reports\nexplicit / implicit\n(templates, no LLM)", "data", h=9)
gold = box(cx[1], R[3], "Correct\nproblem PDDL", "data")
d_llm = box(cx[2], R[0], "LLM writes\nthe plan", "llm", h=5.6)
t_llm = box(cx[2], R[1], "LLM writes\nproblem PDDL", "llm", h=5.6)
fd1 = box(cx[3], R[1], "Fast Downward\n(shared domain)", "tool", h=5.6)
ex = box(cx[3], R[2], "Dijkstra exact\nsolver", "tool", h=5.6)
fd2 = box(cx[3], R[3], "Fast Downward\n(same settings)", "tool")
chk = box(cx[4], 36.5, "Checker replays\nplan on JSON\n(valid? cost C)", "eval", h=9)
gap = box(cx[4], 18, "Gap to optimum\n(C − C*) / C*", "eval", h=7, bold=True)

e = W / 2 + 0.6
jx = cx[0] + e
line([(jx, 27), (17.5, 27), (17.5, 36.5), (cx[1] - e, 36.5)])
line([(jx, 23), (17.5, 23), (17.5, R[3]), (cx[1] - e, R[3])])
line([(jx, 25), (36, 25), (36, R[2]), (cx[3] - e, R[2])])
line([(cx[1] + e, 38.5), (36.5, 38.5), (36.5, R[0]), (cx[2] - e, R[0])])
line([(cx[1] + e, 34.5), (36.5, 34.5), (36.5, R[1]), (cx[2] - e, R[1])])
line([(cx[2] + e, R[1]), (cx[3] - e, R[1])])
line([(cx[1] + e, R[3]), (cx[3] - e, R[3])])
line([(cx[2] + e, R[0]), (cx[4] - e, R[0])])
line([(cx[3] + e, R[1]), (76, R[1]), (76, 34), (cx[4] - e, 34)])
line([(cx[3] + e, R[3]), (77.5, R[3]), (77.5, 32.5), (cx[4] - e, 32.5)], dashed=True)
line([(cx[4], 36.5 - 4.5 - 0.5), (cx[4], 18 + 3.5 + 0.5)])
line([(cx[3] + e, R[2]), (cx[4] - 7.5 - 0.6, R[2])])
ax.text(75, R[2] + 0.6, "C*", color=MUTED, fontsize=7.5, ha="center", va="bottom")

ax.text(cx[2], R[0] + 4.3, "Pipeline 1: LLM-only", color=EDGE["llm"], fontsize=7.5, fontweight="bold", ha="center")
ax.text(cx[2], R[1] - 4.6, "Pipeline 2: LLM + PDDL", color=EDGE["llm"], fontsize=7.5, fontweight="bold", ha="center", va="top")
ax.text(46, R[3] + 1, "planner control (no LLM)", color=EDGE["tool"], fontsize=7, ha="center", va="bottom")
ax.text(46, R[2] + 0.6, "optimal reference", color=EDGE["tool"], fontsize=7, ha="center", va="bottom")

OUT.mkdir(exist_ok=True)
fig.tight_layout(pad=0.2)
for ext in ("pdf", "png"):
    fig.savefig(OUT / f"architecture.{ext}", dpi=220)
print("wrote", OUT / "architecture.pdf")
