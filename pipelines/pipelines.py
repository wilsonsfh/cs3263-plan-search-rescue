#!/usr/bin/env python3
"""The two Claude pipelines.

  direct  Claude reads the field report and writes the rescue plan itself.
  pddl    Claude reads the field report and writes a PDDL problem file for
          domain.pddl; Fast Downward solves it. If the file fails to parse or
          the planner fails, the error goes back to Claude (self-repair loop).

Both return a plan in the checker's format, which run_eval.py scores against
the ground truth with checker.py.
"""

import os
import re
import subprocess
import tempfile
import time
from pathlib import Path

import anthropic

HERE = Path(__file__).parent
DOMAIN = HERE.parent / "pddl" / "domain.pddl"
FD = os.environ.get("FD", "fast-downward.py")

# ---------------------------------------------------------------- prompts

TASK = """You are helping coordinate a post-flood search-and-rescue operation in Nepal.

The rules of the operation:
- Cars drive along the listed roads. A damaged or blocked road cannot be used. Driving a road takes its stated number of minutes.
- People wait at locations. Each person is injured, a child, an elderly person, or an adult (an injured person counts only as injured, whatever their age). People at the same location may be split between cars or trips.
- A car can carry at most its stated number of passengers at once.
- People can only be dropped off at an evacuation point (a designated safe location). Anywhere else does not count.
- Every person must end up either rescued (dropped at an evacuation point) or deferred to a later rescue wave.
- Deferring has a penalty per person: injured 80, child 60, elderly 50, adult 20 (measured in minutes of driving).
- The plan ends when everyone is rescued or deferred. Cars do not need to return anywhere.
- Goal: minimise total cost = total driving minutes of all cars + penalties for deferred people.

Use the identifiers in square brackets (without the brackets) for cars and locations, and the words injured, child, elderly, adult for the bands."""

DIRECT_INSTRUCTIONS = """Write the rescue plan as one action per line, inside <plan></plan> tags, using exactly these forms:
drive <car> <from-location> <to-location>
load <car> <band> <count>
unload <car> <band> <count>
defer <location> <band> <count>

<band> is injured, child, elderly or adult. Actions run in the order written. "load" picks people up at the car's current location; "unload" drops them at the car's current location. "drive" moves along one road only, so a longer route needs one drive line per road. After the plan, give the total cost on a line "COST: <number>"."""

PDDL_INSTRUCTIONS = """Do not plan the rescue yourself. Instead, translate the field report into a PDDL problem file for the domain below, so that a classical planner can find the optimal plan.

Requirements for the problem file:
- (:domain flood-rescue)
- Object names: use the bracketed identifiers exactly for locations and cars. The bands injured, child, elderly, adult and the level n0 are domain constants, so do not declare them. Declare level objects n1 ... nK, where K is the larger of the car capacity and the largest number of people of one band at one location.
- List each road in both directions with (road a b), its (= (travel-time a b) minutes), and (damaged a b) if it cannot be used.
- (evac-point x) for every evacuation point.
- For every car: (car-at c x), (free-seats c nS) with S its capacity, and (carrying c b n0) for each of the four bands.
- (waiting x b nN) for every location and band with N > 0 people waiting.
- (sum a b c) for every a + b = c within n0 ... nK, and (positive n) for n1 ... nK.
- (= (defer-cost b nN) P) for each band and each N in 1 ... K, where P = per-person penalty x N.
- (= (total-cost) 0) in :init.
- Goal: (waiting x b n0) for every (x, b) that had people waiting, and (carrying c b n0) for every car and band.
- (:metric minimize (total-cost))

Return only the complete problem file inside a single ```pddl code block.

The domain:
```pddl
{domain}
```"""

REPAIR_PDDL = """Running the planner on your problem file failed:

{error}

Fix the problem file and return the complete corrected file inside a single ```pddl code block."""

REPAIR_DIRECT = """A plan checker rejected your plan:

{error}

Fix the plan and return the complete corrected plan inside <plan></plan> tags, followed by "COST: <number>"."""


# ---------------------------------------------------------------- Claude calls

class Claude:
    """Thin wrapper that keeps the conversation and adds up token usage."""

    def __init__(self, model, effort, client=None):
        self.model, self.effort = model, effort
        self.client = client or anthropic.Anthropic()
        self.usage = {"input_tokens": 0, "output_tokens": 0, "calls": 0}

    def ask(self, system, messages):
        # Streaming avoids HTTP timeouts on long thinking + output.
        # No refusal fallback on purpose: the experiment must stay on one model.
        with self.client.messages.stream(
            model=self.model,
            max_tokens=32000,
            system=system,
            output_config={"effort": self.effort},
            messages=messages,
        ) as stream:
            msg = stream.get_final_message()
        self.usage["input_tokens"] += msg.usage.input_tokens
        self.usage["output_tokens"] += msg.usage.output_tokens
        self.usage["calls"] += 1
        text = "".join(b.text for b in msg.content if b.type == "text")
        # Keep the full content (incl. thinking blocks) for the next turn.
        messages.append({"role": "assistant", "content": msg.content})
        return text, msg.stop_reason


