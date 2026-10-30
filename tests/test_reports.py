"""The rendered reports must say exactly what the Instance says (fidelity tests)."""
import random
import re

import pytest

from rescue.generator import generate, suite
from rescue.reports import WORDS, describe_people, render
from rescue.schema import GROUPS

NUM = {w: i for i, w in enumerate(WORDS)} | {"a dozen": 12, "half a dozen": 6}


def _n(tok: str) -> int:
    return int(tok) if tok.isdigit() else NUM[tok]


N = r"(\d+|a dozen|half a dozen|" + "|".join(WORDS) + ")"


def parse_people(text: str) -> dict[str, int]:
    text = re.sub(r"\([^)]*\)", "", text)  # injured descriptors may mention children/elderly
    out = {g: 0 for g in GROUPS}
    if m := re.search(N + r" injured (person|people)", text):
        out["injured"] = _n(m.group(1))
    if re.search(r"\ba baby\b|\bone child\b|\bone schoolchild\b", text):
        out["children"] = 1
    elif m := re.search(N + r" (school)?children", text):
        out["children"] = _n(m.group(1))
    if re.search(r"an old man|one elderly resident|one senior citizen", text):
        out["elderly"] = 1
    elif "an elderly couple" in text:
        out["elderly"] = 2
    elif m := re.search(N + r" (elderly residents|senior citizens)", text):
        out["elderly"] = _n(m.group(1))
    if m := re.search(N + r" (other |able-bodied |uninjured )?adults?\b", text):
        out["adults"] = _n(m.group(1))
    return out


def test_describe_people_round_trip():
    rng = random.Random(1)
    for _ in range(500):
        p = {g: rng.choice([0, 0, 1, 2, 3, 6, 12]) for g in GROUPS}
        p["injured"] = min(p["injured"], 3)
        if not sum(p.values()):
            p["adults"] = 1
        got = parse_people(describe_people(p, rng))
        assert got == {g: p.get(g, 0) for g in GROUPS}


def parse_l1(text: str):
    blocked, times, people = set(), {}, {}
    for line in text.splitlines():
        if m := re.match(r"- (.+)\u2013(.+): BLOCKED", line):
            blocked.add(frozenset(m.groups()))
        elif m := re.match(r"- (.+)\u2013(.+): open, travel time now (\d+) min", line):
            times[frozenset(m.groups()[:2])] = int(m.group(3))
        elif m := re.match(r"- ([^:\u2013]+): (\d+) injured, (\d+) children, (\d+) elderly, (\d+) adults", line):
            people[m.group(1)] = dict(zip(GROUPS, map(int, m.groups()[1:])))
    return blocked, times, people


@pytest.mark.parametrize("inst", suite(), ids=lambda i: i.id)
def test_l1_round_trip(inst):
    blocked, times, people = parse_l1(render(inst, "L1").reports)
    name = inst.name_of
    assert blocked == {frozenset((name(r.u), name(r.v))) for r in inst.roads if not r.open}
    for r in inst.roads:
        if r.open and r.base_minutes is not None:
            assert times[frozenset((name(r.u), name(r.v)))] == r.minutes
    assert people == {name(l): {g: inst.people[l].get(g, 0) for g in GROUPS} for l in inst.occupied()}


@pytest.mark.parametrize("level", ["L2", "L3"])
@pytest.mark.parametrize("inst", suite(), ids=lambda i: i.id)
def test_every_change_is_mentioned(inst, level):
    text = render(inst, level).reports
    sentences = re.split(r"(?<=[.:])\s+", text)
    for r in inst.roads:
        changed = (not r.open) or r.base_minutes is not None or r.history
        if changed:
            a, b = inst.name_of(r.u), inst.name_of(r.v)
            assert any(a in s and b in s for s in sentences), f"{a}-{b} not described"
    for l in inst.occupied():
        assert inst.name_of(l) in text


@pytest.mark.parametrize("inst", suite(), ids=lambda i: i.id)
def test_l3_final_statements_come_from_latest_dispatch(inst):
    text = render(inst, "L3").reports
    blocks = dict(re.findall(r"^\[(\d\d:\d\d)\] (.*)$", text, flags=re.M))
    latest = blocks[max(blocks)]
    late_sentences = re.split(r"(?<=[.:])\s+", latest)
    for r in inst.roads:
        a, b = inst.name_of(r.u), inst.name_of(r.v)
        if r.history:  # contested facts must be settled in the latest dispatch
            assert any(a in s and b in s for s in late_sentences), f"{a}-{b} not settled last"
    # Every unconfirmed estimate is superseded by a confirmed headcount later.
    for m in re.finditer(r"stranded in (\w+) \(unconfirmed estimate\)", text):
        assert f"Confirmed headcount" in latest and m.group(1) in latest


def test_generator_is_deterministic():
    a, b = generate(7, 3), generate(7, 3)
    assert a.to_dict() == b.to_dict()
    assert render(a, "L3").text == render(b, "L3").text
