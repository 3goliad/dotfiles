;;; taskspaces.el --- Work tasks with isolated editor state -*- lexical-binding: t; -*-

;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience, outlines, vc
;; Version: 0.2

;;; Commentary:

;; Org is the source of truth for tasks.  Work tasks are TODO headings in
;; `taskspaces-task-file'; the running Org clock identifies the active task.
;; This package adds taskspaces around stable Org IDs: worktrees, terminals,
;; buffers, and window layouts.  Nothing is duplicated in a custom task list.

;;; Code:

(require 'project)
(require 'seq)
(require 'subr-x)

(require 'org)
(require 'org-agenda)
(require 'org-capture)
(require 'org-id)
(require 'org-clock)

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
  "Stable Org ID of the clocked-in task, or nil.

This is a cache synchronized with Org's running clock.")

(defvar taskspaces--layouts (make-hash-table :test #'equal)
  "Window configurations keyed by stable task Org ID.")

(defconst taskspaces--default-taskspace-directory
  (expand-file-name "~/Work/taskspaces/")
  "The default directory for task workspaces.")
(defcustom taskspaces-taskspace-directory taskspaces--default-taskspace-directory
  "Directory containing one live taskspace per stable task ID."
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

(defcustom taskspaces-task-file (expand-file-name "~/Work/org/tasks.org")
  "Org file containing active work-task TODO headings."
  :type 'file)
(defcustom taskspaces-task-archive-file
  (expand-file-name "~/Work/org/tasks.org_archive")
  "Org file receiving archived work-task subtrees."
  :type 'file)

(defun taskspaces--task-file ()
  "Return the expanded task file path."
  (expand-file-name taskspaces-task-file))

(defun taskspaces--task-archive-file ()
  "Return the expanded task archive file path."
  (expand-file-name taskspaces-task-archive-file))

(defun taskspaces--ensure-task-file ()
  "Create the tasks file and add it to Org agenda files."
  (let ((file (taskspaces--task-file)))
    (make-directory (file-name-directory file) t)
    (unless (file-exists-p file)
      (with-temp-file file
        (insert "#+title: Work Tasks\n"
                "#+filetags: :work:\n"
                "#+ARCHIVE: " (taskspaces--task-archive-file) "::\n\n"
                "* Tasks\n")))
    (add-to-list 'org-agenda-files file t)
    file))

(defun taskspaces--configure-task-buffer ()
  "Configure archive behavior in the task Org buffer."
  (when (and buffer-file-name
             (file-equal-p (expand-file-name buffer-file-name)
                           (taskspaces--task-file)))
    (setq-local org-archive-location
                (concat (taskspaces--task-archive-file) "::"))))

(add-hook 'org-mode-hook #'taskspaces--configure-task-buffer)

(defun taskspaces--work-tag-p ()
  "Return non-nil if the heading at point inherits the work tag."
  (and (member "work" (org-get-tags nil nil)) t))

(defun taskspaces--task-record-at-point ()
  "Return task metadata for the valid work TODO heading at point."
  (save-excursion
    (when (org-at-heading-p)
      (org-back-to-heading t)
      (let* ((id (org-entry-get nil "ID"))
             (issue (org-entry-get nil "ISSUE"))
             (title (string-trim (org-get-heading t t t t)))
             (state (org-get-todo-state)))
        (when (and id
                   (not (string-empty-p id))
                   (taskspaces--work-tag-p)
                   (member state '("TODO" "WAIT" "DONE")))
          (list :id id
                :issue issue
                :title (if (string-empty-p title)
                           (or issue id)
                         title)
                :state state
                :blocker (org-entry-get nil "BLOCKER")
                :outline-path (org-get-outline-path t)))))))

(defun taskspaces--active-task-records ()
  "Return task records in the active tasks file, including DONE tasks."
  (let ((file (taskspaces--task-file))
        (records nil))
    (when (file-exists-p file)
      (with-current-buffer (find-file-noselect file)
        (save-restriction
          (widen)
          (setq records
                (delq nil
                      (org-map-entries
                       #'taskspaces--task-record-at-point
                       nil
                       'file))))))
    records))

(defun taskspaces--present-task-ids ()
  "Return stable IDs present in the active tasks file."
  (delete-dups
   (mapcar (lambda (record) (plist-get record :id))
           (taskspaces--active-task-records))))

(defun taskspaces--task-record-by-id (id)
  "Return the task record for active work TODO ID, or nil."
  (when (and id (not (string-empty-p id)))
    (let ((location (org-id-find id)))
      (when location
        (let ((file (car location))
              (position (cdr location)))
          (when (and file
                     (file-equal-p (expand-file-name file)
                                   (taskspaces--task-file)))
            (with-current-buffer (find-file-noselect file)
              (save-excursion
                (save-restriction
                  (widen)
                  (goto-char position)
                  (let ((record (taskspaces--task-record-at-point)))
                    (and record
                         (not (equal (plist-get record :state) "DONE"))
                         record)))))))))))

(defun taskspaces--clocked-task-record ()
  "Return the valid work task record for the running Org clock."
  (when (and (org-clocking-p)
             (markerp org-clock-hd-marker)
             (marker-buffer org-clock-hd-marker))
    (with-current-buffer (marker-buffer org-clock-hd-marker)
      (save-excursion
        (save-restriction
          (widen)
          (goto-char org-clock-hd-marker)
          (when (and buffer-file-name
                     (file-equal-p (expand-file-name buffer-file-name)
                                   (taskspaces--task-file)))
            (let ((record (taskspaces--task-record-at-point)))
              (and record
                   (not (equal (plist-get record :state) "DONE"))
                   record))))))))

(defun taskspaces--candidate-label (record)
  "Return the switcher label for TASK RECORD."
  (let* ((title (plist-get record :title))
         (issue (plist-get record :issue))
         (state (plist-get record :state))
         (blocker (plist-get record :blocker))
         (outline (plist-get record :outline-path))
         (context (when (> (length outline) 1)
                    (concat "[" (string-join (butlast outline) "/") "] ")))
         (issue-label (if (and issue (not (string-empty-p issue)))
                          (format "%s " issue)
                        "")))
    (format "%s%s%s [%s]%s"
            (or context "")
            issue-label
            title
            state
            (if (and blocker (not (string-empty-p blocker)))
                (format ": %s" blocker)
              ""))))

(defun taskspaces--read-task-id (prompt &optional exclude)
  "Read a task ID with PROMPT, optionally excluding EXCLUDE."
  (let ((candidates nil))
    (dolist (record (taskspaces--active-task-records))
      (let ((id (plist-get record :id))
            (state (plist-get record :state)))
        (when (and (not (equal id exclude))
                   (member state '("TODO" "WAIT")))
          (push (cons (taskspaces--candidate-label record) id) candidates))))
    (setq candidates (nreverse candidates))
    (unless candidates
      (user-error "No active work tasks; use M-x taskspaces-new-task"))
    (let* ((choice (completing-read prompt candidates nil t))
           (id (cdr (assoc choice candidates))))
      (or id
          (cdr (seq-find (lambda (candidate)
                           (equal (cdr candidate) choice))
                         candidates))
          (user-error "Unknown task: %s" choice)))))

(defun taskspaces--goto-task-id (id)
  "Visit the heading with stable task ID in the active task file."
  (let ((location (org-id-find id)))
    (unless (and location
                 (file-equal-p (expand-file-name (car location))
                               (taskspaces--task-file)))
      (user-error "Unknown active work task: %s" id))
    (org-id-goto id)))

(defun taskspaces--required-task-value (value label)
  (setq value (string-trim value))
  (when (or (string-empty-p value) (string-match-p "[\n\r]" value))
    (user-error "%s must be a nonempty single line" label))
  value)

;;;; Capture

(defun taskspaces--prepare-capture-finalize ()
  "Finalize captured task headings and register their Org IDs."
  (if org-note-abort
      (setq org-capture-current-plist
            (plist-put org-capture-current-plist :no-save t))
    (with-current-buffer (org-capture-get :buffer t)
      (save-excursion
        (save-restriction
          (widen)
          (org-back-to-heading t)
          (let ((id (org-id-get-create)))
            (org-id-add-location id buffer-file-name)
            (taskspaces--required-task-value
             (org-get-heading t t t t)
             "Task title")))))))

(defun taskspaces--goto-capture-parent ()
  "Position a child capture target beneath its selected parent."
  (let* ((id (org-capture-get :taskspaces-parent-id))
         (location (and id (org-id-find id))))
    (unless location
      (user-error "Unknown task parent: %s" id))
    (pcase location
      (`(,file . ,position)
       (unless (file-equal-p (expand-file-name file)
                             (taskspaces--task-file))
         (user-error "Task parent is not in %s" (taskspaces--task-file)))
       (goto-char position)
       (org-back-to-heading t)))))