# ---------------------------------------------------------------- helpers

def extract_plan(text):
    m = re.search(r"<plan>(.*?)</plan>", text, re.S)
    body = m.group(1) if m else ""
    return [l.strip() for l in body.splitlines() if l.strip()]


def extract_pddl(text):
    blocks = re.findall(r"```(?:pddl|lisp)?\s*\n(.*?)```", text, re.S)
    return blocks[-1] if blocks else None


MS = ("astar(merge_and_shrink(shrink_strategy=shrink_bisimulation(greedy=false),"
      "merge_strategy=merge_sccs(order_of_sccs=topological,merge_selector=score_based_filtering("
      "scoring_functions=[goal_relevance(),dfp(),total_order()])),"
      "label_reduction=exact(before_shrinking=true,before_merging=false),"
      "max_states=50000,threshold_before_merge=1))")

FD_EXIT = {10: "translator proved the problem unsolvable", 11: "planner proved the problem unsolvable",
           12: "search ended without a plan", 22: "out of memory", 23: "out of time",
           30: "translator crashed", 31: "invalid PDDL input", 32: "search crashed",
           33: "invalid search input", 34: "unsupported feature"}


def run_planner(problem_text, timeout):
    """Same searches as pddl/solve.py: two optimal searches, then anytime LAMA.
    Returns (plan_lines or None, info dict)."""
    with tempfile.TemporaryDirectory() as tmp:
        prob = Path(tmp) / "problem.pddl"
        prob.write_text(problem_text)
        info = {}
        for name, args in (("optimal-lmcut", ["--search", "astar(lmcut())"]),
                           ("optimal-ms", ["--search", MS]),
                           ("lama-anytime", ["--alias", "seq-sat-lama-2011"])):
            for f in Path(tmp).glob("sas_plan*"):
                f.unlink()
            cmd = ["python3", FD, "--overall-time-limit", f"{timeout}s"]
            cmd += (args + [str(DOMAIN), str(prob)]) if args[0] == "--alias" else ([str(DOMAIN), str(prob)] + args)
            t0 = time.time()
            p = subprocess.run(cmd, cwd=tmp, capture_output=True, text=True, timeout=timeout + 60)
            info.update(search=name, seconds=round(time.time() - t0, 2), exit_code=p.returncode)
            plans = sorted(Path(tmp).glob("sas_plan*"),
                           key=lambda f: int(f.suffix[1:]) if f.suffix[1:].isdigit() else 0)
            if plans:
                lines = [l for l in plans[-1].read_text().splitlines() if l.startswith("(")]
                info["optimal"] = name.startswith("optimal")
                return lines, info
            if p.returncode != 23:   # anything other than a timeout: report the error
                tail = [l for l in (p.stdout + p.stderr).splitlines()
                        if l.strip() and not l.startswith("INFO")][-25:]
                info["error"] = f"{FD_EXIT.get(p.returncode, f'exit code {p.returncode}')}\n" + "\n".join(tail).replace(str(prob), "problem.pddl")
                return None, info
        info["error"] = "planner ran out of time on both searches"
        return None, info


# ---------------------------------------------------------------- pipelines

def run_direct(claude, report, checker_fn=None, repairs=0):
    """LLM-only pipeline. checker_fn (optional) gives oracle feedback for the
    repair ablation; with repairs=0 Claude gets a single attempt."""
    system = TASK + "\n\n" + DIRECT_INSTRUCTIONS
    messages = [{"role": "user", "content": "FIELD REPORT\n\n" + report}]
    attempts = []
    for attempt in range(repairs + 1):
        text, stop = claude.ask(system, messages)
        plan = extract_plan(text)
        claimed = re.search(r"COST:\s*(\d+)", text)
        attempts.append({"attempt": attempt, "stop_reason": stop, "plan": plan,
                         "claimed_cost": int(claimed.group(1)) if claimed else None, "text": text})
        if checker_fn is None or attempt == repairs:
            break
        res = checker_fn(plan)
        if res["valid"]:
            break
        messages.append({"role": "user", "content": REPAIR_DIRECT.format(error=res["error"])})
    return attempts[-1]["plan"], attempts


def run_pddl(claude, report, repairs=3, timeout=60):
    """LLM -> PDDL -> Fast Downward, with up to `repairs` fix attempts."""
    system = TASK + "\n\n" + PDDL_INSTRUCTIONS.format(domain=DOMAIN.read_text())
    messages = [{"role": "user", "content": "FIELD REPORT\n\n" + report}]
    attempts = []
    for attempt in range(repairs + 1):
        text, stop = claude.ask(system, messages)
        problem = extract_pddl(text)
        if problem is None:
            plan, info = None, {"error": "no ```pddl code block found in the reply"}
        else:
            plan, info = run_planner(problem, timeout)
        attempts.append({"attempt": attempt, "stop_reason": stop, "problem": problem,
                         "planner": info, "text": text})
        if plan is not None:
            return plan, attempts
        if attempt < repairs:
            messages.append({"role": "user", "content": REPAIR_PDDL.format(error=info["error"])})
    return None, attempts
