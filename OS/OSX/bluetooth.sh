#!/bin/bash
# Author: Rohtash Lakra
# Bluetooth: show address or clear cache.
# Usage:
#   ./bluetooth.sh                  # Show Bluetooth address (default)
#   ./bluetooth.sh --address        # Show Bluetooth address
#   ./bluetooth.sh --clear-cache    # Clear Bluetooth cache and restart daemon (requires sudo)
#   ./bluetooth.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Bluetooth: show address or clear cache.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./bluetooth.sh${NC}                 # Show Bluetooth address (default)"
    echo -e "  ${AQUA}./bluetooth.sh --address${NC}       # Show Bluetooth address"
    echo -e "  ${AQUA}./bluetooth.sh --clear-cache${NC}   # Clear Bluetooth cache and restart daemon (requires sudo)"
    echo -e "  ${AQUA}./bluetooth.sh --help${NC}          # Show this help"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}         Show this help message"
    echo -e "  ${INDIGO}--address, -a${NC}      Show this Mac's Bluetooth address"
    echo -e "  ${INDIGO}--clear-cache, -c${NC}  Clear Bluetooth cache and restart blued (requires sudo)"
    echo
}

do_address() {
    print_header "Bluetooth Address"
    echo -e "${INDIGO}This Mac's Bluetooth address:${NC}"
    echo
    system_profiler SPBluetoothDataType 2>/dev/null | sed -n "/Apple Bluetooth Software Version\:/,/Manufacturer\:/p" | egrep -o '([[:xdigit:]]{1,2}-){5}[[:xdigit:]]{1,2}' || true
    echo
}

do_clear_cache() {
    print_header "Clear Bluetooth Cache"
    echo -e "${INDIGO}Resetting Bluetooth cache and restarting daemon (requires sudo)...${NC}"
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
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

if [ "$1" == "--clear-cache" ] || [ "$1" == "-c" ]; then
    do_clear_cache
    exit 0
fi

# Default or --address: show Bluetooth address
if [ $# -eq 0 ] || [ "$1" == "--address" ] || [ "$1" == "-a" ]; then
    do_address
    exit 0
fi

print_error "Unknown option: $1"
usage
exit 1
