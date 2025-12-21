#!/bin/bash
# colors.sh - Shared color definitions for all build and deployment scripts
# Source this file in scripts to use consistent colors across the platform
# Colors for output (optimized for white backgrounds)
# Source this file in your scripts: source "$(dirname "$0")/colors.sh"
# Or: source "${SCRIPTS_HOME}/colors.sh"

# Color codes for better readability
AQUA='\033[0;36m'        # Cyan - good contrast on white
BLUEVIOLET='\033[0;35m'  # Magenta/Purple - good contrast on white
BROWN='\033[0;33m'       # Yellow/Brown - visible on white
RED='\033[0;31m'         # Red - excellent contrast on white
DARKBLUE='\033[0;34m'    # Blue - good contrast on white
GREEN='\033[0;32m'       # Green - good contrast on white
INDIGO='\033[1;34m'      # Bright Blue - good contrast on white
NC='\033[0m'             # No Color


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔍 Extracting JWT and Session Info from VDI Pod
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Helper function to resolve script path and set SCRIPTS_HOME
# Usage: setup_scripts_home "${BASH_SOURCE[0]}"
# This resolves symlinks and sets SCRIPTS_HOME to the directory containing colors.sh
setup_scripts_home() {
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
    local script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    export SCRIPTS_HOME="$(cd "${script_dir}/../.." && pwd)"
}

# Color functions for common use cases
print_aqua() {
    echo -e "${AQUA}$1${NC}"
}

print_cyan() {
    echo -e "${AQUA}$1${NC}"
}

print_blueviolet() {
    echo -e "${BLUEVIOLET}$1${NC}"
}

print_magenta() {
    echo -e "${BLUEVIOLET}$1${NC}"
}

print_brown() {
    echo -e "${BROWN}$1${NC}"
}

print_yellow() {
    echo -e "${BROWN}$1${NC}"
}

print_red() {
    echo -e "${RED}$1${NC}"
}

print_darkblue() {
    echo -e "${DARKBLUE}$1${NC}"
}

print_blue() {
    echo -e "${DARKBLUE}$1${NC}"
}

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_indigo() {
    echo -e "${INDIGO}$1${NC}"
}

# Helper functions for common message types
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${BROWN}⚠ $1${NC}"
}

print_info() {
    echo -e "${AQUA}ℹ $1${NC}"
}

print_header() {
    local title=$1
    echo ""
    echo -e "${DARKBLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${DARKBLUE}   ${title}${NC}"
    echo -e "${DARKBLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Colored build message
print_building() {
    local image_name=$1
    echo ""
    echo -e "${AQUA}Building [${DARKBLUE}${image_name}${AQUA}] ...${NC}"
    echo ""
}

# Colored status messages
print_completed() {
    local message=$1
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   ✓ ${message}${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_failed() {
    local message=$1
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}   ✗ ${message}${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

