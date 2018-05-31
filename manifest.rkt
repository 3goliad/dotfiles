#lang racket/base

(require "lib/dir.rkt")
(require "lib/dotfile.rkt")
(require "lib/git.rkt")
(require "lib/pacman.rkt")
(require "lib/user.rkt")

(provide mods)

(define (symbol->pacman sym)
  (pacman (symbol->string sym)))
(define packages
  (map symbol->pacman
       '(vim
         dmenu
         rtorrent
         htop
         scrot
         emacs
         otf-overpass
         ttf-croscore
         xdg-user-dirs
         fzf
         zsh
         stack
         rustup
         tokei
         jq
         konsole
         ripgrep
         zip
         unzip
         python-boto3
         python-pipenv)))

(define mods
  (append
   packages
   (list
    (user "jam")
    (dir "doom.d" "~/.doom.d")
    (dir "i3" "~/.config/i3")
    (dir "i3status" "~/.config/i3status")
    (dir "git" "~/.config/git")
    (dotfile "gitconfig")
    (dotfile "bashrc")
    (dotfile "bash_profile")
    (dotfile "dircolors.ansi-universal")
    (dotfile "user-dirs.dirs" "~/.config/user-dirs.dirs"))))

;; (git-repo "doom-emacs"
;;              "https://github.com/hlissner/doom-emacs"
;;              "~/.emacs.d"
;;              #:update '("make upgrade" "make update")
;;              #:install "make install"
;;              #:post-change "make compile")

