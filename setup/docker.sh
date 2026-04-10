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
sudo systemctl enable docker
sudo systemctl start docker

###########################################
# 10. Wait for Docker daemon to be ready
###########################################

echo "[INFO] Waiting for Docker daemon to be ready..."
MAX_WAIT=30
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
  if docker info > /dev/null 2>&1; then
    echo "[INFO] Docker daemon is ready!"
    break
  else
    WAIT_COUNT=$((WAIT_COUNT + 1))
    if [ $WAIT_COUNT -lt $MAX_WAIT ]; then
      echo "[INFO] Waiting for Docker... ($WAIT_COUNT/$MAX_WAIT)"
      sleep 1
    else
      echo "[ERROR] Docker daemon failed to start within ${MAX_WAIT}s."
      echo "[ERROR] Check: sudo systemctl status docker"
      exit 1
    fi
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

