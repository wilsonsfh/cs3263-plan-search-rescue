(define (problem large-09)
  (:domain flood-rescue)

  (:objects
    panchakanya-shelter myagang-hospital tarkeshwar-care-home suryagadhi-school
    kakani-market shivapuri-care-home naukunda-temple jwalamukhi-market
    gajuri-village kalika-school benighat-temple uttargaya-care-home - location
    car1 car2 - car
    n1 n2 n3 n4 n5 n6 - level)

  (:init
    ;; Roads
    (road panchakanya-shelter tarkeshwar-care-home)
    (road tarkeshwar-care-home panchakanya-shelter)
    (= (travel-time panchakanya-shelter tarkeshwar-care-home) 7)
    (= (travel-time tarkeshwar-care-home panchakanya-shelter) 7)
    (damaged panchakanya-shelter tarkeshwar-care-home)
    (damaged tarkeshwar-care-home panchakanya-shelter)

    (road panchakanya-shelter suryagadhi-school)
    (road suryagadhi-school panchakanya-shelter)
    (= (travel-time panchakanya-shelter suryagadhi-school) 36)
    (= (travel-time suryagadhi-school panchakanya-shelter) 36)
    (damaged panchakanya-shelter suryagadhi-school)
    (damaged suryagadhi-school panchakanya-shelter)

    (road myagang-hospital kakani-market)
    (road kakani-market myagang-hospital)
    (= (travel-time myagang-hospital kakani-market) 9)
    (= (travel-time kakani-market myagang-hospital) 9)

    (road myagang-hospital shivapuri-care-home)
    (road shivapuri-care-home myagang-hospital)
    (= (travel-time myagang-hospital shivapuri-care-home) 28)
    (= (travel-time shivapuri-care-home myagang-hospital) 28)

    (road naukunda-temple suryagadhi-school)
    (road suryagadhi-school naukunda-temple)
    (= (travel-time naukunda-temple suryagadhi-school) 6)
    (= (travel-time suryagadhi-school naukunda-temple) 6)

    (road jwalamukhi-market gajuri-village)
    (road gajuri-village jwalamukhi-market)
    (= (travel-time jwalamukhi-market gajuri-village) 15)
    (= (travel-time gajuri-village jwalamukhi-market) 15)

    (road jwalamukhi-market kakani-market)
    (road kakani-market jwalamukhi-market)
    (= (travel-time jwalamukhi-market kakani-market) 23)
    (= (travel-time kakani-market jwalamukhi-market) 23)
    (damaged jwalamukhi-market kakani-market)
    (damaged kakani-market jwalamukhi-market)

    (road jwalamukhi-market kalika-school)
    (road kalika-school jwalamukhi-market)
    (= (travel-time jwalamukhi-market kalika-school) 19)
    (= (travel-time kalika-school jwalamukhi-market) 19)

    (road jwalamukhi-market shivapuri-care-home)
    (road shivapuri-care-home jwalamukhi-market)
    (= (travel-time jwalamukhi-market shivapuri-care-home) 14)
    (= (travel-time shivapuri-care-home jwalamukhi-market) 14)
    (damaged jwalamukhi-market shivapuri-care-home)
    (damaged shivapuri-care-home jwalamukhi-market)

    (road gajuri-village suryagadhi-school)
    (road suryagadhi-school gajuri-village)
    (= (travel-time gajuri-village suryagadhi-school) 31)
    (= (travel-time suryagadhi-school gajuri-village) 31)

    (road gajuri-village kalika-school)
    (road kalika-school gajuri-village)
    (= (travel-time gajuri-village kalika-school) 8)
    (= (travel-time kalika-school gajuri-village) 8)

    (road gajuri-village shivapuri-care-home)
    (road shivapuri-care-home gajuri-village)
    (= (travel-time gajuri-village shivapuri-care-home) 11)
    (= (travel-time shivapuri-care-home gajuri-village) 11)

    (road suryagadhi-school uttargaya-care-home)
    (road uttargaya-care-home suryagadhi-school)
    (= (travel-time suryagadhi-school uttargaya-care-home) 19)
    (= (travel-time uttargaya-care-home suryagadhi-school) 19)

    (road benighat-temple kalika-school)
    (road kalika-school benighat-temple)
    (= (travel-time benighat-temple kalika-school) 13)
    (= (travel-time kalika-school benighat-temple) 13)
    (damaged benighat-temple kalika-school)
    (damaged kalika-school benighat-temple)

    (road benighat-temple shivapuri-care-home)
    (road shivapuri-care-home benighat-temple)
    (= (travel-time benighat-temple shivapuri-care-home) 20)
    (= (travel-time shivapuri-care-home benighat-temple) 20)

    (road benighat-temple uttargaya-care-home)
    (road uttargaya-care-home benighat-temple)
    (= (travel-time benighat-temple uttargaya-care-home) 20)
    (= (travel-time uttargaya-care-home benighat-temple) 20)

    (road kalika-school uttargaya-care-home)
    (road uttargaya-care-home kalika-school)
    (= (travel-time kalika-school uttargaya-care-home) 25)
    (= (travel-time uttargaya-care-home kalika-school) 25)
    (damaged kalika-school uttargaya-care-home)
    (damaged uttargaya-care-home kalika-school)

    ;; Evacuation points
    (evac-point panchakanya-shelter)
    (evac-point myagang-hospital)

    ;; Cars
    (car-at car1 panchakanya-shelter)
    (free-seats car1 n4)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)

    (car-at car2 myagang-hospital)
    (free-seats car2 n4)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)

    ;; People waiting
    (waiting kakani-market adult n6)
    (waiting kakani-market injured n3)
    (waiting jwalamukhi-market adult n4)
    (waiting jwalamukhi-market child n3)
    (waiting kalika-school child n5)
    (waiting tarkeshwar-care-home injured n3)
    (waiting tarkeshwar-care-home elderly n3)
    (waiting shivapuri-care-home adult n1)
    (waiting naukunda-temple adult n3)

    ;; Level arithmetic: a + b = c
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

    (positive n1) (positive n2) (positive n3)
    (positive n4) (positive n5) (positive n6)

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

    (= (total-cost) 0))

  (:goal (and
    (waiting kakani-market adult n0)
    (waiting kakani-market injured n0)
    (waiting jwalamukhi-market adult n0)
    (waiting jwalamukhi-market child n0)
    (waiting kalika-school child n0)
    (waiting tarkeshwar-care-home injured n0)
    (waiting tarkeshwar-care-home elderly n0)
    (waiting shivapuri-care-home adult n0)
    (waiting naukunda-temple adult n0)
    (carrying car1 injured n0)
    (carrying car1 child n0)
    (carrying car1 elderly n0)
    (carrying car1 adult n0)
    (carrying car2 injured n0)
    (carrying car2 child n0)
    (carrying car2 elderly n0)
    (carrying car2 adult n0)))

  (:metric minimize (total-cost))
)
