# LLM-only ("direct") pipeline: results, run 2

Run 2 of the direct pipeline, scored against the proven-optimal references. Written 8 Nov 2026 by Wilson (Person 2).
Run 1 (3–4 Nov) is written up in `wilson/main_run_results.md`. This document mentions run 1 only where the
comparison matters. One row per run, for both runs: `wilson/main_results-run-2.csv`.

## 1. What was run

- **Task:** all 45 instances × explicit/implicit reports = 90 reports, each sent once to each model.
- **Models:** `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5`, effort medium, one attempt per report, tools off,
  through a claude.ai subscription with `claude -p` via `pipelines/cli_eval.py`.
- **Unchanged from run 1:** prompt, reports, instances and checker (`pipelines/checker.py`).
- **Reference:** `pddl/results/best_reference.csv`. Jia Bao's exact solver (`pddl/exact.py`, PR #4) proved the optimum
  for all 45 instances. This lowered 10 large references and confirmed `medium-14`, so no valid plan can be cheaper than its reference.
- **Data:** run 2 is in `pipelines/runs/rerun-opus`, `rerun-sonnet` and `rerun-haiku`; run 1 is in `pipelines/runs/main`,
  `main-sonnet` and `main-haiku`. Run 1 was only re-scored against the new reference, so its plans, `valid` and `cost`
  are unchanged.
- **Categories:** **better** = valid and cheaper than the reference; **match** = valid and equal to it; **worse** = valid
  and more expensive; **invalid** = rejected by the checker. Every plan in both runs was re-checked with the checker.

## 2. Headline results (run 2)

The number in brackets is the cost above the reference. Any run not named as worse or invalid is a match.

| Model | Better | Match | Worse | Invalid |
|---|---|---|---|---|
| Opus | 0 (none) | **88**/90 | 2: large-08 explicit (+4), large-15 explicit (+1) | 0: none |
| Sonnet | 0 (none) | **72**/90 | 18: small-10 explicit (+8), medium-01 explicit (+16), medium-01 implicit (+16), large-02 explicit (+6), large-06 explicit (+5), large-07 explicit (+6), large-08 explicit (+8), large-08 implicit (+4), large-09 implicit (+4), large-10 explicit (+42), large-11 explicit (+2), large-12 explicit (+10), large-12 implicit (+10), large-13 explicit (+5), large-13 implicit (+5), large-14 explicit (+12), large-15 explicit (+1), large-15 implicit (+1) | 0: none |
| Haiku | 0 (none) | **70**/90 | 15: small-15 implicit (+50), medium-02 explicit (+1), medium-02 implicit (+1), medium-03 explicit (+14), medium-07 implicit (+17), medium-11 implicit (+16), large-06 implicit (+3), large-07 implicit (+20), large-08 explicit (+4), large-08 implicit (+4), large-09 explicit (+28), large-12 explicit (+10), large-14 explicit (+12), large-14 implicit (+43), large-15 explicit (+1) | 5: small-09 implicit, medium-03 implicit, medium-05 implicit, medium-06 implicit, large-04 implicit |

**Compared with run 1** (run 1 re-scored against the same reference):

| Model | Match, run 1 → run 2 | Worse, run 1 → run 2 | Invalid, run 1 → run 2 | Runs with a different outcome or cost |
|---|---|---|---|---|
| Opus | 84 → **88** | 5 → 2 | 1 → 0 | 6/90 |
| Sonnet | 70 → **72** | 19 → 18 | 1 → 0 | 17/90 |
| Haiku | 70 → **70** | 14 → 15 | 6 → 5 | 24/90 |

No plan was better than its reference in either run (0 of 540), which is what should happen against a proven optimum.
Section 4 lists every run whose outcome changed.

### What the totals hide (summary; full detail and tables in section 5)

