#!/usr/bin/env python3
"""Run the pipelines over the instance set and score every plan.

Examples:
  # plumbing test, no API calls (a fake Claude returns the right answer)
  python3 run_eval.py --mock --sizes small --limit 2

  # real run (needs ANTHROPIC_API_KEY and FD=/path/to/fast-downward.py)
  python3 run_eval.py --pipelines direct pddl --levels explicit implicit

  # repair ablations
  python3 run_eval.py --pipelines pddl --pddl-repairs 0 --tag no-repair
  python3 run_eval.py --pipelines direct --direct-repairs 3 --tag oracle-feedback

Each run is saved under runs/<tag>/<pipeline>/<instance>-<level>.json and
summarised in runs/<tag>/results.csv. Finished runs are skipped, so a crashed
batch can simply be restarted.
"""

import argparse
import csv
import json
import re
import sys
from pathlib import Path
from types import SimpleNamespace

from checker import check
from pipelines import Claude, run_direct, run_pddl

HERE = Path(__file__).parent
INSTANCES = HERE.parent / "pddl" / "instances"
REPORTS = HERE / "reports"

# Opus 5.5 list prices, USD per million tokens (input, output).
PRICES = {"claude-opus-5-5": (4.0, 20.0), "claude-sonnet-5-5": (2.0, 10.0),
          "claude-haiku-5-5": (0.10, 0.50)}


# ---------------------------------------------------------------- translation fidelity

FACT_RE = re.compile(r"\((road|damaged|evac-point|car-at|free-seats|waiting)((?:\s+[\w-]+)+)\s*\)")
FN_RE = re.compile(r"\(=\s*\((travel-time)((?:\s+[\w-]+)+)\s*\)\s*(\d+)\s*\)")


def facts_from_pddl(text):
    init = text.split(":init", 1)[-1].split(":goal", 1)[0].lower()
    facts = {(m.group(1),) + tuple(m.group(2).split()) for m in FACT_RE.finditer(init)}
    facts |= {(m.group(1),) + tuple(m.group(2).split()) + (m.group(3),) for m in FN_RE.finditer(init)}
    return facts


def fidelity(llm_problem, inst):
    """Compare the facts Claude wrote with the ground-truth problem file."""
    gt = facts_from_pddl((INSTANCES / f"{inst['id']}.pddl").read_text())
    got = facts_from_pddl(llm_problem or "")
    out = {"facts_exact": gt == got}
    for kind in ("road", "damaged", "evac-point", "waiting", "travel-time", "car-at", "free-seats"):
        g = {f for f in gt if f[0] == kind}
        h = {f for f in got if f[0] == kind}
        out[f"missing_{kind}"] = len(g - h)
        out[f"extra_{kind}"] = len(h - g)
    return out


# ---------------------------------------------------------------- mock Claude

class MockClient:
    """Answers like a perfect model, from the ground truth. Tests the plumbing only."""

    def __init__(self):
        self.messages = self
        self.case = None   # the instance being run

    def stream(self, **kw):
        inst = self.case
        if "<plan>" in kw["system"]:
            lines = (INSTANCES / f"{inst['id']}.best-plan").read_text().splitlines()
            text = "<plan>\n" + "\n".join(lines) + "\n</plan>\nCOST: 0"
        else:
            text = "```pddl\n" + (INSTANCES / f"{inst['id']}.pddl").read_text() + "```"
        msg = SimpleNamespace(content=[SimpleNamespace(type="text", text=text)], stop_reason="end_turn",
                              usage=SimpleNamespace(input_tokens=0, output_tokens=0))
        return SimpleNamespace(__enter__=lambda *a: SimpleNamespace(get_final_message=lambda: msg),
                               __exit__=lambda *a: False)


