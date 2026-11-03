# Claude pipelines (Group 11)

Two ways of turning a field report into a rescue plan, scored by the same checker.

| File | What it does |
|---|---|
| `reports.py` | Writes a field report for every instance at two levels: **explicit** (facts stated plainly) and **implicit** (journalist-style: "the bridge was washed away", "an elderly couple", "the army set up a relief camp"), plus harmless distractors. Output: `reports/<id>-<level>.txt` |
| `pipelines.py` | **direct**: Claude writes the plan itself. **pddl**: Claude writes a PDDL problem file, Fast Downward solves it, and errors go back to Claude for up to 3 repairs |
| `checker.py` | Replays any plan against the ground truth: valid or not, first error, cost, people rescued. Matches VAL on all 45 reference plans |
| `run_eval.py` | Runs everything, saves each run under `runs/<tag>/`, writes `runs/<tag>/results.csv` |

## Setup

```
pip install anthropic
export ANTHROPIC_API_KEY=...            # your group's key
export FD=/path/to/downward/fast-downward.py
python3 reports.py                       # already done; rerun if instances change
```

## Running

```
# 1. Plumbing test, no API calls (a fake Claude returns the right answers)
python3 run_eval.py --mock --sizes small --limit 2

# 2. Pilot: 2 small instances, both pipelines, both levels (8 runs, about $1-2)
python3 run_eval.py --sizes small --limit 2 --tag pilot

# 3. Main batch: 45 instances x 2 levels x 2 pipelines = 180 runs
python3 run_eval.py --tag main

# 4. Perfect-translation baseline (no API cost): what the PDDL pipeline scores
#    when the translation is exactly right, so the rest of its gap is translation error
python3 run_eval.py --mock --pipelines pddl --tag perfect-translation

# 5. Ablations
python3 run_eval.py --pipelines pddl --pddl-repairs 0 --tag no-repair
python3 run_eval.py --pipelines direct --direct-repairs 3 --tag direct-oracle-feedback
python3 run_eval.py --effort high --tag effort-high
```

Finished runs are skipped, so a batch that stops halfway can be restarted with the same command.

Defaults: model `claude-opus-5-5`, effort `medium`, planner 60 s per search.
No automatic fallback to another model on refusals, so every result comes from the model named in the CSV.

## What results.csv contains

- `valid`, `cost`, `reference_cost`, `gap_pct`: plan quality against the Fast Downward reference
- `error`: the checker's first error (damaged road used, car overfilled, dropped off at a non-evacuation point, people left unresolved, ...)
- `claimed_cost` (direct): the cost Claude says its plan has, which shows whether it can evaluate its own plan
- `attempts` (pddl): how many tries the repair loop needed
- `missing_*` / `extra_*` (pddl): translation fidelity per fact type, e.g. `missing_damaged` = damaged roads Claude failed to mark, `missing_waiting` = people counts it got wrong. These separate translation errors from planning errors
- `input_tokens`, `output_tokens`: for the cost analysis

## Notes

- `--direct-repairs` uses the ground-truth checker as feedback, which a real deployment would not have. Report it as an upper bound (an "oracle"), not as a fair comparison.
- The PDDL repair loop only sees parser and planner errors, not the ground truth, so a translation that parses but is wrong (for example a missed damaged road) goes undetected. That is the main risk of the tool approach and worth a paragraph in the report.
- Reports are templated. Wilson can edit or rewrite the `.txt` files by hand, as long as the bracketed identifiers stay.
- People can be split across cars (see `../pddl/domain.pddl`). The direct pipeline writes `load <car> <band> <count>`, so it can split too.
- People come in four bands: injured, child, elderly, adult (penalties 80/60/50/20). An injured person counts only as injured, whatever their age.
- Reference plans were solved with 300 s per search; the pipeline's planner uses 60 s (`--timeout`). Mention this when comparing costs.
- The PDDL pipeline's planner runs up to three searches of 60 s each, so one attempt can take up to about 3 minutes on large instances.
