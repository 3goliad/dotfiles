;;; -*- lexical-binding: t -*-
;;; Code:

;; A nice completion system
(use-package vertico
  :ensure t
  :pin melpa-stable
  :init
  (vertico-mode))

;;;; Configure emacs for vertico
;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
;; to switch display modes.
(setq context-menu-mode t)
;; Enable recursive minibuffers
(setq enable-recursive-minibuffers t)
;; Hide commands in M-x which do not work in the current mode.  Vertico
;; commands are hidden in normal buffers. This setting is useful beyond
;; Vertico.
(setq read-extended-command-predicate #'command-completion-default-include-p)
;; Do not allow the cursor in the minibuffer prompt
(setq minibuffer-prompt-properties
 '(read-only t cursor-intangible t face minibuffer-prompt))

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
  :bind (
         ("C-x b" . consult-buffer)    ;; orig. switch-to-buffer
         ("M-y" . consult-yank-pop)    ;; orig. yank-pop
         ("M-g g" . consult-goto-line) ;; orig. goto-line
         ;; M-s bindings (search-map)
         ("M-s f" . consult-find)
         ("M-s r" . consult-ripgrep)
         :map help-map
         ("C-i" . consult-info)))
