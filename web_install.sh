#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/LKL1235/Shell/main"

# ── helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[INFO]  $*"; }
die()   { echo "[ERROR] $*" >&2; exit 1; }

need_root() {
    [ "$(id -u)" -eq 0 ] || die "This script must be run as root."
}

# ── tools ─────────────────────────────────────────────────────────────────────
install_ohmyzsh() {
    info "Installing oh-my-zsh..."
    apt-get update -q && apt-get install -y zsh curl git
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  "$custom/plugins/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-autosuggestions           "$custom/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-completions               "$custom/plugins/zsh-completions"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git     "$custom/themes/powerlevel10k"
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git  "$custom/plugins/you-should-use"
    cp ~/.zshrc ~/.zshrc.back 2>/dev/null || true
    mkdir -p ~/.myshell
    curl -fsSL "$REPO/install/mytheme.sh" -o ~/.myshell/mytheme.sh
    curl -fsSL "$REPO/install/venv.sh"    -o ~/.myshell/venv.sh
    grep -qF "source ~/.myshell/mytheme.sh" ~/.zshrc 2>/dev/null \
        || echo "source ~/.myshell/mytheme.sh" >> ~/.zshrc
    info "oh-my-zsh done."
}

install_navi() {
    info "Installing navi..."
    apt-get install -y fzf
    bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
    export PATH="$PATH:/root/.cargo/bin"
    grep -qF '/root/.cargo/bin' ~/.bashrc || echo 'export PATH=$PATH:/root/.cargo/bin' >> ~/.bashrc
    mkdir -p "$(navi info cheats-path)"
    cd "$(navi info cheats-path)"
    [ -d navi-cheats ] || git clone https://github.com/LKL1235/navi-cheats.git
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
Usage: $0 [OPTIONS]

Options:
  --all             Install everything
  --ohmyzsh         Install oh-my-zsh + plugins + theme
  --navi            Install navi + cheat sheets
  --networktools    Install iftop / nload / net-tools
  --systemtools     Install fastfetch
  --rootkey         Add root SSH public key to authorized_keys
  -h, --help        Show this help

Examples:
  $0 --all
  $0 --ohmyzsh --navi
  $0 --rootkey
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
