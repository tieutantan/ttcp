#!/bin/bash

# `./node.sh` is default v20, and `./node.sh 50` is custom version

if [ $# -eq 0 ]; then
  version="20"
elif [ $# -eq 1 ]; then
  version="$1"
else
  echo "Usage: $0 [node_version]"
  exit 1
fi

sudo apt update -y && apt upgrade -y
sudo curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh
sudo chmod 500 nsolid_setup_deb.sh
yes | sudo ./nsolid_setup_deb.sh "$version"
sudo apt update -y && sudo apt install nodejs -y
sudo npm install pm2@latest -g && sudo pm2 install pm2-logrotate
sudo apt-get install libcap2-bin && sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``

rm -f nsolid_setup_deb.sh  # Remove the script after installation
node -v
npm -v
