#!/bin/bash
# Author: Rohtash Lakra
# SVN: create repo, backup (hotcopy/dump/dump-compressed/full-copy), restore, remove .svn dirs.
# Usage:
#   ./svn.sh --help
#   ./svn.sh create [options] [repo_name]
#   ./svn.sh hotcopy <source-repo> <target-path>
#   ./svn.sh dump <repo-path> [output-file]
#   ./svn.sh dump-compressed <repo-path> [output-file]
#   ./svn.sh restore <repo-path> <dump-file>
#   ./svn.sh full-copy <source-dir> <target-dir>
#   ./svn.sh remove-svn-dirs [path] [--execute]

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

DEFAULT_REPO_NAME="SVNRepo"
DEFAULT_FS_TYPE="fsfs"

usage() {
    echo
    echo -e "${DARKBLUE}SVN: create repository, backup (hotcopy/dump/full-copy), restore, remove .svn dirs.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./svn.sh --help${NC}"
    echo -e "  ${AQUA}./svn.sh create [options] [repo_name]${NC}                # Create new repository"
    echo -e "  ${AQUA}./svn.sh hotcopy <source-repo> <target-path>${NC}         # Hotcopy repo (svnadmin hotcopy)"
    echo -e "  ${AQUA}./svn.sh dump <repo-path> [output-file]${NC}              # Dump repo to file"
    echo -e "  ${AQUA}./svn.sh dump-compressed <repo-path> [output-file]${NC}   # Dump repo to .dump.gz"
    echo -e "  ${AQUA}./svn.sh restore <repo-path> <dump-file>${NC}             # Load dump into repo"
    echo -e "  ${AQUA}./svn.sh full-copy <source-dir> <target-dir>${NC}         # Full dir copy (ditto)"
    echo -e "  ${AQUA}./svn.sh remove-svn-dirs [path] [--execute]${NC}          # Find/remove .svn dirs (default path: .)"
    echo
    echo -e "${BROWN}Create options:${NC}"
    echo -e "  ${INDIGO}--name <name>${NC}      Repository name (default: ${DEFAULT_REPO_NAME})"
    echo -e "  ${INDIGO}--path <path>${NC}      Path where to create repo (default: .)"
    echo -e "  ${INDIGO}--fs-type <type>${NC}   fsfs or bdb (default: fsfs)"
    echo
    echo -e "${BROWN}Remove .svn dirs:${NC}"
    echo -e "  ${INDIGO}--execute${NC}         Actually remove .svn dirs; without it, only lists them"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./svn.sh create myrepo${NC}"
    echo -e "  ${AQUA}./svn.sh create --name myrepo --path /svn${NC}"
    echo -e "  ${AQUA}./svn.sh hotcopy /path/to/repo /backup/repo-\$(date +%Y%m%d)${NC}"
    echo -e "  ${AQUA}./svn.sh dump /path/to/repo /backup/repo.dump${NC}"
    echo -e "  ${AQUA}./svn.sh dump-compressed /path/to/repo /backup/repo.dump.gz${NC}"
    echo -e "  ${AQUA}./svn.sh restore /path/to/newrepo /backup/repo.dump${NC}"
    echo -e "  ${AQUA}./svn.sh full-copy ~/Repo/SVN /Volumes/HD/Repo/SVN${NC}"
    echo -e "  ${AQUA}./svn.sh remove-svn-dirs . --execute${NC}"
    echo
}

