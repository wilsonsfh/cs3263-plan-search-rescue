# PDDL experiment summary

All completed cases, including failures, are in the denominator. Mock results are not experiments.

| Size | Report | N | First valid | Final valid | Exact translation | Mean total seconds |
|---|---|---:|---:|---:|---:|---:|
| large | explicit | 15 | 15 | 15 | 15 | 133.44 |
| large | implicit | 15 | 15 | 15 | 15 | 136.67 |
| medium | explicit | 15 | 15 | 15 | 15 | 73.12 |
| medium | implicit | 15 | 15 | 15 | 15 | 74.89 |
| small | explicit | 15 | 15 | 15 | 15 | 15.22 |
| small | implicit | 15 | 15 | 15 | 15 | 16.45 |

## Reference comparisons (valid plans only)

| Reference status | Eligible runs | Valid | Beats | Matches | Exceeds |
|---|---:|---:|---:|---:|---:|
| Proven optimal | 90 | 90 | 0 | 56 | 34 |
| Best known | 0 | 0 | 0 | 0 | 0 |

## Latency by outcome

| Outcome | N | Mean total seconds |
|---|---:|---:|
| Valid | 90 | 74.96 |

## Failure stages

- valid: 90

## Translation versus outcome

| Exact translation | Valid final plan | Cases |
|---|---|---:|
| True | True | 90 |
| True | False | 0 |
| False | True | 0 |
| False | False | 0 |
