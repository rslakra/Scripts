#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Set Git Author Locally"
echo -e "${INDIGO}Setting local git user email and name...${NC}"
git config --local user.email "rslakra.work@gmail.com"
git config --local user.name "Rohtash Lakra"
print_success "Git author set locally successfully!"
echo

