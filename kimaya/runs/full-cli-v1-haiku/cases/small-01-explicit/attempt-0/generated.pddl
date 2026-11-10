(define (problem flood-rescue-small-01)
  (:domain flood-rescue)
  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    myagang-shelter uttargaya-school dhunche-village nilkantha-market
    syaphru-temple dupcheshwar-village - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions)
    (road myagang-shelter uttargaya-school)
    (road uttargaya-school myagang-shelter)
    (= (travel-time myagang-shelter uttargaya-school) 28)
    (= (travel-time uttargaya-school myagang-shelter) 28)

    (road myagang-shelter dhunche-village)
    (road dhunche-village myagang-shelter)
    (= (travel-time myagang-shelter dhunche-village) 46)
    (= (travel-time dhunche-village myagang-shelter) 46)

    (road myagang-shelter nilkantha-market)
    (road nilkantha-market myagang-shelter)
    (= (travel-time myagang-shelter nilkantha-market) 35)
    (= (travel-time nilkantha-market myagang-shelter) 35)
    (damaged myagang-shelter nilkantha-market)
    (damaged nilkantha-market myagang-shelter)

    (road uttargaya-school nilkantha-market)
    (road nilkantha-market uttargaya-school)
    (= (travel-time uttargaya-school nilkantha-market) 8)
    (= (travel-time nilkantha-market uttargaya-school) 8)

    (road uttargaya-school dupcheshwar-village)
    (road dupcheshwar-village uttargaya-school)
    (= (travel-time uttargaya-school dupcheshwar-village) 9)
    (= (travel-time dupcheshwar-village uttargaya-school) 9)

    (road nilkantha-market syaphru-temple)
    (road syaphru-temple nilkantha-market)
    (= (travel-time nilkantha-market syaphru-temple) 31)
    (= (travel-time syaphru-temple nilkantha-market) 31)

    (road nilkantha-market dupcheshwar-village)
    (road dupcheshwar-village nilkantha-market)
    (= (travel-time nilkantha-market dupcheshwar-village) 16)
    (= (travel-time dupcheshwar-village nilkantha-market) 16)

    ;; Evacuation points
    (evac-point myagang-shelter)

    ;; Car
    (car-at car1 myagang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting syaphru-temple adult n1)
    (waiting syaphru-temple elderly n2)
    (waiting uttargaya-school child n2)

    ;; Arithmetic: (sum a b c) means a + b = c, for values within n0..n4
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
    ;; Everyone waiting is either rescued or deferred
    (waiting syaphru-temple adult n0)
    (waiting syaphru-temple elderly n0)
    (waiting uttargaya-school child n0)

    ;; Car has no one left on board
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
