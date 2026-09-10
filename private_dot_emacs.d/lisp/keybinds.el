;;; -*- lexical-binding: t -*-

;;;; Global Keybinds

(defun global-map-p (key fun)
  (eq (keymap-global-lookup key) fun))

(defun keymap-global-unbind (key fun)
  (if (global-map-p key fun)
      (keymap-global-unset key)
    (lwarn 'init.el :error
           "Couldn't unbind %s from %S!"
           key fun)))

(defun keymap-global-rebind (key old-fun new-fun)
  (if (global-map-p key old-fun)
      (keymap-global-set key new-fun)
    (lwarn 'init.el :error
           "Couldn't rebind %s from %S to %S!"
           key old-fun new-fun)))

(keymap-global-unbind "C-x f" 'set-fill-column)
(keymap-global-unbind "C-x ." 'set-fill-prefix)
(keymap-global-unbind "C-x m" 'compose-mail)
(keymap-global-unbind "C-x <" 'scroll-left)
(keymap-global-unbind "C-x >" 'scroll-right)
(keymap-global-unbind "C-x =" 'what-cursor-position)
(keymap-global-unbind "C-x l" 'count-lines-page)
(keymap-global-unbind "C-x C-+" 'text-scale-adjust)
(keymap-global-unbind "C-x C--" 'text-scale-adjust)
(keymap-global-unbind "C-x C-0" 'text-scale-adjust)
(keymap-global-unbind "C-x C-=" 'text-scale-adjust)
(keymap-global-unbind "C-x C-M-+" 'global-text-scale-adjust)
(keymap-global-unbind "C-x C-M--" 'global-text-scale-adjust)
(keymap-global-unbind "C-x C-M-0" 'global-text-scale-adjust)
(keymap-global-unbind "C-x C-M-=" 'global-text-scale-adjust)
(keymap-global-unbind "C-x v" vc-prefix-map)

(keymap-global-rebind "C-x C-b" 'list-buffers 'ibuffer)
(keymap-global-rebind "C-x b" 'switch-to-buffer 'consult-buffer)
(keymap-global-rebind "M-y" 'yank-pop 'consult-yank-pop)

;;;; Replaced Keybinds

(keymap-set help-map "C-i" 'consult-info)

;;;; Leader Keybinds

(keymap-global-set "C-c SPC" 'project-find-file)

;; controlling Git
(define-keymap :name "Git"
  :prefix 'leader-git-map
  "v" 'magit-status
  "f" 'magit-file-dispatch)

(keymap-global-set "C-c v" 'leader-git-map)

;; controlling windows
(define-keymap :name "Window"
  :prefix 'leader-window-map
  "h" 'windmove-left
  "j" 'windmove-down
  "k" 'windmove-up
  "l" 'windmove-right)

(keymap-global-set "C-c w" 'leader-window-map)
