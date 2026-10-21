# TODO

- verify system integrity on boot

# Theme packages

- `NsCDE-icon-theme`

# Custom certs
Shell profiles will need to export application-specific environment variables so that everything picks up system-specific SSL certificates. To facilitate this, I've decided to use the XDG directories to store the certificate files and bundle.

Any custom certificates need to be in the following locations:
- `~/.local/etc/ssl/cert.pem` (bundle)
- `~/.local/etc/ssl/certs/` (directory)

Additionally, custom certificates must also be renamed to `.crt` and placed in the Docker certificate directory (`~/.docker/certs.d/`). Colima takes care of copying them into the VM.
