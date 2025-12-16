# ---------------------------------
# Shared environment (POSIX-safe)
# ---------------------------------

# Homebrew (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# deno
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# Python user installs
PYTHON_USER_BIN="$(python3 -m site --user-base 2>/dev/null)/bin"
[ -d "$PYTHON_USER_BIN" ] && PATH="$PYTHON_USER_BIN:$PATH"
export PATH

# OpenSSL (for building Ruby)
if command -v brew >/dev/null 2>&1; then
  OPENSSL_PREFIX="$(brew --prefix openssl@3 2>/dev/null)"
  if [ -d "$OPENSSL_PREFIX" ]; then
    export PKG_CONFIG_PATH="$OPENSSL_PREFIX/lib/pkgconfig"
    export CPPFLAGS="-I$OPENSSL_PREFIX/include"
    export LDFLAGS="-L$OPENSSL_PREFIX/lib"
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$OPENSSL_PREFIX"
  fi
fi
