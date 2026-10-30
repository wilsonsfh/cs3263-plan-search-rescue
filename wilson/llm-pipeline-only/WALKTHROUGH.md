# Walkthrough: everything in the LLM-only part, and how to check it yourself

*Written 30 Oct 2026. Companion to `NEXT_STEPS.md` (what to do) — this file explains what exists and why.*
Project root: `~/Downloads/cs3263-plan-search-rescue/wilson/llm-pipeline-only/`

---

## A. The big picture in one paragraph

We turn a flood rescue into a **planning problem**: a map of villages and roads (some roads destroyed), people
stranded in villages, one rescue vehicle. A plan is a list of *move / pickup / dropoff* steps. We generate
problems where **we know the true answer**, write them up as **news-style field reports** at three difficulty
levels, give the reports to a frontier model, and **check its plan with an independent judge** that replays the
plan against the true map and compares its cost with a **provably optimal** plan from an exact solver. The
other two pipelines (PDDL + Fast Downward) use the **same problems, same reports and the same judge**, so the
comparison is fair.

```
generator.py ──▶ Instance (ground truth, JSON) ──▶ reports.py ──▶ L1 / L2 / L3 text
                        │                                              │
                        ├──▶ oracle.py: optimal plan + cost            ▼
                        │                                  llm_only.py: prompt ─▶ model (no tools)
                        │                                              │ JSON plan
                        └────────────────────────────▶ validator.py ◀──┘  (Kimaya's sas_plan enters here too)
                                                              │
                                              evaluate.py: tables (valid %, gap, errors, tokens, latency)
```

---

## B. Resources on this machine you can verify yourself

### B1. Course material (what the project must satisfy)
| what | path |
|---|---|
| Project guidelines (grading rubric, 10-page limit) | Wilson's Google Drive: `nus-acad/CS3263/Project/Project_Guidelines.docx` (also on Canvas) |
| Project slides | same folder, `Project_Slides.pdf` |
| Your group's proposal | `.../nus-acad/CS3263/Group 11 Project Proposal CS3263.pdf` |
| Planning lecture (STRIPS, PDDL, the LLM+PDDL harness slide) | `.../nus-acad/CS3263/Lecture05_Planning.pdf` |
| Responsible AI slides | `.../nus-acad/CS3263/Lecture00_Responsible-AI.pdf` |
| LLM-as-reasoner / tools lecture | `.../nus-acad/CS3263/Lecture01_Generative-Reasoning-Agentic-AI.pdf` |
| Your own lecture notes | `~/Projects/Personal_LLM_Wiki/raw/nus/ay2627s1/cs3263/Lecture 5 Planning.md`, `Lecture0- Responsible AI.md`, `Lecture 1 - Generative Reasoning Agentic AI.md` |

Submission rules (from the Canvas announcement of 26 Oct): `Group11.zip` = 10-minute video + report + code, due **Fri 13 Nov 23:59**.

### B2. What I built (read in this order)
| # | file | what it is | time |
|---|---|---|---|
| 1 | `NEXT_STEPS.md` | decisions, teammate message, checklist | 5 min |
| 2 | `docs/llm_only_method.md` | **report source text**: formalisation, method, metrics, assumptions, RAI, pilot results | 20 min |
| 3 | `docs/INTERFACE.md` | contract with Jia Bao and Kimaya | 10 min |
| 4 | `prompts/operator_brief.md` | the task rules every pipeline is given (priority policy lives here) | 3 min |
| 5 | `README.md` | file map + commands | 2 min |

### B3. Example data (open side by side)
| file | what to look for |
|---|---|
| `data/reports/k8-s3-cap-cut/L1.txt` | plain facts: the easy version |
| `data/reports/k8-s3-cap-cut/L2.txt` | same facts as narrative: "bridge swept away" = blocked |
| `data/reports/k8-s3-cap-cut/L3.txt` | same facts as 3 conflicting dispatches out of time order |
| `data/reports/k8-s3-cap-cut/gold.json` | the true answer the reports should say |
| `data/reports/k8-s3-cap-cut/oracle_plan.json` | an optimal plan |
| `data/instances/k8-s3-cap-cut.json` | the raw ground truth |
| `data/manifest.json` | all 48 instances: size, capacity, cut-off village, optimal cost, dev/test |

### B4. Results so far (dev split only)
| file | content |
|---|---|
| `results/pilot/summary.md` | 28/28 valid + optimal, small instances, Sonnet |
| `results/stress/summary.md` | hardest instances (16 places) Sonnet: valid + optimal; thinking tokens and latency |
| `results/stress-haiku/records.jsonl` | Haiku: valid + optimal but 110k thinking tokens, 8 min at k=16 |
| `results/oracle/oracle_stats.md` | exact solver scaling + price of priority |

