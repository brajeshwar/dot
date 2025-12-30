# ---------------------------------
# Shared environment (POSIX-safe)
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

# pipx
PIPX_BIN_DIR="$HOME/.local/bin"
[ -d "$PIPX_BIN_DIR" ] && PATH="$PIPX_BIN_DIR:$PATH"

# Custom tools
TOOLS_DIR="$HOME/_root/tools"
[ -d "$TOOLS_DIR" ] && PATH="$TOOLS_DIR:$PATH"

export PATH