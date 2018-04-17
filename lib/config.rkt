; -*-scheme-*-
#lang racket/base

(require racket/class)
(require racket/list)

(provide config% updates-show updates-apply)

(define config%
  (class object%
         (super-new)
         (init-field name
                     [depends '()])
         (define/public (pending-updates) '())
         (define/public (installed?) #t)
         (define/public (install) #f)
         (define/public (update) #f)
         (define/public (uninstall) #f)
         (define/public (needs-update?)
           (not (null? (pending-updates))))
         (define/public (run)
           (if (installed?)
               (when (needs-update?)
                 (update))
               (install)))))

(define (updates-show configs)
  (if (null? configs)
      '("No configurations are registered!")
      (append-map (lambda (c) (send c pending-updates)) configs)))


(define (updates-apply configs)
  (error "apply is not implemented"))
