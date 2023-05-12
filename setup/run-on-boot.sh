#!/bin/bash

base_dir=$(dirname "$(pwd)")

path="$base_dir/Node-Multiple-Simple/auto-run.sh"

if ! test -f "$path"; then
  echo "Error: $path does not exist. Code execution stopped."
  exit 1
fi

echo "#!/bin/bash" > "$path"
chmod a+x "$path"
if ! crontab -l | grep -q "@reboot $path"; then
  (crontab -l; echo "@reboot $path") | crontab -
fi