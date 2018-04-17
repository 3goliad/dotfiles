                                        ; -*-scheme-*-
#lang racket/base

(require rackunit racket/class "../lib/pacman.rkt")

(define mod (pacman "redis"))

(test-case
 "detects whether the package is installed"
 (check-false (send d installed?)))
