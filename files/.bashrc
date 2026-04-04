
#export PATH=/usr/local/bin:$PATH
export PATH=$PATH:~/scripts/personal/bash:~/scripts/personal/python:~/bin

if [[ -f ~/.tmux.completion.bash ]]; then
    . ~/.tmux.completion.bash
fi

if [[ -f ~/.git-completion.bash ]]; then
    . ~/.git-completion.bash
fi

# Load shellenv for homebrew if installed
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Load ruby
if command -v rbenv > /dev/null
then
    # Used when ruby is installed
    eval "$(rbenv init -)"
fi

#TODO: Generalize this for any specific bashrc.
if [[ -f ~/.work.bashrc ]]; then
    . ~/.work.bashrc
fi


#export PS1="[\u@\h \W]\\$ "
# TODO: this doesn't work in Mac and/or Zsh
if [[ ! $SHELL =~ /zsh ]]; then
    if [[ -f ~/.git-prompt.sh ]]; then
        export GIT_PS1_SHOWDIRTYSTATE="true"
        export GIT_PS1_SHOWUNTRACKEDFILES="true"
        export GIT_PS1_SHOWUPSTREAM="auto"
        source ~/.git-prompt.sh
        export PS1="\[\e[00;32m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;31m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;36m\]\W\[\e[0m\]\[\e[00;37m\]\[\e[0m\]\[\e[00;33m\]\$(__git_ps1)\[\e[0m\]\[\e[00;37m\] \n$\[\e[0m\] "
    else
        export PS1="\[\e[00;32m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;31m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;36m\]\W\[\e[0m\]\[\e[00;37m\]\[\e[0m\]\[\e[00;33m\]\[\e[0m\]\[\e[00;37m\] \n$\[\e[0m\] "
    fi
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# User Customization
alias ebashrc="vi ~/.bashrc && source ~/.bashrc"
alias sbrc="source ~/.bashrc"
alias ls="ls -G"
alias ll="ls -alsh"
alias g=git
alias todo='fgrep -r -e "TODO" '
alias vi="vim"
alias evimrc="vim ~/.vimrc"
alias dotrepo="cd ~/git/dotfiles"
alias import_dotfiles="python3 ~/git/dotfiles/import.py ~ ~/git/dotfiles import && source ~/.bashrc"
alias backup_dotfiles="python3 ~/git/dotfiles/import.py ~ ~/git/dotfiles backup"

