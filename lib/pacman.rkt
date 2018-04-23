                                        ; -*-scheme-*-
#lang racket/base

(require racket/class
         racket/system)
(require "config.rkt")

(provide pacman)

(define pacman%
  (class config%
         (super-new)
         (inherit-field name)
         (define/private (pacman-op op [sudo #f])
           (system (string-append (if sudo "sudo " "") "pacman " op " " name)))
         (define/override (installed?)
           (pacman-op "-Q"))
         (define/override (install)
           (pacman-op "-S" #t))
         (define/override (uninstall)
           (pacman-op "-Rnss" #t))
         (define/override (needs-update?))
         (define/override (update))))

(define (pacman name)
  (make-object pacman% name))
