#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Install Docker + Docker Compose on Ubuntu/Debian
# Requires: systemd, sudo access, curl
# macOS users: install Docker Desktop manually

###########################################
# 0. Validate OS & Prerequisites
###########################################

DISTRO=$(lsb_release -si 2>/dev/null || echo "Unknown")
if [[ ! "$DISTRO" =~ ^(Ubuntu|Debian)$ ]]; then
  echo "ERROR: This script supports Ubuntu/Debian only."
  echo "Current OS: $DISTRO"
  echo "macOS users: Please install Docker Desktop manually."
  exit 1
fi

echo "======================================="
echo " Installing Docker on $DISTRO"
echo "======================================="

###########################################
# 1. Check if already installed
###########################################

if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
  echo "[INFO] Docker and Docker Compose already installed."
  echo "[INFO] Current versions:"
  docker --version
  docker-compose --version

  # Still ensure group membership even if already installed
  if ! groups "$SUDO_USER" 2>/dev/null | grep -q docker; then
    echo "[INFO] Adding $SUDO_USER to docker group..."
    sudo usermod -aG docker "$SUDO_USER"
    echo "[WARN] Please log out and log back in for group membership to take effect."
    echo "[WARN] Or run: newgrp docker"
  fi
  exit 0
fi

###########################################
# 2. Update package index (once)
###########################################

echo "[INFO] Updating package index..."
sudo apt-get update -y

###########################################
# 3. Install HTTPS + GPG prerequisites
###########################################

echo "[INFO] Installing prerequisites (apt-transport-https, curl, ca-certificates, etc.)..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

###########################################
# 4. Add Docker's official GPG key
###########################################

echo "[INFO] Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

###########################################
# 5. Set up Docker stable repository
###########################################

echo "[INFO] Setting up Docker stable repository..."
ARCH=$(dpkg --print-architecture)
UBUNTU_CODENAME=$(lsb_release -cs)
echo \
  "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[INFO] Updating package index again..."
sudo apt-get update -y

###########################################
# 6. Install Docker Engine + containerd
###########################################

echo "[INFO] Installing Docker Engine, CLI, and containerd..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

###########################################
# 7. Install Docker Compose (binary)
###########################################

echo "[INFO] Installing Docker Compose (binary)..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
COMPOSE_DEST="/usr/local/bin/docker-compose"

# Retry logic for download (network might be unstable)
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if sudo curl -fsSL "$COMPOSE_URL" -o "$COMPOSE_DEST"; then
    echo "[INFO] Docker Compose downloaded successfully."
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "[WARN] Docker Compose download failed, retry $RETRY_COUNT/$MAX_RETRIES..."
      sleep 2
    else
      echo "[ERROR] Failed to download Docker Compose after $MAX_RETRIES attempts."
      exit 1
    fi
  fi
done

sudo chmod +x "$COMPOSE_DEST"

###########################################
# 8. Configure Docker group + permissions
###########################################

echo "[INFO] Configuring Docker group permissions..."

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null 2>&1; then
  echo "[INFO] Creating docker group..."
  sudo groupadd docker
else
  echo "[INFO] docker group already exists."
fi

# Add current user to docker group
if [ -n "${SUDO_USER:-}" ]; then
  if ! groups "$SUDO_USER" 2>/dev/null | grep -q docker; then
    echo "[INFO] Adding $SUDO_USER to docker group..."
    sudo usermod -aG docker "$SUDO_USER"
    echo "[WARN] Please log out and log back in for group membership to take effect."
    echo "[WARN] Or run in current session: newgrp docker"
  else
    echo "[INFO] $SUDO_USER already in docker group."
  fi
fi

###########################################
# 9. Enable Docker service + start daemon
###########################################

echo "[INFO] Enabling Docker service on boot..."
sudo systemctl daemon-reload

# Enable service
if ! sudo systemctl enable docker; then
  echo "[WARN] Failed to enable docker service, continuing anyway..."
