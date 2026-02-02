#!/bin/bash
# Author: Rohtash Lakra
# Empty Trash: user Trash and optionally .Trashes on mounted volumes.
# Usage:
#   ./trashCleanup.sh                              # Empty current user's Trash (default)
#   ./trashCleanup.sh --volumes <name> [name...]   # Also empty .Trashes on volumes (names → /Volumes/<name>)
#   ./trashCleanup.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Empty Trash: user Trash and optionally .Trashes on mounted volumes.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./trashCleanup.sh${NC}                                # Empty current user's Trash (default)"
    echo -e "  ${AQUA}./trashCleanup.sh --volumes <name> [name...]${NC}     # Also empty .Trashes on volumes (names → /Volumes/<name>)"
    echo -e "  ${AQUA}./trashCleanup.sh --help${NC}                         # Show this help"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./trashCleanup.sh${NC}                                # User Trash only"
    echo -e "  ${AQUA}./trashCleanup.sh --volumes RSL1TBHD RSL2TBHD${NC}    # Cleans /Volumes/RSL1TBHD/.Trashes, /Volumes/RSL2TBHD/.Trashes"
    echo
    echo -e "${BROWN}Note:${NC} Clearing .Trashes on volumes may require sudo."
    echo
}

print_header "Trash Cleanup"

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

LOGGED_IN_USER="${USER:-$(logname)}"
USER_TRASH="${HOME:-/Users/$(logname)}/.Trash"

# Empty user Trash (contents only; find -mindepth 1 avoids touching . and ..)
if [ -d "$USER_TRASH" ]; then
    echo -e "${INDIGO}User: ${AQUA}${LOGGED_IN_USER}${INDIGO} — Emptying Trash: ${AQUA}${USER_TRASH}${NC}"
    find "$USER_TRASH" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    print_success "User Trash emptied."
else
    print_warning "User Trash not found: $USER_TRASH"
fi

# Optional: empty .Trashes on volumes (volume names get /Volumes/ prefix)
if [ "$1" == "--volumes" ]; then
    shift
    while [ -n "$1" ]; do
        vol_name="$1"
        # Use /Volumes/<name> if not already an absolute path
        if [[ "$vol_name" != /* ]]; then
            vol_path="/Volumes/${vol_name}"
        else
            vol_path="$vol_name"
        fi
        vol_trash="${vol_path}/.Trashes"
        if [ -d "$vol_trash" ]; then
            echo -e "${INDIGO}Emptying volume Trash: ${AQUA}${vol_trash}${NC}"
            sudo find "$vol_trash" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Volume Trash emptied: $vol_name"
        else
            print_warning "Volume Trash not found: $vol_trash"
        fi
        shift
    done
fi

echo
