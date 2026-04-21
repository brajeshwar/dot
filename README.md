# .

https://github.com/brajeshwar/dot

A minimal, layered shell environment — predictable, portable, and resistant to vendor tooling injecting itself into shell config files.

## Bootstrap

```sh
chmod +x bootstrap.sh
./bootstrap.sh
```

Creates all required symlinks in `$HOME`. Safe to re-run — existing non-symlink files are skipped, existing symlinks are updated.

## How it's layered

```
.zshenv   → always loaded (interactive, non-interactive, scripts, CI)
.paths    → login shells only (sourced by .zprofile and .bash_profile)
.zshrc    → interactive shells only (prompt, completions, behavior)
.zprofile → login shell init (Homebrew, sources .paths, lazy nvm)
```

**`.zshenv`** sets the minimal PATH needed everywhere: `~/.local/bin` (pipx tools) and `~/_root/tools` (personal scripts). Nothing else. No Homebrew, no runtimes, no shell behavior. This is why vendor tools don't need to touch your shell config — the PATH is already correct.

**`.paths`** (symlinked from `env/paths.sh`) adds login-shell runtimes: bun, deno, Python user base, LM Studio, and any other vendor tooling. POSIX-safe, no shell-specific logic. `~/.local/bin` and `~/_root/tools` are intentionally absent here — they live in `.zshenv` to be available everywhere, not just login shells.

**`.zshrc`** contains no PATH logic. Prompt, shell options, history, completions only.

**`.zprofile`** initializes Homebrew, sources `~/.paths`, and eagerly loads nvm.

## Notes

**pipx** — installed via Homebrew; tools land in `~/.local/bin` which is in `.zshenv`. Running `pipx ensurepath` should report nothing to do.

**Personal scripts** — place executables in `~/_root/tools`; available in all shell contexts including SSH and scripts.

**nvm** — loaded eagerly at login shell start so globally installed npm tools (e.g. `browser-sync`) are always on PATH without needing to invoke `node` or `npm` first.

**SSH keys** — run once per machine per key to store the passphrase in macOS Keychain (no more prompts after reboots):

```sh
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_ed25519_ONM_MBP2025
ssh-add ~/.ssh/id_ed25519_laaija
ssh-add ~/.ssh/id_ed25519_work
```

## Testing

Run after any changes to verify nothing is broken:

```sh
sh test.sh
```

Checks symlinks, PATH hygiene across all shell files, `env/paths.sh` contents, `brew.sh` flags, macOS defaults, git/ssh/vim/ghostty/zed config, and placeholder directories. A clean run:

```
======================================
  42 passed  |  0 failed
======================================
```

## Version Control

This repo is managed with [Jujutsu (jj)](https://jj-vcs.github.io/jj/latest/) in colocated mode — both `jj` and `git` work in the same repo. The typical workflow:

```sh
jj c "my comment"   # commit with message, opens new working copy
jj bm               # move main bookmark to latest commit
jj pushm            # push to origin
```

`jj bm` is always required before `jj pushm` — bookmarks don't move automatically in jj.

## References

- Awesome Dotfiles — https://project-awesome.org/webpro/awesome-dotfiles
- dotfiles on GitHub — https://dotfiles.github.io
- Chezmoi — https://www.chezmoi.io
- GNU Stow — https://www.gnu.org/software/stow/
- XDG Base Directory Specification — https://specifications.freedesktop.org/basedir/latest/
