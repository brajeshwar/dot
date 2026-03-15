# ---------------------------------
# Shared runtime PATH (POSIX-safe)
# Sourced by .zprofile and .bash_profile for login shells.
# ~/.local/bin and ~/_root/tools are set in .zshenv (all shells).
# ---------------------------------

# bun
export BUN_INSTALL="$HOME/.bun"
PATH="$BUN_INSTALL/bin:$PATH"

# deno (explicit, no activation script)
export DENO_INSTALL="$HOME/.deno"
PATH="$DENO_INSTALL/bin:$PATH"

# Python user binaries (static path)
PYTHON_USER_BASE="$HOME/Library/Python/3.11"
PATH="$PYTHON_USER_BASE/bin:$PATH"

# LM Studio CLI
PATH="$HOME/.lmstudio/bin:$PATH"

# Obsidian (CLI access to app binary)
PATH="/Applications/Obsidian.app/Contents/MacOS:$PATH"

export PATH
