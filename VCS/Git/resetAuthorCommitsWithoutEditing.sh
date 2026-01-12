#!/bin/bash
# Author: Rohtash Lakra
# Reset the author of the last commit without editing the commit message
# Usage:
#   ./resetAuthorCommitsWithoutEditing.sh
#   ./resetAuthorCommitsWithoutEditing.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Reset the author of the last commit without editing the commit message.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./resetAuthorCommitsWithoutEditing.sh${NC}"
    echo -e "  ${AQUA}./resetAuthorCommitsWithoutEditing.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}Amends the last commit to reset the author to the current Git user${NC}"
    echo -e "  ${INDIGO}configuration without changing the commit message.${NC}"
    echo -e "  ${INDIGO}This is useful when you want to update the author of your last commit.${NC}"
    echo
    echo -e "${BROWN}Note:${NC}"
    echo -e "  ${INDIGO}This only affects the most recent commit.${NC}"
    echo -e "  ${INDIGO}If you've already pushed the commit, you'll need to force push.${NC}"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

# Check if there are any commits
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
echo

