"""Canonical problem instance: the single source of ground truth.

Every pipeline (LLM-only, LLM->PDDL->planner) is scored against this object.
The natural-language field reports are *rendered from* it, so the gold facts
behind every sentence are known exactly.

Formal model (see docs/llm_only_method.md for the write-up):

    G = (V, E, w, open)       road network, w(e) = travel minutes, open(e) in {T, F}
    n(l, g)                   civilians of vulnerability group g at location l
    s0 in V                   team start (the evacuation point / base)
    S in V                    shelter where evacuees are delivered
    C in N or infinity        vehicle capacity (people on board)

    Actions  move(a, b)       a,b adjacent by an *open* road; cost w(a, b)
             pickup(l)        team at l; takes EVERYONE at l (no splitting);
                              load + n(l) <= C; tier constraint (below); cost 0
             dropoff(S)       team at S; load -> 0; cost 0

    Tier     tier(l) = 1 if any injured, 2 if any children/elderly, 3 otherwise.
             pickup(l) is allowed only when every *reachable* location with a
             strictly smaller tier has already been picked up.
    Goal     every civilian at a location reachable from s0 via open roads is
             delivered to S; unreachable locations are reported, not visited.
    Cost     total travel minutes (minimised subject to the tier constraint).
"""
from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path

GROUPS: tuple[str, ...] = ("injured", "children", "elderly", "adults")


@dataclass(frozen=True)
class Location:
    id: str
    name: str
    kind: str  # base | village | school | health_post | temple | junction ...


@dataclass(frozen=True)
class Road:
    u: str
    v: str
    minutes: int  # post-flood travel time (what the plan is charged)
    open: bool = True
    # Rendering hints for the report generator; never used for scoring.
    base_minutes: int | None = None  # pre-flood time if the flood changed it
    cause: str | None = None  # landslide | bridge | submerged | debris ...
    history: tuple[str, ...] = ()  # e.g. ("blocked", "cleared") for L3 updates

    def key(self) -> frozenset[str]:
        return frozenset((self.u, self.v))


@dataclass
class Instance:
    id: str
    locations: list[Location]
    roads: list[Road]
    people: dict[str, dict[str, int]]  # location id -> group -> count
    start: str
    shelter: str
    capacity: int | None = None  # None = unlimited
    priority: str = "tiered"  # tiered | none
    meta: dict = field(default_factory=dict)  # seed, size, level, split ...

    # ---- lookups -------------------------------------------------------
    def loc(self, loc_id: str) -> Location:
        return self._by_id()[loc_id]

    def _by_id(self) -> dict[str, Location]:
        return {l.id: l for l in self.locations}

    def name_of(self, loc_id: str) -> str:
        return self.loc(loc_id).name

    def headcount(self, loc_id: str) -> int:
        return sum(self.people.get(loc_id, {}).values())

    def tier(self, loc_id: str) -> int | None:
        p = self.people.get(loc_id, {})
        if p.get("injured", 0) > 0:
            return 1
        if p.get("children", 0) + p.get("elderly", 0) > 0:
            return 2
        if p.get("adults", 0) > 0:
            return 3
        return None

    def occupied(self) -> list[str]:
        return [l.id for l in self.locations if self.headcount(l.id) > 0]

    # ---- (de)serialisation --------------------------------------------
    def to_dict(self) -> dict:
        d = asdict(self)
        for r in d["roads"]:
            r["history"] = list(r["history"])
        return d

    @classmethod
    def from_dict(cls, d: dict) -> "Instance":
        return cls(
            id=d["id"],
            locations=[Location(**l) for l in d["locations"]],
            roads=[Road(**{**r, "history": tuple(r.get("history", ()))}) for r in d["roads"]],
            people={k: dict(v) for k, v in d["people"].items()},
            start=d["start"],
            shelter=d["shelter"],
            capacity=d.get("capacity"),
            priority=d.get("priority", "tiered"),
            meta=d.get("meta", {}),
        )

    def save(self, path: Path) -> None:
        path.write_text(json.dumps(self.to_dict(), indent=2))

    @classmethod
    def load(cls, path: Path) -> "Instance":
        return cls.from_dict(json.loads(Path(path).read_text()))
