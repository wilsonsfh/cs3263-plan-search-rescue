(define (problem small-14)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    tarkeshwar-shelter myagang-temple shivapuri-farm gosaikunda-village benighat-farm tadi-farm - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions), with travel times in minutes
    (road tarkeshwar-shelter myagang-temple)
    (road myagang-temple tarkeshwar-shelter)
    (= (travel-time tarkeshwar-shelter myagang-temple) 20)
    (= (travel-time myagang-temple tarkeshwar-shelter) 20)

    (road shivapuri-farm myagang-temple)
    (road myagang-temple shivapuri-farm)
    (= (travel-time shivapuri-farm myagang-temple) 19)
    (= (travel-time myagang-temple shivapuri-farm) 19)

    (road tadi-farm myagang-temple)
    (road myagang-temple tadi-farm)
    (= (travel-time tadi-farm myagang-temple) 22)
    (= (travel-time myagang-temple tadi-farm) 22)

    (road benighat-farm myagang-temple)
    (road myagang-temple benighat-farm)
    (= (travel-time benighat-farm myagang-temple) 21)
    (= (travel-time myagang-temple benighat-farm) 21)

    (road gosaikunda-village tadi-farm)
    (road tadi-farm gosaikunda-village)
    (= (travel-time gosaikunda-village tadi-farm) 58)
    (= (travel-time tadi-farm gosaikunda-village) 58)

    ;; Closed: collapsed road
    (road shivapuri-farm gosaikunda-village)
    (road gosaikunda-village shivapuri-farm)
    (= (travel-time shivapuri-farm gosaikunda-village) 26)
    (= (travel-time gosaikunda-village shivapuri-farm) 26)
    (damaged shivapuri-farm gosaikunda-village)
    (damaged gosaikunda-village shivapuri-farm)

    ;; Closed: fast floodwater
    (road shivapuri-farm benighat-farm)
    (road benighat-farm shivapuri-farm)
    (= (travel-time shivapuri-farm benighat-farm) 24)
    (= (travel-time benighat-farm shivapuri-farm) 24)
    (damaged shivapuri-farm benighat-farm)
    (damaged benighat-farm shivapuri-farm)

    ;; Evacuation points
    (evac-point tarkeshwar-shelter)

    ;; Car
    (car-at car1 tarkeshwar-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting myagang-temple elderly n3)
    (waiting myagang-temple adult n3)
    (waiting tadi-farm adult n2)

    ;; Addition facts within n0 ... n4
    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n0 n2 n2)
    (sum n0 n3 n3)
    (sum n0 n4 n4)
    (sum n1 n0 n1)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n1 n3 n4)
    (sum n2 n0 n2)
    (sum n2 n1 n3)
    (sum n2 n2 n4)
    (sum n3 n0 n3)
    (sum n3 n1 n4)
    (sum n4 n0 n4)

    ;; Positive levels
    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

    ;; Deferral penalties: per-person penalty x N
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
  )

  (:goal (and
    (waiting myagang-temple elderly n0)
    (waiting myagang-temple adult n0)
    (waiting tadi-farm adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
