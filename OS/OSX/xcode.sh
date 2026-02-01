#!/bin/bash
# Author: Rohtash Lakra
# Install or uninstall (reset) Xcode Command Line Tools.
# Usage:
#   ./xcode.sh install      # Install command line tools
#   ./xcode.sh uninstall    # Reset Xcode (sudo xcode-select --reset)
#   ./xcode.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Xcode Command Line Tools: install or uninstall.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./xcode.sh <action>${NC}"
    echo -e "  ${AQUA}./xcode.sh --help${NC}   # Show this help"
    echo
    echo -e "${BROWN}Actions:${NC}"
    echo -e "  ${INDIGO}install${NC}        Install Xcode Command Line Tools (xcode-select --install)"
    echo -e "  ${INDIGO}uninstall${NC}      Reset Xcode (sudo xcode-select --reset)"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./xcode.sh install${NC}"
    echo -e "  ${AQUA}./xcode.sh uninstall${NC}"
    echo
}

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

case "$1" in
    --help|-h)
        usage
        exit 0
        ;;
    install|--install)
        print_header "Install Xcode Command Line Tools"
        echo -e "${INDIGO}Installing Xcode command line tools...${NC}"
        xcode-select --install
        print_success "Xcode command line tools installation initiated!"
        ;;
    uninstall|--uninstall)
        print_header "Reset Xcode Command Line Tools"
        echo -e "${INDIGO}Resetting Xcode developer directory (requires sudo)...${NC}"
        sudo xcode-select --reset
        print_success "Xcode command line tools reset completed!"
        ;;
    *)
        print_error "Unknown action: $1"
        usage
        exit 1
        ;;
esac
echo