1. **Similar totals, many changed runs:** Haiku scored 70 matches both times, but 24 of its 90 runs changed (Sonnet 17, Opus 6).
2. **Sonnet and Haiku tie only overall:** Sonnet leads on small and medium (111 vs 96 of 120), and Haiku leads on large (44 vs 31 of 60).
3. **Sonnet's explicit vs implicit result reversed:** its matches went from 39/31 to 33/39, so we can't claim an effect for Sonnet.
4. **Haiku's invalid plans are mostly one misreading:** 8 of its 11 invalid plans drive a road described as "floodwater is running fast… a truck was swept off it". No model drove a road with any other damage wording.
5. **Some "worse" plans save more people:** Haiku often drives further to avoid deferring someone. Its `small-15` implicit plan scores 67.6% worse while saving 3 more people.
6. **Near-misses repeat:** 13 worse runs reached the same suboptimal solution in both runs.
7. **Difficulty is concentrated:** 44 of 90 reports were matched by all 6 runs, and 53 of the 86 misses are on large.
8. **A second attempt helps the smaller models more:** reports matched at least once were Opus 89, Sonnet 79 and Haiku 81 of 90.
9. **Opus used 38% more output tokens in run 2:** the cause is unknown.
10. **The two-`<plan>`-blocks problem did not recur:** it affected 2 runs in run 1 and none in run 2.

## 3. Every instance, run 2

Each cell is the run 2 outcome: **match**, the cost above the reference (**+10**), or **invalid**. Anything other than
a match is in bold. "(run 1: …)" appears only when run 1 had a different outcome or cost.

### 3.1 Small

Run 2: Opus 30/30 match, 0 worse, 0 invalid; Sonnet 29/30 match, 1 worse, 0 invalid; Haiku 28/30 match, 1 worse, 1 invalid.

| Instance | Reference | Opus explicit | Opus implicit | Sonnet explicit | Sonnet implicit | Haiku explicit | Haiku implicit |
|---|---|---|---|---|---|---|---|
| `small-01` | 154 | match | match | match | match (run 1: +22) | match | match |
| `small-02` | 170 | match | match | match | match | match | match |
| `small-03` | 146 | match | match | match | match | match | match |
| `small-04` | 102 | match | match | match | match | match (run 1: +26) | match |
| `small-05` | 102 | match | match | match | match | match | match |
| `small-06` | 106 | match | match | match | match | match | match (run 1: invalid) |
| `small-07` | 122 | match | match | match | match | match | match |
| `small-08` | 520 | match | match | match | match | match | match (run 1: +40) |
| `small-09` | 420 | match | match | match | match | match | **invalid** (run 1: match) |
| `small-10` | 136 | match | match | **+8** | match (run 1: +8) | match | match |
| `small-11` | 154 | match | match | match | match | match | match |
| `small-12` | 158 | match | match | match | match | match | match |
| `small-13` | 120 | match | match | match | match | match | match |
| `small-14` | 120 | match | match | match | match | match | match |
| `small-15` | 74 | match | match | match | match | match | **+50** (run 1: +44) |

### 3.2 Medium

Run 2: Opus 30/30 match, 0 worse, 0 invalid; Sonnet 28/30 match, 2 worse, 0 invalid; Haiku 22/30 match, 5 worse, 3 invalid.

| Instance | Reference | Opus explicit | Opus implicit | Sonnet explicit | Sonnet implicit | Haiku explicit | Haiku implicit |
|---|---|---|---|---|---|---|---|
| `medium-01` | 250 | match | match | **+16** (run 1: match) | **+16** | match | match |
| `medium-02` | 191 | match | match | match | match | **+1** (run 1: match) | **+1** (run 1: match) |
| `medium-03` | 528 | match | match | match | match | **+14** | **invalid** |
| `medium-04` | 716 | match | match | match | match | match | match |
| `medium-05` | 412 | match | match | match | match | match | **invalid** |
| `medium-06` | 282 | match | match | match | match | match | **invalid** |
| `medium-07` | 411 | match | match | match | match | match | **+17** |
| `medium-08` | 280 | match | match | match | match | match (run 1: +12) | match |
| `medium-09` | 330 | match | match | match | match | match | match |
| `medium-10` | 476 | match | match | match | match | match | match |
| `medium-11` | 496 | match | match | match | match | match | **+16** (run 1: match) |
| `medium-12` | 278 | match | match | match | match | match | match |
| `medium-13` | 166 | match | match | match | match | match (run 1: +22) | match |
| `medium-14` | 401 | match | match | match | match (run 1: +5) | match (run 1: +6) | match |
| `medium-15` | 194 | match | match | match | match (run 1: +18) | match (run 1: +18) | match (run 1: +18) |

### 3.3 Large

