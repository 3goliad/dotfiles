;;; -*- lexical-binding: t -*-

(setq user-full-name "Javier Maldonado"
      user-mail-address
      (if (eq system-type 'darwin)
          "javier.maldonado@gartner.com"
        "3goliad@gmail.com"))

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

;; Highlight extraneous whitespace
(global-whitespace-mode)
(setq whitespace-global-modes '(not magit-status-mode))
(setq whitespace-style
      '(face
        trailing
        space-before-tab
        indentation
        empty
        space-after-tab
        missing-newline-at-eof))

(load (expand-file-name "lisp/settings" user-emacs-directory))

;; Display tabs nicely
(setq tab-bar-close-button-show nil
      tab-bar-new-button-show nil
      tab-bar-tab-hints t
      tab-bar-auto-width nil
      tab-bar-separator " "
      tab-bar-format '(tab-bar-format-tabs-groups
                       tab-bar-separator
                       tab-bar-format-add-tab))

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
  :pin melpa-stable
  :config
  (keymap-substitute project-prefix-map #'project-find-regexp #'consult-ripgrep)
  (cl-nsubstitute-if
   '(consult-ripgrep "Find regexp")
   (pcase-lambda (`(,cmd _)) (eq cmd #'project-find-regexp))
   project-switch-commands))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim))
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :defer t)

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
  (org-agenda-files '("inbox.org"))
  :config
  (add-to-list 'org-export-backends 'md)
  (setq org-todo-keywords
        '((sequence "TODO(t)"  "STARTED(s!)" "WAIT(w!)" "|" "DONE(d!)")))
  (setq org-clock-persist 'history)
  (org-clock-persistence-insinuate)
  (setq org-log-into-drawer t))

;; Great Git UI
(use-package magit
  :ensure t
  :pin melpa
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

;; Terminal emulator
(use-package ghostel
  :ensure t
  :config
  (add-hook 'ghostel-mode-hook
            (lambda ()
              (keymap-local-set "C-\\" 'other-window)))
  (when (eq system-type 'darwin)
    (setq ghostel-shell "/opt/homebrew/bin/bash")))

(use-package project
  :ensure nil
  :config
  (setq project-switch-commands 'project-find-file))

(use-package project-tab-groups
  :ensure t
  :hook after-init)

(use-package highlight-quoted
  :ensure t
  :hook
  ((emacs-lisp-mode . highlight-quoted-mode)))

;; GUI Emacs on macOS doesn't inherit the environment from the shell, so
;; we'll launch shells to borrow their environment
(use-package exec-path-from-shell
  :ensure t
  :defer t)

(when (eq system-type 'darwin)
  (require 'exec-path-from-shell)
  (exec-path-from-shell-initialize))

;;;; Eldoc

(use-package eldoc
  :ensure nil
  :init
  (global-eldoc-mode)
  :custom
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-prefer-doc-buffer t)
  (eldoc-documentation-strategy 'eldoc-documentation-compose))

;;;; Theme

(use-package flexoki-themes
  :ensure t
  :config
  (load-theme 'flexoki-themes-dark t))

;;;; Treesitter

(setopt treesit-enabled-modes t)
(setopt treesit-font-lock-level 4)
(setopt treesit-auto-install-grammar 'ask)

;; (use-package treesit-langs
;;   :ensure t)

;;;; Eglot

(setq
 ;; Prevent minibuffer spam
 eglot-report-progress init-file-debug
 ;; Shut down after killing last managed buffer
 eglot-autoshutdown t
 ;; A setting of 0 means Eglot will not block the UI at all, allowing Emacs
 ;; to remain fully responsive, although LSP features will only become
 ;; available once the connection is established in the background.
 eglot-sync-connect 0
 ;; Activate Eglot in cross-referenced non-project files
 eglot-extend-to-xref t
 ;; Let ElDoc keep showing docs, don't mention the code action
 eglot-code-action-indications '(left-fringe margin))

(with-eval-after-load 'eglot
  (setq eglot-autoshutdown t)
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (setq eglot-extend-to-xref t))

;;;; Groovy and Jenkins
(use-package groovy-mode
  :ensure t)
(use-package jenkinsfile-mode
  :ensure t)

;;;; Linting

(use-package flymake
  :ensure nil
  :hook
  (yaml-ts-mode emacs-lisp-mode)
  :custom
  (flymake-wrap-around nil)
  (flymake-mode-line-lighter "Fly")
  ;; (flymake-show-diagnostics-at-end-of-line t)
  :config
  (setq flymake-wrap-around nil))

;;;; Formatting

(use-package apheleia
  :ensure t
  :hook
  ((emacs-lisp-mode . apheleia-mode))
  ;; :config
  ;; (apheleia-global-mode +1)
  )


;;;; Keybinds

(load (expand-file-name "lisp/keybinds" user-emacs-directory))
;; (load (expand-file-name "lisp/meow" user-emacs-directory))
(load (expand-file-name "lisp/evil" user-emacs-directory))

;;;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (remove-hook 'flymake-diagnostic-functions
                         'elisp-flymake-checkdoc t)))

;; ;;;; Python

(setq python-indent-guess-indent-offset-verbose nil)

;; make sure Ty uses uv
(setenv "TY_UV" "1")

;; Use Ty and Ruff via Eglot
(add-hook 'python-base-mode-hook
          (lambda ()
            (eglot-ensure)
            (add-hook 'after-save-hook 'eglot-format nil t)))

;;;; HCL/Terraform
(use-package terraform-ts-mode
  :ensure t
  :defer t
  :vc (:url "https://codeberg.org/ccbash-oss/terraform-ts-mode"
            :rev "7a4e5ab5fa005340af1e41455a7950bc5cd56653")
  :config
  '(terraform . ("https://github.com/tree-sitter-grammars/tree-sitter-hcl"
                 :rev "main"
                 :source-dir "dialects/terraform/src")))


;; config changes made through the customize UI will be stored here
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
(put 'upcase-region 'disabled nil)
