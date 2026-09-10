;;; -*- lexical-binding: t -*-

(setq user-full-name "Javier Maldonado"
      user-mail-address "javier.maldonado@gartner.com")
 
;; always load newest byte code
(setq load-prefer-newer t)


;;;; Projects and files


(recentf-mode)
(savehist-mode)


;;;; UI


;; load a theme
(load-theme 'modus-vivendi)

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

;; accept y/n for prompts
(setq use-short-answers t)

;; line numbers
(dolist (hook '(prog-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

(setopt display-line-numbers-width 3)


;; Modeline


(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)
;; (meow-setup-indicator)
(setopt project-mode-line t)

(setq mode-line-collapse-minor-modes '(which-key-mode eldoc-mode))


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

;; don't wipe system clipboard when killing
(setq save-interprogram-paste-before-kill t)

;; don't save dupes to the kill ring
(setq kill-do-not-save-duplicates t)


;;;; Help and Info


;; ensure which-key-mode is on
(which-key-mode +1)

;; always switch to the help window
(setq help-window-select t)

;; Hide commands in M-x which do not work in the current mode.
(setq read-extended-command-predicate #'command-completion-default-include-p)


;;;; Syntax & Highlighting


;; enable treesitter
(setopt treesit-enabled-modes t)
(setopt treesit-font-lock-level 4)
(setopt treesit-auto-install-grammar 'ask)


;;;; Vertico


;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
;; to switch display modes.
(setq context-menu-mode t)

;; Enable recursive minibuffers
(setq enable-recursive-minibuffers t)


;; Do not allow the cursor in the minibuffer prompt
(setq minibuffer-prompt-properties
 '(read-only t cursor-intangible t face minibuffer-prompt))


;;;; Completion

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;; Disable Ispell completion
(setopt text-mode-ispell-word-completion nil)
