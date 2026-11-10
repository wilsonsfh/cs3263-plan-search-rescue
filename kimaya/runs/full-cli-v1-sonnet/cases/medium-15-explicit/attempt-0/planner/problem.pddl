(define (problem flood-rescue-medium-15)
  (:domain flood-rescue)

  (:objects
    jwalamukhi-shelter gosaikunda-hospital galchhi-farm tadi-farm gajuri-market kakani-village dupcheshwar-market shivapuri-care-home - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road jwalamukhi-shelter gosaikunda-hospital)
    (road gosaikunda-hospital jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter gosaikunda-hospital) 18)
    (= (travel-time gosaikunda-hospital jwalamukhi-shelter) 18)

    (road jwalamukhi-shelter galchhi-farm)
    (road galchhi-farm jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter galchhi-farm) 28)
    (= (travel-time galchhi-farm jwalamukhi-shelter) 28)
    (damaged jwalamukhi-shelter galchhi-farm)
    (damaged galchhi-farm jwalamukhi-shelter)

    (road jwalamukhi-shelter tadi-farm)
    (road tadi-farm jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter tadi-farm) 5)
    (= (travel-time tadi-farm jwalamukhi-shelter) 5)

    (road gosaikunda-hospital gajuri-market)
    (road gajuri-market gosaikunda-hospital)
    (= (travel-time gosaikunda-hospital gajuri-market) 49)
    (= (travel-time gajuri-market gosaikunda-hospital) 49)

    (road gosaikunda-hospital galchhi-farm)
    (road galchhi-farm gosaikunda-hospital)
    (= (travel-time gosaikunda-hospital galchhi-farm) 43)
    (= (travel-time galchhi-farm gosaikunda-hospital) 43)

    (road gosaikunda-hospital kakani-village)
    (road kakani-village gosaikunda-hospital)
    (= (travel-time gosaikunda-hospital kakani-village) 5)
    (= (travel-time kakani-village gosaikunda-hospital) 5)

    (road gosaikunda-hospital tadi-farm)
    (road tadi-farm gosaikunda-hospital)
    (= (travel-time gosaikunda-hospital tadi-farm) 22)
    (= (travel-time tadi-farm gosaikunda-hospital) 22)

    (road gajuri-market shivapuri-care-home)
    (road shivapuri-care-home gajuri-market)
    (= (travel-time gajuri-market shivapuri-care-home) 17)
    (= (travel-time shivapuri-care-home gajuri-market) 17)

    (road dupcheshwar-market kakani-village)
    (road kakani-village dupcheshwar-market)
    (= (travel-time dupcheshwar-market kakani-village) 19)
    (= (travel-time kakani-village dupcheshwar-market) 19)

    ;; evacuation points
    (evac-point jwalamukhi-shelter)
    (evac-point gosaikunda-hospital)

    ;; cars
    (car-at car1 jwalamukhi-shelter)
    (car-at car2 gosaikunda-hospital)
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

    ;; people waiting
    (waiting tadi-farm adult n2)
    (waiting dupcheshwar-market adult n6)
    (waiting kakani-village adult n3)
    (waiting galchhi-farm elderly n2)

    ;; positive
    (positive n1) (positive n2) (positive n3) (positive n4) (positive n5) (positive n6)

    ;; sums
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4) (sum n1 n4 n5) (sum n1 n5 n6)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5) (sum n2 n4 n6)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6)
    (sum n5 n0 n5) (sum n5 n1 n6)
    (sum n6 n0 n6)

    ;; defer costs
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
    (waiting tadi-farm adult n0)
    (waiting dupcheshwar-market adult n0)
    (waiting kakani-village adult n0)
    (waiting galchhi-farm elderly n0)
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
