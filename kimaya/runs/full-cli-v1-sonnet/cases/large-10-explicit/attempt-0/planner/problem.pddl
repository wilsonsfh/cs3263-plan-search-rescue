(define (problem large-10)
  (:domain flood-rescue)

  (:objects
    panchakanya-shelter tadi-hospital dhunche-temple syaphru-farm thakre-market
    jwalamukhi-care-home trishuli-care-home gajuri-market myagang-farm likhu-school - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 n7 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road panchakanya-shelter tadi-hospital) (road tadi-hospital panchakanya-shelter)
    (= (travel-time panchakanya-shelter tadi-hospital) 42)
    (= (travel-time tadi-hospital panchakanya-shelter) 42)

    (road panchakanya-shelter dhunche-temple) (road dhunche-temple panchakanya-shelter)
    (= (travel-time panchakanya-shelter dhunche-temple) 12)
    (= (travel-time dhunche-temple panchakanya-shelter) 12)

    (road panchakanya-shelter syaphru-farm) (road syaphru-farm panchakanya-shelter)
    (= (travel-time panchakanya-shelter syaphru-farm) 34)
    (= (travel-time syaphru-farm panchakanya-shelter) 34)

    (road panchakanya-shelter thakre-market) (road thakre-market panchakanya-shelter)
    (= (travel-time panchakanya-shelter thakre-market) 14)
    (= (travel-time thakre-market panchakanya-shelter) 14)
    (damaged panchakanya-shelter thakre-market) (damaged thakre-market panchakanya-shelter)

    (road dhunche-temple jwalamukhi-care-home) (road jwalamukhi-care-home dhunche-temple)
    (= (travel-time dhunche-temple jwalamukhi-care-home) 17)
    (= (travel-time jwalamukhi-care-home dhunche-temple) 17)

    (road dhunche-temple thakre-market) (road thakre-market dhunche-temple)
    (= (travel-time dhunche-temple thakre-market) 10)
    (= (travel-time thakre-market dhunche-temple) 10)

    (road jwalamukhi-care-home thakre-market) (road thakre-market jwalamukhi-care-home)
    (= (travel-time jwalamukhi-care-home thakre-market) 9)
    (= (travel-time thakre-market jwalamukhi-care-home) 9)

    (road trishuli-care-home gajuri-market) (road gajuri-market trishuli-care-home)
    (= (travel-time trishuli-care-home gajuri-market) 11)
    (= (travel-time gajuri-market trishuli-care-home) 11)
    (damaged trishuli-care-home gajuri-market) (damaged gajuri-market trishuli-care-home)

    (road trishuli-care-home myagang-farm) (road myagang-farm trishuli-care-home)
    (= (travel-time trishuli-care-home myagang-farm) 12)
    (= (travel-time myagang-farm trishuli-care-home) 12)

    (road gajuri-market syaphru-farm) (road syaphru-farm gajuri-market)
    (= (travel-time gajuri-market syaphru-farm) 9)
    (= (travel-time syaphru-farm gajuri-market) 9)

    (road gajuri-market myagang-farm) (road myagang-farm gajuri-market)
    (= (travel-time gajuri-market myagang-farm) 5)
    (= (travel-time myagang-farm gajuri-market) 5)
    (damaged gajuri-market myagang-farm) (damaged myagang-farm gajuri-market)

    (road likhu-school syaphru-farm) (road syaphru-farm likhu-school)
    (= (travel-time likhu-school syaphru-farm) 5)
    (= (travel-time syaphru-farm likhu-school) 5)

    (road likhu-school myagang-farm) (road myagang-farm likhu-school)
    (= (travel-time likhu-school myagang-farm) 7)
    (= (travel-time myagang-farm likhu-school) 7)
    (damaged likhu-school myagang-farm) (damaged myagang-farm likhu-school)

    (road syaphru-farm myagang-farm) (road myagang-farm syaphru-farm)
    (= (travel-time syaphru-farm myagang-farm) 6)
    (= (travel-time myagang-farm syaphru-farm) 6)

    ;; evacuation points
    (evac-point panchakanya-shelter)
    (evac-point tadi-hospital)

    ;; cars
    (car-at car1 panchakanya-shelter)
    (car-at car2 tadi-hospital)
    (free-seats car1 n4)
    (free-seats car2 n4)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; people waiting
    (waiting myagang-farm adult n1)
    (waiting syaphru-farm adult n3)
    (waiting gajuri-market adult n1)
    (waiting gajuri-market child n2)
    (waiting thakre-market adult n3)
    (waiting dhunche-temple adult n4)
    (waiting dhunche-temple child n1)
    (waiting trishuli-care-home elderly n7)

    ;; positive
    (positive n1) (positive n2) (positive n3) (positive n4)
    (positive n5) (positive n6) (positive n7)

    ;; sums
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3)
    (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6) (sum n0 n7 n7)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n1 n4 n5) (sum n1 n5 n6) (sum n1 n6 n7)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5)
    (sum n2 n4 n6) (sum n2 n5 n7)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n3 n4 n7)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6) (sum n4 n3 n7)
    (sum n5 n0 n5) (sum n5 n1 n6) (sum n5 n2 n7)
    (sum n6 n0 n6) (sum n6 n1 n7)
    (sum n7 n0 n7)

    ;; defer costs
    (= (defer-cost injured n1) 80) (= (defer-cost injured n2) 160) (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320) (= (defer-cost injured n5) 400) (= (defer-cost injured n6) 480)
    (= (defer-cost injured n7) 560)
    (= (defer-cost child n1) 60) (= (defer-cost child n2) 120) (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240) (= (defer-cost child n5) 300) (= (defer-cost child n6) 360)
    (= (defer-cost child n7) 420)
    (= (defer-cost elderly n1) 50) (= (defer-cost elderly n2) 100) (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200) (= (defer-cost elderly n5) 250) (= (defer-cost elderly n6) 300)
    (= (defer-cost elderly n7) 350)
    (= (defer-cost adult n1) 20) (= (defer-cost adult n2) 40) (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80) (= (defer-cost adult n5) 100) (= (defer-cost adult n6) 120)
    (= (defer-cost adult n7) 140)
  )

  (:goal (and
    (waiting myagang-farm adult n0)
    (waiting syaphru-farm adult n0)
    (waiting gajuri-market adult n0)
    (waiting gajuri-market child n0)
    (waiting thakre-market adult n0)
    (waiting dhunche-temple adult n0)
    (waiting dhunche-temple child n0)
    (waiting trishuli-care-home elderly n0)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
