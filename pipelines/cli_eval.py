#!/usr/bin/env python3
"""Run pipelines/run_eval.py on a Claude subscription instead of an API key.

Every model request goes through `claude -p` with all tools turned off (--tools ""), no user or project
settings (--setting-sources ""), from an empty temp folder, so the model can only read the prompt and write text,
the same as a plain API call. Nothing in pipelines/ is changed: run_eval.py already accepts a stand-in client
(that is how --mock works), and this file passes one.

Usage, from the repo root (takes every run_eval.py option):
    .venv/bin/python pipelines/cli_eval.py --pipelines direct --sizes small --limit 2 --tag pilot-direct

Differences from the API route, to state in the report:
- Claude Code adds a short fixed preamble (~700 input tokens), counted in input_tokens.
- A repair round resends the whole conversation as one prompt; thinking from earlier turns is not carried over.
Also records wall-clock seconds per run in usage["seconds"] (run_eval.py does not time calls).
"""

import contextlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).resolve().parent))  # run_eval.py and pipelines.py sit next to this file
import pipelines  # noqa: E402
import run_eval  # noqa: E402

CLAUDE = shutil.which("claude") or "/opt/homebrew/bin/claude"
# Unset anything that would route the CLI to an API key or a proxy instead of the subscription.
STRIP_ENV = {"ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN", "ANTHROPIC_BASE_URL", "OPENAI_BASE_URL"}


def _text(content):
    if isinstance(content, str):
        return content
    return "".join(b.text for b in content if getattr(b, "type", "") == "text")


def _flatten(messages):
    """The CLI call is stateless, so a multi-turn exchange is sent as one prompt."""
    if len(messages) == 1:
        return _text(messages[0]["content"])
    tag = {"assistant": "YOUR PREVIOUS ANSWER", "user": "USER"}
    return "\n\n".join(f"=== {tag[m['role']]} ===\n{_text(m['content'])}" for m in messages)


class CLIClient:
    """Stands in for anthropic.Anthropic(); pipelines.Claude only calls client.messages.stream(...)."""

    def __init__(self):
        self.messages = self

    def stream(self, model, system, messages, output_config, **_):
        cmd = [CLAUDE, "-p", "--model", model, "--effort", output_config["effort"],
               "--tools", "", "--setting-sources", "", "--no-session-persistence",
               "--output-format", "json", "--system-prompt", system]
        env = {k: v for k, v in os.environ.items() if k not in STRIP_ENV}
        with tempfile.TemporaryDirectory() as cwd:  # empty folder: no project files or CLAUDE.md
            p = subprocess.run(cmd, input=_flatten(messages), capture_output=True, text=True,
                               cwd=cwd, env=env, timeout=1800)
        d = json.loads(p.stdout)  # a crash here is recorded by run_eval as ERROR and the batch moves on
        if p.returncode or d.get("is_error"):
            raise RuntimeError(f"claude -p failed: {str(d.get('result'))[:300]}")
        u = d.get("usage") or {}
        msg = SimpleNamespace(
            content=[SimpleNamespace(type="text", text=d.get("result", ""))],
            stop_reason=d.get("stop_reason") or "end_turn",
            usage=SimpleNamespace(
                input_tokens=u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
                + u.get("cache_read_input_tokens", 0),
                output_tokens=u.get("output_tokens", 0)))
        return contextlib.nullcontext(SimpleNamespace(get_final_message=lambda: msg))


class TimedClaude(pipelines.Claude):
    """pipelines.Claude that also adds up wall-clock seconds; run_eval saves usage (incl. seconds) per run."""

    def ask(self, system, messages):
        t0 = time.perf_counter()
        try:
            return super().ask(system, messages)
        finally:
            self.usage["seconds"] = round(self.usage.get("seconds", 0) + time.perf_counter() - t0, 1)


# run_eval builds Claude(model, effort, client=mock_or_None); give it the CLI client when there is no mock.
run_eval.Claude = lambda model, effort, client=None: TimedClaude(model, effort, client=client or CLIClient())

def require_subscription():
    """Stop unless the claude CLI is logged in with a claude.ai subscription, so nothing is billed to an API account."""
    p = subprocess.run([CLAUDE, "auth", "status"], capture_output=True, text=True)
    try:
        s = json.loads(p.stdout)
    except json.JSONDecodeError:
        s = {}
    if not (s.get("loggedIn") and s.get("authMethod") == "claude.ai" and s.get("apiProvider") == "firstParty"):
        sys.exit(f"Refusing to run: claude is not logged in with a claude.ai subscription "
                 f"(authMethod={s.get('authMethod')}, apiProvider={s.get('apiProvider')}). Nothing was sent.")
    print(f"OK: claude.ai {s.get('subscriptionType')} subscription, tools off, no API key.", file=sys.stderr)


if __name__ == "__main__":
    if "--mock" not in sys.argv:
        require_subscription()
    run_eval.main()
