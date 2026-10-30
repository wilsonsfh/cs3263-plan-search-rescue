"""Command line entry point.

  python -m rescue.cli generate                      # write data/instances + data/reports
  python -m rescue.cli run --name pilot --model claude-sonnet-5-5 --variants nl-reason \
        --levels L1,L2,L3 --split dev --samples 1 --workers 3
  python -m rescue.cli eval results/pilot/records.jsonl
  python -m rescue.cli validate-plan data/instances/k8-s5-cap.json plan.txt [--pddl]
  python -m rescue.cli oracle-stats
"""
from __future__ import annotations

import argparse
import json
import sys
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from .evaluate import report
from .generator import generate, suite
from .graph import stranded_unreachable
from .llm_only import VARIANTS, oracle_cost, run_one
from .oracle import solve
from .probes import rename
from .reports import gold_facts, render
from .schema import Instance
from .validator import parse_pddl_plan, parse_plan_json, plan_to_obj, validate

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"


def cmd_generate(a) -> None:
    (DATA / "instances").mkdir(parents=True, exist_ok=True)
    rows = []
    for inst in suite(sizes=tuple(a.sizes), reps=a.reps):
        inst.save(DATA / "instances" / f"{inst.id}.json")
        d = DATA / "reports" / inst.id
        d.mkdir(parents=True, exist_ok=True)
        for lv in ("L1", "L2", "L3"):
            (d / f"{lv}.txt").write_text(render(inst, lv).text)
        (d / "gold.json").write_text(gold_facts(inst))
        r = solve(inst)
        (d / "oracle_plan.json").write_text(json.dumps(plan_to_obj(r.plan), indent=1))
        rows.append({"id": inst.id, "split": inst.meta["split"], "k": inst.meta["k"],
                     "nodes": len(inst.locations), "roads": len(inst.roads), "blocked": inst.meta["n_blocked"],
                     "capacity": inst.capacity, "unreachable": [inst.name_of(x) for x in stranded_unreachable(inst)],
                     "oracle_cost": r.cost, "expanded": r.expanded, "state_bound": r.state_bound})
    (DATA / "manifest.json").write_text(json.dumps(rows, indent=1))
    print(f"wrote {len(rows)} instances x 3 levels to {DATA}")


def _instances(a) -> list[Instance]:
    out = []
    for p in sorted((DATA / "instances").glob("*.json")):
        inst = Instance.load(p)
        if a.split != "all" and inst.meta.get("split") != a.split:
            continue
        if a.sizes and inst.meta.get("k") not in a.sizes:
            continue
        if a.only and inst.id not in a.only:
            continue
        out.append(inst)
    return out


def cmd_run(a) -> None:
    out = ROOT / "results" / a.name
    out.mkdir(parents=True, exist_ok=True)
    rec_path = out / "records.jsonl"
    done = set()
    if rec_path.exists():
        for line in rec_path.read_text().splitlines():
            r = json.loads(line)
            if not r["call_error"]:
                done.add((r["instance"], r["level"], r["variant"], r["sample"], r["render_seed"], r["probe"]))

    jobs = []
    for inst in _instances(a):
        oracle_cost(inst)
        targets = [(inst, 0, "none")]
        if "paraphrase" in a.probes:
            targets += [(inst, s, f"paraphrase{s}") for s in (1, 2)]
        if "rename" in a.probes:
            targets += [(rename(inst, 1), 0, "rename1")]
        for v in a.variants:
            var = VARIANTS[v]
            levels = ["gold"] if var.input == "gold" else a.levels
            for lv in levels:
                for tgt, seed, probe in targets:
                    if var.input == "gold" and probe.startswith("paraphrase"):
                        continue  # gold facts have no wording to paraphrase
                    for s in range(a.samples):
                        key = (tgt.id, lv, v, s, seed, probe)
                        if key not in done:
                            jobs.append((tgt, lv, var, s, seed, probe))
    print(f"{len(jobs)} runs to do ({len(done)} already done) -> {rec_path}", flush=True)
    if a.dry:
        for j in jobs[:20]:
            print("  ", j[0].id, j[1], j[2].name, "sample", j[3], j[5])
        return
    lock = threading.Lock()
    with ThreadPoolExecutor(a.workers) as ex, rec_path.open("a") as fh:
        futs = {ex.submit(run_one, t, lv, var, a.model, s, seed, probe): (t.id, lv, var.name, s, probe)
                for t, lv, var, s, seed, probe in jobs}
        for i, f in enumerate(as_completed(futs), 1):
            key = futs[f]
            try:
                rec = f.result()
            except Exception as e:  # noqa: BLE001 - keep the batch going; report the crash
                print(f"[{i}/{len(jobs)}] CRASH {key}: {e!r}", flush=True)
                continue
            with lock:
                fh.write(json.dumps(rec) + "\n")
                fh.flush()
            fin = rec["final"] or {}
            status = ("CALL-ERR" if rec["call_error"] else "PARSE-FAIL" if not rec["parse_ok"]
                      else "VALID" if fin.get("valid") else "invalid " + ",".join(sorted(set(fin["error_codes"]))))
            gap = f" gap={rec['gap']:.1%}" if rec["gap"] is not None else ""
            print(f"[{i}/{len(jobs)}] {key} {status}{gap} ({rec['usage']['latency_s']:.0f}s)", flush=True)
    (out / "summary.md").write_text(report(rec_path))
    print(f"summary -> {out / 'summary.md'}")


