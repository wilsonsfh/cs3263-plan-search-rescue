# PDDL experiment summary

All completed cases, including failures, are in the denominator. Mock results are not experiments.

| Size | Report | N | First valid | Final valid | Exact translation | Mean total seconds |
|---|---|---:|---:|---:|---:|---:|
| large | explicit | 15 | 15 | 15 | 8 | 127.91 |
| large | implicit | 15 | 15 | 15 | 7 | 137.76 |
| medium | explicit | 15 | 15 | 15 | 5 | 69.55 |
| medium | implicit | 15 | 14 | 14 | 5 | 71.55 |
| small | explicit | 15 | 15 | 15 | 7 | 12.37 |
| small | implicit | 15 | 15 | 15 | 4 | 15.31 |

## Reference comparisons (valid plans only)

| Reference status | Eligible runs | Valid | Beats | Matches | Exceeds |
|---|---:|---:|---:|---:|---:|
| Proven optimal | 90 | 89 | 0 | 54 | 35 |
| Best known | 0 | 0 | 0 | 0 | 0 |

## Latency by outcome

| Outcome | N | Mean total seconds |
|---|---:|---:|
| Valid | 89 | 72.99 |
| Failed | 1 | 20.88 |

## Failure stages

- ground_truth_invalid: 1
- valid: 89

## Translation versus outcome

| Exact translation | Valid final plan | Cases |
|---|---|---:|
| True | True | 36 |
| True | False | 0 |
| False | True | 53 |
| False | False | 1 |
