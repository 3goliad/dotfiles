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
  (let ((taskspaces-worktree-directory "/tmp/taskspaces-worktrees/")
        (taskspaces-active "ABC-123"))
    (should (equal "ABC-123"
                   (taskspaces--directory-owner
                    "/tmp/taskspaces-worktrees/ABC-123/repo")))
    (should-not (taskspaces--directory-owner
                 "/tmp/taskspaces-worktrees-other/ABC-123/repo"))
    (with-temp-buffer
      (setq default-directory "/tmp/taskspaces-worktrees/ABC-123/repo/")
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
        (taskspaces-worktree-directory "/tmp/worktrees/"))
    (should (equal "/tmp/worktrees/ABC-123/team/repo/"
                   (taskspaces--worktree-path
                    "ABC-123" "/tmp/checkouts/team/repo")))))

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
