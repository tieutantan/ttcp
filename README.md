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

### 3. Install Node.js + PM2 (optional)

Default v20 LTS (recommended)
```shell
./setup/nodejs.sh
```

Specific Version (optional): 12, 14, 16, 18, 20, 22, 23, latest
```shell
./setup/nodejs.sh 18
```

Latest Version
```shell
./setup/nodejs.sh latest
```

**Note:** PM2 and PM2-LogRotate are automatically installed as REQUIRED components.

----

## Main Menu

### Run the Menu
```shell
./menu.sh
```

### Menu Display (Refactored - v2)

Select the desired option by entering the corresponding number and pressing Enter.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    🚀 TTCP CONTROL PANEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Docker & TTCP Status: RUNNING

Main Menu Options:

  Domain Management:
    ➜ [1] Add Domain
    ➜ [2] List Domains
    ➜ [3] Remove Domain

  SSH Key Management:
    ➜ [4] Add SSH Key
    ➜ [5] List SSH Keys

  Repository & Services:
    ➜ [6] List Clone Commands
    ➜ [7] Reload Nginx

  System Management:
    ➜ [98] Start TTCP
    ➜ [99] Update TTCP

  ➜ [0] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Enter your choice (0-7, 98-99):
```

### Menu Features
- ✅ **Beautiful Design** - Unicode borders, colors, and emoji indicators
- ✅ **Real-time Status** - Shows Docker & TTCP container status
- ✅ **Input Validation** - Validates domain format, port range (1-65535), Git URL
- ✅ **Error Handling** - Clear error messages with helpful hints
- ✅ **Fast Navigation** - Loop-based (no recursion), unlimited iterations
- ✅ **Progress Feedback** - Shows what operation is being performed

---

### [1] Add Domain
- **Domain Validation:** Must be valid FQDN format (e.g., example.com, app.example.com)
- **Port Validation:** Must be numeric between 1-65535
- You can add multiple different domains to the same app local port.
- The `.conf` files will be created in `/ttcp/config/` directory.
- **Example:** Adding domain `tantn.com` with port `1111`
- File Created: `/ttcp/config/tantn.com-1111.conf`
```shell
✅ Adding domain: tantn.com → port 1111
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Domain added successfully!
```

Generated Nginx Configuration:
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

### [2] List Domains
Lists all currently added domains with their ports.

```shell
━━━━━━━━━━━━━━━━━━━━━━━━━
1 > ./github.com-39
2 > ./example.com-79
3 > ./tantn.com-68
TTCP: List 3 Domains.
━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Domains listed
```

### [3] Remove Domain
- **Domain Validation:** Must be valid FQDN format
- Removes the domain configuration and reloads Nginx
- Example: `tantn.com`

```shell
✅ Removing domain: tantn.com
━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Domain removed successfully!
```

### [4] Add SSH Key | Create Multiple SSH Keys For Each Repository

- **Git URL Validation:** Must be valid format: `git@github.com:username/repo.git`
- Creates SSH key pair for secure git authentication
- Stores keys in `~/.ssh/ttcp_ssh_key/` directory
- Automatically adds entry to `~/.ssh/config`

```shell
✅ Adding SSH Key...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Enter git repository URL (e.g., git@github.com:user/repo.git): git@github.com:tieutantan/ttcp.git

══════════════════════════════════════════
TTCP: CMD To Clone:
git clone git@ttcp:tieutantan/ttcp.git
══════════════════════════════════════════
TTCP: Your SSH Public Key:
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxlYdqAchLoP2fFUBYIE/8gyZaf4vBC9
NFSPZduTGZdbkZXmW2FCEKJWpHx7h2NarSR61OFvcfpJNuFztYrsAXOFKbhTzZSHwilDhq
mci5BCRd3GbafkkwQMixJEqQHW+qSD root@nw.azure.cloud
══════════════════════════════════════════
✅ SSH key added successfully!
```

**Next Step:** Add the displayed SSH public key to your GitHub/GitLab account

### [5] List SSH Keys
- All keys inside `~/.ssh/ttcp_ssh_key/`
```shell
/home/ubuntu/.ssh/ttcp_ssh_key/Laraker.pub
/home/ubuntu/.ssh/ttcp_ssh_key/ttcp.pub
/home/ubuntu/.ssh/ttcp_ssh_key/wxt.pub
```

### [5] List SSH Keys
- Lists all SSH keys stored in `~/.ssh/ttcp_ssh_key/`
- Shows filenames of generated public keys

```shell
━━━━━━━━━━━━━━━━━━━━━━━━━━
/home/ubuntu/.ssh/ttcp_ssh_key/ttcp.pub
/home/ubuntu/.ssh/ttcp_ssh_key/vue.pub
/home/ubuntu/.ssh/ttcp_ssh_key/kotlin.pub
✅ SSH keys listed
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### [6] List Clone Commands
- Lists all git clone commands from registered SSH keys
- Automatically extracted from `~/.ssh/config`

