#!/usr/bin/env bash
set -euo pipefail

###########################################
# ẢNH HƯỞNG QUAN TRỌNG
# => KHÔNG được chạy script này bằng sudo / root
###########################################
if [ "$EUID" -eq 0 ]; then
  echo "[ERROR] Please do NOT run this script as root or with sudo."
  echo "        Hãy chạy: ./nodejs.sh  (không dùng sudo)"
  exit 1
fi

echo "======================================="
echo " Installing Node.js using NVM (for user: $USER)"
echo " Temporary SWAP enabled during installation"
echo "======================================="

SWAPFILE="/swapfile.temp.nodejs"

###########################################
# 0. Tạo SWAP tạm 2GB
###########################################

if ! grep -q "$SWAPFILE" /proc/swaps 2>/dev/null; then
  echo "[INFO] Creating temporary 2GB swap at $SWAPFILE ..."
  if ! sudo fallocate -l 2G "$SWAPFILE"; then
    echo "[WARN] fallocate failed, using dd instead..."
    sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count=2048
  fi
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
  sudo swapon "$SWAPFILE"
else
  echo "[INFO] Temporary swap already exists (unexpected)."
fi

echo "[INFO] Memory status:"
free -h || true

###########################################
# 1. Cleanup dpkg if NodeSource failed previously
###########################################
echo "[INFO] Cleaning previous broken nodejs installation (if any)..."
sudo dpkg --remove --force-remove-reinstreq nodejs >/dev/null 2>&1 || true
sudo rm -f /var/cache/apt/archives/nodejs_*_amd64.deb || true
sudo apt -f install -y >/dev/null 2>&1 || true
sudo apt update -y

###########################################
# 2. Cài NVM cho user hiện tại
###########################################

if [ ! -d "$HOME/.nvm" ]; then
  echo "[INFO] Installing NVM into $HOME/.nvm ..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
else
  echo "[INFO] NVM already exists at $HOME/.nvm, skipping install."
fi

# Load NVM vào shell hiện tại
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
else
  echo "[ERROR] nvm.sh not found in $NVM_DIR, something went wrong."
  exit 1
fi

###########################################
# 3. Install Node.js via NVM (default: 20)
###########################################

NODE_VERSION="${1:-20}"
echo "[INFO] Installing Node.js v${NODE_VERSION} with NVM..."
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION"

echo "[INFO] Node installed for user $USER:"
node -v
npm -v

###########################################
# 4. Install PM2 + logrotate (không dùng sudo)
###########################################

echo "[INFO] Installing PM2 + pm2-logrotate globally (via NVM's npm)..."
npm install -g pm2 pm2-logrotate
pm2 -v

###########################################
# 5. Xoá swap tạm (sau khi cài xong)
###########################################

echo "[INFO] Removing temporary swap at $SWAPFILE ..."
sudo swapoff "$SWAPFILE" || true
sudo rm -f "$SWAPFILE" || true

echo "[INFO] Final memory state:"
free -h || true

###########################################
# 6. Đảm bảo NVM load auto mỗi lần SSH
###########################################

if ! grep -q 'nvm.sh' "$HOME/.bashrc"; then
cat <<'EOF' >> "$HOME/.bashrc"

# Load NVM automatically
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF
  echo "[INFO] NVM auto-load snippet appended to ~/.bashrc"
else
  echo "[INFO] NVM auto-load already present in ~/.bashrc, skipping."
fi

echo "======================================="
echo " Installation Completed for user: $USER"
echo " Node: $(node -v)"
echo " NPM:  $(npm -v)"
echo " PM2:  $(pm2 -v)"
echo " Temporary SWAP has been removed."
echo "======================================="
echo "Gợi ý:"
echo "  - Sau khi SSH lại, node/npm/pm2 vẫn dùng được do NVM được load từ ~/.bashrc"
echo "  - Ví dụ chạy app: pm2 start index.js --name my-app"
echo "======================================="
