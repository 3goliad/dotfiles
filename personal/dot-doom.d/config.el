;;;  -*- lexical-binding: t; -*-

(setq user-full-name "Javier Maldonado"
      user-mail-address "3goliad@gmail.com")

(setq doom-font (font-spec :family "Fantasque Sans Mono"
                           :size 22))

(setq doom-big-font (font-spec :family "Fantasque Sans Mono"
                               :size 32))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-palenight)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq org-directory "~/d/notes")

(after! tide
  (setq tide-node-executable
        "/home/jam/.asdf/installs/nodejs/18.19.0/bin/node"))

(after! flycheck
  (advice-add 'flycheck-eslint-config-exists-p :override (lambda() t)))

;; (setq deft-directory org-directory)
;; (add-hook! ruby-mode
;;   (setq ruby-block-indent nil))
;; (after! ruby)
;; (require 'company)
;; (setq company-idle-delay 0.2
;;       company-minimum-prefix-length 3)
;; (setq-default flycheck-disabled-checkers '(ruby-reek ruby-rubylint))

;; (after! rjsx-mode
;;   (setq-default flycheck-disabled-checkers '(jsx-tide)))

;; (setq iedit-toggle-key-default nil)
;; (setq tide-tsserver-process-environment '("TSS_LOG=-level verbose -file /tmp/tss.log"))

;; (after! hideshow
;;   (add-to-list 'hs-special-modes-alist
;;                `(ruby-mode
;;                  ,(rx (or "def" "class" "module" "do" "{" "[")) ; Block start
;;                  ,(rx (or "}" "]" "end"))                       ; Block end
;;                  ,(rx (or "#" "=begin"))                        ; Comment start
;;                  ruby-forward-sexp nil)))

;; (after! js2-mode
;;   (setq js-indent-level 2)
;;   (require 'company)
;;   (setq company-idle-delay 0.2
;;         company-minimum-prefix-length 3))

;; (after! typescript-mode
;;   (setq typescript-indent-level 2)
;;   (require 'company)
;;   (setq company-idle-delay 0.2
;;         company-minimum-prefix-length 3))

;; (after! ws-butler
;;   (ws-butler-global-mode t))