fi

# Start daemon with retry logic
echo "[INFO] Starting Docker daemon..."
MAX_START_RETRIES=3
START_RETRY=0

while [ $START_RETRY -lt $MAX_START_RETRIES ]; do
  if sudo systemctl start docker 2>/dev/null; then
    echo "[INFO] Docker daemon started successfully."
    break
  else
    START_RETRY=$((START_RETRY + 1))
    if [ $START_RETRY -lt $MAX_START_RETRIES ]; then
      echo "[WARN] Docker start failed, retry $START_RETRY/$MAX_START_RETRIES..."
      sleep 2
    else
      echo "[ERROR] Failed to start Docker after $MAX_START_RETRIES attempts."
      echo "[ERROR] Trying systemctl reset-failed..."
      sudo systemctl reset-failed docker 2>/dev/null || true
      sudo systemctl start docker 2>/dev/null || true
    fi
  fi
done

###########################################
# 10. Wait for Docker daemon to be ready
###########################################

echo "[INFO] Waiting for Docker daemon to be ready..."
MAX_WAIT=60  # Increased from 30s to 60s for slow systems
WAIT_COUNT=0
DOCKER_SOCKET="/var/run/docker.sock"

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
  # Check 1: Docker socket exists and is accessible
  if [ -S "$DOCKER_SOCKET" ]; then
    echo "[INFO] Docker socket found ($DOCKER_SOCKET)"

    # Check 2: Try docker info (may fail if socket has permission issues)
    if sudo docker info > /dev/null 2>&1; then
      echo "[INFO] ✅ Docker daemon is ready!"
      break
    fi
  fi

  WAIT_COUNT=$((WAIT_COUNT + 1))
  if [ $WAIT_COUNT -lt $MAX_WAIT ]; then
    REMAINING=$((MAX_WAIT - WAIT_COUNT))
    echo "[INFO] Waiting for Docker... ($WAIT_COUNT/$MAX_WAIT, $REMAINING s remaining)"
    sleep 1
  else
    echo "[ERROR] ❌ Docker daemon failed to start within ${MAX_WAIT}s."
    echo "[ERROR] Diagnostic information:"
    echo "[ERROR] 1. Check systemctl status:"
    sudo systemctl status docker --no-pager 2>&1 | head -20
    echo ""
    echo "[ERROR] 2. Check for errors in journal:"
    sudo journalctl -u docker -n 20 --no-pager 2>&1 | tail -20
    echo ""
    echo "[ERROR] Solutions to try:"
    echo "[ERROR] - Run: sudo systemctl restart docker"
    echo "[ERROR] - Run: sudo systemctl reset-failed docker"
    echo "[ERROR] - Check disk space: df -h"
    echo "[ERROR] - Check memory: free -h"
    exit 1
  fi
done

###########################################
# 11. Verify installations
###########################################

echo "[INFO] Verifying installations..."
DOCKER_VERSION=$(docker --version)
COMPOSE_VERSION=$("$COMPOSE_DEST" --version)

echo "[INFO] Docker version: $DOCKER_VERSION"
echo "[INFO] Docker Compose version: $COMPOSE_VERSION"

if [ -z "$DOCKER_VERSION" ] || [ -z "$COMPOSE_VERSION" ]; then
  echo "[ERROR] Version verification failed!"
  exit 1
fi

###########################################
# 12. Start TTCP container
###########################################

echo "[INFO] Starting TTCP container..."
if docker-compose up -d --build; then
  echo "[INFO] TTCP container started successfully!"
else
  echo "[ERROR] Failed to start TTCP container."
  echo "[ERROR] Check: docker-compose logs"
  exit 1
fi

echo "======================================="
echo " Installation Completed Successfully!"
echo " OS:      $DISTRO ($UBUNTU_CODENAME)"
echo " Docker:  $DOCKER_VERSION"
echo " Compose: $COMPOSE_VERSION"
echo "======================================="

