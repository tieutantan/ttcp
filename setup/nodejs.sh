#!/usr/bin/env bash
set -euo pipefail

echo "======================================="
echo " Installing Node.js using NVM"
echo " Temporary SWAP enabled during installation"
echo "======================================="

SWAPFILE="/swapfile.temp.nodejs"

###########################################
# 0. Tạo SWAP tạm 2GB
###########################################

if ! grep -q "$SWAPFILE" /proc/swaps; then
  echo "[INFO] Creating temporary 2GB swap..."
  sudo fallocate -l 2G "$SWAPFILE" || sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count=2048
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
  sudo swapon "$SWAPFILE"
else
  echo "[INFO] Temporary swap already exists (unexpected)."
fi

echo "[INFO] Memory status:"
free -h

###########################################
# 1. Cleanup dpkg if NodeSource failed previously
###########################################
echo "[INFO] Cleaning previous broken nodejs installation..."
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
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

###########################################
# 3. Install Node.js via NVM (default: 20)
###########################################

NODE_VERSION="${1:-20}"
echo "[INFO] Installing Node.js v${NODE_VERSION}..."
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION"

echo "[INFO] Node installed:"
node -v
npm -v

###########################################
# 4. Install PM2 + logrotate
###########################################

echo "[INFO] Installing PM2..."
npm install -g pm2 pm2-logrotate
pm2 -v

###########################################
# 5. Xoá swap tạm (sau khi cài xong)
###########################################

echo "[INFO] Removing temporary swap..."
sudo swapoff "$SWAPFILE" || true
sudo rm -f "$SWAPFILE" || true

echo "[INFO] Final memory state:"
free -h

###########################################
# 6. Đảm bảo NVM load auto mỗi lần SSH
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
echo " Temporary SWAP has been removed."
echo "======================================="
