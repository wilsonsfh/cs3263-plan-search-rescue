# LLM-only ("direct") pipeline: main run results

Run on Tue 3 Nov 2026 by Wilson (Person 2). Raw results: `pipelines/runs/main/results.csv`; each call's full
input, output and usage: `pipelines/runs/main/direct/<id>-<level>.json`; console log: `wilson/main.log`.

Sections 1–10 cover the main run (Opus 5.5). The same 90 calls were then repeated with **Sonnet 5.5** and
**Haiku 5.5** (runs `main-sonnet` and `main-haiku`, 4 Nov). The comparison of the three models is in **section 11**.

> **Update 7 Nov: read section 12 first.** All 45 references are now proven optimal and all 3 models were run again.
> No run beats the reference, so every "beat best-known" statement in sections 2–11 is out of date. Those sections
> are kept as the record of what was measured against the old reference. Section 12 has the current results and what
> the totals hide.

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
> See section 12.4.

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

> **Out of date (7 Nov):** this message used the old reference. Use section 12 instead.

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

> **Out of date (7 Nov):** the best-known columns used the old reference. Current counts are in section 12.1.

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

> **Out of date (7 Nov):** points 3 and 6 did not hold up in the re-run. See sections 12.3 and 12.4.

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

## 12. Re-run against the proven-optimal reference (7 Nov)

**What changed.** Jia Bao's exact solver (`pddl/exact.py`, PR #4) proved the optimal cost of all 45 instances, so the
reference is now the true optimum. 10 large references dropped; `medium-14` kept its cost and is now proven. All 3
models were then run again in full: same prompt, reports, instances and checker, effort medium, tools off, one
attempt per report, through the subscription. The new runs are `pipelines/runs/rerun-opus`, `rerun-sonnet` and
`rerun-haiku`. The original runs were only re-scored: their plans are unchanged, and only `reference_cost`,
`reference_optimal` and `gap_pct` changed in their `results.csv`.

The complete per-run lists, including every match, are in `wilson/rerun_results.md`, with one row per run in
`wilson/rerun_classification.csv`.

### 12.1 Results

| Model | Set | Beat | Match | Worse | Invalid |
|---|---|---|---|---|---|
| Opus 5.5 | Original | 0 | 84 | 5 | 1 |
| Opus 5.5 | Re-run | 0 | **88** | 2 | 0 |
| Sonnet 5.5 | Original | 0 | 70 | 19 | 1 |
| Sonnet 5.5 | Re-run | 0 | **72** | 18 | 0 |
| Haiku 5.5 | Original | 0 | 70 | 14 | 6 |
| Haiku 5.5 | Re-run | 0 | **70** | 15 | 5 |

No plan beat the reference in 540 runs, which is what should happen against a proven optimum. Every report was
matched by at least one of its 6 runs.

### 12.2 Every run that did not match

The number in brackets is the cost above the reference. Any run not listed is a match.

**Re-run**

| Model | Worse, explicit | Worse, implicit | Invalid |
|---|---|---|---|
| Opus | large-08 (+4), large-15 (+1) | None | None |
| Sonnet | small-10 (+8), medium-01 (+16), large-02 (+6), large-06 (+5), large-07 (+6), large-08 (+8), large-10 (+42), large-11 (+2), large-12 (+10), large-13 (+5), large-14 (+12), large-15 (+1) | medium-01 (+16), large-08 (+4), large-09 (+4), large-12 (+10), large-13 (+5), large-15 (+1) | None |
| Haiku | medium-02 (+1), medium-03 (+14), large-08 (+4), large-09 (+28), large-12 (+10), large-14 (+12), large-15 (+1) | small-15 (+50), medium-02 (+1), medium-07 (+17), medium-11 (+16), large-06 (+3), large-07 (+20), large-08 (+4), large-14 (+43) | Implicit: small-09, medium-03, medium-05, medium-06, large-04 |

**Original**

| Model | Worse, explicit | Worse, implicit | Invalid |
|---|---|---|---|
| Opus | large-02 (+2), large-11 (+2), large-12 (+10), large-15 (+1) | large-15 (+1) | Explicit: large-09 |
| Sonnet | small-10 (+8), large-02 (+6), large-08 (+8), large-12 (+10), large-13 (+5), large-15 (+1) | small-01 (+22), small-10 (+8), medium-01 (+16), medium-14 (+5), medium-15 (+18), large-02 (+1), large-04 (+31), large-07 (+6), large-08 (+8), large-09 (+4), large-11 (+8), large-12 (+10), large-15 (+1) | Implicit: large-14 |
| Haiku | small-04 (+26), medium-03 (+14), medium-08 (+12), medium-13 (+22), medium-14 (+6), medium-15 (+18), large-08 (+4), large-13 (+26) | small-08 (+40), small-15 (+44), medium-07 (+17), medium-15 (+18), large-07 (+16), large-12 (+6) | Implicit: small-06, medium-03, medium-05, medium-06, large-04, large-09 |

