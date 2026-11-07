(define (problem flood-rescue-small-12)
  (:domain flood-rescue)

  (:objects
    trishuli-shelter gosaikunda-temple naukunda-farm bidur-village dupcheshwar-temple belkot-farm - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions)
    (road trishuli-shelter gosaikunda-temple)
    (road gosaikunda-temple trishuli-shelter)
    (= (travel-time trishuli-shelter gosaikunda-temple) 11)
    (= (travel-time gosaikunda-temple trishuli-shelter) 11)

    (road trishuli-shelter naukunda-farm)
    (road naukunda-farm trishuli-shelter)
    (damaged trishuli-shelter naukunda-farm)
    (damaged naukunda-farm trishuli-shelter)
    (= (travel-time trishuli-shelter naukunda-farm) 21)
    (= (travel-time naukunda-farm trishuli-shelter) 21)

    (road bidur-village dupcheshwar-temple)
    (road dupcheshwar-temple bidur-village)
    (= (travel-time bidur-village dupcheshwar-temple) 22)
    (= (travel-time dupcheshwar-temple bidur-village) 22)

    (road bidur-village belkot-farm)
    (road belkot-farm bidur-village)
    (= (travel-time bidur-village belkot-farm) 23)
    (= (travel-time belkot-farm bidur-village) 23)

    (road dupcheshwar-temple gosaikunda-temple)
    (road gosaikunda-temple dupcheshwar-temple)
    (= (travel-time dupcheshwar-temple gosaikunda-temple) 25)
    (= (travel-time gosaikunda-temple dupcheshwar-temple) 25)

    (road gosaikunda-temple belkot-farm)
    (road belkot-farm gosaikunda-temple)
    (= (travel-time gosaikunda-temple belkot-farm) 46)
    (= (travel-time belkot-farm gosaikunda-temple) 46)

    (road gosaikunda-temple naukunda-farm)
    (road naukunda-farm gosaikunda-temple)
    (= (travel-time gosaikunda-temple naukunda-farm) 12)
    (= (travel-time naukunda-farm gosaikunda-temple) 12)

    ;; Evacuation points
    (evac-point trishuli-shelter)

    ;; Car
    (car-at car1 trishuli-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting bidur-village adult n2)
    (waiting dupcheshwar-temple adult n4)
    (waiting naukunda-farm adult n4)

    ;; Addition facts a + b = c within n0..n4
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

    ;; Deferral penalties (per-person penalty x N)
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
    (waiting bidur-village adult n0)
    (waiting dupcheshwar-temple adult n0)
    (waiting naukunda-farm adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
