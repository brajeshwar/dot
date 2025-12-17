# .

https://github.com/brajeshwar/dot

## Symlink

```
ln -s [source] [link]
ln -s ~/folder/README.md ~/README
// overwrite/force
ln -sf [source] [link]
```

`.env`: A common POSIX-compatible (no prompts, aliases, functions, or shell-specific logic) sourced by `.bash_profile`, and `.zprofile`.

`.bashrc` (legacy), and `.zshrc` (default) are interactive shells.

Should works consistently across Terminal, SSH, tmux, and CI.
Zsh is modern and fast.
Bash is the safe fallback.

## Bootstrap

```sh
// make it executable
`chmod +x bootstrap.sh`

// run
./bootstrap.sh
```

### References

- [Awesome Dotfiles](https://project-awesome.org/webpro/awesome-dotfiles)
- [dotfiles on GitHub](https://dotfiles.github.io), the Unofficial Guide
- [Chezmoi](https://www.chezmoi.io) manages your dotfiles across multiple diverse machines, securely.
- [GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager which takes distinct packages of software and/or data located in separate directories on the filesystem, and makes them appear to be installed in the same place.
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/)