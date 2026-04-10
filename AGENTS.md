# AGENTS Guide for TTCP

## Project Snapshot
- TTCP is a Bash-driven control panel for one Dockerized Nginx reverse proxy that routes many domains to host ports.
- Core workflow: run `./menu.sh` -> call helpers in `setup/utils.sh` -> execute commands in `ttcp` container.
- Only one runtime service is defined in `docker-compose.yml`: `nginx` (container name fixed to `ttcp`).
- **Environment Caveat**: Setup scripts (`setup/docker.sh`, `setup/nodejs.sh`) are Ubuntu/Debian-only; macOS users cannot run auto-install. Manual Docker/Docker Compose setup required on macOS.

## Architecture and Data Flow
- Host side orchestration: `menu.sh` + `setup/utils.sh` handle prompts, Docker checks, and git/cron/SSH utilities.
- Container side domain management: `nginx/.add-domain.sh`, `.list-domain.sh`, `.remove-domain.sh` are copied into image as `add`, `list`, `remove` (`nginx/Dockerfile`).
- Container scripts validate inputs (domain FQDN format, port range 1-65535) before applying changes.
- Domain add flow:
  1. `addDomain()` in `setup/utils.sh` reads `domain` and `app_local_port` from user input.
  2. Runs `docker exec ttcp add <domain> <port>`.
  3. Container `.add-domain.sh` validates inputs, checks for duplicates (by filename pattern `<domain>-*.conf` and `grep server_name`), generates temp config.
  4. Container tests Nginx syntax on temp config; fails and rolls back if invalid.
  5. Moves validated temp file to `/etc/nginx/conf.d/<domain>-<port>.conf` with `proxy_pass http://host.docker.internal:<port>`.
  6. Container reloads Nginx in-place; rolls back and exits if reload fails.
  7. Returns success message with domain and port.
- Compose setup: mounts `./config -> /etc/nginx/conf.d` and `./log -> /var/log/nginx`, so generated vhost files persist on host after container lifecycle.

## Critical Workflows
- **Menu Loop**: `menu.sh` calls `MenuTTCP()`, which uses a case statement to dispatch to functions like `addDomain`, `listDomains`, etc. Each function ends with recursive `MenuTTCP` call, so menu stays open after each operation until user exits `[0]`.
- **Start/rebuild TTCP**: `docker-compose up -d --build` (used by menu option `[98]` via `ttcpStartDockerContainer()` and by `setup/docker.sh`).
- **Reload Nginx without rebuild**: menu option `[7]` runs `docker exec ttcp nginx -s reload` (no domain config changes, just reapply in-container).
- **Update workflow is destructive**: menu option `[99]` calls `updateTTCP()` which runs `git fetch --all && git reset --hard origin/master && git pull` then `docker-compose up -d --build`. Hard reset discards local changes.
- **Startup automation**: `setup/startup-manage.sh` is called by menu options `[8]`/`[9]` with `"enable"` or `"disable"` args. Path calculation uses `dirname "$(pwd)"` (context-dependent) to build `$base_dir/ttcp/startup.sh` and manages `@reboot` entries in user crontab.
- **SSH key workflow**: `setup/ssh-keygen.sh <repoUrl>` generates 2048-bit RSA key into `~/.ssh/ttcp_ssh_key/<keyName>`, appends managed SSH config block with markers `# start <keyName>` / `# end <keyName>`, outputs clone command hint in `# TTCP_CLONE_CMD # ...` line.

## Project-Specific Conventions
- **Run scripts from repo root**: Many paths are relative (`source ./setup/utils.sh`, `./setup/ssh-keygen.sh`). Some scripts assume cwd is repo root for relative lookups.
- **Docker and container identity are hard-coded**: `docker-compose` command and container name `ttcp` are fixed throughout; keep names aligned if refactoring.
- **Menu recursion pattern**: All menu handler functions (e.g., `addDomain()`, `listDomains()`) end with `MenuTTCP` call to redisplay menu. No explicit looping; user exits via `[0]`.
- **Nginx vhost file naming pattern**: `<domain>-<port>.conf` in `/etc/nginx/conf.d/`. List/remove scripts rely on filename matching; exact domain in filename, port from command.
- **Validation in container scripts**: `.add-domain.sh` uses regex `^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$` for FQDN; port must be numeric 1-65535.
- **Duplicate detection**: `.add-domain.sh` checks both filename glob `$domain-*.conf` and `grep server_name` in all `.conf` files to prevent duplicates; can false-match if not careful with regex.
- **Nginx syntax validation pattern**: Container runs `nginx -t -c /etc/nginx/nginx.conf` on temp config before moving to live; rolls back both config file and reloads Nginx on failure.
- **Crontab path calculation caveat**: `startup-manage.sh` uses `dirname "$(pwd)"` to derive base path; behavior depends on caller's cwd. Assumes cwd is `/path/to/ttcp` and calculates parent for relative path.
- **SSH config block markers**: Format is `# start <keyName>` / `# end <keyName>` with clone hint `# TTCP_CLONE_CMD # <cloneCommand>` embedded. Old blocks are removed and replaced on re-key.

