; -*-scheme-*-
#lang racket/base

(require racket/class)
(require racket/list)

(provide config% run)

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

(define (run mods #:dry-run [dry-run #f])
  (error "run is not implemented"))
