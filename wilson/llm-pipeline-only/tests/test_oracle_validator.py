import dataclasses

from rescue.oracle import solve
from rescue.validator import Plan, Step, parse_plan_json, parse_pddl_plan, validate


def codes(res):
    return {e.code for e in res.errors}


def mv(a, b):
    return Step("move", (a, b))


OPTIMAL = Plan(
    steps=[
        mv("Bidur Base", "Arughat"),
        mv("Arughat", "Chautara"),
        Step("pickup", ("Chautara",)),
        mv("Chautara", "Arughat"),
        Step("pickup", ("Arughat",)),
        mv("Arughat", "Bidur Base"),
        Step("dropoff", ("Bidur Base",)),
    ],
    unreachable=["Khanigaun"],
    claimed_minutes=40,
)


# ---------------------------------------------------------------- oracle
def test_oracle_tiny_unlimited(tiny):
    r = solve(tiny)
    assert r.cost == 40
    assert validate(tiny, r.plan).valid


def test_oracle_capacity_forces_two_trips(tiny):
    tiny.capacity = 2
    r = solve(tiny)
    # B->A->C pick C (20), C->A->B drop (20), B->A pick A (10), A->B drop (10)
    assert r.cost == 60
    assert validate(tiny, r.plan).valid


def test_price_of_priority(tiny):
    # Make the priority constraint costly: injured far away on the slow road side.
    tiny.people = {"A": {"injured": 1}, "C": {"adults": 1}}
    tiny.roads = [r for r in tiny.roads if {r.u, r.v} != {"A", "C"}]  # A, C only via B
    with_p = solve(tiny).cost
    without_p = solve(tiny, priority="none").cost
    assert with_p >= without_p


def test_oracle_priority_changes_cost():
    from rescue.schema import Instance, Location, Road

    # Line: B -- A(adults) -- C(injured). Tiered: must reach C first, passing A.
    inst = Instance(
        id="line",
        locations=[Location("B", "B", "base"), Location("A", "A", "village"), Location("C", "C", "village")],
        roads=[Road("B", "A", 10), Road("A", "C", 10)],
        people={"A": {"adults": 3}, "C": {"injured": 3}},
        start="B",
        shelter="B",
        capacity=3,
    )
    # tiered: B->A->C pick C, C->A->B drop (40), B->A pick, A->B drop (20) = 60
    # none:   same structure (capacity forces 2 trips), also 60
    assert solve(inst).cost == 60
    # Unlimited capacity, tiered: B->A->C pick C, C->A pick A, A->B = 40
    inst.capacity = None
    assert solve(inst).cost == 40


# ------------------------------------------------------------- validator
def test_validator_accepts_optimal(tiny):
    res = validate(tiny, OPTIMAL)
    assert res.valid and res.executable and res.complete and res.priority_ok
    assert res.cost == 40 and res.claimed_cost_error == 0
    assert res.coverage == 1.0
    assert res.errors == []


def test_names_are_case_and_punctuation_insensitive(tiny):
    p = dataclasses.replace(OPTIMAL, steps=[Step(s.action, tuple(a.upper() + "." for a in s.args)) for s in OPTIMAL.steps])
    assert validate(tiny, p).valid


def test_blocked_road(tiny):
    p = Plan([mv("Bidur Base", "Dhunche")], [], None)
    res = validate(tiny, p)
    assert "BLOCKED_ROAD" in codes(res) and not res.executable


def test_nonexistent_road(tiny):
    p = Plan([mv("Bidur Base", "Khanigaun")], [], None)
    assert "NO_ROAD" in codes(validate(tiny, p))


def test_teleport(tiny):
    p = Plan([mv("Arughat", "Chautara")], [], None)  # team is at B
    assert "WRONG_ORIGIN" in codes(validate(tiny, p))


