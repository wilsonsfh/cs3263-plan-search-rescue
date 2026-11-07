(define (problem flood-rescue-large-15)
  (:domain flood-rescue)

  (:objects
    suryagadhi-shelter kalika-hospital gajuri-farm galchhi-village likhu-temple
    nilkantha-market thakre-farm tadi-temple kispang-market tarkeshwar-farm
    myagang-village dhunche-school - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads
    (road suryagadhi-shelter gajuri-farm) (road gajuri-farm suryagadhi-shelter)
    (= (travel-time suryagadhi-shelter gajuri-farm) 27) (= (travel-time gajuri-farm suryagadhi-shelter) 27)

    (road suryagadhi-shelter galchhi-village) (road galchhi-village suryagadhi-shelter)
    (= (travel-time suryagadhi-shelter galchhi-village) 12) (= (travel-time galchhi-village suryagadhi-shelter) 12)

    (road kalika-hospital gajuri-farm) (road gajuri-farm kalika-hospital)
    (= (travel-time kalika-hospital gajuri-farm) 7) (= (travel-time gajuri-farm kalika-hospital) 7)

    (road kalika-hospital galchhi-village) (road galchhi-village kalika-hospital)
    (= (travel-time kalika-hospital galchhi-village) 11) (= (travel-time galchhi-village kalika-hospital) 11)

    (road gajuri-farm likhu-temple) (road likhu-temple gajuri-farm)
    (= (travel-time gajuri-farm likhu-temple) 16) (= (travel-time likhu-temple gajuri-farm) 16)

    (road gajuri-farm galchhi-village) (road galchhi-village gajuri-farm)
    (= (travel-time gajuri-farm galchhi-village) 17) (= (travel-time galchhi-village gajuri-farm) 17)

    (road likhu-temple nilkantha-market) (road nilkantha-market likhu-temple)
    (= (travel-time likhu-temple nilkantha-market) 28) (= (travel-time nilkantha-market likhu-temple) 28)

    (road likhu-temple myagang-village) (road myagang-village likhu-temple)
    (= (travel-time likhu-temple myagang-village) 55) (= (travel-time myagang-village likhu-temple) 55)

    (road nilkantha-market thakre-farm) (road thakre-farm nilkantha-market)
    (= (travel-time nilkantha-market thakre-farm) 5) (= (travel-time thakre-farm nilkantha-market) 5)

    (road nilkantha-market tadi-temple) (road tadi-temple nilkantha-market)
    (= (travel-time nilkantha-market tadi-temple) 15) (= (travel-time tadi-temple nilkantha-market) 15)

    (road kispang-market tadi-temple) (road tadi-temple kispang-market)
    (= (travel-time kispang-market tadi-temple) 15) (= (travel-time tadi-temple kispang-market) 15)

    (road kispang-market tarkeshwar-farm) (road tarkeshwar-farm kispang-market)
    (= (travel-time kispang-market tarkeshwar-farm) 14) (= (travel-time tarkeshwar-farm kispang-market) 14)
    (damaged kispang-market tarkeshwar-farm) (damaged tarkeshwar-farm kispang-market)

    (road kispang-market dhunche-school) (road dhunche-school kispang-market)
    (= (travel-time kispang-market dhunche-school) 19) (= (travel-time dhunche-school kispang-market) 19)

    (road thakre-farm tadi-temple) (road tadi-temple thakre-farm)
    (= (travel-time thakre-farm tadi-temple) 12) (= (travel-time tadi-temple thakre-farm) 12)
    (damaged thakre-farm tadi-temple) (damaged tadi-temple thakre-farm)

    (road tarkeshwar-farm myagang-village) (road myagang-village tarkeshwar-farm)
    (= (travel-time tarkeshwar-farm myagang-village) 15) (= (travel-time myagang-village tarkeshwar-farm) 15)

    (road tarkeshwar-farm dhunche-school) (road dhunche-school tarkeshwar-farm)
    (= (travel-time tarkeshwar-farm dhunche-school) 15) (= (travel-time dhunche-school tarkeshwar-farm) 15)
    (damaged tarkeshwar-farm dhunche-school) (damaged dhunche-school tarkeshwar-farm)

    (road myagang-village dhunche-school) (road dhunche-school myagang-village)
    (= (travel-time myagang-village dhunche-school) 18) (= (travel-time dhunche-school myagang-village) 18)
    (damaged myagang-village dhunche-school) (damaged dhunche-school myagang-village)

    ;; Evacuation points
    (evac-point suryagadhi-shelter)
    (evac-point kalika-hospital)

    ;; Cars
    (car-at car1 suryagadhi-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 kalika-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting nilkantha-market elderly n4)
    (waiting nilkantha-market injured n2)
    (waiting tadi-temple elderly n1)
    (waiting tadi-temple adult n3)
    (waiting likhu-temple elderly n4)
    (waiting gajuri-farm adult n4)
    (waiting galchhi-village elderly n2)
    (waiting tarkeshwar-farm adult n4)
    (waiting thakre-farm adult n2)

    ;; Level arithmetic
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; Deferral penalties
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
    (waiting nilkantha-market elderly n0)
    (waiting nilkantha-market injured n0)
    (waiting tadi-temple elderly n0)
    (waiting tadi-temple adult n0)
    (waiting likhu-temple elderly n0)
    (waiting gajuri-farm adult n0)
    (waiting galchhi-village elderly n0)
    (waiting tarkeshwar-farm adult n0)
    (waiting thakre-farm adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)))

  (:metric minimize (total-cost))
)