### 12.3 What the totals hide

**1. Similar totals, but many individual runs changed.** Haiku scored 70 matches both times, yet 24 of its 90 runs
changed outcome or cost. For example, on `large-12` its explicit run went from 302 to 312 while its implicit run went
from 308 to 302. A single run of a report is therefore a weak measurement for Sonnet and Haiku.

| Model | Same category and cost | Worse → match | Match → worse | Invalid → match | Match → invalid | Worse → worse, new cost |
|---|---|---|---|---|---|---|
| Opus | 84/90 | 4 | 1 | 1 | 0 | 0 |
| Sonnet | 73/90 | 8 | 7 | 1 | 0 | 1 |
| Haiku | 66/90 | 9 | 10 | 2 | 1 | 2 |

Each changed run is listed in `wilson/rerun_results.md`, section 5.

**2. Sonnet and Haiku tie overall, but not at any size.** Across both sets, Sonnet has 142/180 matches and Haiku
140/180, while Opus has 172/180. Splitting by size shows the near-tie comes from two opposite results, and both sets
agree on the direction:

| Size | Opus (original, re-run) | Sonnet (original, re-run) | Haiku (original, re-run) |
|---|---|---|---|
| Small (of 30) | 30, 30 | 27, 29 | 26, 28 |
| Medium (of 30) | 30, 30 | 27, 28 | 20, 22 |
| Large (of 30) | 24, 28 | **16, 15** | **24, 20** |

Haiku is the weaker of the two on small and medium but the stronger on large, where it also writes about 4× as many
output tokens. That the extra tokens cause the better large results is a hypothesis; this data doesn't test it. Opus
is the best at every size, or tied for best.

**3. Sonnet's explicit vs implicit result reversed between sets.** Its matches (explicit/implicit) were 39/31 in the
original and 33/39 in the re-run. Most of the swing is on large: explicit went from 10 to 5, and implicit from 6 to 10.
The original looked like implicit reports hurt Sonnet, and section 11.7 calls that a difference worth reporting; the
re-run doesn't support it. Don't claim an explicit vs implicit effect for Sonnet. Opus (40/44, 43/45) and Haiku (37/33,
38/32) didn't reverse, but those differences are small too.

**4. Haiku's invalid plans are mostly one specific reading mistake.** All 11 Haiku invalids are on implicit reports,
and Haiku has none on the 90 explicit runs. 8 of the 11 drove onto a road described with one wording:

> Floodwater is running fast over the ... road; a truck was swept off it this morning.

| Damage wording in the implicit report | Reports | Opus runs driving it | Sonnet runs driving it | Haiku runs driving it |
|---|---|---|---|---|
| "Floodwater is running fast ... a truck was swept off it" | 24 | 0/48 | 0/48 | **8/48** |
| "A landslide has buried the road" | 20 | 0/40 | 0/40 | 0/40 |
| "Police have closed the ... road" | 20 | 0/40 | 0/40 | 0/40 |
| "The bridge ... was washed away" | 19 | 0/38 | 0/38 | 0/38 |

The floodwater sentence is the only one of the four that describes a hazard without saying the road is gone or
closed. The affected runs are `large-04`, `medium-05` and `medium-06` in both sets, `large-09` in the original and
`small-09` in the re-run. So this failure repeats on some reports, but not always on the same ones.

The other 3 Haiku invalids:
- `medium-03` implicit, both sets, identical error and identical first 11 plan steps. The report says "an old man who
  cannot walk unaided"; the explicit report says "1 elderly person". Haiku tried to defer him as injured, and the
  checker correctly rejected it because no injured person is waiting there. This wording appears in 4 reports, and
  only `medium-03` failed this way.
- `small-06` implicit, original only: Haiku forgot 1 adult. This did not recur.

**5. "Worse" covers different mistakes, and some "worse" plans save more people.** I compared all 73 worse plans with
the exact solver's optimal plan for the same instance (`pddl/instances/<id>.exact-plan`):

| Model | Same people deferred, longer drive | Lower deferral penalty than optimal (over-rescue) | Higher deferral penalty than optimal |
|---|---|---|---|
| Opus (7 worse) | 5 | 1 | 1 |
| Sonnet (37 worse) | 23 | 4 | 10 |
| Haiku (29 worse) | 7 | **18** | 4 |
| All (73) | 35 | 23 | 15 |
| Mean cost above optimal | +7.9 | **+18.8** | +9.5 |

