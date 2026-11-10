(define (problem large-08)
  (:domain flood-rescue)

  (:objects
    kakani-shelter kalika-hospital naukunda-school suryagadhi-care-home
    likhu-farm gajuri-temple thakre-temple panchakanya-care-home
    syaphru-village belkot-school benighat-temple - location
    car1 car2 - car
    n1 n2 n3 n4 n5 - level)

  (:init
    (= (total-cost) 0)

    ;; Evacuation points
    (evac-point kakani-shelter)
    (evac-point kalika-hospital)

    ;; Cars
    (car-at car1 kakani-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 kalika-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; Roads
    ;; kakani-shelter <-> kalika-hospital (damaged)
    (road kakani-shelter kalika-hospital)
    (road kalika-hospital kakani-shelter)
    (= (travel-time kakani-shelter kalika-hospital) 5)
    (= (travel-time kalika-hospital kakani-shelter) 5)
    (damaged kakani-shelter kalika-hospital)
    (damaged kalika-hospital kakani-shelter)

    ;; kalika-hospital <-> suryagadhi-care-home
    (road kalika-hospital suryagadhi-care-home)
    (road suryagadhi-care-home kalika-hospital)
    (= (travel-time kalika-hospital suryagadhi-care-home) 22)
    (= (travel-time suryagadhi-care-home kalika-hospital) 22)

    ;; likhu-farm <-> gajuri-temple
    (road likhu-farm gajuri-temple)
    (road gajuri-temple likhu-farm)
    (= (travel-time likhu-farm gajuri-temple) 20)
    (= (travel-time gajuri-temple likhu-farm) 20)

    ;; thakre-temple <-> panchakanya-care-home (damaged)
    (road thakre-temple panchakanya-care-home)
    (road panchakanya-care-home thakre-temple)
    (= (travel-time thakre-temple panchakanya-care-home) 11)
    (= (travel-time panchakanya-care-home thakre-temple) 11)
    (damaged thakre-temple panchakanya-care-home)
    (damaged panchakanya-care-home thakre-temple)

    ;; kakani-shelter <-> suryagadhi-care-home
    (road kakani-shelter suryagadhi-care-home)
    (road suryagadhi-care-home kakani-shelter)
    (= (travel-time kakani-shelter suryagadhi-care-home) 18)
    (= (travel-time suryagadhi-care-home kakani-shelter) 18)

    ;; likhu-farm <-> suryagadhi-care-home
    (road likhu-farm suryagadhi-care-home)
    (road suryagadhi-care-home likhu-farm)
    (= (travel-time likhu-farm suryagadhi-care-home) 5)
    (= (travel-time suryagadhi-care-home likhu-farm) 5)

    ;; suryagadhi-care-home <-> gajuri-temple
    (road suryagadhi-care-home gajuri-temple)
    (road gajuri-temple suryagadhi-care-home)
    (= (travel-time suryagadhi-care-home gajuri-temple) 17)
    (= (travel-time gajuri-temple suryagadhi-care-home) 17)

    ;; kakani-shelter <-> likhu-farm (damaged)
    (road kakani-shelter likhu-farm)
    (road likhu-farm kakani-shelter)
    (= (travel-time kakani-shelter likhu-farm) 21)
    (= (travel-time likhu-farm kakani-shelter) 21)
    (damaged kakani-shelter likhu-farm)
    (damaged likhu-farm kakani-shelter)

    ;; suryagadhi-care-home <-> syaphru-village
    (road suryagadhi-care-home syaphru-village)
    (road syaphru-village suryagadhi-care-home)
    (= (travel-time suryagadhi-care-home syaphru-village) 17)
    (= (travel-time syaphru-village suryagadhi-care-home) 17)

    ;; panchakanya-care-home <-> syaphru-village
    (road panchakanya-care-home syaphru-village)
    (road syaphru-village panchakanya-care-home)
    (= (travel-time panchakanya-care-home syaphru-village) 28)
    (= (travel-time syaphru-village panchakanya-care-home) 28)

    ;; kalika-hospital <-> belkot-school
    (road kalika-hospital belkot-school)
    (road belkot-school kalika-hospital)
    (= (travel-time kalika-hospital belkot-school) 16)
    (= (travel-time belkot-school kalika-hospital) 16)

    ;; kalika-hospital <-> gajuri-temple
    (road kalika-hospital gajuri-temple)
    (road gajuri-temple kalika-hospital)
    (= (travel-time kalika-hospital gajuri-temple) 10)
    (= (travel-time gajuri-temple kalika-hospital) 10)

    ;; thakre-temple <-> benighat-temple
    (road thakre-temple benighat-temple)
    (road benighat-temple thakre-temple)
    (= (travel-time thakre-temple benighat-temple) 5)
    (= (travel-time benighat-temple thakre-temple) 5)

    ;; kakani-shelter <-> belkot-school (damaged)
    (road kakani-shelter belkot-school)
    (road belkot-school kakani-shelter)
    (= (travel-time kakani-shelter belkot-school) 18)
    (= (travel-time belkot-school kakani-shelter) 18)
    (damaged kakani-shelter belkot-school)
    (damaged belkot-school kakani-shelter)

    ;; kalika-hospital <-> naukunda-school
    (road kalika-hospital naukunda-school)
    (road naukunda-school kalika-hospital)
    (= (travel-time kalika-hospital naukunda-school) 25)
    (= (travel-time naukunda-school kalika-hospital) 25)

    ;; kalika-hospital <-> benighat-temple
    (road kalika-hospital benighat-temple)
    (road benighat-temple kalika-hospital)
    (= (travel-time kalika-hospital benighat-temple) 36)
    (= (travel-time benighat-temple kalika-hospital) 36)

    ;; Waiting people
    (waiting suryagadhi-care-home elderly n2)
    (waiting belkot-school child n5)
    (waiting syaphru-village child n4)
    (waiting syaphru-village adult n3)
    (waiting panchakanya-care-home elderly n2)
    (waiting thakre-temple elderly n1)

    ;; Level arithmetic: a + b = c
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4) (sum n0 n5 n5)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4) (sum n1 n4 n5)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5)
    (sum n4 n0 n4) (sum n4 n1 n5)
    (sum n5 n0 n5)

    (positive n1) (positive n2) (positive n3) (positive n4) (positive n5)

    ;; Deferral penalties
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400)

    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300)

    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250)

    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100)
  )

  (:goal (and
    (waiting suryagadhi-care-home elderly n0)
    (waiting belkot-school child n0)
    (waiting syaphru-village child n0)
    (waiting syaphru-village adult n0)
    (waiting panchakanya-care-home elderly n0)
    (waiting thakre-temple elderly n0)

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
