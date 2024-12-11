#!/bin/bash

#Version listing:
#Node.js 23.x: https://deb.nodesource.com/setup_23.x
#Node.js 22.x: https://deb.nodesource.com/setup_22.x
#Node.js 20.x: https://deb.nodesource.com/setup_20.x
#Node.js 18.x: https://deb.nodesource.com/setup_18.x
#Node.js 16.x: https://deb.nodesource.com/setup_16.x
#Node.js 14.x: https://deb.nodesource.com/setup_14.x
#Node.js 12.x: https://deb.nodesource.com/setup_12.x

# This script installs Node.js from NodeSource for a specified major version.
# Usage: ./nodejs.sh <version>
# Example: ./nodejs.sh 24 will install Node.js 24.x

# Default to 22 if no argument is provided
NODE_VERSION=${1:-22}

# Construct the NodeSource setup URL
SETUP_URL="https://deb.nodesource.com/setup_${NODE_VERSION}.x"

echo "Installing Node.js ${NODE_VERSION}.x from ${SETUP_URL}"

# Download the setup script
curl -fsSL "${SETUP_URL}" -o nodesource_setup.sh

# Run the NodeSource setup script
sudo -E bash nodesource_setup.sh

# Install Node.js
sudo apt-get update
sudo apt-get install -y nodejs

# Ensure pm2 is installed globally, along with pm2-logrotate
if ! command -v pm2 &> /dev/null; then
  sudo npm install -g pm2@latest
  sudo pm2 install pm2-logrotate
fi

# Clean up
rm -f nodesource_setup.sh

# Print the installed versions
echo "Installed versions:"
node -v
npm -v
