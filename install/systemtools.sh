#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pkg.sh
source "$SCRIPT_DIR/pkg.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Run as root (e.g. sudo $0)" >&2
    exit 1
fi

pkg_ensure_supported
pkg_install_fastfetch
echo "System tools installed ($(pkg_distro_id)/$(pkg_family))."