Sonnet's usual mistake is a slightly longer route. Haiku's is driving further to avoid a deferral that the cost
function says is worth accepting, and this is the costliest kind. In 21 of the 23 over-rescue runs the plan saves at
least 1 more person than the optimum; the other 2 save the same number from different groups.

The clearest example is `small-15` implicit in Haiku's re-run. It drives 124 minutes and rescues everyone, for a cost
of 124. The optimum drives 14 minutes and defers 3 adults at a penalty of 20 each, for a cost of 74. So that plan is
scored 67.6% worse while saving 3 more people.

**For the report:** "worse" means worse under the current penalties (80/60/50/20), not necessarily worse for the people
in the flood. This bears directly on the discussion about the deferral penalty, because a higher adult penalty would
change which of these plans counts as optimal. These runs have not been re-scored under other penalties.

**6. Some near-misses repeat.** 14 worse runs have exactly the same cost in both sets: 1 Opus (`large-15` explicit),
10 Sonnet (`small-10` explicit, `medium-01` implicit, `large-02` explicit, `large-08` explicit, `large-09` implicit,
`large-12` both, `large-13` explicit, `large-15` both) and 3 Haiku (`medium-03` explicit, `medium-07` implicit,
`large-08` explicit). 13 of the 14 also have the same driving time and the same people deferred, so the model reached
the same suboptimal solution twice. 3 of those are word-for-word the same plan, and 5 more contain the same actions in
a different order. The exception is Sonnet's `large-08` explicit: both cost 374, but one is 204 minutes plus 170 in
penalties and the other is 264 plus 110, so the equal cost is a coincidence.

**7. The difficulty is concentrated.** 44 of the 90 reports were matched by all 6 runs. Of the 86 non-matching runs, 53
are on large, 23 on medium and 10 on small. The hardest reports are `large-15` explicit and `large-08` explicit (5 of
6 runs missed), then `large-12` explicit (4 of 6).

**8. A second attempt helps the smaller models more.** This table counts reports, out of 90, across each model's two
sets.

| Model | Matched in both sets | Matched in at least one | Never matched |
|---|---|---|---|
| Opus | 83 | 89 | `large-15` explicit |
| Sonnet | 63 | 79 | `small-10` explicit, `medium-01` implicit, `large-02` explicit, `large-08` both, `large-09` implicit, `large-12` both, `large-13` explicit, `large-15` both |
| Haiku | 59 | 81 | `small-15` implicit, `medium-03` both, `medium-05` implicit, `medium-06` implicit, `medium-07` implicit, `large-04` implicit, `large-07` implicit, `large-08` explicit |

This is not what the pipeline does, since it makes one attempt per report. It only shows how much of the shortfall is
run-to-run variation.

**9. Opus's token rise is unexplained.** Mean output tokens per run:

| Model | Original | Re-run | Re-run runs using more tokens than the original |
|---|---|---|---|
| Opus | 2,093 | **2,880** (+38%) | **82/90** |
| Sonnet | 2,262 | 2,219 | 40/90 |
| Haiku | 8,930 | 8,891 | 50/90 |

82 of 90 is not chance variation. Input tokens per run are unchanged (2,085), so the prompt is the same size. Opus also
improved from 84 to 88 matches over the same runs, but nothing here shows that one caused the other. The run files
don't record the Claude Code version, so a change there can't be ruled out, and I don't know the cause.

**10. The two-`<plan>`-blocks problem did not recur.** Section 8 describes answers with two `<plan>` blocks, of
which `extract_plan` scores the first. That happened in 2 of the 270 original runs (Opus `large-09` explicit, Haiku
`small-09` implicit) and 0 of the 270 re-runs.

### 12.4 Claims this replaces

- **"Beat best-known" is retired.** It was true only against the old reference. What remains true is narrower: on those
  10 large instances the models found cheaper plans than Fast Downward's best in 300 s. Those plans are now known to
  be at or above the optimum, and never below it.
- **"Haiku found the best plans of all three on `large-15`" needs care.** Across both sets, 476 was reached 3 of 4 times
  by Haiku, 1 of 4 by Opus and 0 of 4 by Sonnet. That leans towards Haiku, but Opus also reached it in the re-run.
- **"The models differ in reliability, not in how good their plans can be"** is too strong. Opus matches on 172/180
  against 142 and 140, so match rates differ as well as validity.
- **The large mean-gap figures in sections 3, 4 and 11** were measured against the old reference. Use
  `pipelines/runs/*/results.csv` for current values.

### 12.5 Limits

This is two sets per model, so it shows how much one repeat differed, not a stable variance estimate. Both sets use the
same reports, so they aren't independent samples. I ran no significance tests. The re-run of
Opus spanned a usage limit: 7 failed calls from 6 Nov were filled in on 7 Nov and are included like any other run.
