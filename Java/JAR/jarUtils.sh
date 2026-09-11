#!/bin/bash
# Author: Rohtash Lakra
# JAR utilities: copy JAR(s) from source to target.
# Usage:
#   ./jarUtils.sh --cp <source_jar> <target>   # Copy a JAR (target = file or directory)
#   ./jarUtils.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; _d="$(cd "$(dirname "$_s")" && pwd)"; while [ "$_d" != "/" ] && [ ! -f "$_d/script_utils.sh" ]; do _d="$(cd "$_d/.." && pwd)"; done; [ -f "$_d/script_utils.sh" ] && source "$_d/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}" || { DARKBLUE=''; AQUA=''; BROWN=''; GREEN=''; NC=''; }

usage() {
    echo
    echo -e "${DARKBLUE}JAR utilities: copy JAR(s) from source to target.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./jarUtils.sh --cp <source_jar> <target>${NC}   # Copy JAR; target is file path or directory"
    echo -e "  ${AQUA}./jarUtils.sh --help${NC}  ${DARKBLUE}# Show this help${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./jarUtils.sh --cp ./myapp.jar /opt/deploy/${NC}     # Copy myapp.jar into /opt/deploy/"
    echo -e "  ${AQUA}./jarUtils.sh --cp ./lib/foo.jar ./out/foo.jar${NC}  # Copy to specific path"
    echo
}

copy_jar() {
    local src="$1"
    local tgt="$2"
    if [ -z "$src" ] || [ -z "$tgt" ]; then
        echo -e "${BROWN}Usage:${NC} ./jarUtils.sh --cp <source_jar> <target>" >&2
        return 1
    fi
    if [ ! -e "$src" ]; then
        echo -e "${BROWN}Source not found:${NC} $src" >&2
        return 1
    fi
    local dest="$tgt"
    if [ -d "$tgt" ]; then
        dest="${tgt%/}/$(basename "$src")"
    fi
    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [ -n "$dest_dir" ] && [ ! -d "$dest_dir" ]; then
        echo -e "${BROWN}Creating directory:${NC} $dest_dir"
        mkdir -p "$dest_dir" || { echo -e "${BROWN}Failed to create directory:${NC} $dest_dir" >&2; return 1; }
    fi
    cp -f "$src" "$dest" && print_success "Copied $(basename "$src") to $dest" || return 1
}

copy_jboss_ear() {
    export JBOSS_HOME="${JBOSS_HOME:-/Applications/JBoss-4.2.3.GA}"
    export JBOSS_HOME_BR="${JBOSS_HOME_BR:-/Applications/JBoss-4.2.3.GA_BlackRock}"
    export JBOSS_DEPLOY_DIR="server/default/deploy"
    export EAR_NAME="BlackRock.ear"

    echo -e "${DARKBLUE}Setting Environment Variables${NC}"
    echo -e "  ${AQUA}JBOSS_HOME:${NC}      $JBOSS_HOME"
    echo -e "  ${AQUA}JBOSS_HOME_BR:${NC}   $JBOSS_HOME_BR"
    echo -e "  ${AQUA}EAR:${NC}             $EAR_NAME"
    echo

    local ear_dir="$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME"
    if [ ! -d "$ear_dir" ]; then
        echo -e "${DARKBLUE}Creating${NC} $ear_dir"
        mkdir -p "$ear_dir"
    fi

    local src_ear="$JBOSS_HOME_BR/$JBOSS_DEPLOY_DIR/$EAR_NAME"
    if [ ! -d "$src_ear" ]; then
        echo -e "${BROWN}Source EAR directory not found:${NC} $src_ear" >&2
        return 1
    fi

    echo -e "${DARKBLUE}Copying${NC} $src_ear ${DARKBLUE}to${NC} $ear_dir"
    cp -R "$src_ear"/* "$ear_dir"/ && print_success "JAR/EAR copied successfully!" || return 1
}

# --- main ---
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
fi

clear
echo

case "${1:-}" in
    --cp)
        print_header "Copy JAR"
        copy_jar "$2" "$3"
        exit $?
        ;;
    jboss)
        print_header "Copy JBoss BlackRock EAR"
        copy_jboss_ear
        exit $?
        ;;
    "")
        usage
        exit 0
        ;;
    *)
        echo -e "${BROWN}Unknown option:${NC} $1" >&2
        usage
        exit 2
        ;;
esac
