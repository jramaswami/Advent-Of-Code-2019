;; Advent of Code :: Intcode Computer :: Problems 2, 5

#lang racket

(provide run string->intcode-list)

(define (parse-op value)
  (let* ([op (remainder value 100)]
         [parameter (quotient value 100)]
         [C (remainder parameter 10)]
         [B (remainder (quotient parameter 10) 10)]
         [A (remainder (quotient parameter 100) 10)])
    (values op (list C B A))))
  
(define (run intcode-list [noun -1] [verb -1])
  (define intcode-vector (list->vector intcode-list))
  (define (immediate index) (vector-ref intcode-vector index))
  (define (dereference index) (immediate (immediate index)))

  (define (get-value instruction-pointer parameters posn)
    (let ([p (cond [(= posn 1) (first parameters)]
                   [(= posn 2) (second parameters)]
                   [(= posn 3) (third parameters)])]
          [i (+ instruction-pointer posn)])
      (if (= p 0)
          (dereference i)
          (immediate i))))
  
  (define (set-value-at index value) (vector-set! intcode-vector index value))

  ;; Opcode 1 adds together numbers read from two positions and stores the result in a third position.
  (define (add ip params)
    (set-value-at (immediate (+ ip 3))
                  (+ (get-value ip params 1) (get-value ip params 2)))
    (+ ip 4))
  ;; Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them.
  (define (mul ip params)
    (set-value-at (immediate (+ ip 3))
                  (* (get-value ip params 1) (get-value ip params 2)))
    (+ ip 4))

  ;; Opcode 3 takes a single integer as input and saves it to the position given by its only parameter.
  (define (input ip params)
    (printf "Input >> ")
    (let ([inp (string->number (read-line))])
      (set-value-at (immediate (+ ip 1)) inp)
      (+ ip 2)))

  ;; Opcode 4 outputs the value of its only parameter.
  (define (output ip params)
    (printf "Output: ~a~n" (get-value ip params 1))
    (+ ip 2))                          

  ;; Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the instruction
  ;; pointer to the value from the second parameter. Otherwise, it does nothing.
  (define (jump-if-true ip params)
    (let ([lhs (get-value ip params 1)])
      (if (not (= 0 lhs))
          (get-value ip params 2)
          (+ ip 3))))
    
  ;; Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer
  ;; to the value from the second parameter. Otherwise, it does nothing.
  (define (jump-if-false ip params)
    (let ([lhs (get-value ip params 1)])
      (if (= 0 lhs)
          (get-value ip params 2)
          (+ ip 3))))
  
  ;; Opcode 7 is less than: if the first parameter is less than the second parameter, it stores
  ;; 1 in the position given by the third parameter. Otherwise, it stores 0.
  (define (less-than ip params)
    (let ([lhs (get-value ip params 1)]
          [rhs (get-value ip params 2)]
          [dest-index (immediate (+ ip 3))])
      (if (< lhs rhs)
          (set-value-at dest-index 1)
          (set-value-at dest-index 0))
      (+ ip 4)))
  
  ;; Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1
  ;; in the position given by the third parameter. Otherwise, it stores 0.
  (define (equals ip params)
    (let ([lhs (get-value ip params 1)]
          [rhs (get-value ip params 2)]
          [dest-index (immediate (+ ip 3))])
      (if (= lhs rhs)
          (set-value-at dest-index 1)
          (set-value-at dest-index 0))
      (+ ip 4)))

  (define (run-loop ip) 
    (let-values ([(op parameters) (parse-op (immediate ip))])
      ;(printf "~a ~a @ ~a~n" op parameters ip)
      ;(printf "~a~n" intcode-vector)
      (cond [(= op 99) (immediate 0)]
            [(= op 1) (run-loop (add ip parameters))]
            [(= op 2) (run-loop (mul ip parameters))]
            [(= op 3) (run-loop (input ip parameters))]
            [(= op 4) (run-loop (output ip parameters))]
            [(= op 5) (run-loop (jump-if-true ip parameters))]
            [(= op 6) (run-loop (jump-if-false ip parameters))]
            [(= op 7) (run-loop (less-than ip parameters))]
            [(= op 8) (run-loop (equals ip parameters))]
            )))

  (when (>= noun 0)
    (set-value-at 1 noun)
    (set-value-at 2 verb))
  (run-loop 0))

(define (string->intcode-list s)
  (map string->number (string-split (string-trim s) ",")))

(module+ test
  (require rackunit)
  (check-equal? (run (string->intcode-list "1,9,10,3,2,3,11,0,99,30,40,50")) 3500)
  (check-equal? (run (string->intcode-list "1,1,1,4,99,5,6,0,99")) 30))