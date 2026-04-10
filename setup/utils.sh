#!/usr/bin/env bash
set -euo pipefail

# TTCP Utility Functions - Refactored with Better Error Handling & Validation
# Features: Input validation, Error handling, Better feedback, Color support

# Note: Color codes are defined and exported by menu.sh
# They will be available in this scope when sourced from menu.sh

# ====================================
# Docker Permission Check
# ====================================

function check_docker_permission() {
  # Check if user can access docker socket
  if ! docker ps &>/dev/null 2>&1; then
    echo -e "${RED}${ERROR} Docker permission denied!${NC}"
    echo -e "${YELLOW}${INFO} Possible solutions:${NC}"
    echo -e "${YELLOW}${INFO} 1. Run: newgrp docker${NC}"
    echo -e "${YELLOW}${INFO} 2. Or log out and log back in${NC}"
    echo -e "${YELLOW}${INFO} 3. Or run setup again: ./setup/docker.sh${NC}"
    return 1
  fi
  return 0
}

# ====================================
# URL Parsing Functions
# ====================================

function getRepositoryName() {
  local url="$1"
  local regex="([^/]+)\.git$"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    echo -e "${RED}${ERROR} Invalid repository URL${NC}" >&2
    return 1
  fi
}

function getUsername() {
  local url="$1"
  local regex=":([^/]+)/"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    echo -e "${RED}${ERROR} Cannot extract username${NC}" >&2
    return 1
  fi
}

function getDomain() {
  local url="$1"
  local regex="([^@:/]+@)?([^:/]+)(:[0-9]+)?"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[2]}"
    return 0
  else
    echo -e "${RED}${ERROR} Cannot extract domain${NC}" >&2
    return 1
  fi
}

# ====================================
# File Helpers
# ====================================

function createDirectoryIfNeeded() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    if mkdir -p "$directory"; then
      echo -e "${GREEN}${CHECK} Created directory: $directory${NC}" >&2
    else
      echo -e "${RED}${ERROR} Failed to create: $directory${NC}" >&2
      return 1
    fi
  fi
}

function removeEmptyLines() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo -e "${RED}${ERROR} File not found: $file${NC}" >&2
    return 1
  fi
  if sed -i '/^$/d' "$file"; then
    return 0
  else
    echo -e "${RED}${ERROR} Failed to clean file: $file${NC}" >&2
    return 1
  fi
}

# ====================================
# SSH Configuration
# ====================================

function addSSHKeyConfig() {
  local keyName="$1"
  local hostName="$2"
  local sshConfig="$3"
  local cloneCommand="$4"

  if [ -z "$keyName" ] || [ -z "$hostName" ] || [ -z "$sshConfig" ] || [ -z "$cloneCommand" ]; then
    echo -e "${RED}${ERROR} Missing parameters for SSH config${NC}" >&2
    return 1
  fi

  if [ ! -f "$sshConfig" ]; then
    touch "$sshConfig" && chmod 600 "$sshConfig" || {
      echo -e "${RED}${ERROR} Failed to create $sshConfig${NC}" >&2
      return 1
    }
  fi

  if grep -q "# start $keyName" "$sshConfig" 2>/dev/null; then
    sed -i "/^# start $keyName$/,/^# end $keyName$/d" "$sshConfig" || true
  fi

  cat >> "$sshConfig" << EOF

# start $keyName
Host $keyName
  HostName $hostName
  User git
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/ttcp_ssh_key/$keyName
# TTCP_CLONE_CMD # $cloneCommand
# end $keyName
EOF
}

# ====================================
# Domain Management
# ====================================

