#!/bin/bash

#derp
sudo rsync -aAX \
  --info=progress2 \
  --delete \
  --exclude=/home/*/Video \
  --exclude=/home/*/Music \
  --exclude=/home/*/Pictures \
  --exclude=/home/*/Downloads \
  --exclude=/home/lost+found \
  --exclude=/home/*/.thumbnails \
  --exclude=/home/*/.cache/mozilla \
  --exclude=/home/*/.cache/chromium/* \
  --exclude=/home/*/.local/share/Trash \
  --exclude=/home/*/.gvfs \
  --exclude=/home/*/.local/share/Steam \
  --exclude=/dev/* \
  --exclude=/steam_library \
  --exclude=/proc/* \
  --exclude=/sys/* \
  --exclude=/tmp/* \
  --exclude=/run/* \
  --exclude=/mnt/* \
  --exclude=/media/* \
  --exclude=/lost+found \
  / \
  /mnt/mybook/archbackup

