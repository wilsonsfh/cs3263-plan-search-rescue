# LLM-only pipeline: formalisation, design and justification

*Wilson's part (Person 2). This is source material for the report. The sections map onto the grading rubric:
problem definition, formulation, methodology, analysis, assumptions, responsible AI.*

---

## 1. Problem formalisation

The sub-problem is **deterministic classical planning with action costs** (Lecture 5, STRIPS/PDDL), on a
graph abstraction of a flood-hit district.

**Instance.** A tuple $\langle G, n, s_0, S, C, \tau \rangle$:
- $G=(V,E,w,o)$ is the road network. $w(e)\in\mathbb{N}$ is the post-flood travel time in minutes and $o(e)\in\{\top,\bot\}$ says whether the road is passable.
- $n(l,g)$ is the number of stranded people at place $l$ in vulnerability group $g\in\{\text{injured, children, elderly, adults}\}$. Each person is in exactly one group, with precedence injured > child > elderly > adult.
- $s_0$ is the team base, $S$ the shelter, and $C\in\mathbb{N}\cup\{\infty\}$ the vehicle capacity.
- $\tau(l)=1$ if $n(l,\text{injured})>0$; $\tau(l)=2$ if children or elderly are present; otherwise $\tau(l)=3$.

**State.** $(\text{pos},\ P\subseteq V,\ \text{load})$: where the team is, which places have been picked up, and how many people are on board. In STRIPS terms the fluents are `At(team,l)`, `Picked(l)` and `Load(k)`.

**Actions (schemas).**

| action | precondition | effect | cost |
|---|---|---|---|
| `Move(a,b)` | `At(a)`, `Road(a,b)`, `Open(a,b)` | `¬At(a)`, `At(b)` | $w(a,b)$ |
| `Pickup(l)` | `At(l)`, `¬Picked(l)`, load $+\,n(l)\le C$, $\forall l'$ reachable: $\tau(l')<\tau(l)\Rightarrow$ `Picked(l')` | `Picked(l)`, load $\mathrel{+}= n(l)$ | 0 |
| `Dropoff` | `At(S)` | load $:=0$; on-board people become *delivered* | 0 |

**Goal.** Every person at a place reachable from $s_0$ through open roads is delivered to $S$. Unreachable places are reported, not visited.

**Objective.** Minimise total travel time subject to the goal and the tier constraint. This is a lexicographic
(constraint-first) treatment of vulnerability.

**Why this formulation.**
- It is the course's planning formulation exactly, so the PDDL pipeline can express it. The tier constraint is a universally quantified ADL precondition; costs use `:action-costs`.
- The "everyone at a place in one pickup" rule follows the TA's feedback. It makes pickups unsplittable, so with finite $C$ the problem becomes a capacitated routing problem with unsplittable demands.
- The tier rule makes the TA's value question explicit and checkable. It also lets us *measure* its cost (§6).
- It is a classical-planning special case of known NP-hard problems: the uncapacitated case is a precedence-constrained TSP-path, and the capacitated case is a CVRP variant. Even small instances therefore cannot be "eyeballed", but they can be solved exactly for evaluation.

**Exact reference solver (oracle).** Uniform-cost search over macro-states
$(\text{pos}\in K, P\subseteq\text{rescuable}, \text{load})$ on the metric closure (all-pairs Dijkstra over open
roads), where $K$ is the set of rescuable places plus base and shelter. This is exact for the model: driving
*through* a place without stopping is covered by the shortest paths. The state bound is $|K|\cdot 2^k\cdot(C+1)$.

---

## 2. Problem instances

