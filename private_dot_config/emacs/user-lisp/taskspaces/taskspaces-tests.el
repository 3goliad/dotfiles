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
  "Stable task IDs own directories below the taskspace root."
  (let ((taskspaces-taskspace-directory "/tmp/taskspaces/")
        (taskspaces-active "test-id"))
    (should (equal "test-id"
                   (taskspaces--directory-owner
                    "/tmp/taskspaces/test-id/repo")))
    (should-not (taskspaces--directory-owner
                 "/tmp/taskspaces-other/test-id/repo"))
    (with-temp-buffer
      (setq default-directory "/tmp/taskspaces/test-id/repo/")
      (should (equal "test-id"
                     (taskspaces--buffer-owner (current-buffer)))))))

(ert-deftest taskspaces-test-slug ()
  "Task titles become usable branch-name slugs."
  (should (equal "upgrade-controller-api"
                 (taskspaces--slug "Upgrade Controller API")))
  (should (equal "" (taskspaces--slug "---"))))

(ert-deftest taskspaces-test-worktree-path-mirrors-checkout ()
  "Task worktree paths mirror checkout paths below the task ID."
  (let ((taskspaces-checkout-directory "/tmp/checkouts/")
        (taskspaces-taskspace-directory "/tmp/taskspaces/"))
    (should (equal "/tmp/taskspaces/test-id/team/repo/"
                   (taskspaces--worktree-path
                    "test-id" "/tmp/checkouts/team/repo")))))

