;;; taskspaces.el --- Work tasks with isolated editor state -*- lexical-binding: t; -*-

;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience, outlines, vc
;; Version: 0.1

;;; Commentary:

;; File-per-task Org records under `taskspaces-task-directory', plus zero or one
;; globally active task.  Each task owns its worktrees, terminals, and
;; window layout; other tasks' buffers stay alive but hidden from buffer
;; switching.  Org is loaded only when a command needs it.

;;; Code:

(require 'project)
(require 'seq)
(require 'subr-x)

(require 'org)
(require 'org-agenda)
(require 'org-capture)
(require 'org-id)

(defvar consult-buffer-list-function)
(defvar ghostel--process)

(declare-function ghostel-create "ghostel")
(declare-function org-clocking-p "org")
(declare-function org-clock-out "org")
(declare-function org-clock-in "org")

(defgroup taskspaces nil
  "Work tasks with their own records, buffers, and worktrees."
  :group 'convenience)

(defvar taskspaces-active nil
  "Issue identifier of the active task, or nil.")

(defvar taskspaces--layouts (make-hash-table :test #'equal)
  "Window configurations keyed by issue, or by nil when no task is active.")

(defcustom taskspaces-worktree-directory (expand-file-name "~/Work/worktrees/")
  "Directory containing one subdirectory of worktrees per task."
  :type 'directory)
(defcustom taskspaces-checkout-directory (expand-file-name "~/Work/")
  "Directory whose layout task worktree paths mirror."
  :type 'directory)
(defcustom taskspaces-remote "origin"
  "Remote whose default branch new task branches start from."
  :type 'string)
(defcustom taskspaces-application-modes
  '(ghostel-mode eshell-mode shell-mode term-mode compilation-mode)
  "Modes whose non-file buffers belong to the task active when they start."
  :type '(repeat symbol))

;;;; Task records

(defcustom taskspaces-task-directory (expand-file-name "~/Work/org/")
  "Directory containing active task files, with completed files in archive/."
  :type 'directory)

(defun taskspaces--ensure-task-directory ()
  (make-directory taskspaces-task-directory t)
  (add-to-list 'org-agenda-files taskspaces-task-directory t))

(when (file-directory-p taskspaces-task-directory)
  (add-to-list 'org-agenda-files taskspaces-task-directory t))

(defun taskspaces--required-task-value (value label)
  (setq value (string-trim value))
  (when (or (string-empty-p value) (string-match-p "[\n\r]" value))
    (user-error "%s must be a nonempty single line" label))
  value)

(defun taskspaces--save-task ()
  ;; Org normally inserts timestamp logs after the command has returned.
  (when (and (eq org-log-note-how 'time)
             (memq #'org-add-log-note post-command-hook))
    (org-add-log-note))
  (save-buffer))

(defun taskspaces--goto-task-root ()
  (unless (and (derived-mode-p 'org-mode)
               buffer-file-name
               (file-equal-p (file-name-directory buffer-file-name)
                             taskspaces-task-directory))
    (user-error "Open a task file in %s first" taskspaces-task-directory))
  (goto-char (point-min))
  (unless (and (re-search-forward org-heading-regexp nil t)
               (= (org-outline-level) 1)
               (org-entry-get nil "ISSUE")
               (org-get-todo-state))
    (user-error "Expected a top-level task heading with an ISSUE property"))
  (org-back-to-heading t))

(defun taskspaces--capture-template ()
  (let* ((issue (taskspaces--required-task-value (read-string "Issue identifier: ")
                                     "Issue identifier"))
         (file (expand-file-name (concat issue ".org") taskspaces-task-directory))
         (buffer (get-file-buffer file)))
    (unless (string-match-p "\\`[[:alnum:]][[:alnum:]_-]*\\'" issue)
      (user-error "Issue identifier may contain only letters, numbers, - and _"))
    (when (or (file-exists-p file)
              (and buffer
                   (with-current-buffer buffer
                     (or (buffer-modified-p) (> (buffer-size) 0)))))
      (user-error "Task already exists: %s" file))
    (taskspaces--ensure-task-directory)
    (org-capture-put :taskspaces-task-file file)
    (concat "#+title: " issue " %^{Task title}\n#+filetags: :work:\n\n"
            "* TODO %\\1\n:PROPERTIES:\n:ID: %(org-id-new)\n:ISSUE: "
            issue "\n:END:\n\n"
            "** Resources\n- Issue: %^{Issue URL (optional)}\n\n"
            "** Notes\n")))

