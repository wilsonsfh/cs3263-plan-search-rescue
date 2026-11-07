(define (problem small-06)
  (:domain flood-rescue)
  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    galchhi-shelter nilkantha-market gosaikunda-farm panchakanya-school dhunche-farm jwalamukhi-farm - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Evacuation points
    (evac-point galchhi-shelter)

    ;; Cars
    (car-at car1 galchhi-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; Roads: nilkantha-market <-> gosaikunda-farm (23 min)
    (road nilkantha-market gosaikunda-farm)
    (= (travel-time nilkantha-market gosaikunda-farm) 23)
    (road gosaikunda-farm nilkantha-market)
    (= (travel-time gosaikunda-farm nilkantha-market) 23)

    ;; Roads: panchakanya-school <-> gosaikunda-farm (29 min)
    (road panchakanya-school gosaikunda-farm)
    (= (travel-time panchakanya-school gosaikunda-farm) 29)
    (road gosaikunda-farm panchakanya-school)
    (= (travel-time gosaikunda-farm panchakanya-school) 29)

    ;; Roads: galchhi-shelter <-> gosaikunda-farm (24 min)
    (road galchhi-shelter gosaikunda-farm)
    (= (travel-time galchhi-shelter gosaikunda-farm) 24)
    (road gosaikunda-farm galchhi-shelter)
    (= (travel-time gosaikunda-farm galchhi-shelter) 24)

    ;; Roads: galchhi-shelter <-> nilkantha-market (9 min)
    (road galchhi-shelter nilkantha-market)
    (= (travel-time galchhi-shelter nilkantha-market) 9)
    (road nilkantha-market galchhi-shelter)
    (= (travel-time nilkantha-market galchhi-shelter) 9)

    ;; Roads: galchhi-shelter <-> dhunche-farm (23 min)
    (road galchhi-shelter dhunche-farm)
    (= (travel-time galchhi-shelter dhunche-farm) 23)
    (road dhunche-farm galchhi-shelter)
    (= (travel-time dhunche-farm galchhi-shelter) 23)

    ;; Roads: dhunche-farm <-> gosaikunda-farm (29 min)
    (road dhunche-farm gosaikunda-farm)
    (= (travel-time dhunche-farm gosaikunda-farm) 29)
    (road gosaikunda-farm dhunche-farm)
    (= (travel-time gosaikunda-farm dhunche-farm) 29)

    ;; Roads: jwalamukhi-farm <-> gosaikunda-farm (18 min normally, bridge washed away)
    (road jwalamukhi-farm gosaikunda-farm)
    (= (travel-time jwalamukhi-farm gosaikunda-farm) 18)
    (damaged jwalamukhi-farm gosaikunda-farm)
    (road gosaikunda-farm jwalamukhi-farm)
    (= (travel-time gosaikunda-farm jwalamukhi-farm) 18)
    (damaged gosaikunda-farm jwalamukhi-farm)

    ;; Waiting civilians
    (waiting gosaikunda-farm injured n3)
    (waiting gosaikunda-farm adult n3)
    (waiting nilkantha-market adult n3)

    ;; Level arithmetic: (sum a b c) means a + b = c
    (sum n0 n0 n0)
    (sum n0 n1 n1) (sum n1 n0 n1)
    (sum n0 n2 n2) (sum n2 n0 n2)
    (sum n0 n3 n3) (sum n3 n0 n3)
    (sum n0 n4 n4) (sum n4 n0 n4)
    (sum n1 n1 n2)
    (sum n1 n2 n3) (sum n2 n1 n3)
    (sum n1 n3 n4) (sum n3 n1 n4)
    (sum n2 n2 n4)

    ;; Positive levels
    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; Deferral penalties: injured 80, child 60, elderly 50, adult 20 per person
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
    (waiting gosaikunda-farm injured n0)
    (waiting gosaikunda-farm adult n0)
    (waiting nilkantha-market adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
