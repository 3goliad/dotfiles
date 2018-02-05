(define-module (local-packages kubernetes)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public kubectl
  (package
   (name "kubectl")
   (version "v1.9.2")
   (source
    (origin
     (method url-fetch/tarbomb)
     (uri (string-append "https://dl.k8s.io/" version
                         "/kubernetes-client-linux-amd64.tar.gz"))
     (sha256 (base32 "0jf3z1r8yri7gmci9w07f276zv0z4xb6iy16dpy1p7bvsblzjp64"))))
   (build-system trivial-build-system)
   (arguments
    '(#:modules ((guix build utils))
      #:builder
      (begin
        (use-modules (guix build utils))
        (let ((source (assoc-ref %build-inputs "source"))
              (out (string-append %output "/bin")))
          (mkdir-p out)
          (copy-file (string-append source "/kubernetes/client/bin/kubectl")
                     (string-append out "/kubectl"))))))
   (home-page "https://github.com/kubernetes/kubernetes")
   (synopsis "controls the Kubernetes cluster manager")
   (description "Kubernetes is an open source system for managing containerized
applications across multiple hosts, providing basic mechanisms for deployment,
maintenance, and scaling of applications.")
   (license license:asl2.0)))

(define-public docker-machine-driver-kvm2
  (package
   (name "docker-machine-driver-kvm2")
   (version "v0.25.0")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://storage.googleapis.com/minikube/releases/"
                         version "/" name))
     (sha256 (base32 "12fi044cqfaqz3sl9b00avlrgai8gvn3arvr813b5ynxx1lr5k1h"))))
   (build-system trivial-build-system)
   (arguments
    '(#:modules ((guix build utils))
      #:builder
      (begin
        (use-modules (guix build utils))
        (let ((output-binary (string-append %output "/bin/docker-machine-driver-kvm2") ))
          (mkdir-p (dirname output-binary))
          (copy-file (assoc-ref %build-inputs "source") output-binary)
          (chmod output-binary #o755)))))
   (home-page "https://github.com/kubernetes/minikube")
   (synopsis "KVM driver for docker-machine")
   (description "KVM driver for docker-machine")
   (license license:asl2.0)))

(define-public minikube
  (package
   (name "minikube")
   (version "v0.25.0")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://storage.googleapis.com/minikube/releases/"
                         version "/minikube-linux-amd64"))
     (sha256 (base32 "1h83b067lrjmna65wwgrazb7cs81lghwfmlxz6f6y73zygag4xjn"))))
   (build-system trivial-build-system)
   (arguments
    '(#:modules ((guix build utils))
      #:builder
      (begin
        (use-modules (guix build utils))
        (let ((output-binary (string-append %output "/bin/minikube") ))
          (mkdir-p (dirname output-binary))
          (copy-file (assoc-ref %build-inputs "source") output-binary)
          (chmod output-binary #o755)))))
   (home-page "https://github.com/kubernetes/minikube")
   (synopsis "run Kubernetes locally")
   (description "Minikube runs a single-node Kubernetes cluster inside a VM on
your laptop for users looking to try out Kubernetes or develop with it
day-to-day.")
   (license license:asl2.0)))
