(define-module (local-packages ctags)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages compression))

(define-public universal-ctags
  (package
    (name "universal-ctags")
    (version "4dbeb0be3a2e2f710ca8468badeba7611b79f906")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/universal-ctags/ctags.git")
                (commit version)))
              (sha256
               (base32
                "19kbf5lmxpyawic2zhnc1hy79w6ic86x6y66ybmcj334nwc5j98q"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ; no "check" target
       #:configure-flags '("--program-prefix=u")
       #:phases
       (modify-phases %standard-phases
        (add-before 'configure 'autoconf
                    (lambda _ (begin
                                (for-each (lambda (file) (chmod file #o644))
                                          (find-files "./optlib"))
                                (zero? (system* "bash" "./autogen.sh"))))))))
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)
       ("libtool" ,libtool)
       ("gettext" ,gettext-minimal)
       ("pkg-config" ,pkg-config)
       ("perl" ,perl)))
    (home-page "https://ctags.io/")
    (synopsis "A maintained ctags implementation")
    (description "universal-ctags has the objective of continuing the
development from what existed in the Sourceforge area. Github exuberant-ctags
repository was started by Reza Jelveh and was later moved to the universal-ctags
organization.

The goal of the project is preparing and maintaining common/unified working
space where people interested in making ctags better can work together.")
    (license license:gpl2)))
