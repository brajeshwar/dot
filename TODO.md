# TODO

Last updated: 2026-05-17

---

## Completed — Initial Cleanup (2026-03-15)

- [x] Consolidate PATH into `env/paths.sh` as the single source of truth
- [x] Remove all PATH duplication across `.zshenv`, `.zprofile`, `.zshrc`
- [x] Move LM Studio and Obsidian PATH out of `.zshrc` → into `paths.sh`
- [x] Remove `TERM=xterm-256color` override — Ghostty sets its own terminfo
- [x] Rename `env/env.sh` → `env/paths.sh`; update bootstrap.sh and shell files
- [x] Remove deprecated Homebrew flags from `brew.sh`
- [x] Update `osascript` to quit "System Settings" (was "System Preferences")
- [x] Remove `pmset -a sms 0` — irrelevant on SSD Macs
- [x] Remove `QLEnableTextSelection` — deprecated since Mojave
- [x] Switch `insteadOf` → `pushInsteadOf` in gitconfig
- [x] Fix `id_ed25519_laaija` key naming in `ssh/config`
- [x] Deduplicate vimrc directives (`syntax`, `cursorline`, font)
- [x] Raise Ghostty `scrollback-limit` to 10000

---

## Completed — Public Safety & Local Overrides (2026-05-16)

- [x] Move personal SSH host (`github-brajeshwar`) to `~/.ssh/config.local`
- [x] Add `Include ~/.ssh/config.local` to `ssh/config`
- [x] Rename `github-wipro` → `github-job94776`, key to `id_ed25519_job94776`
- [x] Create `ssh/config.local.example` documenting per-device key convention
- [x] Add `[include]` and `[includeIf]` hooks to `git/gitconfig` for local identity
- [x] Create `git/gitconfig.local.example`
- [x] Add `~/.zshrc.local` hook to `zsh/zshrc`; remove openclaw-dench
- [x] Generalize `HOME` fallback in `zsh/zshenv`
- [x] Remove personal byline from `vim/vimrc`
- [x] Generalize screenshots folder path in `macos/defaults.sh`
- [x] Add `*.local`, `id_*`, `*_rsa`, `*_ed25519` to `git/gitignore_global`
- [x] Update `test.sh` assertions for new SSH layout
- [x] Update `README.md` with local override docs and key naming convention
- [x] Add `Device Setup.md` for new work machine onboarding
- [x] Remove laaija SSH identity (moved offline)
- [x] Replace 1Password SSH agent comment with Bitwarden (`~/.bitwarden-ssh-agent.sock`)

---

## Completed — CI & Cleanup (2026-05-17)

- [x] Add CI check (GitHub Actions) to run `sh test.sh` on push
- [x] Add a LICENSE file (MIT or 0BSD)
- [x] Remove `zed/` folder — let users manage their own editor settings
- [x] Fix `test.sh`: remove stale laaija/zed assertions; guard symlink checks for CI

---

## Open

- [ ] Consider a `zed/settings.json.example` if teammates ask for a starting point