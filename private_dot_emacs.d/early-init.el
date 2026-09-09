;;; -*- lexical-binding: t -*-
;;;
;;; This file is loaded before the package system and the UI are initialized,
;;; which makes it the right place for a few settings that have to be applied
;;; very early during startup.

;; Raise the garbage collection threshold as high as possible for the duration
;; of startup, so we don't pay for repeated collections while a lot of code is
;; being loaded.  A modest threshold is restored once startup is over (a
;; permanently huge threshold trades frequent short pauses for rare, long
;; freezes).
(setq gc-cons-threshold most-positive-fixnum)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 50 1000 1000) ; 50MB
                  gc-cons-percentage 0.2)))

;; silence unhelpful warnings
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)


;; Disable the tool bar via frame parameters, so the initial frame is never
;; created with one in the first place.  Toggling `tool-bar-mode' later forces
;; an expensive frame resize.
(push '(tool-bar-lines . 0) default-frame-alist)

;; Disable scroll bars in all frames
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)

;; Set initial frame colors here to avoid flashes later
;;
;; The current theme has a white background, so we don't need these
;; (push '(background-color . "#FFFCF0") initial-frame-alist)
;; (push '(foreground-color . "#100F0F") initial-frame-alist)

;; Don't resize the frame in response to font or UI changes during
;; startup. Avoids needless work before the frame is even visible.
(setq frame-inhibit-implied-resize t)

;; Start with a more generously sized frame
(push '(width . 168) initial-frame-alist)
(push '(height . 48) initial-frame-alist)

;; Let frames resize smoothly in sub-char increments
(setq frame-resize-pixelwise t)

;; Native-compile packages when they are installed rather than lazily on first
;; load, so you don't hit compilation pauses while working.
(setq package-native-compile t)

;; GUI Emacs on macOS doesn't inherit the environment from the shell, so
;; without LANG it ends up in the "C" locale, which breaks things like
;; spell-checker dictionaries and subprocess sorting.
(when (and (eq system-type 'darwin) (not (getenv "LANG")))
  (setenv "LANG" "en_US.UTF-8"))
