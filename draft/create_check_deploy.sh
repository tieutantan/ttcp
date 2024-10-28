#!/bin/bash

# Check if the path to the app is provided
if [ -z "$1" ]; then
    echo "Usage: $0 path_to_app"
    exit 1
fi
# Example command: bash create_check_deploy.sh /path/to/app

APP_PATH="$1"
CHECK_DEPLOY_SCRIPT="$APP_PATH/check_deploy.sh"
EXAMPLE_SCRIPT="example_check_deploy.sh"

# Copy the content from the example_check_deploy.sh file to the check_deploy.sh script
cp "$EXAMPLE_SCRIPT" "$CHECK_DEPLOY_SCRIPT"

# Make the script executable
chmod +x "$CHECK_DEPLOY_SCRIPT"

echo "Created $CHECK_DEPLOY_SCRIPT"