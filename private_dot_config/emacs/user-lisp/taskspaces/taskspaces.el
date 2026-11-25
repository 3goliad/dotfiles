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

(defconst taskspaces--default-taskspace-directory
  (expand-file-name "~/Work/taskspaces/")
  "The default directory for task workspaces.")
(defcustom taskspaces-taskspace-directory taskspaces--default-taskspace-directory
  "Directory containing one task directory per task."
  :type 'directory)
(defconst taskspaces--default-worktree-directory
  (expand-file-name "~/Work/worktrees/")
  "The former default directory for task worktrees.")
(defcustom taskspaces-worktree-directory taskspaces--default-taskspace-directory
  "Deprecated alias for the former task worktree directory.
When customized, it remains available as a compatibility root."
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
  (let* ((parent-issue (org-capture-get :taskspaces-parent-issue))
         (parent-id (org-capture-get :taskspaces-parent-id))
         (issue (taskspaces--required-task-value (read-string "Issue identifier: ")
                                                "Issue identifier"))
         (file (expand-file-name (concat issue ".org") taskspaces-task-directory))
         (buffer (get-file-buffer file))
         (parent-properties
          (if parent-issue
              (concat "\n:PARENT: " parent-issue
                      (if parent-id
                          (concat "\n:PARENT-ID: " parent-id)
                        ""))
            "")))
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
            issue parent-properties "\n:END:\n\n"
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
          (let ((parent-issue (org-capture-get :taskspaces-parent-issue))
                (parent-id (org-capture-get :taskspaces-parent-id)))
            (when parent-issue
              (org-entry-put nil "PARENT" parent-issue)
              (when parent-id
                (org-entry-put nil "PARENT-ID" parent-id)))
            (org-id-add-location (org-id-get-create) buffer-file-name)
            (when parent-issue
              (taskspaces--refresh-parent-children parent-issue parent-id))))))))

(with-eval-after-load 'org-capture
  (add-to-list
   'org-capture-templates
   '("w" "Work task" plain
     (file taskspaces--capture-target)
     (function taskspaces--capture-template)
     :unnarrowed t
     :jump-to-captured t
     :prepare-finalize taskspaces--prepare-capture-finalize))
  (add-to-list
   'org-capture-templates
   '("c" "Linked child task" plain
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

(defun taskspaces--current-task-reference ()
  "Return the current task issue and Org ID, or prompt for a parent task."
  (save-excursion
    (save-restriction
      (widen)
      (if (and (derived-mode-p 'org-mode)
               buffer-file-name
               (file-equal-p (file-name-directory buffer-file-name)
                             taskspaces-task-directory))
          (progn
            (taskspaces--goto-task-root)
            (cons (org-entry-get nil "ISSUE")
                  (org-entry-get nil "ID")))
        (let* ((file (taskspaces--read-task-file "Add child to task: "))
               (issue (file-name-base file)))
          (with-current-buffer (find-file-noselect file)
            (taskspaces--goto-task-root)
            (cons issue (org-entry-get nil "ID"))))))))

;;;###autoload
(defun taskspaces-new-child-task ()
  "Capture a new task linked to the current or selected parent task."
  (interactive)
  (let* ((parent (taskspaces--current-task-reference))
         (parent-issue (car parent))
         (parent-id (cdr parent)))
    (unless parent-issue
      (user-error "Parent task has no ISSUE property"))
    (org-capture-put :taskspaces-parent-issue parent-issue)
    (when parent-id
      (org-capture-put :taskspaces-parent-id parent-id))
    (org-capture nil "c")))

(defun taskspaces--task-title-from-file (file)
  "Return the top-level task heading title from task Org FILE."
  (with-current-buffer (find-file-noselect file)
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (if (and (re-search-forward org-heading-regexp nil t)
                 (= (org-outline-level) 1))
            (let ((title (string-trim
                          (org-get-heading t t t t))))
              (if (string-empty-p title)
                  (file-name-base file)
                title))
          (file-name-base file))))))

