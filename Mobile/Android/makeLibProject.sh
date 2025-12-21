#!/bin/bash
# Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Make Android Library Project"
SRC_DIR_PATH=AuthModule
SRC_PKG_NAME=com.rslakra.authmodule
MODULE_NAME=AuthModule
echo -e "${INDIGO}Creating library project: ${AQUA}${MODULE_NAME}${NC}"
$ANDROID_HOME/tools/android - create lib-project -n "${MODULE_NAME}" -t 1 -k "${SRC_PKG_NAME}" -p "${SRC_DIR_PATH}" -g -v 2.2.0
print_success "Library project created successfully!"
echo
