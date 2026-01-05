#!/bin/bash
# Author: Rohtash Lakra
# Add SSH keys to the SSH agent
# Usage:
#   ./addSSHKeys.sh                     # Add default SSH key based on username
#   ./addSSHKeys.sh <username>          # Add SSH key for specific username
#   ./addSSHKeys.sh --ssh-key <key>     # Add specific SSH key from ~/.ssh
#   ./addSSHKeys.sh --help              # Show this help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./addSSHKeys.sh${NC}                    # Add default SSH key based on username"
    echo -e "  ${AQUA}./addSSHKeys.sh <username>${NC}         # Add SSH key for specific username"
    echo -e "  ${AQUA}./addSSHKeys.sh --ssh-key <key>${NC}    # Add specific SSH key from ~/.ssh"
    echo -e "  ${AQUA}./addSSHKeys.sh --help${NC}             # Show this help"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./addSSHKeys.sh${NC}"
    echo -e "  ${AQUA}./addSSHKeys.sh rslakra${NC}"
    echo -e "  ${AQUA}./addSSHKeys.sh --ssh-key id_ed25519_work${NC}"
    echo -e "  ${AQUA}./addSSHKeys.sh --ssh-key id_rsa${NC}"
    echo
}

# Function to add SSH key
add_ssh_key() {
    local key_path="$1"
    local key_name=$(basename "$key_path")
    
    # Check if key file exists
    if [ ! -f "$key_path" ]; then
        print_error "SSH key file not found: ${key_path}"
        echo
        echo -e "${INDIGO}Available SSH keys in ~/.ssh:${NC}"
        ls -1 ~/.ssh/*.pub 2>/dev/null | sed 's/\.pub$//' | xargs -n1 basename | sed 's/^/  - /' || echo -e "${BROWN}  (none found)${NC}"
        echo
        return 1
    fi
    
    echo -e "${INDIGO}Adding SSH key: ${AQUA}${key_path}${NC}"
    ssh-add "$key_path"
    
    if [ $? -eq 0 ]; then
        print_success "SSH key '${key_name}' added successfully!"
        echo
        return 0
    else
        print_error "Failed to add SSH key '${key_name}'"
        echo
        return 1
    fi
}

# Parse arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
elif [ "$1" == "--ssh-key" ]; then
    if [ -z "$2" ]; then
        print_error "Please provide an SSH key name after --ssh-key"
        usage
        exit 1
    fi
    
    print_header "Add SSH Keys"
    SSH_KEY_NAME="$2"
    SSH_KEY_PATH="${HOME}/.ssh/${SSH_KEY_NAME}"
    
    # Remove .pub extension if provided
    SSH_KEY_NAME="${SSH_KEY_NAME%.pub}"
    SSH_KEY_PATH="${HOME}/.ssh/${SSH_KEY_NAME}"
    
    add_ssh_key "$SSH_KEY_PATH"
    echo
elif [ $# -gt 0 ] && [ -n "$1" ]; then    
    add_ssh_key "${HOME}/.ssh/id_ed25519_${1}_bitbucket"
else
    # Default behavior: use username from parameter or default key
    # No parameter, use default key
    add_ssh_key "${HOME}/.ssh/id_ed25519"
fi
