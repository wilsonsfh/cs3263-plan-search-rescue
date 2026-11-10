(define (problem medium-10)
  (:domain flood-rescue)

  (:objects
    kispang-shelter gosaikunda-temple thakre-care-home dupcheshwar-temple
    myagang-temple tadi-market naukunda-farm galchhi-temple - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads
    (road kispang-shelter gosaikunda-temple)
    (road gosaikunda-temple kispang-shelter)
    (= (travel-time kispang-shelter gosaikunda-temple) 24)
    (= (travel-time gosaikunda-temple kispang-shelter) 24)

    (road kispang-shelter thakre-care-home)
    (road thakre-care-home kispang-shelter)
    (= (travel-time kispang-shelter thakre-care-home) 20)
    (= (travel-time thakre-care-home kispang-shelter) 20)
    (damaged kispang-shelter thakre-care-home)
    (damaged thakre-care-home kispang-shelter)

    (road kispang-shelter dupcheshwar-temple)
    (road dupcheshwar-temple kispang-shelter)
    (= (travel-time kispang-shelter dupcheshwar-temple) 26)
    (= (travel-time dupcheshwar-temple kispang-shelter) 26)

    (road kispang-shelter myagang-temple)
    (road myagang-temple kispang-shelter)
    (= (travel-time kispang-shelter myagang-temple) 16)
    (= (travel-time myagang-temple kispang-shelter) 16)

    (road tadi-market naukunda-farm)
    (road naukunda-farm tadi-market)
    (= (travel-time tadi-market naukunda-farm) 11)
    (= (travel-time naukunda-farm tadi-market) 11)

    (road tadi-market galchhi-temple)
    (road galchhi-temple tadi-market)
    (= (travel-time tadi-market galchhi-temple) 23)
    (= (travel-time galchhi-temple tadi-market) 23)
    (damaged tadi-market galchhi-temple)
    (damaged galchhi-temple tadi-market)

    (road gosaikunda-temple thakre-care-home)
    (road thakre-care-home gosaikunda-temple)
    (= (travel-time gosaikunda-temple thakre-care-home) 11)
    (= (travel-time thakre-care-home gosaikunda-temple) 11)

    (road gosaikunda-temple dupcheshwar-temple)
    (road dupcheshwar-temple gosaikunda-temple)
    (= (travel-time gosaikunda-temple dupcheshwar-temple) 23)
    (= (travel-time dupcheshwar-temple gosaikunda-temple) 23)
    (damaged gosaikunda-temple dupcheshwar-temple)
    (damaged dupcheshwar-temple gosaikunda-temple)

    (road gosaikunda-temple galchhi-temple)
    (road galchhi-temple gosaikunda-temple)
    (= (travel-time gosaikunda-temple galchhi-temple) 17)
    (= (travel-time galchhi-temple gosaikunda-temple) 17)

    (road thakre-care-home myagang-temple)
    (road myagang-temple thakre-care-home)
    (= (travel-time thakre-care-home myagang-temple) 32)
    (= (travel-time myagang-temple thakre-care-home) 32)

    ;; Evacuation points
    (evac-point kispang-shelter)

    ;; Cars
    (car-at car1 kispang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 kispang-shelter)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting galchhi-temple child n4)
    (waiting dupcheshwar-temple elderly n1)
    (waiting myagang-temple injured n3)
    (waiting myagang-temple adult n3)
    (waiting myagang-temple elderly n2)
    (waiting naukunda-farm adult n2)
    (waiting tadi-market injured n3)

    ;; Level arithmetic
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

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
    (waiting galchhi-temple child n0)
    (waiting dupcheshwar-temple elderly n0)
    (waiting myagang-temple injured n0)
    (waiting myagang-temple adult n0)
    (waiting myagang-temple elderly n0)
    (waiting naukunda-farm adult n0)
    (waiting tadi-market injured n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)))

  (:metric minimize (total-cost)))
