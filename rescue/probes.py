"""Invariance probes: transformations that must NOT change the correct answer.

  paraphrase   same instance, report rendered with another seed (different wording and
               sentence order). A reliable planner's validity should not depend on it.
  rename       the instance's place names permuted among its locations. Same vocabulary,
               different roles: detects reliance on name priors (e.g. "knowing" real
               Nepali geography) rather than on the reports.
Both give a consistency measure for the TA's question about whether priority decisions are
made "appropriately and consistently".
"""
from __future__ import annotations

import random

from .schema import Instance, Location


def rename(inst: Instance, seed: int = 1) -> Instance:
    rng = random.Random(f"rename-{inst.id}-{seed}")
    names = [l.name for l in inst.locations]
    perm = names[:]
    while perm == names:
        rng.shuffle(perm)
    d = inst.to_dict()
    out = Instance.from_dict(d)
    out.locations = [Location(l.id, n, l.kind) for l, n in zip(inst.locations, perm)]
    out.id = f"{inst.id}-rn{seed}"
    out.meta = {**inst.meta, "probe": f"rename{seed}", "base_instance": inst.id}
    return out
