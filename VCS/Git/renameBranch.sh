#!/bin/bash
# Author: Rohtash Lakra
# Rename a Git branch (both local and remote)
# Usage:
#   ./renameBranch.sh <old_branch> <new_branch>
#   ./renameBranch.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Rename a Git branch (both local and remote).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./renameBranch.sh <old_branch> <new_branch>${NC}"
    echo -e "  ${AQUA}./renameBranch.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}<old_branch>${NC} - Current name of the branch to rename"
    echo -e "  ${INDIGO}<new_branch>${NC}  - New name for the branch"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}This script renames a Git branch by:${NC}"
    echo -e "  ${INDIGO}  1. Checking out the old branch${NC}"
    echo -e "  ${INDIGO}  2. Renaming the local branch${NC}"
    echo -e "  ${INDIGO}  3. Deleting the old remote branch${NC}"
    echo -e "  ${INDIGO}  4. Pushing the new branch and setting upstream${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./renameBranch.sh feature1 feature2${NC}    # Rename feature1 to feature2"
    echo -e "  ${AQUA}./renameBranch.sh old-name new-name${NC}    # Rename old-name to new-name"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Validate arguments
if [ $# -lt 2 ]; then
    print_error "Both old branch name and new branch name are required"
    usage
    exit 1
fi

oldBranch="$1"
newBranch="$2"

# Validate branch names
if [ -z "${oldBranch}" ] || [ -z "${newBranch}" ]; then
    print_error "Branch names cannot be empty"
    usage
    exit 1
fi

# Check if old branch exists locally
if ! git show-ref --verify --quiet refs/heads/"${oldBranch}"; then
    print_error "Local branch '${oldBranch}' does not exist"
    echo -e "${INDIGO}Available local branches:${NC}"
    git branch --list | sed 's/^/  /'
    exit 1
fi

# Check if new branch already exists
if git show-ref --verify --quiet refs/heads/"${newBranch}"; then
    print_error "Branch '${newBranch}' already exists locally"
    exit 1
fi

print_header "Rename Git Branch"
echo -e "${INDIGO}Renaming branch: ${AQUA}${oldBranch}${INDIGO} -> ${AQUA}${newBranch}${NC}"
echo

# Store current branch to return to it if needed
current_branch=$(git branch --show-current)

# Switch to the old branch
echo -e "${INDIGO}Checking out branch: ${AQUA}${oldBranch}${NC}"
echo -e "${BROWN}git checkout ${oldBranch}${NC}"
git checkout "${oldBranch}"
if [ $? -ne 0 ]; then
    print_error "Failed to checkout branch: ${oldBranch}"
    exit 1
fi

# Rename the local branch
echo
echo -e "${INDIGO}Renaming local branch: ${AQUA}${oldBranch}${INDIGO} -> ${AQUA}${newBranch}${NC}"
echo -e "${BROWN}git branch -m ${newBranch}${NC}"
git branch -m "${newBranch}"
if [ $? -ne 0 ]; then
    print_error "Failed to rename local branch"
    exit 1
fi

# Delete the old remote branch if it exists
echo
echo -e "${INDIGO}Deleting remote branch: ${AQUA}${oldBranch}${NC}"
echo -e "${BROWN}git push origin --delete ${oldBranch}${NC}"
git push origin --delete "${oldBranch}" 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Deleted remote branch: ${oldBranch}"
else
    print_warning "Remote branch '${oldBranch}' may not exist or already deleted"
fi

# Push the new branch and set upstream
echo
echo -e "${INDIGO}Pushing new branch and setting upstream: ${AQUA}${newBranch}${NC}"
echo -e "${BROWN}git push origin -u ${newBranch}${NC}"
git push origin -u "${newBranch}"
if [ $? -ne 0 ]; then
    print_error "Failed to push new branch to remote"
    exit 1
fi

echo
print_success "Branch renamed successfully: ${oldBranch} -> ${newBranch}"
echo
