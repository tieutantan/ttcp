#!/bin/bash

# `./node.sh` is default v22, and `./node.sh 50` is custom version

if [ $# -eq 0 ]; then
  version="22"
elif [ $# -eq 1 ]; then
  version="$1"
else
  echo "Usage: $0 [node_version]"
  exit 1
fi

# Update the package index
sudo apt update -y

# Install necessary packages for Node.js
sudo apt install -y curl libcap2-bin

# Download and run the NodeSource setup script
sudo curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh
sudo chmod 500 nsolid_setup_deb.sh
yes | sudo ./nsolid_setup_deb.sh "$version"

# Install Node.js and npm
sudo apt update -y
sudo apt install -y nodejs

# Install pm2 and pm2-logrotate
sudo npm install pm2@latest -g
sudo pm2 install pm2-logrotate

# Set capabilities for Node.js to bind to low ports
# shellcheck disable=SC2046
# shellcheck disable=SC2006
sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``

# Clean up
rm -f nsolid_setup_deb.sh

# Print versions
node -v
npm -v