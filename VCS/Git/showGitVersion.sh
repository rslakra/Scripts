#!/bin/bash
# Author: Rohtash Lakra
# Display Git version information in various formats
# Usage:
#   ./showGitVersion.sh [options]
#   ./showGitVersion.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default version prefix
DEFAULT_VERSION_PREFIX="v2.0.5"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Display Git version information in various formats.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./showGitVersion.sh [options]${NC}"
    echo -e "  ${AQUA}./showGitVersion.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}All Available Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}              Show this help message"
    echo -e "  ${INDIGO}--full${NC}                  Show full version: prefix-commit-timestamp (default)"
    echo -e "  ${INDIGO}--short${NC}                 Show short version: prefix-commit"
    echo -e "  ${INDIGO}--commit${NC}                Show only commit hash"
    echo -e "  ${INDIGO}--commit-long${NC}           Show only full commit hash"
    echo -e "  ${INDIGO}--timestamp${NC}             Show only timestamp"
    echo -e "  ${INDIGO}--prefix <prefix>${NC}       Custom version prefix (default: ${DEFAULT_VERSION_PREFIX})"
    echo -e "  ${INDIGO}--no-prefix${NC}             Don't include version prefix"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}Generates version strings from Git commit information.${NC}"
    echo -e "  ${INDIGO}Default format: <prefix>-<short-commit-hash>-<timestamp>${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./showGitVersion.sh${NC}                          # Show full version (default)"
    echo -e "  ${AQUA}./showGitVersion.sh --full${NC}                   # Show full version"
    echo -e "  ${AQUA}./showGitVersion.sh --short${NC}                  # Show prefix-commit"
    echo -e "  ${AQUA}./showGitVersion.sh --commit${NC}                 # Show only commit hash"
    echo -e "  ${AQUA}./showGitVersion.sh --commit-long${NC}            # Show full commit hash"
    echo -e "  ${AQUA}./showGitVersion.sh --timestamp${NC}              # Show only timestamp"
    echo -e "  ${AQUA}./showGitVersion.sh --prefix v1.0.0${NC}          # Custom prefix"
    echo -e "  ${AQUA}./showGitVersion.sh --no-prefix --short${NC}      # Commit only"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

# Initialize variables
FORMAT="full"
VERSION_PREFIX="$DEFAULT_VERSION_PREFIX"
NO_PREFIX=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --full)
            FORMAT="full"
            shift
            ;;
        --short)
            FORMAT="short"
            shift
            ;;
        --commit)
            FORMAT="commit"
            shift
            ;;
        --commit-long)
            FORMAT="commit-long"
            shift
            ;;
        --timestamp)
            FORMAT="timestamp"
            shift
            ;;
        --prefix)
            if [ -z "$2" ]; then
                print_error "Version prefix required after --prefix"
                usage
                exit 1
            fi
            VERSION_PREFIX="$2"
            shift 2
            ;;
        --no-prefix)
            NO_PREFIX=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Get Git information
SHORT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null)
FULL_COMMIT=$(git rev-parse HEAD 2>/dev/null)
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Validate Git information
if [ -z "$SHORT_COMMIT" ] || [ -z "$FULL_COMMIT" ]; then
    print_error "Failed to get Git commit information"
    exit 1
fi

# Generate version string based on format
case "$FORMAT" in
    full)
        if [ "$NO_PREFIX" = true ]; then
            VERSION="${SHORT_COMMIT}-${TIMESTAMP}"
        else
            VERSION="${VERSION_PREFIX}-${SHORT_COMMIT}-${TIMESTAMP}"
        fi
        ;;
    short)
        if [ "$NO_PREFIX" = true ]; then
            VERSION="$SHORT_COMMIT"
        else
            VERSION="${VERSION_PREFIX}-${SHORT_COMMIT}"
        fi
        ;;
    commit)
        VERSION="$SHORT_COMMIT"
        ;;
    commit-long)
        VERSION="$FULL_COMMIT"
        ;;
    timestamp)
        VERSION="$TIMESTAMP"
        ;;
    *)
        VERSION="${VERSION_PREFIX}-${SHORT_COMMIT}-${TIMESTAMP}"
        ;;
esac

# Display version
echo "$VERSION"
