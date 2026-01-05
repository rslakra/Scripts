#!/bin/bash
# Author: Rohtash Lakra
# Apache server management utility
# Usage:
#   ./apache.sh start                               # Start Apache server
#   ./apache.sh stop                                # Stop Apache server
#   ./apache.sh restart                             # Restart Apache server
#   ./apache.sh version                             # Show Apache version
#   ./apache.sh --grant-permission [folder_path]    # Set permissions (default: ~/Sites/dCMS)
#   ./apache.sh tail-access-log                     # Tail access log
#   ./apache.sh tail-error-log                      # Tail error log
#   ./apache.sh tail-logs                           # Tail both access and error logs
#   ./apache.sh test-config                         # Test Apache configuration
#   ./apache.sh --help                              # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default paths
SITES_PATH="${HOME}/Sites"
DCMS_PATH="${HOME}/Sites/dCMS"
ACCESS_LOG="/private/var/log/apache2/access_log"
ERROR_LOG="/private/var/log/apache2/error_log"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./apache.sh start${NC}                            # Start Apache server"
    echo -e "  ${AQUA}./apache.sh stop${NC}                             # Stop Apache server"
    echo -e "  ${AQUA}./apache.sh restart${NC}                          # Restart Apache server"
    echo -e "  ${AQUA}./apache.sh version${NC}                          # Show Apache version"
    echo -e "  ${AQUA}./apache.sh --grant-permission [folder_path]${NC} # Set permissions (default: ~/Sites/dCMS)"
    echo -e "  ${AQUA}./apache.sh tail-access-log${NC}                  # Tail access log"
    echo -e "  ${AQUA}./apache.sh tail-error-log${NC}                   # Tail error log"
    echo -e "  ${AQUA}./apache.sh tail-logs${NC}                        # Tail both access and error logs"
    echo -e "  ${AQUA}./apache.sh test-config${NC}                      # Test Apache configuration"
    echo -e "  ${AQUA}./apache.sh --help${NC}                           # Show this help"
    echo
}

# Function to set permissions
set_permissions() {
    local target_path="${1:-$DCMS_PATH}"
    
    print_header "Set Apache Permissions"
    echo -e "${INDIGO}Setting permissions for: ${AQUA}${target_path}${NC}"
    echo
    
    echo -e "${BROWN}sudo chmod -R a+w ${target_path}${NC}"
    sudo chmod -R a+w "$target_path"
    
    echo -e "${BROWN}sudo chown -R _www ${target_path}${NC}"
    sudo chown -R _www "$target_path"
    
    print_success "Permissions set successfully!"
    echo
}

