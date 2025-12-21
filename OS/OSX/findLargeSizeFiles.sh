#!/bin/bash
# Author: Rohtash Lakra
# Finds files larger than the specified size threshold recursively.
# Usage:
#   ./findLargeSizeFiles.sh                                    # Finds files larger than 100MB in current directory
#   OR
#   ./findLargeSizeFiles.sh <size>                             # Finds files larger than specified size
#                                                              # Supported formats: 1KB, 100MB, 1GB, 500M, 1k, 100M, etc.
#   OR
#   ./findLargeSizeFiles.sh <size> <directory>                 # Finds files larger than specified size in given directory

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
echo

# Function to normalize size format for find command
# find accepts: c (bytes), k (kilobytes), M (megabytes), G (gigabytes)
normalize_size() {
    local size="$1"
    # Convert to uppercase for easier matching
    size=$(echo "$size" | tr '[:lower:]' '[:upper:]')
    
    # Handle common formats and convert to find's format
    case "$size" in
        *KB|*K)
            # Remove KB or K, add k (find uses lowercase k for kilobytes)
            size=$(echo "$size" | sed 's/[KB]*$//')k
            ;;
        *MB|*M)
            # Remove MB, keep M (or just M)
            size=$(echo "$size" | sed 's/MB*$//')M
            ;;
        *GB|*G)
            # Remove GB, keep G (or just G)
            size=$(echo "$size" | sed 's/GB*$//')G
            ;;
        *B|*BYTES)
            # Convert bytes to 'c' (find uses 'c' for bytes)
            size=$(echo "$size" | sed 's/[BYTES]*$//')c
            ;;
        *)
            # If no unit specified, assume bytes (c)
            if [[ ! "$size" =~ [kMGc]$ ]]; then
                size="${size}c"
            fi
            ;;
    esac
    
    echo "$size"
}

# Default size threshold (100MB)
SIZE_INPUT=${1:-100M}
START_DIR=${2:-.}

# Normalize the size format
SIZE_THRESHOLD=$(normalize_size "$SIZE_INPUT")

print_header "Large File Finder"
echo -e "${AQUA}Size Threshold:${NC} ${SIZE_INPUT} (${SIZE_THRESHOLD})"
echo -e "${AQUA}Directory:${NC} ${START_DIR}"
echo ""
echo -e "${INDIGO}Finding files larger than ${SIZE_INPUT} (${SIZE_THRESHOLD}) in [${START_DIR}] ...${NC}"
echo

# Find files larger than threshold and display with human-readable sizes, sorted by size (largest first)
# Use find with -exec to get file info, then sort by size in reverse order
find "${START_DIR}" -type f -size +${SIZE_THRESHOLD} -exec ls -lh {} \; | \
    awk '{size=$5; $1=$2=$3=$4=$5=""; gsub(/^[ \t]+/, "", $0); print size, $0}' | \
    sort -h -k1 -r

echo
print_success "Done!"
echo

