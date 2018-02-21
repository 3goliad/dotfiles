(define-module (local-packages fonts)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix derivations)
  #:use-module (guix download)
  #:use-module (guix build-system font)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages node)
  #:use-module (gnu packages compression))

(define-public font-overpass
  (package
    (name "font-overpass")
    (version "3.0.2")
    (source
     (origin
       (method url-fetch/zipbomb)
       (uri (string-append "https://github.com/RedHatBrand/Overpass/releases/"
                           "download/" version "/overpass-desktop-fonts.zip"))
       (sha256
        (base32
         "1r34pf4nsqj11lckb306l0s8whqnvsxs0kif5w92irp1s5m1ilhh"))))
    (build-system font-build-system)

    (home-page "http://overpassfont.org")
    (synopsis
     "An open source font family inspired by Highway Gothic.")
    (description
     "Overpass is a bespoke typeface designed by Delve Fonts between
2011–2016 on commission from Red Hat, Inc. with direction provided by Andy
Fitzsimon, Jakub Steiner, and Ben Dubrovsky.

The design of Overpass is an interpretation of the rather well-known
“Highway Gothic” letterforms from the Standard Alphabets for Traffic Control
Devices published by the U.S. Federal Highway Administration. Starting from those
specifications, critical adjustments were made to the letterforms to create an
optimal presentation at smaller sizes on-screen and later for display sizes —
especially in the lighter weights.

The initial delivery in 2011 was limited to the Regular and Bold upright
weights intended for use primarily in the user interfaces of the Red Hat’s
various linux-based software titles and internal websites. The initial character
set of Overpass is comprised of over 430 glyphs covering dozens of Latin
alphabet based languages.

To increase the versatility and utility of Overpass,six more weights were added
during 2014–2016 , ranging from Extra Light to Heavy,with Italic counterparts
for all eight weights. New Monospace variants of Overpass in four weights were
also created in 2016, to provide a version of Overpass specially tuned for
programming requirements .

Red Hat has generously made the Overpass family freely available to the public
under the SIL Open Font License and The GNU Lesser General Public
License (LGPL).")
    (license (list license:silofl1.1 license:lgpl2.1))))

(define-public font-iosevka
  (package
    (name "font-iosevka")
    (version "1.14.0")
    (source (origin
              (method url-fetch/zipbomb)
              (uri (string-append "https://github.com/be5invis/Iosevka/releases"
                                  "/download/v" version "/06-iosevka-term-slab-"
                                  version ".zip"))
              (sha256
               (base32 "0h2dihg9j72djxwhb7w4wd1r0sgkvp4zripz4qlqin5v5m79j227"))))
    (build-system font-build-system)

    (home-page "https://be5invis.github.io/Iosevka/")
    (synopsis "Coders' typeface, built from code")
    (description
     "Iosevka is a slender monospace sans-serif or slab-serif typeface inspired
by Pragmata Pro, M+, and PF DIN Mono, designed to be the ideal font for
programming.  Iosevka is completely generated from its source code.")
    (license (list license:silofl1.1 ; build artifacts (i.e. the fonts)
                   license:bsd-3))))
