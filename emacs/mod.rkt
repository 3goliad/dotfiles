                                        ; -*-scheme-*-
#lang racket/base

(require "../lib/dir.rkt")
(require "../lib/git.rkt")
(require "../lib/pacman.rkt")

(provide emacs)

(define (emacs)
  (list
   (dir "doom.d" "~/.doom.d")
   (pacman "emacs")
   (git-repo "doom-emacs"
             "https://github.com/hlissner/doom-emacs"
             "~/.emacs.d"
             #:depends '("doom.d")
             #:update '("make upgrade" "make update")
             #:install "make install"
             #:post-change "make compile")))
