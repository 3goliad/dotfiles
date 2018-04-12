                                        ; -*-scheme-*-
#lang racket/base

(require racket/class)
(require "config.rkt")

(provide pacman)

(define pacman%
  (class config%
         (super-new)))

(define (pacman name)
  (make-object pacman% name))
