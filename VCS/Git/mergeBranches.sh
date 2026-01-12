#!/bin/bash
# Author: Rohtash Lakra
# Merges source branch into target branch
# Usage:
#   ./mergeBranches.sh <SOURCE_BRANCH> <TARGET_BRANCH>

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./mergeBranches.sh <SOURCE_BRANCH> <TARGET_BRANCH>${NC}"
    echo -e "  ${AQUA}./mergeBranches.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}<SOURCE_BRANCH>${NC} - Source branch to merge from"
    echo -e "  ${INDIGO}<TARGET_BRANCH>${NC} - Target branch to merge into"
    echo
    echo -e "${BROWN}Example:${NC}"
    echo -e "  ${AQUA}./mergeBranches.sh staging develop${NC}"
    echo -e "  ${INDIGO}This will merge 'staging' branch into 'develop' branch${NC}"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Get branch parameters
SOURCE_BRANCH=$1
TARGET_BRANCH=$2

# Validate arguments
if [ $# -lt 2 ]; then
    print_error "Both source and target branch names are required"
    usage
    exit 1
fi

print_header "Merge Branches"
echo -e "${INDIGO}Merging ${AQUA}${SOURCE_BRANCH}${INDIGO} into ${AQUA}${TARGET_BRANCH}${INDIGO} ...${NC}"
echo

# Fetch latest changes to ensure we have remote branches
echo -e "${INDIGO}Fetching latest changes from remote...${NC}"
echo -e "${BROWN}git fetch${NC}"
git fetch
if [ $? -ne 0 ]; then
    print_warning "Failed to fetch from remote. Continuing anyway..."
fi

# Store current branch to return to it later if needed
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)

# Update source branch if it exists locally
echo
if git show-ref --verify --quiet refs/heads/${SOURCE_BRANCH}; then
    echo -e "${INDIGO}Updating source branch: ${AQUA}${SOURCE_BRANCH}${NC}"
    echo -e "${BROWN}git checkout ${SOURCE_BRANCH}${NC}"
    git checkout ${SOURCE_BRANCH}
    if [ $? -eq 0 ]; then
        echo -e "${BROWN}git pull${NC}"
        git pull
        if [ $? -ne 0 ]; then
            print_warning "Failed to pull latest changes for source branch. Continuing anyway..."
        fi
    else
        print_warning "Failed to checkout source branch. Will merge from remote tracking branch."
    fi
else
    echo -e "${INDIGO}Source branch ${AQUA}${SOURCE_BRANCH}${INDIGO} doesn't exist locally. Will merge from remote tracking branch.${NC}"
fi

# Checkout target branch
echo
echo -e "${INDIGO}Checking out target branch: ${AQUA}${TARGET_BRANCH}${NC}"
echo -e "${BROWN}git checkout ${TARGET_BRANCH}${NC}"
git checkout ${TARGET_BRANCH}
if [ $? -ne 0 ]; then
    print_error "Failed to checkout target branch: ${TARGET_BRANCH}"
    exit 1
fi

# Pull latest changes for target branch
echo
echo -e "${INDIGO}Pulling latest changes for ${AQUA}${TARGET_BRANCH}${NC}"
echo -e "${BROWN}git pull${NC}"
git pull
if [ $? -ne 0 ]; then
    print_warning "Failed to pull latest changes. Continuing anyway..."
fi

# Merge source branch into target branch
echo
echo -e "${INDIGO}Merging ${AQUA}${SOURCE_BRANCH}${INDIGO} into ${AQUA}${TARGET_BRANCH}${NC}"
echo -e "${BROWN}git merge ${SOURCE_BRANCH}${NC}"
git merge --ff-only ${SOURCE_BRANCH}
if [ $? -ne 0 ]; then
    print_error "Merge failed. Please resolve conflicts manually."
    exit 1
fi

# Push the merged changes
echo
echo -e "${INDIGO}Pushing merged changes to remote...${NC}"
echo -e "${BROWN}git push${NC}"
git push
if [ $? -ne 0 ]; then
    print_error "Failed to push changes to remote"
    exit 1
fi

echo
print_success "Successfully merged '${SOURCE_BRANCH}' into '${TARGET_BRANCH}'!"
echo

