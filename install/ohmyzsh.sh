#!/bin/bash
set -e
# 当前用户为 root 用户，执行 apt update 命令
apt update
apt install zsh -y
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
cp ~/.zshrc ~/.zshrc.back
touch ~/.mytheme.sh
cat << 'EOF' > ~/.mytheme.sh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git history zsh-syntax-highlighting zsh-autosuggestions command-not-found safe-paste you-should-use)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
TERM=xterm-256color
if [[ $SHELL =~ "zsh" ]] ; then
    bindkey  '^[[H'   beginning-of-line
    bindkey  '^[[F'   end-of-line
    bindkey  '^[[3~'  delete-char
fi

function chpwd() {
    ls -al
}
function precmd(){
    echo $?>~/.prev_exit_code
}
source $ZSH/oh-my-zsh.sh
EOF
echo "source ~/.mytheme.sh">>~/.zshrc
echo "oh-my-zsh 安装完成。"