## External Dependencies and Integrations
- **Ubuntu-oriented setup scripts** (`apt-get`, `systemctl`, NodeSource, Docker APT repo) in `setup/docker.sh` and `setup/nodejs.sh`.
  - `setup/docker.sh`: Installs latest Docker CE + Docker Compose via APT repos; Ubuntu/Debian only.
  - `setup/nodejs.sh`: Installs Node.js (default 20.x LTS, parameterizable 12-23.x) + PM2 + creates 2GB swap; Ubuntu/Debian only; includes dpkg cleanup and dependency checks.
  - **macOS users**: Must manually install Docker Desktop and Docker Compose; setup scripts will fail. No automated setup path for macOS.
- **Reverse proxy reaches host apps** via Docker host-gateway mapping (`extra_hosts: host.docker.internal:host-gateway` in `docker-compose.yml`).
- **Default site page** in `nginx/index.html` gets public IP injected at image build time (run curl to `ifconfig.me` in `nginx/Dockerfile`, sed replace `_TTCP_` marker).
- **Nginx base image**: `nginx:stable-alpine` in `nginx/Dockerfile`.
- **Shell compatibility**: Host scripts use Bash (shebang `#!/bin/bash`, set options like `set -euo pipefail`); container scripts use POSIX sh (`#!/bin/sh`). Host: Bash functions, test operators; container: sh-portable only.

## Error Handling and Validation Patterns
- **Input validation** in container scripts use regex patterns:
  - Domains: FQDN regex in `.add-domain.sh` lines 6 and `.remove-domain.sh` line 6
  - Ports: numeric check + range 1-65535 in `.add-domain.sh` lines 15-18
  - Both scripts exit with code 1 on validation failure; no partial execution
- **Nginx config testing**: `.add-domain.sh` runs `nginx -t -c /etc/nginx/nginx.conf` (line 70) before committing; expects "successful" in output
- **Rollback on reload failure**: If `nginx -s reload` fails (lines 80, 55), remove temp/live config and exit with code 1
- **Duplicate prevention**: Check filenames (glob) + grep server_name in existing configs; both must pass to allow add
- **Directory access**: `.list-domain.sh` and `.remove-domain.sh` use `cd "$folder" || exit 1` to safely change directories; script exits if directory is inaccessible
- **Menu error handling**: `checkDockerAndDockerCompose()` in `setup/utils.sh` (line 170) validates Docker, Docker Compose, and container running state on every menu display; returns 1 and shows setup hints if checks fail

## Directory Structure and Mounting
- **./config/** → `/etc/nginx/conf.d` (mounted in docker-compose.yml, generated `.conf` files persist here)
- **./log/** → `/var/log/nginx` (mounted in docker-compose.yml, Nginx logs persist here)
- **~/.ssh/ttcp_ssh_key/** → SSH keys generated by `setup/ssh-keygen.sh` (created if missing)
- **~/.ssh/config** → SSH config with managed blocks; see SSH Config Block format below

## SSH Config Block Format
When `setup/ssh-keygen.sh` adds a key, it appends a block to `~/.ssh/config` (or replaces existing block if key name matches):
```
# start <keyName>
Host <keyName>
HostName <hostName>
User git
PreferredAuthentications publickey
IdentityFile ~/.ssh/ttcp_ssh_key/<keyName>
# TTCP_CLONE_CMD # git clone git@<keyName>:<username>/<repo>.git
# end <keyName>
```
- Markers `# start <keyName>` and `# end <keyName>` delimit block; grep + sed removes old blocks before appending
- Clone command embedded in `# TTCP_CLONE_CMD #` comment line; `listCloneCommands()` in `setup/utils.sh` (line 101) uses `grep -oP` to extract and display
- Empty lines removed from SSH config at end of script (line 35)
