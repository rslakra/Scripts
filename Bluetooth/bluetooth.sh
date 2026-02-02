#!/bin/bash
# Author: Rohtash Lakra
# Bluetooth: show address, clear cache, or copy a Bluetooth library to Java lib.
# Usage:
#   ./bluetooth.sh                  # Show Bluetooth address (default)
#   ./bluetooth.sh --address        # Show Bluetooth address
#   ./bluetooth.sh --clear-cache    # Clear Bluetooth cache and restart daemon (requires sudo)
#   ./bluetooth.sh --copy-to-java <path> [dest-dir]   # Copy library to Java lib (default: /usr/lib/java)
#   ./bluetooth.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

JAVA_LIB_DEFAULT="/usr/lib/java"

usage() {
    echo
    echo -e "${DARKBLUE}Bluetooth: show address, clear cache, or copy library to Java lib.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./bluetooth.sh${NC}                                   # Show Bluetooth address (default)"
    echo -e "  ${AQUA}./bluetooth.sh --address${NC}                         # Show Bluetooth address"
    echo -e "  ${AQUA}./bluetooth.sh --clear-cache${NC}                     # Clear Bluetooth cache and restart daemon (requires sudo)"
    echo -e "  ${AQUA}./bluetooth.sh --copy-to-java <path> [dest-dir]${NC}  # Copy Bluetooth library to Java lib"
    echo -e "  ${AQUA}./bluetooth.sh --help${NC}                            # Show this help"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}             Show this help message"
    echo -e "  ${INDIGO}--address, -a${NC}          Show this Mac's Bluetooth address"
    echo -e "  ${INDIGO}--clear-cache, -c${NC}      Clear Bluetooth cache and restart blued (requires sudo)"
    echo -e "  ${INDIGO}--copy-to-java, -j${NC}     Copy a Bluetooth library (.dylib/.jar) to Java library dir."
    echo -e "                 <path>     Source file (e.g. libBluetoothLib.dylib or full path)"
    echo -e "                 [dest-dir] Optional; default: ${JAVA_LIB_DEFAULT}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./bluetooth.sh --copy-to-java /path/to/libMyBluetooth.dylib${NC}"
    echo -e "  ${AQUA}./bluetooth.sh --copy-to-java libBluetoothLib.dylib /usr/lib/java${NC}"
    echo -e "  ${AQUA}./bluetooth.sh -j ./Build/Products/Debug/libBluetoothLib.dylib${NC}"
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

do_copy_to_java() {
    local src="$1"
    local dest_dir="${2:-$JAVA_LIB_DEFAULT}"
    if [ -z "$src" ]; then
        print_error "Source path required. Usage: ./bluetooth.sh --copy-to-java <path> [dest-dir]"
        usage
        exit 2
    fi
    if [ ! -e "$src" ]; then
        print_error "Source not found: $src"
        exit 2
    fi
    if [ -d "$src" ]; then
        print_error "Source must be a file (e.g. .dylib or .jar), not a directory: $src"
        exit 2
    fi
    print_header "Copy Bluetooth Library to Java"
    echo -e "${INDIGO}Source:${NC}      ${AQUA}${src}${NC}"
    echo -e "${INDIGO}Destination:${NC} ${AQUA}${dest_dir}${NC}"
    echo
    if [ ! -d "$dest_dir" ]; then
        echo -e "${INDIGO}Creating directory: ${dest_dir}${NC}"
        sudo mkdir -p "$dest_dir" || { print_error "Failed to create $dest_dir"; exit 2; }
    fi
    local need_sudo=
    case "$dest_dir" in
        /usr/*|/Library/*) need_sudo=1 ;;
    esac
    if [ -n "$need_sudo" ]; then
        sudo cp -f "$src" "$dest_dir/" || { print_error "Copy failed"; exit 2; }
    else
        cp -f "$src" "$dest_dir/" || { print_error "Copy failed"; exit 2; }
    fi
    ls -la "$dest_dir/$(basename "$src")"
    print_success "Bluetooth library copied successfully!"
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

if [ "$1" == "--copy-to-java" ] || [ "$1" == "-j" ]; then
    do_copy_to_java "$2" "$3"
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