function addDomain() {
    echo "$line"

    # Check Docker permission first
    if ! check_docker_permission; then
      echo "$line"
      return 1
    fi

    read -p "Enter domain name (e.g., example.com): " domain

    if ! [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
      echo -e "${RED}${ERROR} Invalid domain format: $domain${NC}"
      echo "$line"
      return 1
    fi

    read -p "Enter app local port (1-65535): " app_local_port

    if ! [[ $app_local_port =~ ^[0-9]+$ ]] || [ "$app_local_port" -lt 1 ] || [ "$app_local_port" -gt 65535 ]; then
      echo -e "${RED}${ERROR} Invalid port: $app_local_port (must be 1-65535)${NC}"
      echo "$line"
      return 1
    fi

    echo -e "${BLUE}${INFO} Adding domain: $domain → port $app_local_port${NC}"

    if docker exec ttcp add "$domain" "$app_local_port"; then
      echo -e "${GREEN}${CHECK} Domain added successfully!${NC}"
    else
      echo -e "${RED}${ERROR} Failed to add domain${NC}"
      echo "$line"
      return 1
    fi
    echo "$line"
}

function listDomains() {
    echo "$line"

    # Check Docker permission first
    if ! check_docker_permission; then
      echo "$line"
      return 1
    fi

    if docker exec ttcp list; then
      echo -e "${GREEN}${CHECK} Domains listed${NC}"
    else
      echo -e "${RED}${ERROR} Failed to list domains${NC}"
      echo "$line"
      return 1
    fi
    echo "$line"
}

function removeDomain() {
    echo "$line"

    # Check Docker permission first
    if ! check_docker_permission; then
      echo "$line"
      return 1
    fi

    read -p "Enter domain name to remove: " domain

    if ! [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
      echo -e "${RED}${ERROR} Invalid domain format: $domain${NC}"
      echo "$line"
      return 1
    fi

    echo -e "${BLUE}${INFO} Removing domain: $domain${NC}"

    if docker exec ttcp remove "$domain"; then
      echo -e "${GREEN}${CHECK} Domain removed successfully!${NC}"
    else
      echo -e "${RED}${ERROR} Failed to remove domain${NC}"
      echo "$line"
      return 1
    fi
    echo "$line"
}

# ====================================
# SSH Management
# ====================================

function addSSHKey() {
    echo "$line"
    read -p "Enter git repository URL (e.g., git@github.com:user/repo.git): " repoUrl

    if ! [[ $repoUrl =~ ^git@[a-zA-Z0-9.-]+:[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+\.git$ ]]; then
      echo -e "${RED}${ERROR} Invalid git URL format${NC}"
      echo -e "${YELLOW}${INFO} Expected: git@github.com:username/repo.git${NC}"
      echo "$line"
      return 1
    fi

    if ./setup/ssh-keygen.sh "$repoUrl"; then
      echo -e "${GREEN}${CHECK} SSH key added successfully!${NC}"
    else
      echo -e "${RED}${ERROR} Failed to add SSH key${NC}"
      return 1
    fi
    echo "$line"
}

function listSSHKeys() {
    echo "$line"
    if [ -d "$sshKeyDirectory" ]; then
      if ls "$sshKeyDirectory"/*.pub 1>/dev/null 2>&1; then
        ls -1 "$sshKeyDirectory"/*.pub
        echo -e "${GREEN}${CHECK} SSH keys listed${NC}"
      else
        echo -e "${YELLOW}${WARN} No SSH keys found${NC}"
      fi
    else
      echo -e "${YELLOW}${WARN} SSH key directory not found${NC}"
    fi
    echo "$line"
}

function listCloneCommands() {
    echo "$line"
    if [ -f "$sshConfigFile" ]; then
      if grep -q "# TTCP_CLONE_CMD #" "$sshConfigFile" 2>/dev/null; then
        grep -oP '(?<=# TTCP_CLONE_CMD # ).*' "$sshConfigFile" 2>/dev/null || true
        echo -e "${GREEN}${CHECK} Clone commands listed${NC}"
      else
        echo -e "${YELLOW}${WARN} No clone commands found. Add SSH keys first!${NC}"
      fi
    else
      echo -e "${YELLOW}${WARN} SSH config not found${NC}"
    fi
    echo "$line"
}

# ====================================
# Nginx Management
# ====================================

function reloadNginx() {
    echo "$line"

    # Check Docker permission first
    if ! check_docker_permission; then
      echo "$line"
      return 1
    fi

    echo -e "${BLUE}${INFO} Reloading Nginx...${NC}"

    if docker exec ttcp nginx -s reload; then
      echo -e "${GREEN}${CHECK} Nginx reloaded successfully!${NC}"
    else
      echo -e "${RED}${ERROR} Failed to reload Nginx${NC}"
      echo "$line"
      return 1
    fi
    echo "$line"
}

# ====================================
# Docker Management
# ====================================

function ttcpStartDockerContainer() {
    echo "$line"

    # Check Docker permission first
    if ! check_docker_permission; then
      echo "$line"
      return 1
    fi

    echo -e "${BLUE}${INFO} Starting TTCP container...${NC}"

    if docker-compose up -d --build; then
      echo -e "${GREEN}${CHECK} TTCP container started!${NC}"
      sleep 2
      echo ""
      echo -e "${BLUE}Container Status:${NC}"
      docker-compose ps
    else
      echo -e "${RED}${ERROR} Failed to start TTCP${NC}"
      echo -e "${YELLOW}${INFO} Check: docker-compose logs${NC}"
      echo "$line"
      return 1
    fi
    echo "$line"
}

function updateTTCP() {
    echo "$line"

    # Check Docker permission first
    if ! check_docker_permission; then
      echo "$line"
      return 1
    fi

    echo -e "${BLUE}${INFO} Updating TTCP from git...${NC}"

    if git fetch --all && git reset --hard origin/master && git pull; then
      echo -e "${GREEN}${CHECK} Git repository updated${NC}"
    else
      echo -e "${RED}${ERROR} Failed to update from git${NC}"
      echo "$line"
      return 1
    fi

    echo -e "${BLUE}${INFO} Rebuilding Docker container...${NC}"

    if docker-compose up -d --build; then
      echo -e "${GREEN}${CHECK} TTCP updated successfully!${NC}"
      sleep 2
      echo ""
      echo -e "${BLUE}Container Status:${NC}"
      docker-compose ps
    else
      echo -e "${RED}${ERROR} Failed to rebuild container${NC}"
      echo -e "${YELLOW}${INFO} Check: docker-compose logs${NC}"
      echo "$line"
      return 1
    fi
    echo "$line"
}

# ====================================
# Docker Validation
# ====================================

function checkDockerAndDockerCompose() {
     if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
          echo -e "${RED}${ERROR} Docker or Docker Compose not found${NC}"
          echo "$line"
          echo -e "${YELLOW}${INFO} Install: ./setup/docker.sh${NC}"
          echo "$line"
          return 1
      fi

      if ! docker info &> /dev/null; then
          echo -e "${RED}${ERROR} Docker service is not running${NC}"
          echo "$line"
          echo -e "${YELLOW}${INFO} Start: sudo systemctl start docker${NC}"
          echo "$line"
          return 1
      fi

      if ! docker ps --format '{{.Names}}' | grep -q '^ttcp$'; then
          echo -e "${YELLOW}${WARN} TTCP container is not running${NC}"
          echo "$line"
          echo -e "${YELLOW}${INFO} Start: Menu option [98]${NC}"
          echo "$line"
          return 1
      fi

      return 0
}
