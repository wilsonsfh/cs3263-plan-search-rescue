(define (problem flood-rescue-small-07)
  (:domain flood-rescue)

  (:objects
    naukunda-shelter gosaikunda-school shivapuri-care-home myagang-care-home kalika-care-home - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    ;; Roads
    (road naukunda-shelter gosaikunda-school)
    (road gosaikunda-school naukunda-shelter)
    (= (travel-time naukunda-shelter gosaikunda-school) 28)
    (= (travel-time gosaikunda-school naukunda-shelter) 28)

    (road gosaikunda-school shivapuri-care-home)
    (road shivapuri-care-home gosaikunda-school)
    (= (travel-time gosaikunda-school shivapuri-care-home) 47)
    (= (travel-time shivapuri-care-home gosaikunda-school) 47)

    (road naukunda-shelter myagang-care-home)
    (road myagang-care-home naukunda-shelter)
    (= (travel-time naukunda-shelter myagang-care-home) 5)
    (= (travel-time myagang-care-home naukunda-shelter) 5)

    (road myagang-care-home kalika-care-home)
    (road kalika-care-home myagang-care-home)
    (= (travel-time myagang-care-home kalika-care-home) 27)
    (= (travel-time kalika-care-home myagang-care-home) 27)

    (road naukunda-shelter kalika-care-home)
    (road kalika-care-home naukunda-shelter)
    (= (travel-time naukunda-shelter kalika-care-home) 26)
    (= (travel-time kalika-care-home naukunda-shelter) 26)

    (road gosaikunda-school kalika-care-home)
    (road kalika-care-home gosaikunda-school)
    (= (travel-time gosaikunda-school kalika-care-home) 5)
    (= (travel-time kalika-care-home gosaikunda-school) 5)

    ;; Evacuation points
    (evac-point naukunda-shelter)

    ;; Cars
    (car-at car1 naukunda-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; Waiting people
    (waiting gosaikunda-school child n4)
    (waiting gosaikunda-school injured n4)
    (waiting myagang-care-home elderly n3)

    ;; Level arithmetic
    (sum n0 n0 n0)
    (sum n0 n1 n1)
    (sum n0 n2 n2)
    (sum n0 n3 n3)
    (sum n0 n4 n4)
    (sum n1 n0 n1)
    (sum n1 n1 n2)
    (sum n1 n2 n3)
    (sum n1 n3 n4)
    (sum n2 n0 n2)
    (sum n2 n1 n3)
    (sum n2 n2 n4)
    (sum n3 n0 n3)
    (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1)
    (positive n2)
    (positive n3)
    (positive n4)

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
    (waiting gosaikunda-school child n0)
    (waiting gosaikunda-school injured n0)
    (waiting myagang-care-home elderly n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)))

  (:metric minimize (total-cost))
)
