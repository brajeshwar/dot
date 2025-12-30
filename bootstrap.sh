#!/usr/bin/env sh
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
  src="$DOTFILES_DIR/$1"
  dest="$2"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "Skipping $dest (already exists)"
    return
  fi

  ln -sf "$src" "$dest"
  echo "Linked $dest → $src"
}

echo "Bootstrapping dotfiles..."

mkdir -p "$HOME/.ssh"

link "env/env.sh"         "$HOME/.env"
link "zsh/zprofile"       "$HOME/.zprofile"
link "zsh/zshenv"         "$HOME/.zshenv"
link "zsh/zshrc"          "$HOME/.zshrc"
link "bash/bash_profile"  "$HOME/.bash_profile"
link "bash/bashrc"        "$HOME/.bashrc"
link "git/gitconfig"      "$HOME/.gitconfig"
link "ssh/config"         "$HOME/.ssh/config"

echo "Done."
echo "Restart your shell or run: exec zsh -l"
