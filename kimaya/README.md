# Kimaya: LLM → PDDL experiments

This runner uses the shared domain, prompts, reports and checker without changing Wilson's experiments. It uses only Python's standard library. Live calls reproduce Wilson's Claude CLI invocation (subscription login, tools disabled, empty working directory, medium effort), with stronger logging. No model call occurs in mock or baseline mode.

## Completed full runs

See [full results](full_results.md), [protocol](full_run_protocol.md), and `runs/full-cli-v1/` for the completed 270 subscription cases and 45 baseline cases. Reproduce the comparisons with `.venv/bin/python kimaya/analyse_full.py`; this issues no model or planner calls. Historical API pilot results remain separate.

## Run

From the repository root:

```sh
python3 -m unittest discover -s kimaya/tests -v
python3 kimaya/evaluate.py --mode mock --tag smoke --ids small-01 medium-01 large-01

# Correct-translation baseline: uses the exact same planner budget as live mode.
python3 kimaya/evaluate.py --mode baseline --tag baseline-opus-60 --levels explicit --fd .tools/downward/fast-downward.py

# LIVE: consumes subscription allowance and potentially paid overage if enabled in your account.
# Log into Claude yourself first. Review billing/usage settings before starting.
python3 kimaya/evaluate.py --mode live --tag opus-medium-v1 --fd .tools/downward/fast-downward.py --model claude-opus-5-5 --effort medium --repairs 0
```

Use `--ids small-01 small-02` for a pilot. Default inputs are all 45 instances and both report styles (90 cases). Use new tags for different models/settings or reruns. Model names match Wilson's saved configuration; availability is checked only when actually calling the provider.

`--timeout 60` is **per search**. The full-run sequence is A* LM-cut, then LAMA on timeout without a plan: at most 120 allocated CPU seconds, with a 120-second wall guard per subprocess. Preserve the best saved LAMA plan even on timeout. The main experiment uses one attempt and zero repairs, matching Wilson. Optional repair experiments must use separate tags; ground-truth feedback is never supplied.

The full-suite baseline runs once per scenario using `--levels explicit`. That label identifies a harness slot, not a report consumed by the planner. There are 45 scenarios and 90 paired presentations per model, not 90 independent worlds.

## Output and reproducibility

`kimaya/runs/<tag>/` contains:

- `manifest.json`: settings, source/input hashes, Git revision, runtime and planner identity.
- `cases/<id>-<level>/record.json`: every attempt, first/final result, per-category fidelity, rescued/deferred counts, usage and timings.
- Each attempt's exact request/response, generated PDDL, planner command, stdout/stderr and plan files.
- `results.csv`: final and first-attempt outcomes, reference comparisons, paired Wilson outcomes, timings and usage.
- `summary.md`: size/report groups, reference comparisons and failure stages.

Completed failures remain in the denominator and are skipped on resume, like completed successes. Configuration or input changes reject resume. Successful CLI responses and planner outcomes are cached and reused under the same unchanged tag. Infrastructure/usage interruptions pause the batch rather than becoming task failures; an unknown CLI outcome requires inspection before retrying. Summaries include only completed cases, so check the expected case count before reporting a final batch. Do not combine mock results with actual experiments.

The canonical reference costs remain fixed. Proven-optimum cases and best-known cases are distinguished. Costs/gaps are reported only for valid plans; failed-run partial rescue counts, when available, are not full successful outcomes. Paired cost differences versus Wilson use only pairs where both plans are valid.

## Metrics and interpretation

