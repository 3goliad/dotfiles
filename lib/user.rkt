#lang racket/base

(require racket/class racket/system)
(require "config.rkt")
(provide user)
(define user%
  (class config%
    (super-new)
    (inherit-field name)
    (define/private (user-exists?)
      (system (string-append
               "passwd -Sa "
               "| awk '{print $1}' "
               "| grep '" name "'")))
    (define/override (installed?)
      (user-exists?))
    (define/override (install)
      (system (string-append "useradd -m "
                             "-G wheel,docker "
                             name))
      (system (string-append "passwd " name)))))

(define (user name)
  (make-object user% name))
