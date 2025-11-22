#!/usr/bin/env bash
set -euo pipefail

#Version listing:
#Node.js 23.x: https://deb.nodesource.com/setup_23.x
#Node.js 22.x: https://deb.nodesource.com/setup_22.x
#Node.js 20.x: https://deb.nodesource.com/setup_20.x
#Node.js 18.x: https://deb.nodesource.com/setup_18.x
#Node.js 16.x: https://deb.nodesource.com/setup_16.x
#Node.js 14.x: https://deb.nodesource.com/setup_14.x
#Node.js 12.x: https://deb.nodesource.com/setup_12.x

# Usage: ./nodejs.sh <version>
# Example: ./nodejs.sh 20  -> install Node.js 20.x
# Default: 20 (LTS) if no argument

NODE_VERSION="${1:-20}"
SETUP_URL="https://deb.nodesource.com/setup_${NODE_VERSION}.x"
SWAPFILE="/swapfile"

echo "======================================="
echo " Installing Node.js ${NODE_VERSION}.x via NodeSource"
echo " Enabling permanent 2GB swap if missing"
echo "======================================="

###########################################
# 0. Tạo SWAP forever if it not exist
###########################################

if ! grep -q "$SWAPFILE" /proc/swaps 2>/dev/null; then
  echo "[INFO] Creating 2GB swap at $SWAPFILE ..."
  if [ ! -f "$SWAPFILE" ]; then
    if ! sudo fallocate -l 2G "$SWAPFILE"; then
      echo "[WARN] fallocate failed, fallback to dd..."
      sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count=2048
    fi
  fi

  sudo chmod 600 "$SWAPFILE" || true
  sudo mkswap "$SWAPFILE" || true
  sudo swapon "$SWAPFILE" || true

  if ! grep -q "$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
  fi

  echo "[INFO] Swap enabled."
else
  echo "[INFO] Swap already active at $SWAPFILE, skipping creation."
fi

echo "[INFO] Current memory:"
free -h || true

###########################################
# 1. Cleanup dpkg nếu NodeSource fail trước đó
###########################################

echo "[INFO] Cleaning possible broken nodejs installation..."
sudo dpkg --remove --force-remove-reinstreq nodejs >/dev/null 2>&1 || true
sudo rm -f /var/cache/apt/archives/nodejs_*_amd64.deb || true
sudo apt -f install -y >/dev/null 2>&1 || true

###########################################
# 2. Đảm bảo có curl + CA
###########################################

if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] Installing curl + ca-certificates..."
  sudo apt-get update
  sudo apt-get install -y curl ca-certificates
fi

###########################################
# 3. Thêm NodeSource repo & cài Node.js
###########################################

echo "[INFO] Using NodeSource setup script: ${SETUP_URL}"
curl -fsSL "${SETUP_URL}" | sudo -E bash -

echo "[INFO] Installing nodejs package..."
sudo apt-get update
sudo apt-get install -y nodejs

echo "[INFO] Installed Node and npm versions:"
node -v
npm -v

###########################################
# 4. Install PM2 + pm2-logrotate (global)
###########################################

if ! command -v pm2 >/dev/null 2>&1; then
  echo "[INFO] Installing pm2 and pm2-logrotate globally..."
  sudo npm install -g pm2@latest
  sudo pm2 install pm2-logrotate || true
else
  echo "[INFO] pm2 already installed, skipping."
fi

echo "[INFO] PM2 version:"
pm2 -v || echo "pm2 not found?!"

echo "======================================="
echo " Installation Completed!"
echo " Node: $(node -v)"
echo " NPM:  $(npm -v)"
echo " PM2:  $(pm2 -v 2>/dev/null || echo 'not installed')"
echo " Swap: $(grep '$SWAPFILE' /proc/swaps || echo 'active but not listed')"
echo "======================================="
echo "Gợi ý:"
echo "  pm2 start index.js --name my-app"
echo "======================================="
