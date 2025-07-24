#!/bin/bash
set -e
# 当前用户为 root 用户，执行 apt update 命令
if [ $(id -u) -eq 0 ]; then
    apt update
    apt install zsh
fi

yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use
cp ~/.zshrc ~/.zshrc.back
mkdir ~/.myshell
cp ./mytheme.sh ~/.myshell/mytheme.sh
cp ./venv.sh ~/.myshell/venv.sh
echo "source ~/.myshell/mytheme.sh" >>~/.zshrc
echo "oh-my-zsh 安装完成。"
