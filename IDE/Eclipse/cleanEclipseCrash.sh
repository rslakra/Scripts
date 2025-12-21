#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Clean Eclipse Crash"
export ECLIPSE_METADATA=${WORKSPACE_HOME}/.metadata
echo -e "${INDIGO}Removing ${AQUA}${ECLIPSE_METADATA}/.lock${NC}"
rm -rf ${ECLIPSE_METADATA}/.lock
ls -la ${ECLIPSE_METADATA}/.lock
echo
echo -e "${INDIGO}Removing ${AQUA}${ECLIPSE_METADATA}/.plugins/org.eclipse.core.resources/.snap${NC}"
rm -rf ${ECLIPSE_METADATAE}/.plugins/org.eclipse.core.resources/.snap
ls -la ${ECLIPSE_METADATAE}/.plugins/org.eclipse.core.resources/.snap
print_success "Eclipse crash files cleaned!"
echo 
