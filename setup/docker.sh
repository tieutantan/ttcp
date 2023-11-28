#!/bin/bash

# Install Newest Docker + Docker Compose on Ubuntu22

# Update the package index
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
sudo add-apt-repository \
   "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the package index again
sudo apt-get update

# Install the latest version of Docker Engine and containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo chmod 777 /var/run/docker.sock
sudo systemctl enable docker # enable docker service on boot

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt update -y && sudo apt install nodejs -y
sudo npm install pm2@latest -g && sudo pm2 install pm2-logrotate

sudo apt-get install libcap2-bin && sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``

# Print Docker and Docker Compose version
docker --version
docker-compose --version