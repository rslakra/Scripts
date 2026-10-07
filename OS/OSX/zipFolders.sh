#!/bin/bash
# Author: Rohtash Lakra
# Zips multiple folders (listed in projects.txt, passed as arguments, or all sub-folders)
# using zipFolder.sh for each folder, so the same exclusions and options apply.

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Locate zipFolder.sh next to the real location of this script (symlink-safe)
_z="${BASH_SOURCE[0]}"; while [ -L "$_z" ]; do _l="$(readlink "$_z")"; [[ "$_l" != /* ]] && _z="$(cd "$(dirname "$_z")" && pwd)/$_l" || _z="$_l"; done
ZIP_FOLDER_SCRIPT="$(cd "$(dirname "$_z")" && pwd)/zipFolder.sh"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Purpose:${NC} Zip multiple folders, each one exactly the way ${AQUA}zipFolder.sh${NC} zips a single folder."
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./zipFolders.sh [options]${NC}"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo
    echo -e "  ${INDIGO}--help, -h${NC}"
    echo -e "    Show this help message and exit."
    echo
    echo -e "  ${INDIGO}--projects <dir1> <dir2> ...${NC}"
    echo -e "    Folder names (inside the current directory) to zip."
    echo
    echo -e "  ${INDIGO}--file <projects.txt>${NC}"
    echo -e "    File listing the folders to zip (one per line, '#' comments allowed)."
    echo
    echo -e "  ${INDIGO}--exclude <excludes.txt>${NC}"
    echo -e "    File listing folders to skip (same format)."
    echo
    echo -e "  ${INDIGO}--output-dir <dir>${NC}"
    echo -e "    Directory to place the zip files in (default: ${AQUA}${PWD}/Backup${NC}, created if missing)."
    echo
    echo -e "${BROWN}Options passed through to zipFolder.sh:${NC}"
    echo -e "  ${INDIGO}--include-node-modules${NC}   Include node_modules folders (default: excluded)"
    echo -e "  ${INDIGO}--timestamp${NC}              Also create a timestamped copy of each zip"
    echo -e "  ${INDIGO}--no-exclusions${NC}          Don't exclude common build/cache files"
    echo
    echo -e "${BROWN}Auto-Detection:${NC}"
    echo -e "  If no project options are given, ${AQUA}projects.txt${NC} and ${AQUA}excludes.txt${NC} are used from"
    echo -e "  the current directory when present; otherwise all sub-directories are zipped."
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./zipFolders.sh${NC}"
    echo -e "    ${INDIGO}(default) Zips the folders listed in projects.txt into ${PWD}/Backup${NC}"
    echo -e "  ${AQUA}./zipFolders.sh --file projects.txt --output-dir ~/Downloads/Backup${NC}"
    echo -e "  ${AQUA}./zipFolders.sh --file projects.txt --exclude excludes.txt --timestamp${NC}"
    echo -e "  ${AQUA}./zipFolders.sh --projects proj1 proj2 --include-node-modules${NC}"
    echo
}

# Read a text file into an array. Usage: read_txt_file <file_path> <array_name> <description>
read_txt_file() {
    local file_path="$1"
    local array_name="$2"
    local description="$3"

    # Expand tilde in file path
    file_path="${file_path/#\~/$HOME}"

    if [ ! -f "${file_path}" ]; then
        print_error "${description} file not found: ${file_path}"
        exit 1
    fi

    echo -e "${INDIGO}Reading ${description} from file: ${AQUA}${file_path}${NC}"

    local temp_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Strip comments and surrounding whitespace, skip empty lines
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        if [ -n "$line" ]; then
            temp_array+=("$line")
        fi
    done < "${file_path}"

    eval "${array_name}=(\"\${temp_array[@]}\")"
}

# Initialize variables
WORKSPACE_DIR="${PWD}"
PROJECTS_FILE=""
PROJECTS_LIST=()
EXCLUDE_FILE=""
EXCLUDE_LIST=()
PROJECTS_TO_ZIP=()
OUTPUT_DIR="${PWD}/Backup"
ZIP_OPTIONS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --file)
            if [ -z "$2" ]; then
                print_error "File path required after --file"
                usage
                exit 1
            fi
            PROJECTS_FILE="$2"
            shift 2
            ;;
        --projects)
            shift
            while [[ $# -gt 0 ]] && [[ ! "$1" =~ ^-- ]]; do
                PROJECTS_LIST+=("$1")
                shift
            done
            ;;
        --exclude)
            if [ -z "$2" ]; then
                print_error "File path required after --exclude"
                usage
                exit 1
            fi
            EXCLUDE_FILE="$2"
            shift 2
            ;;
        --output-dir)
            if [ -z "$2" ]; then
                print_error "Directory required after --output-dir"
                usage
                exit 1
            fi
            OUTPUT_DIR="${2/#\~/$HOME}"
            shift 2
            ;;
        --include-node-modules|--timestamp|--no-exclusions)
            ZIP_OPTIONS+=("$1")
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Verify zipFolder.sh is available
if [ ! -f "${ZIP_FOLDER_SCRIPT}" ]; then
    print_error "zipFolder.sh not found: ${ZIP_FOLDER_SCRIPT}"
    exit 1
fi

# If no project options provided, look for default files in current directory
if [ -z "${PROJECTS_FILE}" ] && [ ${#PROJECTS_LIST[@]} -eq 0 ] && [ -z "${EXCLUDE_FILE}" ]; then
    if [ -f "${WORKSPACE_DIR}/projects.txt" ]; then
        PROJECTS_FILE="${WORKSPACE_DIR}/projects.txt"
        echo -e "${INDIGO}Found ${AQUA}projects.txt${INDIGO} in current directory${NC}"
    fi
    if [ -f "${WORKSPACE_DIR}/excludes.txt" ]; then
        EXCLUDE_FILE="${WORKSPACE_DIR}/excludes.txt"
        echo -e "${INDIGO}Found ${AQUA}excludes.txt${INDIGO} in current directory${NC}"
    fi
fi

# Prepare output directory (absolute path)
if [ -n "${OUTPUT_DIR}" ]; then
    mkdir -p "${OUTPUT_DIR}" || { print_error "Cannot create output directory: ${OUTPUT_DIR}"; exit 1; }
    OUTPUT_DIR="$(cd "${OUTPUT_DIR}" && pwd)"
fi

# Collect folders to zip
if [ -n "${PROJECTS_FILE}" ]; then
    read_txt_file "${PROJECTS_FILE}" "PROJECTS_TO_ZIP" "projects"
elif [ ${#PROJECTS_LIST[@]} -gt 0 ]; then
    PROJECTS_TO_ZIP=("${PROJECTS_LIST[@]}")
else
    echo -e "${INDIGO}No projects specified, zipping all directories in workspace...${NC}"
    for entry in "${WORKSPACE_DIR}"/*; do
        # Skip the output directory so backups are not zipped into themselves
        if [ -d "${entry}" ] && [ "${entry}" != "${OUTPUT_DIR}" ]; then
            PROJECTS_TO_ZIP+=("$(basename "${entry}")")
        fi
    done
fi

# Read excluded projects
if [ -n "${EXCLUDE_FILE}" ]; then
    read_txt_file "${EXCLUDE_FILE}" "EXCLUDE_LIST" "excluded projects"
fi

# Filter out excluded projects
if [ ${#EXCLUDE_LIST[@]} -gt 0 ]; then
    echo -e "${INDIGO}Excluding projects: ${AQUA}${EXCLUDE_LIST[*]}${NC}"
    FILTERED_PROJECTS=()
    for project in "${PROJECTS_TO_ZIP[@]}"; do
        exclude=false
        for exclude_item in "${EXCLUDE_LIST[@]}"; do
            if [ "$project" == "$exclude_item" ]; then
                exclude=true
                break
            fi
        done
        if [ "$exclude" = false ]; then
            FILTERED_PROJECTS+=("$project")
        fi
    done
    PROJECTS_TO_ZIP=("${FILTERED_PROJECTS[@]}")
fi

if [ ${#PROJECTS_TO_ZIP[@]} -eq 0 ]; then
    print_warning "No folders to zip"
    exit 0
fi

# Print summary
print_header "Zip Folders"
echo -e "${INDIGO}Workspace: ${AQUA}${WORKSPACE_DIR}${NC}"
echo -e "${INDIGO}Folders to zip: ${AQUA}${#PROJECTS_TO_ZIP[@]}${NC}"
if [ ${#PROJECTS_TO_ZIP[@]} -le 10 ]; then
    echo -e "${INDIGO}Folder list: ${AQUA}${PROJECTS_TO_ZIP[*]}${NC}"
fi
if [ -n "${OUTPUT_DIR}" ]; then
    echo -e "${INDIGO}Output directory: ${AQUA}${OUTPUT_DIR}${NC}"
fi
if [ ${#ZIP_OPTIONS[@]} -gt 0 ]; then
    echo -e "${INDIGO}Zip options: ${AQUA}${ZIP_OPTIONS[*]}${NC}"
fi

# Zip each folder using zipFolder.sh
ZIPPED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0
FAILED_PROJECTS=()
export ZIP_FOLDER_NO_CLEAR=1

for project in "${PROJECTS_TO_ZIP[@]}"; do
    pathEntry="${WORKSPACE_DIR}/${project}"

    if [[ ! -d "${pathEntry}" ]]; then
        print_warning "${pathEntry} is not a directory, skipping..."
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    echo
    echo -e "${INDIGO}Zipping [${AQUA}${project}${INDIGO}] ...${NC}"

    ZIP_ARGS=("${ZIP_OPTIONS[@]}" "${pathEntry}")
    if [ -n "${OUTPUT_DIR}" ]; then
        ZIP_ARGS+=("${OUTPUT_DIR}")
    fi

    if bash "${ZIP_FOLDER_SCRIPT}" "${ZIP_ARGS[@]}"; then
        ZIPPED_COUNT=$((ZIPPED_COUNT + 1))
    else
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_PROJECTS+=("$project")
    fi
done

# Print final summary
echo
if [ $FAILED_COUNT -eq 0 ]; then
    print_success "Zip completed! Zipped ${ZIPPED_COUNT} folder(s), skipped ${SKIPPED_COUNT}."
else
    print_warning "Zip completed with errors. Zipped ${ZIPPED_COUNT} folder(s), failed ${FAILED_COUNT}, skipped ${SKIPPED_COUNT}."
    echo -e "${INDIGO}Failed folders: ${AQUA}${FAILED_PROJECTS[*]}${NC}"
    echo
    exit 1
fi
echo
