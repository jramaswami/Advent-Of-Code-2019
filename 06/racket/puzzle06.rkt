;; Advent of Code 2019 :: Day 6 :: Universal Orbit Map
;; https://adventofcode.com/2019/day/6

#lang racket

(require graph)
(require racket/file)

(define (read-orbits-graph path)
  (let ([orbit-specs (file->lines path)]
        [g (unweighted-graph/undirected '())])
    (for ([spec orbit-specs])
      (let* ([tokens (string-split spec ")")]
             [node-u (first tokens)]
             [node-v (second tokens)])
        (add-edge! g node-u node-v)))
    g))

(define (solve-1 g)
  (let-values ([(dists preds) (bfs g "COM")])
    (for/sum ([d (hash-values dists)])
      d)))

(define (solve-2 g)
  (let-values ([(dists preds) (bfs g "YOU")])
    (- (hash-ref dists "SAN") 2)))

(module+ main
  (let ([g (read-orbits-graph "../input.txt")])
    (printf "The solution to part 1 is ~a.~n" (solve-1 g))
    (printf "The solution to part 2 is ~a.~n" (solve-2 g))))