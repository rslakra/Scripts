#!/bin/bash
# Author: Rohtash Lakra
# Migrate repository from Bitbucket to GitHub or vice-versa using SSH
# Usage:
#   ./migrate-repository.sh --from <source_url> --to <dest_url> [options]
#   ./migrate-repository.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default values
SOURCE_URL=""
DEST_URL=""
TEMP_DIR=""
KEEP_TEMP=false
UPDATE_ORIGIN=false
BRANCHES_ONLY=false
TAGS_ONLY=false

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./migrate-repository.sh --from <source_url> --to <dest_url> [options]${NC}"
    echo
    echo -e "${DARKBLUE}Required Options:${NC}"
    echo -e "  ${AQUA}--from <url>${NC}          Source repository URL (Bitbucket or GitHub)"
    echo -e "  ${AQUA}--to <url>${NC}            Destination repository URL (GitHub or Bitbucket)"
    echo
    echo -e "${DARKBLUE}Optional Options:${NC}"
    echo -e "  ${AQUA}--temp-dir <path>${NC}     Temporary directory for cloning (default: /tmp/migrate-<repo-name>)"
    echo -e "  ${AQUA}--keep-temp${NC}           Keep temporary directory after migration"
    echo -e "  ${AQUA}--update-origin${NC}       Update origin remote to point to destination after migration"
    echo -e "  ${AQUA}--branches-only${NC}       Migrate only branches (skip tags)"
    echo -e "  ${AQUA}--tags-only${NC}           Migrate only tags (skip branches)"
    echo -e "  ${AQUA}--help${NC}                Show this help message"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}# Migrate from Bitbucket to GitHub${NC}"
    echo -e "  ${INDIGO}./migrate-repository.sh --from git@bitbucket.org:username/repo.git --to git@github.com:username/repo.git${NC}"
    echo
    echo -e "  ${AQUA}# Migrate from GitHub to Bitbucket${NC}"
    echo -e "  ${INDIGO}./migrate-repository.sh --from git@github.com:username/repo.git --to git@bitbucket.org:username/repo.git${NC}"
    echo
    echo -e "  ${AQUA}# Migrate and update origin to new location${NC}"
    echo -e "  ${INDIGO}./migrate-repository.sh --from git@bitbucket.org:user/repo.git --to git@github.com:user/repo.git --update-origin${NC}"
    echo
    echo -e "  ${AQUA}# Migrate only branches${NC}"
    echo -e "  ${INDIGO}./migrate-repository.sh --from git@bitbucket.org:user/repo.git --to git@github.com:user/repo.git --branches-only${NC}"
    echo
    echo -e "${INDIGO}Note:${NC} This script uses SSH for authentication. Make sure:"
    echo -e "  1. Your SSH keys are set up for both source and destination"
    echo -e "  2. You have access to both repositories"
    echo -e "  3. The destination repository exists (empty or with initial commit)"
    echo
}

# Function to extract repository name from URL
extract_repo_name() {
    local url="$1"
    # Remove .git suffix if present
    url="${url%.git}"
    # Extract the last part after the last /
    echo "${url##*/}"
}

# Function to validate SSH URL format
validate_ssh_url() {
    local url="$1"
    if [[ ! "$url" =~ ^git@[^:]+:[^/]+/[^/]+\.git$ ]]; then
        return 1
    fi
    return 0
}

# Function to check if repository is accessible
check_repo_access() {
    local url="$1"
    local name="$2"
    
    echo -e "${INDIGO}Checking access to ${AQUA}${name}${INDIGO} repository...${NC}"
    echo -e "${BROWN}git ls-remote ${url}${NC}"
    
    if git ls-remote "$url" > /dev/null 2>&1; then
        print_success "Repository is accessible"
        return 0
    else
        print_error "Cannot access repository: ${url}"
        echo -e "${INDIGO}Please verify:${NC}"
        echo -e "  1. The repository URL is correct"
        echo -e "  2. Your SSH key is added to the SSH agent"
        echo -e "  3. You have access permissions to the repository"
        return 1
    fi
}

# Function to clone repository
clone_repository() {
    local url="$1"
    local dest_dir="$2"
    
    echo
    echo -e "${INDIGO}Cloning repository from source...${NC}"
    echo -e "${BROWN}git clone --mirror ${url} ${dest_dir}${NC}"
    
    if git clone --mirror "$url" "$dest_dir"; then
        print_success "Repository cloned successfully"
        return 0
    else
        print_error "Failed to clone repository"
        return 1
    fi
}

# Function to push to destination
push_to_destination() {
    local repo_dir="$1"
    local dest_url="$2"
    
    cd "$repo_dir" || return 1
    
    echo
    echo -e "${INDIGO}Setting destination remote...${NC}"
    echo -e "${BROWN}git remote set-url origin ${dest_url}${NC}"
    git remote set-url origin "$dest_url"
    
    if [ "$BRANCHES_ONLY" = true ]; then
        echo
        echo -e "${INDIGO}Pushing all branches (skipping tags)...${NC}"
        echo -e "${BROWN}git push --all${NC}"
        if git push --all; then
            print_success "All branches pushed successfully"
        else
            print_error "Failed to push branches"
            return 1
        fi
    elif [ "$TAGS_ONLY" = true ]; then
        echo
        echo -e "${INDIGO}Pushing all tags (skipping branches)...${NC}"
        echo -e "${BROWN}git push --tags${NC}"
        if git push --tags; then
            print_success "All tags pushed successfully"
        else
            print_error "Failed to push tags"
            return 1
        fi
    else
        echo
        echo -e "${INDIGO}Pushing all branches and tags...${NC}"
        echo -e "${BROWN}git push --all${NC}"
        if git push --all; then
            print_success "All branches pushed successfully"
        else
            print_error "Failed to push branches"
            return 1
        fi
        
        echo
        echo -e "${BROWN}git push --tags${NC}"
        if git push --tags; then
            print_success "All tags pushed successfully"
        else
            print_error "Failed to push tags"
            return 1
        fi
    fi
    
    return 0
}

