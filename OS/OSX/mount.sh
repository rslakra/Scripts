#!/bin/bash
# Author: Rohtash Lakra
# Mount NFS, external disk, NTFS (init rw), or ADB remount.
# Usage:
#   ./mount.sh                                 # Mount default NFS (data)
#   ./mount.sh <source> <target>               # Mount custom NFS source to target
#   ./mount.sh --external-disk [device]        # Unmount, verify, repair, mount disk (default /dev/disk2s1)
#   ./mount.sh --ntfs [volume_path]            # Init NTFS volume for rw (add to /etc/fstab); optional path or pick from /Volumes
#   ./mount.sh --adb-remount                   # Remount Android system rw via ADB
#   ./mount.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default NFS mount configurations (data)
DEFAULT_MOUNT1_SOURCE="devfs1.rslakra.net:/vol/data_fs1"
DEFAULT_MOUNT1_TARGET="/data"
DEFAULT_MOUNT2_SOURCE="devis1.rslakra.net:/vol/data_is1"
DEFAULT_MOUNT2_TARGET="/data_temp"

# Default external disk device
DEFAULT_DISK_DEVICE="/dev/disk2s1"

usage() {
    echo
    echo -e "${DARKBLUE}Mount NFS, external disk, NTFS (init rw), or ADB remount.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./mount.sh${NC}                                   # Mount default NFS (data)"
    echo -e "  ${AQUA}./mount.sh <source> <target>${NC}                 # Mount custom NFS source to target"
    echo -e "  ${AQUA}./mount.sh --external-disk [device]${NC}          # Unmount, verify, repair, mount disk (default: ${DEFAULT_DISK_DEVICE})"
    echo -e "  ${AQUA}./mount.sh --ntfs [volume_path]${NC}              # Init NTFS volume for rw (add to /etc/fstab); requires sudo"
    echo -e "  ${AQUA}./mount.sh --adb-remount${NC}                     # Remount Android system rw (adb shell su -c ...)"
    echo -e "  ${AQUA}./mount.sh --help${NC}                            # Show this help"
    echo
    echo -e "${BROWN}Default NFS (data):${NC}"
    echo -e "  ${DEFAULT_MOUNT1_SOURCE} ${GREEN}->${NC} ${DEFAULT_MOUNT1_TARGET}"
    echo -e "  ${DEFAULT_MOUNT2_SOURCE} ${GREEN}->${NC} ${DEFAULT_MOUNT2_TARGET}"
    echo
}

# Mount NFS directory
mount_nfs() {
    local source="$1"
    local target="$2"

    if [ -z "$source" ] || [ -z "$target" ]; then
        print_error "Source and target are required for mounting"
        return 1
    fi

    if [ ! -d "$target" ]; then
        echo -e "${BROWN}Target directory '${target}' does not exist. Creating...${NC}"
        sudo mkdir -p "$target"
        if [ $? -ne 0 ]; then
            print_error "Failed to create target directory: $target"
            return 1
        fi
    fi

    if mountpoint -q "$target" 2>/dev/null; then
        print_warning "Directory '$target' is already mounted"
        return 0
    fi

    echo -e "${INDIGO}Mounting ${AQUA}${source}${INDIGO} to ${AQUA}${target}${INDIGO}...${NC}"
    sudo mount -t nfs "$source" "$target"

    if [ $? -eq 0 ]; then
        print_success "Successfully mounted ${source} to ${target}"
    else
        print_error "Failed to mount ${source} to ${target}"
        return 1
    fi
}

# External disk: unmount, verify, repair, mount
do_external_disk() {
    local dev="${1:-$DEFAULT_DISK_DEVICE}"
    print_header "External Disk"
    echo -e "${INDIGO}Device: ${AQUA}${dev}${NC}"
    echo
    echo -e "${BROWN}Unmounting...${NC}"
    sudo diskutil unmount "$dev"
    echo -e "${BROWN}Verifying...${NC}"
    sudo diskutil verifyVolume "$dev"
    echo -e "${BROWN}Repairing...${NC}"
    sudo diskutil repairVolume "$dev"
    echo -e "${BROWN}Mounting...${NC}"
    sudo diskutil mountDisk "$dev"
    if [ $? -eq 0 ]; then
        print_success "External disk completed!"
    else
        print_error "External disk operation failed"
        return 1
    fi
}

