                                        ; -*-scheme-*-
#lang racket/base

(require rackunit racket/class "../lib/pacman.rkt")
(require racket/system)

(define mod (pacman "redis"))


(test-case
 "detects whether the package is installed"
 (system "sudo pacman --noconfirm -R redis")
 (check-false (send mod installed?))
 (system "sudo pacman --noconfirm -S redis")
 (check-true (send mod installed?)))

(system "sudo pacman --noconfirm -R redis")

(test-case
 "installs a package"
 (system "sudo pacman --noconfirm -R redis")
 (send mod install)
 (check-true (system "pacman -Q redis")))

(system "sudo pacman --noconfirm -R redis")

(test-case
 "uninstalls a package"
 (system "sudo pacman --noconfirm -S redis")
 (send mod uninstall)
 (check-false (system "pacman -Q redis")))

(test-case
 "updates a package"
 )
