(define-module (local-packages tools)
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
   (version "v1.8.4")
   (source
    (origin
     (method url-fetch/tarbomb)
     (uri (string-append "https://dl.k8s.io/" version
                         "/kubernetes-client-linux-amd64.tar.gz"))
     (sha256 (base32 "0f8z1w1ak04i3rrff35s8zy9dd7zfg2bp58db03kczl31ng2lg2d"))))
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
   (version "v0.24.1")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://storage.googleapis.com/minikube/releases/"
                         version "/" name))
     (sha256 (base32 "04kq2s3si8gglkz8wn4mqrsjqblpsaxwy0vxhy0k2i8fp6ngxjp1"))))
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
   (version "v0.24.1")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://storage.googleapis.com/minikube/releases/"
                         version "/minikube-linux-amd64"))
     (sha256 (base32 "0vh3grx02xglmyl4qals86gydjf2ay3raia6gbpg9lbg704xwq8j"))))
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
