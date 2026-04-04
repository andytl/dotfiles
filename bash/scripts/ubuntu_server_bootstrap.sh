#!/bin/bash

# Run with ubuntu_server_bootstrap_remote.sh
# or use as
# sudo bash ~/scripts/ubuntu_server_bootstrap.sh

echo "doing stuff as $(whoami) on behalf of $SUDO_USER"

# Add no password sudoers
SUDOERS="/etc/sudoers"
HAS_NOPASS_SUDO=$(grep -E "NOPASSWD" $SUDOERS)
if [[ -z $HAS_NOPASS_SUDO ]]
then
    echo "Adding no password sudo"
    export EDITOR=/tmp/visudo_editor_temp.sh
    echo "#!/bin/bash" > $EDITOR
    echo "sed -r \"s/(^%\w+\s+ALL=\(.*\)\s+)(ALL$)/\1NOPASSWD: \2/\" -i \$2" >> $EDITOR
    chmod ugo+rwx $EDITOR
    #SUDOERS="/home/andytl/Downloads/sudoers_test"; visudo -f $SUDOERS
    visudo
    rm $EDITOR
else
    echo "Already have no password sudo"
fi


#Install new packages
apt update
apt-get -y install \
    git \

# Clone dotfiles repo for user
DOTREPO="/home/$SUDO_USER/git/dotfiles"
if [[ ! -e $DOTREPO ]]
then
    echo "Cloning and applying dotfiles"
    sudo --user=$SUDO_USER mkdir -p $DOTREPO
    sudo --user=$SUDO_USER git clone https://github.com/andytl/dotfiles.git $DOTREPO
    sudo --user=$SUDO_USER python3 "$DOTREPO/import.py" "/home/$SUDO_USER" "/home/$SUDO_USER/git/dotfiles" import
fi

echo "press key to exit"
read $IGNORE