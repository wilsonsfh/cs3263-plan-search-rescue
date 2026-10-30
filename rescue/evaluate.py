"""Aggregate run records into the tables used in the report."""
from __future__ import annotations

import json
import statistics as st
from collections import Counter, defaultdict
from pathlib import Path

from .schema import GROUPS


def load(path: Path) -> list[dict]:
    return [json.loads(l) for l in Path(path).read_text().splitlines() if l.strip()]


def _mean(xs):
    xs = [x for x in xs if x is not None]
    return st.mean(xs) if xs else None


def _fmt(x, pct=False, nd=2):
    if x is None:
        return "–"
    return f"{100 * x:.0f}%" if pct else f"{x:.{nd}f}"


def summarise(recs: list[dict]) -> dict:
    ok = [r for r in recs if not r["call_error"]]
    fin = [r["final"] for r in ok if r["final"]]
    n = len(ok)
    vulner = []
    for r in ok:
        f = r["final"]
        if f:
            tot = sum(f["rescuable"][g] for g in ("injured", "children", "elderly"))
            got = sum(f["delivered"][g] for g in ("injured", "children", "elderly"))
            vulner.append(1.0 if tot == 0 else got / tot)
        else:
            vulner.append(0.0)
    return {
        "n": n,
        "call_errors": len(recs) - n,
        "parse": sum(r["parse_ok"] for r in ok) / n if n else None,
        "executable": sum(bool(f and f["executable"]) for f in (r["final"] for r in ok)) / n if n else None,
        "complete": sum(bool(f and f["complete"]) for f in (r["final"] for r in ok)) / n if n else None,
        "priority": sum(bool(f and f["priority_ok"]) for f in (r["final"] for r in ok)) / n if n else None,
        "valid": sum(bool(f and f["valid"]) for f in (r["final"] for r in ok)) / n if n else None,
        # coverage of an unparseable plan is 0: nobody gets rescued
        "coverage": _mean([(r["final"] or {}).get("coverage", 0.0) for r in ok]),
        "vulnerable_coverage": _mean(vulner),
        "gap": _mean([r["gap"] for r in ok]),
        "optimal": (sum(1 for r in ok if r["gap"] is not None and r["gap"] < 1e-9) / n) if n else None,
        "abs_claim_err": _mean([abs(f["claimed_cost_error"]) for f in fin if f["claimed_cost_error"] is not None]),
        "out_tokens": _mean([r["usage"]["output_tokens"] for r in ok]),
        "think_tokens": _mean([r["usage"]["thinking_tokens"] for r in ok]),
        "latency": _mean([r["usage"]["latency_s"] for r in ok if not r["usage"]["cached_calls"]]),
        "rounds": _mean([r["n_rounds"] for r in ok]),
    }


COLS = [("n", "n", None), ("valid", "valid", True), ("executable", "exec", True), ("complete", "complete", True),
        ("priority", "priority", True), ("coverage", "coverage", True), ("vulnerable_coverage", "vuln. cov.", True),
        ("optimal", "optimal", True), ("gap", "gap (valid)", True), ("abs_claim_err", "|claim err| min", False),
        ("out_tokens", "out tok", False), ("think_tokens", "think tok", False), ("latency", "latency s", False),
        ("rounds", "rounds", False)]


def table(recs: list[dict], keys: tuple[str, ...]) -> str:
    groups = defaultdict(list)
    for r in recs:
        groups[tuple(r[k] for k in keys)].append(r)
    head = "| " + " | ".join(list(keys) + [c[1] for c in COLS]) + " |"
    sep = "|" + "---|" * (len(keys) + len(COLS))
    rows = [head, sep]
    order = lambda t: tuple((0, x, "") if isinstance(x, (int, float)) else (1, 0, str(x)) for x in t)  # noqa: E731
    for g in sorted(groups, key=order):
        s = summarise(groups[g])
        cells = [str(x) for x in g]
        for key, _, pct in COLS:
            v = s[key]
            cells.append(str(v) if key == "n" else _fmt(v, pct=bool(pct), nd=0 if key in ("out_tokens", "think_tokens", "latency") else 2))
        rows.append("| " + " | ".join(cells) + " |")
    return "\n".join(rows)


