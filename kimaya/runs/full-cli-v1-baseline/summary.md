# PDDL experiment summary

All completed cases, including failures, are in the denominator. Mock results are not experiments.

| Size | Report | N | First valid | Final valid | Exact translation | Mean total seconds |
|---|---|---:|---:|---:|---:|---:|
| large | explicit | 15 | 15 | 15 | 15 | 107.15 |
| medium | explicit | 15 | 15 | 15 | 15 | 52.88 |
| small | explicit | 15 | 15 | 15 | 15 | 0.09 |

## Reference comparisons (valid plans only)

| Reference status | Eligible runs | Valid | Beats | Matches | Exceeds |
|---|---:|---:|---:|---:|---:|
| Proven optimal | 45 | 45 | 0 | 28 | 17 |
| Best known | 0 | 0 | 0 | 0 | 0 |

## Latency by outcome

| Outcome | N | Mean total seconds |
|---|---:|---:|
| Valid | 45 | 53.38 |

## Failure stages

- valid: 45

## Translation versus outcome

| Exact translation | Valid final plan | Cases |
|---|---|---:|
| True | True | 45 |
| True | False | 0 |
| False | True | 0 |
| False | False | 0 |
