#!/bin/bash
# Author: Rohtash Lakra
# Display Port Usage
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Port Usage Checker"
PORT=${1:-8080}
PORT=$((PORT))
echo -e "${INDIGO}Checking ${AQUA}${PORT}${INDIGO} port usage${NC}"
#sudo lsof -i tcp:$PORT
sudo lsof -i -P | grep ${PORT} | awk '{ print $2 }'
echo
