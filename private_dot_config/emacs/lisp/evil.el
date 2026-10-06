;;; -*- lexical-binding: t -*-

(use-package evil
  :ensure t
  :init
  (setq evil-want-C-d-scroll nil)
  (setq evil-want-C-w-delete nil)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-shift-width 2)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  :config
  (evil-mode 1)
  (keymap-unset evil-motion-state-map "C-b")
  (keymap-unset evil-motion-state-map "C-e")
  (keymap-unset evil-motion-state-map "C-f")
  (keymap-unset evil-motion-state-map "C-o")
  (keymap-unset evil-motion-state-map "C-y")
  (keymap-unset evil-normal-state-map "C-.")
  (keymap-unset evil-normal-state-map "M-.")

  ;; (evil-set-leader nil (kbd "SPC"))
  ;; (evil-define-key 'normal 'global (kbd "<leader>"))
  )

(use-package evil-keypad
  :ensure t
  :after (evil)
  :config
  (evil-keypad-global-mode 1))

(use-package evil-collection
  :ensure t
  :after (evil)
  :config
  (delq 'evil-ghostel evil-collection-mode-list)
  (setq evil-collection-binding-overrides
        '((find-usages :state normal :key "grr")
          (find-definition :state normal :key "grd")))
  (evil-collection-init))

;; (use-package evil-collection-magit
;;   :ensure nil
;;   :after (magit evil)
;;   :config
;;   (evil-collection-magit-setup))

(use-package evil-ghostel
  :ensure t
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))
