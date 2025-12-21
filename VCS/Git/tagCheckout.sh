#!/bin/bash
#Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

tagName=${1:-"v1.0.0"}
branchName="${tagName}-branch"
print_header "Checkout Tag"
echo -e "${INDIGO}Checking out tag ${AQUA}${tagName}${INDIGO} into branch ${AQUA}${branchName}${NC}"
git checkout tags/${tagName} -b ${branchName}
print_success "Tag checked out successfully!"
echo
