#!/bin/bash

base_dir=$(dirname "$(pwd)")

path="$base_dir/Node-Multiple-Simple/auto-start.sh"

if ! test -f "$path"; then

  echo "#!/bin/bash" > "$path"
  chmod a+x "$path"
  if ! crontab -l | grep -q "@reboot $path"; then
      (crontab -l; echo "@reboot $path") | crontab -
  fi

fi