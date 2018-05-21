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


(after! js2-mode
  (setq js-indent-level 2))
