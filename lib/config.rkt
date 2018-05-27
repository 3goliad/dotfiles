#lang racket/base

(require racket/class)
(require racket/list)

(provide config% run)

(define config%
  (class object%
         (super-new)
         (init-field name
                     [depends '()])
         (define/public (display-name)
           name)
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
  (define (run-mod mod)
    (define name (send mod display-name))
    (unless (send mod installed?)
            (displayln (string-append name " needs to be installed")))
    (when (send mod needs-update?)
          (displayln (string-append name " needs to update")))
    (unless dry-run (send mod run)))
  (for-each run-mod mods))
