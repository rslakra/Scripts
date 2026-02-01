#!/bin/bash
# Author: Rohtash Lakra
# macOS Dock, Finder, and Desktop options (defaults write).
# Usage:
#   ./macOSDefaults.sh <action>     # Run an action (required)
#   ./macOSDefaults.sh --help       # Show help
#
# Actions: dock-spacer, finder-path, dock-show-hidden, finder-show-hidden, no-ds-store-network

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}macOS Dock, Finder, and Desktop options (defaults write).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./macOSDefaults.sh <action>${NC}"
    echo -e "  ${AQUA}./macOSDefaults.sh --help${NC}   # Show this help"
    echo
    echo -e "${BROWN}Actions:${NC}"
    echo -e "  ${INDIGO}dock-spacer${NC}            Add a spacer between Dock icons (drag to move, drag out to remove)"
    echo -e "  ${INDIGO}finder-path${NC}            Show full path in Finder window title"
    echo -e "  ${INDIGO}dock-show-hidden${NC}       Show hidden app icons in Dock (transparent)"
    echo -e "  ${INDIGO}finder-show-hidden${NC}     Show hidden files and folders in Finder"
    echo -e "  ${INDIGO}no-ds-store-network${NC}    Stop creating .DS_Store on network volumes"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./macOSDefaults.sh dock-spacer${NC}"
    echo -e "  ${AQUA}./macOSDefaults.sh finder-show-hidden${NC}"
    echo
}

do_dock_spacer() {
    print_header "Dock: Add Spacer"
    echo -e "${INDIGO}Adding spacer to Dock...${NC}"
    defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
    killall Dock
    print_success "Spacer added. Drag it to move; drag out to remove."
}

do_finder_path() {
    print_header "Finder: Show Path in Title"
    echo -e "${INDIGO}Enabling path in Finder window title...${NC}"
    defaults write com.apple.finder FXShowPosixPathInTitle -bool YES
    killall Finder
    print_success "Path will show in Finder title. Restart Finder if needed."
}

do_dock_show_hidden() {
    print_header "Dock: Show Hidden App Icons"
    echo -e "${INDIGO}Making hidden app icons visible (transparent) in Dock...${NC}"
    defaults write com.apple.dock showhidden -boolean yes
    killall Dock
    print_success "Hidden app icons will show in Dock."
}

do_finder_show_hidden() {
    print_header "Finder: Show Hidden Files"
    echo -e "${INDIGO}Showing hidden files and folders in Finder...${NC}"
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
    print_success "Hidden files will show in Finder. To revert: defaults write com.apple.finder AppleShowAllFiles -bool false; killall Finder"
}

do_no_ds_store_network() {
    print_header "Desktop: No .DS_Store on Network"
    echo -e "${INDIGO}Stopping .DS_Store creation on network volumes...${NC}"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    print_success ".DS_Store will not be written on network volumes."
}

if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

case "$1" in
    dock-spacer)
        do_dock_spacer
        ;;
    finder-path)
        do_finder_path
        ;;
    dock-show-hidden)
        do_dock_show_hidden
        ;;
    finder-show-hidden)
        do_finder_show_hidden
        ;;
    no-ds-store-network)
        do_no_ds_store_network
        ;;
    *)
        print_error "Unknown action: $1"
        usage
        exit 1
        ;;
esac
echo
