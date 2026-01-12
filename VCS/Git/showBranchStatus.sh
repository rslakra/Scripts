#!/bin/bash
#Author: Rohtash Lakra
# Show Git branch status with commit graph

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Show Git branch status with commit graph.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./showBranchStatus.sh${NC}"
    echo -e "  ${AQUA}./showBranchStatus.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}Displays a one-line commit log with graph visualization${NC}"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

print_header "Branch Status"
git log --oneline --graph
echo
