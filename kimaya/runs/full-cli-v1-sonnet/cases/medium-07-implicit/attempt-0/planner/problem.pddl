(define (problem flood-rescue-medium-07)
  (:domain flood-rescue)

  (:objects
    kakani-shelter myagang-hospital panchakanya-school benighat-school gajuri-market dupcheshwar-farm jwalamukhi-school - location
    car1 - car
    n1 n2 n3 n4 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road panchakanya-school dupcheshwar-farm)
    (road dupcheshwar-farm panchakanya-school)
    (= (travel-time panchakanya-school dupcheshwar-farm) 27)
    (= (travel-time dupcheshwar-farm panchakanya-school) 27)

    (road myagang-hospital gajuri-market)
    (road gajuri-market myagang-hospital)
    (= (travel-time myagang-hospital gajuri-market) 11)
    (= (travel-time gajuri-market myagang-hospital) 11)
    (damaged myagang-hospital gajuri-market)
    (damaged gajuri-market myagang-hospital)

    (road gajuri-market panchakanya-school)
    (road panchakanya-school gajuri-market)
    (= (travel-time gajuri-market panchakanya-school) 23)
    (= (travel-time panchakanya-school gajuri-market) 23)

    (road kakani-shelter dupcheshwar-farm)
    (road dupcheshwar-farm kakani-shelter)
    (= (travel-time kakani-shelter dupcheshwar-farm) 23)
    (= (travel-time dupcheshwar-farm kakani-shelter) 23)

    (road benighat-school jwalamukhi-school)
    (road jwalamukhi-school benighat-school)
    (= (travel-time benighat-school jwalamukhi-school) 7)
    (= (travel-time jwalamukhi-school benighat-school) 7)

    (road kakani-shelter gajuri-market)
    (road gajuri-market kakani-shelter)
    (= (travel-time kakani-shelter gajuri-market) 23)
    (= (travel-time gajuri-market kakani-shelter) 23)
    (damaged kakani-shelter gajuri-market)
    (damaged gajuri-market kakani-shelter)

    (road kakani-shelter jwalamukhi-school)
    (road jwalamukhi-school kakani-shelter)
    (= (travel-time kakani-shelter jwalamukhi-school) 40)
    (= (travel-time jwalamukhi-school kakani-shelter) 40)

    (road myagang-hospital panchakanya-school)
    (road panchakanya-school myagang-hospital)
    (= (travel-time myagang-hospital panchakanya-school) 33)
    (= (travel-time panchakanya-school myagang-hospital) 33)

    (road kakani-shelter myagang-hospital)
    (road myagang-hospital kakani-shelter)
    (= (travel-time kakani-shelter myagang-hospital) 18)
    (= (travel-time myagang-hospital kakani-shelter) 18)

    ;; evacuation points
    (evac-point kakani-shelter)
    (evac-point myagang-hospital)

    ;; car
    (car-at car1 kakani-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; waiting people
    (waiting panchakanya-school child n3)
    (waiting benighat-school child n4)
    (waiting benighat-school injured n4)
    (waiting gajuri-market adult n3)
    (waiting dupcheshwar-farm child n1)
    (waiting jwalamukhi-school adult n4)

    ;; positive
    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; sums
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    ;; defer costs
    (= (defer-cost injured n1) 80) (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240) (= (defer-cost injured n4) 320)
    (= (defer-cost child n1) 60) (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180) (= (defer-cost child n4) 240)
    (= (defer-cost elderly n1) 50) (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150) (= (defer-cost elderly n4) 200)
    (= (defer-cost adult n1) 20) (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60) (= (defer-cost adult n4) 80)
  )

  (:goal (and
    (waiting panchakanya-school child n0)
    (waiting benighat-school child n0)
    (waiting benighat-school injured n0)
    (waiting gajuri-market adult n0)
    (waiting dupcheshwar-farm child n0)
    (waiting jwalamukhi-school adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
