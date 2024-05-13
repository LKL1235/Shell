
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git history zsh-syntax-highlighting zsh-autosuggestions command-not-found safe-paste you-should-use)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
TERM=xterm-256color
if [[ \"$SHELL\" =~ "zsh" ]] ; then
    bindkey  '^[[H'   beginning-of-line
    bindkey  '^[[F'   end-of-line
    bindkey  '^[[3~'  delete-char
fi

function chpwd() {
    ls -al
}
function precmd(){
	echo \"$?\">~/.prev_exit_code
}
source $ZSH/oh-my-zsh.sh