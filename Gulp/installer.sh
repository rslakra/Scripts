#!/bin/bash
# Author: Rohtash Lakra
# Installs Gulp globally and locally (with common plugins). Requires Node.js and npm.
# Usage:
#   ./installer.sh              # Run install
#   ./installer.sh --help       # Show this help
#
# Prerequisites: Install Node.js (http://nodejs.org/download/). Ensure /usr/local/bin is in $PATH.

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; _d="$(cd "$(dirname "$_s")" && pwd)"; while [ "$_d" != "/" ] && [ ! -f "$_d/script_utils.sh" ]; do _d="$(cd "$_d/.." && pwd)"; done; [ -f "$_d/script_utils.sh" ] && source "$_d/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}" || { DARKBLUE=''; AQUA=''; BROWN=''; GREEN=''; NC=''; }

usage() {
    echo
    echo -e "${DARKBLUE}Installs Gulp globally and locally (with common plugins).${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./installer.sh${NC}               # Run install"
    echo -e "  ${AQUA}./installer.sh --help${NC}        # Show this help"
    echo
    echo -e "${BROWN}Prerequisites:${NC} Node.js and npm (e.g. /usr/local/bin in \$PATH)."
    echo
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
fi

clear
echo
print_header "Install Gulp"

echo -e "${DARKBLUE}Installing Gulp globally...${NC}"
sudo npm install gulp -g

echo -e "${DARKBLUE}Installing Gulp locally (requires package.json)...${NC}"
sudo npm install gulp --save-dev

echo -e "${DARKBLUE}Installing Gulp plugins...${NC}"
sudo npm install gulp-debug gulp-minify-html gulp-concat gulp-replace gulp-concat-css gulp-uglify gulp-minify-css gulp-html-replace yargs gulp-angular-templatecache del gulp-manifest gulp-htmlbuild gulp-load-plugins event-stream --save-dev

print_success "Gulp installed successfully!"
echo