# --- create (from makeRepository.sh) ---
do_create() {
    local REPO_NAME="" REPO_PATH="" FS_TYPE="$DEFAULT_FS_TYPE"
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                [ -z "$2" ] && { print_error "Repository name required after --name"; usage; exit 2; }
                REPO_NAME="$2"; shift 2
                ;;
            --path)
                [ -z "$2" ] && { print_error "Path required after --path"; usage; exit 2; }
                REPO_PATH="$2"; shift 2
                ;;
            --fs-type)
                [ -z "$2" ] && { print_error "Filesystem type required after --fs-type"; usage; exit 2; }
                [ "$2" != "fsfs" ] && [ "$2" != "bdb" ] && { print_error "Invalid fs-type: $2"; usage; exit 2; }
                FS_TYPE="$2"; shift 2
                ;;
            -h|--help)
                usage; exit 0
                ;;
            -*)
                print_error "Unknown option: $1"; usage; exit 2
                ;;
            *)
                if [ -z "$REPO_NAME" ]; then REPO_NAME="$1"; else print_error "Unknown: $1"; usage; exit 2; fi
                shift
                ;;
        esac
    done
    [ -z "$REPO_NAME" ] && REPO_NAME="$DEFAULT_REPO_NAME"
    [ -z "$REPO_PATH" ] && REPO_PATH="."
    if [ ! -d "$REPO_PATH" ]; then
        mkdir -p "$REPO_PATH" || { print_error "Failed to create: $REPO_PATH"; exit 2; }
    fi
    REPO_PATH=$(cd "$REPO_PATH" && pwd)
    local FULL_REPO_PATH="${REPO_PATH}/${REPO_NAME}"
    if [ -d "$FULL_REPO_PATH" ]; then
        print_error "Repository already exists: $FULL_REPO_PATH"; exit 2
    fi
    if ! command -v svnadmin &>/dev/null; then
        print_error "svnadmin not found. Install Subversion."; exit 2
    fi
    print_header "Create SVN Repository"
    echo -e "${INDIGO}Name: ${AQUA}${REPO_NAME}${NC}  ${INDIGO}Path: ${AQUA}${FULL_REPO_PATH}${NC}  ${INDIGO}FS: ${AQUA}${FS_TYPE}${NC}"
    echo
    svnadmin create --fs-type "$FS_TYPE" "$FULL_REPO_PATH" || { print_error "Failed to create repository"; exit 2; }
    print_success "SVN repository created: $FULL_REPO_PATH"
    echo
}

# --- hotcopy ---
do_hotcopy() {
    local src="$1" tgt="$2"
    if [ -z "$src" ] || [ -z "$tgt" ]; then
        print_error "Usage: ./svn.sh hotcopy <source-repo> <target-path>"; usage; exit 2
    fi
    if [ ! -d "$src" ]; then
        print_error "Source repository not found: $src"; exit 2
    fi
    if ! command -v svnadmin &>/dev/null; then
        print_error "svnadmin not found."; exit 2
    fi
    print_header "SVN Hotcopy"
    echo -e "${INDIGO}Source: ${AQUA}${src}${NC}"
    echo -e "${INDIGO}Target: ${AQUA}${tgt}${NC}"
    echo
    svnadmin hotcopy "$src" "$tgt" || { print_error "Hotcopy failed"; exit 2; }
    print_success "Hotcopy succeeded: $tgt"
    echo
}

# --- dump (plain) ---
do_dump() {
    local repo="$1" out="$2"
    if [ -z "$repo" ]; then
        print_error "Usage: ./svn.sh dump <repo-path> [output-file]"; usage; exit 2
    fi
    if [ ! -d "$repo" ]; then
        print_error "Repository not found: $repo"; exit 2
    fi
    if [ -z "$out" ]; then
        out="$(dirname "$repo")/$(basename "$repo")-$(date +%Y%m%d%H%M%S).dump"
    fi
    if ! command -v svnadmin &>/dev/null; then
        print_error "svnadmin not found."; exit 2
    fi
    print_header "SVN Dump"
    echo -e "${INDIGO}Repository: ${AQUA}${repo}${NC}"
    echo -e "${INDIGO}Output: ${AQUA}${out}${NC}"
    echo
    svnadmin dump "$repo" > "$out" || { print_error "Dump failed"; exit 2; }
    print_success "Dump succeeded: $out"
    echo
}

# --- dump compressed ---
do_dump_compressed() {
    local repo="$1" out="$2"
    if [ -z "$repo" ]; then
        print_error "Usage: ./svn.sh dump-compressed <repo-path> [output-file]"; usage; exit 2
    fi
    if [ ! -d "$repo" ]; then
        print_error "Repository not found: $repo"; exit 2
    fi
    if [ -z "$out" ]; then
        out="$(dirname "$repo")/$(basename "$repo")-$(date +%Y%m%d%H%M%S).dump.gz"
    fi
    if ! command -v svnadmin &>/dev/null; then
        print_error "svnadmin not found."; exit 2
    fi
    print_header "SVN Dump (compressed)"
    echo -e "${INDIGO}Repository: ${AQUA}${repo}${NC}"
    echo -e "${INDIGO}Output: ${AQUA}${out}${NC}"
    echo
    svnadmin dump "$repo" | gzip -9 > "$out" || { print_error "Dump failed"; exit 2; }
    print_success "Dump succeeded: $out"
    echo
}

