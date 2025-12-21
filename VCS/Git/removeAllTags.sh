#!/bin/bash
#Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Remove All Git Tags"
#Delete local tags.
allGitTags=$(git tag -l)
echo -e "${INDIGO}Deleting local tags: ${AQUA}${allGitTags}${NC}"
echo -e "${BROWN}git tag -d ${allGitTags}${NC}"
git tag -d $(git tag -l)

#Fetch remote tags.
echo
echo -e "${INDIGO}Fetching remote tags${NC}"
echo -e "${BROWN}git fetch${NC}"
git fetch

#Delete remote tags.
echo
echo -e "${INDIGO}Deleting remote tags: ${AQUA}${allGitTags}${NC}"
echo -e "${BROWN}git push origin --delete ${allGitTags}${NC}"
git push origin --delete $(git tag -l) # Pushing once should be faster than multiple times

#Delete local tags.
echo
echo -e "${INDIGO}Deleting local tags: ${AQUA}${allGitTags}${NC}"
echo -e "${BROWN}git tag -d ${allGitTags}${NC}"
git tag -d $(git tag -l)
print_success "All tags removed successfully!"
echo
