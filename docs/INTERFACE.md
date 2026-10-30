# Shared interface: instances, reports, plans, scoring

Owner: Wilson (LLM-only pipeline). Written so that the PDDL domain/prompts (Jia Bao) and the
LLM→PDDL→planner pipeline (Kimaya) are scored **by the same judge, on the same inputs**.
Anything marked **ALIGN** has to be agreed by all three of us before the final runs.

## 1. Ground truth: `data/instances/<id>.json`

One file per problem instance (`python -m rescue.cli generate`). Everything else is derived from it.

```json
{
  "id": "k8-s5-cap",
  "locations": [{"id": "syaphru", "name": "Syaphru", "kind": "base"}, ...],
  "roads": [{"u": "bhalche", "v": "syaphru", "minutes": 30, "open": true,
             "base_minutes": 15, "cause": "waterlogged", "history": []}, ...],
  "people": {"haku": {"injured": 1, "elderly": 3, "adults": 3}, ...},
  "start": "syaphru", "shelter": "syaphru",
  "capacity": 13,                 // null = unlimited
  "priority": "tiered",
  "meta": {"k": 8, "seed": 5, "split": "test", "condition": "tight", "cut_off": null, ...}
}
```
- `minutes` is the **post-flood** time charged to plans. `base_minutes` is the pre-flood time (only set
  if the flood changed it). `cause`/`history` only control how reports are worded.
- Location `id`s are lowercase and PDDL-safe, so they can be used directly as PDDL object names.

## 2. Inputs every pipeline gets: `data/reports/<id>/`

| file | content |
|---|---|
| `L1.txt`, `L2.txt`, `L3.txt` | mission sheet + pre-flood road register + field reports at 3 language levels (explicit / implicit / noisy multi-source) |
| `gold.json` | the post-flood problem already extracted (used by the gold-facts ablation) |
| `oracle_plan.json` | an optimal plan in the canonical format (§4) |

**ALIGN:** both pipelines must use the same task rules. These are in `prompts/operator_brief.md`
(movement, unsplittable pickup, capacity, drop-off, vulnerability tiers, goal and unreachable places,
objective, conflict resolution). The LLM-only prompt includes this text word for word. The PDDL-translation
prompt should include it word for word as well, so that a difference in results comes from the method and not
from the wording of the task.

## 3. Formal semantics the PDDL domain has to reproduce (ALIGN)

| concept | semantics (enforced by `rescue/validator.py`) | PDDL note |
|---|---|---|
| move | between two places directly connected by an **open** road; cost = current minutes | `:action-costs`, `(increase (total-cost) (road-time ?a ?b))`; blocked roads are left out of `(road ?a ?b)` |
| pickup | takes **everyone** at the place; never split | one `rescued`/`picked` flag per place |
| capacity | on-board people ≤ C | Fast Downward has **no numeric fluents**. Options: load levels as objects with a precomputed `(can-add ?from ?n ?to)` table, a numeric planner (ENHSP / Metric-FF), or run the comparison on `capacity: null` instances only. **Decide this early.** |
| dropoff | at the shelter only; on-board people become delivered | |
| tiers | tier(l) = 1 if any injured, 2 if any child or elderly, else 3; no pickup at tier k while a *reachable* place of tier < k is waiting | ADL precondition `(forall (?l - place) (imply (and (tier1 ?l) (reachable ?l)) (picked ?l)))`. FD supports this |
| goal | everyone at reachable places delivered | the translator has to leave unreachable places **out of the goal**. Otherwise the problem is unsolvable and FD returns no plan. That is an interesting failure mode to report |
| objective | minimise total minutes subject to the above | use FD `--alias seq-opt-lmcut` (optimal) or `lama-first` (satisficing) and report which one |

## 4. Plan formats accepted by the judge

**Canonical JSON** (what the LLM-only pipeline outputs):
```json
{"steps": [{"action": "move", "from": "Syaphru", "to": "Bhalche"},
           {"action": "pickup", "location": "Bhalche"},
           {"action": "move", "from": "Bhalche", "to": "Syaphru"},
           {"action": "dropoff", "location": "Syaphru"}],
 "unreachable": [], "claimed_total_minutes": 60}
```
**Planner output** (`sas_plan`). The adapter reads one action per line and puts **the locations last**:
`(move <team> <from> <to>)`, `(pickup <team> <place> ...)`, `(dropoff <team> <shelter>)`. Action
names starting with move/drive, pickup/rescue/load or dropoff/unload/deliver are recognised. Object names can be
the instance ids or the display names (case-insensitive). If the domain differs, pass a `name_map`
to `parse_pddl_plan`.

## 5. Scoring a plan from any pipeline

```bash
python -m rescue.cli validate-plan data/instances/k8-s5-cap.json sas_plan --pddl
python -m rescue.cli validate-plan data/instances/k8-s5-cap.json plan.json
```
This prints `valid`, `executable`, `complete`, `priority_ok`, `cost`, `oracle_cost`, `gap` and the typed errors. It exits 0 only if
the plan is valid. Error codes:

| severity | codes |
|---|---|
| physical (plan cannot be carried out) | UNKNOWN_LOCATION, UNKNOWN_ACTION, WRONG_ORIGIN, NO_ROAD, BLOCKED_ROAD, NOT_AT_LOCATION, CAPACITY, WRONG_DROPOFF |
| goal (people left behind) | NOT_DELIVERED, FALSE_UNREACHABLE |
| priority | PRIORITY |
| info (recorded only) | UNREPORTED_UNREACHABLE, EMPTY_PICKUP, DUPLICATE_PICKUP, UNKNOWN_UNREACHABLE_NAME |

Kimaya: for the PDDL pipeline, also record **where** it failed (translation syntax error, planner found
no plan, plan found but invalid against ground truth). The last one means the translation was wrong, for example a
blocked road written as open. Only the independent judge can catch it, because the planner trusts the translation.

## 6. Experimental protocol (ALIGN)

- **Same model** for both pipelines (default `claude-sonnet-5-5`; the final choice is the team's).
- **Splits:** `meta.split` in each instance. `dev` = replicate 0 (16 instances, prompt development only);
  `test` = replicates 1–2 (32 instances, reported numbers). Prompts are frozen before running `test`. This is the TA's
  "split data for testing" point.
- **Same instances, same three levels, same number of samples per instance.**
- The repair loops should be comparable. The LLM-only `nl-repair` gets validator feedback for at most 2 rounds.
  The PDDL self-repair should also be capped at 2 rounds and should report what feedback it received.
