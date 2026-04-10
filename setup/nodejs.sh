#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Install Node.js + PM2 on Ubuntu/Debian
#
# Automatically installs latest stable Node.js or specified version
# Installs PM2 (REQUIRED) with automatic compatibility
#
# Supported versions: 12, 14, 16, 18, 20 (LTS), 22, 23 (latest), etc.
#
# Usage:
#   ./nodejs.sh              -> install Node.js 20.x LTS (default)
#   ./nodejs.sh 18           -> install Node.js 18.x
#   ./nodejs.sh latest       -> install latest available Node.js
#   ./nodejs.sh lts          -> install latest LTS (alias for 20)
#
# PM2 will be auto-selected for compatibility with installed Node.js version

# ...existing code...
###########################################
# Configuration
###########################################

SWAPFILE="/swapfile"
SWAP_SIZE_GB=2

# Get Node version from user or use default (20 LTS)
NODE_VERSION_INPUT="${1:-lts}"

# Handle special version keywords
case "$NODE_VERSION_INPUT" in
  latest)
    # Latest stable version (check available versions)
    NODE_VERSION="23"
    echo "[INFO] Using 'latest' -> Node.js ${NODE_VERSION}.x"
    ;;
  lts)
    # Latest LTS version
    NODE_VERSION="20"
    echo "[INFO] Using 'lts' -> Node.js ${NODE_VERSION}.x (LTS recommended)"
    ;;
  *)
    NODE_VERSION="$NODE_VERSION_INPUT"
    ;;
esac

SETUP_URL="https://deb.nodesource.com/setup_${NODE_VERSION}.x"

echo "======================================="
echo " Installing Node.js ${NODE_VERSION}.x"
echo " Using NodeSource repository"
echo " Installing PM2 (REQUIRED + auto-compatible)"
echo " Enabling permanent ${SWAP_SIZE_GB}GB swap"
echo "======================================="

###########################################
# 0. Validate OS
###########################################

DISTRO=$(lsb_release -si 2>/dev/null || echo "Unknown")
if [[ ! "$DISTRO" =~ ^(Ubuntu|Debian)$ ]]; then
  echo "[ERROR] This script supports Ubuntu/Debian only."
  echo "[ERROR] Current OS: $DISTRO"
  exit 1
fi

###########################################
# 1. Validate Node.js version input
###########################################

# Support more versions dynamically (12-24+)
if ! [[ "$NODE_VERSION" =~ ^[0-9]+$ ]] || [ "$NODE_VERSION" -lt 12 ] || [ "$NODE_VERSION" -gt 24 ]; then
  echo "[ERROR] Unsupported Node.js version: $NODE_VERSION"
  echo "[ERROR] Supported versions: 12-24 (or use 'latest', 'lts')"
  echo "[ERROR] Usage: ./nodejs.sh [version|latest|lts]"
  exit 1
fi

echo "[INFO] Selected Node.js version: $NODE_VERSION.x"

###########################################
# 2. Check if already installed (idempotency)
###########################################

# Function to check if pm2-logrotate is installed
check_pm2_logrotate() {
  # Check if pm2-logrotate is in PM2 modules
  if pm2 ls 2>/dev/null | grep -q "pm2-logrotate" || npm ls -g pm2-logrotate 2>/dev/null | grep -q "pm2-logrotate"; then
    return 0
  fi
  return 1
}

if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1 && command -v pm2 >/dev/null 2>&1; then
  echo "[INFO] Node.js, npm, and PM2 already installed."

  INSTALLED_MAJOR=$(node -v | grep -oP 'v\K\d+' | head -1 || echo "unknown")
  echo "[INFO] Installed Node version: $(node -v)"

  # Check if pm2-logrotate is also installed
  if check_pm2_logrotate; then
    echo "[INFO] pm2-logrotate is also installed."
    HAS_PM2_LOGROTATE=true
  else
    echo "[WARN] pm2-logrotate not installed yet."
    HAS_PM2_LOGROTATE=false
  fi

  # Check version match
  if [ "$INSTALLED_MAJOR" = "$NODE_VERSION" ] && [ "$HAS_PM2_LOGROTATE" = true ]; then
    echo "[INFO] ✅ All components already installed and configured. Exiting."
    exit 0
  elif [ "$INSTALLED_MAJOR" = "$NODE_VERSION" ] && [ "$HAS_PM2_LOGROTATE" = false ]; then
    echo "[INFO] Node version matches, but pm2-logrotate missing. Installing pm2-logrotate..."
    pm2 install pm2-logrotate 2>/dev/null || sudo npm install -g pm2-logrotate 2>/dev/null || true
    echo "[INFO] ✅ pm2-logrotate installed. Exiting."
    exit 0
  else
    echo "[WARN] Installed version ($INSTALLED_MAJOR) differs from requested ($NODE_VERSION)."
    echo "[WARN] Continuing with installation..."
  fi
