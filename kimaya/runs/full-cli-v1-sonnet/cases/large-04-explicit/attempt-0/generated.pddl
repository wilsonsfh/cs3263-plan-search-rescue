(define (problem flood-rescue-large-04)
  (:domain flood-rescue)

  (:objects
    shivapuri-shelter trishuli-hospital bidur-school jwalamukhi-care-home
    belkot-care-home syaphru-village thakre-care-home benighat-farm
    dupcheshwar-village panchakanya-temple kakani-farm likhu-care-home
    kalika-village kispang-farm - location
    car1 car2 - car
    n1 n2 n3 n4 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road shivapuri-shelter bidur-school) (road bidur-school shivapuri-shelter)
    (= (travel-time shivapuri-shelter bidur-school) 11) (= (travel-time bidur-school shivapuri-shelter) 11)
    (damaged shivapuri-shelter bidur-school) (damaged bidur-school shivapuri-shelter)

    (road shivapuri-shelter jwalamukhi-care-home) (road jwalamukhi-care-home shivapuri-shelter)
    (= (travel-time shivapuri-shelter jwalamukhi-care-home) 18) (= (travel-time jwalamukhi-care-home shivapuri-shelter) 18)

    (road shivapuri-shelter belkot-care-home) (road belkot-care-home shivapuri-shelter)
    (= (travel-time shivapuri-shelter belkot-care-home) 5) (= (travel-time belkot-care-home shivapuri-shelter) 5)
    (damaged shivapuri-shelter belkot-care-home) (damaged belkot-care-home shivapuri-shelter)

    (road trishuli-hospital syaphru-village) (road syaphru-village trishuli-hospital)
    (= (travel-time trishuli-hospital syaphru-village) 10) (= (travel-time syaphru-village trishuli-hospital) 10)

    (road trishuli-hospital thakre-care-home) (road thakre-care-home trishuli-hospital)
    (= (travel-time trishuli-hospital thakre-care-home) 13) (= (travel-time thakre-care-home trishuli-hospital) 13)

    (road benighat-farm dupcheshwar-village) (road dupcheshwar-village benighat-farm)
    (= (travel-time benighat-farm dupcheshwar-village) 12) (= (travel-time dupcheshwar-village benighat-farm) 12)

    (road benighat-farm panchakanya-temple) (road panchakanya-temple benighat-farm)
    (= (travel-time benighat-farm panchakanya-temple) 7) (= (travel-time panchakanya-temple benighat-farm) 7)

    (road bidur-school belkot-care-home) (road belkot-care-home bidur-school)
    (= (travel-time bidur-school belkot-care-home) 10) (= (travel-time belkot-care-home bidur-school) 10)

    (road bidur-school thakre-care-home) (road thakre-care-home bidur-school)
    (= (travel-time bidur-school thakre-care-home) 19) (= (travel-time thakre-care-home bidur-school) 19)

    (road jwalamukhi-care-home dupcheshwar-village) (road dupcheshwar-village jwalamukhi-care-home)
    (= (travel-time jwalamukhi-care-home dupcheshwar-village) 22) (= (travel-time dupcheshwar-village jwalamukhi-care-home) 22)
    (damaged jwalamukhi-care-home dupcheshwar-village) (damaged dupcheshwar-village jwalamukhi-care-home)

    (road jwalamukhi-care-home belkot-care-home) (road belkot-care-home jwalamukhi-care-home)
    (= (travel-time jwalamukhi-care-home belkot-care-home) 21) (= (travel-time belkot-care-home jwalamukhi-care-home) 21)
    (damaged jwalamukhi-care-home belkot-care-home) (damaged belkot-care-home jwalamukhi-care-home)

    (road kakani-farm syaphru-village) (road syaphru-village kakani-farm)
    (= (travel-time kakani-farm syaphru-village) 5) (= (travel-time syaphru-village kakani-farm) 5)
    (damaged kakani-farm syaphru-village) (damaged syaphru-village kakani-farm)

    (road kakani-farm thakre-care-home) (road thakre-care-home kakani-farm)
    (= (travel-time kakani-farm thakre-care-home) 7) (= (travel-time thakre-care-home kakani-farm) 7)
    (damaged kakani-farm thakre-care-home) (damaged thakre-care-home kakani-farm)

    (road dupcheshwar-village panchakanya-temple) (road panchakanya-temple dupcheshwar-village)
    (= (travel-time dupcheshwar-village panchakanya-temple) 5) (= (travel-time panchakanya-temple dupcheshwar-village) 5)

    (road syaphru-village belkot-care-home) (road belkot-care-home syaphru-village)
    (= (travel-time syaphru-village belkot-care-home) 20) (= (travel-time belkot-care-home syaphru-village) 20)

    (road syaphru-village thakre-care-home) (road thakre-care-home syaphru-village)
    (= (travel-time syaphru-village thakre-care-home) 8) (= (travel-time thakre-care-home syaphru-village) 8)

    (road syaphru-village likhu-care-home) (road likhu-care-home syaphru-village)
    (= (travel-time syaphru-village likhu-care-home) 52) (= (travel-time likhu-care-home syaphru-village) 52)
    (damaged syaphru-village likhu-care-home) (damaged likhu-care-home syaphru-village)

    (road belkot-care-home thakre-care-home) (road thakre-care-home belkot-care-home)
    (= (travel-time belkot-care-home thakre-care-home) 15) (= (travel-time thakre-care-home belkot-care-home) 15)

    (road kalika-village likhu-care-home) (road likhu-care-home kalika-village)
    (= (travel-time kalika-village likhu-care-home) 16) (= (travel-time likhu-care-home kalika-village) 16)
    (damaged kalika-village likhu-care-home) (damaged likhu-care-home kalika-village)

    (road kispang-farm likhu-care-home) (road likhu-care-home kispang-farm)
    (= (travel-time kispang-farm likhu-care-home) 10) (= (travel-time likhu-care-home kispang-farm) 10)

    ;; evacuation points
    (evac-point shivapuri-shelter)
    (evac-point trishuli-hospital)

    ;; cars
    (car-at car1 shivapuri-shelter)
    (car-at car2 trishuli-hospital)
    (free-seats car1 n4)
    (free-seats car2 n4)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; people waiting
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

    ;; arithmetic
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)
    (positive n1) (positive n2) (positive n3) (positive n4)

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
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