Run 2: Opus 28/30 match, 2 worse, 0 invalid; Sonnet 15/30 match, 15 worse, 0 invalid; Haiku 20/30 match, 9 worse, 1 invalid.

| Instance | Reference | Opus explicit | Opus implicit | Sonnet explicit | Sonnet implicit | Haiku explicit | Haiku implicit |
|---|---|---|---|---|---|---|---|
| `large-01` | 240 | match | match | match | match | match | match |
| `large-02` | 428 | match (run 1: +2) | match | **+6** | match (run 1: +1) | match | match |
| `large-03` | 434 | match | match | match | match | match | match |
| `large-04` | 577 | match | match | match | match (run 1: +31) | match | **invalid** |
| `large-05` | 566 | match | match | match | match | match | match |
| `large-06` | 445 | match | match | **+5** (run 1: match) | match | match | **+3** (run 1: match) |
| `large-07` | 422 | match | match | **+6** (run 1: match) | match (run 1: +6) | match | **+20** (run 1: +16) |
| `large-08` | 366 | **+4** (run 1: match) | match | **+8** | **+4** (run 1: +8) | **+4** | **+4** (run 1: match) |
| `large-09` | 818 | match (run 1: invalid) | match | match | **+4** | **+28** (run 1: match) | match (run 1: invalid) |
| `large-10` | 402 | match | match | **+42** (run 1: match) | match | match | match |
| `large-11` | 403 | match (run 1: +2) | match | **+2** (run 1: match) | match (run 1: +8) | match | match |
| `large-12` | 302 | match (run 1: +10) | match | **+10** | **+10** | **+10** (run 1: match) | match (run 1: +6) |
| `large-13` | 212 | match | match | **+5** | **+5** (run 1: match) | match (run 1: +26) | match |
| `large-14` | 460 | match | match | **+12** (run 1: match) | match (run 1: invalid) | **+12** (run 1: match) | **+43** (run 1: match) |
| `large-15` | 476 | **+1** | match (run 1: +1) | **+1** | **+1** | **+1** (run 1: match) | match |

### 3.4 By report type (run 2, run 1 in brackets)

| Model | Explicit: match | Explicit: worse | Explicit: invalid | Implicit: match | Implicit: worse | Implicit: invalid |
|---|---|---|---|---|---|---|
| Opus | 43 (40) | 2 (4) | 0 (1) | 45 (44) | 0 (1) | 0 (0) |
| Sonnet | 33 (39) | 12 (6) | 0 (0) | 39 (31) | 6 (13) | 0 (1) |
| Haiku | 38 (37) | 7 (8) | 0 (0) | 32 (33) | 8 (6) | 5 (6) |

### 3.5 Invalid plans, with the checker's error

| Model | Run | Instance | Checker error |
|---|---|---|---|
| Opus | 1 | `large-09` explicit | step 18: only 0 adult waiting at kakani-market, cannot load 1 |
| Sonnet | 1 | `large-14` implicit | step 40: cannot defer 3 adult at tarkeshwar-market (1 waiting) |
| Haiku | 2 | `small-09` implicit | step 1: road kispang-shelter-nilkantha-village is damaged |
| Haiku | 2 | `medium-03` implicit | step 9: cannot defer 1 injured at kakani-temple (0 waiting) |
| Haiku | 2 | `medium-05` implicit | step 7: road myagang-care-home-suryagadhi-care-home is damaged |
| Haiku | 2 | `medium-06` implicit | step 14: road kalika-temple-nilkantha-temple is damaged |
| Haiku | 2 | `large-04` implicit | step 5: road shivapuri-shelter-bidur-school is damaged |
| Haiku | 1 | `small-06` implicit | plan ends with people unresolved: 1 adult at gosaikunda-farm |
| Haiku | 1 | `medium-03` implicit | step 9: cannot defer 1 injured at kakani-temple (0 waiting) |
| Haiku | 1 | `medium-05` implicit | step 7: road myagang-care-home-suryagadhi-care-home is damaged |
| Haiku | 1 | `medium-06` implicit | step 14: road kalika-temple-nilkantha-temple is damaged |
| Haiku | 1 | `large-04` implicit | step 5: road shivapuri-shelter-bidur-school is damaged |
| Haiku | 1 | `large-09` implicit | step 1: road panchakanya-shelter-suryagadhi-school is damaged |

