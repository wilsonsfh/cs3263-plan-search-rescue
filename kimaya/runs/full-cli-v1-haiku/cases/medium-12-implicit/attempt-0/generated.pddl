(define (problem flood-rescue-medium-12)
  (:domain flood-rescue)

  (:objects
    panchakanya-shelter shivapuri-hospital trishuli-temple suryagadhi-village
    kakani-farm galchhi-market jwalamukhi-village - location
    car1 car2 - car
    n1 n2 n3 n4 - level)

  (:init
    (= (total-cost) 0)

    ;; Roads (both directions), travel times in minutes
    (road suryagadhi-village kakani-farm)
    (road kakani-farm suryagadhi-village)
    (= (travel-time suryagadhi-village kakani-farm) 6)
    (= (travel-time kakani-farm suryagadhi-village) 6)

    (road trishuli-temple kakani-farm)
    (road kakani-farm trishuli-temple)
    (= (travel-time trishuli-temple kakani-farm) 8)
    (= (travel-time kakani-farm trishuli-temple) 8)

    (road panchakanya-shelter galchhi-market)
    (road galchhi-market panchakanya-shelter)
    (= (travel-time panchakanya-shelter galchhi-market) 19)
    (= (travel-time galchhi-market panchakanya-shelter) 19)

    (road panchakanya-shelter jwalamukhi-village)
    (road jwalamukhi-village panchakanya-shelter)
    (= (travel-time panchakanya-shelter jwalamukhi-village) 27)
    (= (travel-time jwalamukhi-village panchakanya-shelter) 27)

    (road panchakanya-shelter kakani-farm)
    (road kakani-farm panchakanya-shelter)
    (= (travel-time panchakanya-shelter kakani-farm) 40)
    (= (travel-time kakani-farm panchakanya-shelter) 40)

    (road shivapuri-hospital galchhi-market)
    (road galchhi-market shivapuri-hospital)
    (= (travel-time shivapuri-hospital galchhi-market) 40)
    (= (travel-time galchhi-market shivapuri-hospital) 40)

    (road panchakanya-shelter shivapuri-hospital)
    (road shivapuri-hospital panchakanya-shelter)
    (= (travel-time panchakanya-shelter shivapuri-hospital) 26)
    (= (travel-time shivapuri-hospital panchakanya-shelter) 26)

    (road panchakanya-shelter suryagadhi-village)
    (road suryagadhi-village panchakanya-shelter)
    (= (travel-time panchakanya-shelter suryagadhi-village) 37)
    (= (travel-time suryagadhi-village panchakanya-shelter) 37)

    (road shivapuri-hospital suryagadhi-village)
    (road suryagadhi-village shivapuri-hospital)
    (= (travel-time shivapuri-hospital suryagadhi-village) 30)
    (= (travel-time suryagadhi-village shivapuri-hospital) 30)

    ;; Evacuation points (trishuli-temple is not designated)
    (evac-point panchakanya-shelter)
    (evac-point shivapuri-hospital)

    ;; Cars
    (car-at car1 panchakanya-shelter)
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

    ;; People waiting at locations
    (waiting kakani-farm adult n4)
    (waiting jwalamukhi-village child n4)
    (waiting jwalamukhi-village adult n3)
    (waiting galchhi-market injured n4)
    (waiting suryagadhi-village elderly n4)

    ;; Arithmetic relations within n0 ... n4
    (sum n0 n0 n0) (sum n0 n1 n1) (sum n0 n2 n2) (sum n0 n3 n3) (sum n0 n4 n4)
    (sum n1 n0 n1) (sum n1 n1 n2) (sum n1 n2 n3) (sum n1 n3 n4)
    (sum n2 n0 n2) (sum n2 n1 n3) (sum n2 n2 n4)
    (sum n3 n0 n3) (sum n3 n1 n4)
    (sum n4 n0 n4)

    (positive n1) (positive n2) (positive n3) (positive n4)

    ;; Deferral penalties: per-person penalty x N
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
    ;; Everyone rescued or deferred
    (waiting kakani-farm adult n0)
    (waiting jwalamukhi-village child n0)
    (waiting jwalamukhi-village adult n0)
    (waiting galchhi-market injured n0)
    (waiting suryagadhi-village elderly n0)

    ;; Cars unloaded
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
