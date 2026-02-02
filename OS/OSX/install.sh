#!/bin/bash
# Author: Rohtash Lakra
# Install-related utilities: check if app is installed (by bundle id).
# Usage:
#   ./install.sh --check-installed <bundle-id>   # Check if app with bundle id is installed
#   ./install.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Install-related utilities: check if an app is installed by bundle id.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./install.sh --check-installed <bundle-id>${NC}   # Check if app with bundle id is installed"
    echo -e "  ${AQUA}./install.sh --help${NC}                          # Show this help"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--check-installed <bundle-id>${NC}  Exit 0 if installed, 1 if not (e.g. com.apple.Safari)"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./install.sh --check-installed com.apple.Safari${NC}"
    echo -e "  ${AQUA}./install.sh --check-installed com.microsoft.Word${NC}"
    echo
}

# Check if app with given bundle id is installed (via Finder AppleScript)
# Exit 0 = installed (success), 1 = not installed (so 'if ./install.sh --check-installed id' works)
do_check_installed() {
    local bundle_id="$1"
    if [ -z "$bundle_id" ]; then
        print_error "Bundle id required. Usage: ./install.sh --check-installed <bundle-id>"
        usage
        exit 2
    fi
    print_header "Check if App is Installed"
    echo -e "${INDIGO}Bundle id: ${AQUA}${bundle_id}${NC}"
    echo
    local applescript
    applescript=$(cat <<EOF
on run argv
  try
    tell application "Finder"
      set appname to name of application file id "$bundle_id"
      return 1
    end tell
  on error err_msg number err_num
    return 0
  end try
end run
EOF
)
    local result
    result=$(osascript -e "$applescript" 2>/dev/null)
    if [ "$result" = "1" ]; then
        print_success "App is installed (bundle id: $bundle_id)"
        exit 0
    else
        print_warning "App is not installed (bundle id: $bundle_id)"
        exit 1
    fi
}

if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

case "$1" in
    --check-installed|-c)
        do_check_installed "$2"
        ;;
    *)
        print_error "Unknown option: $1"
        usage
        exit 2
        ;;
esac
