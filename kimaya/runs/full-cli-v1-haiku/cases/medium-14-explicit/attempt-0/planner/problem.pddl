(define (problem flood-nuwakot-medium-14)
  (:domain flood-rescue)

  (:objects
    dupcheshwar-shelter panchakanya-hospital benighat-market tadi-school
    trishuli-market myagang-care-home uttargaya-care-home tarkeshwar-care-home
    syaphru-temple - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions)
    (road dupcheshwar-shelter benighat-market)
    (road benighat-market dupcheshwar-shelter)
    (= (travel-time dupcheshwar-shelter benighat-market) 6)
    (= (travel-time benighat-market dupcheshwar-shelter) 6)

    (road dupcheshwar-shelter tadi-school)
    (road tadi-school dupcheshwar-shelter)
    (= (travel-time dupcheshwar-shelter tadi-school) 10)
    (= (travel-time tadi-school dupcheshwar-shelter) 10)

    (road panchakanya-hospital benighat-market)
    (road benighat-market panchakanya-hospital)
    (damaged panchakanya-hospital benighat-market)
    (damaged benighat-market panchakanya-hospital)
    (= (travel-time panchakanya-hospital benighat-market) 19)
    (= (travel-time benighat-market panchakanya-hospital) 19)

    (road panchakanya-hospital tadi-school)
    (road tadi-school panchakanya-hospital)
    (= (travel-time panchakanya-hospital tadi-school) 16)
    (= (travel-time tadi-school panchakanya-hospital) 16)

    (road panchakanya-hospital trishuli-market)
    (road trishuli-market panchakanya-hospital)
    (= (travel-time panchakanya-hospital trishuli-market) 65)
    (= (travel-time trishuli-market panchakanya-hospital) 65)

    (road benighat-market myagang-care-home)
    (road myagang-care-home benighat-market)
    (= (travel-time benighat-market myagang-care-home) 20)
    (= (travel-time myagang-care-home benighat-market) 20)

    (road benighat-market syaphru-temple)
    (road syaphru-temple benighat-market)
    (damaged benighat-market syaphru-temple)
    (damaged syaphru-temple benighat-market)
    (= (travel-time benighat-market syaphru-temple) 7)
    (= (travel-time syaphru-temple benighat-market) 7)

    (road benighat-market tadi-school)
    (road tadi-school benighat-market)
    (= (travel-time benighat-market tadi-school) 11)
    (= (travel-time tadi-school benighat-market) 11)

    (road myagang-care-home uttargaya-care-home)
    (road uttargaya-care-home myagang-care-home)
    (= (travel-time myagang-care-home uttargaya-care-home) 23)
    (= (travel-time uttargaya-care-home myagang-care-home) 23)

    (road myagang-care-home tarkeshwar-care-home)
    (road tarkeshwar-care-home myagang-care-home)
    (= (travel-time myagang-care-home tarkeshwar-care-home) 16)
    (= (travel-time tarkeshwar-care-home myagang-care-home) 16)

    (road uttargaya-care-home tarkeshwar-care-home)
    (road tarkeshwar-care-home uttargaya-care-home)
    (= (travel-time uttargaya-care-home tarkeshwar-care-home) 14)
    (= (travel-time tarkeshwar-care-home uttargaya-care-home) 14)

    (road syaphru-temple tadi-school)
    (road tadi-school syaphru-temple)
    (= (travel-time syaphru-temple tadi-school) 8)
    (= (travel-time tadi-school syaphru-temple) 8)

    ;; Evacuation points
    (evac-point dupcheshwar-shelter)
    (evac-point panchakanya-hospital)

    ;; Cars
    (car-at car1 dupcheshwar-shelter)
    (car-at car2 panchakanya-hospital)
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

    ;; People waiting
    (waiting trishuli-market elderly n4)
    (waiting trishuli-market adult n4)
    (waiting tadi-school child n1)
    (waiting uttargaya-care-home adult n4)
    (waiting tarkeshwar-care-home adult n1)
    (waiting tarkeshwar-care-home elderly n3)
    (waiting benighat-market elderly n3)

    ;; Arithmetic: (sum a b c) means a + b = c, for levels n0..n4
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

    ;; Deferral penalties: per-person penalty x N
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
    ;; Everyone waiting is rescued or deferred
    (waiting trishuli-market elderly n0)
    (waiting trishuli-market adult n0)
    (waiting tadi-school child n0)
    (waiting uttargaya-care-home adult n0)
    (waiting tarkeshwar-care-home adult n0)
    (waiting tarkeshwar-care-home elderly n0)
    (waiting benighat-market elderly n0)

    ;; Cars are empty (all passengers dropped off)
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