# --- restore (load) ---
do_restore() {
    local repo="$1" dumpfile="$2"
    if [ -z "$repo" ] || [ -z "$dumpfile" ]; then
        print_error "Usage: ./svn.sh restore <repo-path> <dump-file>"; usage; exit 2
    fi
    if [ ! -f "$dumpfile" ]; then
        print_error "Dump file not found: $dumpfile"; exit 2
    fi
    if ! command -v svnadmin &>/dev/null; then
        print_error "svnadmin not found."; exit 2
    fi
    if [ ! -d "$repo" ]; then
        echo -e "${INDIGO}Repository not found; creating: ${repo}${NC}"
        svnadmin create "$repo" || { print_error "Failed to create repo"; exit 2; }
    fi
    print_header "SVN Restore"
    echo -e "${INDIGO}Repository: ${AQUA}${repo}${NC}"
    echo -e "${INDIGO}Dump file: ${AQUA}${dumpfile}${NC}"
    echo
    if [[ "$dumpfile" == *.gz ]]; then
        gunzip -c "$dumpfile" | svnadmin load "$repo" || { print_error "Restore failed"; exit 2; }
    else
        svnadmin load "$repo" < "$dumpfile" || { print_error "Restore failed"; exit 2; }
    fi
    print_success "Restore succeeded: $repo"
    echo
}

# --- full copy (ditto) ---
do_full_copy() {
    local src="$1" tgt="$2"
    if [ -z "$src" ] || [ -z "$tgt" ]; then
        print_error "Usage: ./svn.sh full-copy <source-dir> <target-dir>"; usage; exit 2
    fi
    if [ ! -d "$src" ]; then
        print_error "Source directory not found: $src"; exit 2
    fi
    print_header "SVN Full Copy"
    echo -e "${INDIGO}Source: ${AQUA}${src}${NC}"
    echo -e "${INDIGO}Target: ${AQUA}${tgt}${NC}"
    echo
    if command -v ditto &>/dev/null; then
        ditto -V "$src" "$tgt" || { print_error "ditto failed"; exit 2; }
    else
        mkdir -p "$tgt" && cp -a "$src"/. "$tgt"/ || { print_error "cp failed"; exit 2; }
    fi
    print_success "Full copy succeeded: $tgt"
    echo
}

# --- remove .svn dirs ---
do_remove_svn_dirs() {
    local path="." do_remove=0
    while [[ $# -gt 0 ]]; do
        case $1 in
            --execute) do_remove=1; shift ;;
            -h|--help) usage; exit 0 ;;
            -*)
                print_error "Unknown option: $1"; usage; exit 2
                ;;
            *)
                path="$1"; shift
                ;;
        esac
    done
    if [ ! -d "$path" ]; then
        print_error "Path not found: $path"; exit 2
    fi
    print_header "Find/Remove .svn directories"
    echo -e "${INDIGO}Path: ${AQUA}${path}${NC}  ${INDIGO}Mode: $([ $do_remove -eq 1 ] && echo "remove" || echo "list only")${NC}"
    echo
    if [ $do_remove -eq 1 ]; then
        find "$path" -depth -type d -name '.svn' -exec rm -rf {} + 2>/dev/null || true
        print_success "Removed .svn directories under $path"
    else
        find "$path" -type d -name '.svn' -print 2>/dev/null || true
        echo -e "${INDIGO}(Use --execute to actually remove the above.)${NC}"
    fi
    echo
}

# --- main ---
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

cmd="$1"
shift

case "$cmd" in
    create|make-repo)
        do_create "$@"
        ;;
    hotcopy)
        do_hotcopy "$1" "$2"
        ;;
    dump)
        do_dump "$1" "$2"
        ;;
    dump-compressed)
        do_dump_compressed "$1" "$2"
        ;;
    restore)
        do_restore "$1" "$2"
        ;;
    full-copy)
        do_full_copy "$1" "$2"
        ;;
    remove-svn-dirs)
        do_remove_svn_dirs "$@"
        ;;
    *)
        print_error "Unknown command: $cmd"
        usage
        exit 2
        ;;
esac