# NTFS: add volume to /etc/fstab for rw, then unmount/remount (requires sudo)
do_ntfs_init() {
    local volume_path="$1"
    if [ -z "$volume_path" ]; then
        echo -e "${INDIGO}Select an NTFS volume from /Volumes:${NC}"
        select volume_path in /Volumes/*; do
            [ -n "$volume_path" ] && break
            echo "Invalid choice."
        done
    fi
    [ -z "$volume_path" ] && exit 1
    if [ ! -d "$volume_path" ]; then
        print_error "Volume path not found: $volume_path"
        exit 1
    fi
    print_header "NTFS Init (Read-Write)"
    echo -e "${INDIGO}Volume: ${AQUA}${volume_path}${NC}"
    echo
    local uuid volume_name device_node filetype
    filetype=$(diskutil info "$volume_path" 2>/dev/null | grep "Type (Bundle):" | cut -d ':' -f2 | tr -d ' ')
    if [ "$filetype" != "ntfs" ]; then
        print_error "Not an NTFS volume: $volume_path (type: $filetype)"
        exit 1
    fi
    uuid=$(diskutil info "$volume_path" 2>/dev/null | grep "Volume UUID:" | cut -d ':' -f2 | tr -d ' ')
    volume_name=$(diskutil info "$volume_path" 2>/dev/null | grep "Volume Name:" | cut -d ':' -f2 | tr -d ' ')
    device_node=$(diskutil info "$volume_path" 2>/dev/null | grep "Device Node:" | cut -d ':' -f2 | tr -d ' ')
    local line
    if [ -n "$uuid" ]; then
        line="UUID=$uuid none ntfs rw,auto,nobrowse"
    else
        line="LABEL=$volume_name none ntfs rw,auto,nobrowse"
    fi
    if [ -f /etc/fstab ] && grep -qF "$line" /etc/fstab 2>/dev/null; then
        print_warning "Volume is already in /etc/fstab. No change."
        exit 0
    fi
    echo -e "${BROWN}Adding to /etc/fstab and remounting...${NC}"
    echo "# New NTFS: $volume_name on $(date)" | sudo tee -a /etc/fstab >/dev/null
    echo "$line" | sudo tee -a /etc/fstab >/dev/null
    sudo diskutil unmount "$volume_path"
    sudo diskutil mount "$device_node"
    if [ $? -eq 0 ]; then
        print_success "NTFS volume initialized for read-write!"
        echo -e "${INDIGO}Open from /Volumes (volume will not auto-open).${NC}"
    else
        print_error "Remount failed"
        exit 1
    fi
}

# ADB remount Android system rw
do_adb_remount() {
    print_header "ADB Remount"
    echo -e "${INDIGO}Remounting Android system partition rw...${NC}"
    adb shell "su -c 'mount -o rw,remount /system'"
    if [ $? -eq 0 ]; then
        print_success "ADB remount completed!"
    else
        print_warning "ADB remount may have failed (check device and su)"
    fi
}

print_header "Mount Manager"

# Parse options
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

if [ "$1" == "--external-disk" ]; then
    DEVICE="${2:-$DEFAULT_DISK_DEVICE}"
    do_external_disk "$DEVICE"
    echo
    exit 0
fi

if [ "$1" == "--ntfs" ]; then
    do_ntfs_init "$2"
    echo
    exit 0
fi

if [ "$1" == "--adb-remount" ]; then
    do_adb_remount
    echo
    exit 0
fi

# No args: default NFS (data)
if [ $# -eq 0 ]; then
    echo -e "${INDIGO}Mounting default folders...${NC}"
    echo
    mount_nfs "$DEFAULT_MOUNT1_SOURCE" "$DEFAULT_MOUNT1_TARGET"
    echo
    mount_nfs "$DEFAULT_MOUNT2_SOURCE" "$DEFAULT_MOUNT2_TARGET"
    echo
    print_completed "Default mounts completed!"
elif [ $# -eq 2 ]; then
    CUSTOM_SOURCE="$1"
    CUSTOM_TARGET="$2"
    echo -e "${INDIGO}Mounting custom folder...${NC}"
    echo
    mount_nfs "$CUSTOM_SOURCE" "$CUSTOM_TARGET"
    echo
    print_completed "Custom mount completed!"
else
    print_error "Invalid arguments"
    usage
    exit 1
fi
echo
