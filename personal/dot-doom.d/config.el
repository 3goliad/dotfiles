;;;  -*- lexical-binding: t; -*-

(setq user-full-name "Javier Maldonado"
      user-mail-address "3goliad@gmail.com")

(setq doom-font (font-spec :family "Fantasque Sans Mono"
                           :size 22))

(setq doom-big-font (font-spec :family "Fantasque Sans Mono"
                               :size 32))

(setq org-directory "~/d/notes")
(setq deft-directory org-directory)

;; (after! ruby)
;; (require 'company)
;; (setq company-idle-delay 0.2
;;       company-minimum-prefix-length 3)
;; (setq-default flycheck-disabled-checkers '(ruby-reek ruby-rubylint))


(add-hook! ruby-mode
  (setq ruby-block-indent nil))


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
