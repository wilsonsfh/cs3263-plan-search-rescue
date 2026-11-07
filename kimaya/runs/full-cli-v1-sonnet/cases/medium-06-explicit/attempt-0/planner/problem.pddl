(define (problem flood-rescue-medium-06)
  (:domain flood-rescue)

  (:objects
    jwalamukhi-shelter gajuri-school belkot-farm syaphru-care-home suryagadhi-market nilkantha-temple kalika-temple - location
    car1 - car
    n1 n2 n3 n4 n5 n6 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road jwalamukhi-shelter gajuri-school) (road gajuri-school jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter gajuri-school) 19)
    (= (travel-time gajuri-school jwalamukhi-shelter) 19)

    (road jwalamukhi-shelter belkot-farm) (road belkot-farm jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter belkot-farm) 20)
    (= (travel-time belkot-farm jwalamukhi-shelter) 20)

    (road jwalamukhi-shelter syaphru-care-home) (road syaphru-care-home jwalamukhi-shelter)
    (= (travel-time jwalamukhi-shelter syaphru-care-home) 56)
    (= (travel-time syaphru-care-home jwalamukhi-shelter) 56)
    (damaged jwalamukhi-shelter syaphru-care-home) (damaged syaphru-care-home jwalamukhi-shelter)

    (road suryagadhi-market nilkantha-temple) (road nilkantha-temple suryagadhi-market)
    (= (travel-time suryagadhi-market nilkantha-temple) 5)
    (= (travel-time nilkantha-temple suryagadhi-market) 5)

    (road gajuri-school belkot-farm) (road belkot-farm gajuri-school)
    (= (travel-time gajuri-school belkot-farm) 19)
    (= (travel-time belkot-farm gajuri-school) 19)

    (road gajuri-school kalika-temple) (road kalika-temple gajuri-school)
    (= (travel-time gajuri-school kalika-temple) 19)
    (= (travel-time kalika-temple gajuri-school) 19)

    (road belkot-farm kalika-temple) (road kalika-temple belkot-farm)
    (= (travel-time belkot-farm kalika-temple) 23)
    (= (travel-time kalika-temple belkot-farm) 23)
    (damaged belkot-farm kalika-temple) (damaged kalika-temple belkot-farm)

    (road syaphru-care-home kalika-temple) (road kalika-temple syaphru-care-home)
    (= (travel-time syaphru-care-home kalika-temple) 30)
    (= (travel-time kalika-temple syaphru-care-home) 30)

    (road kalika-temple nilkantha-temple) (road nilkantha-temple kalika-temple)
    (= (travel-time kalika-temple nilkantha-temple) 12)
    (= (travel-time nilkantha-temple kalika-temple) 12)
    (damaged kalika-temple nilkantha-temple) (damaged nilkantha-temple kalika-temple)

    ;; evacuation points
    (evac-point jwalamukhi-shelter)

    ;; car
    (car-at car1 jwalamukhi-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; people
    (waiting kalika-temple elderly n6)
    (waiting nilkantha-temple elderly n1)
    (waiting suryagadhi-market adult n1)
    (waiting syaphru-care-home injured n1)

    ;; positive
    (positive n1) (positive n2) (positive n3) (positive n4) (positive n5) (positive n6)

    ;; sums
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4) (sum n1 n4 n5) (sum n1 n5 n6)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5) (sum n2 n4 n6)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6)
    (sum n5 n0 n5) (sum n5 n1 n6)
    (sum n6 n0 n6)

    ;; defer costs
    (= (defer-cost injured n1) 80) (= (defer-cost injured n2) 160) (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320) (= (defer-cost injured n5) 400) (= (defer-cost injured n6) 480)
    (= (defer-cost child n1) 60) (= (defer-cost child n2) 120) (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240) (= (defer-cost child n5) 300) (= (defer-cost child n6) 360)
    (= (defer-cost elderly n1) 50) (= (defer-cost elderly n2) 100) (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200) (= (defer-cost elderly n5) 250) (= (defer-cost elderly n6) 300)
    (= (defer-cost adult n1) 20) (= (defer-cost adult n2) 40) (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80) (= (defer-cost adult n5) 100) (= (defer-cost adult n6) 120)
  )

  (:goal (and
    (waiting kalika-temple elderly n0)
    (waiting nilkantha-temple elderly n0)
    (waiting suryagadhi-market adult n0)
    (waiting syaphru-care-home injured n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
