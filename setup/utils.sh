# utils.sh

# Function to extract the repository name from the URL
function getRepositoryName() {
  local url="$1"
  local regex="([^/]+)\.git$"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}
# Example usage: getRepositoryName "git@github.com:tieutantan/TEST.nam-Fail_test.git"
# Output: TEST.nam-Fail_test

# Function to extract the username from the URL
function getUsername() {
  local url="$1"
  local regex=":([^/]+)/"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}
# Example usage: getUsername "git@github.com:tieutantan/TEST.nam-Fail_test.git"
# Output: tieutantan

# Function to extract the domain from the URL
function getDomain() {
  local url="$1"
  local regex="([^@:/]+@)?([^:/]+)(:[0-9]+)?"
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[2]}"
  fi
}
# Example usage: getDomain "git@github.com:tieutantan/TEST.nam-Fail.git"
# Output: github.com

# Function to create a directory if it does not exist
function createDirectoryIfNeeded() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
  fi
}
# Example usage: createDirectoryIfNeeded "/path/to/directory"
# Creates the directory if it does not exist

# Function to add SSH key configuration to the SSH config file
function addSSHKeyConfig() {
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
function removeEmptyLines() {
  local file="$1"
  sed -i '/^$/d' "$file"
}
# Example usage: removeEmptyLines "~/.ssh/config"
# Removes empty lines from the specified file

function addSSHKey() {
    # Prompt the user for the GitHub repository URL
    # shellcheck disable=SC2162
    read -p "Enter the git repository URL (ex: git@github.com:tieutantan/ttcp.git): " repoUrl
    # Run the ssh-keygen.sh script with the repository URL as an argument
    ./setup/ssh-keygen.sh "$repoUrl"
    MenuTTCP
}

function listSSHKeys() {
    # List all SSH keys in the sshKeyDirectory
    # shellcheck disable=SC2154
    echo "$line"
    # shellcheck disable=SC2154
    ls -1 "$sshKeyDirectory"/*.pub
    echo "$line"
    MenuTTCP
}

function listCloneCommands() {
    # Read the SSH config file and list all lines with the format # CLONE CMD # xxxxxx
    echo "$line"
    # shellcheck disable=SC2154
    grep -oP '(?<=# TTCP_CLONE_CMD # ).*' "$sshConfigFile"
    # shellcheck disable=SC2086
    echo $line
    MenuTTCP
}

function reloadNginx() {
    # Reload the NGINX service created by the TTCP Docker container
    docker exec ttcp nginx -s reload
    MenuTTCP
}

function enableAutoRun() {
    # Run the apply-auto-run.sh script in ./setup to apply the auto-run configuration
    ./setup/startup-manage.sh "enable"
    echo "$line"
    crontab -l
    echo "$line"
    MenuTTCP
}

function disableAutoRun() {
    # Run the apply-auto-run.sh script in ./setup to apply the auto-run configuration
    ./setup/startup-manage.sh "disable"
    # shellcheck disable=SC2086
    echo $line
    crontab -l
    # shellcheck disable=SC2086
    echo $line
    MenuTTCP
}

# Add domain by command `docker exec ttcp add [domain] [app_local_port]` format
function addDomain() {
    # shellcheck disable=SC2162
    read -p "Add Domain: Enter the domain: " domain
    # shellcheck disable=SC2162
    read -p "Add Domain: Enter the app local port: " app_local_port
    docker exec ttcp add "$domain" "$app_local_port"
    MenuTTCP
}

function updateTTCP() {
    # Pull the latest changes from the remote repository
    git fetch --all && git reset --hard origin/master && git pull
    docker-compose up -d --build
    # Finished update no need auto-open MenuTTCP because it cached, so we need to re-run it
}

function listDomains() {
    # List all SSH keys in the sshKeyDirectory
    echo "$line"
    docker exec ttcp list
    echo "$line"
    MenuTTCP
}

function removeDomain() {
    # shellcheck disable=SC2162
    read -p "Enter the domain name: " domain
    docker exec ttcp remove "$domain"
    MenuTTCP
}

function ttcpStartDockerContainer() {
    docker-compose up -d --build
    MenuTTCP
}

function checkDockerAndDockerCompose() {
    if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
        echo "Docker or Docker Compose not found. Command to install:"
        echo "$line"
        echo "./setup/docker.sh"
        echo "$line"
    elif ! sudo systemctl is-active --quiet docker; then
        echo "Docker service is not running. Start Docker using the command:"
        echo "$line"
        echo "sudo systemctl start docker"
        echo "$line"
    elif ! docker ps --format '{{.Names}}' | grep -q '^ttcp$'; then
        echo "TTCP container is not running. Start the TTCP using Menu -> [98]"
        echo "$line"
    fi
}
