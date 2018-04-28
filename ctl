#!/usr/bin/env racket
#lang racket/base

(require racket/cmdline)
(require racket/system)

(define refresh? (make-parameter #f))
(define action (make-parameter 'show))

(define mod-filter
  (command-line
   #:once-each
   [("-r" "--refresh")
    "Download the latest configuration files and scripts"
    (refresh? #t)]
   #:once-any
   [("-u" "--update")
    "Install new modules and update existing modules"
    (action 'update)]
   [("-s" "--show")
    "Show changes that will be made by an update"
    (action 'show)]
   [("-l" "--list")
    "List the installed configurations along with their status"
    (action 'list)]
#:args mod-filter
   mod-filter))

(unless (null? mod-filter)
  (displayln
   "Sorry, resource filters aren't supported in this version")
  (exit 1))

(when (refresh?)
  (system "sudo pacman -Sy"))

(require "lib/config.rkt")
(require "manifest.rkt")

(case (action)
  [(list) (display mods)]
  [(show) (run mods #:dry-run #t)]
  [(update) (run mods)])