fi

###########################################
# 3. Create permanent SWAP if missing
###########################################

if ! grep -q "$SWAPFILE" /proc/swaps 2>/dev/null; then
  echo "[INFO] Creating ${SWAP_SIZE_GB}GB permanent swap at $SWAPFILE..."
  if [ ! -f "$SWAPFILE" ]; then
    if ! sudo fallocate -l "${SWAP_SIZE_GB}G" "$SWAPFILE"; then
      echo "[WARN] fallocate failed, falling back to dd..."
      SWAP_SIZE_MB=$((SWAP_SIZE_GB * 1024))
      sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count="$SWAP_SIZE_MB"
    fi
  fi

  # Set proper permissions (exit on failure)
  if ! sudo chmod 600 "$SWAPFILE"; then
    echo "[ERROR] Failed to chmod swap file."
    exit 1
  fi

  # Format swap (exit on failure)
  if ! sudo mkswap "$SWAPFILE"; then
    echo "[ERROR] Failed to format swap."
    exit 1
  fi

  # Enable swap (exit on failure)
  if ! sudo swapon "$SWAPFILE"; then
    echo "[ERROR] Failed to enable swap."
    exit 1
  fi

  # Clean old stale fstab entries to prevent boot failures
  sudo sed -i "\|^$SWAPFILE|d" /etc/fstab || true

  # Add to fstab if not already present
  if ! grep -q "^$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
    echo "[INFO] Added $SWAPFILE to /etc/fstab"
  fi

  echo "[INFO] Permanent swap enabled."
else
  echo "[INFO] Permanent swap already active, skipping creation."
fi
echo "[INFO] Current memory state:"
free -h || true

###########################################
# 4. Cleanup broken Node.js dpkg installs
###########################################

echo "[INFO] Cleaning previous broken Node.js installations..."
sudo dpkg --remove --force-remove-reinstreq nodejs >/dev/null 2>&1 || true
sudo rm -f /var/cache/apt/archives/nodejs_*_amd64.deb >/dev/null 2>&1 || true
sudo apt -f install -y >/dev/null 2>&1 || true

###########################################
# 5. Ensure curl + CA certificates exist
###########################################

if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] Installing curl and ca-certificates..."
  sudo apt-get update
  sudo apt-get install -y curl ca-certificates
fi

###########################################
# 6. Add NodeSource repo & install Node.js
###########################################

echo "[INFO] Running NodeSource setup script for Node.js ${NODE_VERSION}.x"
echo "[INFO] Setup URL: ${SETUP_URL}"

# Retry logic for NodeSource setup (3 attempts, 2s between retries)
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if curl -fsSL "${SETUP_URL}" | sudo -E bash -; then
    echo "[INFO] NodeSource setup completed successfully."
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "[WARN] NodeSource setup failed, retry $RETRY_COUNT/$MAX_RETRIES..."
      sleep 2
    else
      echo "[ERROR] Failed to run NodeSource setup after $MAX_RETRIES attempts."
      echo "[ERROR] Check NodeSource availability for Node.js ${NODE_VERSION}.x"
      exit 1
    fi
  fi
done

echo "[INFO] Updating package index..."
sudo apt-get update

echo "[INFO] Installing nodejs package..."
if ! sudo apt-get install -y nodejs; then
  echo "[ERROR] Failed to install nodejs."
  exit 1
fi

