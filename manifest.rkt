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
         emacs
         xdg-user-dirs
         fzf
         zsh
         stack
         rustup
         tokei
         konsole
         ripgrep
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
    (dotfile "bashrc")
    (dotfile "bash_profile")
    (dotfile "user-dirs.dirs" "~/.config/user-dirs.dirs"))))

;; (git-repo "doom-emacs"
;;              "https://github.com/hlissner/doom-emacs"
;;              "~/.emacs.d"
;;              #:update '("make upgrade" "make update")
;;              #:install "make install"
;;              #:post-change "make compile")

;;
;; (define runtimes '("guile"))
;;
;; (define required '("glibc-utf8-locales"
;;                    "nss-certs"
;;                    "util-linux"
;;                    "guix"))
;;
;; (define filesystem '("zip"
;;                      "unzip"))
;;
;; (define kubernetes '("minikube"
;;                      "docker-machine-driver-kvm2"
;;                      "kubectl"))
;;
;; (define tools '("jq"))
;;
;; (define security '("tomb"))
;;
;; (define monitor '("htop"))
;;
;; (define develop '("emacs"
;;                   "universal-ctags"))
;;
;; (define fonts '("font-fantasque-sans"
;;                 "font-overpass"
;;                 "font-liberation"
;;                 "font-iosevka"))
;;
;; (define media '("mpv"
;;                 "rtorrent"
;;                 "evince"
;;                 "ghostscript"
;;                 "youtube-dl"))
;;
;; (define gui '("dmenu"
;;               "scrot"))
