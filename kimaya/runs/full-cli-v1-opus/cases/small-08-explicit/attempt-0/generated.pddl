(define (problem flood-rescue-small-08)
  (:domain flood-rescue)

  (:objects
    jwalamukhi-shelter dupcheshwar-temple thakre-market gosaikunda-school trishuli-market likhu-school - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads
    (road jwalamukhi-shelter dupcheshwar-temple)
    (road dupcheshwar-temple jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter dupcheshwar-temple) 12)
    (= (travel-time dupcheshwar-temple jwalamukhi-shelter) 12)

    (road dupcheshwar-temple thakre-market)
    (road thakre-market dupcheshwar-temple)
    (= (travel-time dupcheshwar-temple thakre-market) 44)
    (= (travel-time thakre-market dupcheshwar-temple) 44)
    (damaged dupcheshwar-temple thakre-market)
    (damaged thakre-market dupcheshwar-temple)

    (road dupcheshwar-temple gosaikunda-school)
    (road gosaikunda-school dupcheshwar-temple)
    (= (travel-time dupcheshwar-temple gosaikunda-school) 31)
    (= (travel-time gosaikunda-school dupcheshwar-temple) 31)

    (road trishuli-market thakre-market)
    (road thakre-market trishuli-market)
    (= (travel-time trishuli-market thakre-market) 19)
    (= (travel-time thakre-market trishuli-market) 19)

    (road trishuli-market likhu-school)
    (road likhu-school trishuli-market)
    (= (travel-time trishuli-market likhu-school) 22)
    (= (travel-time likhu-school trishuli-market) 22)
    (damaged trishuli-market likhu-school)
    (damaged likhu-school trishuli-market)

    (road trishuli-market gosaikunda-school)
    (road gosaikunda-school trishuli-market)
    (= (travel-time trishuli-market gosaikunda-school) 17)
    (= (travel-time gosaikunda-school trishuli-market) 17)

    (road thakre-market likhu-school)
    (road likhu-school thakre-market)
    (= (travel-time thakre-market likhu-school) 14)
    (= (travel-time likhu-school thakre-market) 14)
    (damaged thakre-market likhu-school)
    (damaged likhu-school thakre-market)

    ;; Evacuation points
    (evac-point jwalamukhi-shelter)

    ;; Cars
    (car-at car1 jwalamukhi-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting likhu-school child n1)
    (waiting likhu-school injured n4)
    (waiting thakre-market adult n3)
    (waiting trishuli-market adult n4)

    ;; Level arithmetic
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

    (= (total-cost) 0))

  (:goal (and
    (waiting likhu-school child n0)
    (waiting likhu-school injured n0)
    (waiting thakre-market adult n0)
    (waiting trishuli-market adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)))

  (:metric minimize (total-cost))
)