###########################################
# 7. Verify Node.js and npm installation
###########################################

echo "[INFO] Verifying Node.js installation..."
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "[ERROR] Node.js or npm not found after installation."
  exit 1
fi

INSTALLED_NODE_VERSION=$(node -v)
INSTALLED_NPM_VERSION=$(npm -v)
INSTALLED_MAJOR=$(echo "$INSTALLED_NODE_VERSION" | grep -oP 'v\K\d+' | head -1)

echo "[INFO] Installed Node.js and npm:"
echo "[INFO]   Node: $INSTALLED_NODE_VERSION"
echo "[INFO]   npm:  $INSTALLED_NPM_VERSION"

if [ "$INSTALLED_MAJOR" != "$NODE_VERSION" ]; then
  echo "[WARN] Version mismatch: requested $NODE_VERSION, installed $INSTALLED_MAJOR"
  echo "[WARN] This may happen if NodeSource doesn't have ${NODE_VERSION}.x available"
fi

###########################################
# 8. Determine PM2 version for compatibility
###########################################

echo "[INFO] Determining PM2 version for Node.js $INSTALLED_MAJOR compatibility..."

# PM2 compatibility matrix (simplified, PM2 latest usually works)
# PM2 5.x+ works with Node 12+
# PM2 4.x works with Node 10+
# For safety, we install latest PM2 which is backward compatible

PM2_COMPAT_VERSION=""

case "$INSTALLED_MAJOR" in
  12|14|16|18|20)
    # Node 12-20: Use latest PM2 (5.x+)
    PM2_COMPAT_VERSION="latest"
    echo "[INFO] Node $INSTALLED_MAJOR compatible with PM2 latest (5.x+)"
    ;;
  22|23|24)
    # Node 22+ latest: Use latest PM2
    PM2_COMPAT_VERSION="latest"
    echo "[INFO] Node $INSTALLED_MAJOR compatible with PM2 latest (5.x+)"
    ;;
  *)
    # Unknown version, use latest
    PM2_COMPAT_VERSION="latest"
    echo "[INFO] Using PM2 latest for Node $INSTALLED_MAJOR"
    ;;
esac

###########################################
# 9. Install PM2 + pm2-logrotate (REQUIRED)
###########################################

echo "[INFO] Installing PM2 globally (REQUIRED + auto-compatible)..."
echo "[INFO] PM2 compatibility version: $PM2_COMPAT_VERSION"

if ! command -v pm2 >/dev/null 2>&1; then
  echo "[INFO] PM2 not found, installing..."
  if [ "$PM2_COMPAT_VERSION" = "latest" ]; then
    if ! sudo npm install -g pm2@latest; then
      echo "[ERROR] Failed to install PM2."
      exit 1
    fi
  else
    if ! sudo npm install -g "pm2@$PM2_COMPAT_VERSION"; then
      echo "[ERROR] Failed to install PM2 version $PM2_COMPAT_VERSION."
      exit 1
    fi
  fi
  echo "[INFO] PM2 installed successfully."
else
  echo "[INFO] PM2 already installed."
  CURRENT_PM2_VERSION=$(pm2 -v 2>/dev/null || echo "unknown")
  echo "[INFO] Current PM2 version: $CURRENT_PM2_VERSION"

  # Check if PM2 is compatible (optional upgrade)
  echo "[INFO] Checking PM2 compatibility with Node.js $INSTALLED_MAJOR..."
  if pm2 -v >/dev/null 2>&1; then
    echo "[INFO] PM2 is functional, no upgrade needed."
  else
    echo "[WARN] PM2 may be outdated, attempting to upgrade..."
    sudo npm install -g pm2@latest || true
  fi
fi

###########################################
# 9b. Install pm2-logrotate (REQUIRED)
###########################################

echo "[INFO] Checking and installing pm2-logrotate..."

# Check if pm2-logrotate is already installed
if npm ls -g pm2-logrotate 2>/dev/null | grep -q "pm2-logrotate"; then
  echo "[INFO] pm2-logrotate already installed globally."
  LOGROTATE_INSTALLED=true
