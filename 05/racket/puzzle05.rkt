;; Advent of Code 2019 :: Day 5 :: Sunny with a Chance of Asteroids
;; https://adventofcode.com/2019/day/5

#lang racket

(require (file "../../lib/racket/intcode.rkt"))

(module+ main
  (require racket/file)
  (printf "    For part 1, enter 1 when asked for input.~n")
  (printf "    Then answer will be the last output value.~n")
  (printf "    Booting ...~n")
  (printf "    Loading code from ../input.txt ...~n")
  (define intcode-list (string->intcode-list (file->string "../input.txt")))
  (printf "    Running code from ../input.txt ...~n")
  (let ([ignore (run intcode-list)])
    (printf "    Done!~n"))
  (printf "    For part 2, enter 5 when asked for input.~n")
  (printf "    Then answer will be the last output value.~n")
  (printf "    Running code from ../input.txt ...~n")
  (let ([ignore (run intcode-list)])
    (printf "    Done!~n")))