#!/bin/bash
#Author:Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Fix Email Privacy Restrictions"
echo -e "${INDIGO}Setting global email to privacy-protected address...${NC}"
git config --global user.email "rslakra@users.noreply.github.com"
git config --list --show-origin
echo -e "${INDIGO}Starting interactive rebase...${NC}"
git rebase -i
git commit --amend --reset-author
git rebase --continue
git push
print_success "Email privacy restrictions fixed!"
echo