def test_unknown_location(tiny):
    p = Plan([mv("Bidur Base", "Kathmandu")], [], None)
    assert "UNKNOWN_LOCATION" in codes(validate(tiny, p))


def test_priority_violation(tiny):
    p = Plan(
        [mv("Bidur Base", "Arughat"), Step("pickup", ("Arughat",)), mv("Arughat", "Chautara"),
         Step("pickup", ("Chautara",)), mv("Chautara", "Bidur Base"), Step("dropoff", ("Bidur Base",))],
        ["Khanigaun"], 50,
    )
    res = validate(tiny, p)
    assert res.executable and res.complete and not res.priority_ok and not res.valid
    assert "PRIORITY" in codes(res)


def test_capacity_violation(tiny):
    tiny.capacity = 2
    res = validate(tiny, OPTIMAL)
    assert "CAPACITY" in codes(res) and not res.executable


def test_incomplete_no_dropoff(tiny):
    p = dataclasses.replace(OPTIMAL, steps=OPTIMAL.steps[:-1])
    res = validate(tiny, p)
    assert res.executable and not res.complete and res.coverage == 0.0
    assert "NOT_DELIVERED" in codes(res)


def test_false_unreachable_claim(tiny):
    p = Plan([], ["Chautara", "Arughat", "Khanigaun"], 0)
    res = validate(tiny, p)
    assert "FALSE_UNREACHABLE" in codes(res) and not res.valid


def test_missed_unreachable_report_is_minor(tiny):
    p = dataclasses.replace(OPTIMAL, unreachable=[])
    res = validate(tiny, p)
    assert "UNREPORTED_UNREACHABLE" in codes(res)
    assert res.valid  # informational, the rescue itself is correct


def test_claimed_cost_mismatch(tiny):
    p = dataclasses.replace(OPTIMAL, claimed_minutes=35)
    res = validate(tiny, p)
    assert res.claimed_cost_error == -5 and res.valid


def test_coverage_counts_only_before_first_physical_error(tiny):
    p = Plan(
        [mv("Bidur Base", "Arughat"), mv("Arughat", "Chautara"), Step("pickup", ("Chautara",)),
         mv("Chautara", "Bidur Base"), Step("dropoff", ("Bidur Base",)),
         mv("Bidur Base", "Dhunche")],  # blocked after first delivery
        [], None,
    )
    res = validate(tiny, p)
    assert not res.executable
    assert res.delivered == {"injured": 1, "children": 0, "elderly": 0, "adults": 1}


def test_wait_times_recorded(tiny):
    res = validate(tiny, OPTIMAL)
    # C picked at t=20, A at t=30; everyone delivered at t=40
    assert res.pickup_minutes_by_group["injured"] == [20]
    assert sorted(res.pickup_minutes_by_group["adults"]) == [20, 30, 30]


# ---------------------------------------------------------------- parsing
def test_parse_plan_json_from_fenced_block():
    text = 'Reasoning...\n```json\n{"steps":[{"action":"move","from":"A","to":"B"},{"action":"pickup","location":"B"},{"action":"dropoff","location":"A"}],"unreachable":["X"],"claimed_total_minutes":12}\n```'
    p = parse_plan_json(text)
    assert p.steps == [Step("move", ("A", "B")), Step("pickup", ("B",)), Step("dropoff", ("A",))]
    assert p.unreachable == ["X"] and p.claimed_minutes == 12


def test_parse_plan_json_bare_object_with_trailing_text():
    text = 'Here: {"steps": [], "unreachable": [], "claimed_total_minutes": 0} hope this helps {x}'
    assert parse_plan_json(text).steps == []


def test_parse_pddl_plan(tiny):
    text = "(move team b a)\n(move team a c)\n(pickup team c)\n(move team c a)\n(pickup team a)\n(move team a b)\n(dropoff team b)\n; cost = 40 (general cost)"
    p = parse_pddl_plan(text)
    res = validate(tiny, p)
    assert res.valid and res.cost == 40
