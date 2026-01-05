#!/bin/bash
# Author: Rohtash Lakra
# Port usage management utility
# Usage:
#   ./portUsage.sh --check <port>       # Check if port is in use
#   ./portUsage.sh --free <port>        # Free/kill processes using the port
#   ./portUsage.sh --details <port>     # Show detailed information about port usage
#   ./portUsage.sh --list [port]        # List all ports or specific port details
#   ./portUsage.sh --help               # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
# Note: Network is 1 level deep, so use .. instead of ../..
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default port
DEFAULT_PORT=8080

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./portUsage.sh --check <port>${NC}       # Check if port is in use"
    echo -e "  ${AQUA}./portUsage.sh --free <port>${NC}        # Free/kill processes using the port"
    echo -e "  ${AQUA}./portUsage.sh --details <port>${NC}     # Show detailed information about port usage"
    echo -e "  ${AQUA}./portUsage.sh --list [port]${NC}        # List all ports or specific port details"
    echo -e "  ${AQUA}./portUsage.sh --help${NC}               # Show this help"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./portUsage.sh --check 8080${NC}          # Check if port 8080 is in use"
    echo -e "  ${AQUA}./portUsage.sh --free 8080${NC}           # Free port 8080"
    echo -e "  ${AQUA}./portUsage.sh --details 8080${NC}        # Show detailed info about port 8080"
    echo -e "  ${AQUA}./portUsage.sh --list${NC}                # List all port usage"
    echo -e "  ${AQUA}./portUsage.sh --list 8080${NC}           # List details for port 8080"
    echo
}

# Function to check if port is in use
check_port() {
    local port="$1"
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        print_error "Invalid port number: ${port}. Port must be between 1 and 65535."
        exit 1
    fi
    
    print_header "Check Port Usage"
    echo -e "${INDIGO}Checking port: ${AQUA}${port}${NC}"
    echo
    
    # Check if port is in use
    local processes=$(sudo lsof -i -P | grep ":${port} " 2>/dev/null)
    
    if [ -z "$processes" ]; then
        print_success "Port ${port} is ${GREEN}FREE${NC} (not in use)"
        echo
        return 0
    else
        print_warning "Port ${port} is ${RED}IN USE${NC}"
        echo
        echo -e "${INDIGO}Process IDs using port ${port}:${NC}"
        echo -e "${BROWN}sudo lsof -i -P | grep :${port}${NC}"
        echo
        sudo lsof -i -P | grep ":${port} " | awk '{print $2}' | sort -u | while read pid; do
            if [ -n "$pid" ]; then
                local process_name=$(ps -p "$pid" -o comm= 2>/dev/null)
                echo -e "  ${AQUA}PID: ${pid}${NC} ${INDIGO}(${process_name})${NC}"
            fi
        done
        echo
        return 1
    fi
}

# Function to show detailed port information
show_port_details() {
    local port="$1"
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        print_error "Invalid port number: ${port}. Port must be between 1 and 65535."
        exit 1
    fi
    
    print_header "Port Details"
    echo -e "${INDIGO}Detailed information for port: ${AQUA}${port}${NC}"
    echo
    
    # Show detailed lsof output (check both TCP and UDP)
    echo -e "${BROWN}sudo lsof -i -P | grep :${port}${NC}"
    echo
    
    # Get full lsof output to preserve header format
    local full_output=$(sudo lsof -i -P 2>/dev/null)
    local header=$(echo "$full_output" | head -1)
    local details=$(echo "$full_output" | grep ":${port} ")
    
    if [ -z "$details" ]; then
        print_success "Port ${port} is ${GREEN}FREE${NC} (not in use)"
        echo
    else
        # Print header and matching lines
        echo "$header"
        echo "$details"
        echo
        echo -e "${INDIGO}Process Information:${NC}"
        echo "$details" | tail -n +2 | while read line; do
            if [ -n "$line" ]; then
                local pid=$(echo "$line" | awk '{print $2}')
                local command=$(echo "$line" | awk '{print $1}')
                local user=$(echo "$line" | awk '{print $3}')
                local name=$(ps -p "$pid" -o comm= 2>/dev/null)
                local full_path=$(ps -p "$pid" -o command= 2>/dev/null | cut -d' ' -f1)
                
                echo -e "  ${AQUA}Command:${NC} ${command}"
                echo -e "  ${AQUA}PID:${NC} ${pid}"
                echo -e "  ${AQUA}User:${NC} ${user}"
                echo -e "  ${AQUA}Process:${NC} ${name}"
                if [ -n "$full_path" ] && [ "$full_path" != "$name" ]; then
                    echo -e "  ${AQUA}Path:${NC} ${full_path}"
                fi
                echo
            fi
        done
    fi
}

