#!/usr/bin/env bash
set -euo pipefail

# TTCP Main Menu - Refactored with Beautiful Decoration & Better UX
# Features: Loop-based (no recursion), Colors, Validation, Error Handling

# ====================================
# Color & Decoration Constants
# ====================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

readonly BORDER="=================================================="
readonly CHECK="[OK]"
readonly ERROR="[ERROR]"
readonly WARN="[WARN]"
readonly INFO="[INFO]"
readonly ARROW=">"

# ====================================
# Source utilities & Setup
# ====================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/setup/utils.sh" ]; then
  echo -e "${RED}${ERROR} setup/utils.sh not found!${NC}"
  echo -e "${YELLOW}${INFO} Please run from ttcp root directory${NC}"
  exit 1
fi

source "$SCRIPT_DIR/setup/utils.sh"

# Global variables for utils.sh
export line="───────────────────────────"
export sshConfigFile=~/.ssh/config
export sshKeyDirectory=~/.ssh/ttcp_ssh_key

# ====================================
# Display Functions
# ====================================

print_header() {
    clear
    echo -e "${CYAN}${BORDER}${NC}"
    echo -e "${BOLD}${CYAN}                     TTCP CONTROL PANEL${NC}"
    echo -e "${CYAN}${BORDER}${NC}"
    echo ""
}

print_menu() {
    echo -e "${BLUE}${BOLD}Main Menu Options:${NC}"
    echo ""
    echo -e "  ${BOLD}Domain Management:${NC}"
    echo -e "    ${ARROW} ${CYAN}[1]${NC} Add Domain"
    echo -e "    ${ARROW} ${CYAN}[2]${NC} List Domains"
    echo -e "    ${ARROW} ${CYAN}[3]${NC} Remove Domain"
    echo ""
    echo -e "  ${BOLD}SSH Key Management:${NC}"
    echo -e "    ${ARROW} ${CYAN}[4]${NC} Add SSH Key"
    echo -e "    ${ARROW} ${CYAN}[5]${NC} List SSH Keys"
    echo ""
    echo -e "  ${BOLD}Repository & Services:${NC}"
    echo -e "    ${ARROW} ${CYAN}[6]${NC} List Clone Commands"
    echo -e "    ${ARROW} ${CYAN}[7]${NC} Reload Nginx"
    echo ""
    echo -e "  ${BOLD}System Management:${NC}"
    echo -e "    ${ARROW} ${CYAN}[98]${NC} Start TTCP"
    echo -e "    ${ARROW} ${CYAN}[99]${NC} Update TTCP"
    echo ""
    echo -e "  ${ARROW} ${RED}[0]${NC} Exit"
    echo ""
    echo -e "${BLUE}${BORDER}${NC}"
}

print_status() {
    if docker info &>/dev/null && docker ps --format '{{.Names}}' | grep -q '^ttcp$'; then
        echo -e "${GREEN}${CHECK} Docker & TTCP Status: RUNNING${NC}"
    elif docker info &>/dev/null; then
        echo -e "${YELLOW}${WARN} Docker: RUNNING | TTCP Container: STOPPED${NC}"
    else
        echo -e "${RED}${ERROR} Docker Status: NOT RUNNING${NC}"
    fi
}

# ====================================
# Main Menu Loop
# ====================================
main_loop() {
    while true; do
        print_header
        print_status
        echo ""
        print_menu
        echo ""

        read -p "$(echo -e ${BOLD}'Enter your choice (0-7, 98-99):'${NC}) " choice
        echo ""

        case "$choice" in
            1)
                echo -e "${CYAN}${BOLD}→ Adding Domain...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                addDomain
                ;;
            2)
                echo -e "${CYAN}${BOLD}→ Listing Domains...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                listDomains
                ;;
            3)
                echo -e "${CYAN}${BOLD}→ Removing Domain...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                removeDomain
                ;;
            4)
                echo -e "${CYAN}${BOLD}→ Adding SSH Key...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                addSSHKey
                ;;
            5)
                echo -e "${CYAN}${BOLD}→ Listing SSH Keys...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                listSSHKeys
                ;;
            6)
                echo -e "${CYAN}${BOLD}→ Listing Clone Commands...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                listCloneCommands
                ;;
            7)
                echo -e "${CYAN}${BOLD}→ Reloading Nginx...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                reloadNginx
                ;;
            98)
                echo -e "${CYAN}${BOLD}→ Starting TTCP Container...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                ttcpStartDockerContainer
                ;;
            99)
                echo -e "${CYAN}${BOLD}→ Updating TTCP...${NC}"
                echo -e "${BLUE}${BORDER}${NC}"
                updateTTCP
                ;;
            0)
                echo -e "${GREEN}${CHECK} Goodbye!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}${ERROR} Invalid menu choice: '$choice'${NC}"
                echo -e "${YELLOW}${INFO} Valid options are: 0-7, 98, 99${NC}"
                sleep 1
                ;;
        esac

        if [ "$choice" != "0" ]; then
            echo ""
            read -p "$(echo -e ${BOLD}'Press Enter to continue...'${NC}) " dummy
        fi
    done
}

# ====================================
# Entry Point
# ====================================
main_loop

