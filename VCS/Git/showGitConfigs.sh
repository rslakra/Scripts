#!/bin/bash
# Author: Rohtash Lakra
# Display Git configuration (global, local, system, or all)
# Usage:
#   ./showGitConfigs.sh [--global|--local|--system|--all]
#   ./showGitConfigs.sh --get <key> [--global|--local|--system]
#   ./showGitConfigs.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Display Git configuration (global, local, system, or all).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./showGitConfigs.sh [options]${NC}"
    echo -e "  ${AQUA}./showGitConfigs.sh --get <key> [scope]${NC}"
    echo -e "  ${AQUA}./showGitConfigs.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}All Available Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}        Show this help message"
    echo -e "  ${INDIGO}--global${NC}          Show global configuration (default)"
    echo -e "  ${INDIGO}--local${NC}           Show local repository configuration"
    echo -e "  ${INDIGO}--system${NC}          Show system-wide configuration"
    echo -e "  ${INDIGO}--all${NC}             Show all configurations (global, local, system)"
    echo -e "  ${INDIGO}--get <key>${NC}       Get specific configuration value"
    echo
    echo -e "${BROWN}Description:${NC}"
    echo -e "  ${INDIGO}Displays Git configuration with origin information.${NC}"
    echo -e "  ${INDIGO}Global: Applies to all repositories for the current user${NC}"
    echo -e "  ${INDIGO}Local: Applies only to the current repository${NC}"
    echo -e "  ${INDIGO}System: Applies to all users on the system${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./showGitConfigs.sh${NC}                          # Show global configs (default)"
    echo -e "  ${AQUA}./showGitConfigs.sh --global${NC}                 # Show global repository configs"
    echo -e "  ${AQUA}./showGitConfigs.sh --local${NC}                  # Show local repository configs"
    echo -e "  ${AQUA}./showGitConfigs.sh --system${NC}                 # Show system-wide configs"
    echo -e "  ${AQUA}./showGitConfigs.sh --all${NC}                    # Show all configs (global, local, system)"
    echo -e "  ${AQUA}./showGitConfigs.sh --get user.email${NC}         # Get user.email value"
    echo -e "  ${AQUA}./showGitConfigs.sh --get user.name --global${NC} # Get global user.name"
    echo
}

# Initialize variables
SCOPE="global"
GET_KEY=""
SHOW_ALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --global)
            SCOPE="global"
            SHOW_ALL=false
            shift
            ;;
        --local)
            SCOPE="local"
            SHOW_ALL=false
            shift
            ;;
        --system)
            SCOPE="system"
            SHOW_ALL=false
            shift
            ;;
        --all)
            SHOW_ALL=true
            SCOPE=""
            shift
            ;;
        --get)
            if [ -z "$2" ]; then
                print_error "Configuration key required after --get"
                usage
                exit 1
            fi
            GET_KEY="$2"
            shift 2
            # Check if there's a scope option after the key
            if [ "$1" == "--global" ] || [ "$1" == "--local" ] || [ "$1" == "--system" ]; then
                SCOPE="$1"
                SCOPE="${SCOPE#--}"  # Remove -- prefix
                shift
            fi
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Handle --get option
if [ -n "$GET_KEY" ]; then
    if [ -z "$SCOPE" ]; then
        # Try to get from all scopes (local, global, system in order of precedence)
        print_header "Get Git Config Value"
        echo -e "${INDIGO}Getting value for: ${AQUA}${GET_KEY}${NC}"
        echo
        
        # Check local first
        local_value=$(git config --local "$GET_KEY" 2>/dev/null)
        if [ -n "$local_value" ]; then
            echo -e "${BROWN}Local:${NC} ${AQUA}${local_value}${NC}"
        fi
        
        # Check global
        global_value=$(git config --global "$GET_KEY" 2>/dev/null)
        if [ -n "$global_value" ]; then
            echo -e "${BROWN}Global:${NC} ${AQUA}${global_value}${NC}"
        fi
        
        # Check system
        system_value=$(git config --system "$GET_KEY" 2>/dev/null)
        if [ -n "$system_value" ]; then
            echo -e "${BROWN}System:${NC} ${AQUA}${system_value}${NC}"
        fi
        
        # Show effective value
        effective_value=$(git config "$GET_KEY" 2>/dev/null)
        if [ -n "$effective_value" ]; then
            echo
            echo -e "${GREEN}Effective value: ${AQUA}${effective_value}${NC}"
        else
            print_warning "Configuration key '${GET_KEY}' not found"
        fi
        echo
        exit 0
    else
        # Get from specific scope
        print_header "Get Git Config Value"
        echo -e "${INDIGO}Getting ${SCOPE} value for: ${AQUA}${GET_KEY}${NC}"
        echo
        
        value=$(git config --${SCOPE} "$GET_KEY" 2>/dev/null)
        if [ -n "$value" ]; then
            echo -e "${BROWN}${SCOPE^}:${NC} ${AQUA}${value}${NC}"
        else
            print_warning "Configuration key '${GET_KEY}' not found in ${SCOPE} scope"
        fi
        echo
        exit 0
    fi