def error_table(recs: list[dict], key: str = "variant") -> str:
    by = defaultdict(Counter)
    for r in recs:
        if r["call_error"]:
            continue
        if not r["parse_ok"]:
            by[r[key]]["PARSE_FAIL"] += 1
            continue
        for c in set(r["final"]["error_codes"]):
            by[r[key]][c] += 1
    codes = sorted({c for v in by.values() for c in v})
    rows = ["| " + key + " | " + " | ".join(codes) + " |", "|" + "---|" * (len(codes) + 1)]
    for k in sorted(by):
        rows.append(f"| {k} | " + " | ".join(str(by[k][c]) for c in codes) + " |")
    return "\n".join(rows)


def consistency(recs: list[dict]) -> str:
    """Across repeated samples / probes of the same instance: do validity and the order of
    pickups agree? (TA: are priority decisions made consistently?)"""
    groups = defaultdict(list)
    for r in recs:
        if not r["call_error"]:
            groups[(r["variant"], r["level"], r["instance"].split("-rn")[0])].append(r)
    agg = defaultdict(lambda: [0, 0, 0, 0])
    for (variant, level, _), rs in groups.items():
        if len(rs) < 2:
            continue
        valid = {bool(r["final"] and r["final"]["valid"]) for r in rs}
        prio = {bool(r["final"] and r["final"]["priority_ok"]) for r in rs}
        orders = {tuple(r["rounds"][-1].get("pickup_ids") or ()) for r in rs}
        a = agg[(variant, level)]
        a[0] += 1
        a[1] += len(valid) == 1
        a[2] += len(prio) == 1
        a[3] += len(orders) == 1
    rows = ["| variant | level | groups | same validity | same priority compliance | same pickup order |",
            "|---|---|---|---|---|---|"]
    for (v, l), (n, a, b, c) in sorted(agg.items()):
        rows.append(f"| {v} | {l} | {n} | {a / n:.0%} | {b / n:.0%} | {c / n:.0%} |")
    return "\n".join(rows)


def report(path: Path) -> str:
    recs = load(path)
    base = [r for r in recs if r["probe"] == "none"]
    parts = [
        f"# Results: {path.parent.name}\n",
        f"{len(recs)} records, {sum(r['call_error'] for r in recs)} call errors (excluded).\n",
        "## By variant and level\n", table(base, ("variant", "level")),
        "\n## By variant and size k\n", table(base, ("variant", "k")),
        "\n## Instances with a cut-off location\n", table(base, ("variant", "cut_off")),
        "\n## Capacity\n", table(base, ("variant", "capacity_mode")),
        "\n## Error types (number of runs with each error)\n", error_table(base),
        "\n## Consistency across samples\n", consistency(base),
    ]
    probes = [r for r in recs if r["probe"] != "none"]
    if probes:
        parts += ["\n## Invariance probes\n", table(recs, ("variant", "probe")),
                  "\n", consistency(recs)]
    rep = [r for r in base if r["variant"] == "nl-repair"]
    if rep:
        parts += ["\n## Validator-repair: validity after each round\n", repair_curve(rep)]
    return "\n".join(parts)


def repair_curve(recs: list[dict]) -> str:
    rows = ["| round | valid so far |", "|---|---|"]
    ok = [r for r in recs if not r["call_error"]]
    for k in range(3):
        v = sum(any(x.get("result", {}).get("valid") for x in r["rounds"][: k + 1]) for r in ok)
        rows.append(f"| {k} | {v}/{len(ok)} ({v / len(ok):.0%}) |" if ok else f"| {k} | – |")
    return "\n".join(rows)
