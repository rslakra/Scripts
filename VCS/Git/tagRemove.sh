#!/bin/bash
#Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

tagName=$1
if [ -z "${tagName}" ]; then
    print_error "Please provide a tag name"
    echo
    echo -e "${DARKBLUE}Usage:${NC} ./tagRemove.sh <tagName>"
    echo
    exit 1
fi

print_header "Remove Git Tag"
echo -e "${INDIGO}Delete local tag${NC}"
echo -e "${BROWN}git tag -d ${tagName}${NC}"
git tag -d $1
echo
echo -e "${INDIGO}Delete remote tag${NC}"
echo -e "${BROWN}git push --delete origin ${tagName}${NC}"
git push --delete origin $1
print_success "Tag removed successfully!"
echo
