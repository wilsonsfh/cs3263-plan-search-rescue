# Flood-rescue PDDL domain and instances (Group 11)

## Files

| File | What it is |
|---|---|
| `domain.pddl` | The planning domain: `drive`, `load`, `unload`, `defer-rescue`. People are counted per location and age band and can be split across cars |
| `no-split/` | The earlier version where each group had to travel together, with its own problem files, plans and results, kept for comparison |
| `generate.py` | Makes random Nepal-inspired instances (`instances/<id>.json` + `.pddl`) |
| `best_reference.py` | Picks the cheaper of the splitting and no-split plans per instance (`results/best_reference.csv`, `instances/<id>.best-plan`); the pipelines score against this |
| `solve.py` | Solves every instance with Fast Downward, checks with VAL, writes `instances/<id>.plan` and `results/reference.csv` |
| `instances/` | Generated set: `small-01..15`, `medium-01..15`, `large-01..15` |

## Model in one paragraph

Cars drive along roads (travel time in minutes); damaged roads can't be used.
People wait at locations and are counted per band (injured, child, elderly, adult; about 10% of people are injured).
A car has 4 seats, can load any number of people that fits, and can only drop
people off at an evacuation point, so people at one location can be split
across cars or trips. Everyone must end up either rescued (delivered) or
deferred to a later rescue wave. Deferring costs a penalty per person
(injured 80, child 60, elderly 50, adult 20 minutes). The planner minimises total driving
time plus deferral penalties. This is the soft-goal-to-action-cost compilation
of Keyder & Geffner (2009). The plan ends once nobody is left waiting or in a
car; cars don't have to return.

## Instance sizes

| Size | Locations | Evac points | Cars | Groups generated | Damaged roads |
|---|---|---|---|---|---|
| small | 5-6 | 1 | 1 | 3-4 | ~15% |
| medium | 7-9 | 1-2 | 1-2 | 5-7 | ~20% |
| large | 10-14 | 2 | 2 | 8-12 | ~25% |

Settings live at the top of `generate.py` (`SIZES`, `PENALTY_PER_PERSON`, `CAR_SEATS`).
Instances are reproducible: the same size and seed always give the same instance.

The `.json` file is the ground truth for each instance. Use it to write the
field reports (Wilson), to check LLM-only plans, and to score results.

## Running it

Build Fast Downward and VAL once (needs cmake and g++):

```
git clone --depth 1 https://github.com/aibasel/downward.git
cmake -S downward/src -B downward/builds/release -DCMAKE_BUILD_TYPE=Release
cmake --build downward/builds/release -j8

git clone --depth 1 https://github.com/KCL-Planning/VAL.git
cmake -S VAL -B VAL/build -DCMAKE_BUILD_TYPE=Release
cmake --build VAL/build -j8
```

Then:

```
python3 generate.py                       # 3 sizes x 15 instances
export FD=downward/fast-downward.py VAL=VAL/build/bin/Validate
python3 solve.py --timeout 300 --jobs 4                    # main (splitting) version
(cd no-split && python3 generate.py)                      # no-split problem files from the same instances
python3 solve.py --domain no-split/domain.pddl --instances no-split/instances --timeout 120 --jobs 4
python3 best_reference.py                                 # best known plan per instance
```

`solve.py` tries two optimal searches (A* with LM-cut, then A* with
merge-and-shrink), 300 s each by default. If both run out of time it uses anytime LAMA
and marks the result `optimal=False`.

To rebuild the no-split comparison, use `no-split/domain.pddl` with the
problem files in `no-split/instances/` (made by `no-split/generate.py` from
the same JSON instances).

## Notes for the report

- People counts and seats use level objects `n0..nK` and a static `(sum a b c)`
  relation (a + b = c), because classical PDDL has no arithmetic in preconditions.
- Allowing splits gives cheaper plans than the no-split version on 7 of 45
  instances (up to about 10%), but optimal search gets much slower: no-split
  proves 15/15 medium and 7/15 large optimal, splitting 14/15 and 5/15 (300 s
  per search). That trade-off between model realism and solvability is worth a
  paragraph in the analysis.
- VAL treats `?before` and `?after` as keywords, so the domain avoids those names.
- Optimal search handles small instances instantly and most medium ones within
  300 s. Most large instances time out, which is a good point to make in the
  scaling analysis. For 9 large instances the best known plan comes from the
  no-split version (see `results/best_reference.csv`).
