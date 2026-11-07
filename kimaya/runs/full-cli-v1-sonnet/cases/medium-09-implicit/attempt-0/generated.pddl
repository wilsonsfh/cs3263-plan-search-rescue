(define (problem medium-09)
  (:domain flood-rescue)

  (:objects
    thakre-shelter kakani-school dhunche-market benighat-care-home shivapuri-village tadi-market myagang-care-home nilkantha-village tarkeshwar-care-home - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 n7 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road thakre-shelter dhunche-market) (road dhunche-market thakre-shelter)
    (= (travel-time thakre-shelter dhunche-market) 23)
    (= (travel-time dhunche-market thakre-shelter) 23)

    (road benighat-care-home shivapuri-village) (road shivapuri-village benighat-care-home)
    (= (travel-time benighat-care-home shivapuri-village) 30)
    (= (travel-time shivapuri-village benighat-care-home) 30)

    (road tadi-market myagang-care-home) (road myagang-care-home tadi-market)
    (= (travel-time tadi-market myagang-care-home) 24)
    (= (travel-time myagang-care-home tadi-market) 24)

    (road thakre-shelter nilkantha-village) (road nilkantha-village thakre-shelter)
    (= (travel-time thakre-shelter nilkantha-village) 5)
    (= (travel-time nilkantha-village thakre-shelter) 5)

    (road thakre-shelter myagang-care-home) (road myagang-care-home thakre-shelter)
    (= (travel-time thakre-shelter myagang-care-home) 25)
    (= (travel-time myagang-care-home thakre-shelter) 25)

    (road tadi-market kakani-school) (road kakani-school tadi-market)
    (= (travel-time tadi-market kakani-school) 24)
    (= (travel-time kakani-school tadi-market) 24)

    (road dhunche-market nilkantha-village) (road nilkantha-village dhunche-market)
    (= (travel-time dhunche-market nilkantha-village) 23)
    (= (travel-time nilkantha-village dhunche-market) 23)
    (damaged dhunche-market nilkantha-village) (damaged nilkantha-village dhunche-market)

    (road benighat-care-home tarkeshwar-care-home) (road tarkeshwar-care-home benighat-care-home)
    (= (travel-time benighat-care-home tarkeshwar-care-home) 25)
    (= (travel-time tarkeshwar-care-home benighat-care-home) 25)

    (road thakre-shelter shivapuri-village) (road shivapuri-village thakre-shelter)
    (= (travel-time thakre-shelter shivapuri-village) 44)
    (= (travel-time shivapuri-village thakre-shelter) 44)

    (road kakani-school dhunche-market) (road dhunche-market kakani-school)
    (= (travel-time kakani-school dhunche-market) 13)
    (= (travel-time dhunche-market kakani-school) 13)

    (road tadi-market tarkeshwar-care-home) (road tarkeshwar-care-home tadi-market)
    (= (travel-time tadi-market tarkeshwar-care-home) 10)
    (= (travel-time tarkeshwar-care-home tadi-market) 10)

    (road dhunche-market myagang-care-home) (road myagang-care-home dhunche-market)
    (= (travel-time dhunche-market myagang-care-home) 16)
    (= (travel-time myagang-care-home dhunche-market) 16)

    ;; evacuation points
    (evac-point thakre-shelter)

    ;; cars
    (car-at car1 thakre-shelter) (free-seats car1 n4)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (car-at car2 thakre-shelter) (free-seats car2 n4)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; people
    (waiting tadi-market adult n7)
    (waiting myagang-care-home elderly n3)
    (waiting dhunche-market injured n4)
    (waiting dhunche-market adult n2)
    (waiting shivapuri-village child n1)

    ;; positive
    (positive n1) (positive n2) (positive n3) (positive n4)
    (positive n5) (positive n6) (positive n7)

    ;; sums
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

    ;; defer costs
    (= (defer-cost injured n1) 80) (= (defer-cost injured n2) 160) (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320) (= (defer-cost injured n5) 400) (= (defer-cost injured n6) 480)
    (= (defer-cost injured n7) 560)
    (= (defer-cost child n1) 60) (= (defer-cost child n2) 120) (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240) (= (defer-cost child n5) 300) (= (defer-cost child n6) 360)
    (= (defer-cost child n7) 420)
    (= (defer-cost elderly n1) 50) (= (defer-cost elderly n2) 100) (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200) (= (defer-cost elderly n5) 250) (= (defer-cost elderly n6) 300)
    (= (defer-cost elderly n7) 350)
    (= (defer-cost adult n1) 20) (= (defer-cost adult n2) 40) (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80) (= (defer-cost adult n5) 100) (= (defer-cost adult n6) 120)
    (= (defer-cost adult n7) 140)
  )

  (:goal (and
    (waiting tadi-market adult n0)
    (waiting myagang-care-home elderly n0)
    (waiting dhunche-market injured n0)
    (waiting dhunche-market adult n0)
    (waiting shivapuri-village child n0)
    (carrying car1 injured n0) (carrying car1 child n0) (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0) (carrying car2 elderly n0) (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
