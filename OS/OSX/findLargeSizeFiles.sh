#!/bin/bash
# Author: Rohtash Lakra
# Finds large files: by size threshold OR top N largest (by disk usage).
# Usage:
#   ./findLargeSizeFiles.sh [size] [directory]              # Files larger than size (default 100M, .)
#   ./findLargeSizeFiles.sh --top [N] [directory]            # Top N largest by du (default N=10, .)
#   ./findLargeSizeFiles.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Find large files by size threshold or show top N largest by disk usage.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh [size] [directory]${NC}       # Files larger than size (default: 100M, .)"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh --top [N] [directory]${NC}    # Top N largest by du (default: N=10, .)"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh --help${NC}                   # Show this help"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--help, -h${NC}           Show this help message"
    echo -e "  ${INDIGO}--top [N]${NC}            Show top N largest items (by du); default N=10. Excludes .git."
    echo
    echo -e "${BROWN}Size formats:${NC} 1K, 100M, 1G, 500M, 1k, 100MB, etc."
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh${NC}                      # Files >100M in current dir"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh 50M /path${NC}            # Files >50M in /path"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh --top${NC}                # Top 10 largest in current dir (excl. .git)"
    echo -e "  ${AQUA}./findLargeSizeFiles.sh --top 20 /path${NC}       # Top 20 largest in /path"
    echo
}

# Function to normalize size format for find command
normalize_size() {
    local size="$1"
    size=$(echo "$size" | tr '[:lower:]' '[:upper:]')
    case "$size" in
        *KB|*K) size=$(echo "$size" | sed 's/[KB]*$//')k ;;
        *MB|*M) size=$(echo "$size" | sed 's/MB*$//')M ;;
        *GB|*G) size=$(echo "$size" | sed 's/GB*$//')G ;;
        *B|*BYTES) size=$(echo "$size" | sed 's/[BYTES]*$//')c ;;
        *)
            if [[ ! "$size" =~ [kMGc]$ ]]; then
                size="${size}c"
            fi
            ;;
    esac
    echo "$size"
}

# Defaults
MODE="threshold"   # threshold | top
SIZE_INPUT="100M"
TOP_N=10
START_DIR="."
EXCLUDE_GIT_TOP=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        --top)
            MODE="top"
            if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
                TOP_N="$2"
                shift 2
            else
                shift
            fi
            # Next arg may be directory (if not starting with -)
            if [[ $# -gt 0 && "$1" != --* ]]; then
                START_DIR="$1"
                shift
            fi
            break
            ;;
        *)
            # Positional: size then optional directory (for threshold mode)
            if [ "$MODE" = "threshold" ]; then
                SIZE_INPUT="$1"
                shift
                if [[ $# -gt 0 && "$1" != --* ]]; then
                    START_DIR="$1"
                    shift
                fi
            fi
            break
            ;;
    esac
done

clear
echo

if [ "$MODE" = "top" ]; then
    print_header "Top ${TOP_N} Largest (by disk usage)"
    echo -e "${AQUA}Directory:${NC} ${START_DIR}"
    echo -e "${AQUA}Excluding:${NC} .git"
    echo
    echo -e "${INDIGO}Finding top ${TOP_N} largest in [${START_DIR}] ...${NC}"
    echo
    if [ "$EXCLUDE_GIT_TOP" = true ]; then
        du -ah -I ".git" "${START_DIR}" 2>/dev/null | sort -hr | head -n "$TOP_N"
    else
        du -ah "${START_DIR}" 2>/dev/null | sort -hr | head -n "$TOP_N"
    fi
else
    SIZE_THRESHOLD=$(normalize_size "$SIZE_INPUT")
    print_header "Large File Finder"
    echo -e "${AQUA}Size Threshold:${NC} ${SIZE_INPUT} (${SIZE_THRESHOLD})"
    echo -e "${AQUA}Directory:${NC} ${START_DIR}"
    echo
    echo -e "${INDIGO}Finding files larger than ${SIZE_INPUT} (${SIZE_THRESHOLD}) in [${START_DIR}] ...${NC}"
    echo
    find "${START_DIR}" -type f -size +${SIZE_THRESHOLD} -exec ls -lh {} \; 2>/dev/null | \
        awk '{size=$5; $1=$2=$3=$4=$5=""; gsub(/^[ \t]+/, "", $0); print size, $0}' | \
        sort -h -k1 -r
fi

echo
print_success "Done!"
echo
