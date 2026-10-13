;;; opentofu-mode.el --- OpenTofu -*- lexical-binding: t; -*-

;;; Commentary:
;;

;;; Code:

;; (require 'hcl-ts-mode)
(require 'eglot)

(define-derived-mode opentofu-mode hcl-ts-mode "OpenTofu"
  "OpenTofu Mode."
  :group 'opentofu)

(add-to-list 'eglot-server-programs
             '(opentofu-mode "tofu-ls" "serve"))

(add-to-list 'auto-mode-alist '("\\.tofu\\(vars\\)?\\'" . opentofu-mode))
