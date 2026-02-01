#!/bin/bash
# Author: Rohtash Lakra
# Removes build artifacts, cache files, and optionally a specified file/folder recursively.
# Usage:
#   ./diskCleanup.sh                              # Removes default build artifacts + ._* files
#   ./diskCleanup.sh <name> [--files-only|--dirs-only]  # Removes specified file/folder by name
#   ./diskCleanup.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
echo
HOME_DIR=$PWD
echo

# Usage
usage() {
   echo
   echo -e "${DARKBLUE}Removes build artifacts and cache files recursively.${NC}"
   echo
   echo -e "${DARKBLUE}Usage:${NC}"
   echo -e "  ${AQUA}./diskCleanup.sh${NC}                                  # Removes default build artifacts + ._* files"
   echo -e "  ${AQUA}./diskCleanup.sh <file_or_folder>${NC}                 # Removes specified name (files and dirs)"
   echo -e "  ${AQUA}./diskCleanup.sh <name> --files-only${NC}              # Removes only files matching name"
   echo -e "  ${AQUA}./diskCleanup.sh <name> --dirs-only${NC}               # Removes only folders matching name"
   echo -e "  ${AQUA}./diskCleanup.sh --help${NC}                           # Show this help"
   echo
   echo -e "${BROWN}Default artifacts removed:${NC}"
   echo -e "  ${INDIGO}.DS_Store, ._* (dot-underscore/resource fork files), .idea, .mvn, .pyc, .pyo${NC}"
   echo -e "  ${INDIGO}.svn, .terraform, .tmp, .venv, __pycache__ (excluding inside venv), bower_components${NC}"
   echo -e "  ${INDIGO}build, dist, node_modules, target, venv${NC}"
   echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Default files/folders to remove (no ._* here; handled separately)
defaultCleanupEntries=".DS_Store .idea .mvn .pyc .pyo .svn .terraform .tmp .venv __pycache__ bower_components build dist node_modules target venv"

# Parse optional --files-only / --dirs-only when used with a name
TYPE_FILTER=""   # "" = both, "f" = files only, "d" = dirs only
CUSTOM_NAME=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --files-only)
            TYPE_FILTER="f"
            shift
            ;;
        --dirs-only)
            TYPE_FILTER="d"
            shift
            ;;
        *)
            CUSTOM_NAME="$1"
            shift
            break
            ;;
    esac
done

print_header "Build Artifacts Cleaner"

if [[ -z "$CUSTOM_NAME" ]]; then
    # No name: default cleanup
    echo -e "${INDIGO}Removing default build artifacts...${NC}"
    echo

    for entry in $defaultCleanupEntries; do
        echo -e "${BROWN}Removing '${entry}' recursively ...${NC}"
        echo
        if [[ "$entry" == "__pycache__" ]]; then
            # Exclude __pycache__ inside venv (match delRecursively behavior)
            find . -type d -name "${entry}" ! -path "*venv*" -print -exec rm -rf {} \;
        else
            find . -name "${entry}" -print -exec rm -rf {} \;
        fi
        echo
    done

    # Dot-underscore / resource fork files (match deleteDotUnderscoreFilesRecursively)
    echo -e "${BROWN}Removing '._*' (resource fork) files recursively ...${NC}"
    echo
    find . -type f -name "._*" -print -exec rm -rf {} \;
    echo

    print_success "Cleanup completed!"
else
    # One name provided
    echo -e "${INDIGO}Removing '${CUSTOM_NAME}' recursively ...${NC}"
    echo
    if [[ "$TYPE_FILTER" == "f" ]]; then
        find . -type f -name "$CUSTOM_NAME" -print -exec rm -rf {} \;
    elif [[ "$TYPE_FILTER" == "d" ]]; then
        find . -type d -name "$CUSTOM_NAME" -print -exec rm -rf {} \;
    else
        find . -name "$CUSTOM_NAME" -print -exec rm -rf {} \;
    fi
    echo
    print_success "Cleanup completed!"
fi
echo