### B5. Commands that check it all without spending any LLM quota
Run from the project root:
```bash
.venv/bin/pytest -q                                          # 223 tests: judge, solver, report fidelity, pipeline logic
.venv/bin/python -m rescue.cli validate-plan data/instances/k8-s3-cap-cut.json data/reports/k8-s3-cap-cut/oracle_plan.json
                                                             # the judge accepts the optimal plan, gap 0
.venv/bin/python -m rescue.cli eval results/stress/records.jsonl   # rebuild result tables from saved runs
.venv/bin/python -m rescue.cli oracle-stats --sizes 4 8 12 --seeds 1  # solver scaling table
```
To see the judge catch a mistake: copy `data/reports/k8-s3-cap-cut/oracle_plan.json` somewhere, change the first
step's `"to": "Kakani"` into `"to": "Battar"` (the Suryagadhi–Battar road is BLOCKED in `L1.txt`), and run
`validate-plan` on your copy. It prints `BLOCKED_ROAD: road Suryagadhi-Battar is impassable`.

---

## C. What each piece is, in plain language

**1. The formal problem** (`rescue/schema.py`, docstring at the top). Places and roads with travel minutes; each
road open or blocked. People per place in four groups. Actions: *move* along an open road (costs its minutes),
*pickup* (takes **everyone** at a place, never split, as the TA asked), *dropoff* at the shelter. Capacity limits
people on board. **Priority:** a place with any injured is tier 1, children/elderly tier 2, others tier 3; you
may not pick up a lower tier while a reachable higher tier is still waiting. Goal: everyone reachable delivered;
cut-off places reported as unreachable. Objective: least total minutes. This is exactly the STRIPS/PDDL planning
of Lecture 5, so Jia Bao's PDDL can express the same thing.

**2. The instances** (`rescue/generator.py`). 48 random but reproducible districts: sizes 4/8/12/16 stranded
places × unlimited/tight capacity × with/without a cut-off village × 3 copies. Blocked roads are deliberately
put on the roads a good route would *want* to use, so ignoring a blockage really breaks the plan. Copy 0 = dev
(for tuning prompts), copies 1–2 = test (for reported numbers) — the TA's "split the data".

**3. The reports** (`rescue/reports.py`). Each instance → mission sheet (base, shelter, capacity, list of places)
+ pre-flood road register (like a map) + field reports. Only the field reports change with difficulty: L1 plain,
L2 narrative (causes, "twice the usual time", "an elderly couple", injured children count as injured, a scary but
passable road), L3 three dispatches with corrections, rumours and distractors. Tests prove the reports say exactly
what the ground truth says.

**4. The exact solver / oracle** (`rescue/oracle.py`). Uniform-cost search (lecture search) over "where is the
vehicle, who has been picked up, how full is it". Gives the true optimal cost, so we can say "the LLM's plan is
X% longer than optimal". It also produced two analysis results: the priority rule costs 0–58% extra time
(median ~4%), and it shrinks the search 10–100×.

**5. The judge / validator** (`rescue/validator.py`). Replays a plan step by step on the true map, trusting
nothing the plan claims. Errors come in four kinds: *physical* (drove a blocked road, teleported, overfilled the
vehicle — the team would be stuck), *goal* (left people behind, wrongly claimed a village unreachable),
*priority* (broke the tier rule), *info* (harmless). "Valid" = no physical, goal or priority error. It also reads
Fast Downward's `sas_plan`, so Kimaya's plans are judged identically.

**6. The LLM-only pipeline** (`rescue/llm_only.py`, `rescue/backends.py`). Builds the prompt (shared rules +
report + output format), calls Claude through your Claude Code login with **all tools switched off** (so it
cannot write code to cheat — truly "LLM-only"), parses the JSON plan (one retry if the format is broken), judges
it. Four variants, each answering one question:

