#!/bin/bash
# Author: Rohtash Lakra
# Uninstall macOS app: remove from /Applications and optionally Application Support.
# Usage:
#   ./uninstall.sh <appname>                # Remove /Applications/<AppName>.app
#   ./uninstall.sh <appname> --support      # Also remove /Library/Application Support/<AppName>
#   ./uninstall.sh --list                   # List all installed app names (to use with uninstall)
#   ./uninstall.sh <appname> --list         # List paths that would be removed for <appname> (dry run)
#   ./uninstall.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Resolve search term (e.g. "word") to actual app name in /Applications (e.g. "Microsoft Word")
# Returns the app name (without .app) via echo; empty if not found or multiple ambiguous.
resolve_app_name() {
    local search="$1"
    local exact_path="/Applications/${search}.app"
    local search_lower
    search_lower=$(echo "$search" | tr '[:upper:]' '[:lower:]')
    # Exact match first
    if [ -d "$exact_path" ]; then
        echo "$search"
        return
    fi
    # Search /Applications for *.app whose name contains search (case-insensitive)
    local matches=()
    local app_path
    for app_path in /Applications/*.app; do
        [ -d "$app_path" ] || continue
        local name
        name=$(basename "$app_path" .app)
        local name_lower
        name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        if [[ "$name_lower" == *"$search_lower"* ]]; then
            matches+=("$name")
        fi
    done
    if [ ${#matches[@]} -eq 1 ]; then
        echo "${matches[0]}"
    elif [ ${#matches[@]} -gt 1 ]; then
        echo -e "${INDIGO}Multiple matches for \"${search}\":${NC}" >&2
        for m in "${matches[@]}"; do echo "  - $m" >&2; done
        echo -e "${INDIGO}Using first: ${matches[0]}${NC}" >&2
        echo "${matches[0]}"
    else
        echo ""
    fi
}

usage() {
    echo
    echo -e "${DARKBLUE}Uninstall macOS app: remove from /Applications and optionally Application Support.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./uninstall.sh <appname>${NC}              # Remove /Applications/<AppName>.app"
    echo -e "  ${AQUA}./uninstall.sh <appname> --support${NC}    # Also remove /Library/Application Support/<AppName>"
    echo -e "  ${AQUA}./uninstall.sh --list${NC}                 # List all installed app names (no app name needed)"
    echo -e "  ${AQUA}./uninstall.sh <appname> --list${NC}       # List paths that would be removed for <appname> (dry run)"
    echo -e "  ${AQUA}./uninstall.sh --help${NC}                 # Show this help"
    echo
    echo -e "${BROWN}Arguments:${NC}"
    echo -e "  ${INDIGO}<appname>${NC}  App name or search term (e.g. GarageBand, word → Microsoft Word)"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--support${NC}   Also remove /Library/Application Support/<AppName> (may require sudo)"
    echo -e "  ${INDIGO}--list${NC}     Without appname: list all installed apps. With appname: dry run (show paths only)"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./uninstall.sh --list${NC}                 # See all app names you can uninstall"
    echo -e "  ${AQUA}./uninstall.sh GarageBand${NC}"
    echo -e "  ${AQUA}./uninstall.sh word --list${NC}             # Dry run for \"word\" (e.g. Microsoft Word)"
    echo
}

if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# --list alone: list all installed app names in /Applications
if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
    if [ $# -eq 1 ]; then
        print_header "Installed Applications"
        echo -e "${INDIGO}App names in /Applications (use as <appname> to uninstall):${NC}"
        echo
        for app_path in /Applications/*.app; do
            [ -d "$app_path" ] || continue
            basename "$app_path" .app
        done | sort
        echo
        exit 0
    fi
fi

APP_NAME="$1"
shift

# Normalize: ensure .app suffix for Applications path
APP_BASE="${APP_NAME%.app}"
APP_PATH="/Applications/${APP_BASE}.app"
SUPPORT_PATH="/Library/Application Support/${APP_BASE}"
LIST_ONLY=false
REMOVE_SUPPORT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list|-l)
            LIST_ONLY=true
            shift
            ;;
        --support|-s)
            REMOVE_SUPPORT=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

print_header "Uninstall App"

if [ -z "$APP_BASE" ] || [[ "$APP_BASE" == --* ]]; then
    print_error "App name required. Usage: ./uninstall.sh <appname> [--support] [--list]"
    usage
    exit 1
fi

# Resolve to actual app name if not an exact path match
if [ ! -d "$APP_PATH" ]; then
    resolved=$(resolve_app_name "$APP_BASE")
    if [ -n "$resolved" ]; then
        APP_BASE="$resolved"
        APP_PATH="/Applications/${APP_BASE}.app"
        SUPPORT_PATH="/Library/Application Support/${APP_BASE}"
        echo -e "${INDIGO}Resolved \"${1}\" to: ${AQUA}${APP_BASE}${NC}"
        echo
    fi
fi

if [ "$LIST_ONLY" = true ]; then
    echo -e "${INDIGO}Paths that would be removed (dry run):${NC}"
    echo
    [ -e "$APP_PATH" ] && echo -e "  ${AQUA}${APP_PATH}${NC}"
    [ "$REMOVE_SUPPORT" = true ] && [ -e "$SUPPORT_PATH" ] && echo -e "  ${AQUA}${SUPPORT_PATH}${NC}"
    echo
    exit 0
fi

# Remove /Applications/<AppName>.app
if [ -d "$APP_PATH" ]; then
    echo -e "${INDIGO}Removing application: ${AQUA}${APP_PATH}${NC}"
    rm -rf "$APP_PATH"
    if [ $? -eq 0 ]; then
        print_success "Removed: $APP_PATH"
    else
        print_warning "Could not remove $APP_PATH (try sudo?)"
    fi
else
    print_warning "Application not found: $APP_PATH"
fi

# Optionally remove Application Support
if [ "$REMOVE_SUPPORT" = true ]; then
    if [ -d "$SUPPORT_PATH" ]; then
        echo -e "${INDIGO}Removing Application Support: ${AQUA}${SUPPORT_PATH}${NC}"
        sudo rm -rf "$SUPPORT_PATH"
        if [ $? -eq 0 ]; then
            print_success "Removed: $SUPPORT_PATH"
        else
            print_warning "Could not remove $SUPPORT_PATH"
        fi
    else
        print_warning "Application Support not found: $SUPPORT_PATH"
    fi
fi

echo
