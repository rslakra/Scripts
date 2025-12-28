#!/bin/bash
# Author: Rohtash Lakra
# Mounts NFS directories
# Usage:
#   ./mountFolders.sh                    # Mounts default folders
#   OR
#   ./mountFolders.sh <source> <target>  # Mounts custom source to target

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default mount configurations
DEFAULT_MOUNT1_SOURCE="devfs1.rslakra.net:/vol/data_fs1"
DEFAULT_MOUNT1_TARGET="/data"
DEFAULT_MOUNT2_SOURCE="devis1.rslakra.net:/vol/data_is1"
DEFAULT_MOUNT2_TARGET="/data_temp"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./mountFolders.sh${NC}                            # Mounts default folders"
    echo -e "  ${AQUA}./mountFolders.sh <source> <target>${NC}          # Mounts custom source to target"
    echo
    echo -e "${INDIGO}Default mounts:${NC}"
    echo -e "  ${BROWN}1.${NC} ${DEFAULT_MOUNT1_SOURCE} ${GREEN}->${NC} ${DEFAULT_MOUNT1_TARGET}"
    echo -e "  ${BROWN}2.${NC} ${DEFAULT_MOUNT2_SOURCE} ${GREEN}->${NC} ${DEFAULT_MOUNT2_TARGET}"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./mountFolders.sh${NC}"
    echo -e "  ${AQUA}./mountFolders.sh server.example.com:/vol/share /mnt/share${NC}"
    echo
}

# Function to mount NFS directory
mount_nfs() {
    local source="$1"
    local target="$2"
    
    if [ -z "$source" ] || [ -z "$target" ]; then
        print_error "Source and target are required for mounting"
        return 1
    fi
    
    # Check if target directory exists, create if it doesn't
    if [ ! -d "$target" ]; then
        echo -e "${BROWN}Target directory '${target}' does not exist. Creating...${NC}"
        sudo mkdir -p "$target"
        if [ $? -ne 0 ]; then
            print_error "Failed to create target directory: $target"
            return 1
        fi
    fi
    
    # Check if already mounted
    if mountpoint -q "$target" 2>/dev/null; then
        print_warning "Directory '$target' is already mounted"
        return 0
    fi
    
    # Mount the NFS share
    echo -e "${INDIGO}Mounting ${AQUA}${source}${INDIGO} to ${AQUA}${target}${INDIGO}...${NC}"
    sudo mount -t nfs "$source" "$target"
    
    if [ $? -eq 0 ]; then
        print_success "Successfully mounted ${source} to ${target}"
    else
        print_error "Failed to mount ${source} to ${target}"
        return 1
    fi
}

print_header "NFS Mount Manager"

# Handle arguments
if [ $# -eq 0 ]; then
    # No arguments - mount default folders
    echo -e "${INDIGO}Mounting default folders...${NC}"
    echo
    
    mount_nfs "$DEFAULT_MOUNT1_SOURCE" "$DEFAULT_MOUNT1_TARGET"
    echo
    mount_nfs "$DEFAULT_MOUNT2_SOURCE" "$DEFAULT_MOUNT2_TARGET"
    echo
    
    print_completed "Default mounts completed!"
elif [ $# -eq 2 ]; then
    # Two arguments - mount custom source to target
    CUSTOM_SOURCE="$1"
    CUSTOM_TARGET="$2"
    
    echo -e "${INDIGO}Mounting custom folder...${NC}"
    echo
    mount_nfs "$CUSTOM_SOURCE" "$CUSTOM_TARGET"
    echo
    
    print_completed "Custom mount completed!"
else
    # Invalid number of arguments
    print_error "Invalid number of arguments"
    usage
    exit 1
fi
