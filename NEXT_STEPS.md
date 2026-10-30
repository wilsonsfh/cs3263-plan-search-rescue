# Next steps (Wilson, Person 2: LLM-only pipeline)

*Written 27 Oct 2026. Report + 10-min video + code due **Fri 13 Nov 2026** as `Group11.zip`. Assignment 2 is due Mon 2 Nov, so plan around it.*

## 1. Decisions only you can make

| # | Decision | Recommendation | Why it matters |
|---|---|---|---|
| 1 | **Which model for the final experiment** | Sonnet 5.5 | Your pipeline and Kimaya's must use the **same model**, or the comparison is unfair. Agree it with her first. |
| 2 | **Go-ahead for the main run** (~350 calls on your Claude subscription, ~3 hours) | Yes, once #1 is agreed | Uses your usage quota. If the limit is hit, re-running the same command resumes it; nothing is lost. |
| 3 | **Add a second, cheaper model (Haiku 5.5)?** | Optional, small extra | Shows whether the result depends on having a top-tier model. Good for the analysis section, not essential. |
| 4 | **Where the team's code lives** | One shared GitHub repo | The submission zip needs all the code together. This folder is a local git repo with nothing committed yet. |

## 2. Message to send your teammates

> Hi both, the LLM-only pipeline is built and tested. A few things we need to agree on so our results can be compared fairly:
>
> 1. **Same model.** I plan to use Claude Sonnet 5.5 for the final runs. Kimaya, can you use the same one for the PDDL translation?
> 2. **Same task rules.** I've written the rescue rules (movement, pick up everyone at a place, capacity, priority: injured > children/elderly > others, minimise travel time) in `prompts/operator_brief.md`. Jia Bao, can your PDDL prompts include this text word for word, so a difference in results comes from the method and not the wording?
> 3. **Capacity.** Fast Downward doesn't support numeric fluents, so vehicle capacity needs either a workaround (load levels as objects), a numeric planner, or we compare only on the unlimited-capacity instances. Jia Bao, which do you prefer?
> 4. **Unreachable villages.** Some instances have a village that's completely cut off. If the PDDL goal includes it, the planner returns "no plan". The translation needs to leave cut-off places out of the goal. That's also a good failure case to discuss in the report.
> 5. **Shared instances and judge.** There are 48 problem instances (`data/instances/`), with reports at 3 difficulty levels (`data/reports/`). Kimaya, you can score your planner output with the same judge I use: `python -m rescue.cli validate-plan <instance> sas_plan --pddl`. It reports validity, the error types and the gap from optimal.
> 6. **Dev/test split.** Tune prompts only on the "dev" instances; report numbers only on "test" (the TA asked for this).
>
> Full details are in `docs/INTERFACE.md`. Which GitHub repo should we put everything in?

## 3. Documents to read yourself (~45–60 min)

The project guidelines say every member must understand the whole work, and you'll present this.

- [ ] **`docs/llm_only_method.md`** (~20 min, most important). The source text for your part of the report.
  - §1 Formalisation: the maths of the problem. You need to be able to explain it in the video.
  - §4 Metrics: what "valid", "coverage" and "optimality gap" mean.
  - §10 Pilot results: the main finding so far. The models get it right; the difference is time and cost.
  - §9 Responsible AI: check that you agree with the arguments.
- [ ] **`docs/INTERFACE.md`** (~10 min): what you're agreeing with your teammates.
- [ ] **`prompts/operator_brief.md`** (~3 min): the exact rules every pipeline is given. If you disagree with the priority policy, change it now, before the main run.
- [ ] **Sample reports: your audit task** (~15 min). Open `data/reports/k8-s3-cap-cut/L2.txt` and `L3.txt` and compare them with `gold.json` in the same folder (the true answer). Do the same for about 8 more instances. Note anything ambiguous or wrong so it can be fixed before the main run. The report can then say a human checked the reports.
- [ ] **`results/stress/summary.md`** (~5 min): the actual numbers behind the findings.
- Optional code: the top comment of `rescue/validator.py` explains how plans are judged.

## 4. Order from now

1. **Today:** send the message above and read the first three documents.
2. **Next 1–2 days:** do the report audit and collect your teammates' answers.
3. **Then say "go" with the chosen model.** Fix any audit findings, freeze the prompts, and run the main experiment:
   ```bash
   .venv/bin/python -m rescue.cli run --name main --model claude-sonnet-5-5 \
       --variants nl-direct,nl-reason,gold-reason,nl-repair --split test --workers 3
   .venv/bin/python -m rescue.cli eval results/main/records.jsonl
   ```
4. **After that:** write the report and record the video (due Fri 13 Nov).

## Findings so far (dev split only, for context)

- Sonnet 5.5 and Haiku 5.5 got **every plan valid and optimal**, up to 16 stranded places with tight capacity, a cut-off village and the noisiest reports. The only non-optimal plan came from the low-effort, answer-only variant (1.7% over).
- **Cost and latency are where the methods differ, not accuracy.** At 16 places, Haiku spent 110k thinking tokens and 8 minutes; the exact solver takes milliseconds.
- **The priority rule has a measurable price:** 0–58% extra travel time (median ~4%), and zero in 17 of 36 instances. It also makes the solver's search 10–100× smaller, a concrete answer to the TA's value question.
- **The exact solver stops being cheap around 24–28 places** with tight capacity. That's the size range where both pipelines would be worth stress-testing.

## Housekeeping

- The folder was moved from `~/Projects` to `~/Downloads`. The Python environment (`.venv`) was rebuilt for the new location, and all 223 tests pass.
- `data_v0_pilot/` holds the instances from the first pilot (old suite design). Keep it for the record; it isn't part of the main experiment.
