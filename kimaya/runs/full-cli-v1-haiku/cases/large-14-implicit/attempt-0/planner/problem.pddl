;; Nuwakot flood response, scenario large-14
;; Translated from the field report. Damaged or blocked roads are marked
;; (damaged). Benighat care home - Gajuri market is marked damaged because the
;; report says a truck was swept off it, so it is treated as unsafe to drive.
;; Bidur temple is a location but not an evacuation point.

(define (problem nuwakot-large-14)
  (:domain flood-rescue)

  (:objects
    trishuli-shelter dhunche-hospital bidur-temple uttargaya-farm
    tadi-care-home benighat-care-home jwalamukhi-market syaphru-market
    gajuri-market dupcheshwar-care-home tarkeshwar-market
    panchakanya-care-home shivapuri-care-home - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Cars
    (car-at car1 trishuli-shelter)
    (car-at car2 dhunche-hospital)
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

    ;; Evacuation points
    (evac-point trishuli-shelter)
    (evac-point dhunche-hospital)

    ;; Waiting people
    (waiting gajuri-market injured n1)
    (waiting gajuri-market adult n1)
    (waiting syaphru-market injured n4)
    (waiting uttargaya-farm injured n3)
    (waiting tarkeshwar-market adult n2)
    (waiting tadi-care-home elderly n4)
    (waiting dupcheshwar-care-home elderly n4)
    (waiting benighat-care-home elderly n1)
    (waiting jwalamukhi-market adult n2)

    ;; Roads, uttargaya-farm <-> tadi-care-home (11 min)
    (road uttargaya-farm tadi-care-home)
    (road tadi-care-home uttargaya-farm)
    (= (travel-time uttargaya-farm tadi-care-home) 11)
    (= (travel-time tadi-care-home uttargaya-farm) 11)

    ;; benighat-care-home <-> jwalamukhi-market (13 min)
    (road benighat-care-home jwalamukhi-market)
    (road jwalamukhi-market benighat-care-home)
    (= (travel-time benighat-care-home jwalamukhi-market) 13)
    (= (travel-time jwalamukhi-market benighat-care-home) 13)

    ;; syaphru-market <-> uttargaya-farm (21 min, bridge washed away)
    (road syaphru-market uttargaya-farm)
    (road uttargaya-farm syaphru-market)
    (= (travel-time syaphru-market uttargaya-farm) 21)
    (= (travel-time uttargaya-farm syaphru-market) 21)
    (damaged syaphru-market uttargaya-farm)
    (damaged uttargaya-farm syaphru-market)

    ;; benighat-care-home <-> gajuri-market (19 min, fast floodwater)
    (road benighat-care-home gajuri-market)
    (road gajuri-market benighat-care-home)
    (= (travel-time benighat-care-home gajuri-market) 19)
    (= (travel-time gajuri-market benighat-care-home) 19)
    (damaged benighat-care-home gajuri-market)
    (damaged gajuri-market benighat-care-home)

    ;; dupcheshwar-care-home <-> gajuri-market (15 min)
    (road dupcheshwar-care-home gajuri-market)
    (road gajuri-market dupcheshwar-care-home)
    (= (travel-time dupcheshwar-care-home gajuri-market) 15)
    (= (travel-time gajuri-market dupcheshwar-care-home) 15)

    ;; dhunche-hospital <-> dupcheshwar-care-home (21 min, landslide)
    (road dhunche-hospital dupcheshwar-care-home)
    (road dupcheshwar-care-home dhunche-hospital)
    (= (travel-time dhunche-hospital dupcheshwar-care-home) 21)
    (= (travel-time dupcheshwar-care-home dhunche-hospital) 21)
    (damaged dhunche-hospital dupcheshwar-care-home)
    (damaged dupcheshwar-care-home dhunche-hospital)

    ;; syaphru-market <-> panchakanya-care-home (35 min)
    (road syaphru-market panchakanya-care-home)
    (road panchakanya-care-home syaphru-market)
    (= (travel-time syaphru-market panchakanya-care-home) 35)
    (= (travel-time panchakanya-care-home syaphru-market) 35)

    ;; trishuli-shelter <-> dupcheshwar-care-home (19 min)
    (road trishuli-shelter dupcheshwar-care-home)
    (road dupcheshwar-care-home trishuli-shelter)
    (= (travel-time trishuli-shelter dupcheshwar-care-home) 19)
    (= (travel-time dupcheshwar-care-home trishuli-shelter) 19)

    ;; uttargaya-farm <-> shivapuri-care-home (5 min, police closed)
    (road uttargaya-farm shivapuri-care-home)
    (road shivapuri-care-home uttargaya-farm)
    (= (travel-time uttargaya-farm shivapuri-care-home) 5)
    (= (travel-time shivapuri-care-home uttargaya-farm) 5)
    (damaged uttargaya-farm shivapuri-care-home)
    (damaged shivapuri-care-home uttargaya-farm)

    ;; tarkeshwar-market <-> gajuri-market (13 min)
    (road tarkeshwar-market gajuri-market)
    (road gajuri-market tarkeshwar-market)
    (= (travel-time tarkeshwar-market gajuri-market) 13)
    (= (travel-time gajuri-market tarkeshwar-market) 13)

    ;; tarkeshwar-market <-> jwalamukhi-market (5 min)
    (road tarkeshwar-market jwalamukhi-market)
    (road jwalamukhi-market tarkeshwar-market)
    (= (travel-time tarkeshwar-market jwalamukhi-market) 5)
    (= (travel-time jwalamukhi-market tarkeshwar-market) 5)

    ;; trishuli-shelter <-> uttargaya-farm (24 min)
    (road trishuli-shelter uttargaya-farm)
    (road uttargaya-farm trishuli-shelter)
    (= (travel-time trishuli-shelter uttargaya-farm) 24)
    (= (travel-time uttargaya-farm trishuli-shelter) 24)

    ;; tarkeshwar-market <-> syaphru-market (19 min)
    (road tarkeshwar-market syaphru-market)
    (road syaphru-market tarkeshwar-market)
    (= (travel-time tarkeshwar-market syaphru-market) 19)
    (= (travel-time syaphru-market tarkeshwar-market) 19)

    ;; benighat-care-home <-> panchakanya-care-home (8 min)
    (road benighat-care-home panchakanya-care-home)
    (road panchakanya-care-home benighat-care-home)
    (= (travel-time benighat-care-home panchakanya-care-home) 8)
    (= (travel-time panchakanya-care-home benighat-care-home) 8)

    ;; shivapuri-care-home <-> tadi-care-home (10 min)
    (road shivapuri-care-home tadi-care-home)
    (road tadi-care-home shivapuri-care-home)
    (= (travel-time shivapuri-care-home tadi-care-home) 10)
    (= (travel-time tadi-care-home shivapuri-care-home) 10)

    ;; trishuli-shelter <-> bidur-temple (7 min)
    (road trishuli-shelter bidur-temple)
    (road bidur-temple trishuli-shelter)
    (= (travel-time trishuli-shelter bidur-temple) 7)
    (= (travel-time bidur-temple trishuli-shelter) 7)

    ;; benighat-care-home <-> tarkeshwar-market (9 min)
    (road benighat-care-home tarkeshwar-market)
    (road tarkeshwar-market benighat-care-home)
    (= (travel-time benighat-care-home tarkeshwar-market) 9)
    (= (travel-time tarkeshwar-market benighat-care-home) 9)

    ;; tarkeshwar-market <-> panchakanya-care-home (16 min)
    (road tarkeshwar-market panchakanya-care-home)
    (road panchakanya-care-home tarkeshwar-market)
    (= (travel-time tarkeshwar-market panchakanya-care-home) 16)
    (= (travel-time panchakanya-care-home tarkeshwar-market) 16)

    ;; Arithmetic: sum a b c means a + b = c, for values within n0..n4
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; Deferral penalties: per-person penalty x N
    ;; injured 80, child 60, elderly 50, adult 20
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

    (= (total-cost) 0)
  )

  (:goal (and
    ;; Everyone waiting is rescued or deferred
    (waiting gajuri-market injured n0)
    (waiting gajuri-market adult n0)
    (waiting syaphru-market injured n0)
    (waiting uttargaya-farm injured n0)
    (waiting tarkeshwar-market adult n0)
    (waiting tadi-care-home elderly n0)
    (waiting dupcheshwar-care-home elderly n0)
    (waiting benighat-care-home elderly n0)
    (waiting jwalamukhi-market adult n0)

    ;; Cars end empty
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
