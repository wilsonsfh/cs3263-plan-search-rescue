(define (problem flood-rescue-large-02)
  (:domain flood-rescue)

  (:objects
    bidur-shelter suryagadhi-hospital tarkeshwar-school kalika-village
    tadi-village likhu-market nilkantha-farm dupcheshwar-school
    trishuli-care-home jwalamukhi-market syaphru-school - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    (= (total-cost) 0)

    ;; Evacuation points
    (evac-point bidur-shelter)
    (evac-point suryagadhi-hospital)

    ;; Cars
    (car-at car1 bidur-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 suryagadhi-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; Roads
    (road kalika-village tadi-village)
    (road tadi-village kalika-village)
    (= (travel-time kalika-village tadi-village) 13)
    (= (travel-time tadi-village kalika-village) 13)

    (road likhu-market nilkantha-farm)
    (road nilkantha-farm likhu-market)
    (= (travel-time likhu-market nilkantha-farm) 26)
    (= (travel-time nilkantha-farm likhu-market) 26)
    (damaged likhu-market nilkantha-farm)
    (damaged nilkantha-farm likhu-market)

    (road tadi-village tarkeshwar-school)
    (road tarkeshwar-school tadi-village)
    (= (travel-time tadi-village tarkeshwar-school) 5)
    (= (travel-time tarkeshwar-school tadi-village) 5)

    (road dupcheshwar-school tarkeshwar-school)
    (road tarkeshwar-school dupcheshwar-school)
    (= (travel-time dupcheshwar-school tarkeshwar-school) 28)
    (= (travel-time tarkeshwar-school dupcheshwar-school) 28)

    (road suryagadhi-hospital likhu-market)
    (road likhu-market suryagadhi-hospital)
    (= (travel-time suryagadhi-hospital likhu-market) 10)
    (= (travel-time likhu-market suryagadhi-hospital) 10)
    (damaged suryagadhi-hospital likhu-market)
    (damaged likhu-market suryagadhi-hospital)

    (road bidur-shelter nilkantha-farm)
    (road nilkantha-farm bidur-shelter)
    (= (travel-time bidur-shelter nilkantha-farm) 7)
    (= (travel-time nilkantha-farm bidur-shelter) 7)

    (road dupcheshwar-school tadi-village)
    (road tadi-village dupcheshwar-school)
    (= (travel-time dupcheshwar-school tadi-village) 26)
    (= (travel-time tadi-village dupcheshwar-school) 26)

    (road suryagadhi-hospital trishuli-care-home)
    (road trishuli-care-home suryagadhi-hospital)
    (= (travel-time suryagadhi-hospital trishuli-care-home) 20)
    (= (travel-time trishuli-care-home suryagadhi-hospital) 20)

    (road nilkantha-farm jwalamukhi-market)
    (road jwalamukhi-market nilkantha-farm)
    (= (travel-time nilkantha-farm jwalamukhi-market) 17)
    (= (travel-time jwalamukhi-market nilkantha-farm) 17)

    (road jwalamukhi-market tarkeshwar-school)
    (road tarkeshwar-school jwalamukhi-market)
    (= (travel-time jwalamukhi-market tarkeshwar-school) 21)
    (= (travel-time tarkeshwar-school jwalamukhi-market) 21)

    (road kalika-village nilkantha-farm)
    (road nilkantha-farm kalika-village)
    (= (travel-time kalika-village nilkantha-farm) 19)
    (= (travel-time nilkantha-farm kalika-village) 19)

    (road kalika-village jwalamukhi-market)
    (road jwalamukhi-market kalika-village)
    (= (travel-time kalika-village jwalamukhi-market) 8)
    (= (travel-time jwalamukhi-market kalika-village) 8)

    (road bidur-shelter kalika-village)
    (road kalika-village bidur-shelter)
    (= (travel-time bidur-shelter kalika-village) 13)
    (= (travel-time kalika-village bidur-shelter) 13)
    (damaged bidur-shelter kalika-village)
    (damaged kalika-village bidur-shelter)

    (road syaphru-school trishuli-care-home)
    (road trishuli-care-home syaphru-school)
    (= (travel-time syaphru-school trishuli-care-home) 17)
    (= (travel-time trishuli-care-home syaphru-school) 17)

    (road suryagadhi-hospital syaphru-school)
    (road syaphru-school suryagadhi-hospital)
    (= (travel-time suryagadhi-hospital syaphru-school) 37)
    (= (travel-time syaphru-school suryagadhi-hospital) 37)
    (damaged suryagadhi-hospital syaphru-school)
    (damaged syaphru-school suryagadhi-hospital)

    (road syaphru-school tadi-village)
    (road tadi-village syaphru-school)
    (= (travel-time syaphru-school tadi-village) 48)
    (= (travel-time tadi-village syaphru-school) 48)

    ;; Waiting people
    (waiting kalika-village elderly n2)
    (waiting kalika-village adult n3)
    (waiting kalika-village child n2)
    (waiting syaphru-school child n6)
    (waiting jwalamukhi-market adult n4)
    (waiting nilkantha-farm adult n1)
    (waiting trishuli-care-home elderly n4)
    (waiting tarkeshwar-school child n4)

    ;; Positive levels
    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)
    (positive n5)
    (positive n6)

    ;; Sums
    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n0 n2 n2)
    (sum n0 n3 n3)
    (sum n0 n4 n4)
    (sum n0 n5 n5)
    (sum n0 n6 n6)
    (sum n1 n0 n1)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n1 n3 n4)
    (sum n1 n4 n5)
    (sum n1 n5 n6)
    (sum n2 n0 n2)
    (sum n2 n1 n3)
    (sum n2 n2 n4)
    (sum n2 n3 n5)
    (sum n2 n4 n6)
    (sum n3 n0 n3)
    (sum n3 n1 n4)
    (sum n3 n2 n5)
    (sum n3 n3 n6)
    (sum n4 n0 n4)
    (sum n4 n1 n5)
    (sum n4 n2 n6)
    (sum n5 n0 n5)
    (sum n5 n1 n6)
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
  )

  (:goal (and
    (waiting kalika-village elderly n0)
    (waiting kalika-village adult n0)
    (waiting kalika-village child n0)
    (waiting syaphru-school child n0)
    (waiting jwalamukhi-market adult n0)
    (waiting nilkantha-farm adult n0)
    (waiting trishuli-care-home elderly n0)
    (waiting tarkeshwar-school child n0)
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
