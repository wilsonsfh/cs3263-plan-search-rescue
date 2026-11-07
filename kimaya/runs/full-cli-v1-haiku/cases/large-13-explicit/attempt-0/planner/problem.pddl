(define (problem nuwakot-large-13)
  (:domain flood-rescue)

  (:objects
    kalika-shelter dhunche-hospital kakani-village benighat-farm syaphru-care-home
    gosaikunda-village jwalamukhi-school belkot-farm gajuri-farm dupcheshwar-temple
    naukunda-market - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; cars
    (car-at car1 kalika-shelter)
    (car-at car2 dhunche-hospital)
    (free-seats car1 n4)
    (free-seats car2 n4)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; evacuation points
    (evac-point kalika-shelter)
    (evac-point dhunche-hospital)

    ;; roads (both directions), travel times
    (road kalika-shelter kakani-village) (= (travel-time kalika-shelter kakani-village) 14)
    (road kakani-village kalika-shelter) (= (travel-time kakani-village kalika-shelter) 14)

    (road kalika-shelter benighat-farm) (= (travel-time kalika-shelter benighat-farm) 27)
    (road benighat-farm kalika-shelter) (= (travel-time benighat-farm kalika-shelter) 27)

    (road kalika-shelter syaphru-care-home) (= (travel-time kalika-shelter syaphru-care-home) 14)
    (road syaphru-care-home kalika-shelter) (= (travel-time syaphru-care-home kalika-shelter) 14)
    (damaged kalika-shelter syaphru-care-home)
    (damaged syaphru-care-home kalika-shelter)

    (road dhunche-hospital gosaikunda-village) (= (travel-time dhunche-hospital gosaikunda-village) 23)
    (road gosaikunda-village dhunche-hospital) (= (travel-time gosaikunda-village dhunche-hospital) 23)

    (road dhunche-hospital jwalamukhi-school) (= (travel-time dhunche-hospital jwalamukhi-school) 9)
    (road jwalamukhi-school dhunche-hospital) (= (travel-time jwalamukhi-school dhunche-hospital) 9)

    (road kakani-village benighat-farm) (= (travel-time kakani-village benighat-farm) 16)
    (road benighat-farm kakani-village) (= (travel-time benighat-farm kakani-village) 16)

    (road kakani-village syaphru-care-home) (= (travel-time kakani-village syaphru-care-home) 22)
    (road syaphru-care-home kakani-village) (= (travel-time syaphru-care-home kakani-village) 22)

    (road belkot-farm gajuri-farm) (= (travel-time belkot-farm gajuri-farm) 21)
    (road gajuri-farm belkot-farm) (= (travel-time gajuri-farm belkot-farm) 21)
    (damaged belkot-farm gajuri-farm)
    (damaged gajuri-farm belkot-farm)

    (road belkot-farm gosaikunda-village) (= (travel-time belkot-farm gosaikunda-village) 5)
    (road gosaikunda-village belkot-farm) (= (travel-time gosaikunda-village belkot-farm) 5)

    (road belkot-farm dupcheshwar-temple) (= (travel-time belkot-farm dupcheshwar-temple) 13)
    (road dupcheshwar-temple belkot-farm) (= (travel-time dupcheshwar-temple belkot-farm) 13)

    (road naukunda-market benighat-farm) (= (travel-time naukunda-market benighat-farm) 5)
    (road benighat-farm naukunda-market) (= (travel-time benighat-farm naukunda-market) 5)

    (road naukunda-market syaphru-care-home) (= (travel-time naukunda-market syaphru-care-home) 25)
    (road syaphru-care-home naukunda-market) (= (travel-time syaphru-care-home naukunda-market) 25)

    (road naukunda-market jwalamukhi-school) (= (travel-time naukunda-market jwalamukhi-school) 18)
    (road jwalamukhi-school naukunda-market) (= (travel-time jwalamukhi-school naukunda-market) 18)

    (road benighat-farm jwalamukhi-school) (= (travel-time benighat-farm jwalamukhi-school) 20)
    (road jwalamukhi-school benighat-farm) (= (travel-time jwalamukhi-school benighat-farm) 20)

    (road gajuri-farm syaphru-care-home) (= (travel-time gajuri-farm syaphru-care-home) 37)
    (road syaphru-care-home gajuri-farm) (= (travel-time syaphru-care-home gajuri-farm) 37)

    (road gosaikunda-village dupcheshwar-temple) (= (travel-time gosaikunda-village dupcheshwar-temple) 11)
    (road dupcheshwar-temple gosaikunda-village) (= (travel-time dupcheshwar-temple gosaikunda-village) 11)
    (damaged gosaikunda-village dupcheshwar-temple)
    (damaged dupcheshwar-temple gosaikunda-village)

    ;; people waiting
    (waiting gosaikunda-village injured n4)
    (waiting gosaikunda-village adult n2)
    (waiting gosaikunda-village child n3)
    (waiting kakani-village injured n3)
    (waiting kakani-village child n1)
    (waiting jwalamukhi-school injured n3)
    (waiting jwalamukhi-school child n2)
    (waiting naukunda-market adult n3)

    ;; arithmetic over n0..n4
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)
    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; deferral penalties: per-person penalty x N
    (= (defer-cost injured n1) 80)   (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)  (= (defer-cost injured n4) 320)
    (= (defer-cost child n1) 60)     (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)    (= (defer-cost child n4) 240)
    (= (defer-cost elderly n1) 50)   (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)  (= (defer-cost elderly n4) 200)
    (= (defer-cost adult n1) 20)     (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)     (= (defer-cost adult n4) 80)

    (= (total-cost) 0)
  )

  (:goal (and
    ;; everyone waiting is rescued or deferred
    (waiting gosaikunda-village injured n0)
    (waiting gosaikunda-village adult n0)
    (waiting gosaikunda-village child n0)
    (waiting kakani-village injured n0)
    (waiting kakani-village child n0)
    (waiting jwalamukhi-school injured n0)
    (waiting jwalamukhi-school child n0)
    (waiting naukunda-market adult n0)

    ;; cars end empty
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
