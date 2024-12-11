#!/bin/bash

#Version listing:
#Node.js 23.x: https://deb.nodesource.com/setup_23.x
#Node.js 22.x: https://deb.nodesource.com/setup_22.x
#Node.js 20.x: https://deb.nodesource.com/setup_20.x
#Node.js 18.x: https://deb.nodesource.com/setup_18.x
#Node.js 16.x: https://deb.nodesource.com/setup_16.x
#Node.js 14.x: https://deb.nodesource.com/setup_14.x
#Node.js 12.x: https://deb.nodesource.com/setup_12.x

# Download the setup script
curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh

# Run the script
sudo -E bash nodesource_setup.sh

sudo apt-get install nodejs -y

# check if not exist pm2 then install it
if ! command -v pm2 &> /dev/null
then
  sudo npm install pm2@latest -g
  sudo pm2 install pm2-logrotate
fi

# Remove the setup script
rm -f nodesource_setup.sh

# Print versions
node -v
npm -v