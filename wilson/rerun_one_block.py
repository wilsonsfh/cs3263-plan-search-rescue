#!/usr/bin/env python3
"""Rerun chosen cases through pipelines/cli_eval.py with one extra prompt line: "exactly one <plan> block".

pipelines/ is not edited: this patches pipelines.DIRECT_INSTRUCTIONS in memory, then hands over to cli_eval.
Takes every cli_eval.py option. Usage, from the repo root:
    .venv/bin/python wilson/rerun_one_block.py --pipelines direct --ids large-09 --levels explicit \
        --model claude-opus-5-5 --tag run1-patch-opus
Output goes to pipelines/runs/<tag>/. The two run 1 reruns were copied from there into pipelines/runs/main and
main-haiku, replacing the originals (see wilson/main_run_results.md section 13).
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "pipelines"))
import pipelines  # noqa: E402

ONE_BLOCK = ('\nGive exactly one <plan></plan> block in your answer. Do not write a second plan block, '
             'even as a correction or a contingency.')
pipelines.DIRECT_INSTRUCTIONS += ONE_BLOCK

import cli_eval  # noqa: E402

if __name__ == "__main__":
    if "--mock" not in sys.argv:
        cli_eval.require_subscription()
    cli_eval.run_eval.main()
