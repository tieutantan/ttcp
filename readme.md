# TTCP

*The Free Simple Control Panel For The Server With Multiple Apps And Domains*

This tool is ideal for individuals who want **a straightforward manner**.

- Run multiple apps with multiple ports and dockerized Nginx.
- With domains on a single server + SSL from CDN.
- A convenient way to create, list, and remove Nginx `.conf` for each domain.
- Easy to run and manage the commands on server boot and multiple SSH keys.

## | [Setup](#setup-ttcp) | [Instruction](#instruction) | [Create Multiple SSH keys](#create-multiple-ssh-keys-for-each-repository) | [Others](#others) |

## Setup TTCP

### 1. Clone this repository.
```commandline
git clone https://github.com/tieutantan/ttcp.git
```

### 2. Move
```commandline
cd ttcp
```

### 3. Install Docker

Newest Version
```shell
./setup/docker.sh
```

Default v20 (optional)
```shell
./setup/nodejs.sh
```

Custom Version (optional)
```shell
./setup/nodejs.sh 18
```

### 4. Start NMS
```commandline
docker-compose up -d --build
```

### 5. If need run cmd after server reboot (ex: start apps, clear cache, schedule...) (optional)

You can put commands to start any app to `ttcp/auto-run.sh`

```commandline
#!/bin/bash

nodemon /path/to/server.js
cd /home/www/domain.com/app
npm run production
pm2 startOrReload /path/other/ecosystem.config.js
```

Apply code run on boot.
```shell
./setup/run-on-boot.sh
```

----

## Instruction

### 1. Add Domain
```commandline
docker exec ttcp add [domain] [app_local_port]
```
```commandline
docker exec ttcp add tantn.com 1111
```
File Created: `/ttcp/config/tantn.com-1111.conf`
```commandline
server {
    client_max_body_size 20M;
    server_name tantn.com;
    location / {
        proxy_pass http://host.docker.internal:1111;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        access_log off;
    }
}
```

### 2. List Domains as domain-port
```commandline
docker exec ttcp list
```

```commandline
root@tt:~/ttcp# docker exec ttcp list
===========================
1 > ./meow.city-1002
2 > ./bunny.org-1101
3 > ./tantn.com-1111
NMS: List 3 Domains.
===========================
```

### 3. Remove Domain
```commandline
docker exec ttcp remove tantn.com
```

----

## Create Multiple SSH Keys For Each Repository
Support multiple platform and cloud-based service for software development and version control.

#### 1. Create Key
```shell
./setup/ssh-keygen.sh [git_repo_url]
```

```shell
root@tt:~/ttcp# ./setup/ssh-keygen.sh git@github.com:usname/repo-name.git
======================================================
TTCP: CMD To Clone:
git clone git@repo-name:usname/repo-name.git
======================================================
TTCP: Your SSH Public Key:
--
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxlYdqAchLoP2fFUBYIE/8gyZaf4vBC9
dxb8dYqoKhaCUt4+7XcAJ/1SQJAqdaIZIaVWAkgX8MncpWMYZY9EEs513olIco/rqPR2pq
DyPEU/2vhR5UncndI8v6+N7n7xCt5TMbIComAPB3CHh3flc4gGBAxSg+phbS6y5DwJitei
t3jM7rNXyRBT8xKraCUpD7HPHeCYZ7bOzvJJQo/WkuxnI6p8pCSDoLZfOGfmWS8QbjQ5tm
NFSPZduTGZdbkZXmW2FCEKJWpHx7h2NarSR61OFvcfpJNuFztYrsAXOFKbhTzZSHwilDhq
mci5BCRd3GbafkkwQMixJEqQHW+qSD root@nw.azure.cloud
--
======================================================
```

#### 1.2. Add Deploy Key to GitHub (optional)
- Copy public key display on CMD > add to GitHub Repo > Settings > Deploy keys

#### 2. Clone repository
- Now your repo URL format and key will display
- All keys inside `~/.ssh/ttcp_ssh_key/`

----

## Others

#### Reload NGINX
```commandline
docker exec ttcp nginx -s reload
```

#### Git pulls the newest version of NMS
```commandline
git fetch --all && git reset --hard origin/master && git pull
```

----

If you run into a bug or want to work with me to improve it, 
please consider submitting a pull request. 
Your help will be much appreciated by the entire community. Thank you!