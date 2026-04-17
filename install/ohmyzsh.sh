#!/bin/bash
set -e
# 当前用户为 root 用户，执行 apt update 命令
if [ $(id -u) -eq 0 ]; then
    apt update
    apt install -y zsh curl git fontconfig
fi

yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use

# Install MesloLGS NF fonts for powerlevel10k.
mkdir -p ~/.local/share/fonts
curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" -o ~/.local/share/fonts/"MesloLGS NF Regular.ttf"
curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" -o ~/.local/share/fonts/"MesloLGS NF Bold.ttf"
curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" -o ~/.local/share/fonts/"MesloLGS NF Italic.ttf"
curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" -o ~/.local/share/fonts/"MesloLGS NF Bold Italic.ttf"
fc-cache -f ~/.local/share/fonts

cp ~/.zshrc ~/.zshrc.back
mkdir -p ~/.myshell
cp ./mytheme.sh ~/.myshell/mytheme.sh
cp ./venv.sh ~/.myshell/venv.sh
echo "source ~/.myshell/mytheme.sh" >>~/.zshrc
echo "oh-my-zsh 安装完成。"
