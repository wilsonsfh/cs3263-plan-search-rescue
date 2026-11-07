(define (problem flood-rescue-small-09)
  (:domain flood-rescue)

  (:objects
    kispang-shelter galchhi-school nilkantha-village thakre-temple kalika-market tadi-village - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads
    (road nilkantha-village thakre-temple)
    (road thakre-temple nilkantha-village)
    (= (travel-time nilkantha-village thakre-temple) 26)
    (= (travel-time thakre-temple nilkantha-village) 26)

    (road thakre-temple kalika-market)
    (road kalika-market thakre-temple)
    (= (travel-time thakre-temple kalika-market) 14)
    (= (travel-time kalika-market thakre-temple) 14)

    (road kispang-shelter nilkantha-village)
    (road nilkantha-village kispang-shelter)
    (= (travel-time kispang-shelter nilkantha-village) 9)
    (= (travel-time nilkantha-village kispang-shelter) 9)
    (damaged kispang-shelter nilkantha-village)
    (damaged nilkantha-village kispang-shelter)

    (road galchhi-school kalika-market)
    (road kalika-market galchhi-school)
    (= (travel-time galchhi-school kalika-market) 21)
    (= (travel-time kalika-market galchhi-school) 21)

    (road galchhi-school nilkantha-village)
    (road nilkantha-village galchhi-school)
    (= (travel-time galchhi-school nilkantha-village) 9)
    (= (travel-time nilkantha-village galchhi-school) 9)

    (road thakre-temple tadi-village)
    (road tadi-village thakre-temple)
    (= (travel-time thakre-temple tadi-village) 37)
    (= (travel-time tadi-village thakre-temple) 37)

    (road galchhi-school thakre-temple)
    (road thakre-temple galchhi-school)
    (= (travel-time galchhi-school thakre-temple) 27)
    (= (travel-time thakre-temple galchhi-school) 27)

    ;; Evacuation points
    (evac-point kispang-shelter)

    ;; Car
    (car-at car1 kispang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; Waiting people
    (waiting kalika-market child n3)
    (waiting galchhi-school child n4)

    ;; Level arithmetic
    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n0 n2 n2)
    (sum n0 n3 n3)
    (sum n0 n4 n4)
    (sum n1 n0 n1)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n1 n3 n4)
    (sum n2 n0 n2)
    (sum n2 n1 n3)
    (sum n2 n2 n4)
    (sum n3 n0 n3)
    (sum n3 n1 n4)
    (sum n4 n0 n4)

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

    (= (total-cost) 0))

  (:goal (and
    (waiting kalika-market child n0)
    (waiting galchhi-school child n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)))

  (:metric minimize (total-cost))
)
