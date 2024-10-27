# utils.sh

# Function to extract the repository name from the URL
function getRepositoryName {
  local url="$1"
  local regex="([^/]+)\.git$"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}
# Example usage: getRepositoryName "git@github.com:tieutantan/TEST.nam-Fail_test.git"
# Output: TEST.nam-Fail_test

# Function to extract the username from the URL
function getUsername {
  local url="$1"
  local regex=":([^/]+)/"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}
# Example usage: getUsername "git@github.com:tieutantan/TEST.nam-Fail_test.git"
# Output: tieutantan

# Function to extract the domain from the URL
function getDomain {
  local url="$1"
  local regex="([^@:/]+@)?([^:/]+)(:[0-9]+)?"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[2]}"
  fi
}
# Example usage: getDomain "git@github.com:tieutantan/TEST.nam-Fail.git"
# Output: github.com

# Function to create a directory if it does not exist
function createDirectoryIfNeeded {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
  fi
}
# Example usage: createDirectoryIfNeeded "/path/to/directory"
# Creates the directory if it does not exist

# Function to add SSH key configuration to the SSH config file
function addSSHKeyConfig {
  local keyName="$1"
  local hostName="$2"
  local sshConfig="$3"
  local cloneCommand="$4"
  local sshKeyBlock="
# start $keyName
  Host $keyName
  HostName $hostName
  User git
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/ttcp_ssh_key/$keyName
# TTCP_CLONE_CMD # $cloneCommand
# end $keyName
  "
  if grep -q "# start $keyName" "$sshConfig"; then
    sed -i "/^# start $keyName$/,/^# end $keyName$/d" "$sshConfig"
  fi
  echo "$sshKeyBlock" >> "$sshConfig"
}
# Example usage: addSSHKeyConfig "TEST.nam-Fail" "github.com" "~/.ssh/config"
# Adds the SSH key configuration for the repository to the SSH config file

# Function to remove empty lines from a file
function removeEmptyLines {
  local file="$1"
  sed -i '/^$/d' "$file"
}
# Example usage: removeEmptyLines "~/.ssh/config"
# Removes empty lines from the specified file