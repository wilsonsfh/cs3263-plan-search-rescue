(define (problem flood-rescue-small-10)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    tarkeshwar-shelter benighat-care-home thakre-care-home kalika-farm dhunche-school - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; roads (both directions), all open
    (road tarkeshwar-shelter benighat-care-home)
    (road benighat-care-home tarkeshwar-shelter)
    (road tarkeshwar-shelter thakre-care-home)
    (road thakre-care-home tarkeshwar-shelter)
    (road tarkeshwar-shelter kalika-farm)
    (road kalika-farm tarkeshwar-shelter)
    (road benighat-care-home dhunche-school)
    (road dhunche-school benighat-care-home)
    (road benighat-care-home kalika-farm)
    (road kalika-farm benighat-care-home)
    (road thakre-care-home dhunche-school)
    (road dhunche-school thakre-care-home)

    ;; travel times
    (= (travel-time tarkeshwar-shelter benighat-care-home) 6)
    (= (travel-time benighat-care-home tarkeshwar-shelter) 6)
    (= (travel-time tarkeshwar-shelter thakre-care-home) 36)
    (= (travel-time thakre-care-home tarkeshwar-shelter) 36)
    (= (travel-time tarkeshwar-shelter kalika-farm) 19)
    (= (travel-time kalika-farm tarkeshwar-shelter) 19)
    (= (travel-time benighat-care-home dhunche-school) 52)
    (= (travel-time dhunche-school benighat-care-home) 52)
    (= (travel-time benighat-care-home kalika-farm) 22)
    (= (travel-time kalika-farm benighat-care-home) 22)
    (= (travel-time thakre-care-home dhunche-school) 30)
    (= (travel-time dhunche-school thakre-care-home) 30)

    ;; evacuation points
    (evac-point tarkeshwar-shelter)

    ;; car
    (car-at car1 tarkeshwar-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; people waiting
    (waiting thakre-care-home elderly n2)
    (waiting benighat-care-home elderly n2)
    (waiting dhunche-school child n2)

    ;; arithmetic support: (sum a b c) means a + b = c, for levels up to n4
    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n1 n0 n1)
    (sum n0 n2 n2)
    (sum n2 n0 n2)
    (sum n0 n3 n3)
    (sum n3 n0 n3)
    (sum n0 n4 n4)
    (sum n4 n0 n4)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n2 n1 n3)
    (sum n1 n3 n4)
    (sum n3 n1 n4)
    (sum n2 n2 n4)

    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

    ;; deferral penalties: per-person penalty x N
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)

    (= (total-cost) 0)
  )

  (:goal
    (and
      (waiting thakre-care-home elderly n0)
      (waiting benighat-care-home elderly n0)
      (waiting dhunche-school child n0)
      (carrying car1 injured n0)
      (carrying car1 child n0)
      (carrying car1 elderly n0)
      (carrying car1 adult n0)
    )
  )

  (:metric minimize (total-cost))
)
