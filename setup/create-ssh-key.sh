#!/bin/bash

if [ -z "$1" ]; then
  echo "NMS: Error key_name is required: ./setup/create-ssh-key.sh [key_name]"
  exit 1
fi

key_name="$1"
ssh_config=~/.ssh/config

# create ~/.ssh/config if not exist
if [ ! -f "$ssh_config" ]; then
  touch "$ssh_config"
fi

# create folder if not exist
if test ! -d ~/.ssh/nms_ssh_key; then
    mkdir -p ~/.ssh/nms_ssh_key
fi

ssh-keygen -b 2048 -t rsa -f ~/.ssh/nms_ssh_key/"$key_name" -q -N ""

ssh_key_block="
# start $key_name
Host $key_name
  HostName github.com
  User git
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/nms_ssh_key/$key_name
# end $key_name
"

# remove if ssh_key_block is exist
if grep -q "# start $key_name" "$ssh_config"; then
    sed -i "/^# start $key_name$/,/^# end $key_name$/d" "$ssh_config"
fi

# add ssh_key_block
echo "$ssh_key_block" >> "$ssh_config"
sed -i '/^$/d' "$ssh_config"

echo "NMS: your git clone as: git@$key_name:USERNAME/repo_name.git"
echo "NMS: your "~/.ssh/nms_ssh_key/"$key_name".pub
echo "--------"
cat < ~/.ssh/nms_ssh_key/"$key_name".pub
echo "--------"