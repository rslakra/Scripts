#!/bin/bash
# Author: Rohtash Lakra
# Set HostName, LocalHostName, and ComputerName (sync to current name or set custom name).
# Usage:
#   ./setHostName.sh              # Sync all to current ComputerName (or default)
#   ./setHostName.sh <name>       # Set HostName, LocalHostName, ComputerName to <name>
#   ./setHostName.sh --help       # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Set HostName, LocalHostName, and ComputerName.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./setHostName.sh${NC}           # Sync all to current ComputerName (or default JG2MVTYWPW)"
    echo -e "  ${AQUA}./setHostName.sh <name>${NC}    # Set all three to <name> (e.g. mbp-lakra)"
    echo -e "  ${AQUA}./setHostName.sh --help${NC}    # Show this help"
    echo
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

clear
print_header "Set Host Name"

if [ -n "$1" ]; then
    COMPUTER_NAME="$1"
    echo -e "${INDIGO}Setting HostName, LocalHostName, ComputerName to: ${AQUA}${COMPUTER_NAME}${NC}"
else
    COMPUTER_NAME=$(sudo scutil --get ComputerName 2>/dev/null)
    if [ -z "${COMPUTER_NAME}" ]; then
        COMPUTER_NAME="JG2MVTYWPW"
    fi
    echo -e "${INDIGO}Syncing HostName, LocalHostName, ComputerName to current: ${AQUA}${COMPUTER_NAME}${NC}"
fi
echo
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo scutil --set ComputerName "$COMPUTER_NAME"
dscacheutil -flushcache
# Restart your Mac for the changes to fully apply.
# You can also restart directly from the terminal using:
# echo "sudo shutdown -r now".

echo -e "${DARKBLUE}Host Name:${NC}"
sudo scutil --get HostName
echo
echo -e "${DARKBLUE}Local Host Name:${NC}"
sudo scutil --get LocalHostName
echo
echo -e "${DARKBLUE}Computer Name:${NC}"
sudo scutil --get ComputerName
echo
print_success "Host name updated successfully!"
