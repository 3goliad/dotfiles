(use-modules (guix config)
             (guix packages)
             (guix store)
             (guix grafts)
             (guix profiles)
             (gnu packages)
             (local-packages fonts)
             (local-packages ctags)
             (local-packages kubernetes)
             (local-packages tools))

(define runtimes '("guile"))

(define required '("glibc-utf8-locales"
                   "nss-certs"
                   "util-linux"
                   "guix"))

(define filesystem '("zip"
                     "unzip"))

(define kubernetes '("minikube"
                     "docker-machine-driver-kvm2"
                     "kubectl"))

(define tools '("jq"))

(define security '("tomb"))

(define monitor '("htop"))

(define develop '("emacs"
                  "universal-ctags"))

(define fonts '("font-fantasque-sans"
                "font-overpass"
                "font-liberation"
                "font-iosevka"))

(define media '("mpv"
                "rtorrent"
                "evince"
                "ghostscript"
                "youtube-dl"))

(define gui '("dmenu"
              "scrot"))

(packages->manifest
 (map (compose list specification->package+output)
      (append required
              runtimes
              filesystem
              kubernetes
              tools
              security
              monitor
              develop
              fonts
              media
              gui)))
