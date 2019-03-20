
alias ls="ls -G"
alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
alias ebashrc="vi ~/.bash_profile && source ~/.bash_profile"
alias ll="ls -alsh"

alias g=git
alias gs="git status"
alias gdc="git diff --color"
alias glg="git log --graph --color --decorate=full --all"
alias gp="git pull"
alias gst="git stash"
alias gsp="git stash pop"

alias todo='fgrep -r -e "TODO" '

alias vi="vim"
alias evimrc="vim ~/.vimrc"

export PATH=/usr/local/bin:$PATH
export PATH=~/bin:$PATH

if [ -f ~/.tmux.completion.bash ]; then
  . ~/.tmux.completion.bash
fi

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

#export PS1="[\u@\h \W]\\$ "
if [ -f ~/.git-prompt.sh ]; then
	export GIT_PS1_SHOWDIRTYSTATE="true"
	export GIT_PS1_SHOWUNTRACKEDFILES="true"
	export GIT_PS1_SHOWUPSTREAM="auto"
	source ~/.git-prompt.sh
	export PS1="\[\e[00;32m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;31m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;36m\]\W\[\e[0m\]\[\e[00;37m\]\[\e[0m\]\[\e[00;33m\]\$(__git_ps1)\[\e[0m\]\[\e[00;37m\] \n$\[\e[0m\] "
else
  export PS1="\[\e[00;32m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;31m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;36m\]\W\[\e[0m\]\[\e[00;37m\]\[\e[0m\]\[\e[00;33m\]\[\e[0m\]\[\e[00;37m\] \n$\[\e[0m\] "
fi

eval "$(rbenv init -)"
export NVM_DIR="/Users/andytl/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8