- LLM time includes all initial/repair calls. Planner time includes every failed search and timeout. Validation, fidelity auditing, residual overhead and total elapsed time are separate.
- Input/output token totals include all calls, with initial and repair usage separated. Missing provider usage is `null`, not zero. Reasoning tokens are recorded only if explicitly returned; do not add them to output tokens without checking provider definitions. Provider dollar estimates are not receipts or actual subscription charges.
- Planner plans have action counts, not LLM token charges. PDDL character count is retained separately from model token usage.
- Fidelity uses parsed, lowercased PDDL structures, ignores comments/order of facts, and preserves duplicate counts. It compares objects, initial facts/functions, goal conjuncts, metric and domain. Each category reports missing/extra facts, precision and recall. Empty-set ratios are null.
- This is **canonical-encoding fidelity**, not a proof of arbitrary logical equivalence. Equivalent alternate encodings and redundant declarations can be flagged. Keep scenario facts separate from arithmetic-table facts, so hundreds of correct `sum` facts cannot obscure a missing blocked road.
- `parse_ok` means the local structural parser accepted the expected problem shape. Fast Downward remains the authoritative check for supported PDDL syntax/semantics.
- Exact translation does not guarantee the planner finishes. A valid final plan does not guarantee exact translation. Cross-tabulate these when analysing failures.
- `optimal_for_generated_problem` requires successful exit from an optimal search. It does not establish optimality for ground truth if translation is wrong. VAL is used by the original reference-generation workflow; this runner uses the shared ground-truth checker and does not claim new VAL validation.

## Comparison protocol

The completed main batch uses all three models, medium effort, zero repairs and the unchanged Wilson reports. The new references from main are labelled optimal for all 45 scenarios, subject to the custom exact solver's reduction assumptions. `analyse_full.py` independently replays saved direct plans and rescores them against those references. Correct-PDDL baselines use the same search budgets as translated problems. References are evaluation targets, not equal-budget end-to-end competitors.

## Local prerequisites

Install/build Fast Downward separately and pass its absolute driver path or `--fd`. The current checkout can use `.tools/downward/fast-downward.py` after building. On this machine CMake is installed in `.venv` when following the setup used for this implementation:

```sh
.venv/bin/cmake -S .tools/downward/src -B .tools/downward/builds/release -DCMAKE_BUILD_TYPE=Release
.venv/bin/cmake --build .tools/downward/builds/release -j2
```

Claude CLI must report a first-party `claude.ai` login. The runner removes API-key/provider-routing environment overrides, but this **does not disable extra paid usage configured on the account**. Billing settings must be managed by the account holder. No full experiment is started automatically.

## Historical Opus API pilot (separate from full subscription runs)

The saved pilot used LM-cut → merge-and-shrink → LAMA. Its generating code is at commit `2895142`; running the current runner uses the revised two-stage planner and will not reproduce that historical configuration. Use a new tag for any new experiment. The command below documents the original pilot invocation.

Install `kimaya/requirements.txt` into the local environment. Configure `ANTHROPIC_API_KEY` through the environment or the Git-ignored repository `.env`; never put it in commands, outputs or commits.

```sh
.venv/bin/python kimaya/evaluate.py --mode live --backend api --tag pilot-opus-api-v1 --ids small-01 small-02 medium-01 medium-02 large-01 large-02 --fd .tools/downward/fast-downward.py --model claude-opus-5-5 --effort medium --repairs 3 --timeout 60 --budget-usd 5
```

This is six distinct scenarios, two report styles, twelve cases. Opus medium, the shared task/domain prompts, reports, checker and references match the team setup. Transport differs: raw Messages API instead of Claude Code's hidden preamble; full API content blocks are preserved during repairs rather than flattening the conversation. The API output cap is 32,000 tokens, matching the shared API wrapper (Wilson's CLI adapter does not enforce that cap). Tools are not supplied. No temperature override, prompt caching or model fallback is configured.

API interruptions pause the whole batch without treating subsequent cases as failures. Successful API responses and planner outcomes are cached; repeating the unchanged command reuses those rather than charging again. Unknown-charge interruptions must be checked against the provider before retrying. The local budget guard uses the verified standard global Opus 5.5 rates ($4/M input, $20/M output), counts input tokens and reserves the maximum output charge before each request. Estimates exclude tax, other account activity and uncertain interrupted-request charges; the provider's billing dashboard remains authoritative. Provider response model identity and raw usage are saved. `estimated_cost_usd` is an experiment estimate, not a paid receipt.

Source for rates/settings: https://platform.claude.com/docs/en/about-claude/pricing and https://platform.claude.com/docs/en/models/opus-5-5/migration-guide (checked 4 November 2026).
