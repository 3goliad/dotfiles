# Copilot Instructions

This is a [chezmoi](https://www.chezmoi.io/) source directory (`~/.local/share/chezmoi`) for personal dotfiles (macOS + Fedora/Linux). There is no build/test/lint suite; validate with chezmoi itself.

## Commands

- `chezmoi diff` — preview what would change in `$HOME`
- `chezmoi apply -v` (or `chezmoi apply ~/.config/nvim`) — apply all / a single target
- `chezmoi execute-template < file.tmpl` — render a `.tmpl` to check it
- `chezmoi doctor` / `chezmoi managed` / `chezmoi unmanaged` — inspect state
- Lua formatting for nvim config: `stylua` (config in `private_dot_config/nvim/.stylua.toml`: 2-space indent, 80 cols)

## Architecture

- **Source-state naming** drives targets: `dot_` → `.`, `private_` → mode 0700/0600, `executable_` → +x, `symlink_` → file whose contents are the symlink target, `.tmpl` → Go template, `run_onchange_` → script re-run when its rendered content changes. E.g. `private_dot_config/nvim/` → `~/.config/nvim/`.
- **Templates** use `.chezmoi.os` / `.chezmoi.osRelease.id` for OS-specific logic, `.work` (prompted once via `.chezmoi.toml.tmpl`; set with `chezmoi init`) for work-machine-only config (Gartner email, Artifactory), and `.chezmoi.sourceDir` for paths into this repo.
- **Package lists** live in `.chezmoidata/packages.toml` (e.g. `.packages.fedora`) and are consumed by `run_onchange_fedora-install-packages.sh.tmpl`, which runs `sudo dnf install` only on Fedora. Editing the list re-triggers the script.
- **Live-editable config via symlinks**: some files are intentionally symlinked back into the source dir so the app can write to them (nvim `nvim-pack-lock.json`, mise `config.toml` → `mise-config.toml` and (work only, via `.work`) `conf.d/work.toml` → `mise-work.toml`, emacs `custom.el` → `customizations.el`, pi `models.json`/`settings.json`). The real files in the source dir are named differently (`nvim-pack-lock.json`, `mise-config.toml`, `customizations.el`, `pi-*.json`) and are listed in the corresponding `.chezmoiignore` so chezmoi doesn't also deploy them as regular files. When adding a similar file, add both the `symlink_*.tmpl` and the `.chezmoiignore` entry.
- **Shell env** (`PATH`, `EDITOR`, etc.) in `dot_profile.tmpl` is mirrored in two other places: `dot_zshenv` and `private_dot_config/environment.d/10-dot_profile.conf` (systemd user env). Keep all three in sync. `mise` is activated from `dot_zshrc`.
- **Neovim** (`private_dot_config/nvim`): `init.lua` loads `lua/config/*` modules and uses the built-in `vim.pack.add` (plugin versions pinned in `nvim-pack-lock.json`); LSP configs under `lsp/`, per-filetype overrides under `after/ftplugin/`.
- **Emacs** (`private_dot_config/emacs`): `init.el` plus modules in `lisp/`; `customizations.el` is the Customize output file.
- **Emacs startup directory**: This machine uses `~/.config/emacs`; never create or modify `~/.emacs.d`. Even an empty `.emacs.d` directory causes Emacs to ignore `~/.config/emacs/init.el`. Run Emacs package operations or set `package-user-dir` only under `~/.config/emacs/elpa`.
- **Emacs packages**: Never install, refresh, update, or remove packages manually with `package-install`, `package-refresh-contents`, or the package manager. Package installation belongs exclusively in `use-package` declarations in `init.el`/`lisp/`; do not replace or work around a package requirement outside that mechanism.
- Linux-desktop configs (sway, waybar, dunst, fuzzel, ghostty) and macOS-oriented ones (colima) coexist; the root `.chezmoiignore` excludes repo-only files (`README.md`, `.github`, `personal`, `nvim-pack-lock.json`) from deployment — add new repo-only files there.

## Conventions

- Custom CA certificates: shell profiles expect the bundle at `~/.local/etc/ssl/cert.pem` and certs in `~/.local/etc/ssl/certs/`; for Docker/Colima, `.crt` copies go in `~/.docker/certs.d/` (see `README.md`). `private_dot_local/bin/executable_macos-dump-certificates` helps generate these.
- Personal scripts go in `private_dot_local/bin/` as `executable_*` (installed to `~/.local/bin`, which is first on `PATH`).
- `.editorconfig` is deployed to `$HOME`; follow it when editing.
