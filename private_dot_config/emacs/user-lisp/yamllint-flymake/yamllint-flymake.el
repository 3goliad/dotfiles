;;; yamllint-flymake.el --- Flymake backend for yamllint -*- lexical-binding: t; -*-

;; Package-Requires: ((emacs "31.1"))
;; Keywords: tools, yaml, flymake
;; Version: 0.1

;;; Commentary:

;; A Flymake backend that lints YAML buffers with yamllint.  Enable it
;; locally with:
;;
;;   (add-hook 'flymake-diagnostic-functions #'yamllint-flymake-backend nil t)

;;; Code:

(require 'flymake)
(require 'rx)

(defvar-local yamllint-flymake--process nil
  "The currently running yamllint process, if any.")

(defun yamllint-flymake--parse-output (source proc report-fn)
  "Parse yamllint output of PROC for SOURCE and call REPORT-FN with diagnostics."
  (with-current-buffer (process-buffer proc)
    (goto-char (point-min))
    (let ((pattern (rx bol (1+ (not ":")) ":" ; filename (always "stdin")
                       (group (1+ digit)) ":" ; line
                       (group (1+ digit)) ":" ; column
                       (1+ blank) "[" (group (1+ alpha)) "]"; type
                       (1+ blank) (group (1+ nonl)) ; message
                       eol))
          diags)
      (while (search-forward-regexp pattern nil t)
        (let* ((diag-region (flymake-diag-region
                             source
                             (string-to-number (match-string 1))
                             (string-to-number (match-string 2))))
               (beg (car diag-region))
               (end (cdr diag-region))
               (type (if (string= (match-string 3) "warning")
                         :warning
                       :error))
               (message (match-string 4)))
          (push (flymake-make-diagnostic source beg end type message)
                diags)))
      (funcall report-fn diags))))

;;;###autoload
(defun yamllint-flymake-backend (report-fn &rest _args)
  "Flymake backend for yamllint.  REPORT-FN is the Flymake report callback."

  (let ((yamllint (executable-find "yamllint"))
        (params '("-f" "parsable" "-"))
        (source (current-buffer)))
    (when (not yamllint)
      (error "Unable to find yamllint command"))

    (when (process-live-p yamllint-flymake--process)
      (flymake-log :debug "Killing earlier yamllint process %s"
                   yamllint-flymake--process)
      (kill-process yamllint-flymake--process))

    (save-restriction
      (widen)
      (setq
       yamllint-flymake--process
       (make-process
        :name "yamllint-flymake"
        :noquery t
        :connection-type 'pipe
        :buffer (generate-new-buffer " *yamllint-flymake*")
        :command `(,yamllint ,@params)
        :sentinel
        (lambda (proc _event)
          (when (and (eq 'exit (process-status proc)) (buffer-live-p source))
            (unwind-protect
                (if (with-current-buffer source
                      (eq proc yamllint-flymake--process))
                    (yamllint-flymake--parse-output source proc report-fn)
                  (flymake-log :debug "Canceling obsolete check %s" proc))
              (kill-buffer (process-buffer proc)))))))
      (process-send-region yamllint-flymake--process (point-min) (point-max))
      (process-send-eof yamllint-flymake--process))))

(provide 'yamllint-flymake)
;;; yamllint-flymake.el ends here
