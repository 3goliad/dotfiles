; -*-scheme-*-
#lang racket/base

(require racket/class)
(require racket/list)

(provide config% updates-show updates-apply)

(define (dummy) #f)

(define config%
  (class object%
         (super-new)
         (init-field name 
                     [depends '()])
         (define/public (pending-updates) '())
         (define/public (installed?) #t)
         (define/public (verified?) #t)
         (define/public (install) #f)
         (define/public (update) #f)
         (define/public (uninstall) #f)
         (define/public (needs-update?)
           (not (null? (pending-updates))))
         (define/public (run)
           (if (installed?)
               (begin
                (unless (verified?)
                        (uninstall)
                        (install))
                (when (needs-update?)
                      (update)))
               (install))
           #f)))

(define (updates-show configs)
  (append-map (lambda (c) (send c pending-updates)) configs))

(define (updates-apply configs)
  (error "apply is not implemented"))