(defun taskspaces--capture-target ()
  (or (org-capture-get :taskspaces-task-file)
      (user-error "Work task capture has no target file")))

(defun taskspaces--prepare-capture-finalize ()
  (if org-note-abort
      ;; Capture otherwise saves even an aborted, empty target file.
      (setq org-capture-current-plist
            (plist-put org-capture-current-plist :no-save t))
    (with-current-buffer (org-capture-get :buffer t)
      (save-excursion
        (save-restriction
          (widen)
          (taskspaces--goto-task-root)
          (taskspaces--required-task-value (org-get-heading t t t t) "Task title")
          (org-id-add-location (org-id-get-create) buffer-file-name))))))

(with-eval-after-load 'org-capture
  (add-to-list
   'org-capture-templates
   '("w" "Work task" plain
     (file taskspaces--capture-target)
     (function taskspaces--capture-template)
     :unnarrowed t
     :jump-to-captured t
     :prepare-finalize taskspaces--prepare-capture-finalize)))

;;;###autoload
(defun taskspaces-new-task ()
  "Capture a new task; finalize with C-c C-c or abort with C-c C-k."
  (interactive)
  (org-capture nil "w"))

(defun taskspaces--read-task-file (prompt &optional exclude)
  "Read an unarchived task file name with PROMPT, omitting file EXCLUDE."
  (let ((files (when (file-directory-p taskspaces-task-directory)
                 (directory-files taskspaces-task-directory nil "\\.org\\'"))))
    (when exclude
      (setq files (delete (file-name-nondirectory exclude) files)))
    (unless files
      (user-error (if exclude "No other task files"
                    "No task files yet; use M-x taskspaces-new-task")))
    (expand-file-name (completing-read prompt files nil t)
                      taskspaces-task-directory)))

(defun taskspaces--visit-task (file)
  "Visit task FILE and show the task heading."
  (find-file file)
  (widen)
  (taskspaces--goto-task-root)
  (org-fold-show-context)
  (org-fold-show-subtree))

(defun taskspaces--task-title ()
  "Return the current task's heading title."
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--goto-task-root)
      (org-get-heading t t t t))))

(defun taskspaces--add-task-resource (text)
  "Append TEXT as a list item to the current task's Resources and save."
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--goto-task-root)
      (let ((end (save-excursion (org-end-of-subtree t t))))
        (unless (re-search-forward "^\\*\\* Resources[ \t]*$" end t)
          (user-error "Task has no Resources section")))
      (org-end-of-subtree t)
      (insert "\n- " text)
      (save-buffer))))

;;;###autoload
(defun taskspaces-show-task ()
  "Open the active task buffer and show the task heading."
  (interactive)
  (taskspaces--visit-task
   (taskspaces--task-file (taskspaces--require-active))))

;;;###autoload
(defun taskspaces-block-task ()
  "Mark the current task WAIT and optionally record a BLOCKER property."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--goto-task-root)
      (when (org-clocking-p)
        (org-clock-out nil t))
      (org-todo "WAIT")
      (let ((blocker (read-string "Blocker (optional): "
                                  (org-entry-get nil "BLOCKER"))))
        (let ((blocker (string-trim blocker)))
          (if (string-empty-p blocker)
              (org-entry-delete nil "BLOCKER")
            (org-entry-put nil "BLOCKER" blocker))))
      (taskspaces--save-task)
      (let ((issue (org-entry-get nil "ISSUE")))
        (when (equal taskspaces-active issue)
          (taskspaces--activate nil))))))