## 4. What changed between run 1 and run 2

Every run whose outcome or cost changed, by kind of change. The number is the cost above the reference.

| Model | Worse → match | Match → worse | Invalid → match | Match → invalid | Worse → worse, new cost |
|---|---|---|---|---|---|
| Opus | 4: large-02 explicit (was +2), large-11 explicit (was +2), large-12 explicit (was +10), large-15 implicit (was +1) | 1: large-08 explicit (now +4) | 1: large-09 explicit | 0 | 0 |
| Sonnet | 8: small-01 implicit (was +22), small-10 implicit (was +8), medium-14 implicit (was +5), medium-15 implicit (was +18), large-02 implicit (was +1), large-04 implicit (was +31), large-07 implicit (was +6), large-11 implicit (was +8) | 7: medium-01 explicit (now +16), large-06 explicit (now +5), large-07 explicit (now +6), large-10 explicit (now +42), large-11 explicit (now +2), large-13 implicit (now +5), large-14 explicit (now +12) | 1: large-14 implicit | 0 | 1: large-08 implicit (+8 → +4) |
| Haiku | 9: small-04 explicit (was +26), small-08 implicit (was +40), medium-08 explicit (was +12), medium-13 explicit (was +22), medium-14 explicit (was +6), medium-15 explicit (was +18), medium-15 implicit (was +18), large-12 implicit (was +6), large-13 explicit (was +26) | 10: medium-02 explicit (now +1), medium-02 implicit (now +1), medium-11 implicit (now +16), large-06 implicit (now +3), large-08 implicit (now +4), large-09 explicit (now +28), large-12 explicit (now +10), large-14 explicit (now +12), large-14 implicit (now +43), large-15 explicit (now +1) | 2: small-06 implicit, large-09 implicit | 1: small-09 implicit | 2: small-15 implicit (+44 → +50), large-07 implicit (+16 → +20) |

## 5. What the totals hide

**5.1 Similar totals, but many individual runs changed.** Haiku scored 70 matches in both runs, yet 24 of its 90 runs
changed outcome or cost (Sonnet 17, Opus 6; section 4 lists each one). On `large-12`, Haiku's explicit run went from
match to +10 while its implicit run went from +6 to match. For Sonnet and Haiku, one run of a report is a weak
measurement.

**5.2 Sonnet and Haiku tie overall, but not at any size.** Matches across both runs (out of 180): Opus 172, Sonnet 142,
Haiku 140. Split by size, the near-tie turns out to be two opposite results, and both runs agree on the direction:

| Size | Opus, run 1 / run 2 | Sonnet, run 1 / run 2 | Haiku, run 1 / run 2 |
|---|---|---|---|
| Small (of 30) | 30 / 30 | 27 / 29 | 26 / 28 |
| Medium (of 30) | 30 / 30 | 27 / 28 | 20 / 22 |
| Large (of 30) | 24 / 28 | **16 / 15** | **24 / 20** |

Haiku is weaker than Sonnet on small and medium (96 vs 111 of 120) but stronger on large (44 vs 31 of 60), where it
also writes about 4× as many output tokens (section 6). Whether the extra tokens cause the better large results is a
hypothesis; this data doesn't test it. Opus is the best at every size, or tied for best.

**5.3 Sonnet's explicit vs implicit result reversed.** Sonnet's matches (explicit/implicit) were 39/31 in run 1 and
33/39 in run 2 (section 3.4). Most of the swing is on large: explicit went from 10 to 5, and implicit from 6 to 10. Run
1 suggested that implicit reports hurt Sonnet, and run 2 doesn't support that, so we shouldn't claim an explicit vs
implicit effect for Sonnet. Opus (40/44, then 43/45) and Haiku (37/33, then 38/32) didn't reverse, but their
differences are small too.

**5.4 Haiku's invalid plans are mostly one misreading.** All 11 Haiku invalids across both runs are on implicit
reports, and none are on explicit ones. 8 of the 11 drive onto a road described with one wording, while no model ever
drove a road described with the other three damage wordings:

