                                        ; -*-scheme-*-
#lang racket/base

(require rackunit
         racket/class
         "../lib/dir.rkt")

(define d (dir "test" ".symlink-test"))
(define p (expand-user-path  "~/c/.symlink-test"))

(test-case
 "symlinks a directory in the config repo to the homedir"
 (send d run)
 (check-pred link-exists? p)
 (check-true (send d installed?))
 (delete-file p))

(test-case
 "deletes the symlink to the directory when uninstalled"
 (send d run)
 (send d uninstall)
 (check-false (link-exists? p))
 (check-false (send d installed?)))

(test-case
 "never needs to update"
 (check-false (send d needs-update?))
 (send d run)
 (check-false (send d needs-update?))
 (send d uninstall)
 (check-false (send d needs-update?)))

(test-case
 "replaces the symlink if deleted"
 (send d run)
 (delete-file p)
 (check-false (send d installed?))
 (send d run)
 (check-true (send d installed?))
 (delete-file p))

(test-case
 "fixes a mangled symlink"
 (send d run)
 (delete-file p)
 (make-directory p)
 (check-false (send d installed?))
 (send d run)
 (check-true (send d installed?))
 (send d uninstall))
