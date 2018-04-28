#lang racket/base

(require racket/class
         racket/system)
(require "config.rkt")

(provide pacman)

(define pacman%
  (class config%
         (super-new)
         (inherit-field name)
         (define/private (pacman-op op #:sudo [sudo #f] #:silent [silent #f])
           (system (string-append (if sudo "sudo " "")
                                  "pacman " op " " name
                                  (if silent " > /dev/null 2>&1" ""))))
         (define/override (installed?)
           (pacman-op "-Q" #:silent #t))
         (define/override (install)
           (pacman-op "-S" #:sudo #t))
         (define/override (uninstall)
           (pacman-op "-Rnss" #:sudo #t))
         (define/override (needs-update?)
           (pacman-op "-Qqu" #:silent #t))
         (define/override (update)
           (install))))

(define (pacman name)
  (make-object pacman% name))
