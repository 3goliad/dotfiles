#lang racket/base

(require racket/class)
(require "config.rkt")

(provide dotfile)

(define dotfile%
  (class config%
    (init location)
    (super-new)
    (inherit-field name)
    (define to (expand-user-path location))
    (define from (expand-user-path
                  (string-append "~/c/" name)))
    (define/override (installed?)
      (and (file-exists? to)
           (= (file-or-directory-identity from)
              (file-or-directory-identity to))))
    (define/override (install)
      (make-file-or-directory-link from to)
      (displayln (string-append
                  "successfully installed " name " to "
                  (path->string to))))
    (define/override (dirty?)
      (or (file-exists? to)
          (link-exists? to)
          (directory-exists? to)))
    (define/override (uninstall)
      (cond
        [(or (file-exists? to) (link-exists? to))
         (delete-file to)]
        [(directory-exists? to)
         (delete-directory to)]))))

(define (dotfile name [location null])
  (new dotfile%
       [name name]
       [location (if (null? location)
                     (string-append "~/." name)
                     location)]))
