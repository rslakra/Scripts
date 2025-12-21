#!/bin/bash
#Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Uninstall Oracle JDK"
echo -e "${INDIGO}Removing Oracle JDK components...${NC}"
sudo rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin
sudo rm -rf /Library/PreferencePanes/JavaControlPanel.prefPane
sudo rm -rf ~/Library/Application\ Support/Oracle/Java
sudo rm -rf jdk1.8.0_261.jdk
print_success "Oracle JDK uninstalled successfully!"
echo
