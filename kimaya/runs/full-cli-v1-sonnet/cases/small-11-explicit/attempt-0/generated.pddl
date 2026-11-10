(define (problem small-11)
  (:domain flood-rescue)

  (:objects
    myagang-shelter gosaikunda-temple suryagadhi-market galchhi-village dhunche-farm - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; roads
    (road myagang-shelter gosaikunda-temple)
    (road gosaikunda-temple myagang-shelter)
    (= (travel-time myagang-shelter gosaikunda-temple) 51)
    (= (travel-time gosaikunda-temple myagang-shelter) 51)

    (road myagang-shelter suryagadhi-market)
    (road suryagadhi-market myagang-shelter)
    (= (travel-time myagang-shelter suryagadhi-market) 26)
    (= (travel-time suryagadhi-market myagang-shelter) 26)

    (road myagang-shelter galchhi-village)
    (road galchhi-village myagang-shelter)
    (= (travel-time myagang-shelter galchhi-village) 14)
    (= (travel-time galchhi-village myagang-shelter) 14)

    (road dhunche-farm gosaikunda-temple)
    (road gosaikunda-temple dhunche-farm)
    (= (travel-time dhunche-farm gosaikunda-temple) 19)
    (= (travel-time gosaikunda-temple dhunche-farm) 19)
    (damaged dhunche-farm gosaikunda-temple)
    (damaged gosaikunda-temple dhunche-farm)

    (road dhunche-farm galchhi-village)
    (road galchhi-village dhunche-farm)
    (= (travel-time dhunche-farm galchhi-village) 45)
    (= (travel-time galchhi-village dhunche-farm) 45)

    (road suryagadhi-market galchhi-village)
    (road galchhi-village suryagadhi-market)
    (= (travel-time suryagadhi-market galchhi-village) 25)
    (= (travel-time galchhi-village suryagadhi-market) 25)

    ;; evacuation points
    (evac-point myagang-shelter)

    ;; car
    (car-at car1 myagang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; people waiting
    (waiting gosaikunda-temple adult n1)
    (waiting gosaikunda-temple elderly n2)
    (waiting suryagadhi-market injured n3)

    ;; positive
    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; sums
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    ;; defer costs
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
    (waiting gosaikunda-temple adult n0)
    (waiting gosaikunda-temple elderly n0)
    (waiting suryagadhi-market injured n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)))

  (:metric minimize (total-cost))
)
