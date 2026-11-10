(define (problem small-02)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    shivapuri-shelter kalika-village trishuli-farm kispang-temple belkot-market - location
    car1 - car
    n1 n2 n3 n4 n5 n6 n7 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions), none damaged
    (road shivapuri-shelter kalika-village)
    (road kalika-village shivapuri-shelter)
    (= (travel-time shivapuri-shelter kalika-village) 7)
    (= (travel-time kalika-village shivapuri-shelter) 7)

    (road shivapuri-shelter trishuli-farm)
    (road trishuli-farm shivapuri-shelter)
    (= (travel-time shivapuri-shelter trishuli-farm) 39)
    (= (travel-time trishuli-farm shivapuri-shelter) 39)

    (road shivapuri-shelter kispang-temple)
    (road kispang-temple shivapuri-shelter)
    (= (travel-time shivapuri-shelter kispang-temple) 45)
    (= (travel-time kispang-temple shivapuri-shelter) 45)

    (road trishuli-farm kispang-temple)
    (road kispang-temple trishuli-farm)
    (= (travel-time trishuli-farm kispang-temple) 9)
    (= (travel-time kispang-temple trishuli-farm) 9)

    (road trishuli-farm belkot-market)
    (road belkot-market trishuli-farm)
    (= (travel-time trishuli-farm belkot-market) 16)
    (= (travel-time belkot-market trishuli-farm) 16)

    (road kispang-temple belkot-market)
    (road belkot-market kispang-temple)
    (= (travel-time kispang-temple belkot-market) 6)
    (= (travel-time belkot-market kispang-temple) 6)

    ;; Evacuation points
    (evac-point shivapuri-shelter)

    ;; Car
    (car-at car1 shivapuri-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; People waiting
    (waiting trishuli-farm elderly n7)
    (waiting kalika-village elderly n4)

    ;; Addition table: a + b = c for a, b, c in n0..n7
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3)
    (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6) (sum n0 n7 n7)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n1 n4 n5) (sum n1 n5 n6) (sum n1 n6 n7)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5)
    (sum n2 n4 n6) (sum n2 n5 n7)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n3 n4 n7)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6) (sum n4 n3 n7)
    (sum n5 n0 n5) (sum n5 n1 n6) (sum n5 n2 n7)
    (sum n6 n0 n6) (sum n6 n1 n7)
    (sum n7 n0 n7)

    ;; Positive levels
    (positive n1) (positive n2) (positive n3) (positive n4)
    (positive n5) (positive n6) (positive n7)

    ;; Deferral penalties: injured 80, child 60, elderly 50, adult 20 per person
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400)
    (= (defer-cost injured n6) 480)
    (= (defer-cost injured n7) 560)

    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300)
    (= (defer-cost child n6) 360)
    (= (defer-cost child n7) 420)

    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250)
    (= (defer-cost elderly n6) 300)
    (= (defer-cost elderly n7) 350)

    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100)
    (= (defer-cost adult n6) 120)
    (= (defer-cost adult n7) 140)
  )

  (:goal (and
    (waiting trishuli-farm elderly n0)
    (waiting kalika-village elderly n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
