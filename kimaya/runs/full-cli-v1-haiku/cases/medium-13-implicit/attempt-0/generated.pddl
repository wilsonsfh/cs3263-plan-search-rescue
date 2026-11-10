(define (problem nuwakot-medium-13)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    tarkeshwar-shelter dhunche-village panchakanya-temple kalika-farm
    gajuri-farm trishuli-care-home nilkantha-temple gosaikunda-care-home - location
    car1 - car
    n1 n2 n3 n4 n5 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions), travel times, and damaged roads
    (road tarkeshwar-shelter dhunche-village)
    (road dhunche-village tarkeshwar-shelter)
    (= (travel-time tarkeshwar-shelter dhunche-village) 11)
    (= (travel-time dhunche-village tarkeshwar-shelter) 11)

    (road kalika-farm gajuri-farm)
    (road gajuri-farm kalika-farm)
    (= (travel-time kalika-farm gajuri-farm) 21)
    (= (travel-time gajuri-farm kalika-farm) 21)

    (road panchakanya-temple gajuri-farm)
    (road gajuri-farm panchakanya-temple)
    (= (travel-time panchakanya-temple gajuri-farm) 16)
    (= (travel-time gajuri-farm panchakanya-temple) 16)

    (road kalika-farm panchakanya-temple)
    (road panchakanya-temple kalika-farm)
    (= (travel-time kalika-farm panchakanya-temple) 7)
    (= (travel-time panchakanya-temple kalika-farm) 7)
    (damaged kalika-farm panchakanya-temple)
    (damaged panchakanya-temple kalika-farm)

    (road trishuli-care-home gajuri-farm)
    (road gajuri-farm trishuli-care-home)
    (= (travel-time trishuli-care-home gajuri-farm) 5)
    (= (travel-time gajuri-farm trishuli-care-home) 5)

    (road dhunche-village gajuri-farm)
    (road gajuri-farm dhunche-village)
    (= (travel-time dhunche-village gajuri-farm) 21)
    (= (travel-time gajuri-farm dhunche-village) 21)

    (road trishuli-care-home nilkantha-temple)
    (road nilkantha-temple trishuli-care-home)
    (= (travel-time trishuli-care-home nilkantha-temple) 7)
    (= (travel-time nilkantha-temple trishuli-care-home) 7)
    (damaged trishuli-care-home nilkantha-temple)
    (damaged nilkantha-temple trishuli-care-home)

    (road kalika-farm dhunche-village)
    (road dhunche-village kalika-farm)
    (= (travel-time kalika-farm dhunche-village) 40)
    (= (travel-time dhunche-village kalika-farm) 40)
    (damaged kalika-farm dhunche-village)
    (damaged dhunche-village kalika-farm)

    (road kalika-farm gosaikunda-care-home)
    (road gosaikunda-care-home kalika-farm)
    (= (travel-time kalika-farm gosaikunda-care-home) 27)
    (= (travel-time gosaikunda-care-home kalika-farm) 27)

    (road kalika-farm nilkantha-temple)
    (road nilkantha-temple kalika-farm)
    (= (travel-time kalika-farm nilkantha-temple) 20)
    (= (travel-time nilkantha-temple kalika-farm) 20)

    ;; Evacuation points
    (evac-point tarkeshwar-shelter)

    ;; Car
    (car-at car1 tarkeshwar-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting dhunche-village injured n1)
    (waiting dhunche-village child n2)
    (waiting gajuri-farm adult n5)
    (waiting gosaikunda-care-home adult n3)

    ;; Sum relation a + b = c for a, b, c in n0..n5
    (sum n0 n0 n0)
    (sum n0 n1 n1) (sum n1 n0 n1)
    (sum n0 n2 n2) (sum n2 n0 n2)
    (sum n0 n3 n3) (sum n3 n0 n3)
    (sum n0 n4 n4) (sum n4 n0 n4)
    (sum n0 n5 n5) (sum n5 n0 n5)
    (sum n1 n1 n2)
    (sum n1 n2 n3) (sum n2 n1 n3)
    (sum n1 n3 n4) (sum n3 n1 n4)
    (sum n1 n4 n5) (sum n4 n1 n5)
    (sum n2 n2 n4)
    (sum n2 n3 n5) (sum n3 n2 n5)

    ;; Positive levels
    (positive n1) (positive n2) (positive n3) (positive n4) (positive n5)

    ;; Deferral penalties: per-person penalty x N
    ;; injured: 80
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400)
    ;; child: 60
    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300)
    ;; elderly: 50
    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250)
    ;; adult: 20
    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100)
  )

  (:goal (and
    ;; Everyone waiting is rescued or deferred
    (waiting dhunche-village injured n0)
    (waiting dhunche-village child n0)
    (waiting gajuri-farm adult n0)
    (waiting gosaikunda-care-home adult n0)

    ;; Car has unloaded everyone it carried
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