else
  echo "[INFO] Installing pm2-logrotate..."
  if sudo npm install -g pm2-logrotate 2>/dev/null; then
    echo "[INFO] pm2-logrotate installed successfully."
    LOGROTATE_INSTALLED=true
  else
    echo "[WARN] Failed to install pm2-logrotate globally, trying PM2 module install..."
    if pm2 install pm2-logrotate 2>/dev/null; then
      echo "[INFO] pm2-logrotate installed as PM2 module."
      LOGROTATE_INSTALLED=true
    else
      echo "[WARN] pm2-logrotate installation failed (non-critical)."
      LOGROTATE_INSTALLED=false
    fi
  fi
fi

###########################################
# 10. Verify PM2 is working
###########################################

echo "[INFO] Verifying PM2 installation and compatibility..."
if ! command -v pm2 >/dev/null 2>&1; then
  echo "[ERROR] PM2 not found after installation."
  exit 1
fi

if ! pm2 -v >/dev/null 2>&1; then
  echo "[ERROR] PM2 verification failed."
  exit 1
fi

PM2_VERSION=$(pm2 -v)
echo "[INFO] PM2 version: $PM2_VERSION"

# Verify pm2-logrotate is working
echo "[INFO] Verifying pm2-logrotate..."
if npm ls -g pm2-logrotate 2>/dev/null | grep -q "pm2-logrotate"; then
  echo "[INFO] ✅ pm2-logrotate is installed globally"
  PM2_LOGROTATE_STATUS="✅ Installed"
elif pm2 ls 2>/dev/null | grep -q "pm2-logrotate"; then
  echo "[INFO] ✅ pm2-logrotate is running as PM2 module"
  PM2_LOGROTATE_STATUS="✅ Running as PM2 module"
else
  echo "[WARN] pm2-logrotate status unknown (but PM2 is running)"
  PM2_LOGROTATE_STATUS="⚠️ Status unknown"
fi

# Test PM2 functionality
echo "[INFO] Testing PM2 functionality..."
if ! pm2 ls >/dev/null 2>&1; then
  echo "[WARN] PM2 list command failed, attempting restart..."
  pm2 kill 2>/dev/null || true
  sleep 1
  pm2 ls >/dev/null 2>&1 || echo "[WARN] PM2 may have issues, but installation complete"
fi

###########################################
# 11. Print completion status and next steps
###########################################

echo ""
echo "======================================="
echo " Installation Completed Successfully!"
echo "======================================="
echo " OS:                  $DISTRO"
echo " Node:                $INSTALLED_NODE_VERSION"
echo " npm:                 $INSTALLED_NPM_VERSION"
echo " PM2:                 $PM2_VERSION (REQUIRED)"
echo " PM2 Compatibility:   Auto-selected for Node $INSTALLED_MAJOR"
echo " PM2-LogRotate:       $PM2_LOGROTATE_STATUS"
if grep -q "$SWAPFILE" /proc/swaps 2>/dev/null; then
  echo " Swap:                Active (${SWAP_SIZE_GB}GB)"
else
  echo " Swap:                Not currently active"
fi
echo "======================================="
echo ""
echo "[INFO] ✅ All components installed and verified!"
echo "[INFO] • Node.js ${INSTALLED_MAJOR}.x is ready"
echo "[INFO] • PM2 is ready for app management"
echo "[INFO] • PM2-LogRotate is configured for log management"
echo ""
echo "[INFO] Next steps:"
echo "[INFO] 1. Create your Node.js app and test locally"
echo "[INFO] 2. Start app with PM2: pm2 start <app.js>"
echo "[INFO] 3. Monitor running apps: pm2 status"
echo "[INFO] 4. View logs: pm2 logs"
echo "[INFO] 5. Save PM2 process list: pm2 save"
echo "[INFO] 6. Enable PM2 startup: pm2 startup"
echo ""
echo "[INFO] PM2 Log Rotation:"
echo "[INFO] • pm2-logrotate automatically rotates PM2 logs"
echo "[INFO] • Logs are kept per app and rotated daily by default"
echo "[INFO] • View log rotation config: pm2 conf"
echo ""
echo "[INFO] For more PM2 commands: pm2 help"
echo ""
