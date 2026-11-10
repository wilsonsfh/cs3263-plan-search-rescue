# Penalty = lambda x r_b: trade-off sweep

The deferral penalty is split into two parts that can each be explained:

| Part | Meaning | Value |
|---|---|---|
| r_b | Urgency of each group relative to an adult (order from triage: injured first, then children, then the elderly) | injured 4, child 3, elderly 2.5, adult 1 |
| lambda | Extra driving minutes the team will spend to rescue one adult now rather than leave them for the next wave | 20 |

lambda = 20 gives exactly the current penalties (80/60/50/20), so nothing in the domain,
instances, references or pipelines changes. Only the explanation changes, plus this sweep.

`sweep.py` solves each instance exactly (Dijkstra, no Fast Downward) for a range of lambda.
At lambda = 20 it reproduces all 15 small Fast Downward references in `../results/best_reference.csv`.

## Small instances (15, one car each, 119 people, 16 cut off by damaged roads)

| lambda | Driving (min, total) | Deferred | of whom reachable | Reachable deferred by group (injured / child / elderly / adult) |
|---|---|---|---|---|
| 0 | 0 | 119 | 103 | 20 / 9 / 25 / 49 |
| 5 | 390 | 78 | 62 | 0 / 5 / 13 / 44 |
| 10 | 542 | 69 | 53 | 0 / 3 / 9 / 41 |
| 15 | 886 | 51 | 35 | 0 / 1 / 4 / 30 |
| **20 (current)** | **1174** | **40** | **24** | **0 / 1 / 0 / 23** |
| 30 | 1392 | 31 | 15 | 0 / 1 / 0 / 14 |
| 40 | 1658 | 23 | 7 | 0 / 1 / 0 / 6 |
| 60 | 1988 | 17 | 1 | 0 / 1 / 0 / 0 |
| 80 and above | 2174 | 16 | 0 | 0 / 0 / 0 / 0 |

Reading it:
- Below about lambda = 10 the planner leaves most people behind; from lambda = 80 up it rescues
  everyone reachable and deferring is never a real choice. lambda = 20 sits in between, where the
  benchmark actually tests triage decisions. That is the argument for choosing it.
- At lambda = 20 the people left behind are almost all adults (23 of 24), so r_b does its job.

## Medium instances (8 of 15 solved exactly; the other 7 ran past 5 min per solve)

Instances medium-02, 03, 05, 06, 07, 11, 13, 15: 27 people cut off by damaged roads. lambda = 20 is
the Fast Downward reference.

| lambda | Driving (min, total) | Deferred | of whom reachable |
|---|---|---|---|
| 10 | 672 | 66 | 39 |
| **20 (current)** | **1230** | **42** | **15** |
| 40 | 1511 | 31 | 4 |
| 80 | 1671 | 27 | 0 |

Same shape as the small set: lambda = 20 sits in the middle of the curve, and by 80 nobody reachable
is left.

The tables above are from the first runs; the full sweeps (all 15 instances per size) are in the
CSV files below and in the figures.

## Figures for the report

`python3 figures.py` (needs matplotlib) writes `figures/tradeoff.pdf` (small, medium, large) and
`figures/who-left.pdf` (all 45 instances), PNG copies, and the numbers behind them in `figures/data.csv`.
"Left behind" counts only people a car could reach; people cut off by damaged roads are excluded.
The main results use lambda = 20.

Data: `sweep-small.csv` (sweep.py), `sweep-medium.csv` and `sweep-large.csv` (`sweep_exact.py`, using
`../exact.py`; large at lambda 0, 5, 10, 15, 20, 30, 40, 60, 80, 120, about 3-4 min per lambda for all 15). At lambda = 20 every row matches
`../results/best_reference.csv`, and sweep.py and exact.py agree on every medium run both finished.
