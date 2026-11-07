(define (problem flood-rescue-large-07)
  (:domain flood-rescue)

  (:objects
    galchhi-shelter shivapuri-hospital naukunda-care-home kispang-temple
    kakani-village belkot-farm bidur-temple gosaikunda-village
    suryagadhi-farm likhu-care-home thakre-care-home myagang-care-home
    kalika-farm - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads
    (road galchhi-shelter naukunda-care-home)
    (road naukunda-care-home galchhi-shelter)
    (= (travel-time galchhi-shelter naukunda-care-home) 10)
    (= (travel-time naukunda-care-home galchhi-shelter) 10)

    (road galchhi-shelter kispang-temple)
    (road kispang-temple galchhi-shelter)
    (= (travel-time galchhi-shelter kispang-temple) 17)
    (= (travel-time kispang-temple galchhi-shelter) 17)

    (road galchhi-shelter kakani-village)
    (road kakani-village galchhi-shelter)
    (= (travel-time galchhi-shelter kakani-village) 5)
    (= (travel-time kakani-village galchhi-shelter) 5)

    (road galchhi-shelter belkot-farm)
    (road belkot-farm galchhi-shelter)
    (= (travel-time galchhi-shelter belkot-farm) 23)
    (= (travel-time belkot-farm galchhi-shelter) 23)

    (road shivapuri-hospital bidur-temple)
    (road bidur-temple shivapuri-hospital)
    (= (travel-time shivapuri-hospital bidur-temple) 14)
    (= (travel-time bidur-temple shivapuri-hospital) 14)
    (damaged shivapuri-hospital bidur-temple)
    (damaged bidur-temple shivapuri-hospital)

    (road shivapuri-hospital belkot-farm)
    (road belkot-farm shivapuri-hospital)
    (= (travel-time shivapuri-hospital belkot-farm) 17)
    (= (travel-time belkot-farm shivapuri-hospital) 17)
    (damaged shivapuri-hospital belkot-farm)
    (damaged belkot-farm shivapuri-hospital)

    (road bidur-temple belkot-farm)
    (road belkot-farm bidur-temple)
    (= (travel-time bidur-temple belkot-farm) 26)
    (= (travel-time belkot-farm bidur-temple) 26)

    (road gosaikunda-village naukunda-care-home)
    (road naukunda-care-home gosaikunda-village)
    (= (travel-time gosaikunda-village naukunda-care-home) 12)
    (= (travel-time naukunda-care-home gosaikunda-village) 12)

    (road gosaikunda-village kispang-temple)
    (road kispang-temple gosaikunda-village)
    (= (travel-time gosaikunda-village kispang-temple) 8)
    (= (travel-time kispang-temple gosaikunda-village) 8)

    (road gosaikunda-village belkot-farm)
    (road belkot-farm gosaikunda-village)
    (= (travel-time gosaikunda-village belkot-farm) 13)
    (= (travel-time belkot-farm gosaikunda-village) 13)

    (road suryagadhi-farm belkot-farm)
    (road belkot-farm suryagadhi-farm)
    (= (travel-time suryagadhi-farm belkot-farm) 40)
    (= (travel-time belkot-farm suryagadhi-farm) 40)

    (road naukunda-care-home kispang-temple)
    (road kispang-temple naukunda-care-home)
    (= (travel-time naukunda-care-home kispang-temple) 7)
    (= (travel-time kispang-temple naukunda-care-home) 7)

    (road likhu-care-home thakre-care-home)
    (road thakre-care-home likhu-care-home)
    (= (travel-time likhu-care-home thakre-care-home) 18)
    (= (travel-time thakre-care-home likhu-care-home) 18)

    (road likhu-care-home myagang-care-home)
    (road myagang-care-home likhu-care-home)
    (= (travel-time likhu-care-home myagang-care-home) 14)
    (= (travel-time myagang-care-home likhu-care-home) 14)

    (road likhu-care-home kalika-farm)
    (road kalika-farm likhu-care-home)
    (= (travel-time likhu-care-home kalika-farm) 20)
    (= (travel-time kalika-farm likhu-care-home) 20)

    (road thakre-care-home myagang-care-home)
    (road myagang-care-home thakre-care-home)
    (= (travel-time thakre-care-home myagang-care-home) 5)
    (= (travel-time myagang-care-home thakre-care-home) 5)
    (damaged thakre-care-home myagang-care-home)
    (damaged myagang-care-home thakre-care-home)

    (road myagang-care-home belkot-farm)
    (road belkot-farm myagang-care-home)
    (= (travel-time myagang-care-home belkot-farm) 18)
    (= (travel-time belkot-farm myagang-care-home) 18)

    (road kalika-farm belkot-farm)
    (road belkot-farm kalika-farm)
    (= (travel-time kalika-farm belkot-farm) 9)
    (= (travel-time belkot-farm kalika-farm) 9)

    ;; Evacuation points
    (evac-point galchhi-shelter)
    (evac-point shivapuri-hospital)

    ;; Cars
    (car-at car1 galchhi-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 shivapuri-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting thakre-care-home injured n1)
    (waiting gosaikunda-village adult n2)
    (waiting gosaikunda-village child n4)
    (waiting gosaikunda-village elderly n1)
    (waiting kalika-farm adult n6)
    (waiting belkot-farm elderly n4)
    (waiting naukunda-care-home elderly n1)
    (waiting likhu-care-home elderly n3)
    (waiting likhu-care-home injured n1)

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
  )

  (:goal (and
    (waiting thakre-care-home injured n0)
    (waiting gosaikunda-village adult n0)
    (waiting gosaikunda-village child n0)
    (waiting gosaikunda-village elderly n0)
    (waiting kalika-farm adult n0)
    (waiting belkot-farm elderly n0)
    (waiting naukunda-care-home elderly n0)
    (waiting likhu-care-home elderly n0)
    (waiting likhu-care-home injured n0)
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
