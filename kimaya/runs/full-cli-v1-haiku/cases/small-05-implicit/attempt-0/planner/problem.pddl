(define (problem flood-rescue-small-05)
  (:domain flood-rescue)
  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    shivapuri-shelter likhu-market myagang-care-home dhunche-temple galchhi-school - location
    car1 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions), with travel times in minutes
    (road shivapuri-shelter likhu-market)
    (road likhu-market shivapuri-shelter)
    (= (travel-time shivapuri-shelter likhu-market) 23)
    (= (travel-time likhu-market shivapuri-shelter) 23)
    (damaged shivapuri-shelter likhu-market)
    (damaged likhu-market shivapuri-shelter)

    (road likhu-market myagang-care-home)
    (road myagang-care-home likhu-market)
    (= (travel-time likhu-market myagang-care-home) 12)
    (= (travel-time myagang-care-home likhu-market) 12)
    (damaged likhu-market myagang-care-home)
    (damaged myagang-care-home likhu-market)

    (road dhunche-temple likhu-market)
    (road likhu-market dhunche-temple)
    (= (travel-time dhunche-temple likhu-market) 30)
    (= (travel-time likhu-market dhunche-temple) 30)

    (road shivapuri-shelter galchhi-school)
    (road galchhi-school shivapuri-shelter)
    (= (travel-time shivapuri-shelter galchhi-school) 33)
    (= (travel-time galchhi-school shivapuri-shelter) 33)

    (road dhunche-temple galchhi-school)
    (road galchhi-school dhunche-temple)
    (= (travel-time dhunche-temple galchhi-school) 20)
    (= (travel-time galchhi-school dhunche-temple) 20)
    (damaged dhunche-temple galchhi-school)
    (damaged galchhi-school dhunche-temple)

    (road shivapuri-shelter dhunche-temple)
    (road dhunche-temple shivapuri-shelter)
    (= (travel-time shivapuri-shelter dhunche-temple) 13)
    (= (travel-time dhunche-temple shivapuri-shelter) 13)

    ;; Evacuation points
    (evac-point shivapuri-shelter)

    ;; Car
    (car-at car1 shivapuri-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting dhunche-temple injured n6)
    (waiting myagang-care-home elderly n1)

    ;; Addition facts for levels n0..n6
    (sum n0 n0 n0)
    (sum n0 n1 n1) (sum n1 n0 n1)
    (sum n0 n2 n2) (sum n1 n1 n2) (sum n2 n0 n2)
    (sum n0 n3 n3) (sum n1 n2 n3) (sum n2 n1 n3) (sum n3 n0 n3)
    (sum n0 n4 n4) (sum n1 n3 n4) (sum n2 n2 n4) (sum n3 n1 n4) (sum n4 n0 n4)
    (sum n0 n5 n5) (sum n1 n4 n5) (sum n2 n3 n5) (sum n3 n2 n5) (sum n4 n1 n5) (sum n5 n0 n5)
    (sum n0 n6 n6) (sum n1 n5 n6) (sum n2 n4 n6) (sum n3 n3 n6) (sum n4 n2 n6) (sum n5 n1 n6) (sum n6 n0 n6)

    (positive n1) (positive n2) (positive n3) (positive n4) (positive n5) (positive n6)

    ;; Deferral penalties (per-person penalty x N)
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400)
    (= (defer-cost injured n6) 480)

    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300)
    (= (defer-cost child n6) 360)

    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250)
    (= (defer-cost elderly n6) 300)

    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100)
    (= (defer-cost adult n6) 120)
  )

  (:goal (and
    ;; Everyone who was waiting is either rescued or deferred
    (waiting dhunche-temple injured n0)
    (waiting myagang-care-home elderly n0)

    ;; Car is unloaded
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
