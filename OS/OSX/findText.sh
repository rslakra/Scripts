#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

if [ $# -lt 2 ]; then
    print_error "Usage: ./findText.sh <search_text> <file_pattern>"
    exit 1
fi

print_header "Find Text"
echo -e "${INDIGO}Searching for '${AQUA}$1${INDIGO}' in files matching '${AQUA}$2${INDIGO}'${NC}"
grep -l $1 $2 | sort -n
echo
