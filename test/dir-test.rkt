                                        ; -*-scheme-*-
#lang racket/base
 
(require rackunit 
         racket/class 
         "../lib/dir.rkt")

(test-case
  "symlinks a directory in the config repo to the homedir"
  (define d (dir "test" ".symlink-test"))
  (send d run)
  (check-pred link-exists? "~/c/.symlink-test")
  (check-pred file-exists? "~/c/.symlink-test")
  (check-true (send d installed?))
  (check-true (send d verified?))
  (delete-file "~/c/.symlink-test"))
