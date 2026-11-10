# LLM-only ("direct") pipeline: main run results

Run on Tue 3 Nov 2026 by Wilson (Person 2). Raw results: `pipelines/runs/main/results.csv`; each call's full
input, output and usage: `pipelines/runs/main/direct/<id>-<level>.json`; console log: `wilson/main.log`.

Sections 1–10 cover the main run (Opus 5.5). The same 90 calls were then repeated with **Sonnet 5.5** and
**Haiku 5.5** (runs `main-sonnet` and `main-haiku`, 4 Nov). The comparison of the three models is in **section 11**.

> **Update 7 Nov: read `wilson/main_results-run-2.md` first.** All 45 references are now proven optimal, and all 3
> models were run a second time. No run beats the reference, so every "beat best-known" statement in sections 2–11 is
> out of date. Those sections are kept as the record of what was measured against the old reference.

## 1. What was run

- **Pipeline:** `direct` from Jia Bao's `pipelines/`. The LLM reads a field report and writes the rescue plan itself
  (`drive`, `load <car> <band> <count>`, `unload`, `defer-rescue`). There is no planner and no repair loop: one call
  per report.
- **Inputs:** all 45 instances (15 small, 15 medium, 15 large), each as an **explicit** report (the facts given
  directly) and an **implicit** report (the same facts as a narrative that has to be interpreted). That makes
  45 × 2 = 90 calls.
- **Model:** Claude Opus 5.5, effort medium, through Claude Code (`claude -p`) on a Pro subscription with **all tools
  off**, via the adapter `pipelines/cli_eval.py`. The prompt is `run_eval.py`'s own. Claude Code adds a fixed
  preamble of about 700 tokens per call; nothing else differs from an API call.
- **Judge:** `pipelines/checker.py` replays every plan step by step against the rules (1–2 cars with 4 seats,
  drop-off only at evacuation points, deferral penalties 80/60/50/20 for injured/child/elderly/adult). A plan is
  **valid** only if every step is legal. Its **cost** is driving minutes plus penalties.
- **Answer key:** `pddl/results/best_reference.csv`, the cheapest plan Fast Downward found for each instance. For
  **34 of 45** instances that plan is **proven optimal**. For the other **11** it is only the **best known** plan,
  because the search ran out of time (300 s).
- **Gap:** `gap_pct = (LLM cost − reference cost) / reference cost × 100`. 0% means as good as the answer key.
  A **negative** gap means the LLM found a **cheaper** plan than the answer key, which can only happen on the 11
  best-known instances.

## 2. Headline numbers

| | |
|---|---|
| Calls | 90, no API or usage errors, 1 attempt each |
| Valid plans | **89 / 90 (98.9%)**; the 1 invalid answer also contains a valid, optimal corrected plan that wasn't scored (section 8) |
| Proven-optimal instances (34 × 2 = 68 runs) | 67 valid and **exactly optimal**, 1 invalid |
| Best-known instances (11 × 2 = 22 runs) | all valid; **cheaper than the answer key in 20**, equal in 2 (`medium-14`) |
| Claimed cost vs checked cost | identical in all 89 valid plans |
| Total tokens | ~188k input, ~188k output (including thinking) |
| Total model time | ~34 min (2,026 s) |

## 3. By size and report type

| Size | Report | Valid | Mean gap (valid plans) | Gap 0 | Output tokens per call | Seconds per call |
|---|---|---|---|---|---|---|
| small | explicit | 15/15 | 0.0% | 15 | ~860 | ~11 |
| small | implicit | 15/15 | 0.0% | 15 | ~1,070 | ~13 |
| medium | explicit | 15/15 | 0.0% | 15 | ~1,650 | ~18 |
| medium | implicit | 15/15 | 0.0% | 15 | ~1,870 | ~20 |
| large | explicit | 14/15 | −9.8% | 4 | ~3,460 | ~37 |
| large | implicit | 15/15 | −9.4% | 5 | ~3,650 | ~37 |

**How to read it:**
- **Small and medium were solved perfectly.** Every plan was legal and as cheap as the answer key.
- **Large is where things get interesting.** The mean gap is negative because on most large instances the LLM beat
  the answer key (section 4). The mean mixes 0% on the proven-optimal instances with large savings on the others.
- **Cost of thinking grows with size.** Output tokens roughly quadruple from small to large (~1k → ~3.5k) and time
  triples (~12 s → ~37 s). That's still small: Fast Downward needed up to 300 s per large instance and often timed
  out.
- **Explicit vs implicit hardly matters for this model.** Implicit reports cost ~5–25% more tokens (+25% small, +14% medium, +5% large; the model has
  to interpret the narrative first), but quality was the same or slightly better.

## 4. Large instances, one by one

