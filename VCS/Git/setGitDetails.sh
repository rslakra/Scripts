#!/bin/bash
# Author: Rohtash Lakra
# Set Git user details (email/name) globally or locally, or generate contributors file
# Usage:
#   ./setGitDetails.sh [--global|--local] [--email <email>] [--name <name>]
#   ./setGitDetails.sh --contributors [output_file]
#   ./setGitDetails.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default values
DEFAULT_EMAIL="rohtash.singh@gmail.com"
DEFAULT_NAME="rslakra"
LOCAL_EMAIL="rslakra.work@gmail.com"
LOCAL_NAME="Rohtash Lakra"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Set Git user details (email/name) globally or locally, or generate contributors file.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./setGitDetails.sh [options]${NC}"
    echo -e "  ${AQUA}./setGitDetails.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}All Available Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}             Show this help message"
    echo -e "  ${INDIGO}--global${NC}               Set user details globally for all repositories (default)"
    echo -e "  ${INDIGO}--local${NC}                Set user details locally for current repository only"
    echo -e "  ${INDIGO}--email <email>${NC}        Custom email address (optional, used with --global or --local)"
    echo -e "  ${INDIGO}--name <name>${NC}          Custom name (optional, used with --global or --local)"
    echo -e "  ${INDIGO}--contributors [file]${NC}  Generate contributors file (default: contributors)"
    echo
    echo -e "${BROWN}Default Values:${NC}"
    echo -e "  ${INDIGO}Global:${NC}"
    echo -e "    ${INDIGO}  Email: ${AQUA}${DEFAULT_EMAIL}${NC}"
    echo -e "    ${INDIGO}  Name: ${AQUA}${DEFAULT_NAME}${NC}"
    echo -e "  ${INDIGO}Local:${NC}"
    echo -e "    ${INDIGO}  Email: ${AQUA}${LOCAL_EMAIL}${NC}"
    echo -e "    ${INDIGO}  Name: ${AQUA}${LOCAL_NAME}${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./setGitDetails.sh${NC}                       # Set global defaults"
    echo -e "  ${AQUA}./setGitDetails.sh --global${NC}              # Set global defaults (explicit)"
    echo -e "  ${AQUA}./setGitDetails.sh --local${NC}               # Set local defaults"
    echo -e "  ${AQUA}./setGitDetails.sh --global --email user@example.com --name \"John Doe\"${NC}"
    echo -e "  ${AQUA}./setGitDetails.sh --local --email work@example.com${NC}"
    echo -e "  ${AQUA}./setGitDetails.sh --contributors${NC}        # Generate contributors file"
    echo -e "  ${AQUA}./setGitDetails.sh --contributors CONTRIBUTORS.txt${NC}"
    echo
}

# Initialize variables
SCOPE="global"
EMAIL=""
NAME=""
GENERATE_CONTRIBUTORS=false
OUTPUT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --global)
            SCOPE="global"
            GENERATE_CONTRIBUTORS=false
            shift
            ;;
        --local)
            SCOPE="local"
            GENERATE_CONTRIBUTORS=false
            shift
            ;;
        --email)
            if [ -z "$2" ]; then
                print_error "Email address required after --email"
                usage
                exit 1
            fi
            EMAIL="$2"
            shift 2
            ;;
        --name)
            if [ -z "$2" ]; then
                print_error "Name required after --name"
                usage
                exit 1
            fi
            NAME="$2"
            shift 2
            ;;
        --contributors)
            GENERATE_CONTRIBUTORS=true
            SCOPE=""  # Clear scope when generating contributors
            # Check if next argument is a file name (not another option)
            if [ -n "$2" ] && [[ ! "$2" =~ ^-- ]]; then
                OUTPUT_FILE="$2"
                shift 2
            else
                shift
            fi
            ;;
        *)
            # If we're generating contributors and haven't set output file yet, treat as filename
            if [ "$GENERATE_CONTRIBUTORS" = true ] && [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
                shift
            else
                print_error "Unknown option: $1"
                usage
                exit 1
            fi
            ;;
    esac
done

# Handle contributors generation
if [ "$GENERATE_CONTRIBUTORS" = true ]; then
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository"
        exit 1
    fi
    
    # Determine output file
    OUTPUT_FILE="${OUTPUT_FILE:-contributors}"
    
    print_header "Generate Contributors File"
    echo -e "${INDIGO}Generating contributors list...${NC}"
    echo -e "${BROWN}git shortlog -s -n > ${OUTPUT_FILE}${NC}"
    git shortlog -s -n > "$OUTPUT_FILE"
    if [ $? -ne 0 ]; then
        print_error "Failed to generate contributors file"
        exit 1
    fi
    
    # Count contributors
    contributor_count=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
        print_success "Contributors file created successfully!"
        echo -e "${INDIGO}Output file: ${AQUA}${OUTPUT_FILE}${NC}"
        echo -e "${INDIGO}Contributors found: ${AQUA}${contributor_count}${NC}"
        echo
        echo -e "${BROWN}Preview (first 10 lines):${NC}"
        head -10 "$OUTPUT_FILE" | sed 's/^/  /'
        if [ "$contributor_count" -gt 10 ]; then
            echo -e "${BROWN}  ... and $((contributor_count - 10)) more${NC}"
        fi
        echo
    else
        print_warning "Contributors file created but appears to be empty"
        echo
    fi
    exit 0
fi

# Handle user details setting
# Set default scope if not specified
if [ -z "$SCOPE" ]; then
    SCOPE="global"
fi

# Set default values if not provided
if [ -z "$EMAIL" ]; then
    if [ "$SCOPE" == "global" ]; then
        EMAIL="$DEFAULT_EMAIL"
    else
        EMAIL="$LOCAL_EMAIL"
    fi
fi

if [ -z "$NAME" ]; then
    if [ "$SCOPE" == "global" ]; then
        NAME="$DEFAULT_NAME"
    else
        NAME="$LOCAL_NAME"
    fi
fi

# Validate Git repository for local scope
if [ "$SCOPE" == "local" ]; then
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository. Cannot set local configuration."
        exit 1
    fi
fi

# Determine scope label and git config flag
if [ "$SCOPE" == "global" ]; then
    SCOPE_LABEL="globally"
    CONFIG_FLAG="--global"
else
    SCOPE_LABEL="locally"
    CONFIG_FLAG="--local"
fi

print_header "Set Git User Details"
echo -e "${INDIGO}Setting git user email and name ${SCOPE_LABEL}...${NC}"
echo
echo -e "${BROWN}git config ${CONFIG_FLAG} user.email \"${EMAIL}\"${NC}"
git config $CONFIG_FLAG user.email "$EMAIL"
if [ $? -ne 0 ]; then
    print_error "Failed to set user email"
    exit 1
fi

echo -e "${BROWN}git config ${CONFIG_FLAG} user.name \"${NAME}\"${NC}"
git config $CONFIG_FLAG user.name "$NAME"
if [ $? -ne 0 ]; then
    print_error "Failed to set user name"
    exit 1
fi

echo
print_success "Git user details set successfully!"
echo -e "${INDIGO}Scope: ${AQUA}${SCOPE}${NC}"
echo -e "${INDIGO}Email: ${AQUA}${EMAIL}${NC}"
echo -e "${INDIGO}Name: ${AQUA}${NAME}${NC}"
echo
