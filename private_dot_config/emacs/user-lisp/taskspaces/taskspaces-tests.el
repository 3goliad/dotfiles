;;; taskspaces-tests.el --- ERT tests for taskspaces -*- lexical-binding: t -*-

(require 'ert)
(require 'cl-lib)
(require 'taskspaces)

(ert-deftest taskspaces-test-public-functions-use-prefix ()
  "Public taskspaces functions use the taskspaces- prefix."
  (mapatoms
   (lambda (symbol)
     (when (and (fboundp symbol)
                (let ((name (symbol-name symbol)))
                  (and (or (string-prefix-p "taskspace-" name)
                           (string-prefix-p "work-task-" name))
                       (not (string-prefix-p "taskspaces-" name)))))
       (ert-fail (format "Old public function name: %s" symbol))))))

(ert-deftest taskspaces-test-directory-owner ()
  "Worktree ownership is derived from the issue directory."
  (let ((taskspaces-taskspace-directory "/tmp/taskspaces/")
        (taskspaces-active "ABC-123"))
    (should (equal "ABC-123"
                   (taskspaces--directory-owner
                    "/tmp/taskspaces/ABC-123/repo")))
    (should-not (taskspaces--directory-owner
                 "/tmp/taskspaces-other/ABC-123/repo"))
    (with-temp-buffer
      (setq default-directory "/tmp/taskspaces/ABC-123/repo/")
      (should (equal "ABC-123"
                     (taskspaces--buffer-owner (current-buffer)))))))

(ert-deftest taskspaces-test-slug ()
  "Task titles become usable branch-name slugs."
  (should (equal "upgrade-controller-api"
                 (taskspaces--slug "Upgrade Controller API")))
  (should (equal "" (taskspaces--slug "---"))))

(ert-deftest taskspaces-test-worktree-path-mirrors-checkout ()
  "Task worktree paths mirror checkout paths below the checkout root."
  (let ((taskspaces-checkout-directory "/tmp/checkouts/")
        (taskspaces-taskspace-directory "/tmp/taskspaces/")
        (taskspaces-worktree-directory nil))
    (should (equal "/tmp/taskspaces/ABC-123/team/repo/"
                   (taskspaces--worktree-path
                    "ABC-123" "/tmp/checkouts/team/repo")))))

(ert-deftest taskspaces-test-no-task-switch-project-uses-checkout ()
  "Switching projects with no active task forwards the regular checkout."
  (let ((taskspaces-active nil)
        (taskspaces-taskspace-directory "/tmp/taskspaces/")
        (taskspaces-worktree-directory nil)
        switched-to)
    (cl-letf (((symbol-function 'project-known-project-roots)
               (lambda () '("~/Work/team/repo")))
              ((symbol-function 'project-switch-project)
               (lambda (directory)
                 (setq switched-to directory))))
      (taskspaces-switch-project "~/Work/team/repo")
      (should (equal (expand-file-name "~/Work/team/repo/")
                     switched-to)))))

(ert-deftest taskspaces-test-taskspace-contains-task-org-symlink ()
  "Each taskspace links to the task's Org record at task.org."
  (let* ((task-directory (make-temp-file "taskspaces-org-" t))
         (taskspace-directory (make-temp-file "taskspaces-root-" t))
         (taskspaces-task-directory (file-name-as-directory task-directory))
         (taskspaces-taskspace-directory (file-name-as-directory
                                          taskspace-directory))
         (taskspaces-worktree-directory nil)
         (task-file (expand-file-name "ABC-123.org" task-directory))
         (link (expand-file-name "ABC-123/task.org" taskspace-directory)))
    (unwind-protect
        (progn
          (with-temp-file task-file
            (insert "* TODO Test task\n"))
          (taskspaces--ensure-taskspace "ABC-123")
          (should (file-symlink-p link))
          (should (file-equal-p link task-file)))
      (delete-directory taskspace-directory t)
      (delete-directory task-directory t))))

(ert-deftest taskspaces-test-no-agent-shell-api ()
  "Agent-shell functionality is not part of the taskspaces API."
  (should-not (fboundp 'taskspaces-agent))
  (should-not (boundp 'agent-shell-cwd-function))
  (should-not (memq 'agent-shell-mode taskspaces-application-modes)))

(ert-deftest taskspaces-test-no-scheduling-api ()
  "Task recheck scheduling is not part of the taskspaces API."
  (should-not (fboundp 'taskspaces-schedule-task)))

(ert-deftest taskspaces-test-no-handoff-api ()
  "The old handoff API is not part of the taskspaces implementation."
  (should-not (fboundp 'taskspaces-park-task))
  (should-not (fboundp 'taskspaces--task-handoff-fields)))

(ert-deftest taskspaces-test-show-task-switches-without-active-task ()
  "Showing a task invokes the switcher when no task is active."
  (let ((taskspaces-active nil))
    (cl-letf (((symbol-function 'taskspaces-switch-task) (lambda () 'switched)))
      (should (eq (taskspaces-show-task) 'switched)))))

(ert-deftest taskspaces-test-switcher-shows-task-title ()
  "Task switcher candidates show the heading title and issue identifier."
  (let* ((directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-directory (file-name-as-directory directory))
         (file (expand-file-name "ABC-123.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file file
            (insert "* TODO Upgrade Controller API\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":ISSUE: ABC-123\n"
                    ":END:\n"))
          (cl-letf (((symbol-function 'completing-read)
                     (lambda (_prompt candidates &rest _)
                       (should (assoc "Upgrade Controller API (ABC-123)"
                                      candidates))
                       "Upgrade Controller API (ABC-123)")))
            (should (equal file
                           (taskspaces--read-task-file
                            "Switch to task: ")))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-switcher-can-return-issue-id ()
  "The switcher still resolves an issue identifier selected by a completion UI."
  (let* ((directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-directory (file-name-as-directory directory))
         (file (expand-file-name "ABC-123.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file file
            (insert "* TODO Upgrade Controller API\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":ISSUE: ABC-123\n"
                    ":END:\n"))
          (cl-letf (((symbol-function 'completing-read)
                     (lambda (&rest _) "ABC-123")))
            (should (equal file
                           (taskspaces--read-task-file
                            "Switch to task: ")))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-activation-marks-task-active ()
  "Activating a task sets both the active issue and ACTIVE Org state."
  (let* ((org-todo-keywords
          '((sequence "TODO(t)" "ACTIVE(a!)" "WAIT(w!)" "|" "DONE(d!)")))
         (directory (make-temp-file "taskspaces-" t))
         (taskspace-directory (make-temp-file "taskspaces-root-" t))
         (taskspaces-task-directory (file-name-as-directory directory))
         (taskspaces-taskspace-directory (file-name-as-directory
                                          taskspace-directory))
         (taskspaces-worktree-directory nil)
         (taskspaces-active nil)
         (taskspaces--layouts (make-hash-table :test #'equal))
         (file (expand-file-name "ABC-123.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file file
            (insert "* TODO Upgrade Controller API\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":ISSUE: ABC-123\n"
                    ":END:\n"))
          (cl-letf (((symbol-function 'taskspaces--ensure-taskspace)
                     (lambda (_issue) directory))
                    ((symbol-function 'taskspaces--fresh-layout)
                     (lambda (_issue) nil))
                    ((symbol-function 'taskspaces--hide-foreign-windows)
                     (lambda () nil))
                    ((symbol-function 'org-clock-in)
                     (lambda (&rest _) t)))
            (taskspaces--activate "ABC-123")
            (should (equal "ABC-123" taskspaces-active))
            (with-current-buffer (find-file-noselect file)
              (taskspaces--goto-task-root)
              (should (equal "ACTIVE" (org-get-todo-state))))))
      (delete-directory taskspace-directory t)
      (delete-directory directory t))))

(ert-deftest taskspaces-test-switching-unblocks-task ()
  "Switching to a WAIT task clears its blocker and makes it TODO."
  (let* ((org-todo-keywords
          '((sequence "TODO(t)" "ACTIVE(a!)" "WAIT(w!)" "|" "DONE(d!)")))
         (directory (make-temp-file "taskspaces-" t))
         (file (expand-file-name "ABC-123.org" directory))
         (taskspaces-task-directory (file-name-as-directory directory)))
    (unwind-protect
        (progn
          (with-temp-file file
            (insert "* WAIT Test task\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":ISSUE: ABC-123\n"
                    ":BLOCKER: Waiting for review\n"
                    ":END:\n"))
          (taskspaces--unblock-task-file file)
          (with-current-buffer (find-file-noselect file)
            (taskspaces--goto-task-root)
            (should (equal (org-get-todo-state) "TODO"))
            (should-not (org-entry-get nil "BLOCKER"))))
      (delete-directory directory t))))

(provide 'taskspaces-tests)
;;; taskspaces-tests.el ends here
