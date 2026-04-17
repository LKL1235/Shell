#!/bin/bash
set -e

info() { echo "[INFO]  $*"; }
die()  { echo "[ERROR] $*" >&2; exit 1; }

# Resolve the real user when invoked via sudo
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$(whoami)"
    REAL_HOME="$HOME"
fi

need_root() {
    [ "$(id -u)" -eq 0 ] || die "This script must be run with sudo."
}

as_user() {
    if [ "$REAL_USER" = "root" ]; then
        "$@"
    else
        sudo -u "$REAL_USER" env HOME="$REAL_HOME" PATH="$PATH" "$@"
    fi
}

install_meslo_font() {
    info "Installing MesloLGS NF fonts for user '$REAL_USER'..."

    apt-get update -q
    apt-get install -y curl fontconfig

    local fonts_dir="$REAL_HOME/.local/share/fonts"
    as_user mkdir -p "$fonts_dir"

    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" -o "$fonts_dir/MesloLGS NF Regular.ttf"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" -o "$fonts_dir/MesloLGS NF Bold.ttf"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" -o "$fonts_dir/MesloLGS NF Italic.ttf"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" -o "$fonts_dir/MesloLGS NF Bold Italic.ttf"

    as_user fc-cache -f "$fonts_dir"
    info "MesloLGS NF fonts installed."
}

main() {
    need_root
    install_meslo_font
}

main "$@"
