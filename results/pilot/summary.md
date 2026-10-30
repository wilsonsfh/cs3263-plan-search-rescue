# Results: pilot

28 records, 0 call errors (excluded).

## By variant and level

| variant | level | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gold-reason | gold | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4258 | 1.00 |
| nl-reason | L1 | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4466 | 1.00 |
| nl-reason | L2 | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4878 | 1.00 |
| nl-reason | L3 | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4806 | 1.00 |
| nl-repair | L1 | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4494 | 1.00 |
| nl-repair | L2 | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4660 | 1.00 |
| nl-repair | L3 | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4733 | 1.00 |

## By variant and size k

| variant | k | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gold-reason | 3 | 1 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 1930 | 1.00 |
| gold-reason | 5 | 1 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 3597 | 1.00 |
| gold-reason | 7 | 1 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 3527 | 1.00 |
| gold-reason | 9 | 1 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 7978 | 1.00 |
| nl-reason | 3 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 1886 | 1.00 |
| nl-reason | 5 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4713 | 1.00 |
| nl-reason | 7 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 3708 | 1.00 |
| nl-reason | 9 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 8560 | 1.00 |
| nl-repair | 3 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 1984 | 1.00 |
| nl-repair | 5 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4422 | 1.00 |
| nl-repair | 7 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 3623 | 1.00 |
| nl-repair | 9 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 8487 | 1.00 |

## Instances with a cut-off location

| variant | cut_off | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gold-reason | False | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4258 | 1.00 |
| nl-reason | False | 12 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4716 | 1.00 |
| nl-repair | False | 12 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4629 | 1.00 |

## Capacity

| variant | capacity_mode | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gold-reason | unlimited | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4258 | 1.00 |
| nl-reason | unlimited | 12 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4716 | 1.00 |
| nl-repair | unlimited | 12 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4629 | 1.00 |

## Error types (number of runs with each error)

| variant |  |
|---|

## Consistency across samples

| variant | level | groups | same validity | same priority compliance | same pickup order |
|---|---|---|---|---|---|

## Validator-repair: validity after each round

| round | valid so far |
|---|---|
| 0 | 12/12 (100%) |
| 1 | 12/12 (100%) |
| 2 | 12/12 (100%) |