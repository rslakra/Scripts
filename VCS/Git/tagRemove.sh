#!/bin/bash
#Author: Rohtash Lakra
# Remove Git tags (single or all)
# Usage:
#   ./tagRemove.sh <tagName>    # Remove a specific tag
#   ./tagRemove.sh --all        # Remove all tags

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./tagRemove.sh <tagName>${NC}    # Remove a specific tag"
    echo -e "  ${AQUA}./tagRemove.sh --all${NC}        # Remove all tags"
    echo
}

# Function to remove a single tag
remove_single_tag() {
    local tagName="$1"
    
    if [ -z "${tagName}" ]; then
        print_error "Please provide a tag name"
        usage
        exit 1
    fi
    
    print_header "Remove Git Tag"
    echo -e "${INDIGO}Deleting local tag: ${AQUA}${tagName}${NC}"
    echo -e "${BROWN}git tag -d ${tagName}${NC}"
    git tag -d "$tagName"
    
    echo
    echo -e "${INDIGO}Deleting remote tag: ${AQUA}${tagName}${NC}"
    echo -e "${BROWN}git push --delete origin ${tagName}${NC}"
    git push --delete origin "$tagName"
    
    print_success "Tag removed successfully!"
    echo
}

# Function to remove all tags
remove_all_tags() {
    print_header "Remove All Git Tags"
    
    # Get all tags
    allGitTags=$(git tag -l)
    
    if [ -z "$allGitTags" ]; then
        print_warning "No tags found to remove"
        echo
        return 0
    fi
    
    # Delete local tags first
    echo -e "${INDIGO}Deleting local tags: ${AQUA}${allGitTags}${NC}"
    echo -e "${BROWN}git tag -d \$(git tag -l)${NC}"
    git tag -d $(git tag -l)
    
    # Fetch remote tags
    echo
    echo -e "${INDIGO}Fetching remote tags${NC}"
    echo -e "${BROWN}git fetch${NC}"
    git fetch
    
    # Delete remote tags
    echo
    echo -e "${INDIGO}Deleting remote tags: ${AQUA}${allGitTags}${NC}"
    echo -e "${BROWN}git push origin --delete \$(git tag -l)${NC}"
    git push origin --delete $(git tag -l) 2>/dev/null || true  # Continue even if some tags don't exist remotely
    
    # Delete local tags again (clean up any remaining)
    remainingTags=$(git tag -l)
    if [ -n "$remainingTags" ]; then
        echo
        echo -e "${INDIGO}Deleting remaining local tags: ${AQUA}${remainingTags}${NC}"
        echo -e "${BROWN}git tag -d \$(git tag -l)${NC}"
        git tag -d $(git tag -l)
    fi
    
    print_success "All tags removed successfully!"
    echo
}

# Parse arguments
if [ $# -eq 0 ]; then
    print_error "No arguments provided"
    usage
    exit 1
elif [ "$1" == "--all" ]; then
    remove_all_tags
else
    # Treat first argument as tag name
    remove_single_tag "$1"
fi
