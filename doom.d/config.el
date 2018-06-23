;;;  -*- lexical-binding: t; -*-

(if (string= system-name "nuc-if-u-buc")
    (setq doom-font (font-spec :family "Iosevka Term Slab"
                               :size 18))
  (setq doom-font (font-spec :family "Fira Mono"
                             :size 18)))


(if (string= system-name "nuc-if-u-buc")
    (setq doom-big-font (font-spec :family "Iosevka Term Slab"
                                   :size 30))
  (setq doom-big-font (font-spec :family "Fira Mono"
                                 :size 30)))

(after! hideshow
  (add-to-list 'hs-special-modes-alist
               `(ruby-mode
                 ,(rx (or "def" "class" "module" "do" "{" "[")) ; Block start
                 ,(rx (or "}" "]" "end"))                       ; Block end
                 ,(rx (or "#" "=begin"))                        ; Comment start
                 ruby-forward-sexp nil)))

(after! js2-mode
  (setq js-indent-level 2))

(require 'company)
(setq company-idle-delay 0.2
      company-minimum-prefix-length 3)

(after! typescript-mode
  (setq typescript-indent-level 2)
  (setq projectile-other-file-alist
        (append projectile-other-file-alist
                '(("ts" . ("spec.ts"))
                  ("spec.ts" . ("ts"))))))
