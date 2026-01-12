#!/bin/bash
# Author: Rohtash Lakra
# Create a new SVN repository with various options
# Usage:
#   ./makeRepository.sh [options] [repository_name]
#   ./makeRepository.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default values
DEFAULT_REPO_NAME="SVNRepo"
DEFAULT_FS_TYPE="fsfs"
DEFAULT_PATH="."

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Create a new SVN repository with various options.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./makeRepository.sh [options] [repository_name]${NC}"
    echo -e "  ${AQUA}./makeRepository.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}All Available Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}         Show this help message"
    echo -e "  ${INDIGO}--name <name>${NC}      Repository name (default: ${DEFAULT_REPO_NAME})"
    echo -e "  ${INDIGO}--path <path>${NC}      Path where to create repository (default: current directory)"
    echo -e "  ${INDIGO}--fs-type <type>${NC}   Filesystem type: fsfs or bdb (default: fsfs)"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}Creates a new Subversion (SVN) repository.${NC}"
    echo -e "  ${INDIGO}fsfs (default): Modern, recommended filesystem backend${NC}"
    echo -e "  ${INDIGO}bdb: Berkeley DB backend (deprecated, not recommended)${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./makeRepository.sh${NC}                              # Create 'SVNRepo' in current directory"
    echo -e "  ${AQUA}./makeRepository.sh myrepo${NC}                       # Create 'myrepo' in current directory"
    echo -e "  ${AQUA}./makeRepository.sh --name myrepo --path /svn${NC}    # Create in /svn directory"
    echo -e "  ${AQUA}./makeRepository.sh --name myrepo --fs-type fsfs${NC} # Explicitly set fsfs"
    echo
}

# Initialize variables
REPO_NAME=""
REPO_PATH=""
FS_TYPE="$DEFAULT_FS_TYPE"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --name)
            if [ -z "$2" ]; then
                print_error "Repository name required after --name"
                usage
                exit 1
            fi
            REPO_NAME="$2"
            shift 2
            ;;
        --path)
            if [ -z "$2" ]; then
                print_error "Path required after --path"
                usage
                exit 1
            fi
            REPO_PATH="$2"
            shift 2
            ;;
        --fs-type)
            if [ -z "$2" ]; then
                print_error "Filesystem type required after --fs-type"
                usage
                exit 1
            fi
            if [ "$2" != "fsfs" ] && [ "$2" != "bdb" ]; then
                print_error "Invalid filesystem type: $2. Must be 'fsfs' or 'bdb'"
                usage
                exit 1
            fi
            FS_TYPE="$2"
            shift 2
            ;;
        *)
            # Treat as repository name if not an option
            if [ -z "$REPO_NAME" ]; then
                REPO_NAME="$1"
            else
                print_error "Unknown option or duplicate repository name: $1"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Set defaults if not provided
if [ -z "$REPO_NAME" ]; then
    REPO_NAME="$DEFAULT_REPO_NAME"
fi

if [ -z "$REPO_PATH" ]; then
    REPO_PATH="$DEFAULT_PATH"
fi

# Validate path
if [ ! -d "$REPO_PATH" ]; then
    print_error "Path does not exist: ${REPO_PATH}"
    echo -e "${INDIGO}Creating directory: ${AQUA}${REPO_PATH}${NC}"
    mkdir -p "$REPO_PATH"
    if [ $? -ne 0 ]; then
        print_error "Failed to create directory: ${REPO_PATH}"
        exit 1
    fi
fi

# Get absolute path
REPO_PATH=$(cd "$REPO_PATH" && pwd)
FULL_REPO_PATH="${REPO_PATH}/${REPO_NAME}"

# Check if repository already exists
if [ -d "$FULL_REPO_PATH" ]; then
    print_error "Repository already exists: ${FULL_REPO_PATH}"
    exit 1
fi

# Check if svnadmin is available
if ! command -v svnadmin &> /dev/null; then
    print_error "svnadmin command not found. Please install Subversion."
    exit 1
fi

print_header "Create SVN Repository"
echo -e "${INDIGO}Repository name: ${AQUA}${REPO_NAME}${NC}"
echo -e "${INDIGO}Repository path: ${AQUA}${FULL_REPO_PATH}${NC}"
echo -e "${INDIGO}Filesystem type: ${AQUA}${FS_TYPE}${NC}"
echo

# Create the repository
echo -e "${BROWN}svnadmin create --fs-type ${FS_TYPE} ${FULL_REPO_PATH}${NC}"
svnadmin create --fs-type "$FS_TYPE" "$FULL_REPO_PATH"

if [ $? -ne 0 ]; then
    print_error "Failed to create SVN repository"
    exit 1
fi

# Verify repository was created
if [ -d "$FULL_REPO_PATH" ] && [ -f "${FULL_REPO_PATH}/format" ]; then
    print_success "SVN repository created successfully!"
    echo
    echo -e "${INDIGO}Repository location: ${AQUA}${FULL_REPO_PATH}${NC}"
    echo -e "${INDIGO}Repository format: ${AQUA}$(cat "${FULL_REPO_PATH}/format" 2>/dev/null || echo "unknown")${NC}"
    echo
    echo -e "${BROWN}Next steps:${NC}"
    echo -e "  ${INDIGO}1. Set up repository structure: ${AQUA}svn mkdir file://${FULL_REPO_PATH}/trunk -m 'Create trunk'${NC}"
    echo -e "  ${INDIGO}2. Checkout repository: ${AQUA}svn checkout file://${FULL_REPO_PATH}${NC}"
    echo
else
    print_error "Repository creation may have failed - verification failed"
    exit 1
fi

