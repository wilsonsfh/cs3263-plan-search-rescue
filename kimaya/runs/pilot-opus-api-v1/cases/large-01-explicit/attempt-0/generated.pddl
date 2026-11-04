(define (problem large-01)
  (:domain flood-rescue)

  (:objects
    myagang-shelter uttargaya-hospital suryagadhi-temple dhunche-school
    shivapuri-farm gosaikunda-school likhu-temple tadi-temple
    jwalamukhi-market galchhi-school kalika-village trishuli-farm
    tarkeshwar-care-home bidur-farm - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 n7 - level)

  (:init
    ;; roads
    (road myagang-shelter suryagadhi-temple) (road suryagadhi-temple myagang-shelter)
    (= (travel-time myagang-shelter suryagadhi-temple) 8) (= (travel-time suryagadhi-temple myagang-shelter) 8)

    (road myagang-shelter dhunche-school) (road dhunche-school myagang-shelter)
    (= (travel-time myagang-shelter dhunche-school) 5) (= (travel-time dhunche-school myagang-shelter) 5)

    (road uttargaya-hospital shivapuri-farm) (road shivapuri-farm uttargaya-hospital)
    (= (travel-time uttargaya-hospital shivapuri-farm) 11) (= (travel-time shivapuri-farm uttargaya-hospital) 11)

    (road uttargaya-hospital gosaikunda-school) (road gosaikunda-school uttargaya-hospital)
    (= (travel-time uttargaya-hospital gosaikunda-school) 11) (= (travel-time gosaikunda-school uttargaya-hospital) 11)

    (road uttargaya-hospital likhu-temple) (road likhu-temple uttargaya-hospital)
    (= (travel-time uttargaya-hospital likhu-temple) 16) (= (travel-time likhu-temple uttargaya-hospital) 16)
    (damaged uttargaya-hospital likhu-temple) (damaged likhu-temple uttargaya-hospital)

    (road uttargaya-hospital tadi-temple) (road tadi-temple uttargaya-hospital)
    (= (travel-time uttargaya-hospital tadi-temple) 15) (= (travel-time tadi-temple uttargaya-hospital) 15)

    (road shivapuri-farm suryagadhi-temple) (road suryagadhi-temple shivapuri-farm)
    (= (travel-time shivapuri-farm suryagadhi-temple) 30) (= (travel-time suryagadhi-temple shivapuri-farm) 30)
    (damaged shivapuri-farm suryagadhi-temple) (damaged suryagadhi-temple shivapuri-farm)

    (road shivapuri-farm jwalamukhi-market) (road jwalamukhi-market shivapuri-farm)
    (= (travel-time shivapuri-farm jwalamukhi-market) 12) (= (travel-time jwalamukhi-market shivapuri-farm) 12)

    (road galchhi-school suryagadhi-temple) (road suryagadhi-temple galchhi-school)
    (= (travel-time galchhi-school suryagadhi-temple) 5) (= (travel-time suryagadhi-temple galchhi-school) 5)
    (damaged galchhi-school suryagadhi-temple) (damaged suryagadhi-temple galchhi-school)

    (road galchhi-school dhunche-school) (road dhunche-school galchhi-school)
    (= (travel-time galchhi-school dhunche-school) 11) (= (travel-time dhunche-school galchhi-school) 11)

    (road kalika-village suryagadhi-temple) (road suryagadhi-temple kalika-village)
    (= (travel-time kalika-village suryagadhi-temple) 20) (= (travel-time suryagadhi-temple kalika-village) 20)

    (road trishuli-farm tarkeshwar-care-home) (road tarkeshwar-care-home trishuli-farm)
    (= (travel-time trishuli-farm tarkeshwar-care-home) 9) (= (travel-time tarkeshwar-care-home trishuli-farm) 9)

    (road gosaikunda-school suryagadhi-temple) (road suryagadhi-temple gosaikunda-school)
    (= (travel-time gosaikunda-school suryagadhi-temple) 13) (= (travel-time suryagadhi-temple gosaikunda-school) 13)

    (road tarkeshwar-care-home suryagadhi-temple) (road suryagadhi-temple tarkeshwar-care-home)
    (= (travel-time tarkeshwar-care-home suryagadhi-temple) 22) (= (travel-time suryagadhi-temple tarkeshwar-care-home) 22)
    (damaged tarkeshwar-care-home suryagadhi-temple) (damaged suryagadhi-temple tarkeshwar-care-home)

    (road tarkeshwar-care-home bidur-farm) (road bidur-farm tarkeshwar-care-home)
    (= (travel-time tarkeshwar-care-home bidur-farm) 9) (= (travel-time bidur-farm tarkeshwar-care-home) 9)

    (road suryagadhi-temple dhunche-school) (road dhunche-school suryagadhi-temple)
    (= (travel-time suryagadhi-temple dhunche-school) 13) (= (travel-time dhunche-school suryagadhi-temple) 13)

    (road likhu-temple jwalamukhi-market) (road jwalamukhi-market likhu-temple)
    (= (travel-time likhu-temple jwalamukhi-market) 7) (= (travel-time jwalamukhi-market likhu-temple) 7)
    (damaged likhu-temple jwalamukhi-market) (damaged jwalamukhi-market likhu-temple)

    (road likhu-temple tadi-temple) (road tadi-temple likhu-temple)
    (= (travel-time likhu-temple tadi-temple) 8) (= (travel-time tadi-temple likhu-temple) 8)

    (road jwalamukhi-market tadi-temple) (road tadi-temple jwalamukhi-market)
    (= (travel-time jwalamukhi-market tadi-temple) 14) (= (travel-time tadi-temple jwalamukhi-market) 14)

    ;; evacuation points
    (evac-point myagang-shelter)
    (evac-point uttargaya-hospital)

    ;; cars
    (car-at car1 myagang-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0) (carrying car1 child n0)
    (carrying car1 elderly n0) (carrying car1 adult n0)
    (car-at car2 uttargaya-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0) (carrying car2 child n0)
    (carrying car2 elderly n0) (carrying car2 adult n0)

    ;; people waiting
    (waiting dhunche-school adult n3)
    (waiting shivapuri-farm adult n3)
    (waiting bidur-farm adult n2)
    (waiting suryagadhi-temple elderly n2)
    (waiting trishuli-farm adult n1)
    (waiting galchhi-school adult n3)
    (waiting gosaikunda-school child n7)
    (waiting kalika-village child n4)

    ;; level arithmetic
    (positive n1) (positive n2) (positive n3) (positive n4)
    (positive n5) (positive n6) (positive n7)

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

    ;; deferral penalties
    (= (defer-cost injured n1) 80) (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240) (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400) (= (defer-cost injured n6) 480)
    (= (defer-cost injured n7) 560)
    (= (defer-cost child n1) 60) (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180) (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300) (= (defer-cost child n6) 360)
    (= (defer-cost child n7) 420)
    (= (defer-cost elderly n1) 50) (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150) (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250) (= (defer-cost elderly n6) 300)
    (= (defer-cost elderly n7) 350)
    (= (defer-cost adult n1) 20) (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60) (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100) (= (defer-cost adult n6) 120)
    (= (defer-cost adult n7) 140)

    (= (total-cost) 0))

  (:goal (and
    (waiting dhunche-school adult n0)
    (waiting shivapuri-farm adult n0)
    (waiting bidur-farm adult n0)
    (waiting suryagadhi-temple elderly n0)
    (waiting trishuli-farm adult n0)
    (waiting galchhi-school adult n0)
    (waiting gosaikunda-school child n0)
    (waiting kalika-village child n0)
    (carrying car1 injured n0) (carrying car1 child n0)
    (carrying car1 elderly n0) (carrying car1 adult n0)
    (carrying car2 injured n0) (carrying car2 child n0)
    (carrying car2 elderly n0) (carrying car2 adult n0)))

  (:metric minimize (total-cost))
)