# Function to free/kill processes using a port
free_port() {
    local port="$1"
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        print_error "Invalid port number: ${port}. Port must be between 1 and 65535."
        exit 1
    fi
    
    print_header "Free Port"
    echo -e "${INDIGO}Freeing port: ${AQUA}${port}${NC}"
    echo
    
    # Get process IDs using the port
    local pids=$(sudo lsof -i -P | grep ":${port} " | awk '{print $2}' | sort -u)
    
    if [ -z "$pids" ]; then
        print_success "Port ${port} is already free (no processes using it)"
        echo
        return 0
    fi
    
    echo -e "${INDIGO}Processes using port ${port}:${NC}"
    echo "$pids" | while read pid; do
        if [ -n "$pid" ]; then
            local process_name=$(ps -p "$pid" -o comm= 2>/dev/null)
            local command=$(ps -p "$pid" -o command= 2>/dev/null | cut -d' ' -f1-3)
            echo -e "  ${AQUA}PID: ${pid}${NC} ${INDIGO}(${process_name})${NC}"
            echo -e "    ${BROWN}Command: ${command}${NC}"
        fi
    done
    echo
    
    echo -e "${INDIGO}Killing processes...${NC}"
    echo -e "${BROWN}sudo lsof -i -P | grep :${port} | awk '{print \$2}' | sudo xargs kill -9${NC}"
    echo
    
    sudo lsof -i -P | grep ":${port} " | awk '{print $2}' | sudo xargs kill -9 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Verify port is now free
        sleep 1
        local remaining=$(sudo lsof -i -P | grep ":${port} " 2>/dev/null)
        if [ -z "$remaining" ]; then
            print_success "Port ${port} freed successfully!"
        else
            print_warning "Some processes may still be using port ${port}"
        fi
    else
        print_error "Failed to free port ${port}"
        exit 1
    fi
    echo
}

# Function to list port usage
list_ports() {
    local port="$1"
    
    print_header "Port Usage List"
    
    if [ -n "$port" ]; then
        if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
            print_error "Invalid port number: ${port}. Port must be between 1 and 65535."
            exit 1
        fi
        
        echo -e "${INDIGO}Port usage for: ${AQUA}${port}${NC}"
        echo
        echo -e "${BROWN}sudo lsof -i -P | grep :${port}${NC}"
        echo
        local port_info=$(sudo lsof -i -P 2>/dev/null | grep ":${port} ")
        if [ -z "$port_info" ]; then
            print_success "Port ${port} is free"
        else
            echo "$port_info"
        fi
    else
        echo -e "${INDIGO}All port usage:${NC}"
        echo
        echo -e "${BROWN}sudo lsof -i -P${NC}"
        echo
        sudo lsof -i -P 2>/dev/null | head -20
        echo
        echo -e "${INDIGO}(Showing first 20 entries. Use --list <port> for specific port details)${NC}"
    fi
    echo
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

case "$1" in
    --check)
        if [ -z "$2" ]; then
            print_error "Please provide a port number after --check"
            usage
            exit 1
        fi
        check_port "$2"
        ;;
    --free)
        if [ -z "$2" ]; then
            print_error "Please provide a port number after --free"
            usage
            exit 1
        fi
        free_port "$2"
        ;;
    --details)
        if [ -z "$2" ]; then
            print_error "Please provide a port number after --details"
            usage
            exit 1
        fi
        show_port_details "$2"
        ;;
    --list)
        list_ports "$2"
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        # Backward compatibility: if first argument is a number, treat as port check
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            print_header "Port Usage"
            echo -e "${INDIGO}Checking port: ${AQUA}$1${NC}"
            echo
            echo -e "${BROWN}sudo lsof -i -P | grep :$1${NC}"
            echo
            full_output=$(sudo lsof -i -P 2>/dev/null)
            header=$(echo "$full_output" | head -1)
            port_info=$(echo "$full_output" | grep ":${1} ")
            if [ -n "$port_info" ]; then
                echo "$header"
                echo "$port_info"
            else
                print_success "Port $1 is free"
            fi
            echo
        else
            print_error "Unknown option: $1"
            usage
            exit 1
        fi
        ;;
esac