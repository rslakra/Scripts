#!/bin/bash
#Author: Rohtash Lakra
# Tags the branch with given version and message.
# git tag -a v1.4 -m "my version 1.4"

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

version="$1"
message="$2"
#if [ -z "${version}" ] || [ -z "${message}" ]; then
if [ -z "${version}" ]; then
    echo
    echo -e "${DARKBLUE}Creates an annotated tag on the GIT branch.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo
    echo -e "\t${AQUA}~/tagBranch.sh <version> <message>${NC}"
    echo
    echo -e "\t${BROWN}<message> is optional${NC}"
    echo
    echo -e "${BROWN}Example:${NC}"
    echo
    echo -e "\t~/tagBranch.sh 1.0.0"
    echo
    echo -e "\t${BROWN}OR${NC}"
    echo
    echo -e "\t~/tagBranch.sh 1.0.0 \"v1.0.0 ready for production release.\""
    echo
    echo
    exit
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

