                                        ; -*-scheme-*-
#lang racket/base
 
(require rackunit racket/class "../lib/config.rkt")

(check-equal? (updates-show '()) '("No configurations are registered!") "Error message for no configs")
