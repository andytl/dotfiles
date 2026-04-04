#!/bin/bash -x

# This script is self-executing. When running on the host, $REMOTE is not set.
if [[ -z "$1" ]]
then
    echo "Usage: $0 username@hostname"
    exit 1
else
    echo "Calling script on remote."

    #METHOD1
    SCRIPT=$(which ubuntu_server_bootstrap.sh)
    chmod u+x $SCRIPT
    scp $SCRIPT "$1:~/server_bootstrap.sh"
    # Call this script again from the target.
    #ssh -t "$1" "sudo bash ~/server_bootstrap.sh"
    ssh -t "$1" "sudo bash ~/server_bootstrap.sh"
    ssh "$1" "rm ~/server_bootstrap.sh"

    #METHOD2
    #ssh -t "$1" REMOTE=1 "sudo bash -s" < $(which $0)
    exit 0
fi
