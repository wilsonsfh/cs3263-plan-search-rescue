# Plan, Search, Rescue! (CS3263 Group 11)

Post-flood search-and-rescue planning from natural-language field reports. Two ways to get a plan are compared:
1. **LLM-only**: a frontier model reads the reports and writes the plan directly (this package, Wilson).
2. **LLM → PDDL → planner**: the model translates the reports into PDDL and Fast Downward solves it (Jia Bao: domain and prompts; Kimaya: pipeline).

Both are scored by the same independent judge against the same ground truth. See `docs/INTERFACE.md`.

```
rescue/schema.py      formal model + canonical instance (ground truth)
rescue/generator.py   seeded Nepal-inspired instance generator (sizes, blockages, capacity, cut-off places)
rescue/reports.py     NL rendering at 3 language levels (L1 explicit, L2 implicit, L3 noisy multi-source)
rescue/oracle.py      exact optimal solver (uniform-cost search) -> optimality gaps
rescue/validator.py   deterministic plan judge with typed errors; JSON and PDDL-plan parsers
rescue/llm_only.py    LLM-only pipeline + variants (nl-direct, nl-reason, gold-reason, nl-repair)
rescue/backends.py    Claude Code CLI (tools disabled, no CLAUDE.md) / Ollama; response cache
rescue/probes.py      invariance probes (rename; paraphrase is a render seed)
rescue/evaluate.py    tables: validity, coverage, gap, error types, consistency
prompts/              operator brief (shared task rules), output format, style, repair
docs/                 INTERFACE.md (team contract), llm_only_method.md (write-up for the report)
```

## Use
```bash
python3 -m venv .venv && .venv/bin/pip install pytest
.venv/bin/pytest -q                                   # validator, oracle and report-fidelity tests
.venv/bin/python -m rescue.cli generate               # data/instances, data/reports, data/manifest.json
.venv/bin/python -m rescue.cli run --name main --model claude-sonnet-5-5 \
    --variants nl-direct,nl-reason,gold-reason,nl-repair --split test --samples 3 \
    --probes paraphrase,rename --workers 3            # resumable; re-run the same command to continue
.venv/bin/python -m rescue.cli eval results/main/records.jsonl
.venv/bin/python -m rescue.cli validate-plan data/instances/k8-s5-cap.json sas_plan --pddl
.venv/bin/python -m rescue.cli oracle-stats           # state-space / price-of-priority table
```
The LLM backend is the `claude` CLI logged in with a Claude subscription (the guidelines allow this). No API key is
needed. Every call is cached in `results/cache/`, so re-running costs nothing.
