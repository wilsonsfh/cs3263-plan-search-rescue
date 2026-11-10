# Full LLM → PDDL subscription results

Completed 7 November 2026: 270 model cases and 45 correct-PDDL baselines. One initial response per case, zero repairs. This report supersedes pilot conclusions for the full-run configuration; historical pilot artifacts remain unchanged.

## Design

45 scenarios (15 per size) × two report styles × three Claude 5.5 models, medium effort. CLI subscription transport and request flags match Wilson; exact model IDs, inputs, objective and checker are unchanged. Claude Code was updated to 2.1.319 after a zero-token version rejection. Same CLI flags do not establish identical hidden context across CLI versions. The new planner sequence is A* LM-cut for 60 CPU seconds, then LAMA for 60 CPU seconds on timeout. The pilot additionally used merge-and-shrink; do not pool its outcomes with these runs. All planner jobs were sequential. See [protocol](full_run_protocol.md).

## Headline results

Optimal means valid and equal in cost to the updated exact reference. Denominators include all attempted cases.

| Model | Valid / 90 | Optimal / 90 | Strict canonical exact / 90 | Exact except added requirements / 90 | Direct valid / 90 | Direct optimal / 90 |
|---|---:|---:|---:|---:|---:|---:|
| opus | 90 | 56 | 90 | 90 | 89 | 84 |
| sonnet | 90 | 56 | 90 | 90 | 89 | 70 |
| haiku | 89 | 54 | 36 | 87 | 84 | 70 |

| Model | Mutually valid pairs | PDDL cheaper | Equal | PDDL more expensive | Mean valid cost gap (%) |
|---|---:|---:|---:|---:|---:|
| opus | 89 | 0 | 56 | 33 | 16.36 |
| sonnet | 89 | 6 | 50 | 33 | 16.36 |
| haiku | 84 | 8 | 42 | 34 | 16.55 |

## Size and report breakdown

| Model | Size | Report | Valid | Optimal | N |
|---|---|---|---:|---:|---:|
| opus | small | explicit | 15 | 15 | 15 |
| opus | small | implicit | 15 | 15 | 15 |
| opus | medium | explicit | 15 | 11 | 15 |
| opus | medium | implicit | 15 | 11 | 15 |
| opus | large | explicit | 15 | 2 | 15 |
| opus | large | implicit | 15 | 2 | 15 |
| sonnet | small | explicit | 15 | 15 | 15 |
| sonnet | small | implicit | 15 | 15 | 15 |
| sonnet | medium | explicit | 15 | 11 | 15 |
| sonnet | medium | implicit | 15 | 11 | 15 |
| sonnet | large | explicit | 15 | 2 | 15 |
| sonnet | large | implicit | 15 | 2 | 15 |
| haiku | small | explicit | 15 | 15 | 15 |
| haiku | small | implicit | 15 | 15 | 15 |
| haiku | medium | explicit | 15 | 11 | 15 |
| haiku | medium | implicit | 14 | 10 | 15 |
| haiku | large | explicit | 15 | 2 | 15 |
| haiku | large | implicit | 15 | 1 | 15 |

## Time and tokens

| Model | Mean LLM seconds | Mean planner seconds | Mean total seconds | Input tokens | Output tokens |
|---|---:|---:|---:|---:|---:|
| opus | 21.79 | 53.17 | 74.96 | 393,930 | 273,183 |
| sonnet | 16.04 | 53.17 | 69.22 | 382,383 | 268,196 |
| haiku | 18.49 | 53.92 | 72.41 | 384,273 | 457,378 |

Tokens include provider-reported cache input usage. Thinking counts exposed under CLI `modelUsage.thinkingTokens` are extracted separately in comparison.csv; do not add them to output tokens without a provider accounting definition. The original top-level thinking field can be null because the CLI exposed this information elsewhere. CLI list-price dollar estimates are not actual subscription charges. No API credit spending is inferred.

## Translation findings

Opus and Sonnet each match all 90 benchmark encodings. Haiku matches 36 strictly. Another 51 Haiku cases differ only by added `:requirements` declarations; the separately labelled comparison excludes only those declarations, not arbitrary extra content. Three Haiku cases have substantive fact differences:

- `medium-03 implicit`: elderly n1 becomes injured n1 at kakani-temple in the initial state and goal. The returned plan fails ground-truth replay at step 2, when it tries to defer an injured person who is not there.
- `large-05 implicit`: omits both directions of a damaged-road fact between thakre-shelter and trishuli-care-home.
- `large-06 implicit`: omits both directions of a damaged-road fact between kakani-temple and dhunche-temple.

Both damaged-road cases still return valid plans. Validity of one returned plan therefore does not prove translation fidelity. Canonical agreement, even with requirements ignored, is an encoding comparison rather than a general semantic-equivalence proof.

## Correct-PDDL baseline and interpretation

The baseline returns **45/45 valid plans**, of which **28/45 match the optimal reference**. It uses LM-cut for 26 final plans and LAMA for the remainder. The baseline consumes no LLM calls; the explicit label is only the harness slot name.

The PDDL pipeline improves validity relative to the saved direct runs, but fewer plans match the optimum for every model. All 30 small presentations per model are optimal. On large presentations, Opus/Sonnet match the optimum in 4/30 cases and Haiku in 3/30. Thus better validity and translation fidelity do not imply better cost optimization under this budget.

Exact translation does not guarantee an optimal resulting plan under finite search time. Compare each generated problem with the correct-PDDL control in comparison.csv. Canonical-equivalent fact/object order can change search tie-breaking; cost differences are not automatically translation failures. These results concern this domain, configuration and budget, not all classical planners.

## Verification and reproducibility

Independently replayed all 315 saved full-run/baseline plans and all 270 saved direct plans; results match their records. Checked 1783 manifested file-hash entries and all 45 exact/best reference pairs. All live cases used the requested model and medium effort with one attempt. No valid plan beats the claimed optimum. No new inference or planning is needed for this analysis:

```sh
.venv/bin/python kimaya/analyse_full.py
```

Detailed outputs are in `runs/full-cli-v1/{comparison,direct_rescored,aggregate}.csv` and `translation_differences.json`. Original per-case records, CLI responses, prompts, generated PDDL, planner logs/plans and manifests remain in the four run directories.

## Limitations

- One model sample per scenario/report. Explicit and implicit presentations share a scenario, so 90 cases are not 90 independent scenarios.
- The six pilot scenarios overlap the full set. This is not a completely untouched held-out benchmark.
- The exact-reference solver inherits its reduction assumptions; replay checks establish validity/cost, not an independent proof of optimality.
- Cross-machine or cross-version latency comparisons with Wilson are descriptive. CLI context and service-side behaviour may vary over time.
- Ground-truth Python replay is the primary validity check; VAL was not rerun for these experiments.
- Penalties are modelling choices, and the simplified rescue objective is not validated for real disaster decisions.
- Implementation and analysis were assisted by Codex; the team should review and own the conclusions.
