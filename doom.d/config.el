;;;  -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "Iosevka Term Slab"
                           :size 20))
(setq doom-big-font (font-spec :family "Iosevka Term Slab"
                               :size 32))

(after! hideshow
  (add-to-list 'hs-special-modes-alist
               `(ruby-mode
                 ,(rx (or "def" "class" "module" "do" "{" "[")) ; Block start
                 ,(rx (or "}" "]" "end"))                       ; Block end
                 ,(rx (or "#" "=begin"))                        ; Comment start
                 ruby-forward-sexp nil)))

(after! projectile
  (setq projectile-other-file-alist
        (append projectile-other-file-alist
                '(("ts" . ("spec.ts"))
                  ("spec.ts" . ("ts"))
                  ("js" . ("spec.js"))
                  ("spec.js" . ("js"))
                  ("clj" . ("_test.clj"))
                  ("_test.clj" . ("clj"))))))

(after! js2-mode
  (setq js-indent-level 2)
  (require 'company)
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 3))

(after! ruby-mode
  (require 'company)
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 3)
  (setq-default flycheck-disabled-checkers '(ruby-rubocop ruby-reek ruby-rubylint)))

(after! typescript-mode
  (setq typescript-indent-level 2)
  (require 'company)
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 3))

(after! ws-butler
  (ws-butler-global-mode t))
