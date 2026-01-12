#!/bin/bash
# Author: Rohtash Lakra
# Fix GitHub email privacy restrictions by updating commit author emails
# Usage:
#   ./fixEmailPrivacyRestrictions.sh
#   ./fixEmailPrivacyRestrictions.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Fix GitHub email privacy restrictions by updating commit author emails.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./fixEmailPrivacyRestrictions.sh${NC}"
    echo -e "  ${AQUA}./fixEmailPrivacyRestrictions.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}This script fixes the 'push declined due to email privacy restrictions' error${NC}"
    echo -e "  ${INDIGO}by updating commit author emails to use GitHub's privacy-protected address.${NC}"
    echo
    echo -e "${BROWN}What Causes This Error:${NC}"
    echo -e "  ${INDIGO}1. GitHub email privacy is enabled in your account settings${NC}"
    echo -e "  ${INDIGO}2. Commits have author emails that don't match:${NC}"
    echo -e "     ${INDIGO}- Your verified GitHub email addresses, OR${NC}"
    echo -e "     ${INDIGO}- Your privacy-protected noreply email (username@users.noreply.github.com)${NC}"
    echo
    echo -e "${BROWN}Note:${NC}"
    echo -e "  ${INDIGO}This script will:${NC}"
    echo -e "  ${INDIGO}  1. Set global email to privacy-protected address${NC}"
    echo -e "  ${INDIGO}  2. Show commits with their author emails${NC}"
    echo -e "  ${INDIGO}  3. Start interactive rebase to amend commits${NC}"
    echo -e "  ${INDIGO}  4. Reset author on each commit${NC}"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

print_header "Fix Email Privacy Restrictions"
echo -e "${INDIGO}This error occurs when commits have author emails that don't match${NC}"
echo -e "${INDIGO}your GitHub verified emails or privacy-protected noreply address.${NC}"
echo

# Show current commits with their author emails
echo -e "${BROWN}Checking commits with their author emails...${NC}"
echo -e "${INDIGO}Commits and their author emails:${NC}"
echo
git log --pretty=format:"%h - %an <%ae> - %s" -10
echo

# Set global email to privacy-protected address
echo -e "${INDIGO}Setting global email to privacy-protected address...${NC}"
echo -e "${BROWN}git config --global user.email \"rslakra@users.noreply.github.com\"${NC}"
git config --global user.email "rslakra@users.noreply.github.com"
if [ $? -ne 0 ]; then
    print_error "Failed to set global email"
    exit 1
fi

echo
echo -e "${INDIGO}Current Git configuration:${NC}"
echo -e "${BROWN}git config --list --show-origin${NC}"
git config --list --show-origin | grep user.email
echo

# Check if there are unpushed commits
if git rev-parse --verify origin/HEAD > /dev/null 2>&1; then
    UNPUSHED=$(git rev-list origin/HEAD..HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNPUSHED" -gt 0 ]; then
        echo -e "${INDIGO}Found ${AQUA}${UNPUSHED}${INDIGO} unpushed commit(s)${NC}"
        echo -e "${BROWN}Unpushed commits with author emails:${NC}"
        git log origin/HEAD..HEAD --pretty=format:"  %h - %an <%ae> - %s"
        echo
    fi
fi

echo -e "${INDIGO}To fix commits, you need to:${NC}"
echo -e "  ${INDIGO}1. Start interactive rebase: ${AQUA}git rebase -i HEAD~${UNPUSHED:-10}${NC}"
echo -e "  ${INDIGO}2. Mark commits as 'edit' or 'e'${NC}"
echo -e "  ${INDIGO}3. For each commit, run: ${AQUA}git commit --amend --reset-author --no-edit${NC}"
echo -e "  ${INDIGO}4. Continue rebase: ${AQUA}git rebase --continue${NC}"
echo -e "  ${INDIGO}5. Push: ${AQUA}git push${NC}"
echo
echo -e "${BROWN}Or use the automated fix:${NC}"
read -p "Do you want to start interactive rebase now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo -e "${INDIGO}Starting interactive rebase...${NC}"
    echo -e "${BROWN}Mark commits as 'edit' or 'e', then for each commit run:${NC}"
    echo -e "${BROWN}  git commit --amend --reset-author --no-edit${NC}"
    echo -e "${BROWN}  git rebase --continue${NC}"
    echo
    git rebase -i HEAD~${UNPUSHED:-10}
    print_success "Interactive rebase completed. Review changes and push when ready."
else
    print_warning "Skipped interactive rebase. Run it manually when ready."
fi
echo
