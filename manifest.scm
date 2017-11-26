(use-modules (guix config)
             (guix packages)
             (guix store)
             (guix grafts)
             (guix profiles)
             (gnu packages)
             (fonts))

(define system '("glibc-utf8-locales"
                 "nss-certs"
                 "guile"
                 "guix"
                 "unzip"
                 "tomb"))

(define monitor '("htop"))

(define develop '("emacs"))

(define fonts '("gucharmap"
                "font-fantasque-sans"
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
