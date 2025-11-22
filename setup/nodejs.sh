#!/usr/bin/env bash

set -euo pipefail

# Version listing:
# Node.js 23.x: https://deb.nodesource.com/setup_23.x
# Node.js 22.x: https://deb.nodesource.com/setup_22.x
# Node.js 20.x: https://deb.nodesource.com/setup_20.x
# Node.js 18.x: https://deb.nodesource.com/setup_18.x
# Node.js 16.x: https://deb.nodesource.com/setup_16.x
# Node.js 14.x: https://deb.nodesource.com/setup_14.x
# Node.js 12.x: https://deb.nodesource.com/setup_12.x
#
# Usage: ./nodejs.sh <version>
# Example: ./nodejs.sh 20  # sẽ cài Node.js 20.x
#
# Mặc định: 20 (LTS) nếu không truyền tham số

NODE_VERSION="${1:-20}"
SETUP_URL="https://deb.nodesource.com/setup_${NODE_VERSION}.x"

echo "======================================="
echo " Installing Node.js ${NODE_VERSION}.x"
echo " From: ${SETUP_URL}"
echo "======================================="

# Đảm bảo có curl & CA
if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] Installing curl and ca-certificates..."
  sudo apt-get update
  sudo apt-get install -y curl ca-certificates
fi

# Tải và chạy script NodeSource (không lưu file tạm)
curl -fsSL "${SETUP_URL}" | sudo -E bash -

# Cài Node.js
echo "[INFO] Installing nodejs package..."
sudo apt-get update
sudo apt-get install -y nodejs

# Kiểm tra node/npm có tồn tại không
if ! command -v node >/dev/null 2>&1; then
  echo "[ERROR] Node.js installation failed (node not found)." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "[ERROR] npm not found after installing nodejs." >&2
  exit 1
fi

# Cài pm2 + pm2-logrotate nếu chưa có
if ! command -v pm2 >/dev/null 2>&1; then
  echo "[INFO] Installing pm2 globally..."
  sudo npm install -g pm2@latest
  echo "[INFO] Installing pm2-logrotate module..."
  sudo pm2 install pm2-logrotate || true
fi

echo "======================================="
echo " Installed versions:"
node -v
npm -v
pm2 -v || echo "pm2 not installed"
echo "======================================="
echo "Done."
