(define (problem large-05)
  (:domain flood-rescue)

  (:objects
    thakre-shelter nilkantha-hospital panchakanya-farm trishuli-care-home
    tadi-village uttargaya-market likhu-temple syaphru-care-home
    gajuri-care-home naukunda-temple suryagadhi-market kispang-farm
    kalika-village belkot-village - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    ;; Roads
    (road thakre-shelter panchakanya-farm)
    (road panchakanya-farm thakre-shelter)
    (= (travel-time thakre-shelter panchakanya-farm) 5)
    (= (travel-time panchakanya-farm thakre-shelter) 5)
    (damaged thakre-shelter panchakanya-farm)
    (damaged panchakanya-farm thakre-shelter)

    (road thakre-shelter trishuli-care-home)
    (road trishuli-care-home thakre-shelter)
    (= (travel-time thakre-shelter trishuli-care-home) 23)
    (= (travel-time trishuli-care-home thakre-shelter) 23)
    (damaged thakre-shelter trishuli-care-home)
    (damaged trishuli-care-home thakre-shelter)

    (road nilkantha-hospital tadi-village)
    (road tadi-village nilkantha-hospital)
    (= (travel-time nilkantha-hospital tadi-village) 10)
    (= (travel-time tadi-village nilkantha-hospital) 10)

    (road uttargaya-market trishuli-care-home)
    (road trishuli-care-home uttargaya-market)
    (= (travel-time uttargaya-market trishuli-care-home) 13)
    (= (travel-time trishuli-care-home uttargaya-market) 13)

    (road uttargaya-market likhu-temple)
    (road likhu-temple uttargaya-market)
    (= (travel-time uttargaya-market likhu-temple) 21)
    (= (travel-time likhu-temple uttargaya-market) 21)
    (damaged uttargaya-market likhu-temple)
    (damaged likhu-temple uttargaya-market)

    (road trishuli-care-home likhu-temple)
    (road likhu-temple trishuli-care-home)
    (= (travel-time trishuli-care-home likhu-temple) 13)
    (= (travel-time likhu-temple trishuli-care-home) 13)
    (damaged trishuli-care-home likhu-temple)
    (damaged likhu-temple trishuli-care-home)

    (road trishuli-care-home tadi-village)
    (road tadi-village trishuli-care-home)
    (= (travel-time trishuli-care-home tadi-village) 5)
    (= (travel-time tadi-village trishuli-care-home) 5)

    (road syaphru-care-home gajuri-care-home)
    (road gajuri-care-home syaphru-care-home)
    (= (travel-time syaphru-care-home gajuri-care-home) 12)
    (= (travel-time gajuri-care-home syaphru-care-home) 12)

    (road naukunda-temple likhu-temple)
    (road likhu-temple naukunda-temple)
    (= (travel-time naukunda-temple likhu-temple) 17)
    (= (travel-time likhu-temple naukunda-temple) 17)

    (road likhu-temple suryagadhi-market)
    (road suryagadhi-market likhu-temple)
    (= (travel-time likhu-temple suryagadhi-market) 33)
    (= (travel-time suryagadhi-market likhu-temple) 33)

    (road likhu-temple gajuri-care-home)
    (road gajuri-care-home likhu-temple)
    (= (travel-time likhu-temple gajuri-care-home) 20)
    (= (travel-time gajuri-care-home likhu-temple) 20)

    (road likhu-temple kispang-farm)
    (road kispang-farm likhu-temple)
    (= (travel-time likhu-temple kispang-farm) 29)
    (= (travel-time kispang-farm likhu-temple) 29)

    (road likhu-temple kalika-village)
    (road kalika-village likhu-temple)
    (= (travel-time likhu-temple kalika-village) 10)
    (= (travel-time kalika-village likhu-temple) 10)
    (damaged likhu-temple kalika-village)
    (damaged kalika-village likhu-temple)

    (road suryagadhi-market gajuri-care-home)
    (road gajuri-care-home suryagadhi-market)
    (= (travel-time suryagadhi-market gajuri-care-home) 21)
    (= (travel-time gajuri-care-home suryagadhi-market) 21)
    (damaged suryagadhi-market gajuri-care-home)
    (damaged gajuri-care-home suryagadhi-market)

    (road belkot-village tadi-village)
    (road tadi-village belkot-village)
    (= (travel-time belkot-village tadi-village) 21)
    (= (travel-time tadi-village belkot-village) 21)

    (road belkot-village kispang-farm)
    (road kispang-farm belkot-village)
    (= (travel-time belkot-village kispang-farm) 21)
    (= (travel-time kispang-farm belkot-village) 21)

    ;; Evacuation points
    (evac-point thakre-shelter)
    (evac-point nilkantha-hospital)

    ;; Cars
    (car-at car1 thakre-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 nilkantha-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting suryagadhi-market elderly n4)
    (waiting suryagadhi-market adult n6)
    (waiting suryagadhi-market child n2)
    (waiting trishuli-care-home elderly n3)
    (waiting panchakanya-farm adult n1)
    (waiting uttargaya-market adult n4)
    (waiting belkot-village adult n1)

    ;; Level arithmetic
    (positive n1) (positive n2) (positive n3)
    (positive n4) (positive n5) (positive n6)

    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3)
    (sum n0 n4 n4) (sum n0 n5 n5) (sum n0 n6 n6)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n1 n4 n5) (sum n1 n5 n6)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4) (sum n2 n3 n5)
    (sum n2 n4 n6)
    (sum n3 n0 n3) (sum n3 n1 n4) (sum n3 n2 n5) (sum n3 n3 n6)
    (sum n4 n0 n4) (sum n4 n1 n5) (sum n4 n2 n6)
    (sum n5 n0 n5) (sum n5 n1 n6)
    (sum n6 n0 n6)

    ;; Deferral penalties
    (= (defer-cost injured n1) 80)
    (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240)
    (= (defer-cost injured n4) 320)
    (= (defer-cost injured n5) 400)
    (= (defer-cost injured n6) 480)

    (= (defer-cost child n1) 60)
    (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180)
    (= (defer-cost child n4) 240)
    (= (defer-cost child n5) 300)
    (= (defer-cost child n6) 360)

    (= (defer-cost elderly n1) 50)
    (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150)
    (= (defer-cost elderly n4) 200)
    (= (defer-cost elderly n5) 250)
    (= (defer-cost elderly n6) 300)

    (= (defer-cost adult n1) 20)
    (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60)
    (= (defer-cost adult n4) 80)
    (= (defer-cost adult n5) 100)
    (= (defer-cost adult n6) 120)

    (= (total-cost) 0)
  )

  (:goal (and
    (waiting suryagadhi-market elderly n0)
    (waiting suryagadhi-market adult n0)
    (waiting suryagadhi-market child n0)
    (waiting trishuli-care-home elderly n0)
    (waiting panchakanya-farm adult n0)
    (waiting uttargaya-market adult n0)
    (waiting belkot-village adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)
  ))

  (:metric minimize (total-cost))
)
