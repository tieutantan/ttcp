#!/bin/bash

# Get the base directory of the current working directory
base_dir=$(dirname "$(pwd)")

# Define the path to the startup.sh script
path="$base_dir/ttcp/startup.sh"

# Function to enable auto-run
enable_auto_run() {
  # Check if the crontab for the current user exists
  if ! crontab -l 2>/dev/null; then
    # If no crontab exists, create a new one and add the @reboot entry
    echo "Creating new crontab for the user"
    echo "@reboot $path" | crontab -
  # If a crontab exists but does not contain the @reboot entry for the script
  elif ! crontab -l | grep -q "@reboot $path"; then
    # Append the @reboot entry to the existing crontab
    (crontab -l; echo "@reboot $path") | crontab -
  fi
}

# Function to disable auto-run
disable_auto_run() {
  # Remove the @reboot entry for the script from the crontab
  crontab -l | grep -v "@reboot $path" | crontab -
}

# Check the argument passed to the script
case "$1" in
  enable)
    enable_auto_run
    ;;
  disable)
    disable_auto_run
    ;;
  *)
    echo "Usage: $0 {enable|disable}"
    exit 1
    ;;
esac