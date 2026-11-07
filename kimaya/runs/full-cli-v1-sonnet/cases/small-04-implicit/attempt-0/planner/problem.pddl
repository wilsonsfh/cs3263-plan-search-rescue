(define (problem small-04)
  (:domain flood-rescue)

  (:objects
    naukunda-shelter likhu-school benighat-farm kakani-market jwalamukhi-temple - location
    car1 - car
    n1 n2 n3 n4 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road naukunda-shelter benighat-farm)
    (road benighat-farm naukunda-shelter)
    (= (travel-time naukunda-shelter benighat-farm) 11)
    (= (travel-time benighat-farm naukunda-shelter) 11)
    (damaged naukunda-shelter benighat-farm)
    (damaged benighat-farm naukunda-shelter)

    (road naukunda-shelter likhu-school)
    (road likhu-school naukunda-shelter)
    (= (travel-time naukunda-shelter likhu-school) 21)
    (= (travel-time likhu-school naukunda-shelter) 21)

    (road kakani-market benighat-farm)
    (road benighat-farm kakani-market)
    (= (travel-time kakani-market benighat-farm) 36)
    (= (travel-time benighat-farm kakani-market) 36)

    (road kakani-market likhu-school)
    (road likhu-school kakani-market)
    (= (travel-time kakani-market likhu-school) 16)
    (= (travel-time likhu-school kakani-market) 16)

    (road likhu-school jwalamukhi-temple)
    (road jwalamukhi-temple likhu-school)
    (= (travel-time likhu-school jwalamukhi-temple) 44)
    (= (travel-time jwalamukhi-temple likhu-school) 44)

    (road likhu-school benighat-farm)
    (road benighat-farm likhu-school)
    (= (travel-time likhu-school benighat-farm) 22)
    (= (travel-time benighat-farm likhu-school) 22)

    ;; evacuation points
    (evac-point naukunda-shelter)

    ;; car
    (car-at car1 naukunda-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; people waiting
    (waiting benighat-farm adult n3)
    (waiting likhu-school adult n3)

    ;; arithmetic
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; defer costs
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
    (waiting benighat-farm adult n0)
    (waiting likhu-school adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
  ))

  (:metric minimize (total-cost))
)
