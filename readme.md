# TTCP

*The Free Simple Control Panel For The Server With Multiple Apps And Domains*

This tool is ideal for individuals who want **a straightforward manner**.

- Run multiple apps with multiple ports and dockerized Nginx.
- With domains on a single server + SSL from CDN.
- A convenient way to create, list, and remove Nginx `.conf` for each domain.
- Easy to run and manage the commands on server boot and multiple SSH keys.

## | [Setup](#setup-ttcp) | [Instruction](#instruction) | [Menu](#main-menu) |

## Setup TTCP

### 1. Clone this and go to directory ttcp
```shell
git clone https://github.com/tieutantan/ttcp.git && cd ttcp
```

### 2. Install Docker on Ubuntu 22, 24

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

### 3. Start TTCP
```shell
docker-compose up -d --build
```

### 4. If need run cmd after server reboot (optional)

You can put (ex: start services, clear cache, schedule...) to `startup.sh`

----

## Instruction

### 1. Add Domain
```shell
docker exec ttcp add [domain] [app_local_port]
```
```shell
docker exec ttcp add tantn.com 1111
```
File Created: `/ttcp/config/tantn.com-1111.conf`
```shell
server {
    client_max_body_size 200M;
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
```shell
docker exec ttcp list
```

```shell
root@tt:~/ttcp# docker exec ttcp list
===========================
1 > ./meow.city-1002
2 > ./bunny.org-1101
3 > ./tantn.com-1111
TTCP: List 3 Domains.
===========================
```

### 3. Remove Domain
```shell
docker exec ttcp remove tantn.com
```

----

## Main Menu

```commandline
./menu.sh
```

Select the desired option by entering the corresponding number and pressing Enter.

```shell
ubuntu@aws:~/ttcp$ ./menu.sh
---------------
-[ TTCP MENU ]-
---------------
1. Add SSH Key
2. List SSH Keys
3. List Clone Commands
4. Reload Nginx
5. Enable Auto-Run on Startup
6. Disable Auto-Run on Startup
99. Update TTCP
0. Exit / Ctrl+C
Enter your choice: 99
```

### 1. Add SSH Key | Create Multiple SSH Keys For Each Repository

```shell
root@tt:~/ttcp#
------------------------------------------------------
TTCP: CMD To Clone:
git clone git@repo-name:user-name/repo-name.git
------------------------------------------------------
TTCP: Your SSH Public Key:
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxlYdqAchLoP2fFUBYIE/8gyZaf4vBC9
NFSPZduTGZdbkZXmW2FCEKJWpHx7h2NarSR61OFvcfpJNuFztYrsAXOFKbhTzZSHwilDhq
mci5BCRd3GbafkkwQMixJEqQHW+qSD root@nw.azure.cloud
```

### 2. List SSH Keys
- All keys inside `~/.ssh/ttcp_ssh_key/`
```shell
/home/ubuntu/.ssh/ttcp_ssh_key/Laraker.pub
/home/ubuntu/.ssh/ttcp_ssh_key/ttcp.pub
/home/ubuntu/.ssh/ttcp_ssh_key/wxt.pub
```

### 3. List Clone Commands

```shell
git clone git@ttcp:tieutantan/ttcp.git
git clone git@vue:vuejs/vue.git
git clone git@kotlin:JetBrains/kotlin.git
```

----

If you run into a bug or want to work with me to improve it, 
please consider submitting a pull request. 
Your help will be much appreciated by the entire community. Thank you!
