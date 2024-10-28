# TTCP

*The Free Simple Control Panel For The Server With Multiple Apps And Domains*

This tool is ideal for individuals who want **a straightforward manner**.

- Run multiple apps with multiple ports and dockerized Nginx.
- With domains on a single server + SSL from CDN.
- A convenient way to create, list, and remove Nginx `.conf` for each domain.
- Easy to run and manage the commands on server boot and multiple SSH keys.

## | [Setup](#setup-ttcp) | [Menu](#main-menu) |

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

Default v22 (optional)
```shell
./setup/nodejs.sh
```

Custom Version (optional)
```shell
./setup/nodejs.sh 24
```

### 3. Run script whenever server reboot (optional)
You can put (ex: start services, clear cache, schedule...) to `startup.sh` example:
```shell
#!/bin/bash
nodemon /path/to/server.js
cd /home/www/domain.com/app && npm run production
pm2 startOrReload /path/other/ecosystem.config.js
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
|| TTCP MENU ||
---------------
[1] Add Domain
[2] List Domain
[3] Remove Domain
---------------
[4] Add SSH Key
[5] List SSH Keys
---------------
[6] List Clone Commands
[7] Reload Nginx
[8] Enable Auto-Run on Startup
[9] Disable Auto-Run on Startup
---------------
[98] Start TTCP
[99] Update TTCP
---------------
[0] Exit / Ctrl+C
Enter your choice: 99 (ex: Update TTCP)
```

### [1] Add Domain
- Enter a domain with the app's local port.
- The `.conf` files will be created in `/ttcp/config/` directory.
- File Created: `/ttcp/config/tantn.com-1111.conf`
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

### [2] List Domains | with the app's local port.
```shell
---------------------------
1 > ./github.com-39
2 > ./example.com-79
3 > ./tantn.com-68
TTCP: List 3 Domains.
---------------------------
```

### [4] Add SSH Key | Create Multiple SSH Keys For Each Repository

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

### [5] List SSH Keys
- All keys inside `~/.ssh/ttcp_ssh_key/`
```shell
/home/ubuntu/.ssh/ttcp_ssh_key/Laraker.pub
/home/ubuntu/.ssh/ttcp_ssh_key/ttcp.pub
/home/ubuntu/.ssh/ttcp_ssh_key/wxt.pub
```

### [6] List Clone Commands

```shell
git clone git@ttcp:tieutantan/ttcp.git
git clone git@vue:vuejs/vue.git
git clone git@kotlin:JetBrains/kotlin.git
```

----

If you run into a bug or want to work with me to improve it, 
please consider submitting a pull request. 
Your help will be much appreciated by the entire community. Thank you!