```shell
━━━━━━━━━━━━━━━━━━━━━━━━━━
git clone git@ttcp:tieutantan/ttcp.git
git clone git@vue:vuejs/vue.git
git clone git@kotlin:JetBrains/kotlin.git
✅ Clone commands listed
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### [7] Reload Nginx
- Reloads Nginx configuration without restart
- Useful after manual config changes
- Takes effect within seconds

```shell
ℹ️ Reloading Nginx...
━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Nginx reloaded successfully!
```

### [98] Start TTCP
- Starts Docker container and builds images if needed
- Shows container status

```shell
ℹ️ Starting TTCP container...
━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TTCP container started!

Container Status:
CONTAINER ID   IMAGE        STATUS        PORTS      NAMES
abc123def456   ttcp:latest  Up 2 seconds  80->80/80  ttcp
```

### [99] Update TTCP
- Pulls latest changes from git repository
- Rebuilds Docker container with new code
- Useful for getting bug fixes and new features

```shell
ℹ️ Updating TTCP from git...
✅ Git repository updated

ℹ️ Rebuilding Docker container...
✅ TTCP updated successfully!

Container Status:
CONTAINER ID   IMAGE        STATUS        PORTS      NAMES
abc123def456   ttcp:latest  Up 2 seconds  80->80/80  ttcp
```

---

## Troubleshooting

### ❌ Invalid Domain Format
```
❌ Invalid domain format: domain_with_underscore
Expected format: example.com or app.example.com
```
**Solution:** Use dots (.) as separators, not underscores

### ❌ Invalid Port
```
❌ Invalid port: 99999 (must be 1-65535)
```
**Solution:** Use a port between 1 and 65535

### ❌ Invalid Git URL
```
❌ Invalid git URL format
Expected: git@github.com:username/repo.git
```
**Solution:** Use the exact format shown in the error message

### ⚠️ Docker Not Running
```
❌ Docker service is not running
Start: sudo systemctl start docker
```
**Solution:** Run the suggested command to start Docker

### ⚠️ Docker Permission Denied
```
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```
**Solutions (in order):**
1. Activate docker group in current session: `newgrp docker`
2. If that doesn't work, log out completely and log back in
3. If still not working, re-run: `./setup/docker.sh`

**Verify it works:**
```bash
docker ps
# Should show list of containers without sudo
```

### ⚠️ TTCP Container Not Running
```
⚠️ TTCP container is not running
Start: Menu option [98]
```
**Solution:** Use menu option [98] to start the container

---

## Advanced Usage

### Check Available Ports
```shell
sudo lsof -i -P -n | grep LISTEN
```

### View Docker Container Logs
```shell
docker-compose logs -f ttcp
```

### View Nginx Error Logs
```shell
docker exec ttcp tail -f /var/log/nginx/error.log
```

### Manual Git Operations
```shell
git push -f origin master
git pull origin master
```

### Add Custom Nginx Config
```shell
# Edit manually (changes will persist)
nano config/domain-name-port.conf
# Then reload Nginx via menu option [7]
```

---

## Features Summary

| Feature | Status | Details |
|---------|--------|---------|
| **Domain Management** | ✅ | Add/List/Remove domains with validation |
| **SSH Key Management** | ✅ | Create & manage multiple SSH keys |
| **Nginx Proxy** | ✅ | Auto-generate reverse proxy configs |
| **Docker Integration** | ✅ | Easy container management |
| **Input Validation** | ✅ | FQDN, port, URL validation |
| **Error Handling** | ✅ | Clear error messages with solutions |
| **Status Display** | ✅ | Real-time Docker & TTCP status |
| **PM2 Management** | ✅ | Manage Node.js apps |
| **Beautiful UI** | ✅ | Colors, emojis, borders |

---

## Requirements

- Ubuntu 22.04 LTS or Ubuntu 24.04 LTS
- Docker & Docker Compose
- Git
- Bash 4.0+
- curl

---

## Installation Quick Start

```bash
# 1. Clone repository
git clone https://github.com/tieutantan/ttcp.git && cd ttcp

