;; Advent of Code 2019 :: Day 4 :: Secure Container
;; https://adventofcode.com/2019/day/4

#lang racket

(struct state (passcode run-found? pair-found? current-run) #:transparent)

;; Return a list of possible states that succeed prev-state.
(define (next-states prev-state max-passcode)
  (define (loop p acc)
    (if (= p 10)
        acc
        (let ([passcode0 (+ p (* 10 (state-passcode prev-state)))])
          (if (<= passcode0 max-passcode)
              ;; If passcode0 is less than the maximum allowable passcode.
              (if (= p (remainder (state-passcode prev-state) 10))
                  ;; If the new digit is the same as the last digit, add passcode0 to the
                  ;; accumulator with the current run incremented by 1.
                  (loop (add1 p)
                        (cons (state passcode0
                                     #t
                                     (state-pair-found? prev-state)
                                     (add1 (state-current-run prev-state)))
                              acc))
                  ;; If the new digit is not the same, add passcode0 to the accumulator
                  ;; after setting pair-found? to true if the current-run is 2, otherwise recurse
                  ;; leave the pair-found? value to what it was previously.  The current run becomes 1.
                  (loop (add1 p)
                        (cons (state passcode0
                                     (state-run-found? prev-state)
                                     (or (state-pair-found? prev-state) (= 2 (state-current-run prev-state)))
                                     1)
                              acc)))
              ;; If passcode0 is more than the maximum allowable passcode, recurse without adding it
              ;; to the accumulator.
              (loop (add1 p) acc)))))
  ;; Loop over possible digits to add to passcode, starting with the last digit of passcode.
  (loop (remainder (state-passcode prev-state) 10) '()))

;; Count the number of passcodes between [min-passcode, max-passcode] such that the passcode
;; passes the predicate.
(define (solve min-passcode max-passcode predicate)
  (define (loop state)
    (if (and (<= min-passcode (state-passcode state)) (>= max-passcode (state-passcode state)))
        (if (predicate state)
            1
            0)
        (for/sum ([state0 (next-states state max-passcode)])
          (loop state0))))
  (for/sum ([p (range (quotient min-passcode 100000) (add1 (quotient max-passcode 100000)))])
    (loop (state p #f #f 1))))

(define (part1-predicate state)
  (state-run-found? state))

(define (part2-predicate state)
  (or (= 2 (state-current-run state)) (state-pair-found? state)))

(module+ main
  (printf "The solution to part 1 is ~a.~n" (solve 206938 679128 part1-predicate))
  (printf "The solution to part 2 is ~a.~n"
          (solve 206938 679128 part2-predicate)))