;;;###autoload
(defun taskspaces-unblock-task ()
  "Clear a task's BLOCKER and return it to TODO."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--goto-task-root)
      (org-entry-delete nil "BLOCKER")
      (org-todo "TODO")
      (taskspaces--save-task)
      (let ((issue (org-entry-get nil "ISSUE")))
        (when (equal taskspaces-active issue)
          (org-todo "ACTIVE")
          (taskspaces--save-task)
          (org-clock-in nil))))))

;;;###autoload
(defun taskspaces-finish-task ()
  "Mark the current task done and save it without archiving its file."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--goto-task-root)
      (when (org-clocking-p)
        (org-clock-out nil t))
      (org-todo "DONE")
      (org-entry-delete nil "BLOCKER")
      (taskspaces--save-task)))
  (message "Task done; use M-x taskspaces-archive-task when ready to archive"))

;;;###autoload
(defun taskspaces-archive-task ()
  "Move a completed task file into archive and destroy its taskspace."
  (interactive)
  (save-restriction
    (widen)
    (taskspaces--goto-task-root)
    (unless (org-entry-is-done-p)
      (user-error "Finish the task before archiving it"))
    (let* ((directory (expand-file-name "archive/" taskspaces-task-directory))
           (file (expand-file-name (file-name-nondirectory buffer-file-name)
                                   directory))
           (id (org-entry-get nil "ID"))
           (issue (org-entry-get nil "ISSUE")))
      (when (or (file-exists-p file) (get-file-buffer file))
        (user-error "Archived task already exists: %s" file))
      (when (y-or-n-p "Archive this completed task file and destroy its taskspace? ")
        (taskspaces--save-task)
        (make-directory directory t)
        (rename-file buffer-file-name file)
        (set-visited-file-name file nil t)
        (save-buffer)
        (when id (org-id-add-location id file))
        (when issue
          (let ((task-directory (taskspaces--task-directory issue)))
            (when (file-directory-p task-directory)
              (dolist (git-marker (directory-files-recursively
                                   task-directory "\\`\\.git\\'" t))
                (let ((worktree
                       (if (file-directory-p git-marker)
                           (file-name-directory
                            (directory-file-name git-marker))
                         (file-name-directory git-marker))))
                  (ignore-errors
                    (taskspaces--git-run
                     (expand-file-name taskspaces-checkout-directory)
                     (list "worktree" "remove" "--force"
                           (directory-file-name worktree))))))
              (delete-directory task-directory t))
            (dolist (buffer (buffer-list))
              (when (equal (taskspaces--buffer-owner buffer) issue)
                (kill-buffer buffer)))
            (remhash issue taskspaces--layouts)
            (when (equal taskspaces-active issue)
              (setq taskspaces-active nil)
              (taskspaces--activate nil))))
        (message "Archived task to %s" file)))))

(with-eval-after-load 'org-agenda
  (add-to-list
   'org-agenda-custom-commands
   '("W" "Work tasks"
     ((todo "ACTIVE" ((org-agenda-overriding-header "Active")))
      (todo "TODO" ((org-agenda-overriding-header "Ready to begin")))
      (todo "WAIT" ((org-agenda-overriding-header "Waiting"))))
     ((org-agenda-files (list taskspaces-task-directory))))))

;;;###autoload
(defun taskspaces-agenda ()
  "Show task states without personal agenda entries."
  (interactive)
  (taskspaces--ensure-task-directory)
  (org-agenda nil "W"))

;;;; Taskspaces

(defvar-local taskspaces--owner nil
  "Issue owning this buffer, :shared, or nil to decide by directory.")
(put 'taskspaces--owner 'permanent-local t)

(defvar-local taskspaces--terminal nil
  "Non-nil in terminals created by `taskspaces-terminal'.")
(put 'taskspaces--terminal 'permanent-local t)

;;;; Ownership

(defun taskspaces--require-active ()
  (or taskspaces-active (user-error "No active task; use taskspaces-switch-task")))

(defun taskspaces--task-file (issue)
  (expand-file-name (concat issue ".org") taskspaces-task-directory))

(defun taskspaces--task-directory (issue)
  (file-name-as-directory (expand-file-name issue taskspaces-worktree-directory)))

