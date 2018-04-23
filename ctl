#!/usr/bin/env racket
                                        ; -*-scheme-*-
#lang racket/base

(require racket/cmdline)

(define refresh? (make-parameter #f))
(define action (make-parameter 'show))

(define resource-filter
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
#:args resource-filter
   resource-filter))

(unless (null? resource-filter)
  (displayln
   "Sorry, resource filters aren't supported in this version")
  (exit 1))

(when (refresh?)
  (displayln
   "Sorry, refresh isn't implemented in this version")
  (exit 1))

(require "lib/config.rkt")
(require "manifest.rkt")

(case (action)
  [(list) (display mods)]
  [(show) (dry-run mods)]
  [(update) (run mods)])
