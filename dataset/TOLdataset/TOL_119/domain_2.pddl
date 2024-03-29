
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Domain file automatically generated by the Tarski FSTRIPS writer
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain TOL)
    (:requirements :equality)
    (:types
        object
    )

    (:constants
        
    )

    (:predicates
        (handempty )
        (free-loc_0_0 )
        (free-loc_0_1 )
        (free-loc_0_2 )
        (free-loc_1_0 )
        (free-loc_1_1 )
        (free-loc_2_0 )
        (clear-b_0 )
        (hold-b_0 )
        (clear-b_1 )
        (hold-b_1 )
        (clear-b_2 )
        (hold-b_2 )
        (at-b_0-loc_0_0 )
        (at-b_1-loc_0_0 )
        (at-b_2-loc_0_0 )
        (at-b_0-loc_0_1 )
        (at-b_1-loc_0_1 )
        (at-b_2-loc_0_1 )
        (at-b_0-loc_0_2 )
        (at-b_1-loc_0_2 )
        (at-b_2-loc_0_2 )
        (at-b_0-loc_1_0 )
        (at-b_1-loc_1_0 )
        (at-b_2-loc_1_0 )
        (at-b_0-loc_1_1 )
        (at-b_1-loc_1_1 )
        (at-b_2-loc_1_1 )
        (at-b_0-loc_2_0 )
        (at-b_1-loc_2_0 )
        (at-b_2-loc_2_0 )
    )

    (:functions
        
    )

    

    
    (:action pick_0
     :parameters ()
     :precondition (and (and (and (at-b_0-loc_0_1 ) (at-b_1-loc_0_0 )) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_0_1 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (clear-b_1 )
        (free-loc_0_1 ))
    )


    (:action pick_1
     :parameters ()
     :precondition (and (and (and (at-b_0-loc_0_2 ) (at-b_1-loc_0_1 )) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_0_2 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (clear-b_1 )
        (free-loc_0_2 ))
    )


    (:action pick_2
     :parameters ()
     :precondition (and (and (and (at-b_0-loc_1_1 ) (at-b_1-loc_1_0 )) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_1_1 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (clear-b_1 )
        (free-loc_1_1 ))
    )


    (:action pick_3
     :parameters ()
     :precondition (and (and (and (at-b_0-loc_0_1 ) (at-b_2-loc_0_0 )) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_0_1 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (clear-b_2 )
        (free-loc_0_1 ))
    )


    (:action pick_4
     :parameters ()
     :precondition (and (and (and (at-b_0-loc_0_2 ) (at-b_2-loc_0_1 )) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_0_2 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (clear-b_2 )
        (free-loc_0_2 ))
    )


    (:action pick_5
     :parameters ()
     :precondition (and (and (and (at-b_0-loc_1_1 ) (at-b_2-loc_1_0 )) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_1_1 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (clear-b_2 )
        (free-loc_1_1 ))
    )


    (:action pick_6
     :parameters ()
     :precondition (and (and (and (at-b_1-loc_0_1 ) (at-b_0-loc_0_0 )) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_0_1 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (clear-b_0 )
        (free-loc_0_1 ))
    )


    (:action pick_7
     :parameters ()
     :precondition (and (and (and (at-b_1-loc_0_2 ) (at-b_0-loc_0_1 )) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_0_2 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (clear-b_0 )
        (free-loc_0_2 ))
    )


    (:action pick_8
     :parameters ()
     :precondition (and (and (and (at-b_1-loc_1_1 ) (at-b_0-loc_1_0 )) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_1_1 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (clear-b_0 )
        (free-loc_1_1 ))
    )


    (:action pick_9
     :parameters ()
     :precondition (and (and (and (at-b_1-loc_0_1 ) (at-b_2-loc_0_0 )) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_0_1 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (clear-b_2 )
        (free-loc_0_1 ))
    )


    (:action pick_10
     :parameters ()
     :precondition (and (and (and (at-b_1-loc_0_2 ) (at-b_2-loc_0_1 )) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_0_2 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (clear-b_2 )
        (free-loc_0_2 ))
    )


    (:action pick_11
     :parameters ()
     :precondition (and (and (and (at-b_1-loc_1_1 ) (at-b_2-loc_1_0 )) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_1_1 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (clear-b_2 )
        (free-loc_1_1 ))
    )


    (:action pick_12
     :parameters ()
     :precondition (and (and (and (at-b_2-loc_0_1 ) (at-b_0-loc_0_0 )) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_0_1 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (clear-b_0 )
        (free-loc_0_1 ))
    )


    (:action pick_13
     :parameters ()
     :precondition (and (and (and (at-b_2-loc_0_2 ) (at-b_0-loc_0_1 )) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_0_2 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (clear-b_0 )
        (free-loc_0_2 ))
    )


    (:action pick_14
     :parameters ()
     :precondition (and (and (and (at-b_2-loc_1_1 ) (at-b_0-loc_1_0 )) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_1_1 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (clear-b_0 )
        (free-loc_1_1 ))
    )


    (:action pick_15
     :parameters ()
     :precondition (and (and (and (at-b_2-loc_0_1 ) (at-b_1-loc_0_0 )) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_0_1 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (clear-b_1 )
        (free-loc_0_1 ))
    )


    (:action pick_16
     :parameters ()
     :precondition (and (and (and (at-b_2-loc_0_2 ) (at-b_1-loc_0_1 )) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_0_2 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (clear-b_1 )
        (free-loc_0_2 ))
    )


    (:action pick_17
     :parameters ()
     :precondition (and (and (and (at-b_2-loc_1_1 ) (at-b_1-loc_1_0 )) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_1_1 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (clear-b_1 )
        (free-loc_1_1 ))
    )


    (:action pick_18
     :parameters ()
     :precondition (and (and (at-b_0-loc_0_0 ) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_0_0 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (free-loc_0_0 ))
    )


    (:action pick_19
     :parameters ()
     :precondition (and (and (at-b_0-loc_1_0 ) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_1_0 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (free-loc_1_0 ))
    )


    (:action pick_20
     :parameters ()
     :precondition (and (and (at-b_0-loc_2_0 ) (handempty )) (clear-b_0 ))
     :effect (and
        (not (at-b_0-loc_2_0 ))
        (not (clear-b_0 ))
        (not (handempty ))
        (hold-b_0 )
        (free-loc_2_0 ))
    )


    (:action pick_21
     :parameters ()
     :precondition (and (and (at-b_1-loc_0_0 ) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_0_0 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (free-loc_0_0 ))
    )


    (:action pick_22
     :parameters ()
     :precondition (and (and (at-b_1-loc_1_0 ) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_1_0 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (free-loc_1_0 ))
    )


    (:action pick_23
     :parameters ()
     :precondition (and (and (at-b_1-loc_2_0 ) (handempty )) (clear-b_1 ))
     :effect (and
        (not (at-b_1-loc_2_0 ))
        (not (clear-b_1 ))
        (not (handempty ))
        (hold-b_1 )
        (free-loc_2_0 ))
    )


    (:action pick_24
     :parameters ()
     :precondition (and (and (at-b_2-loc_0_0 ) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_0_0 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (free-loc_0_0 ))
    )


    (:action pick_25
     :parameters ()
     :precondition (and (and (at-b_2-loc_1_0 ) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_1_0 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (free-loc_1_0 ))
    )


    (:action pick_26
     :parameters ()
     :precondition (and (and (at-b_2-loc_2_0 ) (handempty )) (clear-b_2 ))
     :effect (and
        (not (at-b_2-loc_2_0 ))
        (not (clear-b_2 ))
        (not (handempty ))
        (hold-b_2 )
        (free-loc_2_0 ))
    )


    (:action put_0
     :parameters ()
     :precondition (and (and (and (free-loc_0_1 ) (at-b_1-loc_0_0 )) (hold-b_0 )) (clear-b_1 ))
     :effect (and
        (at-b_0-loc_0_1 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (clear-b_1 ))
        (not (free-loc_0_1 )))
    )


    (:action put_1
     :parameters ()
     :precondition (and (and (and (free-loc_0_2 ) (at-b_1-loc_0_1 )) (hold-b_0 )) (clear-b_1 ))
     :effect (and
        (at-b_0-loc_0_2 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (clear-b_1 ))
        (not (free-loc_0_2 )))
    )


    (:action put_2
     :parameters ()
     :precondition (and (and (and (free-loc_1_1 ) (at-b_1-loc_1_0 )) (hold-b_0 )) (clear-b_1 ))
     :effect (and
        (at-b_0-loc_1_1 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (clear-b_1 ))
        (not (free-loc_1_1 )))
    )


    (:action put_3
     :parameters ()
     :precondition (and (and (and (free-loc_0_1 ) (at-b_2-loc_0_0 )) (hold-b_0 )) (clear-b_2 ))
     :effect (and
        (at-b_0-loc_0_1 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (clear-b_2 ))
        (not (free-loc_0_1 )))
    )


    (:action put_4
     :parameters ()
     :precondition (and (and (and (free-loc_0_2 ) (at-b_2-loc_0_1 )) (hold-b_0 )) (clear-b_2 ))
     :effect (and
        (at-b_0-loc_0_2 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (clear-b_2 ))
        (not (free-loc_0_2 )))
    )


    (:action put_5
     :parameters ()
     :precondition (and (and (and (free-loc_1_1 ) (at-b_2-loc_1_0 )) (hold-b_0 )) (clear-b_2 ))
     :effect (and
        (at-b_0-loc_1_1 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (clear-b_2 ))
        (not (free-loc_1_1 )))
    )


    (:action put_6
     :parameters ()
     :precondition (and (and (and (free-loc_0_1 ) (at-b_0-loc_0_0 )) (hold-b_1 )) (clear-b_0 ))
     :effect (and
        (at-b_1-loc_0_1 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (clear-b_0 ))
        (not (free-loc_0_1 )))
    )


    (:action put_7
     :parameters ()
     :precondition (and (and (and (free-loc_0_2 ) (at-b_0-loc_0_1 )) (hold-b_1 )) (clear-b_0 ))
     :effect (and
        (at-b_1-loc_0_2 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (clear-b_0 ))
        (not (free-loc_0_2 )))
    )


    (:action put_8
     :parameters ()
     :precondition (and (and (and (free-loc_1_1 ) (at-b_0-loc_1_0 )) (hold-b_1 )) (clear-b_0 ))
     :effect (and
        (at-b_1-loc_1_1 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (clear-b_0 ))
        (not (free-loc_1_1 )))
    )


    (:action put_9
     :parameters ()
     :precondition (and (and (and (free-loc_0_1 ) (at-b_2-loc_0_0 )) (hold-b_1 )) (clear-b_2 ))
     :effect (and
        (at-b_1-loc_0_1 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (clear-b_2 ))
        (not (free-loc_0_1 )))
    )


    (:action put_10
     :parameters ()
     :precondition (and (and (and (free-loc_0_2 ) (at-b_2-loc_0_1 )) (hold-b_1 )) (clear-b_2 ))
     :effect (and
        (at-b_1-loc_0_2 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (clear-b_2 ))
        (not (free-loc_0_2 )))
    )


    (:action put_11
     :parameters ()
     :precondition (and (and (and (free-loc_1_1 ) (at-b_2-loc_1_0 )) (hold-b_1 )) (clear-b_2 ))
     :effect (and
        (at-b_1-loc_1_1 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (clear-b_2 ))
        (not (free-loc_1_1 )))
    )


    (:action put_12
     :parameters ()
     :precondition (and (and (and (free-loc_0_1 ) (at-b_0-loc_0_0 )) (hold-b_2 )) (clear-b_0 ))
     :effect (and
        (at-b_2-loc_0_1 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (clear-b_0 ))
        (not (free-loc_0_1 )))
    )


    (:action put_13
     :parameters ()
     :precondition (and (and (and (free-loc_0_2 ) (at-b_0-loc_0_1 )) (hold-b_2 )) (clear-b_0 ))
     :effect (and
        (at-b_2-loc_0_2 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (clear-b_0 ))
        (not (free-loc_0_2 )))
    )


    (:action put_14
     :parameters ()
     :precondition (and (and (and (free-loc_1_1 ) (at-b_0-loc_1_0 )) (hold-b_2 )) (clear-b_0 ))
     :effect (and
        (at-b_2-loc_1_1 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (clear-b_0 ))
        (not (free-loc_1_1 )))
    )


    (:action put_15
     :parameters ()
     :precondition (and (and (and (free-loc_0_1 ) (at-b_1-loc_0_0 )) (hold-b_2 )) (clear-b_1 ))
     :effect (and
        (at-b_2-loc_0_1 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (clear-b_1 ))
        (not (free-loc_0_1 )))
    )


    (:action put_16
     :parameters ()
     :precondition (and (and (and (free-loc_0_2 ) (at-b_1-loc_0_1 )) (hold-b_2 )) (clear-b_1 ))
     :effect (and
        (at-b_2-loc_0_2 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (clear-b_1 ))
        (not (free-loc_0_2 )))
    )


    (:action put_17
     :parameters ()
     :precondition (and (and (and (free-loc_1_1 ) (at-b_1-loc_1_0 )) (hold-b_2 )) (clear-b_1 ))
     :effect (and
        (at-b_2-loc_1_1 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (clear-b_1 ))
        (not (free-loc_1_1 )))
    )


    (:action put_18
     :parameters ()
     :precondition (and (free-loc_0_0 ) (hold-b_0 ))
     :effect (and
        (at-b_0-loc_0_0 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (free-loc_0_0 )))
    )


    (:action put_19
     :parameters ()
     :precondition (and (free-loc_1_0 ) (hold-b_0 ))
     :effect (and
        (at-b_0-loc_1_0 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (free-loc_1_0 )))
    )


    (:action put_20
     :parameters ()
     :precondition (and (free-loc_2_0 ) (hold-b_0 ))
     :effect (and
        (at-b_0-loc_2_0 )
        (clear-b_0 )
        (handempty )
        (not (hold-b_0 ))
        (not (free-loc_2_0 )))
    )


    (:action put_21
     :parameters ()
     :precondition (and (free-loc_0_0 ) (hold-b_1 ))
     :effect (and
        (at-b_1-loc_0_0 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (free-loc_0_0 )))
    )


    (:action put_22
     :parameters ()
     :precondition (and (free-loc_1_0 ) (hold-b_1 ))
     :effect (and
        (at-b_1-loc_1_0 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (free-loc_1_0 )))
    )


    (:action put_23
     :parameters ()
     :precondition (and (free-loc_2_0 ) (hold-b_1 ))
     :effect (and
        (at-b_1-loc_2_0 )
        (clear-b_1 )
        (handempty )
        (not (hold-b_1 ))
        (not (free-loc_2_0 )))
    )


    (:action put_24
     :parameters ()
     :precondition (and (free-loc_0_0 ) (hold-b_2 ))
     :effect (and
        (at-b_2-loc_0_0 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (free-loc_0_0 )))
    )


    (:action put_25
     :parameters ()
     :precondition (and (free-loc_1_0 ) (hold-b_2 ))
     :effect (and
        (at-b_2-loc_1_0 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (free-loc_1_0 )))
    )


    (:action put_26
     :parameters ()
     :precondition (and (free-loc_2_0 ) (hold-b_2 ))
     :effect (and
        (at-b_2-loc_2_0 )
        (clear-b_2 )
        (handempty )
        (not (hold-b_2 ))
        (not (free-loc_2_0 )))
    )

)