# Shell

A collection of shell scripts for setting up a development environment on Debian/Ubuntu.

## Quick Install

Run everything in one command (requires root):

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
| `install/ohmyzsh.sh` | oh-my-zsh + plugins + powerlevel10k |
| `install/meslo-font.sh` | Install MesloLGS NF fonts for p10k |
| `install/navi.sh` | navi cheatsheet tool |
| `install/networktools.sh` | Network monitoring tools |
| `install/systemtools.sh` | System info tools (fastfetch) |
| `install/mytheme.sh` | Zsh theme + keybindings config |
| `install/venv.sh` | Python venv helper |
| `setting/addRootKey.sh` | Standalone SSH key installer |
