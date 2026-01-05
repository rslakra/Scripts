#!/bin/bash
# Author: Rohtash Lakra
# Display IP address information for the host
# Usage:
#   ./ipAddress.sh              # Show all IPv4 addresses
#   ./ipAddress.sh --all        # Show all IP addresses (IPv4 and IPv6)
#   ./ipAddress.sh --ipv4       # Show only IPv4 addresses
#   ./ipAddress.sh --ipv6       # Show only IPv6 addresses
#   ./ipAddress.sh --external   # Show external/public IP address
#   ./ipAddress.sh --internal   # Show internal IP addresses only
#   ./ipAddress.sh --help       # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
# Note: Network is 1 level deep, so use .. instead of ../..
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./ipAddress.sh${NC}              # Show all IPv4 addresses"
    echo -e "  ${AQUA}./ipAddress.sh --all${NC}        # Show all IP addresses (IPv4 and IPv6)"
    echo -e "  ${AQUA}./ipAddress.sh --ipv4${NC}       # Show only IPv4 addresses"
    echo -e "  ${AQUA}./ipAddress.sh --ipv6${NC}       # Show only IPv6 addresses"
    echo -e "  ${AQUA}./ipAddress.sh --external${NC}   # Show external/public IP address"
    echo -e "  ${AQUA}./ipAddress.sh --internal${NC}   # Show internal IP addresses only"
    echo -e "  ${AQUA}./ipAddress.sh --help${NC}       # Show this help"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./ipAddress.sh${NC}              # Show IPv4 addresses"
    echo -e "  ${AQUA}./ipAddress.sh --all${NC}        # Show all IPs"
    echo -e "  ${AQUA}./ipAddress.sh --external${NC}   # Show public IP"
    echo
}

# Function to show IPv4 addresses
show_ipv4() {
    print_header "IPv4 Addresses"
    echo -e "${INDIGO}Network interfaces with IPv4 addresses:${NC}"
    echo
    
    local found=0
    local current_interface=""
    
    while IFS= read -r line; do
        # Check if this is an interface name line
        if echo "$line" | grep -qE "^[a-z0-9]+:"; then
            current_interface=$(echo "$line" | awk '{print $1}' | sed 's/:$//')
        # Check if this is an inet line
        elif echo "$line" | grep -q "inet "; then
            local ip=$(echo "$line" | awk '{print $2}')
            
            # Skip loopback
            if [ "$ip" != "127.0.0.1" ] && [ -n "$current_interface" ]; then
                echo -e "  ${AQUA}Interface:${NC} ${current_interface}"
                echo -e "  ${AQUA}IP Address:${NC} ${GREEN}${ip}${NC}"
                echo
                found=1
            fi
        fi
    done < <(ifconfig)
    
    if [ $found -eq 0 ]; then
        print_warning "No IPv4 addresses found (excluding loopback)"
    fi
    echo
}

# Function to show IPv6 addresses
show_ipv6() {
    print_header "IPv6 Addresses"
    echo -e "${INDIGO}Network interfaces with IPv6 addresses:${NC}"
    echo
    
    local found=0
    local current_interface=""
    
    while IFS= read -r line; do
        # Check if this is an interface name line
        if echo "$line" | grep -qE "^[a-z0-9]+:"; then
            current_interface=$(echo "$line" | awk '{print $1}' | sed 's/:$//')
        # Check if this is an inet6 line
        elif echo "$line" | grep -q "inet6 "; then
            local ip=$(echo "$line" | awk '{print $2}')
            
            # Skip loopback
            if ! echo "$ip" | grep -q "::1" && [ -n "$current_interface" ]; then
                echo -e "  ${AQUA}Interface:${NC} ${current_interface}"
                echo -e "  ${AQUA}IP Address:${NC} ${GREEN}${ip}${NC}"
                echo
                found=1
            fi
        fi
    done < <(ifconfig)
    
    if [ $found -eq 0 ]; then
        print_warning "No IPv6 addresses found (excluding loopback)"
    fi
    echo
}

# Function to show all IP addresses
show_all() {
    print_header "All IP Addresses"
    echo -e "${INDIGO}All network interfaces and their IP addresses:${NC}"
    echo
    
    show_ipv4
    show_ipv6
}

# Function to show external/public IP
show_external() {
    print_header "External IP Address"
    echo -e "${INDIGO}Retrieving public IP address...${NC}"
    echo
    
    # Try multiple services in case one is down
    local external_ip=""
    
    # Try ipify.org
    external_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    
    if [ -z "$external_ip" ]; then
        # Try icanhazip.com
        external_ip=$(curl -s --max-time 5 https://icanhazip.com 2>/dev/null)
    fi
    
    if [ -z "$external_ip" ]; then
        # Try ifconfig.me
        external_ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null)
    fi
    
    if [ -n "$external_ip" ]; then
        echo -e "  ${AQUA}Public IP Address:${NC} ${GREEN}${external_ip}${NC}"
        echo
        print_success "External IP retrieved successfully"
    else
        print_error "Failed to retrieve external IP address"
        echo -e "${INDIGO}Make sure you have internet connectivity.${NC}"
    fi
    echo
}

# Function to show internal IP addresses only
show_internal() {
    print_header "Internal IP Addresses"
    echo -e "${INDIGO}Internal/Private IP addresses (excluding loopback):${NC}"
    echo
    
    local found=0
    local current_interface=""
    
    while IFS= read -r line; do
        # Check if this is an interface name line
        if echo "$line" | grep -qE "^[a-z0-9]+:"; then
            current_interface=$(echo "$line" | awk '{print $1}' | sed 's/:$//')
        # Check if this is an inet line
        elif echo "$line" | grep -q "inet "; then
            local ip=$(echo "$line" | awk '{print $2}')
            
            # Skip loopback and check if it's a private IP
            if [ "$ip" != "127.0.0.1" ] && [ -n "$current_interface" ]; then
                # Check if it's a private IP (10.x.x.x, 172.16-31.x.x, 192.168.x.x)
                if echo "$ip" | grep -qE "^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.168\."; then
                    echo -e "  ${AQUA}Interface:${NC} ${current_interface}"
                    echo -e "  ${AQUA}IP Address:${NC} ${GREEN}${ip}${NC}"
                    echo
                    found=1
                fi
            fi
        fi
    done < <(ifconfig)
    
    if [ $found -eq 0 ]; then
        print_warning "No internal/private IP addresses found"
    fi
    echo
}

# Parse arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
elif [ "$1" == "--all" ]; then
    show_all
elif [ "$1" == "--ipv4" ]; then
    show_ipv4
elif [ "$1" == "--ipv6" ]; then
    show_ipv6
elif [ "$1" == "--external" ]; then
    show_external
elif [ "$1" == "--internal" ]; then
    show_internal
elif [ $# -eq 0 ]; then
    # Default: show IPv4 addresses
    show_ipv4
else
    print_error "Unknown option: $1"
    usage
    exit 1
fi