**Generator** (`rescue/generator.py`, seeded, deterministic):
- $k$ occupied places, plus 1–4 junctions or already-evacuated villages.
- Roads come from a minimum spanning tree plus nearest-neighbour shortcuts (a sparse, hill-road-like network). Times are distance × terrain factor, rounded to 5 minutes.
- **Damage placed where it matters.** Blocked roads are drawn first from the *pre-flood shortest-path tree*, so a plan that misses a blockage really does try to use that road. Blockages never disconnect a stranded place, except in "cut" instances, where one place is deliberately isolated.
- Some roads are slowed (waterlogged); the report gives the time as "twice the usual" or "+15 minutes".
- Capacity is either unlimited or "tight" (forces several shelter trips).
- **Suite:** $k\in\{4,8,12,16\}$ × {unlimited, tight capacity} × {all reachable, one place cut off} × 3 replicates = 48 instances (16–23 places, 8–34 roads, 2–8 blocked). Replicate 0 is the dev split (16), replicates 1–2 are the test split (32). Every condition appears at every size in both splits.
- **Why these sizes.** A pilot on $k\le 9$ with unlimited capacity was 28/28 valid and optimal for the main LLM-only variant, so small instances do not separate the methods (proposal Risk #1). Sizes were extended until failures appear (see §10).

**Natural-language rendering** (`rescue/reports.py`). Every level contains a *mission sheet* (base, shelter,
capacity, list of places), the *pre-flood road register* (usual travel times), and *field reports*. Only the field reports vary:

| level | what makes it hard | proposal link |
|---|---|---|
| L1 explicit | nothing: `Bidur–Ramche: BLOCKED`, `Ramche: 2 injured, 3 children, ...` | baseline, near-trivial translation |
| L2 implicit | causes instead of statuses ("the suspension bridge was swept away"), relative times ("twice the usual time"), number words ("a dozen", "an elderly couple"), people described by condition (an injured child is *injured*), a muddy-but-passable **trap road**, already-evacuated villages | Risk #2 |
| L3 noisy | three time-stamped dispatches printed out of order; superseded facts (debris cleared, fresh landslide on a road that was open earlier), rumours later refuted, estimated headcounts later confirmed, distractor sentences | misinformation and conflict resolution |

The same instance is rendered at all three levels, so level comparisons are **paired** (same underlying difficulty).

**Fidelity is tested, not assumed** (`tests/test_reports.py`):
- L1 is parsed back and must equal the instance exactly.
- Every people-description template is parsed back to exact group counts (500 random cases).
- Every changed road and every stranded place is mentioned at L2/L3.
- At L3, every contested fact is settled in the most recent dispatch.

---

## 3. The LLM-only pipeline

```
instance ──render──▶ NL input ──prompt──▶ frontier model (no tools) ──▶ text
                                                                    │ parse JSON (1 format retry)
                                                                    ▼
                                ground truth ──▶ independent validator ──▶ typed errors, cost
                                                       ▲                    │
                                     (nl-repair only) feedback ◀────────────┘  ≤ 2 rounds
```

- **Model access.** The `claude` CLI in print mode with **all tools disabled** (`--tools ""`), no settings, CLAUDE.md or hooks loaded, a fixed system prompt, and an empty working directory. We checked that the model sees only about 680 tokens of harness context. *LLM-only* therefore really means no code execution: the model cannot write a Dijkstra script for itself.
- **Prompt** = shared operator brief (task rules, identical text in both pipelines) + problem + style instruction + output format. The prompts live in `prompts/`, not in code.
- **Parsing.** The last fenced JSON block, or the first JSON object containing `steps`. One "format retry" if parsing fails; format retries are counted as a metric. Names are matched case- and punctuation-insensitively, and "Chautara Health Post" resolves to "Chautara" only when the match is unambiguous.
- **Variants.** Each one isolates one factor:

| variant | input | style / effort | isolates |
|---|---|---|---|
| `nl-direct` | NL | answer only, low effort | System-1 answering without deliberation |
| `nl-reason` | NL | reason first, high effort | **main LLM-only condition** |
| `gold-reason` | perfect extracted JSON | reason first, high effort | planning ability alone; `nl-reason − gold-reason` = cost of *reading* the reports |
| `nl-repair` | NL | as nl-reason + ≤2 rounds of validator feedback | "LLM proposes, checker verifies" (Lecture 5 harness, option 2); counterpart of the PDDL self-repair loop |

- **Validator-independence.** The judge never trusts the plan's own claims. Claimed total time and claimed unreachability are both checked against ground truth. A gap between claimed and actual time is reported separately (*self-report honesty*).

---

## 4. Metrics and why

| metric | definition | why |
|---|---|---|
| **valid** | executable ∧ complete ∧ tier-compliant ∧ no false "unreachable" | the headline: would the plan work and follow policy? |
| executable | no physical error (blocked or non-existent road, teleport, capacity, wrong drop-off) | separates "breaks in the field" from "suboptimal" |
| complete | every rescuable person delivered | |
| priority_ok | tier rule never violated | the TA's value-sensitivity question |
| coverage | delivered / rescuable, counted **up to the first physical error** | partial credit that matches reality: after a blocked road the team is stuck |
| vulnerable coverage | the same, for injured + children + elderly only | who bears the failure |
| optimality gap | cost / optimal − 1, over valid plans | quality beyond validity |
| claimed-time error | claimed − actual minutes | detects arithmetic hallucination; matters for ETAs given to families and coordinators |
| error types | first-class codes (INTERFACE.md §5) | failure analysis |
| consistency | across 3 samples, paraphrases, renames: same validity, compliance, pickup order | reliability; whether priority is applied *consistently* |
| cost | output and thinking tokens, latency | the practical trade-off against the planner |

---

## 5. Protocol

- **Dev/test split** (TA feedback). Replicate 0 (16 instances, all conditions × all sizes) is used for prompt development and the pilot/stress runs. Replicates 1–2 (32 instances) are held out, and prompts are frozen before they are run.
- 3 samples per (instance, level, variant). The CLI exposes no temperature control, so the samples measure the model's actual run-to-run variation.
- **Paired design.** All variants and levels run on the same instances. Round 0 of `nl-repair` is the cached `nl-reason` answer.
- **Cache and resume.** Each response is stored under a hash of (model, effort, prompt, sample). Failed calls are logged as call errors and **never** replaced with cached or fixture data.

---

## 6. Complexity analysis (from `results/oracle/oracle_stats.md`)

- The state bound grows as $|K|\,2^k\,(C+1)$, from 80 at $k=3$ to $3.8\times10^6$ at $k=13$ with $C=30$. Exact UCS still finishes in **< 0.5 s** because the tier constraint prunes most orderings.
- **The tier rule shrinks the search 10–100×** (e.g. $k=13$, $C=30$: 57k vs 737k expansions). Domain policy works as a search heuristic: the value constraint makes the tool *faster*.
- **Price of priority.** The optimal cost with tiers vs without ranges from 0% to 58% (median ≈ 3.6%; 0% in 17 of 36 instances). In about half the instances, putting the vulnerable first costs nothing. When it does cost something, the planner makes the trade-off explicit, while a free-form LLM plan makes it silently.

*(LLM-side scaling results: §8, after the main run.)*

---

## 7. Assumptions and threats to validity

| assumption | realistic? | failure case / mitigation |
|---|---|---|
| deterministic, known travel times | no; real times are uncertain | the natural extension is an MDP (Lecture 9) with stochastic road status; out of scope, discussed as future work |
| one vehicle, unsplittable pickup | simplification | several teams would be multi-agent planning; splitting is allowed in reality but the TA asked for whole-place pickup |
| final reports are correct | idealised; real reports conflict and are wrong | L3 tests resolving *stated* conflicts only; unresolvable misinformation needs human verification |
| template language | less diverse than real journalism | paraphrase probe; manual audit of a sample (**TODO Wilson: read 10 L2/L3 reports**); real reports would be harder still, so results are an **upper bound** on LLM comprehension |
| real Nepali place names, synthetic geography | names could trigger model priors | rename probe (names permuted among places) |
| the tier policy itself | one defensible policy, not the only one | the policy is an *input* (operator brief), so it can be changed and audited; see §9 |
| hidden harness context | ~680 tokens of CLI context | measured; identical across variants |

---

## 8. Results

*(filled from `results/<run>/summary.md`; see §10 for the pilot)*

---

## 9. Responsible AI (domain-specific)

- **Value-sensitive decisions (TA question).** Who goes first is a moral choice. We do **not** let the model choose it. The tier policy is written in the operator brief, applied identically in both pipelines, and *checked* by the validator, not asked of the model. This separates the *value specification* (a human and policy responsibility) from *execution* (the AI's job). The LLM-only approach can still silently break the policy, which is why `priority_ok` is a first-class metric. The price-of-priority table shows what the policy costs in minutes, so decision-makers can see the trade-off rather than having it hidden inside the model.
- **Fairness and consistency.** Vulnerable coverage, plus the rename and paraphrase probes. A plan should not change because a village has a different name or the report was worded differently (cf. statistical parity and the "appropriate criterion depends on context" point from the RAI notes).
- **Unintended side effects.** The 2017 wildfire navigation example from the RAI videos: route optimisation sent people *into* the fire. Our analogue is the BLOCKED_ROAD error: a plan that is "efficient" but drives into a washed-out road. That is why executability comes before optimality.
- **Transparency and accountability.** The validator gives a human-readable reason for each failure (counterfactual-style: "road X–Y is impassable"). The PDDL route adds an inspectable intermediate artefact. The LLM-only route has only its free-text reasoning, which may not reflect what it actually did; the claimed-vs-actual time error measures this directly.
- **Automation bias / human in the loop.** A coordinator under time pressure will trust a fluent plan. The deployment we recommend is that the AI proposes and an independent checker plus a human approve, never autonomous dispatch.
- **Misinformation and adversarial input.** The L3 rumours show the model must weigh source reliability. In a real deployment, reports could be adversarial (false claims that pull resources away), so the system should flag decisions that rest on a single unconfirmed source.
- **Privacy.** Real field reports contain names, injuries and locations of vulnerable people (sensitive personal data). Only counts per group are needed for planning, so this is data minimisation. Sending reports to a third-party LLM API also raises data-residency questions, and the open-weight backend (Ollama, SoC-hosted models) is the mitigation.

---

## 10. Pilot and stress tests (dev split only, 2026-10-26)

| run | instances | result |
|---|---|---|
| pilot (old suite, k ≤ 9, unlimited capacity) | 4 instances × L1–L3 + gold, Sonnet 5.5 high effort | **28/28 valid, all optimal**, 0 claimed-time error; 1.9k–8.5k output tokens, 13–59 s |
| stress, Sonnet `nl-reason` L3 | k12 cap+cut, k16 cap, k16 cap+cut | 3/3 valid **and optimal**; 16k–33k thinking tokens, 132–254 s |
| stress, Sonnet `nl-direct` (low effort) | k8 cap+cut L1/L3, k16 cap L1/L3 | 4/4 valid; k16 L3 was **1.7% above optimal** (the only non-optimal plan so far) |
| stress, **Haiku 5.5** `nl-reason` L3 | k8, k12, k16 (cap+cut) | 3/3 valid and optimal, but **110k thinking tokens and 477 s** at k16 |
| oracle (exact UCS) | k = 20…28 | ≤ 4 s up to k = 24 with unlimited capacity; 257 s at k = 24 with tight capacity; > 10 min at k = 28 with tight capacity |

**What this means (provisional, dev split):**
1. On instances of this size, current reasoning models do **not** fail on correctness, even with noisy multi-source
   reports, capacity and a cut-off village. Proposal Risk #1 ("instances too simple") holds for *accuracy*.
   What separates the approaches is **cost and latency**: the model's thinking grows steeply with k
   (Sonnet ≈ 1k → 33k thinking tokens from k = 3 to 16; Haiku 110k at k = 16), while the planner/oracle needs
   milliseconds. In effect the model runs a search inside its chain of thought.
2. Reading the reports was not the bottleneck: gold facts ≈ NL at every level tried. The interesting
   comparison with the PDDL pipeline is therefore not "LLM misreads" but "who pays for the search, and what is
   guaranteed": the planner is provably optimal (with an optimal search configuration); the LLM's optimality is only known because we have an oracle.
3. The oracle's own exponential wall (k ≈ 24–28 with capacity) shows where *exact* tool-based planning stops
   being cheap. That is the regime to probe both pipelines in: satisficing planners (LAMA) vs the LLM.
4. Lowering reasoning effort is the first knob that produced a sub-optimal plan, so effort and model size are the
   axes on which LLM-only degrades.
