#!/bin/bash

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y
sudo usermod -aG docker ${USER}
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chmod 777 /var/run/docker.sock
sudo systemctl enable docker # enable docker service on boot

curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt update -y && sudo apt install nodejs -y

sudo apt-get install libcap2-bin && sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``