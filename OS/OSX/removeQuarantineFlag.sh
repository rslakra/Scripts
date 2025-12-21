#!/bin/bash
# Author: Rohtash Lakra
# Removes Quarantine Flag of the file.
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Remove Quarantine Flag"
#Validate the parameter provided or not.
if [ -n "$1" ]; then
    echo -e "${INDIGO}Removing Quarantine Flag, if any, of ${AQUA}'$1'${INDIGO} ...${NC}"
    echo
    xattr -dr com.apple.quarantine $1
    print_success "Quarantine flag removed successfully!"
    echo
else
   print_error "Please, provide full path of either app name or root folder name of an application."
   echo
   echo -e "${DARKBLUE}Syntax:${NC}"
   echo -e "./removeQuarantineFlag.sh /Applications/AppName.app/"
   echo -e "${BROWN}OR${NC}"
   echo -e "./removeQuarantineFlag.sh /Applications/FolderName/"
   echo
fi
