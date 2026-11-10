(define (problem large-06)
  (:domain flood-rescue)

  (:objects
    kispang-shelter benighat-hospital kakani-temple myagang-farm gajuri-school
    dhunche-temple galchhi-temple shivapuri-care-home trishuli-care-home
    jwalamukhi-market syaphru-care-home tarkeshwar-farm - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads
    (road kispang-shelter kakani-temple)
    (road kakani-temple kispang-shelter)
    (= (travel-time kispang-shelter kakani-temple) 5)
    (= (travel-time kakani-temple kispang-shelter) 5)

    (road benighat-hospital myagang-farm)
    (road myagang-farm benighat-hospital)
    (= (travel-time benighat-hospital myagang-farm) 8)
    (= (travel-time myagang-farm benighat-hospital) 8)

    (road benighat-hospital gajuri-school)
    (road gajuri-school benighat-hospital)
    (= (travel-time benighat-hospital gajuri-school) 12)
    (= (travel-time gajuri-school benighat-hospital) 12)

    (road benighat-hospital dhunche-temple)
    (road dhunche-temple benighat-hospital)
    (= (travel-time benighat-hospital dhunche-temple) 16)
    (= (travel-time dhunche-temple benighat-hospital) 16)

    (road kakani-temple galchhi-temple)
    (road galchhi-temple kakani-temple)
    (= (travel-time kakani-temple galchhi-temple) 45)
    (= (travel-time galchhi-temple kakani-temple) 45)

    (road kakani-temple dhunche-temple)
    (road dhunche-temple kakani-temple)
    (= (travel-time kakani-temple dhunche-temple) 58)
    (= (travel-time dhunche-temple kakani-temple) 58)
    (damaged kakani-temple dhunche-temple)
    (damaged dhunche-temple kakani-temple)

    (road galchhi-temple shivapuri-care-home)
    (road shivapuri-care-home galchhi-temple)
    (= (travel-time galchhi-temple shivapuri-care-home) 5)
    (= (travel-time shivapuri-care-home galchhi-temple) 5)

    (road galchhi-temple trishuli-care-home)
    (road trishuli-care-home galchhi-temple)
    (= (travel-time galchhi-temple trishuli-care-home) 20)
    (= (travel-time trishuli-care-home galchhi-temple) 20)
    (damaged galchhi-temple trishuli-care-home)
    (damaged trishuli-care-home galchhi-temple)

    (road myagang-farm gajuri-school)
    (road gajuri-school myagang-farm)
    (= (travel-time myagang-farm gajuri-school) 19)
    (= (travel-time gajuri-school myagang-farm) 19)

    (road myagang-farm dhunche-temple)
    (road dhunche-temple myagang-farm)
    (= (travel-time myagang-farm dhunche-temple) 24)
    (= (travel-time dhunche-temple myagang-farm) 24)

    (road gajuri-school jwalamukhi-market)
    (road jwalamukhi-market gajuri-school)
    (= (travel-time gajuri-school jwalamukhi-market) 11)
    (= (travel-time jwalamukhi-market gajuri-school) 11)

    (road gajuri-school dhunche-temple)
    (road dhunche-temple gajuri-school)
    (= (travel-time gajuri-school dhunche-temple) 9)
    (= (travel-time dhunche-temple gajuri-school) 9)

    (road jwalamukhi-market trishuli-care-home)
    (road trishuli-care-home jwalamukhi-market)
    (= (travel-time jwalamukhi-market trishuli-care-home) 18)
    (= (travel-time trishuli-care-home jwalamukhi-market) 18)

    (road jwalamukhi-market dhunche-temple)
    (road dhunche-temple jwalamukhi-market)
    (= (travel-time jwalamukhi-market dhunche-temple) 18)
    (= (travel-time dhunche-temple jwalamukhi-market) 18)

    (road jwalamukhi-market syaphru-care-home)
    (road syaphru-care-home jwalamukhi-market)
    (= (travel-time jwalamukhi-market syaphru-care-home) 21)
    (= (travel-time syaphru-care-home jwalamukhi-market) 21)

    (road trishuli-care-home syaphru-care-home)
    (road syaphru-care-home trishuli-care-home)
    (= (travel-time trishuli-care-home syaphru-care-home) 21)
    (= (travel-time syaphru-care-home trishuli-care-home) 21)
    (damaged trishuli-care-home syaphru-care-home)
    (damaged syaphru-care-home trishuli-care-home)

    (road tarkeshwar-farm syaphru-care-home)
    (road syaphru-care-home tarkeshwar-farm)
    (= (travel-time tarkeshwar-farm syaphru-care-home) 10)
    (= (travel-time syaphru-care-home tarkeshwar-farm) 10)

    ;; Evacuation points
    (evac-point kispang-shelter)
    (evac-point benighat-hospital)

    ;; Cars
    (car-at car1 kispang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 benighat-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting tarkeshwar-farm adult n4)
    (waiting myagang-farm adult n6)
    (waiting syaphru-care-home elderly n5)
    (waiting gajuri-school adult n3)
    (waiting gajuri-school child n4)
    (waiting shivapuri-care-home elderly n2)
    (waiting kakani-temple adult n3)
    (waiting jwalamukhi-market child n2)

    ;; Level arithmetic
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3)
    (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n1 n4 n5) (sum n1 n5 n6)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5)
    (sum n2 n4 n6)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6)
    (sum n5 n0 n5) (sum n5 n1 n6)
    (sum n6 n0 n6)

    (positive n1) (positive n2) (positive n3)
    (positive n4) (positive n5) (positive n6)

    ;; Deferral penalties
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
    (waiting tarkeshwar-farm adult n0)
    (waiting myagang-farm adult n0)
    (waiting syaphru-care-home elderly n0)
    (waiting gajuri-school adult n0)
    (waiting gajuri-school child n0)
    (waiting shivapuri-care-home elderly n0)
    (waiting kakani-temple adult n0)
    (waiting jwalamukhi-market child n0)

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
