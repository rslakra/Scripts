#!/bin/bash
# Author: Rohtash Lakra
# Display Git commit log in various formats
# Usage:
#   ./logGitCommits.sh              # Short format with graph (default)
#   ./logGitCommits.sh --short      # Short format with graph
#   ./logGitCommits.sh --long       # Long format (oneline)
#   ./logGitCommits.sh --full       # Full format
#   ./logGitCommits.sh --stat       # With file statistics

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./logGitCommits.sh${NC}              # Short format with graph (default)"
    echo -e "  ${AQUA}./logGitCommits.sh --short${NC}     # Short format with graph"
    echo -e "  ${AQUA}./logGitCommits.sh --long${NC}      # Long format (oneline)"
    echo -e "  ${AQUA}./logGitCommits.sh --full${NC}      # Full format"
    echo -e "  ${AQUA}./logGitCommits.sh --stat${NC}      # With file statistics"
    echo
}

# Parse arguments
format="short"  # Default format

if [ $# -gt 0 ]; then
    case "$1" in
        --short)
            format="short"
            ;;
        --long)
            format="long"
            ;;
        --full)
            format="full"
            ;;
        --stat)
            format="stat"
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

print_header "Git Commit Log"

# Display log based on format
case "$format" in
    short)
        echo -e "${INDIGO}Displaying short format with graph...${NC}"
        echo -e "${BROWN}git log --pretty=format:\"%h %s\" --graph${NC}"
        echo
        git log --pretty=format:"%h %s" --graph
        ;;
    long)
        echo -e "${INDIGO}Displaying long format (oneline)...${NC}"
        echo -e "${BROWN}git log --pretty=oneline${NC}"
        echo
        git log --pretty=oneline
        ;;
    full)
        echo -e "${INDIGO}Displaying full format...${NC}"
        echo -e "${BROWN}git log --graph${NC}"
        echo
        git log --graph
        ;;
    stat)
        echo -e "${INDIGO}Displaying with file statistics...${NC}"
        echo -e "${BROWN}git log --stat --graph${NC}"
        echo
        git log --stat --graph
        ;;
esac

echo
print_success "Log display completed!"
echo