class _CM:
    def __init__(self, ns): self.ns = ns
    def __enter__(self): return self.ns.__enter__()
    def __exit__(self, *a): return False


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pipelines", nargs="+", default=["direct", "pddl"], choices=["direct", "pddl"])
    ap.add_argument("--levels", nargs="+", default=["explicit", "implicit"], choices=["explicit", "implicit"])
    ap.add_argument("--sizes", nargs="+", default=["small", "medium", "large"])
    ap.add_argument("--ids", nargs="*", help="only these instance ids")
    ap.add_argument("--limit", type=int, help="first N instances per size")
    ap.add_argument("--model", default="claude-opus-5-5")
    ap.add_argument("--effort", default="medium", choices=["low", "medium", "high", "xhigh", "max"])
    ap.add_argument("--pddl-repairs", type=int, default=3)
    ap.add_argument("--direct-repairs", type=int, default=0,
                    help="checker feedback rounds for the direct pipeline (oracle ablation)")
    ap.add_argument("--timeout", type=int, default=60, help="planner seconds per search")
    ap.add_argument("--tag", default="main", help="name of this batch (folder under runs/)")
    ap.add_argument("--mock", action="store_true", help="no API calls; fake perfect answers")
    args = ap.parse_args()

    out = HERE / "runs" / (args.tag + ("-mock" if args.mock else ""))
    cases = []
    for size in args.sizes:
        ids = sorted(p.stem for p in INSTANCES.glob(f"{size}-*.json"))
        if args.ids:
            ids = [i for i in ids if i in args.ids]
        cases += ids[: args.limit] if args.limit else ids

    mock = MockClient() if args.mock else None
    if mock:
        orig = mock.stream
        mock.stream = lambda **kw: _CM(orig(**kw))

    total = {"input_tokens": 0, "output_tokens": 0}
    for pipeline in args.pipelines:
        for iid in cases:
            inst = json.loads((INSTANCES / f"{iid}.json").read_text())
            for level in args.levels:
                dest = out / pipeline / f"{iid}-{level}.json"
                if dest.exists():
                    continue
                report = (REPORTS / f"{iid}-{level}.txt").read_text()
                if mock:
                    mock.case = inst
                claude = Claude(args.model, args.effort, client=mock)
                try:
                    if pipeline == "direct":
                        plan, attempts = run_direct(claude, report,
                                                    checker_fn=lambda p: check(inst, p),
                                                    repairs=args.direct_repairs)
                    else:
                        plan, attempts = run_pddl(claude, report, args.pddl_repairs, args.timeout)
                except Exception as e:   # keep the batch going; record the failure
                    print(f"{pipeline} {iid} {level}: ERROR {type(e).__name__}: {e}", file=sys.stderr)
                    continue
                result = check(inst, plan) if plan is not None else {"valid": False, "error": "no plan", "cost": None}
                rec = {"pipeline": pipeline, "instance": iid, "size": inst["size"], "level": level,
                       "model": args.model, "effort": args.effort, "attempts_used": len(attempts),
                       "usage": claude.usage, "result": result, "attempts": attempts}
                if pipeline == "pddl":
                    rec["fidelity"] = fidelity(attempts[-1].get("problem"), inst)
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(json.dumps(rec, indent=2, default=str))
                for k in total:
                    total[k] += claude.usage[k]
                print(f"{pipeline:6} {iid:10} {level:8} valid={result['valid']} cost={result.get('cost')} "
                      f"attempts={len(attempts)} {result.get('error', '')[:80]}")

    summarise(out)
    pin, pout = PRICES.get(args.model, (0, 0))
    print(f"tokens this batch: {total}  ~${(total['input_tokens'] * pin + total['output_tokens'] * pout) / 1e6:.2f}")


def summarise(out):
    """Collect every saved run into results.csv, with the reference cost alongside."""
    ref = {r["id"]: r for r in csv.DictReader(open(HERE.parent / "pddl" / "results" / "best_reference.csv"))}
    rows = []
    for f in sorted(out.glob("*/*.json")):
        r = json.loads(f.read_text())
        res, rf = r["result"], ref[r["instance"]]
        row = {"pipeline": r["pipeline"], "instance": r["instance"], "size": r["size"], "level": r["level"],
               "model": r["model"], "effort": r["effort"], "valid": res["valid"], "cost": res.get("cost"),
               "reference_cost": rf["best_cost"], "reference_optimal": rf["proven_optimal"],
               "gap_pct": round(100 * (res["cost"] - int(rf["best_cost"])) / int(rf["best_cost"]), 1) if res.get("cost") else "",
               "people_rescued": res.get("people_rescued", ""), "attempts": r["attempts_used"],
               "input_tokens": r["usage"]["input_tokens"], "output_tokens": r["usage"]["output_tokens"],
               "error": res.get("error", "")}
        if r["pipeline"] == "direct":
            row["claimed_cost"] = r["attempts"][-1].get("claimed_cost")
        if "fidelity" in r:
            row.update(r["fidelity"])
        rows.append(row)
    if not rows:
        return
    fields = list(dict.fromkeys(k for row in rows for k in row))
    with open(out / "results.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {out / 'results.csv'} ({len(rows)} runs)")


if __name__ == "__main__":
    main()
