#!/bin/bash
#Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Checkout a Git tag into a new branch.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./tagCheckout.sh [tagName]${NC}"
    echo -e "  ${AQUA}./tagCheckout.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}[tagName]${NC} - Tag name to checkout (default: v1.0.0)"
    echo -e "  ${INDIGO}              ${NC}  New branch will be named: <tagName>-branch"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./tagCheckout.sh${NC}              # Checkout v1.0.0 into v1.0.0-branch"
    echo -e "  ${AQUA}./tagCheckout.sh v2.0.0${NC}       # Checkout v2.0.0 into v2.0.0-branch"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

tagName=${1:-"v1.0.0"}
branchName="${tagName}-branch"
print_header "Checkout Tag"
echo -e "${INDIGO}Checking out tag ${AQUA}${tagName}${INDIGO} into branch ${AQUA}${branchName}${NC}"
git checkout tags/${tagName} -b ${branchName}
if [ $? -ne 0 ]; then
    print_error "Failed to checkout tag: ${tagName}"
    exit 1
fi
print_success "Tag checked out successfully!"
echo