| Instance | Answer key | Proven optimal? | Where the answer key came from | LLM explicit | LLM implicit |
|---|---|---|---|---|---|
| `large-01` | 268 | no | no-split | 240 (−10.4%) | 240 (−10.4%) |
| `large-02` | 461 | no | no-split | 430 (−6.7%) | 428 (−7.2%) |
| `large-03` | 542 | no | no-split | 434 (−19.9%) | 434 (−19.9%) |
| `large-04` | 577 | yes | split-optimal-lmcut | 577 (0%) | 577 (0%) |
| `large-05` | 566 | yes | split-optimal-lmcut | 566 (0%) | 566 (0%) |
| `large-06` | 446 | no | no-split | 445 (−0.2%) | 445 (−0.2%) |
| `large-07` | 422 | yes | split-optimal-ms | 422 (0%) | 422 (0%) |
| `large-08` | 430 | no | no-split | 366 (−14.9%) | 366 (−14.9%) |
| `large-09` | 818 | yes | split-optimal-ms | **invalid** | 818 (0%) |
| `large-10` | 480 | no | no-split | 402 (−16.2%) | 402 (−16.2%) |
| `large-11` | 529 | no | no-split | 405 (−23.4%) | 403 (−23.8%) |
| `large-12` | 437 | no | split-lama-anytime | 312 (−28.6%) | 302 (−30.9%) |
| `large-13` | 250 | no | no-split | 212 (−15.2%) | 212 (−15.2%) |
| `large-14` | 460 | yes | split-optimal-ms | 460 (0%) | 460 (0%) |
| `large-15` | 487 | no | no-split | 477 (−2.1%) | 477 (−2.1%) |
| `medium-14` | 401 | no | no-split | 401 (0%) | 401 (0%) |

