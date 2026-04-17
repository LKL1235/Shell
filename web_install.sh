#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/LKL1235/Shell/main"

# ── helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[INFO]  $*"; }
die()   { echo "[ERROR] $*" >&2; exit 1; }

# Resolve the real (non-root) user when invoked via sudo
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

# Run a command as the real user (drops back from root when needed)
as_user() {
    if [ "$REAL_USER" = "root" ]; then
        "$@"
    else
        sudo -u "$REAL_USER" env HOME="$REAL_HOME" PATH="$PATH" "$@"
    fi
}

# ── tools ─────────────────────────────────────────────────────────────────────
install_ohmyzsh() {
    info "Installing oh-my-zsh for user '$REAL_USER' (home: $REAL_HOME)..."
    apt-get update -q && apt-get install -y zsh curl git

    # Install oh-my-zsh into the real user's home
    as_user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    local custom="$REAL_HOME/.oh-my-zsh/custom"
    as_user git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting"
    as_user git clone https://github.com/zsh-users/zsh-autosuggestions          "$custom/plugins/zsh-autosuggestions"
    as_user git clone https://github.com/zsh-users/zsh-completions              "$custom/plugins/zsh-completions"
    as_user git clone --depth=1 https://github.com/romkatv/powerlevel10k.git    "$custom/themes/powerlevel10k"
    as_user git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$custom/plugins/you-should-use"

    as_user cp "$REAL_HOME/.zshrc" "$REAL_HOME/.zshrc.back" 2>/dev/null || true
    as_user mkdir -p "$REAL_HOME/.myshell"
    as_user curl -fsSL "$REPO/install/mytheme.sh" -o "$REAL_HOME/.myshell/mytheme.sh"
    as_user curl -fsSL "$REPO/install/venv.sh"    -o "$REAL_HOME/.myshell/venv.sh"
    as_user grep -qF "source ~/.myshell/mytheme.sh" "$REAL_HOME/.zshrc" 2>/dev/null \
        || as_user bash -c "echo 'source ~/.myshell/mytheme.sh' >> '$REAL_HOME/.zshrc'"
    info "oh-my-zsh done."
}

install_navi() {
    info "Installing navi for user '$REAL_USER'..."
    apt-get install -y fzf

    local cargo_bin="$REAL_HOME/.cargo/bin"
    as_user bash -c "$(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)"

    as_user grep -qF "$cargo_bin" "$REAL_HOME/.bashrc" \
        || as_user bash -c "echo 'export PATH=\$PATH:$cargo_bin' >> '$REAL_HOME/.bashrc'"
    as_user grep -qF "$cargo_bin" "$REAL_HOME/.zshrc" 2>/dev/null \
        || as_user bash -c "echo 'export PATH=\$PATH:$cargo_bin' >> '$REAL_HOME/.zshrc'"

    local cheats_path
    cheats_path=$(as_user env PATH="$cargo_bin:$PATH" navi info cheats-path)
    as_user mkdir -p "$cheats_path"
    [ -d "$cheats_path/navi-cheats" ] \
        || as_user git clone https://github.com/LKL1235/navi-cheats.git "$cheats_path/navi-cheats"
    info "navi done."
}

install_networktools() {
    info "Installing network tools..."
    apt-get update -q && apt-get install -y iftop nload net-tools
    info "Network tools done."
}

install_systemtools() {
    info "Installing system tools..."
    add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    apt-get update -q && apt-get install -y fastfetch
    info "System tools done."
}

add_root_key() {
    info "Adding root SSH key..."
    local auth="/root/.ssh/authorized_keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch "$auth"
    chmod 600 "$auth"
    local pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6oMFoHiHoMFoHiHoMFoHiH github.hood.np"
    grep -qF "$pubkey" "$auth" || echo "$pubkey" >> "$auth"
    info "Root key added."
}

# ── menu ──────────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: sudo $0 [OPTIONS]

Options:
  --all             Install everything
  --ohmyzsh         Install oh-my-zsh + plugins + theme
  --navi            Install navi + cheat sheets
  --networktools    Install iftop / nload / net-tools
  --systemtools     Install fastfetch
  --rootkey         Add root SSH public key to authorized_keys
  -h, --help        Show this help

Examples:
  curl ... | sudo bash -s -- --all
  curl ... | sudo bash -s -- --ohmyzsh --navi
EOF
}

main() {
    need_root

    [ $# -eq 0 ] && { usage; exit 0; }

    local do_ohmyzsh=0 do_navi=0 do_net=0 do_sys=0 do_key=0

    for arg in "$@"; do
        case "$arg" in
            --all)          do_ohmyzsh=1; do_navi=1; do_net=1; do_sys=1; do_key=1 ;;
            --ohmyzsh)      do_ohmyzsh=1 ;;
            --navi)         do_navi=1 ;;
            --networktools) do_net=1 ;;
            --systemtools)  do_sys=1 ;;
            --rootkey)      do_key=1 ;;
            -h|--help)      usage; exit 0 ;;
            *)              die "Unknown option: $arg" ;;
        esac
    done

    [ $do_ohmyzsh -eq 1 ] && install_ohmyzsh
    [ $do_navi    -eq 1 ] && install_navi
    [ $do_net     -eq 1 ] && install_networktools
    [ $do_sys     -eq 1 ] && install_systemtools
    [ $do_key     -eq 1 ] && add_root_key

    info "All done."
}

main "$@"
