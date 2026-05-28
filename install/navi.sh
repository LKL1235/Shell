#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pkg.sh
source "$SCRIPT_DIR/pkg.sh"

if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$(whoami)"
    REAL_HOME="$HOME"
fi

if [ "$(id -u)" -eq 0 ]; then
    pkg_ensure_supported
    pkg_install fzf
fi

bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)

CARGO_BIN="$REAL_HOME/.cargo/bin"
export PATH="$PATH:$CARGO_BIN"
grep -qF "$CARGO_BIN" "$REAL_HOME/.bashrc" 2>/dev/null \
    || echo "export PATH=\$PATH:$CARGO_BIN" >>"$REAL_HOME/.bashrc"

CHEATS_PATH=$(env PATH="$CARGO_BIN:$PATH" navi info cheats-path)
mkdir -p "$CHEATS_PATH"
[ -d "$CHEATS_PATH/navi-cheats" ] \
    || git clone https://github.com/LKL1235/navi-cheats.git "$CHEATS_PATH/navi-cheats"

echo "navi installed for $REAL_USER ($(pkg_distro_id)/$(pkg_family))."
