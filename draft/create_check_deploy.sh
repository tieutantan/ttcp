#!/bin/bash

# Check if the path to the app is provided
if [ -z "$1" ]; then
    echo "Usage: $0 path_to_app"
    exit 1
fi
# Example command: bash create_check_deploy.sh /path/to/app

APP_PATH="$1"
CHECK_DEPLOY_SCRIPT_PATH="$APP_PATH/check_deploy.sh"
EXAMPLE_SCRIPT="example_check_deploy.sh"

# Copy the content from the example_check_deploy.sh file to the check_deploy.sh script
cp "$EXAMPLE_SCRIPT" "$CHECK_DEPLOY_SCRIPT_PATH"

# Make the script executable
chmod +x "$CHECK_DEPLOY_SCRIPT_PATH"

# update add $CHECK_DEPLOY_SCRIPT_PATH to  REPO_DIRS in ttcp_check_deploys.sh
TTCP_CHECK_DEPLOYS_SCRIPT_PATH="ttcp_check_deploys.sh"
REPO_DIRS_LINE=$(grep -n "REPO_DIRS=(" "$TTCP_CHECK_DEPLOYS_SCRIPT_PATH" | cut -d: -f1)
REPO_DIRS_LINE=$((REPO_DIRS_LINE+1))
sed -i "${REPO_DIRS_LINE}a \"$APP_PATH\"" "$TTCP_CHECK_DEPLOYS_SCRIPT_PATH"
# doing to this line without test above code