(with-eval-after-load 'org-capture
  (add-to-list
   'org-capture-templates
   '("w" "Work task" entry
     (file+headline taskspaces-task-file "Tasks")
     "* TODO %^{Task title} :work:\n:PROPERTIES:\n:ID: %(org-id-new)\n:ISSUE: %^{Issue identifier (optional)}\n:END:\n"
     :unnarrowed t
     :jump-to-captured t
     :prepare-finalize taskspaces--prepare-capture-finalize))
  (add-to-list
   'org-capture-templates
   '("c" "Linked child task" entry
     (file+function taskspaces-task-file taskspaces--goto-capture-parent)
     "* TODO %^{Child task title} :work:\n:PROPERTIES:\n:ID: %(org-id-new)\n:ISSUE: %^{Issue identifier (optional)}\n:END:\n"
     :unnarrowed t
     :jump-to-captured t
     :prepare-finalize taskspaces--prepare-capture-finalize)))

;;;###autoload
(defun taskspaces-new-task ()
  "Capture a new work task in `taskspaces-task-file'."
  (interactive)
  (taskspaces--ensure-task-file)
  (org-capture nil "w"))

(defun taskspaces--current-task-reference ()
  "Return the current task ID, or prompt for a parent task."
  (save-excursion
    (save-restriction
      (widen)
      (if (and (derived-mode-p 'org-mode)
               buffer-file-name
               (file-equal-p (expand-file-name buffer-file-name)
                             (taskspaces--task-file)))
          (let ((record (taskspaces--task-record-at-point)))
            (if record
                (plist-get record :id)
              (taskspaces--read-task-id "Add child to task: ")))
        (taskspaces--read-task-id "Add child to task: ")))))

;;;###autoload
(defun taskspaces-new-child-task ()
  "Capture a child task beneath the current or selected task."
  (interactive)
  (taskspaces--ensure-task-file)
  (let ((parent-id (taskspaces--current-task-reference)))
    (org-capture-put :taskspaces-parent-id parent-id)
    (org-capture nil "c")))

;;;; Ownership

(defun taskspaces--require-active ()
  (or taskspaces-active
      (user-error "No active task; use M-x taskspaces-switch-task")))

(defun taskspaces--taskspace-root ()
  "Return the directory containing task workspaces."
  (file-name-as-directory (expand-file-name taskspaces-taskspace-directory)))

(defun taskspaces--task-directory-name (id)
  "Return a safe directory name for stable task ID."
  (replace-regexp-in-string "[^[:alnum:]_-]+" "-" id))

(defun taskspaces--task-directory (id)
  "Return the live taskspace directory for stable task ID."
  (file-name-as-directory
   (expand-file-name (taskspaces--task-directory-name id)
                     (taskspaces--taskspace-root))))

(defun taskspaces--ensure-taskspace (id)
  "Create and return the taskspace directory for stable task ID."
  (let ((directory (taskspaces--task-directory id)))
    (make-directory directory t)
    (directory-file-name directory)))

(defun taskspaces--directory-owner (directory)
  "Return the stable task ID owning DIRECTORY, or nil."
  (when directory
    (let ((root (taskspaces--taskspace-root))
          (directory (expand-file-name directory)))
      (when (string-prefix-p root directory)
        (car (split-string (substring directory (length root)) "/" t))))))

(defvar-local taskspaces--owner nil
  "Stable task ID owning this buffer, :shared, or nil to infer ownership.")
(put 'taskspaces--owner 'permanent-local t)

(defvar-local taskspaces--terminal nil
  "Non-nil in terminals created by `taskspaces-terminal'.")
(put 'taskspaces--terminal 'permanent-local t)

(defun taskspaces--buffer-owner (buffer)
  "Return the stable task ID owning BUFFER, or nil if it is shared."
  (pcase (buffer-local-value 'taskspaces--owner buffer)
    (:shared nil)
    ('nil (let* ((directory
                  (or (buffer-local-value 'buffer-file-name buffer)
                      (buffer-local-value 'default-directory buffer)))
                 (owner (taskspaces--directory-owner directory)))
            (if owner
                (taskspaces--find-id-from-directory-name owner)
              nil)))
    (owner owner)))

(defun taskspaces--find-id-from-directory-name (name)
  "Resolve directory NAME back to a stable task ID."
  (let ((id
         (seq-find
          (lambda (record)
            (equal (taskspaces--task-directory-name (plist-get record :id))
                   name))
          (taskspaces--active-task-records))))
    (unless id
      (maphash
       (lambda (layout-id _layout)
         (when (and layout-id
                    (equal (taskspaces--task-directory-name layout-id)
                           name))
           (setq id layout-id)))
       taskspaces--layouts))
    (or id name)))

(defun taskspaces--buffer-visible-p (buffer)
  "Return non-nil if BUFFER is shared or belongs to the active task."
  (let ((owner (taskspaces--buffer-owner buffer)))
    (or (null owner) (equal owner taskspaces-active))))

(defun taskspaces--buffer-list ()
  "Return `buffer-list' without other tasks' buffers."
  (seq-filter #'taskspaces--buffer-visible-p (buffer-list)))

(defun taskspaces--tag-application-buffer ()
  "Associate a newly created application buffer with the active task."
  (when (and (not buffer-file-name)
             (derived-mode-p taskspaces-application-modes))
    (setq taskspaces--owner (or taskspaces-active :shared))))

(add-hook 'after-change-major-mode-hook #'taskspaces--tag-application-buffer)

(modify-all-frames-parameters
 '((buffer-predicate . taskspaces--buffer-visible-p)))

(with-eval-after-load 'consult
  (setq consult-buffer-list-function #'taskspaces--buffer-list))

;;;; Switching

(defun taskspaces--hide-foreign-windows ()
  "Hide windows owned by tasks other than the active task."
  (dolist (window (window-list nil 'no-minibuf))
    (unless (taskspaces--buffer-visible-p (window-buffer window))
      (switch-to-prev-buffer window)
      (unless (taskspaces--buffer-visible-p (window-buffer window))
        (if (and (window-parameter window 'window-side)
                 (not (eq window (window-main-window))))
            (delete-window window)
          (set-window-buffer window (get-scratch-buffer-create)))))))

(defun taskspaces--fresh-layout (id)
  "Create a fresh window layout for stable task ID."
  (select-window (window-main-window))
  (dolist (window (window-list nil 'no-minibuf))
    (unless (eq window (selected-window))
      (ignore-errors (delete-window window))))
  (let ((directory (taskspaces--ensure-taskspace id)))
    (switch-to-buffer (if (file-directory-p directory)
                          (dired-noselect directory)
                        (get-scratch-buffer-create))
                      nil t))
  (taskspaces--goto-task-id id)
  (org-fold-show-context)
  (org-fold-show-subtree))

(defun taskspaces--plain-layout ()
  "Select a plain layout with no active task."
  (select-window (window-main-window))
  (dolist (window (window-list nil 'no-minibuf))
    (unless (eq window (selected-window))
      (ignore-errors (delete-window window))))
  (switch-to-buffer (get-scratch-buffer-create) nil t))

(defun taskspaces--activate (id)
  "Activate stable task ID, or deactivate with nil."
  (unless (equal taskspaces-active id)
    (puthash taskspaces-active (current-window-configuration)
             taskspaces--layouts)
    (setq taskspaces-active id))
  (if id
      (progn
        (taskspaces--ensure-taskspace id)
        (let ((layout (gethash id taskspaces--layouts)))
          (cond
           ((and layout (frame-live-p
                         (window-configuration-frame layout)))
            (set-window-configuration layout))
           (t (taskspaces--fresh-layout id)))))
    (let ((layout (gethash nil taskspaces--layouts)))
      (if (and layout (frame-live-p
                       (window-configuration-frame layout)))
          (set-window-configuration layout)
        (taskspaces--plain-layout))))
  (taskspaces--hide-foreign-windows)
  (force-mode-line-update t))

(defun taskspaces--sync-active-taskspace ()
  "Synchronize the live taskspace with Org's running clock."
  (let ((record (taskspaces--clocked-task-record)))
    (taskspaces--activate (and record (plist-get record :id))))
  (force-mode-line-update t))

(defun taskspaces--clock-in-taskspace ()
  "Unblock WAIT tasks and synchronize the live taskspace after clock-in."
  (let ((record (taskspaces--clocked-task-record)))
    (when (and record (equal (plist-get record :state) "WAIT"))
      (save-excursion
        (org-with-point-at org-clock-hd-marker
          (org-back-to-heading t)
          (org-entry-delete nil "BLOCKER")
          (org-todo "TODO")
          (save-buffer))))
    (taskspaces--sync-active-taskspace)))

(add-hook 'org-clock-in-hook #'taskspaces--clock-in-taskspace)
(add-hook 'org-clock-out-hook #'taskspaces--sync-active-taskspace)
(add-hook 'org-clock-cancel-hook #'taskspaces--sync-active-taskspace)

(run-at-time 0 nil #'taskspaces--sync-active-taskspace)
(add-hook 'emacs-startup-hook #'taskspaces--sync-active-taskspace)

;;;###autoload
(defun taskspaces-show-task ()
  "Open the active task heading, or switch if no task is active."
  (interactive)
  (if (and taskspaces-active
           (taskspaces--task-record-by-id taskspaces-active))
      (taskspaces--goto-task-id taskspaces-active)
    (taskspaces-switch-task)))

(defun taskspaces--leave (prompt-for-blocker)
  "Clock out the active task and preserve its taskspace.
When PROMPT-FOR-BLOCKER is non-nil, optionally mark the task WAIT."
  (let ((id taskspaces-active))
    (when id
      (when (org-clocking-p)
        (org-clock-out nil t))
      (when (not (org-clocking-p))
        (taskspaces--activate nil))
      (save-some-buffers
       nil (lambda ()
             (equal (taskspaces--buffer-owner (current-buffer)) id)))
      (when prompt-for-blocker
        (let ((record (taskspaces--task-record-by-id id)))
          (when (and record
                     (y-or-n-p
                      (format "Mark %s blocked? "
                              (or (plist-get record :issue) id))))
            (save-excursion
              (taskspaces--goto-task-id id)
              (let ((blocker
                     (string-trim
                      (read-string "Blocker (optional): "
                                   (org-entry-get nil "BLOCKER")))))
                (org-todo "WAIT")
                (if (string-empty-p blocker)
                    (org-entry-delete nil "BLOCKER")
                  (org-entry-put nil "BLOCKER" blocker))
                (save-buffer)))))))))

;;;###autoload
(defun taskspaces-switch-task ()
  "Switch taskspaces by clocking in a selected work task."
  (interactive)
  (let* ((id (taskspaces--read-task-id
              "Switch to task: " taskspaces-active)))
    (let ((record (taskspaces--task-record-by-id id)))
      (unless record
        (user-error "Task is no longer active: %s" id))
      (when (equal (plist-get record :state) "WAIT")
        (save-excursion
          (taskspaces--goto-task-id id)
          (org-entry-delete nil "BLOCKER")
          (org-todo "TODO")
          (save-buffer))))
    (unless (equal id taskspaces-active)
      (taskspaces--leave t))
    (save-excursion
      (taskspaces--goto-task-id id)
      (org-clock-in nil)))
  (let ((record (taskspaces--clocked-task-record)))
    (message "%s"
             (if record
                 (taskspaces--candidate-label record)
               "No active task"))))

;;;###autoload
(defun taskspaces-close-task ()
  "Clock out and return to buffers shared by no task."
  (interactive)
  (taskspaces--require-active)
  (taskspaces--leave nil))

;;;###autoload
(defun taskspaces-block-task ()
  "Mark the current work task WAIT and optionally record a BLOCKER."
  (interactive)
  (let* ((record (if (and taskspaces-active
                           (taskspaces--task-record-by-id taskspaces-active))
                     (taskspaces--task-record-by-id taskspaces-active)
                   (save-excursion
                     (when (and (derived-mode-p 'org-mode)
                                (taskspaces--work-tag-p))
                       (taskspaces--task-record-at-point)))))
         (id (and record (plist-get record :id))))
    (unless id
      (user-error "Point is not in an active work task"))
    (when (and (org-clocking-p)
               (equal (plist-get (taskspaces--clocked-task-record) :id) id))
      (org-clock-out nil t))
    (save-excursion
      (taskspaces--goto-task-id id)
      (let ((blocker
             (string-trim
              (read-string "Blocker (optional): "
                           (org-entry-get nil "BLOCKER")))))
        (org-todo "WAIT")
        (if (string-empty-p blocker)
            (org-entry-delete nil "BLOCKER")
          (org-entry-put nil "BLOCKER" blocker))
        (save-buffer)))))

;;;###autoload
(defun taskspaces-unblock-task ()
  "Clear a task's BLOCKER and return it to TODO."
  (interactive)
  (let* ((id (if (and taskspaces-active
                      (taskspaces--task-record-by-id taskspaces-active))
                 taskspaces-active
               (let ((record (save-excursion
                               (when (and (derived-mode-p 'org-mode)
                                          (taskspaces--work-tag-p))
                                 (taskspaces--task-record-at-point)))))
                 (and record (plist-get record :id)))))
         (record (and id (taskspaces--task-record-by-id id))))
    (unless record
      (user-error "Point is not in an active work task"))
    (save-excursion
      (taskspaces--goto-task-id id)
      (org-entry-delete nil "BLOCKER")
      (org-todo "TODO")
      (save-buffer))))

;;;###autoload
(defun taskspaces-finish-task ()
  "Mark the current work task DONE and clock out if needed."
  (interactive)
  (let* ((record (save-excursion
                   (when (and (derived-mode-p 'org-mode)
                              (taskspaces--work-tag-p))
                     (taskspaces--task-record-at-point))))
         (id (and record (plist-get record :id))))
    (unless id
      (setq id taskspaces-active)
      (setq record (and id (taskspaces--task-record-by-id id))))
    (unless record
      (user-error "Point is not in an active work task"))
    (when (and (org-clocking-p)
               (equal (plist-get (taskspaces--clocked-task-record) :id) id))
      (org-clock-out nil t))
    (save-excursion
      (taskspaces--goto-task-id id)
      (org-entry-delete nil "BLOCKER")
      (org-todo "DONE")
      (save-buffer))
    (message "Task done; use M-x taskspaces-archive-task to archive")))

;;;###autoload
(defun taskspaces-archive-task ()
  "Archive the current DONE work-task subtree with Org's standard behavior."
  (interactive)
  (let* ((record (save-excursion
                   (when (and (derived-mode-p 'org-mode)
                              (taskspaces--work-tag-p))
                     (taskspaces--task-record-at-point))))
         (id (and record (plist-get record :id))))
    (unless id
      (setq id taskspaces-active)
      (setq record (and id (taskspaces--task-record-by-id id))))
    (unless record
      (user-error "Point is not in an active work task"))
    (unless (equal (plist-get record :state) "DONE")
      (user-error "Finish the task before archiving it"))
    (save-excursion
      (taskspaces--goto-task-id id)
      (when (y-or-n-p "Archive this completed task subtree and tear down its taskspace? ")
        (org-archive-subtree)))))

;;;; Worktrees

(defun taskspaces--git-run (directory args)
  "Run git ARGS in DIRECTORY and return (STATUS . OUTPUT)."
  (let ((default-directory directory))
    (with-temp-buffer
      (cons (apply #'process-file "git" nil t nil args)
            (string-trim (buffer-string))))))

(defun taskspaces--git (directory &rest args)
  "Run git ARGS in DIRECTORY or signal a user-facing error."
  (pcase-let ((`(,status . ,output) (taskspaces--git-run directory args)))
    (unless (eq status 0)
      (user-error "git %s failed: %s" (string-join args " ") output))
    output))

(defun taskspaces--git-ok-p (directory &rest args)
  "Return non-nil if git ARGS succeed in DIRECTORY."
  (eq 0 (car (taskspaces--git-run directory args))))

(defun taskspaces--remote-default-branch (checkout)
  "Return the remote default branch for CHECKOUT."
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
  "Convert TITLE to a branch-name slug."
  (string-trim (replace-regexp-in-string "[^[:alnum:]]+" "-" (downcase title))
               "-+" "-+"))

(defun taskspaces--default-branch-name (id)
  "Return a default branch name for stable task ID."
  (let* ((record (taskspaces--task-record-by-id id))
         (issue (and record (plist-get record :issue)))
         (title (and record (plist-get record :title)))
         (slug (taskspaces--slug (or title id)))
         (prefix (if (and issue (not (string-empty-p issue)))
                     (concat issue "-")
                   "")))
    (if (string-empty-p slug)
        (or issue id)
      (concat prefix slug))))

(defun taskspaces--worktree-path (id checkout)
  "Return the task worktree path for ID mirroring CHECKOUT."
  (let* ((base (file-name-as-directory
                (expand-file-name taskspaces-checkout-directory)))
         (relative (if (string-prefix-p base checkout)
                       (substring checkout (length base))
                     "")))
    (when (string-empty-p relative)
      (setq relative (file-name-nondirectory (directory-file-name checkout))))
    (file-name-as-directory
     (expand-file-name relative (taskspaces--task-directory id)))))

(defun taskspaces--add-task-resource (id text)
  "Append TEXT to task ID's Resources section."
  (save-excursion
    (save-restriction
      (widen)
      (taskspaces--goto-task-id id)
      (let ((end (save-excursion (org-end-of-subtree t t))))
        (unless (re-search-forward "^\\*\\*+ Resources[ \t]*$" end t)
          (user-error "Task has no Resources section")))
      (org-end-of-subtree t)
      (insert "\n- " text)
      (save-buffer))))

(defun taskspaces--create-worktree (id checkout path)
  "Create a worktree for task ID at PATH for CHECKOUT."
  (let* ((target (directory-file-name path))
         (branch (string-trim
                  (read-string
                   (format "Create %s on branch: " (abbreviate-file-name target))
                   (taskspaces--default-branch-name id)))))
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
    (taskspaces--add-task-resource
     id
     (format "Worktree: %s (branch %s)"
             (abbreviate-file-name target)
             branch))
    (message "Created worktree %s" (abbreviate-file-name target))))

(defun taskspaces--checkout-roots ()
  "Return regular project checkout roots outside taskspaces."
  (let ((worktrees (taskspaces--taskspace-root)))
    (seq-remove
     (lambda (root)
       (string-prefix-p worktrees (expand-file-name root)))
     (mapcar (lambda (root)
               (file-name-as-directory (expand-file-name root)))
             (project-known-project-roots)))))

;;;###autoload
(defun taskspaces-switch-project (checkout)
  "Visit CHECKOUT's worktree for the clocked task, creating it if needed."
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
       (let ((path (taskspaces--worktree-path
                    taskspaces-active checkout)))
         (unless (file-directory-p path)
           (taskspaces--create-worktree
            taskspaces-active checkout path))
         path)))))

;;;; Archive cleanup

(defun taskspaces--known-taskspace-ids ()
  "Return task IDs that have live layouts or taskspace directories."
  (let ((ids nil))
    (maphash (lambda (id _layout)
               (when id (push id ids)))
             taskspaces--layouts)
    (when taskspaces-active
      (push taskspaces-active ids))
    (let ((root (taskspaces--taskspace-root)))
      (when (file-directory-p root)
        (dolist (name (directory-files root nil "\\`[^.]"))
          (when (file-directory-p (expand-file-name name root))
            (push (taskspaces--find-id-from-directory-name name) ids)))))
    (dolist (buffer (buffer-list))
      (when-let* ((owner (taskspaces--buffer-owner buffer)))
        (push owner ids)))
    (delete-dups (delq nil ids))))

(defun taskspaces--remove-task-worktrees (id)
  "Remove Git worktrees and files under task ID."
  (let* ((directory (taskspaces--task-directory id))
         (root (directory-file-name directory)))
    (when (file-directory-p directory)
      (dolist (git-marker
               (directory-files-recursively directory "\\`\\.git\\'" t))
        (let* ((worktree
                (if (file-directory-p git-marker)
                    (directory-file-name
                     (file-name-directory
                      (directory-file-name git-marker)))
                  (directory-file-name
                   (file-name-directory git-marker))))
               (base (file-name-as-directory
                      (expand-file-name taskspaces-checkout-directory)))
               (relative (when (string-prefix-p
                                (file-name-as-directory root)
                                worktree)
                           (substring worktree
                                      (length
                                       (file-name-as-directory root)))))
               (checkout (and relative
                              (expand-file-name relative base))))
          (when (and checkout
                     (file-directory-p checkout)
                     (taskspaces--git-ok-p checkout "rev-parse"
                                            "--git-dir"))
            (taskspaces--git-run
             checkout
             (list "worktree" "remove" "--force"
                   (directory-file-name worktree))))))
      (delete-directory directory t))))

(defun taskspaces--destroy-taskspace (id)
  "Destroy live buffers, layout, worktrees, and directory for task ID."
  (when id
    (when (equal taskspaces-active id)
      (when (and (org-clocking-p)
                 (equal (plist-get (taskspaces--clocked-task-record) :id) id))
        (org-clock-out nil t))
      (taskspaces--activate nil))
    (dolist (buffer (buffer-list))
      (when (equal (taskspaces--buffer-owner buffer) id)
        (kill-buffer buffer)))
    (remhash id taskspaces--layouts)
    (taskspaces--remove-task-worktrees id)))

(defun taskspaces--cleanup-taskspaces ()
  "Destroy live taskspaces whose IDs are absent from the active task file."
  (let ((present (taskspaces--present-task-ids)))
    (dolist (id (taskspaces--known-taskspace-ids))
      (unless (member id present)
        (taskspaces--destroy-taskspace id)))))

(defun taskspaces--org-archive-hook ()
  "Clock out and schedule cleanup after a subtree is archived."
  (let* ((record (save-excursion
                   (org-back-to-heading t)
                   (taskspaces--task-record-at-point)))
         (id (and record (plist-get record :id))))
    (when (and id
               (org-clocking-p)
               (equal (plist-get (taskspaces--clocked-task-record) :id) id))
      (org-clock-out nil t))
    (run-at-time 0 nil #'taskspaces--cleanup-taskspaces)))

(with-eval-after-load 'org-archive
  (add-hook 'org-archive-hook #'taskspaces--org-archive-hook))

(defun taskspaces--task-summary (id)
  "Return a short summary for task ID."
  (let ((record (taskspaces--task-record-by-id id)))
    (if record
        (taskspaces--candidate-label record)
      id)))

;;;; Terminals and agents

(defconst taskspaces--terminal-display
  '((display-buffer-reuse-window display-buffer-at-bottom)
    (window-height . 0.33)))

(defun taskspaces--terminal-buffer ()
  "Return the active task's live terminal buffer."
  (seq-find
   (lambda (buffer)
     (and (buffer-local-value 'taskspaces--terminal buffer)
          (equal (taskspaces--buffer-owner buffer) taskspaces-active)
          (process-live-p
           (ignore-errors (buffer-local-value 'ghostel--process buffer)))))
   (buffer-list)))

(defun taskspaces--terminal-directory ()
  "Return the directory in which to start or find the active terminal."
  (if (not taskspaces-active)
      default-directory
    (let ((project (project-current)))
      (if (and project
               (equal (taskspaces--directory-owner (project-root project))
                      taskspaces-active))
          (project-root project)
        (taskspaces--ensure-taskspace taskspaces-active)))))

;;;###autoload
(defun taskspaces-terminal (&optional new)
  "Summon or dismiss the active task terminal, or the shared terminal.
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

;;;; Agenda

(defun taskspaces--agenda-prefix ()
  "Return an ACTIVE or outline-context prefix for a work-task agenda entry."
  (let* ((marker (or (get-text-property (point) 'org-hd-marker)
                     (get-text-property (point) 'org-marker)))
         (buffer (and marker (marker-buffer marker))))
    (if (and buffer marker)
        (with-current-buffer buffer
          (save-excursion
            (goto-char marker)
            (let* ((id (org-entry-get nil "ID"))
                   (record (taskspaces--task-record-at-point))
                   (outline (and record
                                 (plist-get record :outline-path))))
              (cond
               ((and id
                     (equal id taskspaces-active))
                "[ACTIVE] ")
               ((and outline (> (length outline) 1))
                (format "[%s] "
                        (string-join (butlast outline) "/")))
               (t "")))))
      "")))

(with-eval-after-load 'org-agenda
  (add-to-list
   'org-agenda-custom-commands
   '("W" "Work tasks"
     ((todo "TODO" ((org-agenda-overriding-header "Ready")))
      (todo "WAIT" ((org-agenda-overriding-header "Waiting")))
      (todo "DONE" ((org-agenda-overriding-header "Done"))))
     ((org-agenda-files (list taskspaces-task-file))
      (org-agenda-prefix-format
       '((todo . " %(taskspaces--agenda-prefix)")))))))

;;;###autoload
(defun taskspaces-agenda ()
  "Show work tasks grouped by state."
  (interactive)
  (taskspaces--ensure-task-file)
  (org-agenda nil "W"))

;;;; Mode line and keys

(defvar taskspaces-mode-line
  '(taskspaces-active (" [" taskspaces-active "]")))
(put 'taskspaces-mode-line 'risky-local-variable t)
(add-to-list 'global-mode-string 'taskspaces-mode-line t)

(provide 'taskspaces)
;;; taskspaces.el ends here