("Where the answer key came from" is the `best_source` column of `best_reference.csv`. `no-split` means the best
plan Fast Downward found came from the older version of the domain where a group can't be divided between cars.)

## 5. What it means

### 5.1 On problems the planner could solve, the LLM matched it
Wherever Fast Downward **proved** the optimal cost (34 instances), the LLM's plan cost exactly the same, in 67 of 68
runs. Optimality is proven there, so this is a solid result: on this task, direct LLM planning is as good as optimal
search wherever optimal search finishes.

### 5.2 Where the planner timed out, the LLM did better than it

> **Out of date (7 Nov):** the true optimum is now known. The LLM beat Fast Downward's 300 s plan but never the optimum.
> See `wilson/main_results-run-2.md` section 7.

On the 10 large instances without a proven optimum, the LLM found plans **0.2% to 31% cheaper** than the best plan
Fast Downward found in 300 s. The checker accepted every one of them, and the cost the LLM claimed matched the
checker's cost each time. So these aren't miscalculations; the plans really are legal and cheaper under the
checker's rules. Why it's believable:
- In 9 of these 10, the answer key comes from the **no-split** domain. With splitting allowed (the real rules), the
  search found even worse plans (e.g. `large-01`: 452 with splitting vs 268 without). So the answer key there
  shows what the planner could find **before running out of time**, not the true optimum. The LLM, which can split
  groups freely, found something better.
- `large-12` (−31%) is the one case where the key came from the splitting search (anytime LAMA, timed out).

**For the report:** this is a scaling story. As problems grow, exact search times out and its fallback plans get
worse, while the LLM keeps producing near-optimal plans in under a minute. The fair way to state it is "cheaper than
the best plan found by Fast Downward in 300 s", not "better than optimal", because we don't know the true optimum
for those 10.

**To check before relying on it:** a cheaper-than-reference plan is also what you'd see if `checker.py` missed a
rule. The checker is Jia Bao's, and its claimed and checked costs agree, but it's worth having Jia Bao or Kimaya look
at one of the big wins (e.g. `pipelines/runs/main/direct/large-12-implicit.json`) at Wednesday's check-in to confirm
the plan is genuinely legal.

### 5.3 The one failure: the model fixed its plan, but the first draft was scored
`large-09` explicit failed at step 18 with "only 0 adult waiting at kakani-market, cannot load 1". The model's first
draft made one Kakani trip too many. It noticed this in the same answer, said so ("Wait — the plan above is wrong")
and wrote a corrected second plan. That second plan is **valid and optimal (818)**, but the pipeline graded the
first one. Details in section 8.

### 5.4 Explicit vs implicit reports
For Opus 5.5 the narrative form didn't hurt. Both forms gave the same cost on 41 of 45 instances. Implicit was
slightly **cheaper** on `large-02`, `large-11` and `large-12`, and on `large-09` it was valid where explicit wasn't.
On `large-11` the implicit plan rescued one fewer person (12 vs 13), taking a deferral penalty instead of a long
drive, and still came out 2 cost units cheaper (403 vs 405). Implicit reports cost ~5–25% more output tokens. One
known ambiguity remains (see `wilson/report_audit.md`: "a farmer with a badly cut arm" = injured, in 4 implicit
reports). Every implicit run was valid with gap 0 or better, so it didn't visibly hurt, but I haven't checked how
the model classified that farmer in each plan.

## 6. Caveats to state in the write-up

1. **One run per report.** No repeated samples, so no variance estimate. Rerunning could flip a borderline case such
   as `large-09` explicit.
2. **Not yet frozen.** If the team changes the prompt (`TASK` in `pipelines.py`) or the penalty weights at the
   Wed 4 Nov check-in, these runs must be repeated under a new tag.
3. **Claude Code, not the raw API.** Same model and effort, tools off, plus a fixed ~700-token preamble per call.
4. **Best-known references are time-limited.** Negative gaps are relative to Fast Downward with a 300 s limit.
5. **Stray edit:** `pipelines/reports/large-01-explicit.txt` has an extra leading space on line 1 (origin unknown,
   left as is). Both `large-01` runs came out identical (240), so it made no difference.
6. **Cost.** No money was spent. `run_eval.py` printed an API-equivalent estimate of about $4.50 for the 90 calls.

## 7. What "split" means

A **group** is all the people of one band waiting at one place, e.g. "6 adults at Kakani market". Cars have
**4 seats**.

- **Splitting allowed (the current rules, `pddl/domain.pddl`):** a group can be divided. Some of the 6 adults go
  in one trip and the rest later, or in the other car. The plan says how many to take: `load car2 adult 4`. The
  report says so as well: "People at the same location may be split between cars or trips."
- **No-split (Jia Bao's earlier version, kept for comparison):** a group had to travel together, all at once.

Splitting is more realistic and can only make plans cheaper or equal (more options). But it makes exact search much
harder, because the planner has to consider every way of dividing every group: optimal search proved 5/15 large
instances optimal with splitting, against 7/15 without (`pddl/README.md`).

That's why the answer key looks the way it does. For each instance, `best_reference.py` takes the cheaper of the
two searches. On 9 large instances (and `medium-14`) the splitting search timed out with a poor plan, so the "best
known" answer came from the no-split search. A no-split plan is also legal under the split rules (it just never
divides a group), so it's a fair upper bound, but not the best possible. The LLM splits groups freely and found
cheaper plans there. In `large-09`, for example, it moved Kakani's 6 adults and 3 injured as 3 injured + 1 adult,
then 4 adults, then 1 adult.

## 8. Why `large-09` explicit is invalid, step by step

**The situation:** Kakani market has **6 adults and 3 injured** (9 people). Car2 (4 seats) shuttles them to Myagang
hospital, 9 minutes each way.

**What the model wrote first** (the plan the checker graded):

| Trip | Loads at Kakani | Adults taken so far | Adults left |
|---|---|---|---|
| 1 (steps 3–8) | 3 injured + 1 adult | 1 | 5 |
| 2 (steps 9–12) | 4 adults | 5 | 1 |
| 3 (steps 13–16) | 1 adult | 6 | **0** |
| 4 (steps 17–20) | 1 adult, **step 18** | | nobody left, so it fails |

It made one trip too many. That first draft also stops after Kakani: the 8 children at Kalika school and Jwalamukhi
market and 8 adults elsewhere are never rescued or deferred.

**Why it probably happened.** The model writes a summary before the plan. Its summary says "three round trips…
Even the third trip, carrying 2 adults, costs less than deferring them". That fits a different way of dividing the
group: 2 adults, then 4 adults, then 3 injured, which is exactly how the answer key does it. But the plan it wrote
uses another division: 3 injured + 1 adult, then 4 adults, then 1 adult. After three trips all 6 adults are already
out. The model then seems to have added the remaining "1 more adult" from its summary's version, giving a fourth
trip (1 + 4 + 1 + 1 = 7 adults). In other words, it **mixed up two equally good ways to split the same group** and
lost count of how many people were left. Nothing in the route or the cost reasoning was wrong: the summary's cost
(818) is the optimum.

**What the checker does with it.** `checker.py` replays the plan one step at a time and keeps a count of who is
waiting where and who is in each car. At step 18 the count of adults waiting at Kakani is 0, so "load 1 adult" is
impossible. The checker stops at the **first** illegal step and marks the whole plan invalid. That's why the error
mentions step 18 and not the missing children: it never gets that far.

**What happened next, in the same answer:** the model wrote "Wait — the plan above is wrong: it makes four Kakani
trips, which carry 10 people when only 6 adults and 3 injured are there. Here is the corrected full plan:" and gave
a second `<plan>` block. It also stated cost 818. **I ran Jia Bao's checker on that second plan myself: it is valid
and costs 818, exactly the proven optimum.**

**Why the pipeline scored the wrong one:** `extract_plan` in `pipelines/pipelines.py` (line 118) uses `re.search`,
which takes the **first** `<plan>...</plan>` block. The LLM-to-PDDL pipeline's `extract_pddl` (line 125) takes the
**last** block instead (`blocks[-1]`). This was the only one of the 90 answers with more than one plan block, so it
affects exactly this run.

**How to count it (team decision, I haven't changed anything):**
- **As it is now (strict):** 89/90 valid. Fair to say "the answer contained a wrong plan first."
- **If `extract_plan` took the last block (lenient):** 90/90 valid, every proven-optimal instance solved optimally.
  This needs a one-line change in Jia Bao's `pipelines.py` (`re.findall(...)[-1]`) and a rerun of this one call, or
  of all of them under a new tag, so every run is graded the same way.

**But "last block" isn't automatically better.** In the Haiku run (section 11), `small-09` implicit also has two
plan blocks. There the **first** is the real answer (valid, 420). The second is a "contingency, only if the
Kispang–Nilkantha road is confirmed passable", which uses a damaged road. Grading the last block would turn that
valid answer invalid. Across all 270 answers, only these two had more than one plan block. So the choice is really
about the prompt: asking for "exactly one `<plan>` block" would remove the ambiguity for any rerun.

**Update:** both cases were rerun with that line added. See section 13.

Either way it's a good point for the report: the model **self-corrected in its own reasoning**, but a single-shot
pipeline has no way to use that unless the answer format is parsed carefully. It also shows the real LLM weakness:
keeping count of people over many steps.

## 9. What to push to the team, and what not

Nothing is committed yet. Local `main` is 7 commits ahead of GitHub: Jia Bao's `jb/domain-rep` merged in (commit
`61c6878`). There's also one stray change.

**Push** (I scanned these for personal info such as emails or local paths and found none):

| File | Why |
|---|---|
| `pipelines/cli_eval.py` | The adapter the runs used. Needed to reproduce them. Tell the team it's new in their folder. |
| `pipelines/runs/main/` (`results.csv` + 90 `direct/*.json`, ~0.5 MB) | The results. `run_eval.py` is designed to save under `runs/<tag>/`, and the JSONs hold each full answer, so anyone can check a plan or regrade. |
| `pipelines/runs/main-sonnet/`, `pipelines/runs/main-haiku/` | The Sonnet and Haiku runs, same layout. They're the evidence for the model comparison. |
| `wilson/main_run_results.md` | This explanation. |
| `wilson/report_audit.md`, `wilson/priority_research.md` (optional) | Earlier write-ups that are useful for the report (report faithfulness check, priority weights background). |

**Don't push:**

| File | Why not |
|---|---|
| `pipelines/reports/large-01-explicit.txt` (modified) | Stray leading space nobody meant to add. Don't commit it. Undo it with `git checkout -- pipelines/reports/large-01-explicit.txt` before committing, or just leave it out of the commit. |
| `HANDOFF.md`, `PLAN_2026-11-03.md` | Your own session notes. They mention your subscription setup and options you declined. |
| `wilson/main.log`, `wilson/main-sonnet.log`, `wilson/main-haiku.log` | Console output, duplicates `results.csv`. |
| `wilson/run_all.sh`, `wilson/README.md`, `wilson/compare.py`, `wilson/tests/`, `wilson/checkin_2026-11-04.md` | You decided not to use them, and they point to the old adapter path. |
| `wilson/course/` | Course guidelines document; everyone already has it. |
| `pipelines/runs/pilot-direct/` | 4-call test run, superseded by `main`. |

**One decision to make first: where to push.** Pushing local `main` also puts Jia Bao's merge onto the team's
`main`, which they haven't agreed to yet. Two options:
- **Push to a new branch** (e.g. `wilson/direct-main-run`) and let the team merge at the check-in.
  **Recommended**: it changes nothing for anyone until they agree.
- Ask Jia Bao first whether `jb/domain-rep` can go into `main`, then push `main`.

## 10. What to tell the team (Wed 4 Nov check-in)

> **Out of date (7 Nov):** this message used the old reference. Use `wilson/main_results-run-2.md` instead.

Short version you can say or paste:

> **Direct (LLM-only) pipeline: all runs done.** 45 instances × explicit/implicit = 90 calls per model, done for
> **Opus 5.5, Sonnet 5.5 and Haiku 5.5**, all at effort medium, one call each, same prompt. It went through my
> Claude subscription via a small adapter, `pipelines/cli_eval.py`, which wraps `run_eval.py` unchanged with tools
> off, so no API key and no cost. I'll push the adapter and `runs/main*` to a branch.
>
> **Main result (Opus 5.5):**
> - **89/90 valid.** On the 34 proven-optimal instances it hit the exact optimum (67/68 runs).
> - **On the 10 large instances where Fast Downward timed out, it beat our best-known plan by 0.2–31%**, checker
>   validated. 9 of those references come from the no-split search, so the reference is weak there, not
>   necessarily the LLM being "better than optimal".
> - **Speed:** ~11 s per small instance, ~37 s per large one, against up to 300 s for FD.
>
> **Model comparison (same 90 reports):**
>
> | | Opus | Sonnet | Haiku |
> |---|---|---|---|
> | Valid | 89/90 | 89/90 | 84/90 |
> | Optimal on proven-optimal (68 runs) | 67 | 59 | 52 |
> | Output tokens per call | ~2.1k | ~2.3k | ~8.9k |
> | Seconds per call | ~23 | ~20 | ~41 |
>
> - **Models differ in reliability, not in how good their plans can be.** Optimality drops with model size (67 → 59 → 52
>   optimal runs) and Haiku also has more invalid plans (6 vs 1 and 1), but all three beat the best-known plan on 20/22 of the timed-out runs. **Haiku, the smallest, actually
>   found the lowest-cost plan of all three on `large-15` (476 vs 477) and tied Opus for the lowest on `large-12`
>   (302; on the explicit report Opus and Sonnet only reached 312).**
> - **Implicit (narrative) reports are where smaller models break:** all 6 Haiku failures are on implicit reports,
>   4 of them driving a road the narrative says is flooded ("a truck was swept off it"). Opus had no implicit
>   failures. This is a nice result for the explicit vs implicit question.
> - Haiku "thinks" ~4× more tokens than Opus and is ~2× slower, so the smaller model isn't faster here (per token it
>   is still cheaper on API prices).
>
> **Four things I need from you:**
> 1. **Jia Bao:** two of the 270 answers have two `<plan>` blocks. Opus `large-09` explicit corrected itself in a
>    second block, which is valid and optimal, but `extract_plan` scores the first. Haiku `small-09` implicit added
>    a second "contingency" plan that is invalid, so "take the last block" would break that one. Keep it as is, or
>    add "exactly one `<plan>` block" to the prompt for any rerun? Your code, your call.
> 2. **Jia Bao / Kimaya:** could one of you sanity-check a big win, e.g. `runs/main/direct/large-12-implicit.json`
>    (302 vs reference 437), so we're sure `checker.py` isn't missing a rule before we headline it?
> 3. **Kimaya:** for a fair comparison, should the PDDL pipeline also use Opus 5.5 at effort medium? That matches
>    my main run.
> 4. **Everyone:** are the prompt (`TASK`) and the penalty weights frozen? If anything changes, I rerun under new
>    tags (~35 min for Opus, ~1 h for Haiku). And is it OK to merge `jb/domain-rep` into `main`?
>
> Also: `pipelines/reports/large-01-explicit.txt` had a stray leading space locally. Not from me, and I won't
> commit it.

