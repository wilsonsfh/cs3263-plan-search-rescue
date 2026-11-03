;; Plan, Search, Rescue! -- post-flood rescue domain (CS3263 Group 11)
;;
;; Cars drive along roads between locations, pick up civilians and drop them
;; at evacuation points. Damaged roads cannot be used.
;;
;; People are counted per band (injured, child, elderly, adult), so a
;; car can take any number of them that fits, and the people at one location
;; can be split across cars or trips.
;;
;; Priorities use soft goals compiled into action costs (Keyder & Geffner 2009):
;; everyone must end up either delivered to an evacuation point (cost: driving
;; time) or deferred to a later rescue wave (cost: a per-person penalty,
;; highest for the injured, then children, then the elderly, then adults).
;; Minimising total-cost therefore trades travel time against people deferred.
;;
;; Classical PDDL has no integer arithmetic in preconditions, so counts are
;; level objects n0, n1, ... with a static (sum ?a ?b ?c) relation meaning
;; a + b = c, and (positive ?n) for n > 0.
;; (Parameter names avoid ?before/?after, which VAL treats as keywords.)
;;
;; The earlier version, where each group had to travel together, is kept in
;; no-split/ for comparison.

(define (domain flood-rescue)
  (:requirements :strips :typing :negative-preconditions :action-costs)

  (:types location car band level)

  (:constants
    n0 - level
    injured child elderly adult - band)

  (:predicates
    (road ?from ?to - location)                    ; a road exists (listed in both directions)
    (damaged ?from ?to - location)                 ; road cannot be used by a car
    (evac-point ?l - location)                     ; safe drop-off location
    (car-at ?c - car ?l - location)
    (waiting ?l - location ?b - band ?n - level)   ; n people of band b still at l
    (carrying ?c - car ?b - band ?n - level)       ; n people of band b in car c
    (free-seats ?c - car ?n - level)
    (sum ?a ?b ?c - level)                         ; a + b = c
    (positive ?n - level))                         ; n > 0

  (:functions
    (total-cost) - number
    (travel-time ?from ?to - location) - number
    (defer-cost ?b - band ?n - level) - number)    ; penalty for deferring n people of band b

  (:action drive
    :parameters (?c - car ?from ?to - location)
    :precondition (and (car-at ?c ?from)
                       (road ?from ?to)
                       (not (damaged ?from ?to)))
    :effect (and (not (car-at ?c ?from))
                 (car-at ?c ?to)
                 (increase (total-cost) (travel-time ?from ?to))))

  ;; Pick up ?m people of band ?b at the car's location.
  (:action load
    :parameters (?c - car ?l - location ?b - band ?m ?w ?rest ?k ?k2 ?f ?f2 - level)
    :precondition (and (car-at ?c ?l)
                       (positive ?m)
                       (waiting ?l ?b ?w) (sum ?rest ?m ?w)
                       (carrying ?c ?b ?k) (sum ?k ?m ?k2)
                       (free-seats ?c ?f) (sum ?f2 ?m ?f))
    :effect (and (not (waiting ?l ?b ?w)) (waiting ?l ?b ?rest)
                 (not (carrying ?c ?b ?k)) (carrying ?c ?b ?k2)
                 (not (free-seats ?c ?f)) (free-seats ?c ?f2)))

  ;; Drop off everyone of band ?b in the car at an evacuation point.
  (:action unload
    :parameters (?c - car ?l - location ?b - band ?k ?f ?f2 - level)
    :precondition (and (car-at ?c ?l)
                       (evac-point ?l)
                       (positive ?k)
                       (carrying ?c ?b ?k)
                       (free-seats ?c ?f) (sum ?f ?k ?f2))
    :effect (and (not (carrying ?c ?b ?k)) (carrying ?c ?b n0)
                 (not (free-seats ?c ?f)) (free-seats ?c ?f2)))

  ;; Leave everyone of band ?b still waiting at ?l for a later rescue wave.
  (:action defer-rescue
    :parameters (?l - location ?b - band ?w - level)
    :precondition (and (waiting ?l ?b ?w)
                       (positive ?w))
    :effect (and (not (waiting ?l ?b ?w)) (waiting ?l ?b n0)
                 (increase (total-cost) (defer-cost ?b ?w))))
)
