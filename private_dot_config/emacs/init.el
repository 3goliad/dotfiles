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

;; Don't show the buffer name in the tab, it should be in the modeline
;; (defun tab-bar-tab-name-format-hints (name _tab i)
;;   (if tab-bar-tab-hints
;;       (concat (format "»%d«" i) "")
;;     name))

;; (defun tab-bar-tab-group-format-default (tab _i &optional current-p)
;;   (propertize
;;    (concat (funcall tab-bar-tab-group-function tab))
;;    'face (if current-p 'tab-bar-tab-group-current 'tab-bar-tab-group-inactive)))

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
  (org-agenda-files '("inbox.org"))
  :config
  (add-to-list 'org-export-backends 'md)
  (setq org-todo-keywords
        '((sequence "TODO(t)"  "STARTED(s!)" "|" "DONE(d!)")))
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

(use-package project-tab-groups
  :ensure t
  :hook after-init)

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

;; GUI Emacs on macOS doesn't inherit the environment from the shell, so
;; we'll launch shells to borrow their environment
(use-package exec-path-from-shell
  :ensure t
  :defer t)

(when (eq system-type 'darwin)
  (require 'exec-path-from-shell)
  (exec-path-from-shell-initialize))

(setenv "TY_UV" "1")

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
 ;; Disable margin indicators to prevent line-height shifts caused by emoji
 ;; font rendering issues. This disables both `left-fringe' and `margin'
 ;; indicators.
                                        ; eglot-code-action-indications '(eldoc-hint)
 )

(with-eval-after-load 'eglot
  (setq eglot-autoshutdown t)
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (setq eglot-extend-to-xref t)
  ;; (add-to-list 'eglot-server-programs
  ;;              '('python-base-mode . ("ty" "server")))
  )
;;;; Groovy and Jenkins
(use-package groovy-mode
  :ensure t)
(use-package jenkinsfile-mode
  :ensure t)

;;;; Linting

(use-package flycheck
  :ensure t
  :hook
  ((after-init . global-flycheck-mode)
   (after-init . global-flycheck-annotate-mode)
   ;; (python-ts-mode . flycheck-mode)
   ;; (yaml-ts-mode . flycheck-mode)
   )
  :custom
  (flycheck-annotate-current-line-style 'below)
  (flycheck-annotate-other-lines-style 'eol)
  :config
  (global-flycheck-eglot-mode 1)
  ;; (setq flycheck-python-ruff-executable "ruff")
  )

;; (use-package flymake
;;   :ensure nil
;;   :hook
;;   ((yaml-ts-mode . flymake-mode))
;;   :custom
;;   (flymake-wrap-around nil)
;;   (flymake-mode-line-lighter "Fly")
;;   (flymake-show-diagnostics-at-end-of-line t)
;;   :config
;;   (setq flymake-wrap-around nil))

;;;; Formatting

(use-package apheleia
  :ensure t
  :hook
  ((emacs-lisp-mode . apheleia-mode))
  ;; :config
  ;; (apheleia-global-mode +1)
  ;; (setf (alist-get 'python-mode apheleia-mode-alist) 'ruff)
  ;; (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  )

;;;; Utility functions


;; (defun personal/tab-group-from-project
;;     "Call `tab-group` with the current project name as the group."
;;   (interactive)
;;   (when-let* ((proj (project-current))
;;               (name (file-name-nondirectory
;;                      (directory-file-name (project-root proj)))))
;;     (tab-group (format "[%s]" name))))

;; (defun personal/find-tab-by-group-name (tab-group-name)
;;     "Find the first tab that belongs to a group named TAB-GROUP-NAME"
;;   (seq-find
;;    (lambda (tab) (equal tab-group-name (alist-get 'group tab)))
;;    (funcall tab-bar-tabs-function)))

;; (defun personal/select-or-create-tab-group (tab-group-name)
;;   "Select or create the first tab in a group named TAB_GROUP_NAME.

;; Returns non-nil if a new tab was created, and nil otherwise"
;;   (if-let ((tab (personal/find-tab-by-group-name)))
;;       (progn
;;         (tab-bar-select-tab (1+ tab-bar--ta)))))

;;;; Keybinds

(load (expand-file-name "lisp/keybinds" user-emacs-directory))
;; (load (expand-file-name "lisp/meow" user-emacs-directory))

(use-package evil
  :ensure t
  :init
  (setq evil-want-C-d-scroll nil)
  (setq evil-want-C-w-delete nil)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-shift-width 2)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  :config
  (evil-mode 1)
  ;; (evil-set-leader nil (kbd "SPC"))
  ;; (evil-define-key 'normal 'global (kbd "<leader>"))
  )

(use-package evil-keypad
  :ensure t
  :after (evil)
  :config
  (evil-keypad-global-mode 1))

(use-package evil-collection
  :ensure t
  :after (evil)
  :config
  (evil-collection-init))

;; (use-package evil-collection-magit
;;   :ensure nil
;;   :after (magit evil)
;;   :config
;;   (evil-collection-magit-setup))

;; (use-package evil-ghostel
;;   :ensure t
;;   :after (ghostel evil)
;;   :hook (ghostel-mode . evil-ghostel-mode))

;; ;;;; Python

(setq python-indent-guess-indent-offset-verbose nil)

;; format with Ruff on save
(add-hook 'python-base-mode-hook
          (lambda ()
            (eglot-ensure)
            (add-hook 'after-save-hook 'eglot-format nil t)))

;; config changes made through the customize UI will be stored here
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
(put 'upcase-region 'disabled nil)
