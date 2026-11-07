;; Nuwakot district flood response (scenario large-11)
;; Evacuation points: tarkeshwar-shelter, dupcheshwar-hospital.
;; myagang-temple is not designated as a drop-off point, so it is not marked evac-point.
;; The panchakanya-farm to trishuli-temple road is closed by police, so it is marked damaged.
;; The galchhi-village to myagang-temple road has fast floodwater and a swept-away truck, so it is marked damaged.
;; Level objects: K = max(car capacity 4, largest group 6) = 6.

(define (problem flood-rescue-large-11)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    tarkeshwar-shelter dupcheshwar-hospital myagang-temple bidur-village
    syaphru-village panchakanya-farm trishuli-temple galchhi-village
    nilkantha-care-home gajuri-school naukunda-school - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    (= (total-cost) 0)

    ;; Evacuation points
    (evac-point tarkeshwar-shelter)
    (evac-point dupcheshwar-hospital)

    ;; Roads (both directions), travel times, and damaged roads

    ;; dupcheshwar-hospital <-> bidur-village, 21 min
    (road dupcheshwar-hospital bidur-village)
    (road bidur-village dupcheshwar-hospital)
    (= (travel-time dupcheshwar-hospital bidur-village) 21)
    (= (travel-time bidur-village dupcheshwar-hospital) 21)

    ;; syaphru-village <-> panchakanya-farm, 9 min
    (road syaphru-village panchakanya-farm)
    (road panchakanya-farm syaphru-village)
    (= (travel-time syaphru-village panchakanya-farm) 9)
    (= (travel-time panchakanya-farm syaphru-village) 9)

    ;; tarkeshwar-shelter <-> galchhi-village, 20 min (muddy, passable)
    (road tarkeshwar-shelter galchhi-village)
    (road galchhi-village tarkeshwar-shelter)
    (= (travel-time tarkeshwar-shelter galchhi-village) 20)
    (= (travel-time galchhi-village tarkeshwar-shelter) 20)

    ;; tarkeshwar-shelter <-> bidur-village, 15 min
    (road tarkeshwar-shelter bidur-village)
    (road bidur-village tarkeshwar-shelter)
    (= (travel-time tarkeshwar-shelter bidur-village) 15)
    (= (travel-time bidur-village tarkeshwar-shelter) 15)

    ;; syaphru-village <-> trishuli-temple, 21 min
    (road syaphru-village trishuli-temple)
    (road trishuli-temple syaphru-village)
    (= (travel-time syaphru-village trishuli-temple) 21)
    (= (travel-time trishuli-temple syaphru-village) 21)

    ;; galchhi-village <-> syaphru-village, 14 min (muddy, passable)
    (road galchhi-village syaphru-village)
    (road syaphru-village galchhi-village)
    (= (travel-time galchhi-village syaphru-village) 14)
    (= (travel-time syaphru-village galchhi-village) 14)

    ;; tarkeshwar-shelter <-> trishuli-temple, 52 min
    (road tarkeshwar-shelter trishuli-temple)
    (road trishuli-temple tarkeshwar-shelter)
    (= (travel-time tarkeshwar-shelter trishuli-temple) 52)
    (= (travel-time trishuli-temple tarkeshwar-shelter) 52)

    ;; panchakanya-farm <-> trishuli-temple, 12 min, CLOSED (collapsed into river)
    (road panchakanya-farm trishuli-temple)
    (road trishuli-temple panchakanya-farm)
    (= (travel-time panchakanya-farm trishuli-temple) 12)
    (= (travel-time trishuli-temple panchakanya-farm) 12)
    (damaged panchakanya-farm trishuli-temple)
    (damaged trishuli-temple panchakanya-farm)

    ;; bidur-village <-> myagang-temple, 17 min (muddy, passable)
    (road bidur-village myagang-temple)
    (road myagang-temple bidur-village)
    (= (travel-time bidur-village myagang-temple) 17)
    (= (travel-time myagang-temple bidur-village) 17)

    ;; galchhi-village <-> panchakanya-farm, 22 min
    (road galchhi-village panchakanya-farm)
    (road panchakanya-farm galchhi-village)
    (= (travel-time galchhi-village panchakanya-farm) 22)
    (= (travel-time panchakanya-farm galchhi-village) 22)

    ;; dupcheshwar-hospital <-> nilkantha-care-home, 18 min
    (road dupcheshwar-hospital nilkantha-care-home)
    (road nilkantha-care-home dupcheshwar-hospital)
    (= (travel-time dupcheshwar-hospital nilkantha-care-home) 18)
    (= (travel-time nilkantha-care-home dupcheshwar-hospital) 18)

    ;; tarkeshwar-shelter <-> gajuri-school, 10 min
    (road tarkeshwar-shelter gajuri-school)
    (road gajuri-school tarkeshwar-shelter)
    (= (travel-time tarkeshwar-shelter gajuri-school) 10)
    (= (travel-time gajuri-school tarkeshwar-shelter) 10)

    ;; myagang-temple <-> nilkantha-care-home, 11 min
    (road myagang-temple nilkantha-care-home)
    (road nilkantha-care-home myagang-temple)
    (= (travel-time myagang-temple nilkantha-care-home) 11)
    (= (travel-time nilkantha-care-home myagang-temple) 11)

    ;; naukunda-school <-> trishuli-temple, 5 min
    (road naukunda-school trishuli-temple)
    (road trishuli-temple naukunda-school)
    (= (travel-time naukunda-school trishuli-temple) 5)
    (= (travel-time trishuli-temple naukunda-school) 5)

    ;; galchhi-village <-> bidur-village, 12 min (muddy, passable)
    (road galchhi-village bidur-village)
    (road bidur-village galchhi-village)
    (= (travel-time galchhi-village bidur-village) 12)
    (= (travel-time bidur-village galchhi-village) 12)

    ;; galchhi-village <-> myagang-temple, 14 min, UNUSABLE (fast floodwater, truck swept off)
    (road galchhi-village myagang-temple)
    (road myagang-temple galchhi-village)
    (= (travel-time galchhi-village myagang-temple) 14)
    (= (travel-time myagang-temple galchhi-village) 14)
    (damaged galchhi-village myagang-temple)
    (damaged myagang-temple galchhi-village)

    ;; Cars
    (car-at car1 tarkeshwar-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 dupcheshwar-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting panchakanya-farm adult n6)
    (waiting syaphru-village adult n5)
    (waiting galchhi-village injured n1)
    (waiting naukunda-school child n4)
    (waiting nilkantha-care-home adult n2)
    (waiting bidur-village elderly n2)

    ;; Arithmetic: (sum a b c) means a + b = c, for a, b, c in n0..n6
    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n0 n2 n2)
    (sum n0 n3 n3)
    (sum n0 n4 n4)
    (sum n0 n5 n5)
    (sum n0 n6 n6)
    (sum n1 n0 n1)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n1 n3 n4)
    (sum n1 n4 n5)
    (sum n1 n5 n6)
    (sum n2 n0 n2)
    (sum n2 n1 n3)
    (sum n2 n2 n4)
    (sum n2 n3 n5)
    (sum n2 n4 n6)
    (sum n3 n0 n3)
    (sum n3 n1 n4)
    (sum n3 n2 n5)
    (sum n3 n3 n6)
    (sum n4 n0 n4)
    (sum n4 n1 n5)
    (sum n4 n2 n6)
    (sum n5 n0 n5)
    (sum n5 n1 n6)
    (sum n6 n0 n6)

    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)
    (positive n5)
    (positive n6)

    ;; Deferral penalties: per-person penalty x N
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
    ;; Everyone waiting is either rescued or deferred
    (waiting panchakanya-farm adult n0)
    (waiting syaphru-village adult n0)
    (waiting galchhi-village injured n0)
    (waiting naukunda-school child n0)
    (waiting nilkantha-care-home adult n0)
    (waiting bidur-village elderly n0)

    ;; Both cars empty
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
