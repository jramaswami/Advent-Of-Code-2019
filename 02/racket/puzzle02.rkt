;; Advent of Code 2019 :: Day 2 :: 1202 Program Alarm
;; https://adventofcode.com/2019/day/2

#lang racket

(require (file "../../lib/racket/intcode.rkt"))

(define (solve-part-2 intcode-list)
  (define (run-loop noun verb)
    (cond [(= noun 100) -1]
        [(= verb 100) (run-loop (add1 noun) 1)]
        [(= 19690720 (run intcode-list noun verb))
         (+ (* 100 noun) verb)]
        [else (run-loop noun (add1 verb))]))
  (run-loop 1 1))

(module+ test
  (require rackunit)
  (define intcode-list (string->intcode-list (file->string "../input.txt")))
  (check-equal? (run intcode-list 12 2) 2890696)
  (check-equal? (solve-part-2 intcode-list) 8226))

;; Disabled in favor of testing above.
(module+ main0
  (require racket/file)
  (define intcode-list (string->intcode-list (file->string "../input.txt")))
  (printf "The solution to part 1 is ~a.~n" (run intcode-list 12 2))
  (printf "The solution to part 2 is ~a.~n" (solve-part-2 intcode-list)))