## 11. Comparing Opus, Sonnet and Haiku (all 5.5)

### 11.1 How the comparison was kept fair
- **Same everything except the model:** the same 90 reports, the same prompt from `run_eval.py`, the same adapter
  (subscription, tools off, empty folder, one call per report, no repair) and the same **effort: medium**.
- **Why the same effort:** effort is a setting, not a fixed thinking budget; each model decides how much to think at
  that level. Keeping it fixed changes one thing at a time (the model). How much thinking each model chose to do
  shows up in its output tokens and seconds, which we report. "Best effort per model" (e.g. Haiku at high) would
  answer a different question, whether a small model can catch up by thinking longer, and wasn't run.
- **Checked afterwards:** every result row and JSON records the intended model and `effort: medium`. Every run was
  1 attempt, 1 call, `stop_reason: end_turn`, with no `ERROR`s in any log. All three runs cover the same 90
  instance/report pairs. The team's files in `pipelines/` were last modified 3 Nov 17:02 and `cli_eval.py` 18:23, both before the first run (20:05). Input tokens per call
  differ by at most 28 tokens between models (e.g. `large-01` explicit: 2,497 / 2,502 / 2,522), which is the
  Claude Code preamble; the prompts were identical.
- **One difference:** Sonnet and Haiku ran at the same time (4 Nov, ~02:33–03:35), Opus alone (3 Nov,
  20:05–20:39). That can affect seconds slightly, not the plans.

