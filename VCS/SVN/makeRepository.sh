#!/bin/bash
#
# This script makes a new repository with the given name.
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Create SVN Repository"
repoName=${1:-"SVNRepo"}
echo -e "${INDIGO}Creating SVN repository: ${AQUA}${repoName}${NC}"
svnadmin create --fs-type fsfs ${repoName}
print_success "SVN repository created successfully!"
echo