# Function to update origin in existing repository
update_origin() {
    local dest_url="$1"
    local current_dir="$(pwd)"
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        print_warning "Not in a git repository. Skipping origin update."
        return 0
    fi
    
    echo
    echo -e "${INDIGO}Updating origin remote to destination...${NC}"
    echo -e "${BROWN}git remote set-url origin ${dest_url}${NC}"
    git remote set-url origin "$dest_url"
    
    if [ $? -eq 0 ]; then
        print_success "Origin remote updated successfully"
        echo -e "${INDIGO}New origin URL: ${AQUA}$(git remote get-url origin)${NC}"
    else
        print_error "Failed to update origin remote"
        return 1
    fi
}

# Function to cleanup temporary directory
cleanup() {
    if [ "$KEEP_TEMP" = false ] && [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        echo
        echo -e "${INDIGO}Cleaning up temporary directory...${NC}"
        rm -rf "$TEMP_DIR"
        print_success "Temporary directory removed"
    elif [ "$KEEP_TEMP" = true ] && [ -n "$TEMP_DIR" ]; then
        echo
        echo -e "${INDIGO}Temporary directory kept at: ${AQUA}${TEMP_DIR}${NC}"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --from)
            SOURCE_URL="$2"
            shift 2
            ;;
        --to)
            DEST_URL="$2"
            shift 2
            ;;
        --temp-dir)
            TEMP_DIR="$2"
            shift 2
            ;;
        --keep-temp)
            KEEP_TEMP=true
            shift
            ;;
        --update-origin)
            UPDATE_ORIGIN=true
            shift
            ;;
        --branches-only)
            BRANCHES_ONLY=true
            shift
            ;;
        --tags-only)
            TAGS_ONLY=true
            shift
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
done

# Validate required arguments
if [ -z "$SOURCE_URL" ] || [ -z "$DEST_URL" ]; then
    print_error "Both --from and --to options are required"
    usage
    exit 1
fi

# Validate URL formats
if ! validate_ssh_url "$SOURCE_URL"; then
    print_error "Invalid source URL format. Expected: git@host:user/repo.git"
    echo -e "${INDIGO}Example: ${AQUA}git@bitbucket.org:username/repository.git${NC}"
    exit 1
fi

if ! validate_ssh_url "$DEST_URL"; then
    print_error "Invalid destination URL format. Expected: git@host:user/repo.git"
    echo -e "${INDIGO}Example: ${AQUA}git@github.com:username/repository.git${NC}"
    exit 1
fi

# Validate mutually exclusive options
if [ "$BRANCHES_ONLY" = true ] && [ "$TAGS_ONLY" = true ]; then
    print_error "Cannot use --branches-only and --tags-only together"
    exit 1
fi

# Extract repository names
SOURCE_REPO_NAME=$(extract_repo_name "$SOURCE_URL")
DEST_REPO_NAME=$(extract_repo_name "$DEST_URL")

# Set default temp directory if not provided
if [ -z "$TEMP_DIR" ]; then
    TEMP_DIR="/tmp/migrate-${SOURCE_REPO_NAME}-$(date +%s)"
fi

# Print header
print_header "Migrate Repository"
echo -e "${INDIGO}Source:${NC}      ${AQUA}${SOURCE_URL}${NC}"
echo -e "${INDIGO}Destination:${NC} ${AQUA}${DEST_URL}${NC}"
echo -e "${INDIGO}Temp Directory:${NC} ${AQUA}${TEMP_DIR}${NC}"
echo

# Check access to both repositories
if ! check_repo_access "$SOURCE_URL" "source"; then
    exit 1
fi

echo
if ! check_repo_access "$DEST_URL" "destination"; then
    exit 1
fi

# Clone repository
if ! clone_repository "$SOURCE_URL" "$TEMP_DIR"; then
    cleanup
    exit 1
fi

# Push to destination
if ! push_to_destination "$TEMP_DIR" "$DEST_URL"; then
    cleanup
    exit 1
fi

# Update origin if requested
if [ "$UPDATE_ORIGIN" = true ]; then
    # If we're in a git repo, update it
    if [ -d ".git" ]; then
        update_origin "$DEST_URL"
    else
        print_warning "Not in a git repository. Cannot update origin."
        echo -e "${INDIGO}To update origin manually, run:${NC}"
        echo -e "${BROWN}  git remote set-url origin ${DEST_URL}${NC}"
    fi
fi

# Cleanup
cleanup

echo
print_success "Repository migration completed successfully!"
echo
echo -e "${INDIGO}Summary:${NC}"
echo -e "  ${AQUA}Source:${NC}      ${SOURCE_URL}"
echo -e "  ${AQUA}Destination:${NC} ${DEST_URL}"
if [ "$BRANCHES_ONLY" = true ]; then
    echo -e "  ${AQUA}Migrated:${NC}    Branches only"
elif [ "$TAGS_ONLY" = true ]; then
    echo -e "  ${AQUA}Migrated:${NC}    Tags only"
else
    echo -e "  ${AQUA}Migrated:${NC}    All branches and tags"
fi
echo