> **Key finding: models differ in reliability, not in how good their plans can be.**
> The smallest model, **Haiku, found the best plan of all three on `large-15` and tied Opus for the best on
> `large-12`**, two of the hardest instances, where Fast Downward ran out of time.
>
> ("Best" = the **lowest cost** among valid plans, where cost = driving minutes + deferral penalties as computed by
> `checker.py`. It's compared across all 6 runs of an instance: 3 models × explicit/implicit, which describe the same
> instance, so their costs are directly comparable. It's the best plan **we've seen**, not a proven optimum: for
> these instances nobody knows the true optimum.)
>
> - **`large-15`:** Haiku 476 on both reports; Opus and Sonnet 477; answer key 487.
> - **`large-12`:** Haiku 302 on the explicit report, against 312 for both Opus and Sonnet; answer key 437. Only
>   Opus's implicit run matched it (302).
>
> Haiku is also best on the `large-02` explicit report (428 vs 430 / 434). Across both reports it's a tie, since
> Opus also reached 428 on implicit. So Haiku *can* plan as well as Opus, sometimes
> better. What it can't do is plan **reliably**: it has 6 invalid plans against Opus's 1, and 52 against 67
> optimal on proven-optimal runs. Bigger models don't find better best-case plans; they make fewer mistakes. (One run per model and report, so
> treat this as indicative. It holds best for Haiku vs Opus; Sonnet's best plans were slightly worse on `large-02`,
> `large-08` and `large-13`.)

