                                        ; -*-scheme-*-
#lang racket/base

(require racket/class)
(require "config.rkt")

(provide dir)

(define dir%
  (class config%
         (init location)
         (super-new)
         (inherit-field name)
         (define to location)
         (define from (string-append "~/c/" name))
         (define/override (installed?)
           (directory-exists? to))
         (define/override (verified?)
           (= (file-or-directory-identity from)
              (file-or-directory-identity to)))
         (define/override (install)
           (make-file-or-directory-link from to))
         (define/override (uninstall)
           (delete-directory to))))

(define (dir name location)
  (make-object dir% name location))
