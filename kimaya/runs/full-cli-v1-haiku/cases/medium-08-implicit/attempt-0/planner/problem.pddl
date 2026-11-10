(define (problem flood-rescue-medium-08)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    uttargaya-shelter kakani-temple trishuli-village bidur-temple
    galchhi-temple gajuri-farm syaphru-farm - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions)
    (road trishuli-village bidur-temple)
    (road bidur-temple trishuli-village)
    (= (travel-time trishuli-village bidur-temple) 7)
    (= (travel-time bidur-temple trishuli-village) 7)

    ;; Galchhi-Trishuli bridge washed away
    (road galchhi-temple trishuli-village)
    (road trishuli-village galchhi-temple)
    (damaged galchhi-temple trishuli-village)
    (damaged trishuli-village galchhi-temple)
    (= (travel-time galchhi-temple trishuli-village) 28)
    (= (travel-time trishuli-village galchhi-temple) 28)

    (road uttargaya-shelter bidur-temple)
    (road bidur-temple uttargaya-shelter)
    (= (travel-time uttargaya-shelter bidur-temple) 17)
    (= (travel-time bidur-temple uttargaya-shelter) 17)

    ;; Floodwater running fast, truck swept off this morning: treated as unusable
    (road uttargaya-shelter gajuri-farm)
    (road gajuri-farm uttargaya-shelter)
    (damaged uttargaya-shelter gajuri-farm)
    (damaged gajuri-farm uttargaya-shelter)
    (= (travel-time uttargaya-shelter gajuri-farm) 20)
    (= (travel-time gajuri-farm uttargaya-shelter) 20)

    (road syaphru-farm trishuli-village)
    (road trishuli-village syaphru-farm)
    (= (travel-time syaphru-farm trishuli-village) 8)
    (= (travel-time trishuli-village syaphru-farm) 8)

    (road galchhi-temple syaphru-farm)
    (road syaphru-farm galchhi-temple)
    (= (travel-time galchhi-temple syaphru-farm) 20)
    (= (travel-time syaphru-farm galchhi-temple) 20)

    ;; Uttargaya-Syaphru road closed by police after collapse
    (road uttargaya-shelter syaphru-farm)
    (road syaphru-farm uttargaya-shelter)
    (damaged uttargaya-shelter syaphru-farm)
    (damaged syaphru-farm uttargaya-shelter)
    (= (travel-time uttargaya-shelter syaphru-farm) 11)
    (= (travel-time syaphru-farm uttargaya-shelter) 11)

    (road uttargaya-shelter kakani-temple)
    (road kakani-temple uttargaya-shelter)
    (= (travel-time uttargaya-shelter kakani-temple) 48)
    (= (travel-time kakani-temple uttargaya-shelter) 48)

    (road syaphru-farm bidur-temple)
    (road bidur-temple syaphru-farm)
    (= (travel-time syaphru-farm bidur-temple) 11)
    (= (travel-time bidur-temple syaphru-farm) 11)

    ;; Evacuation points (kakani-temple is not designated)
    (evac-point uttargaya-shelter)

    ;; Cars
    (car-at car1 uttargaya-shelter)
    (car-at car2 uttargaya-shelter)
    (free-seats car1 n4)
    (free-seats car2 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; Waiting people
    (waiting kakani-temple elderly n3)
    (waiting kakani-temple adult n4)
    (waiting bidur-temple adult n3)
    (waiting syaphru-farm elderly n3)
    (waiting trishuli-village injured n3)

    ;; Sum relation a + b = c within n0 ... n4
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

    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

    ;; Deferral penalties
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
    (waiting kakani-temple elderly n0)
    (waiting kakani-temple adult n0)
    (waiting bidur-temple adult n0)
    (waiting syaphru-farm elderly n0)
    (waiting trishuli-village injured n0)

    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
