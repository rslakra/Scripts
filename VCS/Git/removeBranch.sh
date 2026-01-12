#!/bin/bash
# Author: Rohtash Lakra
# Remove a Git branch (both local and remote)
# Usage:
#   ./removeBranch.sh <branch_name>
#   ./removeBranch.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Remove a Git branch (both local and remote).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./removeBranch.sh <branch_name>${NC}"
    echo -e "  ${AQUA}./removeBranch.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}<branch_name>${NC} - Name of the branch to remove"
    echo
    echo -e "${BROWN}Example:${NC}"
    echo -e "  ${AQUA}./removeBranch.sh feature-branch${NC}"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Validate arguments
if [ $# -lt 1 ]; then
    print_error "Branch name is required"
    usage
    exit 1
fi

BRANCH_NAME="$1"

print_header "Remove Git Branch"
echo
echo -e "${INDIGO}Deleting remote branch: ${AQUA}${BRANCH_NAME}${NC}"
echo -e "${BROWN}git push -d origin ${BRANCH_NAME}${NC}"
git push -d origin "$BRANCH_NAME" 2>/dev/null || print_warning "Remote branch may not exist or already deleted"
echo
echo -e "${INDIGO}Deleting local branch: ${AQUA}${BRANCH_NAME}${NC}"
echo -e "${BROWN}git branch -D ${BRANCH_NAME}${NC}"
git branch -D "$BRANCH_NAME"
if [ $? -ne 0 ]; then
    print_error "Failed to delete local branch: ${BRANCH_NAME}"
    exit 1
fi
echo
print_success "Branch removed successfully!"
echo

