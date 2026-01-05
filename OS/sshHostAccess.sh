#!/bin/bash
# Author: Rohtash Lakra
# SSH host access utility
# Usage:
#   ./sshHostAccess.sh                              # Connect to default host (logs.domain.com)
#   ./sshHostAccess.sh <host>                       # Connect to host as current user
#   ./sshHostAccess.sh <user>@<host>                # Connect to host as specified user
#   ./sshHostAccess.sh --host <host>                # Connect to specific host
#   ./sshHostAccess.sh --user <user> --host <host>  # Connect with user and host
#   ./sshHostAccess.sh --key <keyfile> --host <host> # Connect using specific key file
#   ./sshHostAccess.sh --port <port> --host <host>   # Connect to specific port
#   ./sshHostAccess.sh --help                       # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default values
DEFAULT_HOST="logs.domain.com"
DEFAULT_USER="rlakra"
SSH_HOST=""
SSH_USER=""
SSH_KEY=""
SSH_PORT=""
SSH_OPTIONS=""

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh${NC}                               # Connect to default host (${DEFAULT_USER}@${DEFAULT_HOST})"
    echo -e "  ${AQUA}./sshHostAccess.sh <host>${NC}                        # Connect to host as current user"
    echo -e "  ${AQUA}./sshHostAccess.sh <user>@<host>${NC}                 # Connect to host as specified user"
    echo -e "  ${AQUA}./sshHostAccess.sh --host <host>${NC}                 # Connect to specific host"
    echo -e "  ${AQUA}./sshHostAccess.sh --user <user> --host <host>${NC}   # Connect with user and host"
    echo -e "  ${AQUA}./sshHostAccess.sh --key <keyfile> --host <host>${NC} # Connect using specific key file"
    echo -e "  ${AQUA}./sshHostAccess.sh --port <port> --host <host>${NC}   # Connect to specific port"
    echo -e "  ${AQUA}./sshHostAccess.sh --help${NC}                        # Show this help"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh example.com${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh user@example.com${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh --host server.example.com${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh --user admin --host server.example.com${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh --key ~/.ssh/id_rsa --host server.example.com${NC}"
    echo -e "  ${AQUA}./sshHostAccess.sh --port 2222 --host server.example.com${NC}"
    echo
    echo -e "${INDIGO}SSH Key File Instructions:${NC}"
    echo -e "  - Place your SSH keys in ${AQUA}~/.ssh/${NC} directory"
    echo -e "  - Set proper permissions: ${BROWN}chmod 600 ~/.ssh/keyfile${NC}"
    echo -e "  - Public key: ${BROWN}chmod 644 ~/.ssh/keyfile.pub${NC}"
    echo
}

# Parse arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            SSH_HOST="$2"
            shift 2
            ;;
        --user)
            SSH_USER="$2"
            shift 2
            ;;
        --key)
            SSH_KEY="$2"
            shift 2
            ;;
        --port)
            SSH_PORT="$2"
            shift 2
            ;;
        --*)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            # Check if argument contains @ (user@host format)
            if [[ "$1" == *"@"* ]]; then
                SSH_USER="${1%%@*}"
                SSH_HOST="${1#*@}"
            else
                # Treat as host if not already set
                if [ -z "$SSH_HOST" ]; then
                    SSH_HOST="$1"
                else
                    print_error "Unexpected argument: $1"
                    usage
                    exit 1
                fi
            fi
            shift
            ;;
    esac
done

# Build SSH command array
build_ssh_command() {
    SSH_ARGS=("ssh")
    
    # Add key file if specified
    if [ -n "$SSH_KEY" ]; then
        # Expand ~ to home directory
        SSH_KEY="${SSH_KEY/#\~/$HOME}"
        
        # Check if key file exists
        if [ ! -f "$SSH_KEY" ]; then
            print_error "SSH key file not found: ${SSH_KEY}"
            echo
            echo -e "${INDIGO}Available SSH keys in ~/.ssh:${NC}"
            ls -1 ~/.ssh/*.pub 2>/dev/null | sed 's/\.pub$//' | xargs -n1 basename | sed 's/^/  - /' || echo -e "${BROWN}  (none found)${NC}"
            echo
            exit 1
        fi
        SSH_ARGS+=("-i" "$SSH_KEY")
    fi
    
    # Add port if specified
    if [ -n "$SSH_PORT" ]; then
        SSH_ARGS+=("-p" "$SSH_PORT")
    fi
    
    # Add user and host
    if [ -n "$SSH_USER" ] && [ -n "$SSH_HOST" ]; then
        SSH_ARGS+=("${SSH_USER}@${SSH_HOST}")
    elif [ -n "$SSH_HOST" ]; then
        SSH_ARGS+=("${SSH_HOST}")
    else
        # Default connection
        SSH_ARGS+=("${DEFAULT_USER}@${DEFAULT_HOST}")
    fi
}

# Execute SSH connection
print_header "SSH Host Access"
build_ssh_command

# Display the command
SSH_CMD_STR="${SSH_ARGS[*]}"
echo -e "${INDIGO}Connecting via SSH...${NC}"
echo -e "${BROWN}${SSH_CMD_STR}${NC}"
echo

# Execute the SSH command
"${SSH_ARGS[@]}"
