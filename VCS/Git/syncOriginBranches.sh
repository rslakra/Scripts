#!/bin/bash
# Author: Rohtash Lakra
# Your local branch is now an exact copy (commits and all) of the remote branch.

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

REMOTE_BRANCH=$1
print_header "Sync with Remote Branch"
# Validate the parameter provided or not.
if [ -n "${REMOTE_BRANCH}" ]; then
    echo -e "${INDIGO}Syncing local branch with remote [${AQUA}${REMOTE_BRANCH}${INDIGO}] branch ...${NC}"
    echo
    git fetch origin && git reset --hard origin/$REMOTE_BRANCH && git clean -f -d
    print_success "Branch synced successfully!"
else
   print_error "Please, provide <REMOTE_BRANCH> name."
   echo
   echo -e "${DARKBLUE}Syntax:${NC}"
   echo -e "./syncBranchWithRemote <REMOTE_BRANCH>"
   echo
   echo -e "${BROWN}Example:${NC}"
   echo -e "./syncBranchWithRemote develop"
   echo
fi
echo

