# Shell

用于在多种 Linux 发行版上配置开发环境的 shell 脚本集合。

## 支持的发行版

| 系列 | 包管理器 | 示例 |
|------|----------|------|
| Debian/Ubuntu | apt | Debian, Ubuntu, Mint, Pop!\_OS, Kali |
| RHEL/Fedora | dnf / yum | Fedora, Rocky, AlmaLinux, CentOS Stream, **Amazon Linux 2023**, Amazon Linux 2 |
| Arch | pacman | Arch Linux, Manjaro |
| Alpine | apk | Alpine Linux |
| openSUSE | zypper | Leap, Tumbleweed, SLES |

安装逻辑集中在 `install/pkg.sh`，`web_install.sh` 与各 `install/*.sh` 脚本通过它自动检测发行版并调用对应的包管理器。

**Amazon Linux 2023**（`ID=amzn`, `VERSION_ID=2023`）使用 `dnf` 安装系统包；`fastfetch` 不在 AL2023 官方源中，脚本会自动从 GitHub 下载对应架构的 `.rpm` 安装。

## Quick Install

一键安装（需要 root）：

```bash
curl -fsSL https://raw.githubusercontent.com/LKL1235/Shell/main/web_install.sh | sudo bash -s -- --all
```

## Usage

```
web_install.sh [OPTIONS]

Options:
  --all             Install everything
  --ohmyzsh         Install oh-my-zsh + plugins (syntax-highlighting,
                    autosuggestions, completions, you-should-use) + powerlevel10k
  --meslofont       Install MesloLGS NF fonts for powerlevel10k
  --navi            Install navi + custom cheat sheets
  --networktools    Install iftop / nload / net-tools
  --systemtools     Install fastfetch
  --rootkey         Add root SSH public key to ~/.ssh/authorized_keys
  -h, --help        Show help
```

### Examples

```bash
# Install oh-my-zsh and navi only
curl -fsSL https://raw.githubusercontent.com/LKL1235/Shell/main/web_install.sh | sudo bash -s -- --ohmyzsh --navi

# Add root SSH key only
curl -fsSL https://raw.githubusercontent.com/LKL1235/Shell/main/web_install.sh | sudo bash -s -- --rootkey

# Install everything remotely
curl -fsSL https://raw.githubusercontent.com/LKL1235/Shell/main/web_install.sh | sudo bash -s -- --all
```

## Scripts

| Path | Description |
|------|-------------|
| `web_install.sh` | Unified installer entry-point |
| `install/pkg.sh` | Cross-distro package manager detection and install helpers |
| `install/ohmyzsh.sh` | oh-my-zsh + plugins + powerlevel10k |
| `install/meslo-font.sh` | Install MesloLGS NF fonts for p10k |
| `install/navi.sh` | navi cheatsheet tool |
| `install/networktools.sh` | Network monitoring tools |
| `install/systemtools.sh` | System info tools (fastfetch) |
| `install/mytheme.sh` | Zsh theme + keybindings config |
| `install/venv.sh` | Python venv helper |
| `setting/addRootKey.sh` | Standalone SSH key installer |