### 11.2 Overall

> **Out of date (7 Nov):** the best-known columns used the old reference. Current counts are in `wilson/main_results-run-2.md` section 2.

| Model | Valid | Optimal on proven-optimal (68 runs) | Beat best-known (22 runs) | Match best-known (22 runs) | Worse than best-known (22 runs) | Mean gap (valid plans) | Output tokens per call | Seconds per call | Total output tokens | Total time |
|---|---|---|---|---|---|---|---|---|---|---|
| Opus 5.5 | **89/90** | **67** | 20 | 2 | 0 | −3.1% | ~2,090 | ~23 | 188k | 34 min |
| Sonnet 5.5 | **89/90** | 59 | 20 | 1 | 1 | −2.4% | ~2,260 | ~20 | 204k | 31 min |
| Haiku 5.5 | 84/90 | 52 | 20 | 1 | 1 | −1.5% | ~8,930 | ~41 | 804k | 61 min |

### 11.3 By size and report type

| Model | Size | Report | Valid | Gap 0 or better | Mean gap (valid) | Worst gap | Output tokens | Seconds |
|---|---|---|---|---|---|---|---|---|
| Opus | small | explicit | 15/15 | 15 | 0.0% | 0.0% | 855 | 11 |
| Opus | small | implicit | 15/15 | 15 | 0.0% | 0.0% | 1,070 | 13 |
| Opus | medium | explicit | 15/15 | 15 | 0.0% | 0.0% | 1,648 | 18 |
| Opus | medium | implicit | 15/15 | 15 | 0.0% | 0.0% | 1,874 | 20 |
| Opus | large | explicit | 14/15 | 14 | −9.8% | 0.0% | 3,461 | 36 |
| Opus | large | implicit | 15/15 | 15 | −9.4% | 0.0% | 3,650 | 37 |
| Sonnet | small | explicit | 15/15 | 14 | +0.4% | +5.9% | 832 | 10 |
| Sonnet | small | implicit | 15/15 | 13 | +1.3% | +14.3% | 1,092 | 12 |
| Sonnet | medium | explicit | 15/15 | 15 | 0.0% | 0.0% | 1,642 | 15 |
| Sonnet | medium | implicit | 15/15 | 12 | +1.1% | +9.3% | 2,074 | 20 |
| Sonnet | large | explicit | 15/15 | 15 | −8.9% | 0.0% | 3,641 | 32 |
| Sonnet | large | implicit | 14/15 | 11 | −9.1% | +5.4% | 4,292 | 33 |
| Haiku | small | explicit | 15/15 | 14 | +1.7% | +25.5% | 2,426 | 12 |
| Haiku | small | implicit | 14/15 | 12 | +4.8% | +59.5% | 3,556 | 17 |
| Haiku | medium | explicit | 15/15 | 10 | +2.1% | +13.3% | 7,139 | 34 |
| Haiku | medium | implicit | 12/15 | 10 | +1.1% | +9.3% | 8,801 | 40 |
| Haiku | large | explicit | 15/15 | 15 | −8.6% | 0.0% | 14,657 | 65 |
| Haiku | large | implicit | 13/15 | 12 | −10.4% | +3.8% | 16,998 | 76 |

("Gap 0 or better" counts valid plans that are as cheap as the answer key or cheaper. A positive gap means the plan
is legal but more expensive than the answer key. "Mean gap" on large is negative for every model because of the
best-known instances.)

### 11.4 Explicit vs implicit, per model

| Model | Report | Valid (of 45) | Optimal on proven-optimal (of 34) | Valid but more expensive than optimal | Average excess when it is |
|---|---|---|---|---|---|
| Opus | explicit | 44 | 33 | 0 | – |
| Opus | implicit | **45** | **34** | 0 | – |
| Sonnet | explicit | 45 | 33 | 1 | +5.9% |
| Sonnet | implicit | 44 | 26 | 7 | +6.2% |
| Haiku | explicit | 45 | 29 | 5 | +11.0% |
| Haiku | implicit | 39 | 23 | 5 | +16.9% |

