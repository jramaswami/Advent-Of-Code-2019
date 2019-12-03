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



;; Get next posn based on offset.
(define (next-posn posn offset)
  (list (+ (first posn) (first offset))
        (+ (second posn) (second offset))))

;; Record visit to posn, returning posn.
(define (visit-posn posn steps visited)
  (when (not (dict-has-key? visited posn))
    (dict-set! visited posn steps))
  posn)

;; Move and record visit to each intermediate posn.
(define (move cmd posn steps visited)
  (define dirn (substring cmd 0 1))
  (define dist (string->number (substring cmd 1)))
  (define offset (get-offset dirn))
  (define (move-loop d posn0 steps0)
    (if (= d 0) (values posn0 steps0)
        (move-loop (sub1 d)
                   (visit-posn (next-posn posn0 offset) (add1 steps0) visited)
                   (add1 steps0))))
  (move-loop dist posn steps))

(define (solve wires)
  (define wire0 (first wires))
  (define wire1 (second wires))
  (define visited0 (make-hash))
  (define visited1 (make-hash))
  (define (run-wire wire posn steps visited)
    (when (not (empty? wire))
      (let ([cmd (first wire)])
        (let-values ([(posn0 steps0) (move cmd posn steps visited)])
          (run-wire (rest wire) posn0 steps0 visited)))))
  (define (find-solution visited0 visited1)
    (define (soln-loop ks min-steps min-dist)
      (if (empty? ks)
          (values min-dist  min-steps)
          (let ([k (first ks)])
            (if (dict-has-key? visited1 k)
                (let ([steps (+ (dict-ref visited0 k) (dict-ref visited1 k))]
                      [dist (+ (abs (first k)) (abs (second k)))])
                  (soln-loop (rest ks) (min min-steps steps) (min min-dist dist)))
                (soln-loop (rest ks) min-steps min-dist)))))
    (soln-loop (dict-keys visited0) 9999999999 9999999999))
  (run-wire wire0 (list 0 0) 0 visited0)
  (run-wire wire1 (list 0 0) 0 visited1)
  (find-solution visited0 visited1))

(module+ main
(require racket/file)
(define wires (map (λ (x) (string-split (string-trim x) ",")) (file->lines "../input.txt")))
  (let-values ([(part1-soln part2-soln) (solve wires)])
    (printf "The solution to part 1 is ~a.~n" part1-soln)
    (printf "The solution to part 2 is ~a.~n" part2-soln)))