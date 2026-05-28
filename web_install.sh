#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/LKL1235/Shell/main"

# When run via `curl ... | bash`, only web_install.sh is on stdin — fetch pkg.sh from the repo.
_source_pkg() {
    local script_dir pkg_local pkg_tmp=""
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || script_dir=""
    pkg_local="${script_dir:+$script_dir/install/}pkg.sh"
    if [ -n "$pkg_local" ] && [ -f "$pkg_local" ]; then
        # shellcheck source=install/pkg.sh
        source "$pkg_local"
        return 0
    fi
    pkg_tmp="$(mktemp)"
    curl -fsSL "$REPO/install/pkg.sh" -o "$pkg_tmp" \
        || { rm -f "$pkg_tmp"; die "Failed to download $REPO/install/pkg.sh"; }
    # shellcheck source=/dev/null
    source "$pkg_tmp"
    rm -f "$pkg_tmp"
}

die() { echo "[ERROR] $*" >&2; exit 1; }
_source_pkg
unset -f _source_pkg

# ── helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[INFO]  $*"; }

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
# Writes a single managed block to ~/.zshrc (THEME: starship | p10k).
refresh_myshell_zshrc() {
    local zshrc="$REAL_HOME/.zshrc"
    as_user touch "$zshrc"
    if as_user grep -qF '# >>>myshell-theme-begin' "$zshrc" 2>/dev/null; then
        as_user sed -i '/# >>>myshell-theme-begin/,/# <<<myshell-theme-end/d' "$zshrc"
    fi
    if as_user grep -qFx 'source ~/.myshell/mytheme.sh' "$zshrc" 2>/dev/null; then
        as_user sed -i '\|^source ~/.myshell/mytheme.sh$|d' "$zshrc"
    fi
    {
        echo '# >>>myshell-theme-begin'
        if [ "$THEME" = "starship" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"'
            echo 'ZSH_THEME=""'
        else
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"'
        fi
        echo 'source ~/.myshell/mytheme.sh'
        if [ "$THEME" = "starship" ]; then
            echo 'eval "$(starship init zsh)"'
        fi
        echo '# <<<myshell-theme-end'
    } | as_user tee -a "$zshrc" >/dev/null
}

install_ohmyzsh() {
    info "Installing oh-my-zsh for user '$REAL_USER' (home: $REAL_HOME), theme: $THEME ($(pkg_distro_label))..."
    pkg_update && pkg_install zsh curl git

    # Install oh-my-zsh into the real user's home
    as_user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    local custom="$REAL_HOME/.oh-my-zsh/custom"
    as_user git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting"
    as_user git clone https://github.com/zsh-users/zsh-autosuggestions          "$custom/plugins/zsh-autosuggestions"
    as_user git clone https://github.com/zsh-users/zsh-completions              "$custom/plugins/zsh-completions"
    as_user git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$custom/plugins/you-should-use"
    if [ "$THEME" = "p10k" ]; then
        as_user git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
    fi

    if [ "$THEME" = "starship" ]; then
        info "Installing Starship for user '$REAL_USER'..."
        as_user mkdir -p "$REAL_HOME/.local/bin"
        curl -sS https://starship.rs/install.sh | as_user sh -s -- -y -b "$REAL_HOME/.local/bin"
        as_user mkdir -p "$REAL_HOME/.config"
        as_user curl -fsSL "$REPO/setting/starship.toml" -o "$REAL_HOME/.config/starship.toml"
    fi

    as_user cp "$REAL_HOME/.zshrc" "$REAL_HOME/.zshrc.back" 2>/dev/null || true
    as_user mkdir -p "$REAL_HOME/.myshell"
    as_user curl -fsSL "$REPO/install/mytheme.sh" -o "$REAL_HOME/.myshell/mytheme.sh"
    as_user curl -fsSL "$REPO/install/venv.sh"    -o "$REAL_HOME/.myshell/venv.sh"

    refresh_myshell_zshrc

    info "oh-my-zsh done."
}

install_meslo_font() {
    info "Installing MesloLGS NF fonts for user '$REAL_USER'..."
    pkg_update && pkg_install curl fontconfig

    local fonts_dir="$REAL_HOME/.local/share/fonts"
    as_user mkdir -p "$fonts_dir"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" -o "$fonts_dir/MesloLGS NF Regular.ttf"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" -o "$fonts_dir/MesloLGS NF Bold.ttf"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" -o "$fonts_dir/MesloLGS NF Italic.ttf"
    as_user curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" -o "$fonts_dir/MesloLGS NF Bold Italic.ttf"
    as_user fc-cache -f "$fonts_dir"
    info "MesloLGS NF fonts done."
}

install_navi() {
    info "Installing navi for user '$REAL_USER'..."
    pkg_install fzf

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
    info "Installing network tools ($(pkg_distro_label))..."
    pkg_update && pkg_install iftop nload net-tools
    info "Network tools done."
}

install_systemtools() {
    info "Installing system tools ($(pkg_distro_label))..."
    pkg_install_fastfetch
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
  --theme NAME      Shell theme for --all / --ohmyzsh only: starship (default) or p10k
                    ZSH_THEME and Starship init are written to ~/.zshrc, not mytheme.sh
  --meslofont       Install MesloLGS NF fonts for powerlevel10k
  --navi            Install navi + cheat sheets
  --networktools    Install iftop / nload / net-tools
  --systemtools     Install fastfetch
  --rootkey         Add root SSH public key to authorized_keys
  -h, --help        Show this help

Examples:
  curl ... | sudo bash -s -- --all
  curl ... | sudo bash -s -- --all --theme=p10k
  curl ... | sudo bash -s -- --ohmyzsh --navi
  curl ... | sudo bash -s -- --ohmyzsh --theme starship
EOF
}

main() {
    need_root
    pkg_ensure_supported || die "This Linux distribution is not supported."

    [ $# -eq 0 ] && { usage; exit 0; }

    local do_ohmyzsh=0 do_font=0 do_navi=0 do_net=0 do_sys=0 do_key=0
    local THEME=starship theme_explicit=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)          do_ohmyzsh=1; do_font=1; do_navi=1; do_net=1; do_sys=1; do_key=1; shift ;;
            --ohmyzsh)      do_ohmyzsh=1; shift ;;
            --meslofont)    do_font=1; shift ;;
            --navi)         do_navi=1; shift ;;
            --networktools) do_net=1; shift ;;
            --systemtools)  do_sys=1; shift ;;
            --rootkey)      do_key=1; shift ;;
            --theme=*)
                theme_explicit=1
                THEME="${1#*=}"
                shift
                ;;
            --theme)
                theme_explicit=1
                [ -n "${2:-}" ] || die "--theme requires a value (starship|p10k)"
                THEME="$2"
                shift 2
                ;;
            -h|--help)      usage; exit 0 ;;
            *)              die "Unknown option: $1" ;;
        esac
    done

    THEME="${THEME,,}"
    case "$THEME" in
        starship|p10k) ;;
        *) die "Invalid --theme: use starship or p10k" ;;
    esac

    if [ "$theme_explicit" -eq 1 ] && [ "$do_ohmyzsh" -eq 0 ]; then
        die "--theme is only valid with --all or --ohmyzsh"
    fi

    [ $do_ohmyzsh -eq 1 ] && install_ohmyzsh
    [ $do_font    -eq 1 ] && install_meslo_font
    [ $do_navi    -eq 1 ] && install_navi
    [ $do_net     -eq 1 ] && install_networktools
    [ $do_sys     -eq 1 ] && install_systemtools
    [ $do_key     -eq 1 ] && add_root_key

    info "All done."
}

main "$@"
