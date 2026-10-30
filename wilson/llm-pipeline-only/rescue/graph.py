"""Shortest paths and reachability over the post-flood road network."""
from __future__ import annotations

import heapq

from .schema import Instance


def adjacency(inst: Instance, open_only: bool = True) -> dict[str, dict[str, int]]:
    adj: dict[str, dict[str, int]] = {l.id: {} for l in inst.locations}
    for r in inst.roads:
        if open_only and not r.open:
            continue
        # Parallel roads: keep the faster one.
        w = min(r.minutes, adj[r.u].get(r.v, r.minutes))
        adj[r.u][r.v] = w
        adj[r.v][r.u] = w
    return adj


def dijkstra(adj: dict[str, dict[str, int]], src: str) -> tuple[dict[str, int], dict[str, str]]:
    dist = {src: 0}
    prev: dict[str, str] = {}
    pq = [(0, src)]
    while pq:
        d, u = heapq.heappop(pq)
        if d > dist.get(u, float("inf")):
            continue
        for v, w in adj[u].items():
            nd = d + w
            if nd < dist.get(v, float("inf")):
                dist[v] = nd
                prev[v] = u
                heapq.heappush(pq, (nd, v))
    return dist, prev


def path(prev: dict[str, str], src: str, dst: str) -> list[str]:
    out = [dst]
    while out[-1] != src:
        out.append(prev[out[-1]])
    return out[::-1]


def reachable(inst: Instance) -> set[str]:
    dist, _ = dijkstra(adjacency(inst), inst.start)
    return set(dist)


def stranded_reachable(inst: Instance) -> list[str]:
    """Occupied locations the team can actually reach (the goal set)."""
    r = reachable(inst)
    return [l for l in inst.occupied() if l in r]


def stranded_unreachable(inst: Instance) -> list[str]:
    r = reachable(inst)
    return [l for l in inst.occupied() if l not in r]
