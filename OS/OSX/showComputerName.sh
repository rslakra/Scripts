#!/bin/bash
# Author: Rohtash Lakra
# Display Computer Name
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Computer Name Information"
echo -e "${DARKBLUE}Host Name:${NC}"
sudo scutil --get HostName
echo
echo -e "${DARKBLUE}Local Host Name:${NC}"
sudo scutil --get LocalHostName
echo
echo -e "${DARKBLUE}Computer Name:${NC}"
sudo scutil --get ComputerName
echo