# 2. Install Docker
./setup/docker.sh

# 3. (Optional) Install Node.js + PM2
./setup/nodejs.sh

# 4. Start TTCP
./menu.sh
# Then select option [98] to start container
```

---

## Support & Contribution

## Main Menu

### Run the Menu
```shell
./menu.sh
```

### Menu Display (Refactored - v2)

Select the desired option by entering the corresponding number and pressing Enter.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    🚀 TTCP CONTROL PANEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Docker & TTCP Status: RUNNING

Main Menu Options:

  Domain Management:
    ➜ [1] Add Domain
    ➜ [2] List Domains
    ➜ [3] Remove Domain

  SSH Key Management:
    ➜ [4] Add SSH Key
    ➜ [5] List SSH Keys

  Repository & Services:
    ➜ [6] List Clone Commands
    ➜ [7] Reload Nginx

  System Management:
    ➜ [98] Start TTCP
    ➜ [99] Update TTCP

  ➜ [0] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Enter your choice (0-7, 98-99):
```

### Menu Features
- ✅ **Beautiful Design** - Unicode borders, colors, and emoji indicators
- ✅ **Real-time Status** - Shows Docker & TTCP container status
- ✅ **Input Validation** - Validates domain format, port range (1-65535), Git URL
- ✅ **Error Handling** - Clear error messages with helpful hints
- ✅ **Fast Navigation** - Loop-based (no recursion), unlimited iterations
- ✅ **Progress Feedback** - Shows what operation is being performed

### [1] Add Domain
- **Domain Validation:** Must be valid FQDN format (e.g., example.com, app.example.com)
- **Port Validation:** Must be numeric between 1-65535
- You can add multiple different domains to the same app local port.
- The `.conf` files will be created in `/ttcp/config/` directory.
- **Example:** Adding domain `tantn.com` with port `1111`
- File Created: `/ttcp/config/tantn.com-1111.conf`
```shell
✅ Adding domain: tantn.com → port 1111
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Domain added successfully!
```

Generated Nginx Configuration:
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

### [2] List Domains
Lists all currently added domains with their ports.

```shell
━━━━━━━━━━━━━━━━━━━━━━━━━
1 > ./github.com-39
2 > ./example.com-79
3 > ./tantn.com-68
TTCP: List 3 Domains.
━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Domains listed
```

### [3] Remove Domain
- **Domain Validation:** Must be valid FQDN format
- Removes the domain configuration and reloads Nginx
- Example: `tantn.com`

```shell
✅ Removing domain: tantn.com
━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Domain removed successfully!
```

### [4] Add SSH Key | Create Multiple SSH Keys For Each Repository

- **Git URL Validation:** Must be valid format: `git@github.com:username/repo.git`
- Creates SSH key pair for secure git authentication
- Stores keys in `~/.ssh/ttcp_ssh_key/` directory
- Automatically adds entry to `~/.ssh/config`

```shell
✅ Adding SSH Key...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Enter git repository URL (e.g., git@github.com:user/repo.git): git@github.com:tieutantan/ttcp.git

══════════════════════════════════════════
TTCP: CMD To Clone:
git clone git@ttcp:tieutantan/ttcp.git
══════════════════════════════════════════
TTCP: Your SSH Public Key:
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxlYdqAchLoP2fFUBYIE/8gyZaf4vBC9
NFSPZduTGZdbkZXmW2FCEKJWpHx7h2NarSR61OFvcfpJNuFztYrsAXOFKbhTzZSHwilDhq
mci5BCRd3GbafkkwQMixJEqQHW+qSD root@nw.azure.cloud
══════════════════════════════════════════
✅ SSH key added successfully!
```

**Next Step:** Add the displayed SSH public key to your GitHub/GitLab account

### [5] List SSH Keys
- All keys inside `~/.ssh/ttcp_ssh_key/`
```shell
/home/ubuntu/.ssh/ttcp_ssh_key/Laraker.pub
/home/ubuntu/.ssh/ttcp_ssh_key/ttcp.pub
/home/ubuntu/.ssh/ttcp_ssh_key/wxt.pub
```

### [5] List SSH Keys
- Lists all SSH keys stored in `~/.ssh/ttcp_ssh_key/`
- Shows filenames of generated public keys