(ert-deftest taskspaces-test-no-task-switch-project-uses-checkout ()
  "Switching projects with no active task forwards the regular checkout."
  (let ((taskspaces-active nil)
        (taskspaces-taskspace-directory "/tmp/taskspaces/")
        switched-to)
    (cl-letf (((symbol-function 'project-known-project-roots)
               (lambda () '("~/Work/team/repo")))
              ((symbol-function 'project-switch-project)
               (lambda (directory)
                 (setq switched-to directory))))
      (taskspaces-switch-project "~/Work/team/repo")
      (should (equal (expand-file-name "~/Work/team/repo/")
                     switched-to)))))

(ert-deftest taskspaces-test-task-records-from-one-org-file ()
  "A work-tagged ID TODO is discovered from the regular task file."
  (let* ((directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-file (expand-file-name "tasks.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file taskspaces-task-file
            (insert "#+title: Work Tasks\n"
                    "#+filetags: :work:\n"
                    "* Tasks\n"
                    "** TODO Upgrade Controller API\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":ISSUE: ABC-123\n"
                    ":END:\n"))
          (let ((records (taskspaces--active-task-records)))
            (should (= 1 (length records)))
            (should (equal "test-id"
                           (plist-get (car records) :id)))
            (should (equal "ABC-123"
                           (plist-get (car records) :issue)))
            (should (equal "TODO"
                           (plist-get (car records) :state)))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-switcher-excludes-done-and-personal-tasks ()
  "Switcher discovery includes only TODO/WAIT work tasks with IDs."
  (let* ((org-todo-keywords
          '((sequence "TODO(t)" "WAIT(w!)" "|" "DONE(d!)")))
         (directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-file (expand-file-name "tasks.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file taskspaces-task-file
            (insert "#+title: Work Tasks\n"
                    "* Tasks\n"
                    "** TODO Ready task :work:\n"
                    ":PROPERTIES:\n"
                    ":ID: ready-id\n"
                    ":END:\n"
                    "** WAIT Blocked task :work:\n"
                    ":PROPERTIES:\n"
                    ":ID: blocked-id\n"
                    ":BLOCKER: Waiting for review\n"
                    ":END:\n"
                    "** DONE Finished task :work:\n"
                    ":PROPERTIES:\n"
                    ":ID: done-id\n"
                    ":END:\n"
                    "* Personal\n"
                    "** TODO Personal task\n"
                    ":PROPERTIES:\n"
                    ":ID: personal-id\n"
                    ":END:\n"))
          (let ((ids (mapcar (lambda (record) (plist-get record :id))
                             (taskspaces--active-task-records))))
            (should (member "ready-id" ids))
            (should (member "blocked-id" ids))
            (should (member "done-id" ids))
            (should-not (member "personal-id" ids))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-task-record-by-id ()
  "Stable IDs resolve only in the active task file."
  (let* ((directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-file (expand-file-name "tasks.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file taskspaces-task-file
            (insert "#+title: Work Tasks\n"
                    "#+filetags: :work:\n"
                    "* Tasks\n"
                    "** TODO Upgrade Controller API\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":ISSUE: ABC-123\n"
                    ":END:\n"))
          (org-id-add-location "test-id" taskspaces-task-file)
          (let ((record (taskspaces--task-record-by-id "test-id")))
            (should record)
            (should (equal "ABC-123" (plist-get record :issue)))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-goto-done-task ()
  "Archiving can locate a DONE task by stable ID."
  (let* ((org-todo-keywords
          '((sequence "TODO(t)" "WAIT(w!)" "|" "DONE(d!)")))
         (directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-file (expand-file-name "tasks.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file taskspaces-task-file
            (insert "#+title: Work Tasks\n"
                    "#+filetags: :work:\n"
                    "* Tasks\n"
                    "** DONE Finished task\n"
                    ":PROPERTIES:\n"
                    ":ID: done-id\n"
                    ":END:\n"))
          (org-id-add-location "done-id" taskspaces-task-file)
          (taskspaces--goto-task-id "done-id")
          (should (equal "Finished task"
                         (org-get-heading t t t t))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-clocked-task-record-requires-valid-work-task ()
  "The running clock activates only recognized work TODO headings."
  (let* ((directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-file (expand-file-name "tasks.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file taskspaces-task-file
            (insert "#+title: Work Tasks\n"
                    "#+filetags: :work:\n"
                    "* Tasks\n"
                    "** TODO Work task\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":END:\n"))
          (with-current-buffer (find-file-noselect taskspaces-task-file)
            (goto-char (point-min))
            (re-search-forward "test-id")
            (org-back-to-heading t)
            (let* ((position (point-marker))
                   (org-clock-hd-marker position)
                   (org-clock-marker position))
              (should (equal "test-id"
                             (plist-get
                              (taskspaces--clocked-task-record)
                              :id))))))
      (delete-directory directory t))))

(ert-deftest taskspaces-test-clocked-personal-task-is-not-active ()
  "A running clock outside the task file has no taskspace."
  (let* ((task-file (make-temp-file "taskspaces-task-" nil ".org"))
         (personal-file (make-temp-file "taskspaces-personal-" nil ".org"))
         (taskspaces-task-file task-file))
    (unwind-protect
        (progn
          (with-temp-file task-file
            (insert "#+filetags: :work:\n"
                    "* Tasks\n"
                    "** TODO Work task\n"
                    ":PROPERTIES:\n"
                    ":ID: test-id\n"
                    ":END:\n"))
          (with-temp-file personal-file
            (insert "* TODO Personal task\n"))
          (with-current-buffer (find-file-noselect personal-file)
            (goto-char (point-min))
            (let* ((position (point-marker))
                   (org-clock-hd-marker position)
                   (org-clock-marker position))
              (should-not (taskspaces--clocked-task-record)))))
      (delete-file task-file)
      (delete-file personal-file))))

(ert-deftest taskspaces-test-candidate-label ()
  "Switcher labels include issue, hierarchy, state, and blocker."
  (let ((record (list :id "test-id"
                      :issue "ABC-123"
                      :title "Upgrade API"
                      :state "WAIT"
                      :blocker "Waiting for review"
                      :outline-path '("Tasks" "Upgrade API"))))
    (should (string-match-p "ABC-123"
                            (taskspaces--candidate-label record)))
    (should (string-match-p "\\[WAIT\\]"
                            (taskspaces--candidate-label record)))
    (should (string-match-p "Waiting for review"
                            (taskspaces--candidate-label record)))))

(ert-deftest taskspaces-test-cleanup-destroys-taskspace-for-absent-id ()
  "Cleanup tears down a live taskspace when its ID leaves the task file."
  (let* ((directory (make-temp-file "taskspaces-root-" t))
         (task-file (make-temp-file "taskspaces-" nil ".org"))
         (taskspaces-taskspace-directory (file-name-as-directory directory))
         (taskspaces-task-file task-file)
         (taskspaces-active nil)
         (taskspaces--layouts (make-hash-table :test #'equal))
         (task-dir (expand-file-name "missing-id" directory)))
    (unwind-protect
        (progn
          (make-directory task-dir t)
          (with-temp-file task-file
            (insert "#+title: Work Tasks\n"
                    "#+filetags: :work:\n"
                    "* Tasks\n"))
          (cl-letf (((symbol-function 'taskspaces--clocked-task-record)
                     (lambda () nil)))
            (taskspaces--cleanup-taskspaces)
            (should-not (file-directory-p task-dir))))
      (delete-directory directory t)
      (delete-file task-file))))

(ert-deftest taskspaces-test-capture-templates-use-stable-id ()
  "Capture templates create work TODOs with generated Org IDs."
  (let ((templates (with-eval-after-load 'org-capture
                     org-capture-templates)))
    (should (seq-find
             (lambda (template)
               (and (equal "w" (car template))
                    (string-match-p ":ID: %(org-id-new)"
                                    (nth 4 template))))
             templates))
    (should (seq-find
             (lambda (template)
               (and (equal "c" (car template))
                    (string-match-p ":ID: %(org-id-new)"
                                    (nth 4 template))))
             templates))))

(ert-deftest taskspaces-test-child-capture-target ()
  "Child capture positions at the selected parent heading."
  (let* ((directory (make-temp-file "taskspaces-" t))
         (taskspaces-task-file (expand-file-name "tasks.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file taskspaces-task-file
            (insert "#+title: Work Tasks\n"
                    "#+filetags: :work:\n"
                    "* Tasks\n"
                    "** TODO Parent task\n"
                    ":PROPERTIES:\n"
                    ":ID: parent-id\n"
                    ":END:\n"))
          (org-id-add-location "parent-id" taskspaces-task-file)
          (cl-letf (((symbol-function 'org-capture-get)
                     (lambda (property &optional _)
                       (if (eq property :taskspaces-parent-id)
                           "parent-id"
                         nil))))
            (with-current-buffer (find-file-noselect taskspaces-task-file)
              (taskspaces--goto-capture-parent)
              (should (org-at-heading-p))
              (should (equal "Parent task"
                             (org-get-heading t t t t))))))
      (delete-directory directory t))))

(provide 'taskspaces-tests)
;;; taskspaces-tests.el ends here
