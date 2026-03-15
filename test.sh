#!/usr/bin/env sh
# --------------------------------------
# Dotfiles sanity checks
# Run from the root of the dotfiles repo:  sh test.sh
# --------------------------------------

PASS=0
FAIL=0
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

ok()   { printf "${GREEN}  PASS${RESET}  %s\n" "$1"; PASS=$((PASS + 1)); }
fail() { printf "${RED}  FAIL${RESET}  %s\n" "$1"; FAIL=$((FAIL + 1)); }

assert_contains()     { grep -qF -- "$2" "$1"      && ok "$3"  || fail "$3"; }
assert_not_contains() { ! grep -qF -- "$2" "$1"    && ok "$3"  || fail "$3"; }
assert_symlink()      { [ -L "$1" ]             && ok "$2"  || fail "$2"; }
assert_no_symlink()   { [ ! -L "$1" ]           && ok "$2"  || fail "$2"; }
assert_file()         { [ -f "$1" ]             && ok "$2"  || fail "$2"; }

# -----------------------------------------------------------------------
printf "\n--- Symlinks\n"
# -----------------------------------------------------------------------

assert_symlink    "$HOME/.paths"      "~/.paths symlink exists"
assert_no_symlink "$HOME/.env"        "~/.env symlink is gone (old broken link)"
assert_symlink    "$HOME/.zshrc"      "~/.zshrc symlink exists"
assert_symlink    "$HOME/.zprofile"   "~/.zprofile symlink exists"
assert_symlink    "$HOME/.zshenv"     "~/.zshenv symlink exists"
assert_symlink    "$HOME/.gitconfig"  "~/.gitconfig symlink exists"
assert_symlink    "$HOME/.ssh/config" "~/.ssh/config symlink exists"

# -----------------------------------------------------------------------
printf "\n--- zshrc: no violations\n"
# -----------------------------------------------------------------------

assert_not_contains zsh/zshrc "lmstudio"             "zshrc: no LM Studio PATH"
assert_not_contains zsh/zshrc "Obsidian.app"          "zshrc: no Obsidian PATH"
assert_not_contains zsh/zshrc "TERM=xterm"            "zshrc: no TERM override"
assert_not_contains zsh/zshrc 'source "/'             "zshrc: no hardcoded absolute source path"
assert_not_contains zsh/zshrc '. "$NVM_DIR/nvm.sh"'  "zshrc: no eager nvm load"

# -----------------------------------------------------------------------
printf "\n--- zprofile: clean\n"
# -----------------------------------------------------------------------

assert_contains     zsh/zprofile ".paths"             "zprofile: sources .paths"
assert_not_contains zsh/zprofile "env.sh"             "zprofile: no stale env.sh reference"
assert_not_contains zsh/zprofile "export NVM_DIR"     "zprofile: no duplicate NVM_DIR declaration"
assert_not_contains zsh/zprofile "PIPX_BIN_DIR"       "zprofile: no duplicate PIPX_BIN_DIR"

# -----------------------------------------------------------------------
printf "\n--- env/paths.sh: correct content\n"
# -----------------------------------------------------------------------

assert_file         env/paths.sh                      "env/paths.sh exists"
assert_contains     env/paths.sh "lmstudio"           "paths.sh: LM Studio PATH present"
assert_contains     env/paths.sh "Obsidian.app"       "paths.sh: Obsidian PATH present"
assert_not_contains env/paths.sh "PIPX_BIN_DIR"       "paths.sh: no duplicate PIPX_BIN_DIR"
# Check that _root/tools is not being set as a PATH entry (comment references are fine)
assert_not_contains env/paths.sh 'PATH="$HOME/_root'  "paths.sh: no duplicate _root/tools PATH entry"

# -----------------------------------------------------------------------
printf "\n--- bootstrap.sh\n"
# -----------------------------------------------------------------------

assert_contains     bootstrap.sh "paths.sh"           "bootstrap.sh: references paths.sh"
assert_not_contains bootstrap.sh "env/env.sh"         "bootstrap.sh: no stale env/env.sh reference"
assert_contains     bootstrap.sh ".paths"             "bootstrap.sh: symlinks to .paths"
assert_not_contains bootstrap.sh '".env"'             "bootstrap.sh: no stale .env symlink"

# -----------------------------------------------------------------------
printf "\n--- bash: no vendor injections\n"
# -----------------------------------------------------------------------

