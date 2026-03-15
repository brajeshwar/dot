# Dotfiles TODO

A prioritized checklist of fixes based on a critical review of the repo.

---

## 1. PATH Cleanup

- [x] Audit every file that touches `PATH`: `.zshenv`, `.zprofile`, `env.sh`, `.zshrc`, `.bash_profile`, `.bashrc`
- [x] Remove duplicate `~/.local/bin` additions (was in `.zshenv`, `env.sh`, and `.zprofile`)
- [x] Remove duplicate `~/_root/tools` additions (was in `.zshenv` and `env.sh`)
- [x] Consolidate all runtime PATH manipulation into `paths.sh` as the single source of truth

---

## 2. `.zshrc` Violations

- [x] Move LM Studio PATH addition out of `.zshrc` → into `paths.sh`
- [x] Move Obsidian PATH addition out of `.zshrc` → into `paths.sh`
- [x] Remove `TERM=xterm-256color` override — Ghostty sets its own terminfo
- [x] Fix OpenClaw completion source: use `$HOME` instead of hardcoded absolute path

---

## 3. NVM Loading Strategy

- [x] Keep lazy-load in `.zprofile`; remove eager-load from `.zshrc`
- [x] Remove duplicate `NVM_DIR` declaration from `.zprofile` (set in `.zshenv`)
- [x] Remove duplicate `PIPX_BIN_DIR`/`~/.local/bin` addition from `.zprofile`

---

## 4. `.env` File Naming Collision

- [x] Rename `env/env.sh` → `env/paths.sh` to avoid dotenv tool collisions
- [x] Update `bootstrap.sh` to symlink as `$HOME/.paths` (was `$HOME/.env`)
- [x] Fix `.zprofile` to source `$HOME/.paths` (was incorrectly sourcing `$HOME/env.sh`)
- [x] Fix `.bash_profile` to source `$HOME/.paths` (was `$HOME/.env`)

---

## 5. Homebrew Script (`brew.sh`)

- [x] Remove deprecated `--with-iri` flag from wget
- [x] Remove deprecated `--with-override-system-vi` flag from vim
- [x] Remove deprecated `--with-webp` flag from imagemagick
- [x] Remove manual `ln -s` for `sha256sum` — coreutils gnubin handles this automatically

---

## 6. macOS Defaults Script

- [x] Update `osascript` to quit "System Settings" (was "System Preferences", renamed in Ventura)
- [x] Remove `pmset -a sms 0` (Sudden Motion Sensor — irrelevant on all modern SSD Macs)
- [x] Remove `QLEnableTextSelection` — deprecated since Mojave, has no effect

---

## 7. Git Config

- [x] Remove `sign` alias — redundant since `gpgsign = true` is already set globally
- [ ] Consider reviewing `amend` and `c` aliases — both run `git add -A` implicitly
- [x] Switch `insteadOf` → `pushInsteadOf` so fetch/clone stays HTTPS, only push uses SSH

---

## 8. SSH Config

- [x] Update `IdentityFile` reference to `~/.ssh/id_ed25519_laaija` (was `~/.ssh/laaija`)
- [x] Rename the actual key file: `mv ~/.ssh/laaija ~/.ssh/id_ed25519_laaija`

---

## 9. Vimrc

- [x] Replace duplicate `syntax on` + `syntax enable` with a single `syntax enable`
- [x] Remove duplicate `set cursorline`
- [x] Collapse per-platform font conditional (all branches were identical `Monaco:h16`)
- [x] Remove empty Plugins scaffolding section

---

## 10. Ghostty Config

- [x] Raise `scrollback-limit` from 999 → 10000 lines

---

## 11. Zed Settings

- [x] Remove trailing comma after `file_scan_exclusions` array (invalid JSON)
- [ ] Confirm `always_allow_tool_actions: true` is intentional

---

## 12. Empty Directories

- [x] Add `.gitkeep` to: `claude/`, `config/`, `emacs/`, `jujutsu/`, `sublimetext/`

---
