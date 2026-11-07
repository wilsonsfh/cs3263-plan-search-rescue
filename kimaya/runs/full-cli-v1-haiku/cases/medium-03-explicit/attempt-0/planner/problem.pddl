(define (problem flood-rescue-nuwakot-medium-03)
  (:domain flood-rescue)

  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:objects
    car1 car2 - car
    uttargaya-shelter thakre-hospital bidur-care-home kalika-temple
    belkot-village kakani-temple naukunda-village suryagadhi-school - location
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    ;; Roads, both directions
    (road uttargaya-shelter bidur-care-home)
    (road bidur-care-home uttargaya-shelter)
    (road uttargaya-shelter kalika-temple)
    (road kalika-temple uttargaya-shelter)
    (road uttargaya-shelter belkot-village)
    (road belkot-village uttargaya-shelter)
    (road uttargaya-shelter kakani-temple)
    (road kakani-temple uttargaya-shelter)
    (road thakre-hospital bidur-care-home)
    (road bidur-care-home thakre-hospital)
    (road bidur-care-home kalika-temple)
    (road kalika-temple bidur-care-home)
    (road kalika-temple belkot-village)
    (road belkot-village kalika-temple)
    (road kalika-temple naukunda-village)
    (road naukunda-village kalika-temple)
    (road belkot-village naukunda-village)
    (road naukunda-village belkot-village)
    (road kakani-temple suryagadhi-school)
    (road suryagadhi-school kakani-temple)

    ;; Travel times
    (= (travel-time uttargaya-shelter bidur-care-home) 8)
    (= (travel-time bidur-care-home uttargaya-shelter) 8)
    (= (travel-time uttargaya-shelter kalika-temple) 11)
    (= (travel-time kalika-temple uttargaya-shelter) 11)
    (= (travel-time uttargaya-shelter belkot-village) 16)
    (= (travel-time belkot-village uttargaya-shelter) 16)
    (= (travel-time uttargaya-shelter kakani-temple) 20)
    (= (travel-time kakani-temple uttargaya-shelter) 20)
    (= (travel-time thakre-hospital bidur-care-home) 22)
    (= (travel-time bidur-care-home thakre-hospital) 22)
    (= (travel-time bidur-care-home kalika-temple) 14)
    (= (travel-time kalika-temple bidur-care-home) 14)
    (= (travel-time kalika-temple belkot-village) 6)
    (= (travel-time belkot-village kalika-temple) 6)
    (= (travel-time kalika-temple naukunda-village) 15)
    (= (travel-time naukunda-village kalika-temple) 15)
    (= (travel-time belkot-village naukunda-village) 14)
    (= (travel-time naukunda-village belkot-village) 14)
    (= (travel-time kakani-temple suryagadhi-school) 6)
    (= (travel-time suryagadhi-school kakani-temple) 6)

    ;; Damaged roads (impassable)
    (damaged uttargaya-shelter kakani-temple)
    (damaged kakani-temple uttargaya-shelter)

    ;; Evacuation points
    (evac-point uttargaya-shelter)
    (evac-point thakre-hospital)

    ;; Cars
    (car-at car1 uttargaya-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 thakre-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting kalika-temple elderly n4)
    (waiting kakani-temple elderly n1)
    (waiting kakani-temple adult n4)
    (waiting suryagadhi-school child n6)
    (waiting bidur-care-home elderly n3)

    ;; Addition relation a + b = c over n0..n6
    (sum n0 n0 n0)
    (sum n0 n1 n1) (sum n1 n0 n1)
    (sum n0 n2 n2) (sum n1 n1 n2) (sum n2 n0 n2)
    (sum n0 n3 n3) (sum n1 n2 n3) (sum n2 n1 n3) (sum n3 n0 n3)
    (sum n0 n4 n4) (sum n1 n3 n4) (sum n2 n2 n4) (sum n3 n1 n4) (sum n4 n0 n4)
    (sum n0 n5 n5) (sum n1 n4 n5) (sum n2 n3 n5) (sum n3 n2 n5) (sum n4 n1 n5) (sum n5 n0 n5)
    (sum n0 n6 n6) (sum n1 n5 n6) (sum n2 n4 n6) (sum n3 n3 n6) (sum n4 n2 n6) (sum n5 n1 n6) (sum n6 n0 n6)

    ;; Positive levels
    (positive n1) (positive n2) (positive n3)
    (positive n4) (positive n5) (positive n6)

    ;; Deferral penalties: injured 80, child 60, elderly 50, adult 20 per person
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
    ;; Everyone waiting is either rescued or deferred
    (waiting kalika-temple elderly n0)
    (waiting kakani-temple elderly n0)
    (waiting kakani-temple adult n0)
    (waiting suryagadhi-school child n0)
    (waiting bidur-care-home elderly n0)

    ;; Both cars end empty
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
