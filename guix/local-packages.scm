(define-module (local-packages))

;; The composite module that re-exports everything from the public modules.

(eval-when (eval load compile)
  (begin
    (define %public-modules
      '(fonts
        tools))

    (for-each (let ((i (module-public-interface (current-module))))
                (lambda (m)
                  (module-use! i (resolve-interface `(local-packages ,m)))))
              %public-modules)))
