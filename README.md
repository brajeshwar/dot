# .

https://github.com/brajeshwar/dot

A **minimal, layered shell environment** designed to be predictable, portable, and resistant to vendor tooling modifying shell configuration files.

The setup prioritizes:
- Explicit PATH management.
- POSIX-safe shared configuration.
- Correct use of Zsh startup files.
- Consistent behavior across interactive and non-interactive shells.

## Symlink

Dotfiles in this repository are expected to be symlinked into `$HOME`. Use `bootstrap.sh` for initial setup. For manual linking:

```sh
ln -sf [source] [link]
```

## Bootstrap

```sh
chmod +x bootstrap.sh
./bootstrap.sh
```

Creates all required symlinks in `$HOME`. Safe to re-run — existing non-symlink files are skipped, existing symlinks are updated.

## Shell File Responsibilities

Configuration is intentionally layered and boring.

```
.zshenv  → tools, PATH, invariants (always loaded)
.paths   → shared runtime PATH (POSIX-safe, login shells)
.zshrc   → humans and interaction (interactive only)
```

## `.zshenv`

Loaded by **all** Zsh invocations:
- interactive
- non-interactive
- login
- tool probes (pipx, CI, scripts)

Responsibilities:
- Minimal PATH setup required by tools everywhere
- Tool invariants only (`NVM_DIR`, etc.)
- Zero interactivity

Typical contents:
- `~/.local/bin` (pipx-installed tools)
- `~/_root/tools` (personal scripts)

This file exists so tools see the correct PATH immediately and do not attempt to modify shell configuration files.

No Homebrew.
No language runtimes.
No shell behavior.

## `.paths`

Symlinked from `env/paths.sh`. A shared, POSIX-compatible file for login-shell PATH additions.

Characteristics:
- No prompts, aliases, functions, or shell-specific logic
- Explicit and auditable
- Safe to source from any POSIX shell

Responsibilities:
- Language runtimes (bun, deno, Python user base)
- Vendor tooling (LM Studio, etc.)

Sourced by `.zprofile` (Zsh login shells) and `.bash_profile` (Bash login shells).

**Note:** `~/.local/bin` and `~/_root/tools` are not here — they belong in `.zshenv` since they need to be available in all shell types, not just login shells.

## `.zshrc`

Interactive shell configuration only.

Responsibilities:
- Shell options and history
- Prompt
- Completions

No PATH manipulation occurs here.
No sourcing of `.paths` — that happens in `.zprofile` for login shells.

## `.zprofile`

Login shell configuration for Zsh.

Responsibilities:
- Initialize Homebrew shell environment
- Source `~/.paths`
- Lazy-load nvm (deferred until first use of `nvm`, `node`, `npm`, or `npx`)

## PATH Strategy

PATH is assembled in layers, each with a distinct scope:

1. **`.zshenv`** — every shell, every context
   - Guarantees tool visibility everywhere
   - Required for non-interactive shells and scripts
   - Prevents vendor tools from editing shell config

2. **`.paths`** — login shells only
   - Adds developer runtimes (bun, deno, Python)
   - All vendor PATH additions live here

3. **`.zshrc`** — no PATH logic whatsoever

This avoids duplication, ordering bugs, and shell-specific surprises.

## pipx

- `pipx` itself is installed via Homebrew
- pipx-installed tools live in `~/.local/bin`
- `~/.local/bin` is added to PATH in `.zshenv`

This ensures:
- `pipx ensurepath` reports nothing to do
- No PATH injection into `.zshrc`
- Tools resolve correctly in all shell contexts

Verification:

```sh
zsh -lc 'command -v black'
pipx ensurepath
```

## Personal Tools

Custom & personal scripts live in:

```
~/_root/tools
```

Requirements:
- Scripts must be executable
- Directory is added to PATH in `.zshenv`

This allows scripts to run consistently in terminals, SSH sessions, and automated contexts.

## Testing

A sanity-check script verifies that all configuration is correct and no regressions have crept in. Run it from the root of the repo after any changes:

```sh
sh test.sh
```

The script checks:
- All expected `$HOME` symlinks exist (and stale ones are gone)
- No vendor PATH injections in shell files (`.zshrc`, `.bash_profile`, `.bashrc`)
- `env/paths.sh` contains the right entries and no duplicates
- `bootstrap.sh` references current file names
- `brew.sh` has no deprecated `--with-*` flags
- `macos/defaults.sh` has no stale or no-op settings
- `git/gitconfig` has no redundant aliases
- `ssh/config` follows consistent key naming
- `vim/vimrc` has no duplicate directives
- `ghostty/config` and `zed/settings.json` are correctly configured
- All placeholder directories have a `.gitkeep`

A fully passing run looks like:

```
======================================
  50 passed  |  0 failed
======================================
```

Any failure prints the exact check that broke, making it easy to spot what needs fixing.

## Compatibility Notes

- Works consistently across Terminal, SSH, tmux, and CI
- Zsh is the default shell
- Bash remains a safe fallback
- Configuration avoids shell-specific assumptions

## References

- Awesome Dotfiles — https://project-awesome.org/webpro/awesome-dotfiles
- dotfiles on GitHub — https://dotfiles.github.io
- Chezmoi — https://www.chezmoi.io
- GNU Stow — https://www.gnu.org/software/stow/
- XDG Base Directory Specification — https://specifications.freedesktop.org/basedir/latest/