| Damage wording in the implicit report | Reports | Opus | Sonnet | Haiku |
|---|---|---|---|---|
| "Floodwater is running fast ... a truck was swept off it" | 24 | 0/48 runs drove it | 0/48 runs drove it | 8/48 runs drove it: small-09 (run 2), medium-05 (run 1), medium-05 (run 2), medium-06 (run 1), medium-06 (run 2), large-04 (run 1), large-04 (run 2), large-09 (run 1) |
| "A landslide has buried the road" | 20 | 0/40 runs drove it | 0/40 runs drove it | 0/40 runs drove it |
| "Police have closed the ... road" | 20 | 0/40 runs drove it | 0/40 runs drove it | 0/40 runs drove it |
| "The bridge ... was washed away" | 19 | 0/38 runs drove it | 0/38 runs drove it | 0/38 runs drove it |

The floodwater sentence is the only one of the four that describes a hazard without saying the road is gone or
closed. The explicit reports mark the same roads "IMPASSABLE (damaged)". The misreading repeats on `large-04`,
`medium-05` and `medium-06`, but `large-09` failed only in run 1 and `small-09` only in run 2.

The other 3 Haiku invalids:
- **`medium-03` implicit fails in both runs,** with the same error and the same first 11 plan steps. The report says
  "an old man who cannot walk unaided", and the explicit report says "1 elderly person". Haiku tried to defer him as
  injured, and the checker rejected that because no injured person is waiting there. The same wording appears in 4
  reports (`medium-03`, `medium-10`, `large-14`, `large-15`), and only `medium-03` failed this way.
- **`small-06` implicit, run 1 only:** Haiku forgot 1 adult. This did not recur.

**5.5 "Worse" covers different mistakes, and some "worse" plans save more people.** I compared every worse plan with
the exact solver's optimal plan for the same instance (`pddl/instances/<id>.exact-plan`). Run 2:

| Model | Same people deferred, longer drive | Defers fewer than the optimum (over-rescue) | Defers more than the optimum |
|---|---|---|---|
| Opus | 1: large-15 explicit (+1) | 0 | 1: large-08 explicit (+4) |
| Sonnet | 11: small-10 explicit (+8), large-02 explicit (+6), large-07 explicit (+6), large-09 implicit (+4), large-10 explicit (+42), large-12 explicit (+10), large-12 implicit (+10), large-13 explicit (+5), large-13 implicit (+5), large-15 explicit (+1), large-15 implicit (+1) | 1: large-11 explicit (+2) | 6: medium-01 explicit (+16), medium-01 implicit (+16), large-06 explicit (+5), large-08 explicit (+8), large-08 implicit (+4), large-14 explicit (+12) |
| Haiku | 4: medium-03 explicit (+14), medium-11 implicit (+16), large-12 explicit (+10), large-15 explicit (+1) | 8: small-15 implicit (+50), medium-02 explicit (+1), medium-02 implicit (+1), medium-07 implicit (+17), large-06 implicit (+3), large-07 implicit (+20), large-09 explicit (+28), large-14 implicit (+43) | 3: large-08 explicit (+4), large-08 implicit (+4), large-14 explicit (+12) |
| **All, run 2** | 16 | 9 | 10 |
| All, run 1 | 19 | 14 | 5 |

Sonnet's usual mistake is a slightly longer route. Haiku's is driving further to avoid a deferral that the cost
function says is worth accepting. Across both runs, over-rescue is the costliest kind, at +18.8 on average against
+7.9 for a longer drive and +9.5 for deferring too many. The run 2 over-rescue plans:

| Model | Instance | Plan: driving + penalty | Optimum: driving + penalty | Plan defers | Optimum defers |
|---|---|---|---|---|---|
| Sonnet | `large-11` explicit | 265 + 140 = 405 | 243 + 160 = 403 | 7 adult | 8 adult |
| Haiku | `small-15` implicit | 124 + 0 = 124 | 14 + 60 = 74 | nobody | 3 adult |
| Haiku | `medium-02` explicit | 192 + 0 = 192 | 151 + 40 = 191 | nobody | 2 adult |
| Haiku | `medium-02` implicit | 192 + 0 = 192 | 151 + 40 = 191 | nobody | 2 adult |
| Haiku | `medium-07` implicit | 368 + 60 = 428 | 271 + 140 = 411 | 3 adult | 7 adult |
| Haiku | `large-06` implicit | 308 + 140 = 448 | 265 + 180 = 445 | 2 elderly, 2 adult | 2 elderly, 4 adult |
| Haiku | `large-07` implicit | 442 + 0 = 442 | 302 + 120 = 422 | nobody | 1 injured, 2 adult |
| Haiku | `large-09` explicit | 376 + 470 = 846 | 268 + 550 = 818 | 3 injured, 3 elderly, 4 adult | 3 injured, 3 elderly, 8 adult |
| Haiku | `large-14` implicit | 503 + 0 = 503 | 400 + 60 = 460 | nobody | 3 adult |

