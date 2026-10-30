"""The LLM-only pipeline: field reports -> frontier model -> plan -> independent validator.

Variants (each isolates one factor; see docs/llm_only_method.md):
  nl-direct    NL reports, answer-only, low reasoning effort    (fast "System 1" baseline)
  nl-reason    NL reports, reason first, high effort            (main LLM-only condition)
  gold-reason  perfectly extracted facts (JSON), high effort     (removes comprehension errors:
                                                                 nl-reason minus gold-reason =
                                                                 cost of reading the reports)
  nl-repair    nl-reason + up to 2 rounds of validator feedback  (LLM proposes, checker verifies;
                                                                 counterpart of the PDDL self-repair loop)
Round 0 of nl-repair is byte-identical to nl-reason, so it is served from the cache and
the two are a paired comparison at no extra cost.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .backends import Backend, make_backend
from .oracle import solve
from .reports import gold_facts, render
from .schema import GROUPS, Instance
from .validator import NameResolver, PlanParseError, ValidationResult, parse_plan_json, validate

PROMPTS = Path(__file__).resolve().parent.parent / "prompts"


def _p(name: str) -> str:
    return (PROMPTS / name).read_text().strip()


@dataclass(frozen=True)
class Variant:
    name: str
    input: str  # nl | gold
    style: str  # direct | reason
    effort: str
    repair_rounds: int = 0


VARIANTS = {v.name: v for v in [
    Variant("nl-direct", "nl", "direct", "low"),
    Variant("nl-reason", "nl", "reason", "high"),
    Variant("gold-reason", "gold", "reason", "high"),
    Variant("nl-repair", "nl", "reason", "high", repair_rounds=2),
]}


def build_prompt(inst: Instance, level: str, variant: Variant, render_seed: int = 0) -> tuple[str, str]:
    if variant.input == "gold":
        problem = ("PROBLEM (already extracted from the reports; post-flood road status and current "
                   "travel times)\n" + gold_facts(inst))
    else:
        problem = render(inst, level, seed=render_seed).text
    style = _p("style_direct.md" if variant.style == "direct" else "style_reason.md")
    user = f"{_p('operator_brief.md')}\n\n{problem}\n\nTASK\n{style}\n\n{_p('output_format.md')}"
    return _p("llm_only_system.md"), user


def feedback_text(res: ValidationResult) -> str:
    lines = [f"- {e.message}" + (f" (step {e.step + 1})" if e.step is not None else "")
             for e in res.errors if e.severity != "info"]
    return "\n".join(lines) or "- (no rule violations)"


_ORACLE: dict[str, float | None] = {}


def oracle_cost(inst: Instance) -> float | None:
    if inst.id not in _ORACLE:
        _ORACLE[inst.id] = solve(inst).cost
    return _ORACLE[inst.id]


def _attempt(backend: Backend, system: str, msgs: list[dict], sample: int, usage: dict):
    """One model answer + at most one format retry. Returns (plan|None, reply_text, parse_error)."""
    reply = backend.chat(system, msgs, sample)
    _add_usage(usage, reply)
    if not reply.ok:
        return None, None, f"call_error: {reply.error}"
    try:
        return parse_plan_json(reply.text), reply.text, None
    except PlanParseError as e:
        usage["format_retries"] += 1
        msgs2 = msgs + [{"role": "assistant", "content": reply.text},
                        {"role": "user", "content": _p("format_retry.md").format(error=e)}]
        r2 = backend.chat(system, msgs2, sample)
        _add_usage(usage, r2)
        if not r2.ok:
            return None, reply.text, f"call_error: {r2.error}"
        try:
            return parse_plan_json(r2.text), r2.text, None
        except PlanParseError as e2:
            return None, r2.text, f"parse_error: {e2}"


def _add_usage(u: dict, r) -> None:
    u["calls"] += 1
    u["cached_calls"] += int(r.cached)
    for k in ("input_tokens", "output_tokens", "thinking_tokens", "cost_usd", "latency_s"):
        u[k] += getattr(r, k)


def run_one(inst: Instance, level: str, variant: Variant, model: str, sample: int = 0,
            render_seed: int = 0, probe: str = "none") -> dict:
    backend = make_backend(f"claude:{model}:{variant.effort}") if ":" not in model else make_backend(model)
    system, user = build_prompt(inst, level, variant, render_seed)
    usage = {"calls": 0, "cached_calls": 0, "input_tokens": 0, "output_tokens": 0, "thinking_tokens": 0,
             "cost_usd": 0.0, "latency_s": 0.0, "format_retries": 0}
    msgs = [{"role": "user", "content": user}]
    opt = oracle_cost(inst)
    rounds = []
    final_text = None
    for rnd in range(variant.repair_rounds + 1):
        plan, text, perr = _attempt(backend, system, msgs, sample, usage)
        final_text = text or final_text
        if plan is None:
            rounds.append({"round": rnd, "parse_ok": False, "error": perr})
            break
        res = validate(inst, plan)
        resolve = NameResolver(inst)
        rounds.append({"round": rnd, "parse_ok": True, "result": res.summary(),
                       "pickup_ids": [resolve(s.args[0]) for s in plan.steps if s.action == "pickup" and s.args],
                       "gap": (res.cost / opt - 1) if (res.valid and opt) else None,
                       "plan": {"steps": [[s.action, *s.args] for s in plan.steps],
                                "unreachable": plan.unreachable, "claimed_minutes": plan.claimed_minutes}})
        if res.valid or rnd == variant.repair_rounds:
            break
        msgs = msgs + [{"role": "assistant", "content": text},
                       {"role": "user", "content": _p("repair.md").format(feedback=feedback_text(res))}]

    last = rounds[-1]
    call_error = (not last["parse_ok"]) and last["error"].startswith("call_error")
    return {
        "instance": inst.id, "k": inst.meta.get("k"), "split": inst.meta.get("split"),
        "cut_off": bool(inst.meta.get("cut_off")), "capacity": inst.capacity,
        "capacity_mode": "tight" if inst.capacity else "unlimited",
        "level": "gold" if variant.input == "gold" else level, "variant": variant.name,
        "model": model, "effort": variant.effort, "sample": sample, "render_seed": render_seed, "probe": probe,
        "oracle_cost": opt, "rounds": rounds, "n_rounds": len(rounds), "call_error": call_error,
        "parse_ok": last["parse_ok"], "final": last.get("result"), "gap": last.get("gap"),
        "usage": usage, "final_text": final_text,
        "rescuable": {g: 0 for g in GROUPS} if not last.get("result") else last["result"]["rescuable"],
    }
