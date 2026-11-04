# PDDL experiment summary

All completed cases, including failures, are in the denominator. Mock results are not experiments.

| Size | Report | N | First valid | Final valid | Exact translation | Mean total seconds |
|---|---|---:|---:|---:|---:|---:|
| large | explicit | 2 | 2 | 2 | 2 | 206.86 |
| large | implicit | 2 | 2 | 2 | 2 | 207.85 |
| medium | explicit | 2 | 2 | 2 | 2 | 65.43 |
| medium | implicit | 2 | 2 | 2 | 2 | 66.66 |
| small | explicit | 2 | 2 | 2 | 2 | 15.49 |
| small | implicit | 2 | 2 | 2 | 2 | 15.35 |

## Reference comparisons (valid plans only)

| Reference status | Eligible runs | Valid | Beats | Matches | Exceeds |
|---|---:|---:|---:|---:|---:|
| Proven optimal | 8 | 8 | 0 | 8 | 0 |
| Best known | 4 | 4 | 0 | 0 | 4 |

## Latency by outcome

| Outcome | N | Mean total seconds |
|---|---:|---:|
| Valid | 12 | 96.27 |

## Failure stages

- valid: 12

## Translation versus outcome

| Exact translation | Valid final plan | Cases |
|---|---|---:|
| True | True | 12 |
| True | False | 0 |
| False | True | 0 |
| False | False | 0 |
