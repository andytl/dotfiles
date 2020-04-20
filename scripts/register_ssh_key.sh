#!/bin/bash

#
# Registers your ssh key on the remote host.
#

# This script is self-executing. When running on the host, $KEYTOADD is not set.
if [[ -z "$KEYTOADD" && -z "$1" ]]
then
    echo "Usage: $0 username@hostname"
    exit 1
elif [[ -z "$KEYTOADD" ]]
then
    echo "Adding ssh key for $1"
    echo "0 = $0"
    # Call this script again from the target.
    ssh "$1" KEYTOADD="\"$(<~/.ssh/id_rsa.pub)\"" "bash -s" < $(which $0)
    exit 0
fi

# Now we are running on the remote.
SSHFILE=~/.ssh/authorized_keys

if [[ ! -f "$SSHFILE" ]]
then
    touch $SSHFILE
    chmod go-rwx $SSHFILE
fi

HASKEY=$(grep -F "$KEYTOADD" $SSHFILE)
if [[ ! -n "$HASKEY" ]]
then
    echo "$KEYTOADD" >> $SSHFILE
fi