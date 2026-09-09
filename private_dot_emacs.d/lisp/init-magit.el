;;; -*- lexical-binding: t -*-
;;; Code:

(use-package transient
  :ensure t)

(use-package magit
  :ensure t
  :pin melpa-stable
  :config
  (setq magit-view-git-manual-method 'man))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))
