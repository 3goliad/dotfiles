;;; -*- lexical-binding: t -*-
;;; Code:

(use-package transient
  :ensure t)

(use-package magit
  :ensure t
  :pin melpa-stable
  :config
  (setq magit-view-git-manual-method 'man))
