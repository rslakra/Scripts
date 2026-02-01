#!/bin/bash
# Author: Rohtash Lakra
# Git commit utilities: reset author, amend, and more
# Usage:
#   ./commit.sh <action>           # Run an action (required)
#   ./commit.sh --help             # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Git commit utilities: reset author, amend, and more.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./commit.sh <action>${NC}"
    echo -e "  ${AQUA}./commit.sh --help${NC}   # Show this help"
    echo
    echo -e "${BROWN}Actions:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}           Show this help message"
    echo -e "  ${INDIGO}--reset-author${NC}       Reset author of last commit"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./commit.sh --reset-author${NC}   # Reset author of last commit"
    echo
    echo -e "${BROWN}Note:${NC}"
    echo -e "  ${INDIGO}--reset-author only affects the most recent commit.${NC}"
    echo -e "  ${INDIGO}If you've already pushed, you'll need to force push.${NC}"
    echo
}

# No action provided: show help and exit
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

ACTION="$1"

# Parse action and optional extra args
case "$ACTION" in
    --reset-author)
        # Check if we're in a git repository
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            print_error "Not a git repository"
            exit 1
        fi
        if ! git rev-parse HEAD > /dev/null 2>&1; then
            print_error "No commits found in this repository"
            exit 1
        fi
        print_header "Reset Commit Author"
        echo -e "${INDIGO}Resetting commit author without editing...${NC}"
        echo -e "${BROWN}git commit --amend --reset-author --no-edit${NC}"
        git commit --amend --reset-author --no-edit
        if [ $? -ne 0 ]; then
            print_error "Failed to reset commit author"
            exit 1
        fi
        print_success "Commit author reset successfully!"
        ;;
    *)
        print_error "Unknown option: $ACTION"
        usage
        exit 1
        ;;
esac
echo