### 11.5 Every invalid plan

| Model | Run | Checker's first error | What went wrong |
|---|---|---|---|
| Opus | `large-09` explicit | step 18: only 0 adult waiting at kakani-market, cannot load 1 | Lost count of people; its own second plan block is valid and optimal (section 8) |
| Sonnet | `large-14` implicit | step 40: cannot defer 3 adult at tarkeshwar-market (1 waiting) | Lost count: deferred 3 people where only 1 was still waiting |
| Haiku | `large-04` implicit | step 5: road shivapuri-shelter-bidur-school is damaged | Drove a road the narrative describes as unusable |
| Haiku | `large-09` implicit | step 1: road panchakanya-shelter-suryagadhi-school is damaged | Same |
| Haiku | `medium-05` implicit | step 7: road myagang-care-home-suryagadhi-care-home is damaged | Same: the report says "Floodwater is running fast over the … road; a truck was swept off it this morning" |
| Haiku | `medium-06` implicit | step 14: road kalika-temple-nilkantha-temple is damaged | Same |
| Haiku | `medium-03` implicit | step 9: cannot defer 1 injured at kakani-temple (0 waiting) | Lost count |
| Haiku | `small-06` implicit | plan ends with people unresolved: 1 adult at gosaikunda-farm | Forgot one person (neither rescued nor deferred) |

### 11.6 Large instances, one by one (cost; ✗ = invalid; * = best known, not proven optimal)

| Instance | Report | Answer key | Opus | Sonnet | Haiku |
|---|---|---|---|---|---|
| `large-01` | explicit | 268* | 240 | 240 | 240 |
| `large-01` | implicit | 268* | 240 | 240 | 240 |
| `large-02` | explicit | 461* | 430 | 434 | 428 |
| `large-02` | implicit | 461* | 428 | 429 | 428 |
| `large-03` | explicit | 542* | 434 | 434 | 434 |
| `large-03` | implicit | 542* | 434 | 434 | 434 |
| `large-04` | explicit | 577 | 577 | 577 | 577 |
| `large-04` | implicit | 577 | 577 | 608 | ✗ |
| `large-05` | explicit | 566 | 566 | 566 | 566 |
| `large-05` | implicit | 566 | 566 | 566 | 566 |
| `large-06` | explicit | 446* | 445 | 445 | 445 |
| `large-06` | implicit | 446* | 445 | 445 | 445 |
| `large-07` | explicit | 422 | 422 | 422 | 422 |
| `large-07` | implicit | 422 | 422 | 428 | 438 |
| `large-08` | explicit | 430* | 366 | 374 | 370 |
| `large-08` | implicit | 430* | 366 | 374 | 366 |
| `large-09` | explicit | 818 | ✗ | 818 | 818 |
| `large-09` | implicit | 818 | 818 | 822 | ✗ |
| `large-10` | explicit | 480* | 402 | 402 | 402 |
| `large-10` | implicit | 480* | 402 | 402 | 402 |
| `large-11` | explicit | 529* | 405 | 403 | 403 |
| `large-11` | implicit | 529* | 403 | 411 | 403 |
| `large-12` | explicit | 437* | 312 | 312 | 302 |
| `large-12` | implicit | 437* | 302 | 312 | 308 |
| `large-13` | explicit | 250* | 212 | 217 | 238 |
| `large-13` | implicit | 250* | 212 | 212 | 212 |
| `large-14` | explicit | 460 | 460 | 460 | 460 |
| `large-14` | implicit | 460 | 460 | ✗ | 460 |
| `large-15` | explicit | 487* | 477 | 477 | 476 |
| `large-15` | implicit | 487* | 477 | 477 | 476 |

### 11.7 What the comparison means

> **Out of date (7 Nov):** points 3 and 6 did not hold up in run 2. See `wilson/main_results-run-2.md` sections 5 and 7.

1. **Bigger model, more reliable plans.** Valid plans: 89 → 89 → 84. Optimal on proven-optimal runs: 67 → 59 → 52.
   Sonnet is as reliable as Opus but more often settles for a slightly worse plan (about 6% more expensive when it
   does). Haiku both fails more and wastes more when it's suboptimal (11–17%).
2. **Implicit reports separate the models.** For Opus the narrative made no difference. For Sonnet it mostly cost
   optimality (26/34 optimal on implicit vs 33/34 explicit). For Haiku it caused **all 6 invalid plans**. Four of
   those are the same mistake, from the same sentence: "Floodwater is running fast over the … road; a truck was
   swept off it this morning. The drive usually takes N minutes." The report never says "IMPASSABLE", and it
   still gives a drive time, and Haiku treated the road as usable all four times. So reading damage out of a narrative is a real skill the task tests, and it scales with model size.
   That's a strong point for the explicit vs implicit part of the report.
