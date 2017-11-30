export PATH=$HOME/.guix-profile/bin:$PATH
export PATH=$HOME/.guix-profile/sbin:$PATH
export PATH=$HOME/.local/bin:$PATH

export GUIX_LOCPATH=$HOME/.guix-profile/lib/locale${GUIX_LOCPATH:+:}$GUIX_LOCPATH

export GUILE_LOAD_PATH=$HOME/.guix-profile/share/guile/site/2.2${GUILE_LOAD_PATH:+:}$GUILE_LOAD_PATH
export GUILE_LOAD_COMPILED_PATH=$HOME/.guix-profile/lib/guile/2.2/site-ccache:$HOME/.guix-profile/share/guile/site/2.2${GUILE_LOAD_COMPILED_PATH:+:}$GUILE_LOAD_COMPILED_PATH

export INFOPATH=$HOME/.guix-profile/share/info${INFOPATH:+:}$INFOPATH
export SSL_CERT_DIR="$HOME/.guix-profile/etc/ssl/certs"
export SSL_CERT_FILE="$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt"
export GUIX_PACKAGE_PATH=$HOME/p/packages
