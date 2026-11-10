(define (problem small-03)
  (:domain flood-rescue)

  (:objects
    myagang-shelter benighat-temple nilkantha-market jwalamukhi-village syaphru-school bidur-village - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads
    (road myagang-shelter nilkantha-market)
    (road nilkantha-market myagang-shelter)
    (= (travel-time myagang-shelter nilkantha-market) 18)
    (= (travel-time nilkantha-market myagang-shelter) 18)

    (road jwalamukhi-village syaphru-school)
    (road syaphru-school jwalamukhi-village)
    (= (travel-time jwalamukhi-village syaphru-school) 10)
    (= (travel-time syaphru-school jwalamukhi-village) 10)

    (road myagang-shelter bidur-village)
    (road bidur-village myagang-shelter)
    (= (travel-time myagang-shelter bidur-village) 27)
    (= (travel-time bidur-village myagang-shelter) 27)

    (road myagang-shelter jwalamukhi-village)
    (road jwalamukhi-village myagang-shelter)
    (= (travel-time myagang-shelter jwalamukhi-village) 27)
    (= (travel-time jwalamukhi-village myagang-shelter) 27)
    (damaged myagang-shelter jwalamukhi-village)
    (damaged jwalamukhi-village myagang-shelter)

    (road benighat-temple syaphru-school)
    (road syaphru-school benighat-temple)
    (= (travel-time benighat-temple syaphru-school) 36)
    (= (travel-time syaphru-school benighat-temple) 36)

    (road myagang-shelter syaphru-school)
    (road syaphru-school myagang-shelter)
    (= (travel-time myagang-shelter syaphru-school) 18)
    (= (travel-time syaphru-school myagang-shelter) 18)

    (road bidur-village nilkantha-market)
    (road nilkantha-market bidur-village)
    (= (travel-time bidur-village nilkantha-market) 19)
    (= (travel-time nilkantha-market bidur-village) 19)

    ;; Evacuation points
    (evac-point myagang-shelter)

    ;; Cars
    (car-at car1 myagang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; Waiting people
    (waiting nilkantha-market adult n2)
    (waiting nilkantha-market injured n4)
    (waiting syaphru-school adult n1)
    (waiting bidur-village adult n4)

    ;; Sums
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

    ;; Deferral costs
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

    (= (total-cost) 0))

  (:goal (and
    (waiting nilkantha-market adult n0)
    (waiting nilkantha-market injured n0)
    (waiting syaphru-school adult n0)
    (waiting bidur-village adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)))

  (:metric minimize (total-cost)))
