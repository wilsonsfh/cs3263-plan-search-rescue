(define (problem flood-rescue-medium-05)
  (:domain flood-rescue)

  (:objects
    thakre-shelter tarkeshwar-hospital likhu-farm myagang-care-home
    suryagadhi-care-home gajuri-care-home panchakanya-care-home - location
    car1 - car
    n1 n2 n3 n4 n5 n6 n7 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road tarkeshwar-hospital likhu-farm)
    (road likhu-farm tarkeshwar-hospital)
    (= (travel-time tarkeshwar-hospital likhu-farm) 24)
    (= (travel-time likhu-farm tarkeshwar-hospital) 24)
    (damaged tarkeshwar-hospital likhu-farm)
    (damaged likhu-farm tarkeshwar-hospital)

    (road myagang-care-home suryagadhi-care-home)
    (road suryagadhi-care-home myagang-care-home)
    (= (travel-time myagang-care-home suryagadhi-care-home) 9)
    (= (travel-time suryagadhi-care-home myagang-care-home) 9)
    (damaged myagang-care-home suryagadhi-care-home)
    (damaged suryagadhi-care-home myagang-care-home)

    (road tarkeshwar-hospital suryagadhi-care-home)
    (road suryagadhi-care-home tarkeshwar-hospital)
    (= (travel-time tarkeshwar-hospital suryagadhi-care-home) 17)
    (= (travel-time suryagadhi-care-home tarkeshwar-hospital) 17)
    (damaged tarkeshwar-hospital suryagadhi-care-home)
    (damaged suryagadhi-care-home tarkeshwar-hospital)

    (road thakre-shelter gajuri-care-home)
    (road gajuri-care-home thakre-shelter)
    (= (travel-time thakre-shelter gajuri-care-home) 7)
    (= (travel-time gajuri-care-home thakre-shelter) 7)

    (road suryagadhi-care-home likhu-farm)
    (road likhu-farm suryagadhi-care-home)
    (= (travel-time suryagadhi-care-home likhu-farm) 24)
    (= (travel-time likhu-farm suryagadhi-care-home) 24)

    (road likhu-farm panchakanya-care-home)
    (road panchakanya-care-home likhu-farm)
    (= (travel-time likhu-farm panchakanya-care-home) 26)
    (= (travel-time panchakanya-care-home likhu-farm) 26)

    (road myagang-care-home gajuri-care-home)
    (road gajuri-care-home myagang-care-home)
    (= (travel-time myagang-care-home gajuri-care-home) 25)
    (= (travel-time gajuri-care-home myagang-care-home) 25)
    (damaged myagang-care-home gajuri-care-home)
    (damaged gajuri-care-home myagang-care-home)

    (road suryagadhi-care-home gajuri-care-home)
    (road gajuri-care-home suryagadhi-care-home)
    (= (travel-time suryagadhi-care-home gajuri-care-home) 29)
    (= (travel-time gajuri-care-home suryagadhi-care-home) 29)
    (damaged suryagadhi-care-home gajuri-care-home)
    (damaged gajuri-care-home suryagadhi-care-home)

    (road thakre-shelter myagang-care-home)
    (road myagang-care-home thakre-shelter)
    (= (travel-time thakre-shelter myagang-care-home) 24)
    (= (travel-time myagang-care-home thakre-shelter) 24)

    ;; evacuation points
    (evac-point thakre-shelter)
    (evac-point tarkeshwar-hospital)

    ;; car
    (car-at car1 thakre-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; waiting people
    (waiting myagang-care-home elderly n1)
    (waiting panchakanya-care-home injured n2)
    (waiting panchakanya-care-home elderly n1)
    (waiting likhu-farm adult n7)
    (waiting gajuri-care-home elderly n1)

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
    (waiting myagang-care-home elderly n0)
    (waiting panchakanya-care-home injured n0)
    (waiting panchakanya-care-home elderly n0)
    (waiting likhu-farm adult n0)
    (waiting gajuri-care-home elderly n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
