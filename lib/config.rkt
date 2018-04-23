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
         (define/public (installed?) #t)
         (define/public (install) #f)
         (define/public (update) #f)
         (define/public (uninstall) #f)
         (define/public (dirty?) #f)
         (define/public (needs-update?) #f)
         (define/public (run)
           (if (installed?)
               (when (needs-update?)
                 (update))
               (begin
                 (when (dirty?) (uninstall))
                 (install))))))

(define (updates-show configs)
  (if (null? configs)
      '("No configurations are registered!")
      (append-map (lambda (c) (send c pending-updates)) configs)))


(define (updates-apply configs)
  (error "apply is not implemented"))
