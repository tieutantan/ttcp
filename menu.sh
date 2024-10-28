#!/bin/bash

# Source the utils.sh file
source ./setup/utils.sh

# Path to the SSH config file
# shellcheck disable=SC2034
sshConfigFile=~/.ssh/config
# shellcheck disable=SC2034
sshKeyDirectory=~/.ssh/ttcp_ssh_key
line="---------------"

# display menu and get user choice for the SSH tools menu options 1-4
function MenuTTCP() {
    echo "$line"
    echo "-[ TTCP MENU ]-"
    echo "$line"
    checkDockerAndDockerCompose
    echo "[1] Add Domain"
    echo "[2] List Domain"
    echo "[3] Remove Domain"
    echo "[4] Add SSH Key"
    echo "[5] List SSH Keys"
    echo "[6] List Clone Commands"
    echo "[7] Reload Nginx"
    echo "[8] Enable Auto-Run on Startup"
    echo "[9] Disable Auto-Run on Startup"
    echo "[98] Start TTCP"
    echo "[99] Update TTCP"
    echo "[0] Exit / Ctrl+C"
    # shellcheck disable=SC2162
    read -p "Enter your choice: " choice
    case $choice in
        1) addDomain ;;
        2) listDomains ;;
        3) removeDomain ;;
        4) addSSHKey ;;
        5) listSSHKeys ;;
        6) listCloneCommands ;;
        7) reloadNginx ;;
        8) enableAutoRun ;;
        9) disableAutoRun ;;

        98) ttcpStartDockerContainer ;;
        99) updateTTCP ;;

        0) exit 0 ;;

        *) echo "Invalid choice. Please try again." && MenuTTCP ;;
    esac
}

# run MenuTTCP function to display the SSH tools menu
MenuTTCP