3. **Where Fast Downward timed out, all three models beat it.** Every model beat the best-known plan on 20 of 22
   runs. The other 2 are all on `medium-14`: Opus matched it twice, Sonnet and Haiku matched once and were worse once
   (+1.2% and +1.5%). No model was invalid on a best-known instance. On those 22 runs, the lowest cost of the three came from Opus 17 times, Haiku 18 and Sonnet 11 (ties
   count for each). **Haiku found the best plans of all three on `large-15` (476 vs 477, both reports) and on
   `large-12` explicit (302 vs 312; tied only by Opus's implicit run).** So on the hardest instances the gap
   between models is small. **The models differ in reliability, not in how good their plans can be** (see the
   key finding at the top of this section).
4. **The smallest model isn't the cheapest here.** At the same effort, Haiku wrote about 4× as many output tokens as
   Opus (8.9k vs 2.1k per call; ~17k on large implicit) and took nearly twice as long. It reasons at length and
   still makes more mistakes. On API prices Haiku would still be cheaper per token, but the "smaller model = faster"
   assumption doesn't hold here. Sonnet is the best value: Opus-level validity, slightly faster, about the same tokens, but less often optimal.
5. **Typical LLM error types, across 8 failures:** losing count of people (4: Opus, Sonnet, 2× Haiku, including the
   forgotten adult in `small-06`) and misreading road damage from the narrative (4, all Haiku). No failure was
   caused by the seat limit or by dropping people off outside an evacuation point. (The checker stops at the first
   error, so this covers the first mistake in each plan.) On every valid plan, for all three models, the cost the
   model claimed equals the checker's cost.
6. **For the write-up:** one run per model and report, so small differences (e.g. Opus 17 vs Haiku 18 lowest costs)
   are within noise. The large differences (Haiku's 6 implicit failures, Sonnet's drop to 26/34 optimal on
   implicit) are the ones to report.

## 12. Run 2

All 3 models were run a second time against the proven-optimal reference. The results and what the totals hide
are in **`wilson/main_results-run-2.md`**.

## 13. The two two-block answers, rerun with "exactly one `<plan>` block"

Only the 2 affected cases were rerun, one call each, through `wilson/rerun_one_block.py`. It adds one line to the
direct prompt in memory (`Give exactly one <plan></plan> block in your answer. Do not write a second plan block, even
as a correction or a contingency.`) and then runs `pipelines/cli_eval.py` unchanged; nothing in `pipelines/` was
edited. Same models, effort medium, tools off, claude.ai subscription. The originals are kept. The reruns are saved
separately in `pipelines/runs/run1-patch-opus/` and `pipelines/runs/run1-patch-haiku/`.

| Case | Original run 1 (2 blocks, first scored) | Rerun (1 block) | Reference |
|---|---|---|---|
| Opus `large-09` explicit | **invalid** (step 18: only 0 adult waiting at kakani-market) | **valid, cost 818, match** | 818 |
| Haiku `small-09` implicit | valid, cost 420, match | **invalid** (step 1: road kispang-shelter-nilkantha-village is damaged) | 420 |

- **Opus:** with one plan allowed, it gave a single valid plan at the optimum. Its output is 1 block.
- **Haiku:** forced to choose, it put the contingency plan (driving the damaged Kispang–Nilkantha road, cost 114) in the
  single block and said the team should confirm the road. The checker rejects it at step 1. In the original answer,
  the first block was the safe plan (defer all 7 children, cost 420) and the contingency was a second block. This is
  the same misreading as Haiku's other floodwater failures (`wilson/main_results-run-2.md` section 5.4). Rerunning
  did not make the answer better, and one block did not fix it.
- **Effect on the run 1 totals if the reruns replaced the originals:** Opus 84 → 85 matches and 1 → 0 invalid; Haiku
  70 → 69 matches and 6 → 7 invalid. The tables above are not changed, so the headline numbers still describe the
  original run 1 answers. Run 2 is the report's comparator and had no two-block answers, so no report number changes.
- **Not a like-for-like comparison:** the prompt differs by one line, and each case is a single new sample, so this
  shows what one more draw did and not a stable effect. The reruns also confirm that the first block was the better
  one for Haiku and not for Opus, so "the first block is the better plan" isn't a rule.
- **Tokens recorded:** Opus 54,653 input / 2,576 output (29.7 s); Haiku 1,879 input / 3,132 output (15.2 s). Opus's
  input is far above its usual ~2,400. The adapter counts cache tokens as input, which may explain it, but that
  isn't confirmed.
