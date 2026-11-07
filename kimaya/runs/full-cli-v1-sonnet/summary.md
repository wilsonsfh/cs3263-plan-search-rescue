# PDDL experiment summary

All completed cases, including failures, are in the denominator. Mock results are not experiments.

| Size | Report | N | First valid | Final valid | Exact translation | Mean total seconds |
|---|---|---:|---:|---:|---:|---:|
| large | explicit | 15 | 15 | 15 | 15 | 125.73 |
| large | implicit | 15 | 15 | 15 | 15 | 127.56 |
| medium | explicit | 15 | 15 | 15 | 15 | 68.12 |
| medium | implicit | 15 | 15 | 15 | 15 | 68.80 |
| small | explicit | 15 | 15 | 15 | 15 | 12.01 |
| small | implicit | 15 | 15 | 15 | 15 | 13.11 |

## Reference comparisons (valid plans only)

| Reference status | Eligible runs | Valid | Beats | Matches | Exceeds |
|---|---:|---:|---:|---:|---:|
| Proven optimal | 90 | 90 | 0 | 56 | 34 |
| Best known | 0 | 0 | 0 | 0 | 0 |

## Latency by outcome

| Outcome | N | Mean total seconds |
|---|---:|---:|
| Valid | 90 | 69.22 |

## Failure stages

- valid: 90

## Translation versus outcome

| Exact translation | Valid final plan | Cases |
|---|---|---:|
| True | True | 90 |
| True | False | 0 |
| False | True | 0 |
| False | False | 0 |
