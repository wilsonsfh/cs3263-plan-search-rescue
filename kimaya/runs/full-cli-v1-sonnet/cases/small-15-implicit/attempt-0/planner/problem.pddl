(define (problem small-15)
  (:domain flood-rescue)

  (:objects
    shivapuri-shelter dhunche-temple kispang-care-home uttargaya-farm dupcheshwar-market kalika-farm - location
    car1 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; roads
    (road kispang-care-home dhunche-temple) (road dhunche-temple kispang-care-home)
    (= (travel-time kispang-care-home dhunche-temple) 23)
    (= (travel-time dhunche-temple kispang-care-home) 23)

    (road uttargaya-farm dupcheshwar-market) (road dupcheshwar-market uttargaya-farm)
    (= (travel-time uttargaya-farm dupcheshwar-market) 23)
    (= (travel-time dupcheshwar-market uttargaya-farm) 23)

    (road uttargaya-farm dhunche-temple) (road dhunche-temple uttargaya-farm)
    (= (travel-time uttargaya-farm dhunche-temple) 9)
    (= (travel-time dhunche-temple uttargaya-farm) 9)

    (road shivapuri-shelter dupcheshwar-market) (road dupcheshwar-market shivapuri-shelter)
    (= (travel-time shivapuri-shelter dupcheshwar-market) 32)
    (= (travel-time dupcheshwar-market shivapuri-shelter) 32)

    (road dupcheshwar-market kispang-care-home) (road kispang-care-home dupcheshwar-market)
    (= (travel-time dupcheshwar-market kispang-care-home) 29)
    (= (travel-time kispang-care-home dupcheshwar-market) 29)

    (road shivapuri-shelter kalika-farm) (road kalika-farm shivapuri-shelter)
    (= (travel-time shivapuri-shelter kalika-farm) 7)
    (= (travel-time kalika-farm shivapuri-shelter) 7)

    (road uttargaya-farm kispang-care-home) (road kispang-care-home uttargaya-farm)
    (= (travel-time uttargaya-farm kispang-care-home) 32)
    (= (travel-time kispang-care-home uttargaya-farm) 32)

    ;; evacuation points
    (evac-point shivapuri-shelter)

    ;; car
    (car-at car1 shivapuri-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    ;; people
    (waiting kalika-farm adult n3)
    (waiting dupcheshwar-market adult n1)
    (waiting uttargaya-farm adult n2)

    ;; sums
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; defer costs
    (= (defer-cost injured n1) 80) (= (defer-cost injured n2) 160)
    (= (defer-cost injured n3) 240) (= (defer-cost injured n4) 320)
    (= (defer-cost child n1) 60) (= (defer-cost child n2) 120)
    (= (defer-cost child n3) 180) (= (defer-cost child n4) 240)
    (= (defer-cost elderly n1) 50) (= (defer-cost elderly n2) 100)
    (= (defer-cost elderly n3) 150) (= (defer-cost elderly n4) 200)
    (= (defer-cost adult n1) 20) (= (defer-cost adult n2) 40)
    (= (defer-cost adult n3) 60) (= (defer-cost adult n4) 80))

  (:goal (and
    (waiting kalika-farm adult n0)
    (waiting dupcheshwar-market adult n0)
    (waiting uttargaya-farm adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)))

  (:metric minimize (total-cost)))
