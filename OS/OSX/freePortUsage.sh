#!/bin/bash
# Author: Rohtash Lakra
# Free Port Usage
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Free Port Usage"
PORT=${1:-8080}
PORT=$((PORT))
echo -e "${INDIGO}Freeing ${AQUA}${PORT}${INDIGO} port usage${NC}"
#sudo lsof -i ticp:$PORT
sudo lsof -i -P | grep $PORT | awk '{ print $2 }' | sudo xargs kill -9
print_success "Port ${PORT} freed successfully!"
echo
