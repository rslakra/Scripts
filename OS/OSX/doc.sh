#!/bin/bash
# Author: Rohtash Lakra
# Generate API docs with appledoc.
# Usage:
#   ./doc.sh --project-name <name> [--company <name>] [--company-id <id>] [--output <path>]
#   ./doc.sh --help
#
# Requires: appledoc (e.g. brew install appledoc or from https://github.com/tomaz/appledoc)

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage() {
    echo
    echo -e "${DARKBLUE}Generate API documentation with appledoc.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./doc.sh --project-name <name>${NC} [options]"
    echo -e "  ${AQUA}./doc.sh --help${NC}"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}--project-name <name>${NC}  Project name (required)"
    echo -e "  ${INDIGO}--company <name>${NC}       Project company (default: same as project name)"
    echo -e "  ${INDIGO}--company-id <id>${NC}      Company ID / reverse-DNS style (e.g. gov.nasa.worldwind)"
    echo -e "  ${INDIGO}--output <path>${NC}        Output directory (default: ~/help)"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./doc.sh --project-name \"My App\" --company \"My Co\" --company-id com.myco.app --output ~/help${NC}"
    echo -e "  ${AQUA}./doc.sh --project-name \"NASA World Wind\" --company \"NASA World Wind\" --company-id gov.nasa.worldwind --output ~/help${NC}"
    echo
}

PROJECT_NAME=""
PROJECT_COMPANY=""
COMPANY_ID=""
OUTPUT_DIR="${HOME}/help"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --company)
            PROJECT_COMPANY="$2"
            shift 2
            ;;
        --company-id)
            COMPANY_ID="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ]; then
    print_error "Project name required. Usage: ./doc.sh --project-name <name> [options]"
    usage
    exit 1
fi

# Default company to project name if not set
[ -z "$PROJECT_COMPANY" ] && PROJECT_COMPANY="$PROJECT_NAME"

if ! command -v appledoc >/dev/null 2>&1; then
    print_error "appledoc not found. Install with: brew install appledoc (or see https://github.com/tomaz/appledoc)"
    exit 1
fi

print_header "Generate API Docs"
echo -e "${INDIGO}Project: ${AQUA}${PROJECT_NAME}${NC}"
echo -e "${INDIGO}Company: ${AQUA}${PROJECT_COMPANY}${NC}"
echo -e "${INDIGO}Output:  ${AQUA}${OUTPUT_DIR}${NC}"
echo

# Run appledoc (run from current dir; appledoc reads source from . or specified path)
if [ -n "$COMPANY_ID" ]; then
    appledoc --project-name "$PROJECT_NAME" --project-company "$PROJECT_COMPANY" --company-id "$COMPANY_ID" --output "$OUTPUT_DIR" .
else
    appledoc --project-name "$PROJECT_NAME" --project-company "$PROJECT_COMPANY" --output "$OUTPUT_DIR" .
fi
if [ $? -eq 0 ]; then
    print_success "API docs generated in: ${OUTPUT_DIR}"
else
    print_error "appledoc failed"
    exit 1
fi
echo