(defun taskspaces--task-record-from-file (file)
  "Return task metadata from Org task FILE."
  (with-current-buffer (find-file-noselect file)
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (if (and (re-search-forward org-heading-regexp nil t)
                 (= (org-outline-level) 1))
            (list :file file
                  :issue (org-entry-get nil "ISSUE")
                  :id (org-entry-get nil "ID")
                  :title (string-trim (org-get-heading t t t t))
                  :state (org-get-todo-state)
                  :parent (org-entry-get nil "PARENT")
                  :parent-id (org-entry-get nil "PARENT-ID"))
          (list :file file
                :issue (file-name-base file)
                :title (file-name-base file)))))))

(defun taskspaces--children-of-task (issue &optional id)
  "Return task records whose PARENT links identify ISSUE or ID."
  (let ((children nil))
    (dolist (filename (when (file-directory-p taskspaces-task-directory)
                        (directory-files taskspaces-task-directory nil "\\.org\\'")))
      (let* ((file (expand-file-name filename taskspaces-task-directory))
             (record (taskspaces--task-record-from-file file))
             (parent (plist-get record :parent))
             (parent-id (plist-get record :parent-id)))
        (when (and (or (and issue (equal parent issue))
                       (and id (equal parent-id id)))
                   (not (equal (plist-get record :issue) issue)))
          (push record children))))
    (sort children
          (lambda (left right)
            (string< (or (plist-get left :issue) "")
                     (or (plist-get right :issue) ""))))))

(defun taskspaces--task-is-parent-p (issue &optional id)
  "Return non-nil if ISSUE or ID has linked child tasks."
  (not (null (taskspaces--children-of-task issue id))))

(defun taskspaces--task-candidate-label (file)
  "Return the switcher label for task FILE."
  (let* ((record (taskspaces--task-record-from-file file))
         (issue (plist-get record :issue))
         (title (plist-get record :title))
         (parent (plist-get record :parent))
         (parent-id (plist-get record :parent-id))
         (id (plist-get record :id))
         (label (format "%s (%s)"
                        (if (and title (not (string-empty-p title)))
                            title
                          issue)
                        issue)))
    (cond
     (parent (format "%s [child of %s]" label parent))
     ((taskspaces--task-is-parent-p issue id)
      (format "%s [parent]" label))
     (t label))))

(defun taskspaces--refresh-parent-children (issue &optional id)
  "Refresh the Children section in parent ISSUE, when it is in the active task directory."
  (let ((file (taskspaces--task-file issue)))
    (when (file-exists-p file)
      (let ((children (taskspaces--children-of-task issue id)))
        (with-current-buffer (find-file-noselect file)
          (save-excursion
            (save-restriction
              (widen)
              (goto-char (point-min))
              (taskspaces--goto-task-root)
              (let* ((root-end (save-excursion (org-end-of-subtree t t)))
                     (section-start
                      (save-excursion
                        (goto-char (point-min))
                        (when (re-search-forward
                               "^\\*\\* Children[ \t]*$" root-end t)
                          (line-beginning-position)))))
                (when section-start
                  (goto-char section-start)
                  (let ((section-end (save-excursion
                                       (org-end-of-subtree t t))))
                    (delete-region section-start section-end)))
                (when children
                  (goto-char (save-excursion
                               (org-end-of-subtree t t)))
                  (insert "\n** Children\n")
                  (dolist (child children)
                    (let* ((child-id (plist-get child :id))
                           (child-issue (plist-get child :issue))
                           (child-title (plist-get child :title))
                           (child-state (plist-get child :state))
                           (link (if child-id
                                     (format "id:%s" child-id)
                                   (format "file:%s"
                                           (plist-get child :file)))))
                      (insert (format "- [[%s][%s %s]] (%s)\n"
                                      link child-issue child-title child-state))))))
              (taskspaces--save-task))))))))

