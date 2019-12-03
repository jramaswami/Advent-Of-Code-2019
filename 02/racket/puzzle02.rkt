;; Advent of Code 2019 :: Day 2 :: 1202 Program Alarm
;; https://adventofcode.com/2019/day/2

#lang racket

(define (run intcode-list noun verb)
  (define intcode-vector (list->vector intcode-list))
  (define (get-value-at index) (vector-ref intcode-vector index))
  (define (dereference index) (get-value-at (get-value-at index)))
  (define (set-value-at index value) (vector-set! intcode-vector index value))
  (define (add ip)
    (set-value-at (get-value-at (+ ip 3))
                  (+ (dereference (+ ip 1)) (dereference (+ ip 2))))
    (+ ip 4))
  (define (mul ip)
    (set-value-at (get-value-at (+ ip 3))
                  (* (dereference (+ ip 1)) (dereference (+ ip 2))))
    (+ ip 4))
  (define (run-loop ip) 
    (let ([op (get-value-at ip)])
      (cond [(= op 99) (get-value-at 0)]
            [(= op 1) (run-loop (add ip))]
            [(= op 2) (run-loop (mul ip))])))
                        
  (set-value-at 1 noun)
  (set-value-at 2 verb)
  (run-loop 0))

(define (run-as-is intcode-list)
  (let  ([noun (second intcode-list)]
         [verb (third intcode-list)])
    (run intcode-list noun verb)))

(define (string->intcode-list s)
  (map string->number (string-split (string-trim s) ",")))

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
  (check-equal? (run-as-is (string->intcode-list "1,9,10,3,2,3,11,0,99,30,40,50")) 3500)
  (check-equal? (run-as-is (string->intcode-list "1,1,1,4,99,5,6,0,99")) 30))

(module+ main
  (require racket/file)
  (define intcode-list (string->intcode-list (file->string "../input.txt")))
  (printf "The solution to part 1 is ~a.~n" (run intcode-list 12 2))
  (printf "The solution to part 2 is ~a.~n" (solve-part-2 intcode-list)))
