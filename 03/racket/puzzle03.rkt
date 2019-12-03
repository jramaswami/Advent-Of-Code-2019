;; Advent of Code 2019 :: Day 3 :: Crossed Wires
;; https://adventofcode.com/2019/day/3

#lang racket
(require racket/dict)

(define offsets
  (list
   (list "U" (list 0 -1))
   (list "D" (list 0 1))
   (list "R" (list 1 0))
   (list "L" (list -1 0))))

(define (get-offset dirn)
  (second (assoc dirn offsets)))

;; Solve puzzle.
(define (solve wires)
  ;; Run through the commands for a given wire.
  (define (run-wire wire posn steps visited)
    ;; Move and record visit to each intermediate posn.
    (define (move cmd posn steps visited)
      ;; Get next posn based on offset.
      (define (next-posn posn0 offset0)
        (list (+ (first posn0) (first offset0))
              (+ (second posn0) (second offset0))))
      ;; Record visit to posn, returning posn.
      (define (visit-posn posn0 steps0 visited0)
        (when (not (dict-has-key? visited0 posn0))
          (dict-set! visited0 posn0 steps0))
        posn0)
      ;; Loop over each posn in loop.
      (define (move-loop offset d posn0 steps0)
        (if (= d 0) (values posn0 steps0)
            (move-loop offset
                       (sub1 d)
                       (visit-posn (next-posn posn0 offset) (add1 steps0) visited)
                       (add1 steps0))))
      ;; First call to move-loop.
      (move-loop (get-offset (substring cmd 0 1))
                 (string->number (substring cmd 1))
                 posn
                 steps))
    ;; Recursively run the commands for the given wire.
    (if (empty? wire)
        visited
        (let-values ([(posn0 steps0) (move (first wire) posn steps visited)])
          (run-wire (rest wire) posn0 steps0 visited))))
  ;; Return the manhattan distance to the origin.
  (define (distance-to-origin posn)
    (+ (abs (first posn)) (abs (second posn))))
  ;; Return the total number of steps by wire0 and wire1 to reach the given posn.
  (define (steps-to-posn posn visited0 visited1)
    (+ (dict-ref visited0 posn) (dict-ref visited1 posn)))
  ;; Loop through the visited posns for the two wires to find the minimum distance
  ;; to the origin and the minimum number of steps to any given position touched by
  ;; both wires.
  (define (find-solution visited0 visited1)
    (define (soln-loop posns min-steps min-dist)
      (if (empty? posns)
          (values min-dist  min-steps)
          (if (dict-has-key? visited1 (first posns))
              (soln-loop (rest posns)
                         (min min-steps (steps-to-posn (first posns) visited0 visited1))
                         (min min-dist (distance-to-origin (first posns))))
              (soln-loop (rest posns) min-steps min-dist))))
    (soln-loop (dict-keys visited0) 9999999999 9999999999))
  ;; Find the solution ... returning both the minimum distance and steps.
  (find-solution (run-wire (first wires) (list 0 0) 0 (make-hash))
                 (run-wire (second wires) (list 0 0) 0 (make-hash))))

(module+ main
  (require racket/file)
  (define wires (map (λ (x) (string-split (string-trim x) ",")) (file->lines "../input.txt")))
  (let-values ([(part1-soln part2-soln) (solve wires)])
    (printf "The solution to part 1 is ~a.~n" part1-soln)
    (printf "The solution to part 2 is ~a.~n" part2-soln)))