;; Problem: Nuwakot district flood response (scenario large-04)
;; Assumption: floodwater-swept roads (shivapuri-shelter <-> bidur-school and
;; kakani-farm <-> syaphru-village) are marked damaged, since vehicles are being swept off them.
;; Bidur school is not a designated evacuation point and is not marked as one.

(define (problem flood-rescue-large-04)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    shivapuri-shelter trishuli-hospital bidur-school jwalamukhi-care-home
    belkot-care-home kakani-farm thakre-care-home benighat-farm
    dupcheshwar-village syaphru-village kispang-farm likhu-care-home
    panchakanya-temple kalika-village - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; ---- Evacuation points ----
    (evac-point shivapuri-shelter)
    (evac-point trishuli-hospital)

    ;; ---- Cars ----
    (car-at car1 shivapuri-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 trishuli-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; ---- Usable roads (both directions) ----
    (road shivapuri-shelter jwalamukhi-care-home)
    (= (travel-time shivapuri-shelter jwalamukhi-care-home) 18)
    (road jwalamukhi-care-home shivapuri-shelter)
    (= (travel-time jwalamukhi-care-home shivapuri-shelter) 18)

    (road bidur-school belkot-care-home)
    (= (travel-time bidur-school belkot-care-home) 10)
    (road belkot-care-home bidur-school)
    (= (travel-time belkot-care-home bidur-school) 10)

    (road benighat-farm dupcheshwar-village)
    (= (travel-time benighat-farm dupcheshwar-village) 12)
    (road dupcheshwar-village benighat-farm)
    (= (travel-time dupcheshwar-village benighat-farm) 12)

    (road syaphru-village belkot-care-home)
    (= (travel-time syaphru-village belkot-care-home) 20)
    (road belkot-care-home syaphru-village)
    (= (travel-time belkot-care-home syaphru-village) 20)

    (road trishuli-hospital syaphru-village)
    (= (travel-time trishuli-hospital syaphru-village) 10)
    (road syaphru-village trishuli-hospital)
    (= (travel-time syaphru-village trishuli-hospital) 10)

    (road bidur-school thakre-care-home)
    (= (travel-time bidur-school thakre-care-home) 19)
    (road thakre-care-home bidur-school)
    (= (travel-time thakre-care-home bidur-school) 19)

    (road trishuli-hospital thakre-care-home)
    (= (travel-time trishuli-hospital thakre-care-home) 13)
    (road thakre-care-home trishuli-hospital)
    (= (travel-time thakre-care-home trishuli-hospital) 13)

    (road benighat-farm panchakanya-temple)
    (= (travel-time benighat-farm panchakanya-temple) 7)
    (road panchakanya-temple benighat-farm)
    (= (travel-time panchakanya-temple benighat-farm) 7)

    (road belkot-care-home thakre-care-home)
    (= (travel-time belkot-care-home thakre-care-home) 15)
    (road thakre-care-home belkot-care-home)
    (= (travel-time thakre-care-home belkot-care-home) 15)

    (road kispang-farm likhu-care-home)
    (= (travel-time kispang-farm likhu-care-home) 10)
    (road likhu-care-home kispang-farm)
    (= (travel-time likhu-care-home kispang-farm) 10)

    (road syaphru-village thakre-care-home)
    (= (travel-time syaphru-village thakre-care-home) 8)
    (road thakre-care-home syaphru-village)
    (= (travel-time thakre-care-home syaphru-village) 8)

    (road dupcheshwar-village panchakanya-temple)
    (= (travel-time dupcheshwar-village panchakanya-temple) 5)
    (road panchakanya-temple dupcheshwar-village)
    (= (travel-time panchakanya-temple dupcheshwar-village) 5)

    ;; ---- Damaged roads (listed for completeness, cannot be used) ----
    ;; Floodwater, swept-away vehicle
    (road shivapuri-shelter bidur-school)
    (= (travel-time shivapuri-shelter bidur-school) 11)
    (damaged shivapuri-shelter bidur-school)
    (road bidur-school shivapuri-shelter)
    (= (travel-time bidur-school shivapuri-shelter) 11)
    (damaged bidur-school shivapuri-shelter)

    ;; Closed by police (collapse)
    (road jwalamukhi-care-home belkot-care-home)
    (= (travel-time jwalamukhi-care-home belkot-care-home) 21)
    (damaged jwalamukhi-care-home belkot-care-home)
    (road belkot-care-home jwalamukhi-care-home)
    (= (travel-time belkot-care-home jwalamukhi-care-home) 21)
    (damaged belkot-care-home jwalamukhi-care-home)

    ;; Landslide
    (road kakani-farm thakre-care-home)
    (= (travel-time kakani-farm thakre-care-home) 7)
    (damaged kakani-farm thakre-care-home)
    (road thakre-care-home kakani-farm)
    (= (travel-time thakre-care-home kakani-farm) 7)
    (damaged thakre-care-home kakani-farm)

    ;; Landslide
    (road jwalamukhi-care-home dupcheshwar-village)
    (= (travel-time jwalamukhi-care-home dupcheshwar-village) 22)
    (damaged jwalamukhi-care-home dupcheshwar-village)
    (road dupcheshwar-village jwalamukhi-care-home)
    (= (travel-time dupcheshwar-village jwalamukhi-care-home) 22)
    (damaged dupcheshwar-village jwalamukhi-care-home)

    ;; Floodwater, swept-away vehicle
    (road kakani-farm syaphru-village)
    (= (travel-time kakani-farm syaphru-village) 5)
    (damaged kakani-farm syaphru-village)
    (road syaphru-village kakani-farm)
    (= (travel-time syaphru-village kakani-farm) 5)
    (damaged syaphru-village kakani-farm)

    ;; Bridge washed away
    (road kalika-village likhu-care-home)
    (= (travel-time kalika-village likhu-care-home) 16)
    (damaged kalika-village likhu-care-home)
    (road likhu-care-home kalika-village)
    (= (travel-time likhu-care-home kalika-village) 16)
    (damaged likhu-care-home kalika-village)

    ;; Landslide
    (road shivapuri-shelter belkot-care-home)
    (= (travel-time shivapuri-shelter belkot-care-home) 5)
    (damaged shivapuri-shelter belkot-care-home)
    (road belkot-care-home shivapuri-shelter)
    (= (travel-time belkot-care-home shivapuri-shelter) 5)
    (damaged belkot-care-home shivapuri-shelter)

    ;; Landslide
    (road syaphru-village likhu-care-home)
    (= (travel-time syaphru-village likhu-care-home) 52)
    (damaged syaphru-village likhu-care-home)
    (road likhu-care-home syaphru-village)
    (= (travel-time likhu-care-home syaphru-village) 52)
    (damaged likhu-care-home syaphru-village)

    ;; ---- Stranded civilians ----
    (waiting syaphru-village adult n2)
    (waiting thakre-care-home elderly n1)
    (waiting thakre-care-home injured n1)
    (waiting kakani-farm adult n3)
    (waiting jwalamukhi-care-home elderly n4)
    (waiting bidur-school injured n1)
    (waiting kispang-farm adult n4)
    (waiting benighat-farm child n4)
    (waiting kalika-village adult n3)
    (waiting belkot-care-home elderly n3)

    ;; ---- Level arithmetic ----
    (sum n0 n0 n0)
    (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n2 n0 n2) (sum n3 n0 n3) (sum n4 n0 n4)
    (sum n1 n1 n2) (sum n1 n2 n3) (sum n2 n1 n3)
    (sum n1 n3 n4) (sum n3 n1 n4) (sum n2 n2 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; ---- Deferral penalties: per-person penalty x N ----
    ;; injured 80
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    ;; child 60
    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    ;; elderly 50
    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    ;; adult 20
    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)

    (= (total-cost) 0)
  )

  (:goal (and
    ;; Everyone waiting is either rescued or deferred
    (waiting syaphru-village adult n0)
    (waiting thakre-care-home elderly n0)
    (waiting thakre-care-home injured n0)
    (waiting kakani-farm adult n0)
    (waiting jwalamukhi-care-home elderly n0)
    (waiting bidur-school injured n0)
    (waiting kispang-farm adult n0)
    (waiting benighat-farm child n0)
    (waiting kalika-village adult n0)
    (waiting belkot-care-home elderly n0)

    ;; Both cars end up empty
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
