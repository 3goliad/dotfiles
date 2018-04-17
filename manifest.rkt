                                        ; -*-scheme-*-
#lang racket/base

(require "lib/dir.rkt")
(require "lib/git.rkt")
(require "lib/pacman.rkt")

(provide mods)

(define emacs
  (list
   (pacman "emacs")
   (dir "doom.d" "~/.doom.d")
   (git-repo "doom-emacs"
             "https://github.com/hlissner/doom-emacs"
             "~/.emacs.d"
             #:update '("make upgrade" "make update")
             #:install "make install"
             #:post-change "make compile")))

(define mods
  emacs)
