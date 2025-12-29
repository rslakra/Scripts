#!/bin/bash
#Author: Rohtash Lakra
# Fetch Git tags or display latest tag
# Usage:
#   ./fetchTags.sh              # Display latest tag (default)
#   ./fetchTags.sh --latest     # Display latest tag
#   ./fetchTags.sh --all        # Fetch all tags
#   ./fetchTags.sh --tag <tag>  # Fetch specific tag

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./fetchTags.sh${NC}               # Display latest tag (default)"
    echo -e "  ${AQUA}./fetchTags.sh --latest${NC}      # Display latest tag"
    echo -e "  ${AQUA}./fetchTags.sh --all${NC}         # Fetch all tags"
    echo -e "  ${AQUA}./fetchTags.sh --tag <tag>${NC}   # Fetch specific tag"
    echo
}

# Parse arguments
mode="latest"  # Default mode
TAG_NAME=""

if [ $# -gt 0 ]; then
    case "$1" in
        --all)
            mode="all"
            ;;
        --latest)
            mode="latest"
            ;;
        --tag)
            if [ -z "$2" ]; then
                print_error "Please provide a tag name after --tag"
                usage
                exit 1
            fi
            mode="tag"
            TAG_NAME="$2"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
fi

# Execute based on mode
case "$mode" in
    all)
        print_header "Fetch All Tags"
        echo -e "${INDIGO}Fetching all tags from remote...${NC}"
        echo -e "${BROWN}git fetch --all --tags${NC}"
        git fetch --all --tags
        print_success "All tags fetched successfully!"
        echo
        ;;
    latest)
        print_header "Latest Tag"
        echo -e "${INDIGO}Finding latest tag...${NC}"
        echo -e "${BROWN}git describe --tags \`git rev-list --tags --max-count=1\`${NC}"
        tag=$(git describe --tags `git rev-list --tags --max-count=1` 2>/dev/null)
        if [ -z "$tag" ]; then
            print_warning "No tags found in the repository"
        else
            echo -e "${GREEN}Latest Tag:${NC} ${AQUA}${tag}${NC}"
        fi
        echo
        ;;
    tag)
        print_header "Fetch Specific Tag"
        echo -e "${INDIGO}Fetching tag: ${AQUA}${TAG_NAME}${NC}"
        echo -e "${BROWN}git fetch origin tag ${TAG_NAME}${NC}"
        git fetch origin tag "${TAG_NAME}"
        if [ $? -eq 0 ]; then
            print_success "Tag '${TAG_NAME}' fetched successfully!"
        else
            print_error "Failed to fetch tag '${TAG_NAME}'. It may not exist on the remote."
            exit 1
        fi
        echo
        ;;
esac
