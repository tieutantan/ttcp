#!/bin/bash

# Path to the SSH config file
sshConfigFile=~/.ssh/config
sshKeyDirectory=~/.ssh/ttcp_ssh_key
line="---------------"

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
    echo $line
    ls -1 "$sshKeyDirectory"/*.pub
    echo $line
    MenuTTCP
}

function listCloneCommands() {
    # Read the SSH config file and list all lines with the format # CLONE CMD # xxxxxx
    echo $line
    grep -oP '(?<=# TTCP_CLONE_CMD # ).*' "$sshConfigFile"
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
    echo $line
    crontab -l
    echo $line
    MenuTTCP
}

function disableAutoRun() {
    # Run the apply-auto-run.sh script in ./setup to apply the auto-run configuration
    ./setup/startup-manage.sh "disable"
    echo $line
    crontab -l
    echo $line
    MenuTTCP
}

function updateTTCP() {
    # Pull the latest changes from the remote repository
    git fetch --all && git reset --hard origin/master && git pull
    MenuTTCP
}

# display menu and get user choice for the SSH tools menu options 1-4
function MenuTTCP() {
    echo $line
    echo "-[ TTCP MENU ]-"
    echo $line
    echo "1. Add SSH Key"
    echo "2. List SSH Keys"
    echo "3. List Clone Commands"
    echo "4. Reload Nginx"
    echo "5. Enable Auto-Run on Startup"
    echo "6. Disable Auto-Run on Startup"
    echo "99. Update TTCP"
    echo "0. Exit / Ctrl+C"
    # shellcheck disable=SC2162
    read -p "Enter your choice: " choice
    case $choice in
        1) addSSHKey ;;
        2) listSSHKeys ;;
        3) listCloneCommands ;;
        4) reloadNginx ;;
        5) enableAutoRun ;;
        6) disableAutoRun ;;
        99) updateTTCP ;;
        0) exit 0 ;;
        *) echo "Invalid choice. Please try again." && MenuTTCP ;;
    esac
}

# run MenuTTCP function to display the SSH tools menu
MenuTTCP