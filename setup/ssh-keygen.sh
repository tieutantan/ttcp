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
sshConfigFile=~/.ssh/config
sshKeyDirectory=~/.ssh/ttcp_ssh_key

# Extract repository name, path, and domain from the URL
repositoryName=$(getRepositoryName "$repoUrl")
repositoryUsername=$(getUsername "$repoUrl")
repositoryDomain=$(getDomain "$repoUrl")

# Construct the Git clone command
cloneCommand="git clone git@$repositoryName:$repositoryUsername/$repositoryName.git"

# Create the SSH key directory if it does not exist
createDirectoryIfNeeded "$sshKeyDirectory"

# Generate an SSH key
ssh-keygen -b 2048 -t rsa -f "$sshKeyDirectory/$repositoryName" -q -N ""

# Add the SSH key configuration to the SSH config file
addSSHKeyConfig "$repositoryName" "$repositoryDomain" "$sshConfigFile" "$cloneCommand"

# Remove empty lines from the SSH config file
removeEmptyLines "$sshConfigFile"

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