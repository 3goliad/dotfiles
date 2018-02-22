(define-module (local-packages solano)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system ruby)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages ruby))

(define-public ruby-solano
  (package
   (name "ruby-solano")
   (version "1.31.7")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "solano" version))
     (sha256
      (base32
       "0hh0dnxpax9ai94dc8wqr3dc8mr3l79yy3znkmjdq5jm8m2h8b1y"))))
   (build-system ruby-build-system)
   (arguments
    '(#:phases (modify-phases %standard-phases (delete 'check))))
   (propagated-inputs
    `(("ruby-addressable" ,ruby-addressable)
      ("ruby-highline" ,ruby-highline)
      ("ruby-json" ,ruby-json)
      ("ruby-launchy" ,ruby-launchy)
      ("ruby-nayutaya-msgpack-pure"
       ,ruby-nayutaya-msgpack-pure)
      ("ruby-public-suffix" ,ruby-public-suffix)
      ("ruby-tddium-client" ,ruby-tddium-client)
      ("ruby-thor" ,ruby-thor)))
   (synopsis
    "Solano CI runs your test suite simply and quickly in our managed
      cloud environment.  You can run tests by hand, or enable our hosted CI to watch
      your git repos automatically.

      Solano CI automatically and safely parallelizes your tests to save you time, and
      takes care of setting up fresh isolated DB instances for each test thread.

      Tests have access to a wide variety of databases (postgres, mongo, redis,
                                                                  mysql, memcache), solr, sphinx, selenium/webdriver browsers, webkit and culerity.

      Solano CI supports all common Ruby test frameworks, including rspec, cucumber,
      test::unit, and spinach.  Solano CI also supports Javascript testing using
      jasmine, evergreen, and many other frameworks.
      ")
   (description
    "Solano CI runs your test suite simply and quickly in our managed
        cloud environment.  You can run tests by hand, or enable our hosted CI to watch
        your git repos automatically.

        Solano CI automatically and safely parallelizes your tests to save you time, and
        takes care of setting up fresh isolated DB instances for each test thread.

        Tests have access to a wide variety of databases (postgres, mongo, redis,
                                                                    mysql, memcache), solr, sphinx, selenium/webdriver browsers, webkit and culerity.

        Solano CI supports all common Ruby test frameworks, including rspec, cucumber,
        test::unit, and spinach.  Solano CI also supports Javascript testing using
        jasmine, evergreen, and many other frameworks.
        ")
   (home-page
    "https://github.com/solanolabs/solano.git")
   (license license:expat)))

(define-public ruby-json-1.8
  (package
   (name "ruby-json-1.8")
   (version "1.8.3")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "json" version))
     (sha256
      (base32
       "1nsby6ry8l9xg3yw4adlhk2pnc7i0h0rznvcss4vk3v74qg0k8lc"))))
   (build-system ruby-build-system)
   (arguments '(#:tests? #f))
   (synopsis
    "This is a JSON implementation as a Ruby extension in C.")
   (description
    "This is a JSON implementation as a Ruby extension in C.")
   (home-page "http://json-jruby.rubyforge.org/")
   (license #f)))

(define-public ruby-addressable 
  (package
   (name "ruby-addressable")
   (version "2.5.2")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "addressable" version))
     (sha256
      (base32
       "0viqszpkggqi8hq87pqp0xykhvz60g99nwmkwsb0v45kc2liwxvk"))))
   (build-system ruby-build-system)
   (arguments
    '(#:phases (modify-phases %standard-phases (delete 'check))))
   (propagated-inputs
    `(("ruby-public-suffix" ,ruby-public-suffix)))
   (synopsis
    "Addressable is a replacement for the URI implementation that is part of
Ruby's standard library. It more closely conforms to the relevant RFCs and
adds support for IRIs and URI templates.
")
   (description
    "Addressable is a replacement for the URI implementation that is part of
Ruby's standard library.  It more closely conforms to the relevant RFCs and
adds support for IRIs and URI templates.
")
   (home-page
    "https://github.com/sporkmonger/addressable")
   (license #f)))

(define-public ruby-launchy 
  (package
   (name "ruby-launchy")
   (version "2.4.3")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "launchy" version))
     (sha256
      (base32
       "190lfbiy1vwxhbgn4nl4dcbzxvm049jwc158r2x7kq3g5khjrxa2"))))
   (build-system ruby-build-system)
   (arguments
    '(#:phases (modify-phases %standard-phases (delete 'check))))
   (propagated-inputs
    `(("ruby-addressable" ,ruby-addressable)))
   (synopsis
    "Launchy is helper class for launching cross-platform applications in a fire and forget manner. There are application concepts (browser, email client, etc) that are common across all platforms, and they may be launched differently on each platform. Launchy is here to make a common approach to launching external application from within ruby programs.")
   (description
    "Launchy is helper class for launching cross-platform applications in a fire and forget manner.  There are application concepts (browser, email client, etc) that are common across all platforms, and they may be launched differently on each platform.  Launchy is here to make a common approach to launching external application from within ruby programs.")
   (home-page
    "http://github.com/copiousfreetime/launchy")
   (license #f)))

(define-public ruby-nayutaya-msgpack-pure 
  (package
   (name "ruby-nayutaya-msgpack-pure")
   (version "0.0.2")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "nayutaya-msgpack-pure" version))
     (sha256
      (base32
       "0863rhmmsm18r4iz1y7hz0i3zx6vlvffr8rc185npcip889470ja"))))
   (build-system ruby-build-system)
   (arguments
    '(#:phases (modify-phases %standard-phases (delete 'check))))
   (synopsis
    "pure ruby implementation of MessagePack")
   (description
    "pure ruby implementation of MessagePack")
   (home-page
    "http://github.com/nayutaya/msgpack-pure/")
   (license #f)))

(define-public ruby-public-suffix 
  (package
   (name "ruby-public-suffix")
   (version "3.0.2")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "public_suffix" version))
     (sha256
      (base32
       "1x5h1dh1i3gwc01jbg01rly2g6a1qwhynb1s8a30ic507z1nh09s"))))
   (build-system ruby-build-system)
   (arguments
    '(#:phases (modify-phases %standard-phases (delete 'check))))
   (synopsis
    "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains.")
   (description
    "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains.")
   (home-page
    "https://simonecarletti.com/code/publicsuffix-ruby")
   (license license:expat)))

(define-public ruby-tddium-client 
  (package
   (name "ruby-tddium-client")
   (version "0.6.4")
   (source
    (origin
     (method url-fetch)
     (uri (rubygems-uri "tddium_client" version))
     (sha256
      (base32
       "12d6znwzskl0f24idcxfw6xp362h75kkcbxinjf1ffsncmraxp5l"))))
   (build-system ruby-build-system)
   (arguments
    '(#:phases (modify-phases %standard-phases (delete 'check))))
   (propagated-inputs
    `(("ruby-httpclient" ,ruby-httpclient)
      ("ruby-json" ,ruby-json)))
   (synopsis
    "Internal Gem used to call the Tddium API")
   (description
    "Internal Gem used to call the Tddium API")
   (home-page "https://www.solanolabs.com/")
   (license #f)))
