#!/bin/bash

function getRepositoryName {
  local url="$1"
  local regex="([^/]+)\.git$"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

function getRepositoryPath {
  local githubUrl="$1"
  echo "$githubUrl" | grep -oE '[:/][^/]+/[^.]+\.git' | sed 's/^://'
}

function getDomain {
  local url="$1"
  local regex="([^@:/]+@)?([^:/]+)"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[2]}"
  fi
}

function createDirectoryIfNeeded {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
  fi
}

function addSSHKeyConfig {
  local keyName="$1"
  local hostName="$2"
  local sshConfig="$3"
  local sshKeyBlock="
# start $keyName
Host $keyName
  HostName $hostName
  User git
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/ttcp_ssh_key/$keyName
# end $keyName
  "

  if grep -q "# start $keyName" "$sshConfig"; then
    sed -i "/^# start $keyName$/,/^# end $keyName$/d" "$sshConfig"
  fi
  echo "$sshKeyBlock" >> "$sshConfig"
}

function removeEmptyLines {
  local file="$1"
  sed -i '/^$/d' "$file"
}

# Main script starts here
if [ -z "$1" ]; then
  echo "TTCP: Error - GitHub repository URL is required."
  exit 1
fi

repoUrl="$1"
sshConfigFile=~/.ssh/config
sshKeyDirectory=~/.ssh/ttcp_ssh_key

repositoryName=$(getRepositoryName "$repoUrl")
repositoryPath=$(getRepositoryPath "$repoUrl")
domainName=$(getDomain "$repoUrl")

cloneCommand="git clone git@$repositoryName:$repositoryPath"

createDirectoryIfNeeded "$sshKeyDirectory"
ssh-keygen -b 2048 -t rsa -f "$sshKeyDirectory/$repositoryName" -q -N ""

addSSHKeyConfig "$repositoryName" "$domainName" "$sshConfigFile"
removeEmptyLines "$sshConfigFile"

echo "======================================================"
echo "TTCP: CMD To Clone:"
echo "$cloneCommand"
echo "======================================================"
echo "TTCP: Your SSH Public Key:"
echo "--"
cat < "$sshKeyDirectory/$repositoryName.pub"
echo "--"
echo "======================================================"
