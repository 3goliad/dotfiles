;;; -*- lexical-binding: t -*-

(setq user-full-name "Javier Maldonado"
      user-mail-address "javier.maldonado@gartner.com")
 
;; Always load newest byte code
(setq load-prefer-newer t)

;; define some directories
(defvar config-dir (expand-file-name "lisp" user-emacs-directory)
  "Personal configuration")

;;;; Package setup and utils

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("melpa-stable" .  "https://stable.melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

(setq use-package-verbose t)
(setq package-install-upgrade-built-in t)

(load (expand-file-name "init-modal-editing" config-dir))
(load (expand-file-name "init-completion" config-dir))
(load (expand-file-name "init-magit" config-dir))
(load (expand-file-name "init-prog-mode" config-dir))
(load (expand-file-name "init-lang-yaml" config-dir))

;;;; UI

;; load a theme
(load-theme 'modus-operandi)

;; don't blink the cursor
(blink-cursor-mode -1)

;; silence ringing bell
(setq ring-bell-function 'ignore)

;; no startup screen
(setq inhibit-startup-screen t)

;; improve scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)
(pixel-scroll-precision-mode t)

;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '("Emacs - " (:eval (if (buffer-file-name)
                              (abbreviate-file-name (buffer-file-name))
                            "%b"))))

;; disable BiDi text scanning
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; don't re-highlight until input stops
(setq redisplay-skip-fontification-on-input t)

;; hide cursors and highlights in non-focused windows
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

;; modeline
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)
(meow-setup-indicator)

;; line numbers
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; accept y/n for prompts
(setq use-short-answers t)

;;;; External programs

;; raise default amount read from external processes from 64KB to 4MB
;; helps with big LSP responses
(setq read-process-output-max (* 4 1024 1024)) ; 4MB

;;;; Editing

;; no tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)

;; final newlines
(setq require-final-newline 'ask)

;; delete selection if text is typed
(delete-selection-mode t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;; don't wipe system clipboard when killing
(setq save-interprogram-paste-before-kill t)

;; don't save dupes to the kill ring
(setq kill-do-not-save-duplicates t)

;;;; Keybinds

;; replace default buffer menu
(keymap-global-set "C-x C-b" 'ibuffer)

;;;; Help and Info

;; ensure which-key-mode is on
(which-key-mode +1)

;; always switch to the help window
(setq help-window-select t)

;;;; LSP

(with-eval-after-load 'eglot
  (setq eglot-autoshutdown t)
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (setq eglot-extend-to-xref t))

;;;; Final setup

;; config changes made through the customize UI will be stored here
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
