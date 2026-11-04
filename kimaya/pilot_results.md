# Opus LLM → PDDL pilot

## Design

Six fixed scenarios (small-01/02, medium-01/02, large-01/02), each explicit and implicit: 12 cases. One initial Opus 5.5 response per report at medium effort; up to three parser/unsolvability repairs. No tools and no ground-truth feedback are supplied to the LLM. The goal, penalty weights, domain, reports, and ground-truth checker are unchanged.

Wilson used Claude Code; this pilot uses the raw Anthropic Messages API, with a 32,000-output-token cap and preserved assistant content blocks for repairs. This matches his requested model/effort, but not the CLI hidden preamble or transport. Do not claim identical model context.

Fast Downward uses LM-cut → merge-and-shrink → LAMA, each with a 60-second overall CPU-time budget and a 120-second wall-clock process guard. All invocation times are added. Planner timeouts do not trigger model repairs. The correct-PDDL baseline uses the same configurations. The baseline and pilot overlapped in execution, so timings are descriptive, not controlled hardware benchmarks.

## Results

- Completed cases: **12/12**.
- Valid on first attempt: **12/12**; final: **12/12**.
- Canonical translation exact on final attempt: **12/12**.
- Model calls: **12**; repairs: **0**.
- Input/output tokens: **42,505 / 34,180**.
- Estimated API generation cost: **US$0.8536** (usage × published rates; excludes tax and is not a receipt).

| Scenario | Report | First/final valid | Translation exact | PDDL cost | Direct cost | Correct-PDDL cost | Saved reference |
|---|---|---|---|---:|---:|---:|---:|
| large-01 | explicit | True/True | True | 462 | 240 | 462 | 268* |
| large-01 | implicit | True/True | True | 462 | 240 | 462 | 268* |
| large-02 | explicit | True/True | True | 721 | 430 | 721 | 461* |
| large-02 | implicit | True/True | True | 721 | 428 | 721 | 461* |
| medium-01 | explicit | True/True | True | 250 | 250 | 250 | 250 |
| medium-01 | implicit | True/True | True | 250 | 250 | 250 | 250 |
| medium-02 | explicit | True/True | True | 191 | 191 | 191 | 191 |
| medium-02 | implicit | True/True | True | 191 | 191 | 191 | 191 |
| small-01 | explicit | True/True | True | 154 | 154 | 154 | 154 |
| small-01 | implicit | True/True | True | 154 | 154 | 154 | 154 |
| small-02 | explicit | True/True | True | 170 | 170 | 170 | 170 |
| small-02 | implicit | True/True | True | 170 | 170 | 170 | 170 |

*Reference not proven optimal. A valid lower cost beats this saved upper bound, not an optimum.

## Component time and usage

| Size | N | Mean LLM seconds | Mean planner seconds | Mean total seconds | Mean output tokens |
|---|---:|---:|---:|---:|---:|
| small | 4 | 14.95 | 0.12 | 15.42 | 2048 |
| medium | 4 | 17.26 | 48.41 | 66.05 | 2451 |
| large | 4 | 27.76 | 179.20 | 207.36 | 4046 |

## Translation fidelity and limitations

Translation metrics compare parsed canonical objects, initial facts, goals, metric, and cost functions. Order and comments are ignored; missing/extra facts and precision/recall are reported separately per category. Scenario facts are not pooled with arithmetic-table facts. This detects semantic omissions in the expected encoding; it is not an equivalence prover for arbitrary PDDL. The local parser flag is distinct from planner acceptance.

See `translation_metrics.csv` and per-attempt records for the category-level details. Separate LLM/planner/validation/fidelity/total timings, initial/repair tokens, rescued/deferred counts, planner logs, returned model IDs and complete model responses are retained. Reasoning tokens remain null if the provider does not expose them separately.

There is one sample per presentation and only six underlying scenarios. These are development pilot results, not a held-out or statistically conclusive main evaluation. Optimality of a plan for generated PDDL does not establish translation correctness. Original reference budgets and encodings differ from this pilot.

## Verification

All 12 saved final plans with a plan available were replayed against the shared ground-truth checker; results agree. The harness has focused unit tests for fidelity, failure persistence, repair feedback, timing, API caching and spend guarding. VAL was not rerun for these experimental plans.

## Reproduction

See `README.md` for setup and the exact API pilot command. Never commit `.env`. The manifested planner commit/binary and file hashes identify inputs. API budget or transport interruptions pause the batch; cached successful calls avoid duplicate generation on resume. Provider billing is authoritative.

Implementation and analysis were assisted by Codex; team members should review the modelling, results and conclusions before submission.

## Interpretation

- small: among 4 mutually valid pairs, PDDL cost is lower/equal/higher than direct in 0/4/0 cases.
- medium: among 4 mutually valid pairs, PDDL cost is lower/equal/higher than direct in 0/4/0 cases.
- large: among 4 mutually valid pairs, PDDL cost is lower/equal/higher than direct in 0/0/4 cases.

For large-01 explicit, the translated-PDDL plan costs 462, rescuing 18 people and deferring {'injured': 0, 'child': 4, 'elderly': 0, 'adult': 3}. Wilson's direct plan costs 240, rescues 22 people and defers three adults. The canonical translation is exact; the correct-PDDL baseline also costs 462. Thus this case identifies a planner/configuration-budget limitation, not a translation failure. This does not establish that all classical planners perform worse.

Formatting/object ordering can affect search tie-breaking even when canonical fidelity is exact. Any cost differences between correct and translated PDDL should therefore be analysed with the search logs and budget, not automatically attributed to missing facts.
