#lang racket/base

(require "lib/dir.rkt")
(require "lib/dotfile.rkt")
(require "lib/git.rkt")
(require "lib/pacman.rkt")

(provide mods)

(define mods
  (list
   (dir "doom.d" "~/.doom.d")
   (dir "i3" "~/.config/i3")
   (dir "i3status" "~/.config/i3status")
   (dotfile ".bashrc")
   (dotfile ".bash_profile")
   (pacman "vim")
   (pacman "emacs")
   (pacman "python-pipenv")))

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
