"""Pipeline control flow with a scripted fake model (no network)."""
import json

import pytest

from rescue import llm_only
from rescue.backends import Reply
from rescue.validator import plan_to_obj

from .test_oracle_validator import OPTIMAL

GOOD = "```json\n" + json.dumps(plan_to_obj(OPTIMAL)) + "\n```"
BLOCKED = '```json\n{"steps":[{"action":"move","from":"Bidur Base","to":"Dhunche"}],"unreachable":[],"claimed_total_minutes":5}\n```'


class Scripted:
    def __init__(self, replies):
        self.replies, self.seen = list(replies), []

    def chat(self, system, messages, sample=0):
        self.seen.append(messages)
        r = self.replies.pop(0)
        return r if isinstance(r, Reply) else Reply(r, True, output_tokens=10)


@pytest.fixture
def fake(monkeypatch):
    def install(replies):
        s = Scripted(replies)
        monkeypatch.setattr(llm_only, "make_backend", lambda spec: s)
        llm_only._ORACLE.clear()
        return s
    return install


def run(tiny, variant):
    return llm_only.run_one(tiny, "L2", llm_only.VARIANTS[variant], "fake-model")


def test_valid_first_time(tiny, fake):
    s = fake([GOOD])
    r = run(tiny, "nl-reason")
    assert r["final"]["valid"] and r["gap"] == 0 and r["n_rounds"] == 1 and len(s.seen) == 1


def test_format_retry_then_success(tiny, fake):
    s = fake(["I think we should go to Arughat first.", GOOD])
    r = run(tiny, "nl-reason")
    assert r["parse_ok"] and r["usage"]["format_retries"] == 1
    assert "could not be read" in s.seen[1][-1]["content"]


def test_parse_failure_after_retry_is_recorded_not_crashed(tiny, fake):
    fake(["no plan", "still no plan"])
    r = run(tiny, "nl-reason")
    assert not r["parse_ok"] and not r["call_error"] and r["final"] is None


def test_call_error_is_flagged(tiny, fake):
    fake([Reply("", False, "rate limited")])
    r = run(tiny, "nl-reason")
    assert r["call_error"]


def test_repair_feeds_validator_errors_back(tiny, fake):
    s = fake([BLOCKED, GOOD])
    r = run(tiny, "nl-repair")
    assert r["n_rounds"] == 2 and r["final"]["valid"]
    assert not r["rounds"][0]["result"]["valid"]
    fb = s.seen[1][-1]["content"]
    assert "impassable" in fb and s.seen[1][-2]["role"] == "assistant"


def test_repair_stops_after_two_rounds(tiny, fake):
    fake([BLOCKED, BLOCKED, BLOCKED])
    r = run(tiny, "nl-repair")
    assert r["n_rounds"] == 3 and not r["final"]["valid"]


def test_no_repair_for_nl_reason(tiny, fake):
    fake([BLOCKED])
    r = run(tiny, "nl-reason")
    assert r["n_rounds"] == 1 and not r["final"]["valid"]


def test_prompt_contains_shared_brief_and_no_ground_truth(tiny):
    _, user = llm_only.build_prompt(tiny, "L2", llm_only.VARIANTS["nl-reason"])
    brief = (llm_only.PROMPTS / "operator_brief.md").read_text().strip()
    assert brief in user
    assert '"open": false' not in user and "BLOCKED" not in user  # L2 never states status keywords
    _, gold = llm_only.build_prompt(tiny, "L2", llm_only.VARIANTS["gold-reason"])
    assert '"status": "blocked"' in gold
