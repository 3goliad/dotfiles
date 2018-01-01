(use-modules (guix config)
             (guix packages)
             (guix store)
             (guix grafts)
             (guix profiles)
             (gnu packages)
             (local-packages fonts)
             (local-packages tools))

(define system '("glibc-utf8-locales"
                 "nss-certs"
                 "guile"
                 "guix"
                 "unzip"
                 "tomb"
                 "jq"
                 "minikube"
                 "docker-machine-driver-kvm2"
                 "kubectl"))

(define monitor '("htop"))

(define develop '("emacs"))

(define fonts '("font-fantasque-sans"
                "font-overpass"
                "font-liberation"))

(define media '("mpv"
                "rtorrent"
                "evince"
                "youtube-dl"))

(define gui '("dmenu"))

(packages->manifest
 (map (compose list specification->package+output)
      (append system
              monitor
              develop
              fonts
              media
              gui)))