```shell
━━━━━━━━━━━━━━━━━━━━━━━━━━
/home/ubuntu/.ssh/ttcp_ssh_key/ttcp.pub
/home/ubuntu/.ssh/ttcp_ssh_key/vue.pub
/home/ubuntu/.ssh/ttcp_ssh_key/kotlin.pub
✅ SSH keys listed
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### [6] List Clone Commands
- Lists all git clone commands from registered SSH keys
- Automatically extracted from `~/.ssh/config`

```shell
━━━━━━━━━━━━━━━━━━━━━━━━━━
git clone git@ttcp:tieutantan/ttcp.git
git clone git@vue:vuejs/vue.git
git clone git@kotlin:JetBrains/kotlin.git
✅ Clone commands listed
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### [7] Reload Nginx
- Reloads Nginx configuration without restart
- Useful after manual config changes
- Takes effect within seconds

```shell
ℹ️ Reloading Nginx...
━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Nginx reloaded successfully!
```

### [98] Start TTCP
- Starts Docker container and builds images if needed
- Shows container status

```shell
ℹ️ Starting TTCP container...
━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TTCP container started!

Container Status:
CONTAINER ID   IMAGE        STATUS        PORTS      NAMES
abc123def456   ttcp:latest  Up 2 seconds  80->80/80  ttcp
```

### [99] Update TTCP
- Pulls latest changes from git repository
- Rebuilds Docker container with new code
- Useful for getting bug fixes and new features

```shell
ℹ️ Updating TTCP from git...
✅ Git repository updated

ℹ️ Rebuilding Docker container...
✅ TTCP updated successfully!

Container Status:
CONTAINER ID   IMAGE        STATUS        PORTS      NAMES
abc123def456   ttcp:latest  Up 2 seconds  80->80/80  ttcp
```

---

## Troubleshooting

### ❌ Invalid Domain Format
```
❌ Invalid domain format: domain_with_underscore
Expected format: example.com or app.example.com
```
**Solution:** Use dots (.) as separators, not underscores

### ❌ Invalid Port
```
❌ Invalid port: 99999 (must be 1-65535)
```
**Solution:** Use a port between 1 and 65535

### ❌ Invalid Git URL
```
❌ Invalid git URL format
Expected: git@github.com:username/repo.git
```
**Solution:** Use the exact format shown in the error message

### ⚠️ Docker Not Running
```
❌ Docker service is not running
Start: sudo systemctl start docker
```
**Solution:** Run the suggested command to start Docker

### ⚠️ Docker Permission Denied
```
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```
**Solutions (in order):**
1. Activate docker group in current session: `newgrp docker`
2. If that doesn't work, log out completely and log back in
3. If still not working, re-run: `./setup/docker.sh`

**Verify it works:**
```bash
docker ps
# Should show list of containers without sudo
```

### ⚠️ TTCP Container Not Running
```
⚠️ TTCP container is not running
Start: Menu option [98]
```
**Solution:** Use menu option [98] to start the container

---

## Advanced Usage

### Check Available Ports
```shell
sudo lsof -i -P -n | grep LISTEN
```

### View Docker Container Logs
```shell
docker-compose logs -f ttcp
```

### View Nginx Error Logs
```shell
docker exec ttcp tail -f /var/log/nginx/error.log
```

### Manual Git Operations
```shell
git push -f origin master
git pull origin master
```

### Add Custom Nginx Config
```shell
# Edit manually (changes will persist)
nano config/domain-name-port.conf
# Then reload Nginx via menu option [7]
```

---

## Features Summary

| Feature | Status | Details |
|---------|--------|---------|
| **Domain Management** | ✅ | Add/List/Remove domains with validation |
| **SSH Key Management** | ✅ | Create & manage multiple SSH keys |
| **Nginx Proxy** | ✅ | Auto-generate reverse proxy configs |
| **Docker Integration** | ✅ | Easy container management |
| **Input Validation** | ✅ | FQDN, port, URL validation |
| **Error Handling** | ✅ | Clear error messages with solutions |
| **Status Display** | ✅ | Real-time Docker & TTCP status |
| **PM2 Management** | ✅ | Manage Node.js apps |
| **Beautiful UI** | ✅ | Colors, emojis, borders |

---

## Requirements

- Ubuntu 22.04 LTS or Ubuntu 24.04 LTS
- Docker & Docker Compose
- Git
- Bash 4.0+
- curl

---

## Installation Quick Start

```bash
# 1. Clone repository
git clone https://github.com/tieutantan/ttcp.git && cd ttcp

# 2. Install Docker
./setup/docker.sh

# 3. (Optional) Install Node.js + PM2
./setup/nodejs.sh

# 4. Start TTCP
./menu.sh
# Then select option [98] to start container
```

---

## Support & Contribution
