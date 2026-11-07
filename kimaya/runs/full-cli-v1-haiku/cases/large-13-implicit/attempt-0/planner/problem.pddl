(define (problem flood-rescue-large-13)
  (:domain flood-rescue)
  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    kalika-shelter dhunche-hospital jwalamukhi-school gajuri-farm
    syaphru-care-home benighat-farm belkot-farm dupcheshwar-temple
    kakani-village gosaikunda-village naukunda-market - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Levels: sums a + b = c within n0..n4
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)
    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; Evacuation points
    (evac-point kalika-shelter)
    (evac-point dhunche-hospital)

    ;; Roads (both directions), travel times, damaged roads
    (road dhunche-hospital jwalamukhi-school)
    (road jwalamukhi-school dhunche-hospital)
    (= (travel-time dhunche-hospital jwalamukhi-school) 9)
    (= (travel-time jwalamukhi-school dhunche-hospital) 9)

    (road gajuri-farm syaphru-care-home)
    (road syaphru-care-home gajuri-farm)
    (= (travel-time gajuri-farm syaphru-care-home) 37)
    (= (travel-time syaphru-care-home gajuri-farm) 37)

    (road kalika-shelter kakani-village)
    (road kakani-village kalika-shelter)
    (= (travel-time kalika-shelter kakani-village) 14)
    (= (travel-time kakani-village kalika-shelter) 14)

    (road kalika-shelter syaphru-care-home)
    (road syaphru-care-home kalika-shelter)
    (= (travel-time kalika-shelter syaphru-care-home) 14)
    (= (travel-time syaphru-care-home kalika-shelter) 14)
    (damaged kalika-shelter syaphru-care-home)
    (damaged syaphru-care-home kalika-shelter)

    (road benighat-farm jwalamukhi-school)
    (road jwalamukhi-school benighat-farm)
    (= (travel-time benighat-farm jwalamukhi-school) 20)
    (= (travel-time jwalamukhi-school benighat-farm) 20)

    (road kalika-shelter benighat-farm)
    (road benighat-farm kalika-shelter)
    (= (travel-time kalika-shelter benighat-farm) 27)
    (= (travel-time benighat-farm kalika-shelter) 27)

    (road belkot-farm dupcheshwar-temple)
    (road dupcheshwar-temple belkot-farm)
    (= (travel-time belkot-farm dupcheshwar-temple) 13)
    (= (travel-time dupcheshwar-temple belkot-farm) 13)

    (road kakani-village benighat-farm)
    (road benighat-farm kakani-village)
    (= (travel-time kakani-village benighat-farm) 16)
    (= (travel-time benighat-farm kakani-village) 16)

    (road kakani-village syaphru-care-home)
    (road syaphru-care-home kakani-village)
    (= (travel-time kakani-village syaphru-care-home) 22)
    (= (travel-time syaphru-care-home kakani-village) 22)

    (road dhunche-hospital gosaikunda-village)
    (road gosaikunda-village dhunche-hospital)
    (= (travel-time dhunche-hospital gosaikunda-village) 23)
    (= (travel-time gosaikunda-village dhunche-hospital) 23)

    (road naukunda-market syaphru-care-home)
    (road syaphru-care-home naukunda-market)
    (= (travel-time naukunda-market syaphru-care-home) 25)
    (= (travel-time syaphru-care-home naukunda-market) 25)

    (road gosaikunda-village dupcheshwar-temple)
    (road dupcheshwar-temple gosaikunda-village)
    (= (travel-time gosaikunda-village dupcheshwar-temple) 11)
    (= (travel-time dupcheshwar-temple gosaikunda-village) 11)
    (damaged gosaikunda-village dupcheshwar-temple)
    (damaged dupcheshwar-temple gosaikunda-village)

    (road belkot-farm gajuri-farm)
    (road gajuri-farm belkot-farm)
    (= (travel-time belkot-farm gajuri-farm) 21)
    (= (travel-time gajuri-farm belkot-farm) 21)
    (damaged belkot-farm gajuri-farm)
    (damaged gajuri-farm belkot-farm)

    (road belkot-farm gosaikunda-village)
    (road gosaikunda-village belkot-farm)
    (= (travel-time belkot-farm gosaikunda-village) 5)
    (= (travel-time gosaikunda-village belkot-farm) 5)

    (road naukunda-market benighat-farm)
    (road benighat-farm naukunda-market)
    (= (travel-time naukunda-market benighat-farm) 5)
    (= (travel-time benighat-farm naukunda-market) 5)

    (road naukunda-market jwalamukhi-school)
    (road jwalamukhi-school naukunda-market)
    (= (travel-time naukunda-market jwalamukhi-school) 18)
    (= (travel-time jwalamukhi-school naukunda-market) 18)

    ;; Cars
    (car-at car1 kalika-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 dhunche-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting gosaikunda-village injured n4)
    (waiting gosaikunda-village child n3)
    (waiting gosaikunda-village adult n2)

    (waiting kakani-village injured n3)
    (waiting kakani-village child n1)

    (waiting jwalamukhi-school injured n3)
    (waiting jwalamukhi-school child n2)

    (waiting naukunda-market adult n3)

    ;; Defer costs (per-person penalty x N)
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
    (waiting gosaikunda-village injured n0)
    (waiting gosaikunda-village child n0)
    (waiting gosaikunda-village adult n0)
    (waiting kakani-village injured n0)
    (waiting kakani-village child n0)
    (waiting jwalamukhi-school injured n0)
    (waiting jwalamukhi-school child n0)
    (waiting naukunda-market adult n0)

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
