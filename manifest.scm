(use-modules (guix config)
             (guix packages)
             (guix store)
             (guix grafts)
             (guix profiles)
             (gnu packages))

(define system-packages '("glibc-utf8-locales"
                          "nss-certs"
                          "guile"
                          "guix"))

(define monitor-tools '("htop"))

(define develop-tools '("emacs"))

(packages->manifest
 (map (compose list specification->package+output)
      (append system-packages
              monitor-tools
              develop-tools)))
