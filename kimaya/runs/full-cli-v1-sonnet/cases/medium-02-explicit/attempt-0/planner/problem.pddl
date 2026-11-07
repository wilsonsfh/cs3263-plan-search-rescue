(define (problem flood-rescue-medium-02)
  (:domain flood-rescue)

  (:objects
    benighat-shelter jwalamukhi-care-home nilkantha-farm kalika-temple dhunche-hospital uttargaya-care-home likhu-village - location
    car1 car2 - car
    n1 n2 n3 n4 - level
  )

  (:init
    (= (total-cost) 0)

    ;; roads
    (road benighat-shelter jwalamukhi-care-home)
    (road jwalamukhi-care-home benighat-shelter)
    (= (travel-time benighat-shelter jwalamukhi-care-home) 21)
    (= (travel-time jwalamukhi-care-home benighat-shelter) 21)

    (road benighat-shelter nilkantha-farm)
    (road nilkantha-farm benighat-shelter)
    (= (travel-time benighat-shelter nilkantha-farm) 22)
    (= (travel-time nilkantha-farm benighat-shelter) 22)

    (road benighat-shelter kalika-temple)
    (road kalika-temple benighat-shelter)
    (= (travel-time benighat-shelter kalika-temple) 8)
    (= (travel-time kalika-temple benighat-shelter) 8)
    (damaged benighat-shelter kalika-temple)
    (damaged kalika-temple benighat-shelter)

    (road dhunche-hospital uttargaya-care-home)
    (road uttargaya-care-home dhunche-hospital)
    (= (travel-time dhunche-hospital uttargaya-care-home) 12)
    (= (travel-time uttargaya-care-home dhunche-hospital) 12)

    (road dhunche-hospital likhu-village)
    (road likhu-village dhunche-hospital)
    (= (travel-time dhunche-hospital likhu-village) 22)
    (= (travel-time likhu-village dhunche-hospital) 22)

    (road dhunche-hospital kalika-temple)
    (road kalika-temple dhunche-hospital)
    (= (travel-time dhunche-hospital kalika-temple) 30)
    (= (travel-time kalika-temple dhunche-hospital) 30)

    (road jwalamukhi-care-home nilkantha-farm)
    (road nilkantha-farm jwalamukhi-care-home)
    (= (travel-time jwalamukhi-care-home nilkantha-farm) 19)
    (= (travel-time nilkantha-farm jwalamukhi-care-home) 19)

    (road jwalamukhi-care-home kalika-temple)
    (road kalika-temple jwalamukhi-care-home)
    (= (travel-time jwalamukhi-care-home kalika-temple) 19)
    (= (travel-time kalika-temple jwalamukhi-care-home) 19)

    (road likhu-village kalika-temple)
    (road kalika-temple likhu-village)
    (= (travel-time likhu-village kalika-temple) 11)
    (= (travel-time kalika-temple likhu-village) 11)

    ;; evacuation points
    (evac-point benighat-shelter)
    (evac-point dhunche-hospital)

    ;; cars
    (car-at car1 benighat-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 dhunche-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; people waiting
    (waiting likhu-village adult n4)
    (waiting likhu-village injured n4)
    (waiting nilkantha-farm adult n1)
    (waiting nilkantha-farm injured n2)
    (waiting kalika-temple elderly n2)

    ;; sums
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
    (waiting likhu-village adult n0)
    (waiting likhu-village injured n0)
    (waiting nilkantha-farm adult n0)
    (waiting nilkantha-farm injured n0)
    (waiting kalika-temple elderly n0)
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
