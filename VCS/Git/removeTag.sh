#!/bin/bash
#Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Remove Git Tag"
tagName=$1
if [ -z "${tagName}" ]; then
    print_error "Please provide a tag name"
    echo
    echo -e "${DARKBLUE}Usage:${NC} ./removeTag.sh <tagName>"
    echo
    exit 1
fi
echo -e "${INDIGO}Deleting local tag: ${AQUA}${tagName}${NC}"
echo -e "${BROWN}git tag -d ${tagName}${NC}"
git tag -d $tagName
echo
echo -e "${INDIGO}Deleting remote tag: ${AQUA}${tagName}${NC}"
echo -e "${BROWN}git push --delete origin ${tagName}${NC}"
git push --delete origin $tagName
print_success "Tag removed successfully!"
echo
