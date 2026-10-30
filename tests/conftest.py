import pytest

from rescue.schema import Instance, Location, Road


@pytest.fixture
def tiny() -> Instance:
    """Hand-checkable instance.

        B --10-- A --10-- C        B = base and shelter
        |                 |        B--C 30 (open, slow)
        +------30---------+        B--D 5 (BLOCKED)
        B --5x-- D                 C--X 10 (BLOCKED) -> X is unreachable
                 C --10x-- X

    A: 2 adults (tier 3). C: 1 injured + 1 adult (tier 1). X: 2 children.
    Unlimited capacity, tiered priority: C must be picked up before A.
    Optimum: B->A->C pickup C, C->A pickup A, A->B dropoff = 40 min.
    """
    return Instance(
        id="tiny",
        locations=[
            Location("B", "Bidur Base", "base"),
            Location("A", "Arughat", "village"),
            Location("C", "Chautara", "health_post"),
            Location("D", "Dhunche", "junction"),
            Location("X", "Khanigaun", "village"),
        ],
        roads=[
            Road("B", "A", 10),
            Road("A", "C", 10),
            Road("B", "C", 30),
            Road("B", "D", 5, open=False, cause="landslide"),
            Road("C", "X", 10, open=False, cause="bridge"),
        ],
        people={"A": {"adults": 2}, "C": {"injured": 1, "adults": 1}, "X": {"children": 2}},
        start="B",
        shelter="B",
    )
