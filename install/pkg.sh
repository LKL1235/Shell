#!/bin/bash
# Cross-distro package helpers for install scripts.
# Source this file; do not execute directly.

# shellcheck disable=SC2034
PKG_ID=""
PKG_ID_LIKE=""
PKG_FAMILY=""
PKG_PM=""

_pkg_load_os_release() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
    fi
    PKG_ID="${ID:-unknown}"
    PKG_ID_LIKE="${ID_LIKE:-}"
}

_pkg_detect_family() {
    _pkg_load_os_release
    case "$PKG_ID" in
        debian|ubuntu|linuxmint|pop|elementary|kali|raspbian|zorin|neon)
            PKG_FAMILY=debian
            ;;
        fedora|rhel|centos|rocky|almalinux|ol|amzn|azurelinux|mariner|alinux|alios|anolis|aliyun|opencloudos|tencentos|eurolinux)
            PKG_FAMILY=rhel
            ;;
        arch|manjaro|endeavouros|garuda|cachyos)
            PKG_FAMILY=arch
            ;;
        alpine)
            PKG_FAMILY=alpine
            ;;
        opensuse-leap|opensuse-tumbleweed|sles|opensuse)
            PKG_FAMILY=suse
            ;;
        *)
            case "$PKG_ID_LIKE" in
                *debian*|*ubuntu*) PKG_FAMILY=debian ;;
                *rhel*|*fedora*|*centos*) PKG_FAMILY=rhel ;;
                *arch*) PKG_FAMILY=arch ;;
                *suse*) PKG_FAMILY=suse ;;
                *) PKG_FAMILY=unknown ;;
            esac
            ;;
    esac
}

_pkg_detect_pm() {
    _pkg_detect_family
    case "$PKG_FAMILY" in
        debian)
            if command -v apt-get >/dev/null 2>&1; then
                PKG_PM=apt
            else
                PKG_PM=""
            fi
            ;;
        rhel)
            if command -v dnf >/dev/null 2>&1; then
                PKG_PM=dnf
            elif command -v yum >/dev/null 2>&1; then
                PKG_PM=yum
            elif command -v microdnf >/dev/null 2>&1; then
                PKG_PM=microdnf
            else
                PKG_PM=""
            fi
            ;;
        arch)
            if command -v pacman >/dev/null 2>&1; then
                PKG_PM=pacman
            else
                PKG_PM=""
            fi
            ;;
        alpine)
            if command -v apk >/dev/null 2>&1; then
                PKG_PM=apk
            else
                PKG_PM=""
            fi
            ;;
        suse)
            if command -v zypper >/dev/null 2>&1; then
                PKG_PM=zypper
            else
                PKG_PM=""
            fi
            ;;
        *)
            PKG_PM=""
            ;;
    esac
}

# Map logical package names to distro-specific names.
_pkg_map_name() {
    local logical="$1"
    case "$PKG_FAMILY" in
        arch)
            case "$logical" in
                net-tools) echo "net-tools" ;;
                *) echo "$logical" ;;
            esac
            ;;
        alpine)
            case "$logical" in
                net-tools) echo "net-tools" ;;
                *) echo "$logical" ;;
            esac
            ;;
        *)
            echo "$logical"
            ;;
    esac
}

pkg_family() {
    [ -n "$PKG_FAMILY" ] || _pkg_detect_pm
    echo "$PKG_FAMILY"
}

pkg_distro_id() {
    [ -n "$PKG_ID" ] || _pkg_detect_pm
    echo "$PKG_ID"
}

pkg_ensure_supported() {
    _pkg_detect_pm
    if [ -z "$PKG_PM" ]; then
        echo "[ERROR] Unsupported or unrecognized Linux distro (ID=${PKG_ID:-unknown}, ID_LIKE=${PKG_ID_LIKE:-none})." >&2
        echo "[ERROR] Supported families: Debian/Ubuntu (apt), RHEL/Fedora (dnf/yum), Arch (pacman), Alpine (apk), openSUSE (zypper)." >&2
        return 1
    fi
}

pkg_update() {
    pkg_ensure_supported || return 1
    case "$PKG_PM" in
        apt)    apt-get update -q ;;
        dnf)    dnf -y makecache ;;
        yum)    yum -y makecache ;;
        microdnf) microdnf -y makecache ;;
        pacman) pacman -Sy --noconfirm ;;
        apk)    apk update ;;
        zypper) zypper -n refresh ;;
    esac
}

pkg_install() {
    pkg_ensure_supported || return 1
    local pkgs=()
    local p mapped
    for p in "$@"; do
        mapped=$(_pkg_map_name "$p")
        [ -n "$mapped" ] && pkgs+=("$mapped")
    done
    [ "${#pkgs[@]}" -gt 0 ] || return 0

    case "$PKG_PM" in
        apt)
            DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
            ;;
        dnf)
            dnf -y install "${pkgs[@]}"
            ;;
        yum)
            yum -y install "${pkgs[@]}"
            ;;
        microdnf)
            microdnf -y install "${pkgs[@]}"
            ;;
        pacman)
            pacman -S --noconfirm --needed "${pkgs[@]}"
            ;;
        apk)
            apk add --no-cache "${pkgs[@]}"
            ;;
        zypper)
            zypper -n install -y "${pkgs[@]}"
            ;;
    esac
}

# Install fastfetch: PPA on Debian/Ubuntu when available; standard repos elsewhere.
pkg_install_fastfetch() {
    _pkg_detect_pm
    pkg_ensure_supported || return 1

    case "$PKG_FAMILY" in
        debian)
            if command -v add-apt-repository >/dev/null 2>&1; then
                add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null \
                    || true
            fi
            pkg_update && pkg_install fastfetch
            ;;
        *)
            pkg_update
            pkg_install fastfetch || {
                echo "[WARN] fastfetch not found in distro repos (ID=$PKG_ID). Install manually: https://github.com/fastfetch-cli/fastfetch" >&2
                return 1
            }
            ;;
    esac
}

_pkg_detect_pm
