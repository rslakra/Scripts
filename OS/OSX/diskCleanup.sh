#!/bin/bash
# Author: Rohtash Lakra
# Removes build artifacts and cache files recursively, or a specified file/folder.
# Usage:
#   ./diskCleanup.sh                    # Removes default build artifacts
#   OR
#   ./diskCleanup.sh 'file or folder name'         # Removes specified file/folder recursively

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
echo
HOME_DIR=$PWD
echo

# Usage
usage() {
   echo
   echo -e "${DARKBLUE}Usage:${NC} ./diskCleanup.sh                    # Removes default build artifacts"
   echo -e "${BROWN}OR${NC}"
   echo -e "${DARKBLUE}Usage:${NC} ./diskCleanup.sh 'FileName'         # Removes specified file/folder recursively"
   echo
}

print_header "Build Artifacts Cleaner"

# files/folders to be removed
defaultCleanupEntries=".DS_Store .idea .mvn .pyc .pyo .svn .terraform .tmp .venv __pycache__ bower_components build dist node_modules target venv"
# check which files/folders to remove
if [[ -z "$1" ]]; then  # No Arguments Supplied
    echo -e "${INDIGO}Removing default build artifacts...${NC}"
    echo
    for entry in $defaultCleanupEntries; do
        echo -e "${BROWN}Removing '${entry}' recursively ...${NC}"
        echo
        # Remove both files and folders with the given name
        find . -name "${entry}" -print -exec rm -rf {} \;
        echo
    done
    print_success "Cleanup completed!"
elif [ -n "$1" ]; then
    echo -e "${INDIGO}Removing '${1}' recursively ...${NC}"
    echo
    # Remove both files and folders with the given name
    find . -name "$1" -print -exec rm -rf {} \;
    echo
    print_success "Cleanup completed!"
fi
echo
