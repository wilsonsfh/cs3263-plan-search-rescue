(define (problem medium-01)
  (:domain flood-rescue)

  (:objects
    kakani-shelter tarkeshwar-school benighat-farm uttargaya-farm
    myagang-market naukunda-school belkot-farm tadi-school
    gosaikunda-temple - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; roads
    (road benighat-farm uttargaya-farm) (road uttargaya-farm benighat-farm)
    (= (travel-time benighat-farm uttargaya-farm) 38) (= (travel-time uttargaya-farm benighat-farm) 38)

    (road benighat-farm myagang-market) (road myagang-market benighat-farm)
    (= (travel-time benighat-farm myagang-market) 54) (= (travel-time myagang-market benighat-farm) 54)
    (damaged benighat-farm myagang-market) (damaged myagang-market benighat-farm)

    (road tarkeshwar-school naukunda-school) (road naukunda-school tarkeshwar-school)
    (= (travel-time tarkeshwar-school naukunda-school) 17) (= (travel-time naukunda-school tarkeshwar-school) 17)

    (road myagang-market naukunda-school) (road naukunda-school myagang-market)
    (= (travel-time myagang-market naukunda-school) 29) (= (travel-time naukunda-school myagang-market) 29)

    (road tarkeshwar-school benighat-farm) (road benighat-farm tarkeshwar-school)
    (= (travel-time tarkeshwar-school benighat-farm) 14) (= (travel-time benighat-farm tarkeshwar-school) 14)

    (road kakani-shelter naukunda-school) (road naukunda-school kakani-shelter)
    (= (travel-time kakani-shelter naukunda-school) 25) (= (travel-time naukunda-school kakani-shelter) 25)

    (road uttargaya-farm belkot-farm) (road belkot-farm uttargaya-farm)
    (= (travel-time uttargaya-farm belkot-farm) 11) (= (travel-time belkot-farm uttargaya-farm) 11)
    (damaged uttargaya-farm belkot-farm) (damaged belkot-farm uttargaya-farm)

    (road tarkeshwar-school tadi-school) (road tadi-school tarkeshwar-school)
    (= (travel-time tarkeshwar-school tadi-school) 7) (= (travel-time tadi-school tarkeshwar-school) 7)
    (damaged tarkeshwar-school tadi-school) (damaged tadi-school tarkeshwar-school)

    (road gosaikunda-temple uttargaya-farm) (road uttargaya-farm gosaikunda-temple)
    (= (travel-time gosaikunda-temple uttargaya-farm) 5) (= (travel-time uttargaya-farm gosaikunda-temple) 5)

    (road benighat-farm tadi-school) (road tadi-school benighat-farm)
    (= (travel-time benighat-farm tadi-school) 21) (= (travel-time tadi-school benighat-farm) 21)

    (road kakani-shelter tarkeshwar-school) (road tarkeshwar-school kakani-shelter)
    (= (travel-time kakani-shelter tarkeshwar-school) 12) (= (travel-time tarkeshwar-school kakani-shelter) 12)

    ;; evacuation points
    (evac-point kakani-shelter)

    ;; cars
    (car-at car1 kakani-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0) (carrying car1 child n0)
    (carrying car1 elderly n0) (carrying car1 adult n0)
    (car-at car2 kakani-shelter)
    (free-seats car2 n4)
    (carrying car2 injured n0) (carrying car2 child n0)
    (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; waiting people
    (waiting myagang-market adult n4)
    (waiting benighat-farm adult n4)
    (waiting tarkeshwar-school injured n4)
    (waiting tarkeshwar-school child n1)
    (waiting belkot-farm adult n2)
    (waiting naukunda-school child n3)

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

    (= (total-cost) 0))

  (:goal (and
    (waiting myagang-market adult n0)
    (waiting benighat-farm adult n0)
    (waiting tarkeshwar-school injured n0)
    (waiting tarkeshwar-school child n0)
    (waiting belkot-farm adult n0)
    (waiting naukunda-school child n0)
    (carrying car1 injured n0) (carrying car1 child n0)
    (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0)
    (carrying car2 elderly n0) (carrying car2 adult n0)))

  (:metric minimize (total-cost))
)
