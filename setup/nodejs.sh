#!/usr/bin/env bash
set -euo pipefail

echo "======================================="
echo " Installing Node.js using NVM (stable)"
echo " Auto-create SWAP to avoid dpkg kill"
echo "======================================="

###########################################
# 0. Tạo SWAP nếu chưa có (2GB)
###########################################

SWAPFILE="/swapfile"

if ! grep -q "$SWAPFILE" /proc/swaps; then
  echo "[INFO] Creating 2GB swap..."
  sudo fallocate -l 2G "$SWAPFILE" || sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count=2048
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
  sudo swapon "$SWAPFILE"
  echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
else
  echo "[INFO] Swap already exists. Skipping."
fi

echo "[INFO] Current memory:"
free -h

###########################################
# 1. Dọn lỗi nodejs bị kẹt trong dpkg (nếu có)
###########################################
echo "[INFO] Cleaning broken Node.js installation (if exists)..."

sudo dpkg --remove --force-remove-reinstreq nodejs || true
sudo rm -f /var/cache/apt/archives/nodejs_*_amd64.deb || true
sudo apt -f install -y || true
sudo apt update -y

###########################################
# 2. Cài NVM
###########################################

if [ ! -d "$HOME/.nvm" ]; then
  echo "[INFO] Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
else
  echo "[INFO] NVM already installed. Skipping."
fi

# Load NVM vào shell hiện tại
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

###########################################
# 3. Cài Node.js (default: 20 LTS)
###########################################

NODE_VERSION="${1:-20}"
echo "[INFO] Installing Node.js v${NODE_VERSION} using NVM..."

nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION"

echo "[INFO] Node.js installed:"
node -v
npm -v

###########################################
# 4. Cài PM2 + PM2-Logrotate
###########################################

echo "[INFO] Installing PM2 globally..."
npm install -g pm2 pm2-logrotate

echo "[INFO] PM2 installed:"
pm2 -v

###########################################
# 5. Đảm bảo NVM load mỗi lần SSH
###########################################

if ! grep -q 'nvm.sh' ~/.bashrc; then
cat <<'EOF' >> ~/.bashrc

# Load NVM automatically
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF
fi

echo "======================================="
echo " Installation Completed!"
echo " Node: $(node -v)"
echo " NPM:  $(npm -v)"
echo " PM2:  $(pm2 -v)"
echo "======================================="
echo "Use: pm2 start index.js --name app-name"
echo "======================================="
