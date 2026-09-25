;;; -*- lexical-binding: t -*-
;;; Code:

(use-package meow-tree-sitter
  :pin melpa
  :ensure t
  :defer t)

(use-package meow
  :pin melpa
  :ensure t
  :config
  (require 'meow-tree-sitter)
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (setq meow-char-thing-table
        '((?\( . round )
          (?\[ . square)
          (?\{ . curly)
          (?\' . string)
          (?\" . string)
          (?. . sentence)
          (?b . buffer)
          (?d . defun)
          (?e . symbol)
          (?l . line)
          (?p . paragraph)
          (?w . window)
          ))

  
  (meow-tree-sitter-register-thing ?/ "comment")
  (meow-tree-sitter-register-thing ?a "class")
  (meow-tree-sitter-register-thing ?f "function")
  (meow-tree-sitter-register-thing ?y "entry")
  (meow-tree-sitter-register-thing ?, "parameter")

  ;; LSP actions
  ;; (define-keymap :name "LSP"
  ;;   :prefix 'meow-lsp-map
  ;;   "a" 'eglot-code-actions
  ;;   )

  ;; 
  ;; going and doing
  (define-keymap :name "Go..."
    :prefix 'meow-go-map
    "t" 'tab-next
    "T" 'tab-previous)

  ;; forward navigations
  (define-keymap :name "Next..."
    :prefix 'meow-navigate-next-map
    "d" 'flymake-goto-next-error)

  ;; backward navigations
  (define-keymap :name "Prev..."
    :prefix 'meow-navigate-prev-map
    "d" 'flymake-goto-prev-error)

  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("{" . meow-navigate-prev-map)
   '("}" . meow-navigate-next-map)
   ;; '("[" . meow-navigate-prev-map)
   ;; '("]" . meow-navigate-next-map)
   ;; '("{" . meow-beginning-of-thing)
   ;; '("}" . meow-end-of-thing)
   '("a" . meow-append)
   ;; '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   ;; '("F" . meow-)
   ;; '("g" . meow-cancel-selection)
   ;; '("G" . meow-grab)
   '("g" . meow-go-map)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   ;; '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   ;; '("o" . meow-block)
   ;; '("O" . meow-to-block)
   '("o" . meow-open-below)
   '("O" . meow-open-above)
   '("p" . meow-yank)
   ;; '("q" . meow-quit)
   '("q" . meow-cancel-selection)
   '("Q" . meow-quit)
   ;; '("r" . meow-replace)
   '("r" . meow-change)
   ;; '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   ;; '("v" . meow-visit)
   '("v" . meow-line)
   '("V" . meow-grab)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   ;; '("x" . meow-line)
   ;; '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '(":" . meow-goto-line)
   '("/" . meow-visit)
   '("<escape>" . ignore))

  (add-to-list 'meow-mode-state-list
               '(ghostel-mode . insert))

  (defun meow-enter-ghostel-semi-char-mode ()
    (goto-char (point-max))
    (ghostel-semi-char-mode))

  (defun ghostel-meow-setup ()
    (add-hook 'meow-normal-mode-hook 'ghostel-emacs-mode nil t)
    (add-hook 'meow-insert-mode-hook 'meow-enter-ghostel-semi-char-mode nil t))

  (with-eval-after-load "ghostel"
    (add-hook 'ghostel-mode-hook 'ghostel-meow-setup))

  (meow-global-mode 1))
