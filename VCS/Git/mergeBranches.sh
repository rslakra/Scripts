#!/bin/bash
# Author: Rohtash Lakra
# mergeBranches  # Merges the branches
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage:
usage () {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo
    echo -e "\t${AQUA}~/mergeBranches <SOURCE_BRANCH> <TARGET_BRANCH>${NC}"
    echo
    echo -e "${BROWN}Example:${NC}"
    echo
    echo -e "\t~/mergeBranches staging develop"
    echo
    exit 2
}

# Branches
SOURCE_BRANCH=$1
TARGET_BRANCH=$2
# check no. of args
if [ $# -eq 0 ]; then
  usage
elif [ $# -le 2 ]; then
  usage
else
  print_header "Merge Branches"
  echo -e "${INDIGO}Merging ${AQUA}${SOURCE_BRANCH}${INDIGO} into ${AQUA}${TARGET_BRANCH}${INDIGO} ...${NC}"
  echo
  git checkout $SOURCE_BRANCH;
  git pull
  git merge --ff-only origin/$TARGET_BRANCH;
  git push;
  print_success "Merge completed!"
fi
echo

