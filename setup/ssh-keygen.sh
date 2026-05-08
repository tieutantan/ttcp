#!/bin/bash

# Source the utils.sh file
source "$(dirname "$0")/utils.sh"

# Main script starts here
if [ -z "$1" ]; then
  echo "TTCP: Error - GitHub repository URL is required."
  exit 1
fi

# Example repoUrl: git@github.com:tieutantan/ttcp.git
repoUrl="$1"

# Remove leading/trailing whitespace (defensive programming)
repoUrl=$(echo "$repoUrl" | xargs)

sshConfigFile=~/.ssh/config
sshKeyDirectory=~/.ssh/ttcp_ssh_key

# Extract repository name, path, and domain from the URL
repositoryName=$(getRepositoryName "$repoUrl") || exit 1
repositoryUsername=$(getUsername "$repoUrl") || exit 1
repositoryDomain=$(getDomain "$repoUrl") || exit 1

# Construct the Git clone command
cloneCommand="git clone git@$repositoryName:$repositoryUsername/$repositoryName.git"

# Create the SSH key directory if it does not exist
createDirectoryIfNeeded "$sshKeyDirectory" || exit 1

# Generate an SSH key
ssh-keygen -b 2048 -t rsa -f "$sshKeyDirectory/$repositoryName" -q -N "" || {
  echo "TTCP: Error - Failed to generate SSH key" >&2
  exit 1
}

# Add the SSH key configuration to the SSH config file
addSSHKeyConfig "$repositoryName" "$repositoryDomain" "$sshConfigFile" "$cloneCommand" || exit 1

# Remove empty lines from the SSH config file
removeEmptyLines "$sshConfigFile" || exit 1

# Output the Git clone command and the SSH public key
echo "======================================================"
echo "TTCP: CMD To Clone:"
echo "$cloneCommand"
echo "======================================================"
echo "TTCP: Your SSH Public Key:"
echo "--"
cat < "$sshKeyDirectory/$repositoryName.pub"
echo "--"
echo "======================================================"