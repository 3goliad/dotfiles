(define-module (iosevka-custom)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public font-iosevka-custom
  (package
   (name "font-iosevka-custom")
   (version "v1.13.3")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/be5invis/Iosevka.git")
                  (commit version)))
            (sha256
             (base32
              "0wfhfiahllq8ngn0mybvp29cfcm7b8ndk3fyhizd620wrj50bazf"))))
   (build-system trivial-build-system)
   (arguments
    '(#:modules ((guix build utils))
      #:builder
      (begin
        (use-modules (guix build utils))
        (let ((font-dir
               (string-append %output "/share/fonts/TTF")))
          (if
           (and
            (zero? (system* "npm" "install"))
            (zero? (system* "make" "custom-config" "design=design"))
            (zero? (system* "make" "custom")))
           (begin
             (for-each (lambda (font-file)
                         (install-file font-file font-dir))
                       (find-files "dist" "\\.ttf$"))
             (install-file
              "LICENSE.md"
              (string-append %output
                             "/share/licenses/Iosevka")))
           #f)))))
   (home-page "https://be5invis.github.io/Iosevka/")
   (synopsis "Coders' typeface, built from code")
   (description
    "Iosevka is a slender monospace sans-serif or slab-serif typeface inspired
by Pragmata Pro, M+, and PF DIN Mono, designed to be the ideal font for
programming.  Iosevka is completely generated from its source code.")
   (license (list license:silofl1.1 ; build artifacts (i.e. the fonts)
                  license:bsd-3)))) ; supporting code
