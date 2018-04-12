; -*-scheme-*-
#lang racket/base

(require racket/class)
(require "config.rkt")

(provide git-repo)

(define git-repo%
  (class config%
         (init url)
         (init folder)
         (super-new)))

(define (git-repo name 
                  url 
                  folder 
                  #:depends [deps '()]
                  #:update [upd #f]
                  #:install [inst #f]
                  #:post-change [post-ch #f])
  (make-object git-repo% name url folder))
