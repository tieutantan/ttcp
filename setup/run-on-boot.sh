#!/bin/bash

base_dir=$(dirname "$(pwd)")

path="$base_dir/ttcp/auto-run.sh"

if ! crontab -l 2>/dev/null; then
  echo "Creating new crontab for the user"
  echo "@reboot $path" | crontab -
elif ! crontab -l | grep -q "@reboot $path"; then
  (crontab -l; echo "@reboot $path") | crontab -
fi