| variant | question it answers |
|---|---|
| `nl-direct` (answer only, low effort) | how good is a quick answer with no deliberation? |
| `nl-reason` (reason first, high effort) | the main LLM-only result |
| `gold-reason` (given perfect facts instead of reports) | is failure from *reading* or from *planning*? |
| `nl-repair` (+ up to 2 rounds of judge feedback) | does a checker loop fix mistakes? (mirrors Kimaya's self-repair) |

**7. Metrics** (`rescue/evaluate.py`): valid %, executable %, complete %, priority-respected %, coverage (people
actually delivered before any fatal error), vulnerable coverage, optimality gap, claimed-vs-actual time error,
consistency across repeats, tokens, thinking tokens, latency.

**8. The findings so far (dev only, provisional).** Frontier models (Sonnet 5.5, even Haiku 5.5) produce **valid,
optimal** plans up to 16 places, even from the noisiest reports. They pay for it in thinking: tokens and latency
grow steeply with size (Haiku: 110k thinking tokens, 8 minutes at 16 places, vs milliseconds for the solver).
So the story for the report is **"the LLM can solve it, but by spending lots of compute on an internal search,
with no guarantee; the planner is cheap and provably optimal — until its own exponential wall (~24–28 places with
capacity)."** The main test run will confirm or change this.

---

## D. What to explain to your teammates

### To both
1. **The headline finding** (C8). It changes what the comparison is about: not "LLM fails, planner wins", but
   accuracy vs cost vs guarantees. So **Kimaya should also log tokens and latency** for her pipeline (translation
   call + planner time), or we cannot compare cost.
2. **Same model, same rules text, same instances, same judge, dev/test split.**
3. Everyone must understand the whole work (guidelines): walk them through section F below (~15 min).

### To Jia Bao (PDDL domain + prompts)
- The semantics their domain must reproduce: table in `docs/INTERFACE.md` §3.
- Paste `prompts/operator_brief.md` into the PDDL prompts word for word.
- Priority = ADL universal precondition (`forall … imply`), costs = `:action-costs`.
- **Capacity:** Fast Downward has no numbers — choose: load levels as objects, a numeric planner, or compare on
  unlimited-capacity instances only.
- Location ids in `data/instances/*.json` are already PDDL-safe object names.

### To Kimaya (LLM→PDDL→planner + self-repair)
- Score plans with `python -m rescue.cli validate-plan <instance> sas_plan --pddl` (locations must be the last
  arguments of each action, INTERFACE §4).
- Record **where** each failure happens: PDDL syntax error / planner finds no plan / plan found but the judge says
  invalid (= the translation was wrong, e.g. a blocked road written as open — only the judge can see this).
- Cut-off villages must be left out of the PDDL goal, or the planner says "no plan".
- Cap self-repair at 2 rounds and record what feedback it got, to match `nl-repair`.
- Use the same model; tune only on `dev`.

---

## E. The one sentence each to remember for Q&A
- *Why an oracle?* Without the true optimum you can say a plan is valid but not how good it is.
- *Why an independent judge?* The planner trusts its PDDL and the LLM trusts itself; only a judge with the true
  map catches a mistranslation or a hallucinated road.
- *Why three language levels?* Proposal Risk #2: explicit reports make translation trivial; L2/L3 test inference.
- *Why gold-facts?* It separates "misread the report" from "planned badly".
- *Why tools disabled?* Otherwise the "LLM-only" model could write a Dijkstra script, and it would not be LLM-only.
- *Who decides priority?* Not the model: the policy is written in the rules, applied identically, and checked
  (Responsible AI: value decisions belong to humans; the cost of the policy is measured).

---

## F. Code to show teammates (a 15-minute walkthrough, in this order)

| step | open | point at |
|---|---|---|
| 1 | `tests/conftest.py` | a 5-place map you can check by hand: optimal = 40 min, injured place first, one village cut off |
| 2 | `rescue/schema.py:1` | the formal model in the docstring; `tier()` at line 83 |
| 3 | `data/reports/k8-s3-cap-cut/L1.txt` → `L2.txt` → `L3.txt` | same facts, three difficulty levels |
| 4 | `rescue/reports.py:206` (`_l1`), `:222` (`_l2`), `:244` (`_l3`) | how each level is written |
| 5 | `rescue/validator.py:125` (`validate`) | the judge. Key lines: blocked road `:174`, capacity `:196`, priority `:202`, people left behind `:238`, wrong "unreachable" `:251`, definition of valid `:259` |
| 6 | `rescue/validator.py:346` (`parse_pddl_plan`) | how Kimaya's `sas_plan` is read |
| 7 | `rescue/oracle.py:36` (`solve`) | uniform-cost search: loop `:71`, goal test `:77`, pickup successors `:87`, dropoff `:89`, tier rule `:59` |
| 8 | `rescue/llm_only.py:41` (`VARIANTS`), `:49` (`build_prompt`), `:104` (`run_one`), repair loop `:114` | the pipeline |
| 9 | `rescue/backends.py:111` | the exact `claude` command: `--tools ""` = no tools, `--setting-sources ""` = no personal settings |
| 10 | `tests/test_oracle_validator.py` | each judge error has a small test showing the mistake it catches |
