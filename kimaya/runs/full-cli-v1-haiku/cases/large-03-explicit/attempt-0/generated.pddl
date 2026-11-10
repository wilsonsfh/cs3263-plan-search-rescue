(define (problem flood-large-03)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    benighat-shelter gajuri-hospital likhu-temple trishuli-farm gosaikunda-village
    syaphru-school kalika-care-home naukunda-village suryagadhi-farm kispang-care-home
    dupcheshwar-farm shivapuri-school - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    ;; roads (both directions)
    (road benighat-shelter gajuri-hospital) (road gajuri-hospital benighat-shelter)
    (road benighat-shelter likhu-temple) (road likhu-temple benighat-shelter)
    (road benighat-shelter trishuli-farm) (road trishuli-farm benighat-shelter)
    (road benighat-shelter gosaikunda-village) (road gosaikunda-village benighat-shelter)
    (road benighat-shelter syaphru-school) (road syaphru-school benighat-shelter)
    (road benighat-shelter kalika-care-home) (road kalika-care-home benighat-shelter)
    (road gajuri-hospital naukunda-village) (road naukunda-village gajuri-hospital)
    (road gajuri-hospital suryagadhi-farm) (road suryagadhi-farm gajuri-hospital)
    (road gajuri-hospital trishuli-farm) (road trishuli-farm gajuri-hospital)
    (road gajuri-hospital kispang-care-home) (road kispang-care-home gajuri-hospital)
    (road likhu-temple syaphru-school) (road syaphru-school likhu-temple)
    (road dupcheshwar-farm kispang-care-home) (road kispang-care-home dupcheshwar-farm)
    (road shivapuri-school kalika-care-home) (road kalika-care-home shivapuri-school)
    (road naukunda-village trishuli-farm) (road trishuli-farm naukunda-village)
    (road naukunda-village gosaikunda-village) (road gosaikunda-village naukunda-village)
    (road suryagadhi-farm trishuli-farm) (road trishuli-farm suryagadhi-farm)
    (road trishuli-farm gosaikunda-village) (road gosaikunda-village trishuli-farm)

    ;; travel times (both directions)
    (= (travel-time benighat-shelter gajuri-hospital) 20) (= (travel-time gajuri-hospital benighat-shelter) 20)
    (= (travel-time benighat-shelter likhu-temple) 10) (= (travel-time likhu-temple benighat-shelter) 10)
    (= (travel-time benighat-shelter trishuli-farm) 11) (= (travel-time trishuli-farm benighat-shelter) 11)
    (= (travel-time benighat-shelter gosaikunda-village) 11) (= (travel-time gosaikunda-village benighat-shelter) 11)
    (= (travel-time benighat-shelter syaphru-school) 10) (= (travel-time syaphru-school benighat-shelter) 10)
    (= (travel-time benighat-shelter kalika-care-home) 15) (= (travel-time kalika-care-home benighat-shelter) 15)
    (= (travel-time gajuri-hospital naukunda-village) 10) (= (travel-time naukunda-village gajuri-hospital) 10)
    (= (travel-time gajuri-hospital suryagadhi-farm) 10) (= (travel-time suryagadhi-farm gajuri-hospital) 10)
    (= (travel-time gajuri-hospital trishuli-farm) 8) (= (travel-time trishuli-farm gajuri-hospital) 8)
    (= (travel-time gajuri-hospital kispang-care-home) 31) (= (travel-time kispang-care-home gajuri-hospital) 31)
    (= (travel-time likhu-temple syaphru-school) 5) (= (travel-time syaphru-school likhu-temple) 5)
    (= (travel-time dupcheshwar-farm kispang-care-home) 21) (= (travel-time kispang-care-home dupcheshwar-farm) 21)
    (= (travel-time shivapuri-school kalika-care-home) 14) (= (travel-time kalika-care-home shivapuri-school) 14)
    (= (travel-time naukunda-village trishuli-farm) 7) (= (travel-time trishuli-farm naukunda-village) 7)
    (= (travel-time naukunda-village gosaikunda-village) 5) (= (travel-time gosaikunda-village naukunda-village) 5)
    (= (travel-time suryagadhi-farm trishuli-farm) 7) (= (travel-time trishuli-farm suryagadhi-farm) 7)
    (= (travel-time trishuli-farm gosaikunda-village) 10) (= (travel-time gosaikunda-village trishuli-farm) 10)

    ;; damaged roads (both directions)
    (damaged benighat-shelter trishuli-farm) (damaged trishuli-farm benighat-shelter)
    (damaged benighat-shelter syaphru-school) (damaged syaphru-school benighat-shelter)
    (damaged suryagadhi-farm trishuli-farm) (damaged trishuli-farm suryagadhi-farm)

    ;; evacuation points
    (evac-point benighat-shelter)
    (evac-point gajuri-hospital)

    ;; cars
    (car-at car1 benighat-shelter)
    (car-at car2 gajuri-hospital)
    (free-seats car1 n4)
    (free-seats car2 n4)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; people waiting
    (waiting suryagadhi-farm adult n6)
    (waiting kalika-care-home elderly n4)
    (waiting kalika-care-home injured n1)
    (waiting naukunda-village elderly n3)
    (waiting naukunda-village child n2)
    (waiting kispang-care-home elderly n5)
    (waiting shivapuri-school child n4)
    (waiting likhu-temple elderly n1)
    (waiting dupcheshwar-farm elderly n4)

    ;; arithmetic relations a + b = c
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4) (sum n1 n4 n5) (sum n1 n5 n6)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5) (sum n2 n4 n6)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6)
    (sum n5 n0 n5) (sum n5 n1 n6)
    (sum n6 n0 n6)

    (positive n1) (positive n2) (positive n3) (positive n4) (positive n5) (positive n6)

    ;; deferral penalties (per-person penalty x N)
    (= (defer-cost injured n1) 80)   (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)  (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400)  (= (defer-cost injured n6) 480)
    (= (defer-cost child n1) 60)     (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)    (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300)    (= (defer-cost child n6) 360)
    (= (defer-cost elderly n1) 50)   (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)  (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250)  (= (defer-cost elderly n6) 300)
    (= (defer-cost adult n1) 20)     (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)     (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100)    (= (defer-cost adult n6) 120)

    (= (total-cost) 0)
  )

  (:goal (and
    ;; everyone is either rescued or deferred
    (waiting suryagadhi-farm adult n0)
    (waiting kalika-care-home elderly n0)
    (waiting kalika-care-home injured n0)
    (waiting naukunda-village elderly n0)
    (waiting naukunda-village child n0)
    (waiting kispang-care-home elderly n0)
    (waiting shivapuri-school child n0)
    (waiting likhu-temple elderly n0)
    (waiting dupcheshwar-farm elderly n0)

    ;; cars end empty of people
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