# Function to start Apache
start_apache() {
    print_header "Start Apache Server"
    
    # Set permissions for all Sites
    echo -e "${INDIGO}Setting permissions for ${AQUA}${SITES_PATH}/*${NC}"
    echo -e "${BROWN}sudo chmod -R a+w ${SITES_PATH}/*${NC}"
    sudo chmod -R a+w ${SITES_PATH}/*
    
    echo -e "${BROWN}sudo chown -R _www ${SITES_PATH}/*${NC}"
    sudo chown -R _www ${SITES_PATH}/*
    echo
    
    # Start Apache
    echo -e "${INDIGO}Starting Apache server...${NC}"
    echo -e "${BROWN}sudo apachectl start${NC}"
    sudo apachectl start
    
    if [ $? -eq 0 ]; then
        print_success "Apache server started successfully!"
    else
        print_error "Failed to start Apache server"
        exit 1
    fi
    echo
}

# Function to stop Apache
stop_apache() {
    print_header "Stop Apache Server"
    
    echo -e "${INDIGO}Stopping Apache server...${NC}"
    echo -e "${BROWN}sudo apachectl stop${NC}"
    sudo apachectl stop
    
    if [ $? -eq 0 ]; then
        print_success "Apache server stopped successfully!"
    else
        print_error "Failed to stop Apache server"
        exit 1
    fi
    echo
}

# Function to restart Apache
restart_apache() {
    print_header "Restart Apache Server"
    
    # Set permissions for all Sites
    echo -e "${INDIGO}Setting permissions for ${AQUA}${SITES_PATH}/*${NC}"
    echo -e "${BROWN}sudo chmod -R a+w ${SITES_PATH}/*${NC}"
    sudo chmod -R a+w ${SITES_PATH}/*
    
    echo -e "${BROWN}sudo chown -R _www ${SITES_PATH}/*${NC}"
    sudo chown -R _www ${SITES_PATH}/*
    echo
    
    # Restart Apache
    echo -e "${INDIGO}Restarting Apache server...${NC}"
    echo -e "${BROWN}sudo apachectl restart${NC}"
    sudo apachectl restart
    
    if [ $? -eq 0 ]; then
        print_success "Apache server restarted successfully!"
    else
        print_error "Failed to restart Apache server"
        exit 1
    fi
    echo
}

# Function to show Apache version
show_version() {
    print_header "Apache Version"
    
    echo -e "${INDIGO}Apache version information:${NC}"
    echo -e "${BROWN}httpd -v${NC}"
    echo
    httpd -v
    echo
}

# Function to tail access log
tail_access_log() {
    print_header "Apache Access Log"
    
    if [ ! -f "$ACCESS_LOG" ]; then
        print_error "Access log file not found: ${ACCESS_LOG}"
        exit 1
    fi
    
    echo -e "${INDIGO}Tailing access log: ${AQUA}${ACCESS_LOG}${NC}"
    echo -e "${BROWN}tail -f ${ACCESS_LOG}${NC}"
    echo
    tail -f "$ACCESS_LOG"
}

# Function to tail error log
tail_error_log() {
    print_header "Apache Error Log"
    
    if [ ! -f "$ERROR_LOG" ]; then
        print_error "Error log file not found: ${ERROR_LOG}"
        exit 1
    fi
    
    echo -e "${INDIGO}Tailing error log: ${AQUA}${ERROR_LOG}${NC}"
    echo -e "${BROWN}tail -f ${ERROR_LOG}${NC}"
    echo
    tail -f "$ERROR_LOG"
}

# Function to tail both logs
tail_both_logs() {
    print_header "Apache Logs (Access & Error)"
    
    if [ ! -f "$ACCESS_LOG" ] || [ ! -f "$ERROR_LOG" ]; then
        print_error "One or more log files not found"
        [ ! -f "$ACCESS_LOG" ] && echo -e "${RED}  Missing: ${ACCESS_LOG}${NC}"
        [ ! -f "$ERROR_LOG" ] && echo -e "${RED}  Missing: ${ERROR_LOG}${NC}"
        exit 1
    fi
    
    echo -e "${INDIGO}Tailing both logs (Access: ${AQUA}${ACCESS_LOG}${INDIGO}, Error: ${AQUA}${ERROR_LOG}${INDIGO})${NC}"
    echo -e "${BROWN}tail -f ${ACCESS_LOG} ${ERROR_LOG}${NC}"
    echo
    tail -f "$ACCESS_LOG" "$ERROR_LOG"
}

# Function to test Apache configuration
test_config() {
    print_header "Apache Configuration Test"
    
    echo -e "${INDIGO}Testing Apache configuration...${NC}"
    echo -e "${BROWN}apachectl configtest${NC}"
    echo
    apachectl configtest
    
    if [ $? -eq 0 ]; then
        echo
        print_success "Apache configuration is valid!"
    else
        echo
        print_error "Apache configuration has errors"
        exit 1
    fi
    echo
}

# Parse arguments
if [ $# -eq 0 ]; then
    print_error "No action specified"
    usage
    exit 1
fi

case "$1" in
    start)
        start_apache
        ;;
    stop)
        stop_apache
        ;;
    restart)
        restart_apache
        ;;
    version)
        show_version
        ;;
    --grant-permission)
        # Use default path if not provided
        local folder_path="${2:-$DCMS_PATH}"
        set_permissions "$folder_path"
        ;;
    tail-access-log)
        tail_access_log
        ;;
    tail-error-log)
        tail_error_log
        ;;
    tail-logs)
        tail_both_logs
        ;;
    test-config)
        test_config
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        print_error "Unknown action: $1"
        usage
        exit 1
        ;;
esac
