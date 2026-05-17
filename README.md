# .

A minimal, layered shell environment — predictable, portable, and resistant to vendor tooling injecting itself into shell config files.

› https://github.com/brajeshwar/dot

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

**`.zshrc`** contains no PATH logic. Prompt, shell options, history, completions only. Sources `~/.zshrc.local` at the end if it exists.

**`.zprofile`** initializes Homebrew, sources `~/.paths`, and eagerly loads nvm.

## Local overrides

Three files are loaded automatically if they exist, but are never committed. They hold anything machine-specific or private.

| File | Purpose |
|---|---|
| `~/.ssh/config.local` | Device-specific SSH identities (see `ssh/config.local.example`) |
| `~/.gitconfig.local` | Work identity — name, email, GPG key (see `git/gitconfig.local.example`) |
| `~/.zshrc.local` | Work env vars, aliases, tool completions |

Copy the `.example` files as starting points. These files match the `*.local` pattern in `gitignore_global` and will never be accidentally committed.

## SSH keys

Each device gets its own key — keys are never shared between machines. This lets you audit and revoke individual device access from GitHub without affecting other devices.

**Key naming convention for personal devices:**
```
id_ed25519_<Owner>_<DeviceModel><Year>
```
For example: `id_ed25519_ONM_MBP2025`, `id_ed25519_ONM_MBA2023`

Work and job devices use a separate codename scheme defined in `ssh/config.local.example`.

**Generate a key for this device:**
```sh
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519_<Device>
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_<Device>
```

Then add the public key (`~/.ssh/id_ed25519_<Device>.pub`) to the relevant GitHub account under Settings → SSH keys.

## Multiple GitHub identities

`ssh/config` defines Host aliases for different identities, each mapped to a specific SSH key. Use the alias instead of `github.com` when cloning to control which identity is used:

```sh
git clone git@github-brajeshwar:<user>/<repo>.git
git clone git@github-arin:<user>/<repo>.git
git clone git@github-kairo:<user>/<repo>.git
git clone git@github-job94776:<user>/<repo>.git
```

Personal device identities (`github-brajeshwar`) go in `~/.ssh/config.local` since they reference a device-specific key. See `ssh/config.local.example`.

To automatically apply a work identity to all repos under a folder:

```ini
# Already wired in git/gitconfig:
[includeIf "gitdir:~/work/"]
  path = ~/.gitconfig.local
```

## Testing

Run after any changes to verify nothing is broken:

```sh
sh test.sh
```

Checks symlinks, PATH hygiene across all shell files, `env/paths.sh` contents, `brew.sh` flags, macOS defaults, git/ssh/vim/ghostty config, and placeholder directories. A clean run:

```
======================================
  45 passed  |  0 failed
======================================
```

## References

- [Awesome Dotfiles](https://project-awesome.org/webpro/awesome-dotfiles) is a curated list of `dotfiles` resource.
- [dotfiles.github.io](https://github.com/dotfiles/dotfiles.github.com) is an unofficial guide to doing dotfiles on GitHub.
- [Chezmoi](https://www.chezmoi.io) manages your dotfiles across multiple diverse machines, securely.
- [GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager which takes distinct packages of software and/or data located in separate directories on the filesystem, and makes them appear to be installed in the same place.
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/) specify files and file formats, where these files should be looked for by defining one or more base directories relative to which files should be located.