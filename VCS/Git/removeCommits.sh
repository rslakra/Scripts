#!/bin/bash
# Author: Rohtash Lakra
# Deletes commits up until a specific commit
# Reference: https://articles.assembla.com/en/articles/2941346-how-to-delete-commits-from-a-branch-in-git
# Usage:
#   ./removeCommits.sh <commit_id>
#   ./removeCommits.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Delete commits up until a specific commit (destructive operation).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./removeCommits.sh <commit_id>${NC}"
    echo -e "  ${AQUA}./removeCommits.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}<commit_id>${NC} - SHA1 commit hash to reset to (all commits after this will be deleted)"
    echo
    echo -e "${RED}WARNING:${NC}"
    echo -e "  ${INDIGO}This is a destructive operation that will:${NC}"
    echo -e "  ${INDIGO}  - Delete all commits after the specified commit${NC}"
    echo -e "  ${INDIGO}  - Discard all uncommitted changes${NC}"
    echo -e "  ${INDIGO}  - Force push to remote (rewrites history)${NC}"
    echo -e "  ${INDIGO}  - May affect other collaborators${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./removeCommits.sh abc1234${NC}   # Reset to commit abc1234"
    echo -e "  ${AQUA}./removeCommits.sh HEAD~3${NC}    # Reset to 3 commits before HEAD"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Validate arguments
if [ $# -lt 1 ]; then
    print_error "Commit ID is required"
    usage
    exit 1
fi

GIT_SHA1_COMMIT_ID="$1"

# Validate commit exists
if ! git rev-parse --verify "$GIT_SHA1_COMMIT_ID" >/dev/null 2>&1; then
    print_error "Invalid commit ID: ${GIT_SHA1_COMMIT_ID}"
    echo -e "${INDIGO}Please provide a valid commit hash or reference (e.g., HEAD~3)${NC}"
    exit 1
fi

print_header "Remove Git Commits"
echo -e "${RED}WARNING: This is a destructive operation!${NC}"
echo -e "${INDIGO}This will delete all commits after ${AQUA}${GIT_SHA1_COMMIT_ID}${INDIGO} and force push to remote.${NC}"
echo

# Show what will be deleted
current_branch=$(git branch --show-current)
echo -e "${INDIGO}Current branch: ${AQUA}${current_branch}${NC}"
echo -e "${INDIGO}Target commit: ${AQUA}${GIT_SHA1_COMMIT_ID}${NC}"
echo

# Show commits that will be deleted
commits_to_delete=$(git log --oneline "${GIT_SHA1_COMMIT_ID}..HEAD" 2>/dev/null | wc -l | tr -d ' ')
if [ "$commits_to_delete" -gt 0 ]; then
    echo -e "${BROWN}Commits that will be deleted (${commits_to_delete}):${NC}"
    git log --oneline "${GIT_SHA1_COMMIT_ID}..HEAD" 2>/dev/null | head -10
    if [ "$commits_to_delete" -gt 10 ]; then
        echo -e "${BROWN}... and $((commits_to_delete - 10)) more${NC}"
    fi
    echo
else
    print_warning "No commits to delete (already at or before the specified commit)"
    exit 0
fi

# Confirm if not in a non-interactive environment
if [ -t 0 ]; then
    echo -e "${RED}Are you sure you want to continue? (yes/no):${NC} "
    read -r confirmation
    if [ "$confirmation" != "yes" ]; then
        print_warning "Operation cancelled"
        exit 0
    fi
    echo
fi

# Discard all working tree changes and move HEAD to the commit chosen
echo -e "${INDIGO}Resetting to commit: ${AQUA}${GIT_SHA1_COMMIT_ID}${NC}"
echo -e "${BROWN}git reset --hard ${GIT_SHA1_COMMIT_ID}${NC}"
git reset --hard "$GIT_SHA1_COMMIT_ID"
if [ $? -ne 0 ]; then
    print_error "Failed to reset to commit: ${GIT_SHA1_COMMIT_ID}"
    exit 1
fi

echo
echo -e "${INDIGO}Force pushing to remote...${NC}"
echo -e "${BROWN}git push origin HEAD --force${NC}"
git push origin HEAD --force
if [ $? -ne 0 ]; then
    print_error "Failed to force push to remote"
    exit 1
fi

echo
print_success "Commits removed successfully!"
echo -e "${INDIGO}Repository reset to: ${AQUA}${GIT_SHA1_COMMIT_ID}${NC}"
echo

