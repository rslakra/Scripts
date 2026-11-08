#!/bin/bash
# Author: Rohtash Lakra
# Shows disk space usage: overall summary, and the largest folders/files in a chosen order.
# Usage:
#   ./diskUsage.sh [options] [directory]
#   ./diskUsage.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Show disk space usage and the largest folders/files, sorted by size.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./diskUsage.sh [options] [directory]${NC}"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}-s, --summary${NC}          Show overall disk usage (df -h) only"
    echo -e "  ${INDIGO}-m, --mode MODE${NC}        What to list: dirs | files | all (default: dirs)"
    echo -e "  ${INDIGO}-d, --depth N${NC}          Folder depth for dirs/all modes (default: 1 for dirs, unlimited for all)"
    echo -e "  ${INDIGO}-n, --top N${NC}            Show only the N largest items (default: 10, 0 = no limit)"
    echo -e "  ${INDIGO}-o, --order ORDER${NC}      Sort order: desc | asc (default: desc)"
    echo -e "  ${INDIGO}-x, --exclude NAME${NC}     Exclude a file/folder name or pattern (repeatable), e.g. .git"
    echo -e "  ${INDIGO}-S, --sudo${NC}             Run with sudo (to read protected folders, e.g. /)"
    echo -e "  ${INDIGO}-h, --help${NC}             Show this help message"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./diskUsage.sh --summary${NC}                      # Overall disk usage"
    echo -e "  ${AQUA}./diskUsage.sh ~${NC}                              # Top 10 folders in ~ (1 level), largest first"
    echo -e "  ${AQUA}./diskUsage.sh -d 2 -n 20 ~/Library${NC}           # Top 20 folders, 2 levels deep"
    echo -e "  ${AQUA}./diskUsage.sh -m files -n 25 ~/Downloads${NC}     # 25 largest files"
    echo -e "  ${AQUA}./diskUsage.sh -m all -n 50 -x .git .${NC}         # 50 largest files+folders, skipping .git"
    echo -e "  ${AQUA}./diskUsage.sh -o asc -n 10 .${NC}                 # 10 smallest folders"
    echo -e "  ${AQUA}./diskUsage.sh -S -d 2 -n 30 /${NC}                # Whole disk, 2 levels, top 30"
    echo
}

# Formats "<KB> <path>" lines into "<human size>  <path>"
format_sizes() {
    awk '{
        line = $0
        kb = $1 + 0
        sub(/^[0-9]+[ \t]+/, "", line)
        split("K M G T", unit, " ")
        i = 1
        while (kb >= 1024 && i < 4) { kb /= 1024; i++ }
        printf "%8.1f%s\t%s\n", kb, unit[i], line
    }'
}

# Defaults
SUMMARY_ONLY=false
MODE="dirs"        # dirs | files | all
DEPTH=""
TOP_N=10
ORDER="desc"       # desc | asc
TARGET_DIR="."
USE_SUDO=false
EXCLUDES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -s|--summary)
            SUMMARY_ONLY=true
            shift
            ;;
        -m|--mode)
            MODE="$2"
            shift 2 || { print_error "Missing value for $1"; usage; exit 1; }
            ;;
        -d|--depth)
            DEPTH="$2"
            shift 2 || { print_error "Missing value for $1"; usage; exit 1; }
            ;;
        -n|--top)
            TOP_N="$2"
            shift 2 || { print_error "Missing value for $1"; usage; exit 1; }
            ;;
        -o|--order)
            ORDER="$2"
            shift 2 || { print_error "Missing value for $1"; usage; exit 1; }
            ;;
        -x|--exclude)
            if [ -z "$2" ]; then print_error "Missing value for $1"; usage; exit 1; fi
            EXCLUDES+=("$2")
            shift 2
            ;;
        -S|--sudo)
            USE_SUDO=true
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Validate arguments
case "$MODE" in dirs|files|all) ;; *) print_error "Invalid mode: $MODE (use dirs|files|all)"; exit 1 ;; esac
case "$ORDER" in desc|asc) ;; *) print_error "Invalid order: $ORDER (use desc|asc)"; exit 1 ;; esac
if ! [[ "$TOP_N" =~ ^[0-9]+$ ]]; then print_error "Invalid --top value: $TOP_N"; exit 1; fi
if [ -n "$DEPTH" ] && ! [[ "$DEPTH" =~ ^[0-9]+$ ]]; then print_error "Invalid --depth value: $DEPTH"; exit 1; fi
if [ ! -e "$TARGET_DIR" ]; then print_error "Path not found: $TARGET_DIR"; exit 1; fi

SUDO=()
[ "$USE_SUDO" = true ] && SUDO=(sudo)

print_header "Disk Usage"

# Overall disk usage
echo -e "${AQUA}Overall disk usage:${NC}"
df -h "$TARGET_DIR"
echo
if [ "$SUMMARY_ONLY" = true ]; then
    print_success "Done!"
    echo
    exit 0
fi

# Sort flags
SORT_FLAGS="-n"
[ "$ORDER" = "desc" ] && SORT_FLAGS="-nr"

# Default depth: 1 for dirs mode, unlimited for all mode
if [ "$MODE" = "dirs" ] && [ -z "$DEPTH" ]; then
    DEPTH=1
fi

# Build du exclude options (macOS du uses -I, GNU du uses --exclude)
DU_EXCLUDES=()
for pattern in "${EXCLUDES[@]}"; do
    if [ "$(uname)" = "Darwin" ]; then
        DU_EXCLUDES+=(-I "$pattern")
    else
        DU_EXCLUDES+=(--exclude="$pattern")
    fi
done

# Build find exclude options (for files mode)
FIND_EXCLUDES=()
for pattern in "${EXCLUDES[@]}"; do
    FIND_EXCLUDES+=(-not -path "*/${pattern}/*" -not -name "$pattern")
done

LIMIT_TEXT="all"
[ "$TOP_N" -gt 0 ] && LIMIT_TEXT="top ${TOP_N}"
echo -e "${AQUA}Path:${NC}     ${TARGET_DIR}"
echo -e "${AQUA}Mode:${NC}     ${MODE}${DEPTH:+ (depth ${DEPTH})}"
echo -e "${AQUA}Order:${NC}    ${ORDER} (${LIMIT_TEXT})"
[ ${#EXCLUDES[@]} -gt 0 ] && echo -e "${AQUA}Excluding:${NC} ${EXCLUDES[*]}"
echo
echo -e "${INDIGO}Calculating sizes, this may take a while ...${NC}"
echo

# Collect "<KB> <path>" lines
collect() {
    case "$MODE" in
        dirs)
            "${SUDO[@]}" du -k -d "$DEPTH" "${DU_EXCLUDES[@]}" "$TARGET_DIR" 2>/dev/null
            ;;
        all)
            if [ -n "$DEPTH" ]; then
                "${SUDO[@]}" du -ak -d "$DEPTH" "${DU_EXCLUDES[@]}" "$TARGET_DIR" 2>/dev/null
            else
                "${SUDO[@]}" du -ak "${DU_EXCLUDES[@]}" "$TARGET_DIR" 2>/dev/null
            fi
            ;;
        files)
            "${SUDO[@]}" find "$TARGET_DIR" -type f "${FIND_EXCLUDES[@]}" -exec du -k {} + 2>/dev/null
            ;;
    esac
}

if [ "$TOP_N" -gt 0 ]; then
    collect | sort $SORT_FLAGS | head -n "$TOP_N" | format_sizes
else
    collect | sort $SORT_FLAGS | format_sizes
fi

echo
print_success "Done!"
echo
