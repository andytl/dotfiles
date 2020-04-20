
#export PATH=/usr/local/bin:$PATH
export PATH=$PATH:~/scripts:~/python:~/bin

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

if [[ -n "$(which rbenv)" ]]
then
    # Used when ruby is installed
    eval "$(rbenv init -)"
fi

if [[ -f ~/.nvm ]]; then
    export NVM_DIR="/Users/andytl/.nvm"
fi

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# MacOS Specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
fi

# User Customization

run_backup() {
    # this needs 7zip and rclone
    mkdir ~/backup_staging
    rm ~/backup_staging/*
    ~/scripts/7zencrbackup.sh ~/Sync ~/backup_staging/backup_Sync_$(date +"%Y-%m-%d_%H-%M").7z ~/Sync/BackupConfig/BackupKey
    #TODO rclone it without encryption
    echo "Pushing zipped file to cloud storage"
    rclone sync ~/backup_staging google_drive:RcloneBackup/ZipBackup
    rclone sync ~/backup_staging onedrive:RcloneBackup/ZipBackup
    rclone sync ~/backup_staging dropbox:RcloneBackup/ZipBackup
}
run_rclone_backup() {
    # this needs rclone
    # Since the rclone config already specifies the directory for encrypted backup,
    # this just needs to reference the "root" folder on the remote
    rclone sync ~/Sync crypt_google_drive:
    rclone sync ~/Sync crypt_onedrive:
    rclone sync ~/Sync crypt_dropbox:
}
restore_rclone_backup() {
    echo "Pick a source before running"
    #rclone sync crypt_google_drive: ~/Sync
    #rclone sync crypt_onedrive: ~/Sync
    #rclone sync crypt_dropbox: ~/Sync
}


alias ebashrc="vi ~/.bash_profile && source ~/.bash_profile"
alias sbrc="source ~/.bash_profile"
alias ls="ls -G"
alias ll="ls -alsh"
alias g=git
alias todo='fgrep -r -e "TODO" '
alias vi="vim"
alias evimrc="vim ~/.vimrc"
alias dotrepo="cd ~/git/dotfiles"
alias import_dotfiles="python3 ~/git/dotfiles/import.py ~ ~/git/dotfiles import && source ~/.bash_profile"
alias backup_dotfiles="python3 ~/git/dotfiles/import.py ~ ~/git/dotfiles backup"

