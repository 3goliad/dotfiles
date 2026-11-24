;;; taskspaces-tests.el --- ERT tests for taskspaces -*- lexical-binding: t -*-

(require 'ert)
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

(ert-deftest taskspaces-test-show-task-requires-active-task ()
  "Showing a task requires an active task."
  (let ((taskspaces-active nil))
    (should-error (taskspaces-show-task) :type 'user-error)))

(provide 'taskspaces-tests)
;;; taskspaces-tests.el ends here
