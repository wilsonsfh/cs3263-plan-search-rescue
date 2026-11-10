# Full subscription experiment protocol

Approved 7 November 2026. This is separate from the API pilot and does not replace its artifacts.

## Fixed comparison

- 45 unchanged scenarios: 15 small, 15 medium, 15 large.
- Explicit and implicit reports: 90 cases per model, 270 total.
- Match Wilson: `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5`; medium effort; one attempt; zero repairs.
- Same shared prompts, reports, domain, checker and cost: driving minutes + 80 per injured person deferred + 60 per child + 50 per elderly person + 20 per adult.
- CLI subscription authentication, no tools, empty working directory, no settings sources or persisted conversation. API/proxy/cloud-routing credentials are stripped. CLI mode never loads `.env`.
- No explicit output cap, matching Wilson's CLI invocation. Provider/model usage metadata and CLI version are preserved. Provider dollar estimates are not subscription charges or receipts.

## Planning and controls

Fast Downward A* with LM-cut gets 60 CPU seconds. On timeout without a plan, a separate LAMA anytime search gets 60 CPU seconds. No merge-and-shrink stage. Each subprocess has a 120-second wall-clock guard; the maximum allocated CPU budget is 120 seconds across both searches. Keep saved LAMA plans even on timeout. This is a documented practical budget choice, not an empirically selected best configuration.

Run 45 ground-truth PDDL baselines once each with identical settings. The explicit label in their paths only identifies the harness slot; baseline planning does not consume a report or call an LLM. Run all planner jobs sequentially, including baselines, to avoid mutual CPU contention.

References come from main at `a0e5741`: all 45 saved exact and best plans were replayed with the unchanged checker and their costs matched the reference CSV. This is a validity/cost check, not an independent proof of the custom solver's reductions. Rescore Wilson's existing results against these references without new direct-model calls. Any valid plan cheaper than a claimed optimum is flagged for investigation.

## Records and interpretation

Per-case JSON, CSV summaries and translation category CSVs preserve validity, cost and gap, paired direct comparison, rescued/deferred counts by band, rescue coverage, driving/penalty components, action count, canonical translation agreement and missing/extra facts. Fidelity compares the benchmark encoding, not arbitrary semantic equivalence; it is never returned to the model.

Timing includes LLM, each search, combined planning, validation, fidelity and remaining overhead. On a resumed case, cached successful component durations are retained in the reported component sum and identified by `resumed_cached_seconds`. Time spent waiting for quota reset is excluded. Invocation interruption durations remain in separate logs. These elapsed wall-clock observations are not identical to CPU limits, and cross-machine timing comparisons with Wilson are descriptive.

Usage includes input/output totals, provider input/cache breakdown where available, thinking only when separately available, initial/repair usage and call count. Planner actions consume no LLM tokens. Raw requests, responses, search stdout/stderr, plans, command lines, exit codes and manifests with code/input hashes are retained. No secrets are included.

## Interruptions and resuming

Run from the repository root:

```sh
.venv/bin/python -u kimaya/run_full_suite.py
```

Successful CLI responses are cached before planning. Completed cases are skipped on rerun. A network/authentication/usage interruption pauses further model calls and is not scored as an invalid plan. The local baseline still runs. A process interrupted before its CLI outcome was saved requires inspection before retrying, since the remote call could have completed. No automatic switch to API billing or another model is allowed. Subscription login does not control account-level extra-usage billing settings.

Tags are `full-cli-v1-opus`, `full-cli-v1-sonnet`, `full-cli-v1-haiku`, and `full-cli-v1-baseline`. Suite logs are under `kimaya/runs/full-cli-v1/`. Resume fingerprints prevent changing settings or inputs under the same tag.
