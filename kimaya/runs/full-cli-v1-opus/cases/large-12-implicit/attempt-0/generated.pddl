(define (problem flood-rescue-large-12)
  (:domain flood-rescue)

  (:objects
    benighat-shelter kalika-hospital belkot-school myagang-market
    dupcheshwar-temple jwalamukhi-village likhu-market tarkeshwar-village
    kakani-farm galchhi-temple tadi-farm - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads
    (road myagang-market dupcheshwar-temple)
    (road dupcheshwar-temple myagang-market)
    (= (travel-time myagang-market dupcheshwar-temple) 5)
    (= (travel-time dupcheshwar-temple myagang-market) 5)

    (road benighat-shelter dupcheshwar-temple)
    (road dupcheshwar-temple benighat-shelter)
    (= (travel-time benighat-shelter dupcheshwar-temple) 14)
    (= (travel-time dupcheshwar-temple benighat-shelter) 14)

    (road benighat-shelter jwalamukhi-village)
    (road jwalamukhi-village benighat-shelter)
    (= (travel-time benighat-shelter jwalamukhi-village) 14)
    (= (travel-time jwalamukhi-village benighat-shelter) 14)

    (road kalika-hospital likhu-market)
    (road likhu-market kalika-hospital)
    (= (travel-time kalika-hospital likhu-market) 13)
    (= (travel-time likhu-market kalika-hospital) 13)

    (road jwalamukhi-village tarkeshwar-village)
    (road tarkeshwar-village jwalamukhi-village)
    (= (travel-time jwalamukhi-village tarkeshwar-village) 16)
    (= (travel-time tarkeshwar-village jwalamukhi-village) 16)
    (damaged jwalamukhi-village tarkeshwar-village)
    (damaged tarkeshwar-village jwalamukhi-village)

    (road myagang-market belkot-school)
    (road belkot-school myagang-market)
    (= (travel-time myagang-market belkot-school) 12)
    (= (travel-time belkot-school myagang-market) 12)
    (damaged myagang-market belkot-school)
    (damaged belkot-school myagang-market)

    (road dupcheshwar-temple belkot-school)
    (road belkot-school dupcheshwar-temple)
    (= (travel-time dupcheshwar-temple belkot-school) 10)
    (= (travel-time belkot-school dupcheshwar-temple) 10)

    (road kakani-farm galchhi-temple)
    (road galchhi-temple kakani-farm)
    (= (travel-time kakani-farm galchhi-temple) 12)
    (= (travel-time galchhi-temple kakani-farm) 12)

    (road tadi-farm galchhi-temple)
    (road galchhi-temple tadi-farm)
    (= (travel-time tadi-farm galchhi-temple) 20)
    (= (travel-time galchhi-temple tadi-farm) 20)

    (road benighat-shelter myagang-market)
    (road myagang-market benighat-shelter)
    (= (travel-time benighat-shelter myagang-market) 17)
    (= (travel-time myagang-market benighat-shelter) 17)
    (damaged benighat-shelter myagang-market)
    (damaged myagang-market benighat-shelter)

    (road jwalamukhi-village likhu-market)
    (road likhu-market jwalamukhi-village)
    (= (travel-time jwalamukhi-village likhu-market) 11)
    (= (travel-time likhu-market jwalamukhi-village) 11)

    (road likhu-market dupcheshwar-temple)
    (road dupcheshwar-temple likhu-market)
    (= (travel-time likhu-market dupcheshwar-temple) 31)
    (= (travel-time dupcheshwar-temple likhu-market) 31)
    (damaged likhu-market dupcheshwar-temple)
    (damaged dupcheshwar-temple likhu-market)

    (road dupcheshwar-temple galchhi-temple)
    (road galchhi-temple dupcheshwar-temple)
    (= (travel-time dupcheshwar-temple galchhi-temple) 19)
    (= (travel-time galchhi-temple dupcheshwar-temple) 19)

    (road benighat-shelter belkot-school)
    (road belkot-school benighat-shelter)
    (= (travel-time benighat-shelter belkot-school) 5)
    (= (travel-time belkot-school benighat-shelter) 5)

    (road jwalamukhi-village belkot-school)
    (road belkot-school jwalamukhi-village)
    (= (travel-time jwalamukhi-village belkot-school) 18)
    (= (travel-time belkot-school jwalamukhi-village) 18)

    (road tarkeshwar-village belkot-school)
    (road belkot-school tarkeshwar-village)
    (= (travel-time tarkeshwar-village belkot-school) 9)
    (= (travel-time belkot-school tarkeshwar-village) 9)

    ;; Evacuation points
    (evac-point benighat-shelter)
    (evac-point kalika-hospital)

    ;; Cars
    (car-at car1 benighat-shelter)
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

    ;; Waiting people
    (waiting tarkeshwar-village injured n1)
    (waiting likhu-market adult n1)
    (waiting jwalamukhi-village elderly n3)
    (waiting jwalamukhi-village adult n1)
    (waiting kakani-farm elderly n2)
    (waiting kakani-farm adult n2)
    (waiting belkot-school adult n3)
    (waiting myagang-market adult n4)
    (waiting myagang-market child n3)
    (waiting tadi-farm adult n2)
    (waiting galchhi-temple elderly n1)

    ;; Level arithmetic
    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n1 n0 n1)
    (sum n0 n2 n2)
    (sum n1 n1 n2)
    (sum n2 n0 n2)
    (sum n0 n3 n3)
    (sum n1 n2 n3)
    (sum n2 n1 n3)
    (sum n3 n0 n3)
    (sum n0 n4 n4)
    (sum n1 n3 n4)
    (sum n2 n2 n4)
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
  )

  (:goal (and
    (waiting tarkeshwar-village injured n0)
    (waiting likhu-market adult n0)
    (waiting jwalamukhi-village elderly n0)
    (waiting jwalamukhi-village adult n0)
    (waiting kakani-farm elderly n0)
    (waiting kakani-farm adult n0)
    (waiting belkot-school adult n0)
    (waiting myagang-market adult n0)
    (waiting myagang-market child n0)
    (waiting tadi-farm adult n0)
    (waiting galchhi-temple elderly n0)
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
