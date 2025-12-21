#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
oldBranch=$1
newBranch=$2
if [[ -z "${oldBranch}" || -z "${newBranch}" ]]; then
   echo
   echo -e "${DARKBLUE}This utility renames the existing GIT branch to the new branch. The parameters are mandatory.${NC}"
   echo -e "${BROWN}<Old Branch Name>:${NC} - The branch to be renamed"
   echo -e "${BROWN}<New Branch Name>:${NC} - The new name of the branch"
   echo
   echo -e "${DARKBLUE}Syntax:${NC}"
   echo -e "./renameGitBranch <Old Branch Name> <New Branch Name>"
   echo
   echo -e "${BROWN}For Example:${NC}"
   echo -e "./renameGitBranch feature1 feature2"
   echo -e "The 'feature1' branch will be renamed to 'feature2'."
   echo
   exit 1;
else
   print_header "Rename Git Branch"
   echo -e "${INDIGO}Renaming GIT branch: ${AQUA}'${oldBranch}'${INDIGO} to ${AQUA}'${newBranch}'${INDIGO} ...${NC}"
fi

echo
echo -e "${INDIGO}Switching to the local '${AQUA}${oldBranch}${INDIGO}' branch, which you want to rename${NC}"
git checkout ${oldBranch}
echo -e "${INDIGO}Renaming the local '${AQUA}${oldBranch}${INDIGO}' branch with new '${AQUA}${newBranch}${INDIGO}' branch name.${NC}"
git branch -m ${newBranch}
echo -e "${INDIGO}Deleting the '${AQUA}${oldBranch}${INDIGO}' remote branch, if it's already pushed to the remote repository${NC}"
git push origin --delete ${oldBranch}
echo -e "${INDIGO}Finally, pushing the '${AQUA}${newBranch}${INDIGO}' local branch and reset the upstream branch${NC}"
git push origin -u ${newBranch}
print_success "'${oldBranch}' branch is renamed successfully to '${newBranch}' branch."
echo
