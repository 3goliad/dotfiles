(use-modules (guix config)
             (guix packages)
             (guix store)
             (guix grafts)
             (guix profiles)
             (gnu packages))

(define system '("glibc-utf8-locales"
                 "nss-certs"
                 "guile"
                 "guix"))

(define monitor '("htop"))

(define develop '("emacs"))

(define fonts '("gucharmap"
                "font-fantasque-sans"))

(define media '("mpv"
                "rtorrent"
                "evince"))

(define gui '("dmenu"))

(packages->manifest
 (map (compose list specification->package+output)
      (append system
              monitor
              develop
              fonts
              media
              gui)))
