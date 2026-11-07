# CS3263 Group 11: LLM-only re-run, classification against proven-optimal references

Generated locally from `wilson/rerun_classification.csv` (one row per run, 540 runs). Nothing here is committed.

**Beat check: 0 runs beat the reference.** No plan has a cost below its reference, which is what should happen now that all 45 references are proven optimal. No checker or solver bug is indicated by this check.

Categories: **beat** = valid and cost < reference; **match** = valid and cost = reference; **worse** = valid and cost > reference; **invalid** = checker rejected the plan; **errored** = no saved result (none in this data). Each of the 90 runs per model and set is 45 instances x explicit/implicit, one attempt each. Reference = `pddl/results/best_reference.csv`, all 45 proven optimal (Jia Bao's exact solver). Every plan was re-checked with `pipelines/checker.py`; all 540 re-checks agree with the stored valid/cost.

## 1. Counts per model and attempt set

| Scope | Model | Set | n | beat | match | worse | invalid | errored |
|---|---|---|---|---|---|---|---|---|
| all | Opus 5.5 | original | 90 | 0 | 84 | 5 | 1 | 0 |
| all | Opus 5.5 | rerun | 90 | 0 | 88 | 2 | 0 | 0 |
| all | Sonnet 5.5 | original | 90 | 0 | 70 | 19 | 1 | 0 |
| all | Sonnet 5.5 | rerun | 90 | 0 | 72 | 18 | 0 | 0 |
| all | Haiku 5.5 | original | 90 | 0 | 70 | 14 | 6 | 0 |
| all | Haiku 5.5 | rerun | 90 | 0 | 70 | 15 | 5 | 0 |

Totals per set: original 270 runs, rerun 270 runs.

## 2. Counts by size

| Size | Model | Set | n | beat | match | worse | invalid | errored |
|---|---|---|---|---|---|---|---|---|
| small | Opus 5.5 | original | 30 | 0 | 30 | 0 | 0 | 0 |
| small | Opus 5.5 | rerun | 30 | 0 | 30 | 0 | 0 | 0 |
| small | Sonnet 5.5 | original | 30 | 0 | 27 | 3 | 0 | 0 |
| small | Sonnet 5.5 | rerun | 30 | 0 | 29 | 1 | 0 | 0 |
| small | Haiku 5.5 | original | 30 | 0 | 26 | 3 | 1 | 0 |
| small | Haiku 5.5 | rerun | 30 | 0 | 28 | 1 | 1 | 0 |
| medium | Opus 5.5 | original | 30 | 0 | 30 | 0 | 0 | 0 |
| medium | Opus 5.5 | rerun | 30 | 0 | 30 | 0 | 0 | 0 |
| medium | Sonnet 5.5 | original | 30 | 0 | 27 | 3 | 0 | 0 |
| medium | Sonnet 5.5 | rerun | 30 | 0 | 28 | 2 | 0 | 0 |
| medium | Haiku 5.5 | original | 30 | 0 | 20 | 7 | 3 | 0 |
| medium | Haiku 5.5 | rerun | 30 | 0 | 22 | 5 | 3 | 0 |
| large | Opus 5.5 | original | 30 | 0 | 24 | 5 | 1 | 0 |
| large | Opus 5.5 | rerun | 30 | 0 | 28 | 2 | 0 | 0 |
| large | Sonnet 5.5 | original | 30 | 0 | 16 | 13 | 1 | 0 |
| large | Sonnet 5.5 | rerun | 30 | 0 | 15 | 15 | 0 | 0 |
| large | Haiku 5.5 | original | 30 | 0 | 24 | 4 | 2 | 0 |
| large | Haiku 5.5 | rerun | 30 | 0 | 20 | 9 | 1 | 0 |

## 3. Counts by explicit / implicit

| Level | Model | Set | n | beat | match | worse | invalid | errored |
|---|---|---|---|---|---|---|---|---|
| explicit | Opus 5.5 | original | 45 | 0 | 40 | 4 | 1 | 0 |
| explicit | Opus 5.5 | rerun | 45 | 0 | 43 | 2 | 0 | 0 |
| explicit | Sonnet 5.5 | original | 45 | 0 | 39 | 6 | 0 | 0 |
| explicit | Sonnet 5.5 | rerun | 45 | 0 | 33 | 12 | 0 | 0 |
| explicit | Haiku 5.5 | original | 45 | 0 | 37 | 8 | 0 | 0 |
| explicit | Haiku 5.5 | rerun | 45 | 0 | 38 | 7 | 0 | 0 |
| implicit | Opus 5.5 | original | 45 | 0 | 44 | 1 | 0 | 0 |
| implicit | Opus 5.5 | rerun | 45 | 0 | 45 | 0 | 0 | 0 |
| implicit | Sonnet 5.5 | original | 45 | 0 | 31 | 13 | 1 | 0 |
| implicit | Sonnet 5.5 | rerun | 45 | 0 | 39 | 6 | 0 | 0 |
| implicit | Haiku 5.5 | original | 45 | 0 | 33 | 6 | 6 | 0 |
| implicit | Haiku 5.5 | rerun | 45 | 0 | 32 | 8 | 5 | 0 |

The split above is 45 runs per cell. Small differences between cells are small counts, not established effects.

## 4. Every run by category, model and attempt set

Worse entries show cost difference, percent gap, and cost vs reference. Match lists are per size; 'both' means explicit and implicit both matched.

### Beat

**Opus 5.5, original: 0**

none

**Opus 5.5, rerun: 0**

none

**Sonnet 5.5, original: 0**

none

**Sonnet 5.5, rerun: 0**

none

**Haiku 5.5, original: 0**

none

**Haiku 5.5, rerun: 0**

none

### Worse

**Opus 5.5, original: 5**

- large-02 explicit (+2, 0.5%; 430 vs 428)
- large-11 explicit (+2, 0.5%; 405 vs 403)
- large-12 explicit (+10, 3.3%; 312 vs 302)
- large-15 explicit (+1, 0.2%; 477 vs 476)
- large-15 implicit (+1, 0.2%; 477 vs 476)

**Opus 5.5, rerun: 2**

- large-08 explicit (+4, 1.1%; 370 vs 366)
- large-15 explicit (+1, 0.2%; 477 vs 476)

**Sonnet 5.5, original: 19**

- large-02 explicit (+6, 1.4%; 434 vs 428)
- large-02 implicit (+1, 0.2%; 429 vs 428)
- large-04 implicit (+31, 5.4%; 608 vs 577)
- large-07 implicit (+6, 1.4%; 428 vs 422)
- large-08 explicit (+8, 2.2%; 374 vs 366)
- large-08 implicit (+8, 2.2%; 374 vs 366)
- large-09 implicit (+4, 0.5%; 822 vs 818)
- large-11 implicit (+8, 2.0%; 411 vs 403)
- large-12 explicit (+10, 3.3%; 312 vs 302)
- large-12 implicit (+10, 3.3%; 312 vs 302)
- large-13 explicit (+5, 2.4%; 217 vs 212)
- large-15 explicit (+1, 0.2%; 477 vs 476)
- large-15 implicit (+1, 0.2%; 477 vs 476)
- medium-01 implicit (+16, 6.4%; 266 vs 250)
- medium-14 implicit (+5, 1.2%; 406 vs 401)
- medium-15 implicit (+18, 9.3%; 212 vs 194)
- small-01 implicit (+22, 14.3%; 176 vs 154)
- small-10 explicit (+8, 5.9%; 144 vs 136)
- small-10 implicit (+8, 5.9%; 144 vs 136)

**Sonnet 5.5, rerun: 18**

- large-02 explicit (+6, 1.4%; 434 vs 428)
- large-06 explicit (+5, 1.1%; 450 vs 445)
- large-07 explicit (+6, 1.4%; 428 vs 422)
- large-08 explicit (+8, 2.2%; 374 vs 366)
- large-08 implicit (+4, 1.1%; 370 vs 366)
- large-09 implicit (+4, 0.5%; 822 vs 818)
- large-10 explicit (+42, 10.4%; 444 vs 402)
- large-11 explicit (+2, 0.5%; 405 vs 403)
- large-12 explicit (+10, 3.3%; 312 vs 302)
- large-12 implicit (+10, 3.3%; 312 vs 302)
- large-13 explicit (+5, 2.4%; 217 vs 212)
- large-13 implicit (+5, 2.4%; 217 vs 212)
- large-14 explicit (+12, 2.6%; 472 vs 460)
- large-15 explicit (+1, 0.2%; 477 vs 476)
- large-15 implicit (+1, 0.2%; 477 vs 476)
- medium-01 explicit (+16, 6.4%; 266 vs 250)
- medium-01 implicit (+16, 6.4%; 266 vs 250)
- small-10 explicit (+8, 5.9%; 144 vs 136)

**Haiku 5.5, original: 14**

- large-07 implicit (+16, 3.8%; 438 vs 422)
- large-08 explicit (+4, 1.1%; 370 vs 366)
- large-12 implicit (+6, 2.0%; 308 vs 302)
- large-13 explicit (+26, 12.3%; 238 vs 212)
- medium-03 explicit (+14, 2.7%; 542 vs 528)
- medium-07 implicit (+17, 4.1%; 428 vs 411)
- medium-08 explicit (+12, 4.3%; 292 vs 280)
- medium-13 explicit (+22, 13.3%; 188 vs 166)
- medium-14 explicit (+6, 1.5%; 407 vs 401)
- medium-15 explicit (+18, 9.3%; 212 vs 194)
- medium-15 implicit (+18, 9.3%; 212 vs 194)
- small-04 explicit (+26, 25.5%; 128 vs 102)
- small-08 implicit (+40, 7.7%; 560 vs 520)
- small-15 implicit (+44, 59.5%; 118 vs 74)

**Haiku 5.5, rerun: 15**

- large-06 implicit (+3, 0.7%; 448 vs 445)
- large-07 implicit (+20, 4.7%; 442 vs 422)
- large-08 explicit (+4, 1.1%; 370 vs 366)
- large-08 implicit (+4, 1.1%; 370 vs 366)
- large-09 explicit (+28, 3.4%; 846 vs 818)
- large-12 explicit (+10, 3.3%; 312 vs 302)
- large-14 explicit (+12, 2.6%; 472 vs 460)
- large-14 implicit (+43, 9.3%; 503 vs 460)
- large-15 explicit (+1, 0.2%; 477 vs 476)
- medium-02 explicit (+1, 0.5%; 192 vs 191)
- medium-02 implicit (+1, 0.5%; 192 vs 191)
- medium-03 explicit (+14, 2.7%; 542 vs 528)
- medium-07 implicit (+17, 4.1%; 428 vs 411)
- medium-11 implicit (+16, 3.2%; 512 vs 496)
- small-15 implicit (+50, 67.6%; 124 vs 74)

### Invalid

**Opus 5.5, original: 1**

- large-09 explicit: step 18: only 0 adult waiting at kakani-market, cannot load 1

**Opus 5.5, rerun: 0**

none

**Sonnet 5.5, original: 1**

- large-14 implicit: step 40: cannot defer 3 adult at tarkeshwar-market (1 waiting)

**Sonnet 5.5, rerun: 0**

none

**Haiku 5.5, original: 6**

- large-04 implicit: step 5: road shivapuri-shelter-bidur-school is damaged
- large-09 implicit: step 1: road panchakanya-shelter-suryagadhi-school is damaged
- medium-03 implicit: step 9: cannot defer 1 injured at kakani-temple (0 waiting)
- medium-05 implicit: step 7: road myagang-care-home-suryagadhi-care-home is damaged
- medium-06 implicit: step 14: road kalika-temple-nilkantha-temple is damaged
- small-06 implicit: plan ends with people unresolved: 1 adult at gosaikunda-farm

**Haiku 5.5, rerun: 5**

- large-04 implicit: step 5: road shivapuri-shelter-bidur-school is damaged
- medium-03 implicit: step 9: cannot defer 1 injured at kakani-temple (0 waiting)
- medium-05 implicit: step 7: road myagang-care-home-suryagadhi-care-home is damaged
- medium-06 implicit: step 14: road kalika-temple-nilkantha-temple is damaged
- small-09 implicit: step 1: road kispang-shelter-nilkantha-village is damaged

### Errored

**Opus 5.5, original: 0**

none

**Opus 5.5, rerun: 0**

none

**Sonnet 5.5, original: 0**

none

**Sonnet 5.5, rerun: 0**

none

**Haiku 5.5, original: 0**

none

**Haiku 5.5, rerun: 0**

none

### Match

**Opus 5.5, original: 84**

- small (30): small-01 (both), small-02 (both), small-03 (both), small-04 (both), small-05 (both), small-06 (both), small-07 (both), small-08 (both), small-09 (both), small-10 (both), small-11 (both), small-12 (both), small-13 (both), small-14 (both), small-15 (both)
- medium (30): medium-01 (both), medium-02 (both), medium-03 (both), medium-04 (both), medium-05 (both), medium-06 (both), medium-07 (both), medium-08 (both), medium-09 (both), medium-10 (both), medium-11 (both), medium-12 (both), medium-13 (both), medium-14 (both), medium-15 (both)
- large (24): large-01 (both), large-02 (implicit only), large-03 (both), large-04 (both), large-05 (both), large-06 (both), large-07 (both), large-08 (both), large-09 (implicit only), large-10 (both), large-11 (implicit only), large-12 (implicit only), large-13 (both), large-14 (both)

**Opus 5.5, rerun: 88**

- small (30): small-01 (both), small-02 (both), small-03 (both), small-04 (both), small-05 (both), small-06 (both), small-07 (both), small-08 (both), small-09 (both), small-10 (both), small-11 (both), small-12 (both), small-13 (both), small-14 (both), small-15 (both)
- medium (30): medium-01 (both), medium-02 (both), medium-03 (both), medium-04 (both), medium-05 (both), medium-06 (both), medium-07 (both), medium-08 (both), medium-09 (both), medium-10 (both), medium-11 (both), medium-12 (both), medium-13 (both), medium-14 (both), medium-15 (both)
- large (28): large-01 (both), large-02 (both), large-03 (both), large-04 (both), large-05 (both), large-06 (both), large-07 (both), large-08 (implicit only), large-09 (both), large-10 (both), large-11 (both), large-12 (both), large-13 (both), large-14 (both), large-15 (implicit only)

**Sonnet 5.5, original: 70**

- small (27): small-01 (explicit only), small-02 (both), small-03 (both), small-04 (both), small-05 (both), small-06 (both), small-07 (both), small-08 (both), small-09 (both), small-11 (both), small-12 (both), small-13 (both), small-14 (both), small-15 (both)
- medium (27): medium-01 (explicit only), medium-02 (both), medium-03 (both), medium-04 (both), medium-05 (both), medium-06 (both), medium-07 (both), medium-08 (both), medium-09 (both), medium-10 (both), medium-11 (both), medium-12 (both), medium-13 (both), medium-14 (explicit only), medium-15 (explicit only)
- large (16): large-01 (both), large-03 (both), large-04 (explicit only), large-05 (both), large-06 (both), large-07 (explicit only), large-09 (explicit only), large-10 (both), large-11 (explicit only), large-13 (implicit only), large-14 (explicit only)

**Sonnet 5.5, rerun: 72**

- small (29): small-01 (both), small-02 (both), small-03 (both), small-04 (both), small-05 (both), small-06 (both), small-07 (both), small-08 (both), small-09 (both), small-10 (implicit only), small-11 (both), small-12 (both), small-13 (both), small-14 (both), small-15 (both)
- medium (28): medium-02 (both), medium-03 (both), medium-04 (both), medium-05 (both), medium-06 (both), medium-07 (both), medium-08 (both), medium-09 (both), medium-10 (both), medium-11 (both), medium-12 (both), medium-13 (both), medium-14 (both), medium-15 (both)
- large (15): large-01 (both), large-02 (implicit only), large-03 (both), large-04 (both), large-05 (both), large-06 (implicit only), large-07 (implicit only), large-09 (explicit only), large-10 (implicit only), large-11 (implicit only), large-14 (implicit only)

**Haiku 5.5, original: 70**

- small (26): small-01 (both), small-02 (both), small-03 (both), small-04 (implicit only), small-05 (both), small-06 (explicit only), small-07 (both), small-08 (explicit only), small-09 (both), small-10 (both), small-11 (both), small-12 (both), small-13 (both), small-14 (both), small-15 (explicit only)
- medium (20): medium-01 (both), medium-02 (both), medium-04 (both), medium-05 (explicit only), medium-06 (explicit only), medium-07 (explicit only), medium-08 (implicit only), medium-09 (both), medium-10 (both), medium-11 (both), medium-12 (both), medium-13 (implicit only), medium-14 (implicit only)
- large (24): large-01 (both), large-02 (both), large-03 (both), large-04 (explicit only), large-05 (both), large-06 (both), large-07 (explicit only), large-08 (implicit only), large-09 (explicit only), large-10 (both), large-11 (both), large-12 (explicit only), large-13 (implicit only), large-14 (both), large-15 (both)

**Haiku 5.5, rerun: 70**

- small (28): small-01 (both), small-02 (both), small-03 (both), small-04 (both), small-05 (both), small-06 (both), small-07 (both), small-08 (both), small-09 (explicit only), small-10 (both), small-11 (both), small-12 (both), small-13 (both), small-14 (both), small-15 (explicit only)
- medium (22): medium-01 (both), medium-04 (both), medium-05 (explicit only), medium-06 (explicit only), medium-07 (explicit only), medium-08 (both), medium-09 (both), medium-10 (both), medium-11 (explicit only), medium-12 (both), medium-13 (both), medium-14 (both), medium-15 (both)
- large (20): large-01 (both), large-02 (both), large-03 (both), large-04 (explicit only), large-05 (both), large-06 (explicit only), large-07 (explicit only), large-09 (implicit only), large-10 (both), large-11 (both), large-12 (implicit only), large-13 (both), large-15 (implicit only)

## 5. Repeatability (original vs re-run, same model)

A run is 'same' if category and cost are identical in both. Note this is one repeat per run (n=2 per cell): it shows how much one re-run differed, not a stable variance estimate.

| Model | Same category and cost | Same category, different cost | Different category | Changed total |
|---|---|---|---|---|
| Opus 5.5 | 84/90 | 0 | 6 | 6 |
| Sonnet 5.5 | 73/90 | 1 | 16 | 17 |
| Haiku 5.5 | 66/90 | 2 | 22 | 24 |

**Opus 5.5: runs whose outcome changed (6)**

- large-02 explicit: original worse 430 (ref 428) -> rerun match 428 (ref 428)
- large-08 explicit: original match 366 (ref 366) -> rerun worse 370 (ref 366)
- large-09 explicit: original invalid (ref 818) -> rerun match 818 (ref 818)
- large-11 explicit: original worse 405 (ref 403) -> rerun match 403 (ref 403)
- large-12 explicit: original worse 312 (ref 302) -> rerun match 302 (ref 302)
- large-15 implicit: original worse 477 (ref 476) -> rerun match 476 (ref 476)

**Sonnet 5.5: runs whose outcome changed (17)**

- large-02 implicit: original worse 429 (ref 428) -> rerun match 428 (ref 428)
- large-04 implicit: original worse 608 (ref 577) -> rerun match 577 (ref 577)
- large-06 explicit: original match 445 (ref 445) -> rerun worse 450 (ref 445)
- large-07 explicit: original match 422 (ref 422) -> rerun worse 428 (ref 422)
- large-07 implicit: original worse 428 (ref 422) -> rerun match 422 (ref 422)
- large-08 implicit: original worse 374 (ref 366) -> rerun worse 370 (ref 366)
- large-10 explicit: original match 402 (ref 402) -> rerun worse 444 (ref 402)
- large-11 explicit: original match 403 (ref 403) -> rerun worse 405 (ref 403)
- large-11 implicit: original worse 411 (ref 403) -> rerun match 403 (ref 403)
- large-13 implicit: original match 212 (ref 212) -> rerun worse 217 (ref 212)
- large-14 explicit: original match 460 (ref 460) -> rerun worse 472 (ref 460)
- large-14 implicit: original invalid (ref 460) -> rerun match 460 (ref 460)
- medium-01 explicit: original match 250 (ref 250) -> rerun worse 266 (ref 250)
- medium-14 implicit: original worse 406 (ref 401) -> rerun match 401 (ref 401)
- medium-15 implicit: original worse 212 (ref 194) -> rerun match 194 (ref 194)
- small-01 implicit: original worse 176 (ref 154) -> rerun match 154 (ref 154)
- small-10 implicit: original worse 144 (ref 136) -> rerun match 136 (ref 136)

**Haiku 5.5: runs whose outcome changed (24)**

- large-06 implicit: original match 445 (ref 445) -> rerun worse 448 (ref 445)
- large-07 implicit: original worse 438 (ref 422) -> rerun worse 442 (ref 422)
- large-08 implicit: original match 366 (ref 366) -> rerun worse 370 (ref 366)
- large-09 explicit: original match 818 (ref 818) -> rerun worse 846 (ref 818)
- large-09 implicit: original invalid (ref 818) -> rerun match 818 (ref 818)
- large-12 explicit: original match 302 (ref 302) -> rerun worse 312 (ref 302)
- large-12 implicit: original worse 308 (ref 302) -> rerun match 302 (ref 302)
- large-13 explicit: original worse 238 (ref 212) -> rerun match 212 (ref 212)
- large-14 explicit: original match 460 (ref 460) -> rerun worse 472 (ref 460)
- large-14 implicit: original match 460 (ref 460) -> rerun worse 503 (ref 460)
- large-15 explicit: original match 476 (ref 476) -> rerun worse 477 (ref 476)
- medium-02 explicit: original match 191 (ref 191) -> rerun worse 192 (ref 191)
- medium-02 implicit: original match 191 (ref 191) -> rerun worse 192 (ref 191)
- medium-08 explicit: original worse 292 (ref 280) -> rerun match 280 (ref 280)
- medium-11 implicit: original match 496 (ref 496) -> rerun worse 512 (ref 496)
- medium-13 explicit: original worse 188 (ref 166) -> rerun match 166 (ref 166)
- medium-14 explicit: original worse 407 (ref 401) -> rerun match 401 (ref 401)
- medium-15 explicit: original worse 212 (ref 194) -> rerun match 194 (ref 194)
- medium-15 implicit: original worse 212 (ref 194) -> rerun match 194 (ref 194)
- small-04 explicit: original worse 128 (ref 102) -> rerun match 102 (ref 102)
- small-06 implicit: original invalid (ref 106) -> rerun match 106 (ref 106)
- small-08 implicit: original worse 560 (ref 520) -> rerun match 520 (ref 520)
- small-09 implicit: original match 420 (ref 420) -> rerun invalid (ref 420)
- small-15 implicit: original worse 118 (ref 74) -> rerun worse 124 (ref 74)

## 6. Mean output tokens and mean seconds per run

From `usage.output_tokens` and `usage.seconds` in each run JSON (one call per run). 15 instances per size x 2 levels = 30 runs per cell. Seconds depend on the machine, subscription load and time of day, so differences between original and re-run seconds are not a clean model-speed comparison.

| Size | Model | Output tokens (original) | Output tokens (rerun) | Seconds (original) | Seconds (rerun) |
|---|---|---|---|---|---|
| small | Opus 5.5 | 963 | 1204 | 11.6 | 13.1 |
| small | Sonnet 5.5 | 962 | 908 | 10.8 | 8.9 |
| small | Haiku 5.5 | 2991 | 3086 | 14.8 | 16.2 |
| medium | Opus 5.5 | 1761 | 2342 | 19.1 | 24.0 |
| medium | Sonnet 5.5 | 1858 | 1860 | 17.6 | 15.0 |
| medium | Haiku 5.5 | 7970 | 7836 | 37.1 | 38.0 |
| large | Opus 5.5 | 3555 | 5095 | 36.8 | 50.7 |
| large | Sonnet 5.5 | 3966 | 3889 | 32.6 | 29.6 |
| large | Haiku 5.5 | 15828 | 15750 | 70.6 | 71.1 |
| all | Opus 5.5 | 2093 | 2880 | 22.5 | 29.3 |
| all | Sonnet 5.5 | 2262 | 2219 | 20.3 | 17.9 |
| all | Haiku 5.5 | 8930 | 8891 | 40.8 | 41.8 |

## 7. Setup

- Models (read from the `model` field of the run JSONs): `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5`. Effort: `medium` in all 540 runs. Every run used 1 attempt (`attempts_used` = 1, one entry in `attempts`); no run differs from the rest of its tag in model, effort or attempt count.
- Tools off. Calls went through a Claude subscription using `claude -p` via `pipelines/cli_eval.py`, not the API.
- Tags: original = `pipelines/runs/main` (Opus), `main-sonnet`, `main-haiku`; re-run = `pipelines/runs/rerun-opus`, `rerun-sonnet`, `rerun-haiku`. 90 runs each. Prompt, reports, instances and checker are unchanged between original and re-run.
- Original runs were re-scored for this report with `run_eval.summarise`, which rewrites each tag's `results.csv` against the new reference. Comparing old and new rows, only `reference_cost`, `reference_optimal` and `gap_pct` changed (20, 22 and 20 rows per tag); `valid` and `cost` did not change. The re-run tags' `results.csv` were not re-scored.
- Merge state: `origin/main` is merged and staged but uncommitted. It brings `pddl/results/best_reference.csv` with all 45 references proven optimal. Before the merge, 11 instances (22 runs: large-01, 02, 03, 06, 08, 10, 11, 12, 13, 15 and medium-14) had best-known references that were not proven optimal. Ten of them got a lower reference cost; medium-14 kept its cost and is now proven.
- Re-run timing: rerun-opus hit a usage limit at about 23:12 on 6 Nov; 7 failed calls were filled by a re-run at 12:54 on 7 Nov. rerun-sonnet and rerun-haiku ran on 7 Nov with 0 errors. The 7 filled runs are in the rerun-opus numbers like any other.
- Dollar figures in the run logs (`~$...`) are estimates from token counts and a price table, not charges; the runs were on a subscription.
- `pipelines/reports/large-01-explicit.txt` has a known extra leading space. It was left as is; the same file was used for the original and re-run, and this report does not test whether it affected the result.

## 8. Claims to retire

With every reference proven optimal, a plan cheaper than the reference should not exist. The earlier claim that the models "beat the best-known plan" on the 10 large instances where Fast Downward timed out (e.g. `wilson/main_run_results.md` lines 55, 263, 278, 341, 444) was measured against non-optimal references. Against the proven-optimal references, the beat count is 0 in all six tags. That claim should leave the PR and the report. `wilson/main_run_results.md` was not edited.