def cmd_eval(a) -> None:
    text = report(Path(a.records))
    Path(a.records).with_name("summary.md").write_text(text)
    print(text)


def cmd_validate_plan(a) -> None:
    inst = Instance.load(Path(a.instance))
    text = Path(a.plan).read_text()
    plan = parse_pddl_plan(text) if a.pddl else parse_plan_json(text)
    res = validate(inst, plan)
    opt = solve(inst).cost
    s = res.summary()
    s["oracle_cost"] = opt
    s["gap"] = (res.cost / opt - 1) if res.valid and opt else None
    print(json.dumps({k: v for k, v in s.items() if k != "pickup_minutes_by_group"}, indent=1))
    sys.exit(0 if res.valid else 1)


def cmd_oracle_stats(a) -> None:
    # "no tiers" = same instance solved without the vulnerability-tier rule: the extra
    # minutes are the price of prioritising the vulnerable; the extra expansions show
    # how much the rule prunes the search.
    print("| k | seed | nodes | roads | capacity | expanded | state bound | seconds | cost "
          "| cost no tiers | price of priority | expanded no tiers |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for k in a.sizes:
        for s in range(a.seeds):
            for cap in ("unlimited", "tight"):
                inst = generate(k, s, capacity=cap)
                r, r0 = solve(inst), solve(inst, priority="none")
                price = f"{r.cost / r0.cost - 1:.1%}" if r.cost and r0.cost else "–"
                print(f"| {k} | {s} | {len(inst.locations)} | {len(inst.roads)} | {inst.capacity} | "
                      f"{r.expanded} | {r.state_bound} | {r.seconds:.3f} | {r.cost} | {r0.cost} | {price} "
                      f"| {r0.expanded} |")


def main(argv=None) -> None:
    ap = argparse.ArgumentParser(prog="rescue")
    sub = ap.add_subparsers(required=True)

    g = sub.add_parser("generate")
    g.add_argument("--sizes", type=int, nargs="+", default=[4, 8, 12, 16])
    g.add_argument("--reps", type=int, default=3)
    g.set_defaults(fn=cmd_generate)

    r = sub.add_parser("run")
    r.add_argument("--name", required=True)
    r.add_argument("--model", default="claude-sonnet-5-5")
    r.add_argument("--variants", type=lambda s: s.split(","), default=["nl-reason"])
    r.add_argument("--levels", type=lambda s: s.split(","), default=["L1", "L2", "L3"])
    r.add_argument("--split", default="test", choices=["dev", "test", "all"])
    r.add_argument("--sizes", type=int, nargs="*", default=None)
    r.add_argument("--only", nargs="*", default=None, help="instance ids")
    r.add_argument("--samples", type=int, default=1)
    r.add_argument("--probes", type=lambda s: s.split(","), default=[])
    r.add_argument("--workers", type=int, default=3)
    r.add_argument("--dry", action="store_true")
    r.set_defaults(fn=cmd_run)

    e = sub.add_parser("eval")
    e.add_argument("records")
    e.set_defaults(fn=cmd_eval)

    v = sub.add_parser("validate-plan")
    v.add_argument("instance")
    v.add_argument("plan")
    v.add_argument("--pddl", action="store_true", help="plan is planner output, e.g. sas_plan")
    v.set_defaults(fn=cmd_validate_plan)

    o = sub.add_parser("oracle-stats")
    o.add_argument("--sizes", type=int, nargs="+", default=[3, 5, 7, 9, 11, 13])
    o.add_argument("--seeds", type=int, default=2)
    o.set_defaults(fn=cmd_oracle_stats)

    a = ap.parse_args(argv)
    a.fn(a)


if __name__ == "__main__":
    main()
