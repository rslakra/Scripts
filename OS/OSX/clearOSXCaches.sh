#!/bin/bash
# Author: Rohtash Lakra
# Clear terminal screen or OS X caches (e.g. Bluetooth).
# Usage:
#   ./clearOSXCaches.sh              # Clear terminal screen (default)
#   ./clearOSXCaches.sh --bluetooth  # Reset Bluetooth cache and restart daemon
#   ./clearOSXCaches.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Clear terminal screen or OS X caches (e.g. Bluetooth).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./clearOSXCaches.sh${NC}              # Clear terminal screen (default)"
    echo -e "  ${AQUA}./clearOSXCaches.sh --bluetooth${NC}  # Reset Bluetooth cache and restart Bluetooth daemon"
    echo -e "  ${AQUA}./clearOSXCaches.sh --help${NC}       # Show this help"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}       Show this help message"
    echo -e "  ${INDIGO}--bluetooth, -b${NC}  Clear Bluetooth cache (CoreBluetoothCache) and restart blued (requires sudo)"
    echo
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

if [ "$1" == "--bluetooth" ] || [ "$1" == "-b" ]; then
    print_header "Clear Bluetooth Cache"
    echo -e "${INDIGO}Resetting Bluetooth cache and restarting Bluetooth daemon (requires sudo)...${NC}"
    echo
    sudo defaults write /Library/Preferences/com.apple.Bluetooth CoreBluetoothCache -dict
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
    sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist
    if [ $? -eq 0 ]; then
        print_success "Bluetooth cache cleared and daemon restarted!"
    else
        print_warning "Some steps may have failed (check sudo)"
    fi
    echo
    exit 0
fi

# No args or unknown: clear terminal screen (original behavior)
clear