fi

# Handle --all option
if [ "$SHOW_ALL" = true ]; then
    print_header "Git All Configurations"
    echo
    
    # Show system configs
    if git config --system --list > /dev/null 2>&1; then
        echo -e "${BLUEVIOLET}System Configuration:${NC}"
        echo -e "${BROWN}git config --system --list --show-origin${NC}"
        git config --system --list --show-origin 2>/dev/null | sed 's/^/  /'
        echo
    fi
    
    # Show global configs
    if git config --global --list > /dev/null 2>&1; then
        echo -e "${BLUEVIOLET}Global Configuration:${NC}"
        echo -e "${BROWN}git config --global --list --show-origin${NC}"
        git config --global --list --show-origin 2>/dev/null | sed 's/^/  /'
        echo
    fi
    
    # Show local configs (if in a git repo)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if git config --local --list > /dev/null 2>&1; then
            echo -e "${BLUEVIOLET}Local Configuration:${NC}"
            echo -e "${BROWN}git config --local --list --show-origin${NC}"
            git config --local --list --show-origin 2>/dev/null | sed 's/^/  /'
            echo
        fi
    else
        echo -e "${BROWN}Local Configuration:${NC} ${INDIGO}(Not in a git repository)${NC}"
        echo
    fi
    
    exit 0
fi

# Handle specific scope
case "$SCOPE" in
    global)
        print_header "Git Global Configuration"
        echo -e "${BROWN}git config --global --list --show-origin${NC}"
        git config --global --list --show-origin 2>/dev/null
        if [ $? -ne 0 ]; then
            print_warning "No global configuration found"
        fi
        echo
        ;;
    local)
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            print_error "Not a git repository. Cannot show local configuration."
            exit 1
        fi
        print_header "Git Local Configuration"
        echo -e "${BROWN}git config --local --list --show-origin${NC}"
        git config --local --list --show-origin 2>/dev/null
        if [ $? -ne 0 ]; then
            print_warning "No local configuration found"
        fi
        echo
        ;;
    system)
        print_header "Git System Configuration"
        echo -e "${BROWN}git config --system --list --show-origin${NC}"
        git config --system --list --show-origin 2>/dev/null
        if [ $? -ne 0 ]; then
            print_warning "No system configuration found or insufficient permissions"
        fi
        echo
        ;;
    *)
        # Default to global
        print_header "Git Global Configuration"
        echo -e "${BROWN}git config --global --list --show-origin${NC}"
        git config --global --list --show-origin 2>/dev/null
        if [ $? -ne 0 ]; then
            print_warning "No global configuration found"
        fi
        echo
        ;;
esac

