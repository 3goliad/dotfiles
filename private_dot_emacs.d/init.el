;;; -*- lexical-binding: t -*-

;; Always load newest byte code
(setq load-prefer-newer t)

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("melpa-stable" .  "https://stable.melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

(setq use-package-verbose t)
(setq package-install-upgrade-built-in t)

(load (expand-file-name "lisp/settings" user-emacs-directory))

;; Maintain balanced parentheses
(use-package smartparens
  :ensure t
  :hook
  ((prog-mode . smartparens-mode)
   (text-mode . smartparens-mode)
   (markdown-mode . smartparens-mode)
   (emacs-lisp-mode . smartparens-strict-mode))
  :config
  (require 'smartparens-config)
  :bind (:map
         smartparens-mode-map
         ("C-M-f" . sp-forward-sexp)
         ("C-M-b" . sp-backward-sexp)
         ("C-M-t" . sp-transpose-sexp)))

;; A nice completion system
(use-package vertico
  :ensure t
  :pin melpa-stable
  :init
  (vertico-mode))

;; Use the `orderless' completion style.
(use-package orderless
  :ensure t
  :pin melpa-stable
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

;; Rich annotations in the minibuffer (docstrings, file sizes, etc.)
(use-package marginalia
  :ensure t
  :pin melpa-stable
  :init
  (marginalia-mode))

;; Cool completing commands, replacing some default ones
(use-package consult
  :ensure t
  :pin melpa-stable)

;; Code completion
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.25)
  (corfu-auto-trigger ".")
  (corfu-quit-no-match 'separator)
  :init
  (global-corfu-mode)
  :config
  (corfu-popupinfo-mode)
  (corfu-history-mode))

;; Temporary menus, important for Magit
(use-package transient
  :ensure t)

;; Document & Knowledge system
(use-package org
  :ensure t
  :hook ((org-mode . visual-line-mode))
  :custom
  (org-directory "~/Documents/org")
  (org-agenda-files '("inbox.org" "personal.org"))
  :config
  (add-to-list 'org-export-backends 'md))

;; Great Git UI
(use-package magit
  :ensure t
  :pin melpa-stable
  :custom
  (magit-define-global-key-bindings nil)
  :config
  (setq magit-view-git-manual-method 'man))

;; Show VC changes in gutter
(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;; elisp
;; (setopt elisp-fontify-semantically t)

;; (font-lock-add-keywords 'emacs-lisp-mode
;;                         `((,(rx (and (group (or "`" "'" "#'"))
;;                                      (? (* whitespace)
;;                                         (group (+ (or (syntax word)
;;                                                       (syntax symbol))))))))
;;                           (1 'font-lock-keyword-face)
;;                           (2 'font-lock-constant-face nil t))
;;                         :append)

(use-package highlight-quoted
  :ensure t
  :hook
  ((emacs-lisp-mode . highlight-quoted-mode)))

;;;; LSP

(with-eval-after-load 'eglot
  (setq eglot-autoshutdown t)
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (setq eglot-extend-to-xref t))

(load (expand-file-name "lisp/keybinds" user-emacs-directory))
(load (expand-file-name "lisp/meow" user-emacs-directory))

;; config changes made through the customize UI will be stored here
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
