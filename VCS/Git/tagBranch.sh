#!/bin/bash
#Author: Rohtash Lakra
# Tags the branch with given version and message.
# git tag -a v1.4 -m "my version 1.4"

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Creates an annotated tag on the GIT branch.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./tagBranch.sh <version> [message]${NC}"
    echo -e "  ${AQUA}./tagBranch.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}<version>${NC}  - Version number (e.g., 1.0.0)"
    echo -e "  ${INDIGO}[message]${NC} - Optional tag message (default: \"v<version> ready for production release.\")"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./tagBranch.sh 1.0.0${NC}"
    echo -e "  ${AQUA}./tagBranch.sh 1.0.0 \"v1.0.0 ready for production release.\"${NC}"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

version="$1"
message="$2"

if [ -z "${version}" ]; then
    print_error "Version is required"
    usage
    exit 1
fi

if [ -z "${message}" ]; then
  message="v${version} ready for production release."
fi

print_header "Tag Branch"
echo -e "${INDIGO}git tag -a v${AQUA}${version}${INDIGO} -m \"${AQUA}${message}${INDIGO}\"${NC}"
git tag -a "v${version}" -m "${message}"
git push origin "v${version}"
print_success "Tag created and pushed successfully!"
echo

