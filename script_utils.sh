#!/bin/bash
# script_utils.sh - Utility functions for script path resolution
# This file should be sourced before colors.sh to resolve symlinks and set SCRIPTS_HOME
# Location: Same directory as colors.sh (Scripts.bak root)
#
# Usage in scripts (one-liner):
#   _s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Function to resolve script path (handles symlinks)
# Usage: resolve_script_path "${BASH_SOURCE[0]}"
# Returns: The actual script path (resolved symlinks)
resolve_script_path() {
    local script_path="$1"
    # Resolve symlinks to get actual script path
    while [ -L "$script_path" ]; do
        local link_target="$(readlink "$script_path")"
        # If readlink returns a relative path, make it absolute
        if [[ "$link_target" != /* ]]; then
            script_path="$(cd "$(dirname "$script_path")" && pwd)/$link_target"
        else
            script_path="$link_target"
        fi
    done
    echo "$script_path"
}

# Function to setup scripts environment (resolves path and sources colors.sh)
# Usage: setup_scripts_env "${BASH_SOURCE[0]}"
# This resolves symlinks, sets SCRIPTS_HOME, and sources colors.sh
setup_scripts_env() {
    local script_source="$1"
    
    # Resolve symlinks to get actual script path
    local script_path=$(resolve_script_path "$script_source")
    local script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    export SCRIPTS_HOME="$(cd "${script_dir}/../.." && pwd)"
    
    # Source colors.sh if it exists
    if [ -f "${SCRIPTS_HOME}/colors.sh" ]; then
        source "${SCRIPTS_HOME}/colors.sh"
    else
        echo "Error: colors.sh not found at ${SCRIPTS_HOME}/colors.sh" >&2
        return 1
    fi
}

