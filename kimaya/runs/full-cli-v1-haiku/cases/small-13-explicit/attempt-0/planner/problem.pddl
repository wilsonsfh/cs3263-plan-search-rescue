(define (problem small-13)
  (:domain flood-rescue)

  (:objects
    car1 - car
    bidur-shelter nilkantha-market suryagadhi-farm belkot-village likhu-care-home - location
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads (both directions)
    (road bidur-shelter nilkantha-market)
    (road nilkantha-market bidur-shelter)
    (damaged bidur-shelter nilkantha-market)
    (damaged nilkantha-market bidur-shelter)
    (= (travel-time bidur-shelter nilkantha-market) 45)
    (= (travel-time nilkantha-market bidur-shelter) 45)

    (road bidur-shelter suryagadhi-farm)
    (road suryagadhi-farm bidur-shelter)
    (= (travel-time bidur-shelter suryagadhi-farm) 20)
    (= (travel-time suryagadhi-farm bidur-shelter) 20)

    (road belkot-village likhu-care-home)
    (road likhu-care-home belkot-village)
    (= (travel-time belkot-village likhu-care-home) 22)
    (= (travel-time likhu-care-home belkot-village) 22)

    (road likhu-care-home suryagadhi-farm)
    (road suryagadhi-farm likhu-care-home)
    (= (travel-time likhu-care-home suryagadhi-farm) 51)
    (= (travel-time suryagadhi-farm likhu-care-home) 51)

    (road nilkantha-market suryagadhi-farm)
    (road suryagadhi-farm nilkantha-market)
    (damaged nilkantha-market suryagadhi-farm)
    (damaged suryagadhi-farm nilkantha-market)
    (= (travel-time nilkantha-market suryagadhi-farm) 28)
    (= (travel-time suryagadhi-farm nilkantha-market) 28)

    ;; Evacuation points
    (evac-point bidur-shelter)

    ;; Car
    (car-at car1 bidur-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting belkot-village child n1)
    (waiting nilkantha-market adult n3)

    ;; Arithmetic over n0..n4
    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n1 n0 n1)
    (sum n0 n2 n2)
    (sum n2 n0 n2)
    (sum n0 n3 n3)
    (sum n3 n0 n3)
    (sum n0 n4 n4)
    (sum n4 n0 n4)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n2 n1 n3)
    (sum n1 n3 n4)
    (sum n3 n1 n4)
    (sum n2 n2 n4)

    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

    ;; Deferral penalties
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
    (waiting belkot-village child n0)
    (waiting nilkantha-market adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
