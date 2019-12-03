;; Advent of Code 2019 :: Day 1 :: The Tyranny of the Rocket Equation
;; https://adventofcode.com/2019/day/1

#lang racket

(define (fuel-required module-mass)
  (- (floor (/ module-mass 3)) 2))

(define (solve-part-1 modules)
  (apply + (map fuel-required modules)))

(define (fuel-required-2 module-mass)
  (define (fr m acc)
    (let ([f (fuel-required m)])
      (if (<= f 0)
          acc
          (fr f (+ acc f)))))
  (fr module-mass 0))

(define (solve-part-2 modules)
  (apply + (map fuel-required-2 modules)))

(module+ test
  (require rackunit)
  (check-equal? (fuel-required 12) 2)
  (check-equal? (fuel-required 14) 2)
  (check-equal? (fuel-required 1969) 654)
  (check-equal? (fuel-required 100756) 33583)

  (check-equal? (fuel-required-2 14) 2)
  (check-equal? (fuel-required-2 1969) 966)
  (check-equal? (fuel-required-2 100756) 50346))

(module+ main
  (require racket/file)
  (let ([input (map string->number (file->lines "../input.txt"))])
    (printf "The solution to part 1 is ~a.~n" (solve-part-1 input))
    (printf "The solution to part 2 is ~a.~n" (solve-part-2 input))))