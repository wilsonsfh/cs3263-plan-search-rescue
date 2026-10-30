# Results: stress

7 records, 0 call errors (excluded).

## By variant and level

| variant | level | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | think tok | latency s | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nl-direct | L1 | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 8785 | 6168 | 57 | 1.00 |
| nl-direct | L3 | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 50% | 1% | 0.00 | 9418 | 6789 | 69 | 1.00 |
| nl-reason | L3 | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 26508 | 22191 | 179 | 1.00 |

## By variant and size k

| variant | k | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | think tok | latency s | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nl-direct | 8 | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4913 | 4073 | 39 | 1.00 |
| nl-direct | 16 | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 50% | 1% | 0.00 | 13290 | 8884 | 87 | 1.00 |
| nl-reason | 12 | 1 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 19127 | 15862 | 132 | 1.00 |
| nl-reason | 16 | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 30198 | 25356 | 203 | 1.00 |

## Instances with a cut-off location

| variant | cut_off | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | think tok | latency s | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nl-direct | False | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 50% | 1% | 0.00 | 13290 | 8884 | 87 | 1.00 |
| nl-direct | True | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 4913 | 4073 | 39 | 1.00 |
| nl-reason | False | 1 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 23379 | 17704 | 151 | 1.00 |
| nl-reason | True | 2 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 28072 | 24434 | 193 | 1.00 |

## Capacity

| variant | capacity_mode | n | valid | exec | complete | priority | coverage | vuln. cov. | optimal | gap (valid) | |claim err| min | out tok | think tok | latency s | rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nl-direct | tight | 4 | 100% | 100% | 100% | 100% | 100% | 100% | 75% | 0% | 0.00 | 9102 | 6478 | 63 | 1.00 |
| nl-reason | tight | 3 | 100% | 100% | 100% | 100% | 100% | 100% | 100% | 0% | 0.00 | 26508 | 22191 | 179 | 1.00 |

## Error types (number of runs with each error)

| variant |  |
|---|

## Consistency across samples

| variant | level | groups | same validity | same priority compliance | same pickup order |
|---|---|---|---|---|---|