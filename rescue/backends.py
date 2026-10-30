"""LLM backends with an on-disk response cache.

ClaudeCLI calls the frontier model through the Claude Code CLI in print mode with
ALL tools disabled, no settings/CLAUDE.md/hooks loaded, and a fixed system prompt,
so the model really is solving the problem "LLM-only" (no code execution).
Verified 2026-10-26: the model sees ~680 tokens of harness context (environment +
date) besides our prompts, and nothing else.

The cache makes runs resumable and reproducible: a response is stored under a hash
of (backend, model, effort, messages, sample index). It is NOT a fallback: a failed
call is recorded as a call error, never replaced by stale data.
"""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import threading
import time
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "results" / "cache"

# Environment variables that would reroute the CLI away from the subscription login.
_KEY_LOCKS: dict[str, threading.Lock] = {}
_KEY_LOCKS_GUARD = threading.Lock()

_STRIP_ENV = ["ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN", "ANTHROPIC_BASE_URL", "OPENAI_BASE_URL",
              "HEADROOM_PORT", "HEADROOM_HOST", "HEADROOM_MODE", "HEADROOM_BACKEND", "HEADROOM_TELEMETRY",
              "COPILOT_PROVIDER_TYPE", "COPILOT_PROVIDER_BASE_URL"]


@dataclass
class Reply:
    text: str
    ok: bool
    error: str | None = None
    latency_s: float = 0.0
    input_tokens: int = 0
    output_tokens: int = 0
    thinking_tokens: int = 0
    cost_usd: float = 0.0
    cached: bool = False
    raw: dict = field(default_factory=dict)


class Backend:
    name = "base"

    def __init__(self, model: str, effort: str | None = None):
        self.model, self.effort = model, effort

    @property
    def label(self) -> str:
        return f"{self.name}:{self.model}" + (f":{self.effort}" if self.effort else "")

    def _key(self, system: str, messages: list[dict], sample: int) -> str:
        blob = json.dumps([self.name, self.model, self.effort, system, messages, sample], sort_keys=True)
        return hashlib.sha256(blob.encode()).hexdigest()[:24]

    def chat(self, system: str, messages: list[dict], sample: int = 0, retries: int = 3) -> Reply:
        CACHE.mkdir(parents=True, exist_ok=True)
        key = self._key(system, messages, sample)
        with _KEY_LOCKS_GUARD:
            lock = _KEY_LOCKS.setdefault(key, threading.Lock())
        with lock:  # identical concurrent requests (nl-reason / nl-repair round 0) share one call
            return self._chat_locked(key, system, messages, sample, retries)

    def _chat_locked(self, key: str, system: str, messages: list[dict], sample: int, retries: int) -> Reply:
        path = CACHE / f"{key}.json"
        if path.exists():
            d = json.loads(path.read_text())
            return Reply(**{**d["reply"], "cached": True})
        reply = Reply("", False, "not attempted")
        for attempt in range(retries):
            reply = self._call(system, messages)
            if reply.ok:
                break
            time.sleep(10 * (attempt + 1))
        if reply.ok:  # only successful calls are cached
            path.write_text(json.dumps({"backend": self.label, "system": system, "messages": messages,
                                        "sample": sample, "reply": {**reply.__dict__, "cached": False}}, indent=1))
        return reply

    def _call(self, system: str, messages: list[dict]) -> Reply:
        raise NotImplementedError


def _flatten(messages: list[dict]) -> str:
    """Single-shot rendering of a multi-turn exchange (the CLI is stateless here)."""
    if len(messages) == 1:
        return messages[0]["content"]
    parts = []
    for m in messages:
        tag = "YOUR PREVIOUS ANSWER" if m["role"] == "assistant" else "USER"
        parts.append(f"=== {tag} ===\n{m['content']}")
    return "\n\n".join(parts)


class ClaudeCLI(Backend):
    name = "claude-cli"
    binary = shutil.which("claude") or "/opt/homebrew/bin/claude"

    def _call(self, system: str, messages: list[dict]) -> Reply:
        env = {k: v for k, v in os.environ.items() if k not in _STRIP_ENV}
        cmd = [self.binary, "-p", "--model", self.model, "--tools", "", "--setting-sources", "",
               "--no-session-persistence", "--output-format", "json", "--system-prompt", system]
        if self.effort:
            cmd += ["--effort", self.effort]
        t0 = time.perf_counter()
        with tempfile.TemporaryDirectory() as cwd:  # empty dir: no project CLAUDE.md
            try:
                p = subprocess.run(cmd, input=_flatten(messages), capture_output=True, text=True,
                                   cwd=cwd, env=env, timeout=900)
            except subprocess.TimeoutExpired:
                return Reply("", False, "timeout", time.perf_counter() - t0)
        dt = time.perf_counter() - t0
        try:
            d = json.loads(p.stdout)
        except json.JSONDecodeError:
            return Reply("", False, f"exit {p.returncode}: {(p.stderr or p.stdout)[:300]}", dt)
        if d.get("is_error") or p.returncode != 0:
            return Reply(d.get("result", ""), False, f"cli error: {str(d.get('result'))[:300]}", dt, raw=d)
        u = d.get("usage", {}) or {}
        return Reply(
            text=d.get("result", ""), ok=True, latency_s=dt,
            input_tokens=(u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
                          + u.get("cache_read_input_tokens", 0)),
            output_tokens=u.get("output_tokens", 0),
            thinking_tokens=(u.get("output_tokens_details") or {}).get("thinking_tokens", 0),
            cost_usd=d.get("total_cost_usd", 0.0) or 0.0,
            raw={k: d.get(k) for k in ("session_id", "duration_ms", "num_turns", "modelUsage")},
        )


class Ollama(Backend):
    """Open-weight models served locally (`ollama serve`); optional comparison."""
    name = "ollama"
    url = "http://localhost:11434/api/chat"

    def _call(self, system: str, messages: list[dict]) -> Reply:
        body = json.dumps({"model": self.model, "stream": False, "options": {"temperature": 0.7},
                           "messages": [{"role": "system", "content": system}, *messages]}).encode()
        t0 = time.perf_counter()
        try:
            with urllib.request.urlopen(urllib.request.Request(self.url, body, {"Content-Type": "application/json"}),
                                        timeout=900) as r:
                d = json.loads(r.read())
        except Exception as e:  # noqa: BLE001 - surface any transport error as a call error
            return Reply("", False, f"ollama: {e}", time.perf_counter() - t0)
        return Reply(d["message"]["content"], True, latency_s=time.perf_counter() - t0,
                     input_tokens=d.get("prompt_eval_count", 0), output_tokens=d.get("eval_count", 0))


def make_backend(spec: str) -> Backend:
    """'claude:<model>[:effort]' or 'ollama:<model>'."""
    kind, _, rest = spec.partition(":")
    model, _, effort = rest.partition(":")
    if kind == "claude":
        return ClaudeCLI(model, effort or None)
    if kind == "ollama":
        return Ollama(model)
    raise ValueError(f"unknown backend {spec}")
