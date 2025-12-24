# .

https://github.com/brajeshwar/dot

A **minimal, layered shell environment** designed to be predictable, portable, and resistant to vendor tooling modifying shell configuration files.

The setup prioritizes:
- Explicit PATH management.
- POSIX-safe shared configuration.
- Correct use of Zsh startup files.
- Consistent behavior across interactive and non-interactive shells.

## Symlink

Dotfiles in this repository are expected to be symlinked into `$HOME`.

```sh
ln -s [source] [link]
ln -s ~/folder/README.md ~/README

# overwrite / force
ln -sf [source] [link]
```

## Shell File Responsibilities

Configuration is intentionally layered and boring.

```
.zshenv  → tools, PATH, invariants (always loaded)
.env     → shared runtime environment (POSIX-safe)
.zshrc   → humans and interaction (interactive only)
```

## `.zshenv`

Loaded by **all** Zsh invocations:
- interactive
- non-interactive
- login
- tool probes (pipx, CI, scripts)

Responsibilities:
- Minimal PATH setup required by tools
- Tool invariants only
- Zero interactivity

Typical contents:
- `~/.local/bin` (pipx-installed tools)
- `~/ _root/tools` (personal scripts)

This file exists so tools see the correct PATH immediately and do not attempt to modify shell configuration files.

No Homebrew.  
No language runtimes.  
No shell behavior.

## `.env`

A shared, POSIX-compatible environment file.

Characteristics:
- No prompts, aliases, functions, or shell-specific logic
- Explicit and auditable
- Safe to source from any shell

Responsibilities:
- Homebrew shell environment
- Language runtimes (bun, deno, Python user base)
- Build and toolchain flags (OpenSSL, Ruby)

This file is sourced explicitly by `.zshrc`.

## `.zshrc`

Interactive shell configuration only.

Responsibilities:
- Source `.env`
- Shell options
- Prompt
- Keybindings

No PATH manipulation occurs here.

## PATH Strategy

PATH is assembled in layers:

1. **`.zshenv`**
   - Guarantees tool visibility everywhere
   - Required for non-interactive shells
   - Prevents vendor tools from editing shell config

2. **`.env`**
   - Adds developer tooling and runtimes

3. **`.zshrc`**
   - No PATH logic

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

Custom scripts live in:

```
~/ _root/tools
```

Requirements:
- Scripts must be executable
- Directory is added to PATH in `.zshenv`

This allows scripts to run consistently in terminals, SSH sessions, and automated contexts.

## Bootstrap

```sh
chmod +x bootstrap.sh
./bootstrap.sh
```

The bootstrap script is responsible for initial setup and symlink creation.

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