(defun taskspaces--agenda-prefix ()
  "Return a parent or child label for the Org agenda entry at point."
  (let* ((marker (or (get-text-property (point) 'org-hd-marker)
                     (get-text-property (point) 'org-marker)))
         (buffer (and marker (marker-buffer marker))))
    (if (and buffer marker)
        (with-current-buffer buffer
          (save-excursion
            (goto-char marker)
            (let* ((issue (org-entry-get nil "ISSUE"))
                   (id (org-entry-get nil "ID"))
                   (parent (org-entry-get nil "PARENT"))
                   (parent-id (org-entry-get nil "PARENT-ID")))
              (cond
               (parent (format "[child of %s] " parent))
               ((taskspaces--task-is-parent-p issue id) "[parent] ")
               (t "")))))
      "")))

(defun taskspaces--read-task-file (prompt &optional exclude)
  "Read an unarchived task file name with PROMPT, omitting file EXCLUDE."
  (let* ((files (when (file-directory-p taskspaces-task-directory)
                  (directory-files taskspaces-task-directory nil "\\.org\\'")))
         (candidates
          (mapcar
           (lambda (filename)
             (let* ((file (expand-file-name filename taskspaces-task-directory))
                      (issue (file-name-base file)))
                (cons (taskspaces--task-candidate-label file) file)))
           files)))
    (when exclude
      (setq candidates
            (seq-remove
             (lambda (candidate)
               (equal (cdr candidate) exclude))
             candidates)))
    (unless candidates
      (user-error (if exclude "No other task files"
                    "No task files yet; use M-x taskspaces-new-task")))
    (let* ((choice (string-trim (completing-read prompt candidates nil t)))
           (file (or (cdr (assoc choice candidates))
                     (seq-find
                      (lambda (candidate)
                        (equal (file-name-base (cdr candidate)) choice))
                      candidates)
                     (seq-find
                      (lambda (candidate)
                        (equal (cdr candidate)
                               (expand-file-name choice taskspaces-task-directory)))
                      candidates))))
      (when file
        (setq file (if (stringp file) file (cdr file))))
      (or file
          (user-error "Unknown task: %s" choice)))))

(defun taskspaces--visit-task (file)
  "Visit task FILE and show the task heading."
  (find-file file)
  (widen)
  (taskspaces--goto-task-root)
  (let ((issue (org-entry-get nil "ISSUE"))
        (id (org-entry-get nil "ID")))
    (taskspaces--refresh-parent-children issue id))
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
  (if taskspaces-active
      (taskspaces--visit-task
       (taskspaces--task-file taskspaces-active))
    (taskspaces-switch-task)))

(defun taskspaces--unblock-task-file (file)
  "Clear WAIT and BLOCKER on task FILE and return it to TODO."
  (with-current-buffer (find-file-noselect file)
    (taskspaces--goto-task-root)
    (when (equal (org-get-todo-state) "WAIT")
      (org-entry-delete nil "BLOCKER")
      (org-todo "TODO")
      (taskspaces--save-task)
      t)))

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
      (let ((issue (org-entry-get nil "ISSUE"))
            (parent (org-entry-get nil "PARENT"))
            (parent-id (org-entry-get nil "PARENT-ID")))
        (when parent
          (taskspaces--refresh-parent-children parent parent-id))
        (when (equal taskspaces-active issue)
          (taskspaces--activate nil))))))

;;;###autoload
(defun taskspaces-unblock-task ()
  "Clear a task's BLOCKER and return it to TODO."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--unblock-task-file buffer-file-name)
      (let ((issue (org-entry-get nil "ISSUE"))
            (parent (org-entry-get nil "PARENT"))
            (parent-id (org-entry-get nil "PARENT-ID")))
        (when (equal taskspaces-active issue)
          (org-todo "ACTIVE")
          (taskspaces--save-task)
          (org-clock-in nil))
        (when parent
          (taskspaces--refresh-parent-children parent parent-id))))))

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
      (taskspaces--save-task)
      (let ((parent (org-entry-get nil "PARENT"))
            (parent-id (org-entry-get nil "PARENT-ID")))
        (when parent
          (taskspaces--refresh-parent-children parent parent-id)))))
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
           (issue (org-entry-get nil "ISSUE"))
           (parent (org-entry-get nil "PARENT"))
           (parent-id (org-entry-get nil "PARENT-ID")))
      (when (or (file-exists-p file) (get-file-buffer file))
        (user-error "Archived task already exists: %s" file))
      (when (y-or-n-p "Archive this completed task file and destroy its taskspace? ")
        (taskspaces--save-task)
        (make-directory directory t)
        (rename-file buffer-file-name file)
        (set-visited-file-name file nil t)
        (save-buffer)
        (when id (org-id-add-location id file))
        (when parent
          (taskspaces--refresh-parent-children parent parent-id))
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
     ((org-agenda-files (list taskspaces-task-directory))
      (org-agenda-prefix-format
       '((todo . " %(taskspaces--agenda-prefix)")))))))

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

(defun taskspaces--taskspace-root ()
  "Return the directory containing task workspaces.
The legacy worktree directory is used only when explicitly customized."
  (if (and (equal (expand-file-name taskspaces-taskspace-directory)
                  taskspaces--default-taskspace-directory)
           taskspaces-worktree-directory
           (not (equal (expand-file-name taskspaces-worktree-directory)
                       taskspaces--default-taskspace-directory))
           (not (equal (expand-file-name taskspaces-worktree-directory)
                       taskspaces--default-worktree-directory)))
      (file-name-as-directory (expand-file-name taskspaces-worktree-directory))
    (file-name-as-directory (expand-file-name taskspaces-taskspace-directory))))

(defun taskspaces--task-directory (issue)
  (file-name-as-directory (expand-file-name issue (taskspaces--taskspace-root))))

(defun taskspaces--ensure-taskspace (issue)
  "Create ISSUE's taskspace directory and link its Org task record."
  (let* ((directory (taskspaces--task-directory issue))
         (link (expand-file-name "task.org" directory))
         (target (taskspaces--task-file issue)))
    (make-directory directory t)
    (when (and (not (file-equal-p link target))
               (or (file-exists-p link) (file-symlink-p link)))
      (if (file-symlink-p link)
          (delete-file link)
        (user-error "Taskspace path already contains a regular task.org: %s" link)))
    (unless (file-equal-p link target)
      (make-symbolic-link target link t))
    (directory-file-name directory)))

(defun taskspaces--directory-owner (directory)
  (when directory
    (let ((root (taskspaces--taskspace-root))
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
  (let ((directory (taskspaces--ensure-taskspace issue)))
    (switch-to-buffer (if (file-directory-p directory)
                          (dired-noselect directory)
                        (get-scratch-buffer-create))
                      nil t))
  (taskspaces--visit-task (taskspaces--task-file issue)))

(defun taskspaces--activate (issue)
  (puthash taskspaces-active (current-window-configuration) taskspaces--layouts)
  (setq taskspaces-active issue)
  (when issue
    (taskspaces--ensure-taskspace issue))
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
        (let ((parent (org-entry-get nil "PARENT"))
              (parent-id (org-entry-get nil "PARENT-ID")))
          (when parent
            (taskspaces--refresh-parent-children parent parent-id)))
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
               (taskspaces--save-task)
               (let ((parent (org-entry-get nil "PARENT"))
                     (parent-id (org-entry-get nil "PARENT-ID")))
                 (when parent
                   (taskspaces--refresh-parent-children parent parent-id))))))
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
      (when (equal (org-get-todo-state) "DONE")
        (user-error "%s is done; archive it instead" issue)))
    (taskspaces--unblock-task-file file)
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
  (let ((worktrees (taskspaces--taskspace-root)))
    (seq-remove
     (lambda (root)
       (string-prefix-p worktrees (expand-file-name root)))
     (mapcar (lambda (root)
               (file-name-as-directory (expand-file-name root)))
             (project-known-project-roots)))))

;;;###autoload
(defun taskspaces-switch-project (checkout)
  "Visit the active task's worktree of CHECKOUT, creating it if needed.
With no active task, visit CHECKOUT itself."
  (interactive
   (list (completing-read
          (if taskspaces-active
              (format "Project for %s: " taskspaces-active)
            "Project: ")
          (taskspaces--checkout-roots)
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
          (taskspaces--ensure-taskspace taskspaces-active))))))

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