Every one of these 9 plans saves more people than the optimum. The clearest example is Haiku's `small-15` implicit,
which rescues everyone for a cost of 124. The optimum defers 3 adults, for a cost of 74, so the plan is scored 67.6%
worse while saving 3 more people.

**For the report:** "worse" means worse under the current penalties (injured 80, child 60, elderly 50, adult 20), not
necessarily worse for the people in the flood. This bears directly on the deferral-penalty discussion, because a
higher adult penalty would change which of these plans counts as optimal. These runs have not been re-scored under
other penalties.

**5.6 Some near-misses repeat.** 14 worse runs have the same cost in both runs:

| Model | Instance | Cost above reference, both runs | Same driving time and people deferred? | Same plan? |
|---|---|---|---|---|
| Opus | `large-15` explicit | +1 | yes | no |
| Sonnet | `small-10` explicit | +8 | yes | word for word |
| Sonnet | `medium-01` implicit | +16 | yes | word for word |
| Sonnet | `large-02` explicit | +6 | yes | same actions, different order |
| Sonnet | `large-08` explicit | +8 | no: 204 + 170 vs 264 + 110 | no |
| Sonnet | `large-09` implicit | +4 | yes | same actions, different order |
| Sonnet | `large-12` explicit | +10 | yes | no |
| Sonnet | `large-12` implicit | +10 | yes | no |
| Sonnet | `large-13` explicit | +5 | yes | same actions, different order |
| Sonnet | `large-15` explicit | +1 | yes | same actions, different order |
| Sonnet | `large-15` implicit | +1 | yes | no |
| Haiku | `medium-03` explicit | +14 | yes | word for word |
| Haiku | `medium-07` implicit | +17 | yes | same actions, different order |
| Haiku | `large-08` explicit | +4 | yes | no |

13 of the 14 have the same driving time and the same people deferred, so the model reached the same suboptimal
solution twice. The exception is Sonnet's `large-08` explicit, where the costs are equal by coincidence.

**5.7 The difficulty is concentrated.** This table counts, for each of the 90 reports, how many of its 6 runs (3 models × 2 runs) missed the
optimum:

| Runs that missed (of 6) | Reports |
|---|---|
| 5 | 2: large-08 explicit, large-15 explicit |
| 4 | 1: large-12 explicit |
| 3 | 8: large-02 explicit, large-04 implicit, large-07 implicit, large-08 implicit, large-09 implicit, large-12 implicit, large-13 explicit, large-15 implicit |
| 2 | 13: small-10 explicit, small-15 implicit, medium-01 implicit, medium-03 explicit, medium-03 implicit, medium-05 implicit, medium-06 implicit, medium-07 implicit, medium-15 implicit, large-09 explicit, large-11 explicit, large-14 explicit, large-14 implicit |
| 1 | 22: small-01 implicit, small-04 explicit, small-06 implicit, small-08 implicit, small-09 implicit, small-10 implicit, medium-01 explicit, medium-02 explicit, medium-02 implicit, medium-08 explicit, medium-11 implicit, medium-13 explicit, medium-14 explicit, medium-14 implicit, medium-15 explicit, large-02 implicit, large-06 explicit, large-06 implicit, large-07 explicit, large-10 explicit, large-11 implicit, large-13 implicit |
| 0 | 44 (every run matched) |

Of the 86 runs that missed, 53 are on large, 23 on medium and 10 on small. Every report was matched by at least one run.

**5.8 A second attempt helps the smaller models more.** The pipeline makes one attempt per report, so this isn't what
it does. It only shows how much of each model's shortfall is run-to-run variation:

| Model | Matched in both runs | Matched in at least one run | Never matched |
|---|---|---|---|
| Opus | 83/90 | 89/90 | 1: large-15 explicit |
| Sonnet | 63/90 | 79/90 | 11: small-10 explicit, medium-01 implicit, large-02 explicit, large-08 explicit, large-08 implicit, large-09 implicit, large-12 explicit, large-12 implicit, large-13 explicit, large-15 explicit, large-15 implicit |
| Haiku | 59/90 | 81/90 | 9: small-15 implicit, medium-03 explicit, medium-03 implicit, medium-05 implicit, medium-06 implicit, medium-07 implicit, large-04 implicit, large-07 implicit, large-08 explicit |

**5.9 Opus used 38% more tokens in run 2, and the cause is unknown.** Its mean output went from 2,093 to 2,880 tokens
per run, and 82 of its 90 runs used more than in run 1. For Sonnet and Haiku, 40/90 and 50/90 runs used more, which
is about what chance would give. Input tokens per run are unchanged (2,085), so the prompt is the same size. Opus also
went from 84 to 88 matches, but nothing here shows that one caused the other. The run files don't record the Claude
Code version, so a change there can't be ruled out.

**5.10 The two-`<plan>`-blocks problem did not recur.** `extract_plan` scores the first `<plan>` block. In run 1,
two answers had two blocks (Opus `large-09` explicit and Haiku `small-09` implicit; see `wilson/main_run_results.md`
section 8). In run 2, none did.

## 6. Output tokens and seconds per run

Mean per run, run 2 first, with run 1 in brackets. Seconds depend on load and time of day, so they are not a clean
speed comparison.

| Size | Opus | Sonnet | Haiku |
|---|---|---|---|
| small | 1,204 tokens, 13.1 s (run 1: 963, 11.6 s) | 908 tokens, 8.9 s (run 1: 962, 10.8 s) | 3,086 tokens, 16.2 s (run 1: 2,991, 14.8 s) |
| medium | 2,342 tokens, 24.0 s (run 1: 1,761, 19.1 s) | 1,860 tokens, 15.0 s (run 1: 1,858, 17.6 s) | 7,836 tokens, 38.0 s (run 1: 7,970, 37.1 s) |
| large | 5,095 tokens, 50.7 s (run 1: 3,555, 36.8 s) | 3,889 tokens, 29.6 s (run 1: 3,966, 32.6 s) | 15,750 tokens, 71.1 s (run 1: 15,828, 70.6 s) |
| all | 2,880 tokens, 29.3 s (run 1: 2,093, 22.5 s) | 2,219 tokens, 17.9 s (run 1: 2,262, 20.3 s) | 8,891 tokens, 41.8 s (run 1: 8,930, 40.8 s) |

## 7. Claims from run 1 that this replaces

- **"Beat best-known" is withdrawn.** It was measured against the old, non-optimal reference. What remains true is
  narrower: on the 10 large instances where Fast Downward timed out, the models found cheaper plans than Fast
  Downward's best in 300 s. No plan in either run is cheaper than the proven optimum.
- **"Haiku found the best plans of all three on `large-15`" needs care.** Across both runs, the optimum 476 was reached
  3 of 4 times by Haiku, 1 of 4 by Opus (run 2 implicit) and 0 of 4 by Sonnet. That leans towards Haiku, but it isn't
  Haiku alone.
- **"The models differ in reliability, not in how good their plans can be" is too strong.** Opus matches 172 of 180
  runs against Sonnet's 142 and Haiku's 140, so the match rate differs as well as validity.
- **"Sonnet's drop to 26/34 optimal on implicit"** (`wilson/main_run_results.md` 11.7) did not hold in run 2 (section 5.3).
- **Mean gaps in `wilson/main_run_results.md` sections 2–4 and 11** used the old reference. Current values are in each
  run's `results.csv`.

## 8. Limits

- **Small sample:** two runs per model on the same reports show how much one repeat differed, not a stable variance
  estimate. The two runs aren't independent samples, and no significance tests were run.
- **Usage limit in run 2:** the Opus runs hit a usage limit on 6 Nov, and 7 failed calls were filled in on 7 Nov. They
  count like any other run. Sonnet and Haiku ran on 7 Nov with no errors.
- **Cost figures:** dollar amounts in the run logs are estimates from token counts, not charges, because the runs were on
  a subscription.
- **Stray space:** `pipelines/reports/large-01-explicit.txt` has a stray leading space in the local copy only. It isn't
  committed, and both runs read the same file.
