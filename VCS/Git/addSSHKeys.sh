#!/bin/bash
#Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Add SSH Keys"
USER_NAME="${1}"
if [ "${USER_NAME}" == "rslakra" ]; then
  echo -e "${INDIGO}Adding SSH key: ${AQUA}~/.ssh/id_ed25519_rslakra${NC}"
  ssh-add ~/.ssh/id_ed25519_rslakra
else
  echo -e "${INDIGO}Adding SSH key: ${AQUA}~/.ssh/id_ed25519${NC}"
  ssh-add ~/.ssh/id_ed25519
fi
print_success "SSH keys added successfully!"
echo

