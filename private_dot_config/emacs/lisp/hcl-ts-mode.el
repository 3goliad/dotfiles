;;; hcl-ts-mode.el --- tree-sitter support for HCL  -*- lexical-binding: t; -*-

;;; Commentary:
;;

;;; Code:

(require 'treesit)

;; (declare-function treesit-parser-create "treesit.c")

(add-to-list
 'treesit-language-source-alist
 '(hcl "https://github.com/tree-sitter-grammars/tree-sitter-hcl"
       :revision "v1.2.0")
 t)

(defcustom hcl-ts-indent-offset 2
  "Number of spaces for each indentation step in `hcl-ts-mode'."
  :type 'natnum
  :safe 'nanump
  :group 'hcl)

(defvar hcl-ts--syntax-table
  (let ((table (make-syntax-table)))
    ;; Identifiers
    (modify-syntax-entry ?_ "_" table)
    (modify-syntax-entry ?- "_" table)

    ;; Comments
    (modify-syntax-entry ?# "< b" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23" table)

    ;; Strings
    (modify-syntax-entry ?\" "\"")
    (modify-syntax-entry ?\' "\"")
    (modify-syntax-entry ?\\ "\\") ; escape

    ;; Punctuation
    (modify-syntax-entry ?= "." table)
    table)
  "Syntax table for `hcl-ts-mode'")

(defvar hcl-ts-mode--indent-rules
  `((hcl
     ((node-is "block_end") parent-bol 0)
     ((node-is "object_end") parent-bol 0)
     ((node-is ")") parent-bol 0)
     ((node-is "tuple_end") parent-bol 0)
     ((node-is "function_call") parent-bol hcl-ts-indent-offset)
     ((node-is "object") parent-bol hcl-ts-indent-offset)
     ((node-is "tuple") parent-bol hcl-ts-indent-offset)
     ((node-is "block") parent-bol hcl-ts-indent-offset)))
  "Indent rules for `hcl-ts-mode'")

(defvar hcl-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :default-language 'hcl
   :feature 'comment
   '((comment) @font-lock-comment-face)

   ;; :feature 'definition
   ;; '((identifier) @font-lock-variable-name-face)

   :feature 'string
   '((string_lit) @font-lock-string-face)

   :feature 'constant
   '(([(bool_lit) (null_lit)]) @font-lock-constant-face)

   :feature 'number
   '((numeric_lit) @font-lock-number-face)

   :feature 'delimiter
   '((["="]) @font-lock-delimiter-face)

   :feature 'bracket
   '(([(block_start)
       (block_end)
       (object_start)
       (object_end)
       (tuple_start)
       (tuple_end)])
     @font-lock-bracket-face)

   ;; :feature 'attribute
   ;; '((attribute) @font-lock-property-name-face)

   :feature 'funcall
   '((function_call) @font-lock-function-call-face)

   ;; :language 'toml
   ;; :feature 'pair
   ;; :override t            ; Needed for overriding string face on keys.
   ;; '((bare_key) @font-lock-property-use-face
   ;;   (quoted_key) @font-lock-property-use-face
   ;;   (table ("[" @font-lock-bracket-face
   ;;           (_) @font-lock-type-face
   ;;           "]" @font-lock-bracket-face))
   ;;   (table_array_element ("[[" @font-lock-bracket-face
   ;;                         (_) @font-lock-type-face
   ;;                         "]]" @font-lock-bracket-face))
   ;;   (table (quoted_key) @font-lock-type-face)
   ;;   (table (dotted_key (quoted_key)) @font-lock-type-face))

   :feature 'error
   :override t
   '((ERROR) @font-lock-warning-face))
  "Font-lock settings for HCL.")

;;    • Level 1: highlight function declarations, file directives (such as
;;      include or import directives), strings and comments.  The idea is
;;      speed, so only the most important and top-level components are
;;      fontified.
;;
;;    • Level 2: in addition to level 1, highlight all language keywords,
;;      including type names that act like keywords, as well as named
;;      constant values.  The idea is that all keywords (either syntactic
;;      or semantic) should be fontified appropriately.
;;
;;    • Level 3: in addition to level 2, highlight the symbols being
;;      defined in function and variable declarations, and all builtin
;;      function names, wherever they appear.
;; level 1
;; comment definition
;; level 2
;; keyword string type
;; level 3
;; assignment constant number
;; level 4
;; builtin string-interpolation doc operator property preprocessor escape-sequence key
(defvar hcl-ts-mode--font-lock-feature-list
  '((comment) ; definition
    (string)
    (constant number)
    (delimiter bracket funcall error)) ; attribute
  "Font-lock feature list for HCL.")

(define-derived-mode hcl-ts-mode prog-mode "HCL"
  "Generic major mode for editing HashiCorp Configuration Language files.

This is a generic major mode intended to be inherited by tool-specific
implementations. The only implementation currently provided is `opentofu-mode'."
  :group 'hcl-ts
  :syntax-table hcl-ts--syntax-table
  (when (and (treesit-ensure-installed 'hcl)
             (treesit-ready-p 'hcl))
    (setq treesit-primary-parser (treesit-parser-create 'hcl))

    ;; Comments
    ;; TODO: Investigate whether these are useful
    (setq-local comment-start "#")
    (setq-local comment-use-syntax t)
    (setq-local comment-start-skip "\\(//+\\|/\\*+\\)\\s *")

    ;; Indent
    (setq-local treesit-simple-indent-rules hcl-ts-mode--indent-rules)

    ;; (setq-local electric-indent-chars (append "{}[]" electric-indent-chars))

    ;; Font-lock
    (setq-local treesit-font-lock-settings hcl-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list hcl-ts-mode--font-lock-feature-list)

    (treesit-major-mode-setup)))


(add-to-list 'auto-mode-alist '("\\.hcl\\'" . hcl-mode))
