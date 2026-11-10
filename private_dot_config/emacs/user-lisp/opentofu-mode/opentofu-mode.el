;;; opentofu-mode.el --- OpenTofu major mode -*- lexical-binding: t; -*-

;; Package-Requires: ((emacs "31.1") (hcl-ts-mode "0.1"))
;; Keywords: languages, terraform, opentofu
;; Version: 0.1

;;; Commentary:

;; Major mode for OpenTofu/Terraform files, derived from `hcl-ts-mode',
;; with `eglot' configured to use tofu-ls.

;;; Code:

(require 'hcl-ts-mode)

(defvar eglot-server-programs)

;;;###autoload
(define-derived-mode opentofu-mode hcl-ts-mode "OpenTofu"
  "OpenTofu Mode."
  :group 'opentofu)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(opentofu-mode "tofu-ls" "serve")))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(tofu\\|tf\\)\\(vars\\)?\\'" . opentofu-mode))

(provide 'opentofu-mode)
;;; opentofu-mode.el ends here