assert_contains     bash/bash_profile ".paths"        "bash_profile: sources .paths"
assert_not_contains bash/bash_profile '".env"'        "bash_profile: no stale .env reference"
assert_not_contains bash/bash_profile "lmstudio"      "bash_profile: no LM Studio PATH"
assert_not_contains bash/bashrc       "lmstudio"      "bashrc: no LM Studio PATH"

# -----------------------------------------------------------------------
printf "\n--- brew.sh: no deprecated flags\n"
# -----------------------------------------------------------------------

assert_not_contains brew/brew.sh "--with-iri"         "brew.sh: no --with-iri"
assert_not_contains brew/brew.sh "--with-override"    "brew.sh: no --with-override-system-vi"
assert_not_contains brew/brew.sh "--with-webp"        "brew.sh: no --with-webp"
assert_not_contains brew/brew.sh "gsha256sum"         "brew.sh: no stale sha256sum symlink"

# -----------------------------------------------------------------------
printf "\n--- macos/defaults.sh\n"
# -----------------------------------------------------------------------

assert_contains     macos/defaults.sh "System Settings"        "defaults.sh: uses System Settings"
assert_not_contains macos/defaults.sh "System Preferences"    "defaults.sh: no old System Preferences"
assert_not_contains macos/defaults.sh "pmset -a sms"          "defaults.sh: no Sudden Motion Sensor"
assert_not_contains macos/defaults.sh "QLEnableTextSelection"  "defaults.sh: no QLEnableTextSelection"

# -----------------------------------------------------------------------
printf "\n--- git/gitconfig\n"
# -----------------------------------------------------------------------

assert_not_contains git/gitconfig "sign  ="            "gitconfig: no redundant sign alias"

# -----------------------------------------------------------------------
printf "\n--- ssh/config\n"
# -----------------------------------------------------------------------

assert_contains     ssh/config "id_ed25519_laaija"     "ssh/config: laaija key uses standard naming"
assert_not_contains ssh/config "/.ssh/laaija"          "ssh/config: no bare laaija key reference"

# -----------------------------------------------------------------------
printf "\n--- vim/vimrc\n"
# -----------------------------------------------------------------------

SYNTAX_COUNT=$(grep -cF "syntax" vim/vimrc 2>/dev/null || echo 0)
[ "$SYNTAX_COUNT" -eq 1 ] && ok "vimrc: exactly one syntax directive" || fail "vimrc: duplicate syntax directive (found $SYNTAX_COUNT)"

CURSORLINE_COUNT=$(grep -cF "set cursorline" vim/vimrc 2>/dev/null || echo 0)
[ "$CURSORLINE_COUNT" -eq 1 ] && ok "vimrc: exactly one set cursorline" || fail "vimrc: duplicate cursorline (found $CURSORLINE_COUNT)"

assert_not_contains vim/vimrc 'has("mac")'             "vimrc: no redundant font conditional"

# -----------------------------------------------------------------------
printf "\n--- ghostty/config\n"
# -----------------------------------------------------------------------

assert_contains ghostty/config "scrollback-limit = 10000" "ghostty: scrollback-limit is 10000"

# -----------------------------------------------------------------------
printf "\n--- zed/settings.json\n"
# -----------------------------------------------------------------------

assert_not_contains zed/settings.json "  ],"           "zed: no trailing comma after file_scan_exclusions"

# -----------------------------------------------------------------------
printf "\n--- jujutsu/config.toml\n"
# -----------------------------------------------------------------------

assert_file         jujutsu/config.toml                       "jujutsu/config.toml exists"
assert_contains     jujutsu/config.toml "brajeshwar@oinam.com" "jujutsu: user email set"
assert_contains     jujutsu/config.toml "sign-all = true"      "jujutsu: sign-all enabled"
assert_contains     jujutsu/config.toml "backend  = \"gpg\""   "jujutsu: GPG signing backend"
assert_contains     jujutsu/config.toml "editor"               "jujutsu: editor set"
assert_contains     bootstrap.sh "jujutsu/config.toml"         "bootstrap.sh: links jujutsu config"
assert_symlink      "$HOME/.config/jj/config.toml"             "~/.config/jj/config.toml symlink exists"

# -----------------------------------------------------------------------
printf "\n--- Empty dirs have .gitkeep\n"
# -----------------------------------------------------------------------

for dir in claude config emacs sublimetext; do
  assert_file "$dir/.gitkeep" "$dir/.gitkeep exists"
done

# -----------------------------------------------------------------------
printf "\n======================================\n"
printf "  %d passed  |  %d failed\n" "$PASS" "$FAIL"
printf "======================================\n\n"

[ "$FAIL" -eq 0 ]