(defun taskspaces--directory-owner (directory)
  (when directory
    (let ((root (expand-file-name taskspaces-worktree-directory))
          (directory (expand-file-name directory)))
      (when (string-prefix-p root directory)
        (car (split-string (substring directory (length root)) "/" t))))))

(defun taskspaces--buffer-owner (buffer)
  "Return the issue owning BUFFER, or nil if it is shared."
  (pcase (buffer-local-value 'taskspaces--owner buffer)
    (:shared nil)
    ('nil (taskspaces--directory-owner
           (or (buffer-local-value 'buffer-file-name buffer)
               (buffer-local-value 'default-directory buffer))))
    (owner owner)))

(defun taskspaces--buffer-visible-p (buffer)
  "Return non-nil if BUFFER is shared or belongs to the active task."
  (let ((owner (taskspaces--buffer-owner buffer)))
    (or (null owner) (equal owner taskspaces-active))))

(defun taskspaces--buffer-list ()
  "Return `buffer-list' without other tasks' buffers."
  (seq-filter #'taskspaces--buffer-visible-p (buffer-list)))

(defun taskspaces--tag-application-buffer ()
  (when (and (not buffer-file-name)
             (derived-mode-p taskspaces-application-modes))
    (setq taskspaces--owner (or taskspaces-active :shared))))

(add-hook 'after-change-major-mode-hook #'taskspaces--tag-application-buffer)

;; `other-buffer', `switch-to-prev-buffer', and buffer killing all honor this.
(modify-all-frames-parameters
 '((buffer-predicate . taskspaces--buffer-visible-p)))

(with-eval-after-load 'consult
  (setq consult-buffer-list-function #'taskspaces--buffer-list))

;;;; Switching

(defun taskspaces--hide-foreign-windows ()
  (dolist (window (window-list nil 'no-minibuf))
    (unless (taskspaces--buffer-visible-p (window-buffer window))
      (switch-to-prev-buffer window)
      (unless (taskspaces--buffer-visible-p (window-buffer window))
        (if (and (window-parameter window 'window-side)
                 (not (eq window (window-main-window))))
            (delete-window window)
          (set-window-buffer window (get-scratch-buffer-create)))))))

(defun taskspaces--fresh-layout (issue)
  (select-window (window-main-window))
  (dolist (window (window-list nil 'no-minibuf))
    (unless (eq window (selected-window))
      (ignore-errors (delete-window window))))
  (let ((directory (taskspaces--task-directory issue)))
    (switch-to-buffer (if (file-directory-p directory)
                          (dired-noselect directory)
                        (get-scratch-buffer-create))
                      nil t))
  (taskspaces--visit-task (taskspaces--task-file issue)))

(defun taskspaces--activate (issue)
  (puthash taskspaces-active (current-window-configuration) taskspaces--layouts)
  (setq taskspaces-active issue)
  (let ((layout (gethash issue taskspaces--layouts)))
    (cond ((and layout (frame-live-p (window-configuration-frame layout)))
           (set-window-configuration layout))
          (issue (taskspaces--fresh-layout issue))))
  (taskspaces--hide-foreign-windows)
  (when issue
    (with-current-buffer (find-file-noselect (taskspaces--task-file issue))
      (taskspaces--goto-task-root)
      (unless (equal (org-get-todo-state) "WAIT")
        (org-todo "ACTIVE")
        (taskspaces--save-task)
        (org-clock-in nil))))
  (force-mode-line-update t))

(defun taskspaces--leave ()
  "Clock out the active task and preserve its taskspace."
  (when-let* ((issue taskspaces-active))
    (let ((file (taskspaces--task-file issue)))
      (if (file-exists-p file)
          (with-current-buffer (find-file-noselect file)
            (taskspaces--goto-task-root)
            (when (org-clocking-p)
              (org-clock-out nil t))
            (cond
             ((y-or-n-p (format "Mark %s blocked? " issue))
              (taskspaces-block-task))
             ((equal (org-get-todo-state) "ACTIVE")
              (org-todo "TODO")
              (taskspaces--save-task))))
        (message "Task file %s no longer exists; not clocking out" file)))
    (save-some-buffers
     nil (lambda () (equal (taskspaces--buffer-owner (current-buffer)) issue)))))

(defun taskspaces--task-summary (issue)
  (with-current-buffer (find-file-noselect (taskspaces--task-file issue))
    (taskspaces--goto-task-root)
    (let ((blocker (org-entry-get nil "BLOCKER"))
          (state (org-get-todo-state)))
      (format "%s [%s]%s" issue state
              (if (and blocker (not (string-empty-p blocker)))
                  (format ": %s" blocker)
                "")))))

;;;###autoload
(defun taskspaces-switch-task ()
  "Switch taskspaces, clocking out and clocking in as needed."
  (interactive)
  (let* ((file (taskspaces--read-task-file
                "Switch to task: "
                (and taskspaces-active (taskspaces--task-file taskspaces-active))))
         (issue (file-name-base file)))
    (with-current-buffer (find-file-noselect file)
      (taskspaces--goto-task-root)
      (when (equal (org-get-todo-state) "WAIT")
        (user-error "%s is blocked; unblock it before switching" issue)))
    (taskspaces--leave)
    (taskspaces--activate issue)
    (message "%s" (taskspaces--task-summary issue))))

;;;###autoload
(defun taskspaces-close-task ()
  "Clock out and return to buffers shared by no task."
  (interactive)
  (taskspaces--require-active)
  (taskspaces--leave)
  (taskspaces--activate nil)
  (message "No active task"))

;;;; Worktrees

(defun taskspaces--git-run (directory args)
  (let ((default-directory directory))
    (with-temp-buffer
      (cons (apply #'process-file "git" nil t nil args)
            (string-trim (buffer-string))))))

(defun taskspaces--git (directory &rest args)
  (pcase-let ((`(,status . ,output) (taskspaces--git-run directory args)))
    (unless (eq status 0)
      (user-error "git %s failed: %s" (string-join args " ") output))
    output))

(defun taskspaces--git-ok-p (directory &rest args)
  (eq 0 (car (taskspaces--git-run directory args))))

(defun taskspaces--remote-default-branch (checkout)
  (let ((remote (cdr (taskspaces--git-run
                      checkout
                      (list "ls-remote" "--symref" taskspaces-remote "HEAD"))))
        (local (taskspaces--git-run
                checkout
                (list "symbolic-ref" "--short"
                      (format "refs/remotes/%s/HEAD" taskspaces-remote)))))
    (cond ((string-match "^ref: refs/heads/\\(.+\\)\tHEAD$" remote)
           (match-string 1 remote))
          ((eq (car local) 0)
           (string-remove-prefix (concat taskspaces-remote "/") (cdr local)))
          (t (user-error "Cannot determine the default branch of %s"
                         taskspaces-remote)))))

(defun taskspaces--slug (title)
  (string-trim (replace-regexp-in-string "[^[:alnum:]]+" "-" (downcase title))
               "-+" "-+"))

(defun taskspaces--default-branch-name (issue)
  (let ((slug (with-current-buffer
                  (find-file-noselect (taskspaces--task-file issue))
                (taskspaces--slug (taskspaces--task-title)))))
    (if (string-empty-p slug) issue (concat issue "-" slug))))

(defun taskspaces--worktree-path (issue checkout)
  (let* ((base (file-name-as-directory
                (expand-file-name taskspaces-checkout-directory)))
         (relative (if (string-prefix-p base checkout)
                       (substring checkout (length base))
                     "")))
    (when (string-empty-p relative)
      (setq relative (file-name-nondirectory (directory-file-name checkout))))
    (file-name-as-directory
     (expand-file-name relative (taskspaces--task-directory issue)))))

(defun taskspaces--create-worktree (issue checkout path)
  (let* ((target (directory-file-name path))
         (branch (string-trim
                  (read-string
                   (format "Create %s on branch: " (abbreviate-file-name target))
                   (taskspaces--default-branch-name issue)))))
    (unless (taskspaces--git-ok-p checkout "check-ref-format" "--branch" branch)
      (user-error "Invalid branch name: %s" branch))
    (make-directory (file-name-directory target) t)
    (if (taskspaces--git-ok-p checkout "show-ref" "--verify" "--quiet"
                             (concat "refs/heads/" branch))
        (if (y-or-n-p (format "Branch %s exists; use it for the worktree? "
                              branch))
            (taskspaces--git checkout "worktree" "add" target branch)
          (user-error "Worktree not created"))
      (let ((base (taskspaces--remote-default-branch checkout)))
        (message "Fetching %s/%s..." taskspaces-remote base)
        (taskspaces--git checkout "fetch" taskspaces-remote base)
        (taskspaces--git checkout "worktree" "add" "--no-track" "-b" branch
                        target (concat taskspaces-remote "/" base))))
    (with-current-buffer (find-file-noselect (taskspaces--task-file issue))
      (taskspaces--add-task-resource
       (format "Worktree: %s (branch %s)" (abbreviate-file-name target) branch)))
    (message "Created worktree %s" (abbreviate-file-name target))))

(defun taskspaces--checkout-roots ()
  (let ((worktrees (expand-file-name taskspaces-worktree-directory)))
    (seq-remove (lambda (root) (string-prefix-p worktrees (expand-file-name root)))
                (project-known-project-roots))))

;;;###autoload
(defun taskspaces-switch-project (checkout)
  "Visit the active task's worktree of CHECKOUT, creating it if needed.
With no active task, visit CHECKOUT itself."
  (interactive
   (list (completing-read
          (if taskspaces-active
              (format "Project for %s: " taskspaces-active)
            "Project: ")
          (mapcar #'abbreviate-file-name (taskspaces--checkout-roots))
          nil t)))
  (let ((checkout (file-name-as-directory (expand-file-name checkout))))
    (project-switch-project
     (if (not taskspaces-active)
         checkout
       (let ((path (taskspaces--worktree-path taskspaces-active checkout)))
         (unless (file-directory-p path)
           (taskspaces--create-worktree taskspaces-active checkout path))
         path)))))

;;;; Terminals and agents

(defconst taskspaces--terminal-display
  '((display-buffer-reuse-window display-buffer-at-bottom)
    (window-height . 0.33)))

(defun taskspaces--terminal-buffer ()
  (seq-find
   (lambda (buffer)
     (and (buffer-local-value 'taskspaces--terminal buffer)
          (equal (taskspaces--buffer-owner buffer) taskspaces-active)
          (process-live-p
           (ignore-errors (buffer-local-value 'ghostel--process buffer)))))
   (buffer-list)))

(defun taskspaces--terminal-directory ()
  (if (not taskspaces-active)
      default-directory
    (let ((project (project-current)))
      (if (and project
               (equal (taskspaces--directory-owner (project-root project))
                      taskspaces-active))
          (project-root project)
        (let ((directory (taskspaces--task-directory taskspaces-active)))
          (make-directory directory t)
          directory)))))

;;;###autoload
(defun taskspaces-terminal (&optional new)
  "Summon or dismiss the active task's terminal, or the shared one.
With prefix argument NEW, create another terminal."
  (interactive "P")
  (let* ((buffer (unless new (taskspaces--terminal-buffer)))
         (window (and buffer (get-buffer-window buffer))))
    (cond
     (window (quit-window nil window))
     (buffer (pop-to-buffer buffer taskspaces--terminal-display))
     (t
      (require 'ghostel)
      (let ((default-directory (taskspaces--terminal-directory)))
        (with-current-buffer
            (ghostel-create (if taskspaces-active
                                (format "*ghostel %s*" taskspaces-active)
                              "*ghostel*")
                            taskspaces--terminal-display)
          (setq taskspaces--terminal t)))))))

;;;; Mode line and keys

(defvar taskspaces-mode-line '(taskspaces-active (" [" taskspaces-active "]")))
(put 'taskspaces-mode-line 'risky-local-variable t)
(add-to-list 'global-mode-string 'taskspaces-mode-line t)

(provide 'taskspaces)
;;; taskspaces.el ends here
