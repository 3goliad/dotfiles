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
         (define to
           (expand-user-path location))
         (define from
           (expand-user-path (string-append "~/c/" name)))
         (define/override (installed?)
           (directory-exists? to))
         (define/override (verified?)
           (and (installed?)
                (= (file-or-directory-identity from)
                   (file-or-directory-identity to))))
         (define/override (install)
           (make-file-or-directory-link from to))
         (define/override (uninstall)
           (cond
            [(or (file-exists? to) (link-exists? to))
             (delete-file to)]
            [(directory-exists? to)
             (delete-directory to)]))))

(define (dir name location)
  (new dir% [name name] [location location]))
