#!/bin/bash
# Author: Rohtash Lakra
# Creates a zip archive of the specified folder with smart exclusions.
# Usage:
#   ./zipFolder.sh                                    # Zips current directory
#   OR
#   ./zipFolder.sh <folder_path>                     # Zips specified folder
#   OR
#   ./zipFolder.sh <folder_path> <output_path>       # Zips to specified output path
#   OR
#   ./zipFolder.sh [options] <folder_path> [output_path]
#
# Options:
#   --include-node-modules    Include node_modules folder (default: excluded)
#   --timestamp               Create timestamped version
#   --no-exclusions           Don't exclude common build/cache files
#   --help                    Show this help message
clear

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Usage function
usage() {
   echo
   echo -e "${BLUE}Usage:${NC} ./zipFolder.sh [options] [folder_path] [output_path]"
   echo
   echo -e "${YELLOW}Options:${NC}"
   echo "  --include-node-modules    Include node_modules folder (default: excluded)"
   echo "  --timestamp               Create timestamped version"
   echo "  --no-exclusions           Don't exclude common build/cache files"
   echo "  --help                    Show this help message"
   echo
   echo -e "${YELLOW}Arguments:${NC}"
   echo "  folder_path               Folder to zip (default: current directory)"
   echo "  output_path               Output zip file path (default: same directory as folder)"
   echo
   echo -e "${YELLOW}Examples:${NC}"
   echo "  ./zipFolder.sh                                    # Zips current directory"
   echo "  ./zipFolder.sh /path/to/folder                    # Zips specified folder"
   echo "  ./zipFolder.sh /path/to/folder /output/path      # Zips to specified output path"
   echo "  ./zipFolder.sh --include-node-modules .           # Zips current dir with node_modules"
   echo "  ./zipFolder.sh --timestamp /path/to/folder        # Creates timestamped zip"
   echo
}

# Parse command line arguments
EXCLUDE_NODE_MODULES=true
CREATE_TIMESTAMPED=false
USE_EXCLUSIONS=true
FOLDER_PATH=""
OUTPUT_PATH=""

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --include-node-modules)
            EXCLUDE_NODE_MODULES=false
            shift
            ;;
        --timestamp)
            CREATE_TIMESTAMPED=true
            shift
            ;;
        --no-exclusions)
            USE_EXCLUSIONS=false
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            usage
            exit 1
            ;;
        *)
            if [[ -z "$FOLDER_PATH" ]]; then
                FOLDER_PATH="$1"
            elif [[ -z "$OUTPUT_PATH" ]]; then
                OUTPUT_PATH="$1"
            else
                echo -e "${RED}Error: Too many arguments${NC}"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Default to current directory if no folder path is provided
FOLDER_PATH=${FOLDER_PATH:-.}

# Check if folder exists
if [[ ! -d "${FOLDER_PATH}" ]]; then
   echo -e "${RED}Error: Folder '${FOLDER_PATH}' does not exist.${NC}"
   echo
   exit 1
fi

# Get absolute path of the folder
FOLDER_ABS_PATH="$(cd "${FOLDER_PATH}" && pwd)"
FOLDER_NAME="$(basename "${FOLDER_ABS_PATH}")"
FOLDER_PARENT="$(dirname "${FOLDER_ABS_PATH}")"

# Determine output path
if [[ -z "${OUTPUT_PATH}" ]]; then
   # Default: create zip in the same directory as the folder
   OUTPUT_FILE="${FOLDER_NAME}.zip"
   OUTPUT_PATH="${FOLDER_PARENT}/${OUTPUT_FILE}"
else
   # If output path is provided, check if it's a directory or file
   if [[ -d "${OUTPUT_PATH}" ]]; then
      # If it's a directory, create zip file with folder name
      OUTPUT_FILE="${FOLDER_NAME}.zip"
      OUTPUT_PATH="${OUTPUT_PATH}/${OUTPUT_FILE}"
   else
      # If it's a file path, use it as is
      OUTPUT_FILE="$(basename "${OUTPUT_PATH}")"
      OUTPUT_PATH="${OUTPUT_PATH}"
   fi
fi

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}   Folder Zip Archive Creator${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${YELLOW}Folder:${NC} ${FOLDER_ABS_PATH}"
echo -e "${YELLOW}Output:${NC} ${OUTPUT_PATH}"
echo ""

# Change to parent directory for zipping
cd "${FOLDER_PARENT}" || exit 1

# Build exclusion arguments
EXCLUDE_ARGS=()

if [[ "$USE_EXCLUSIONS" == true ]]; then
    # Define common exclusion patterns (always excluded)
    COMMON_EXCLUDES=(
        "*/.DS_Store"
        "*/.git/*"
        "*/.git"
        "*/npm-debug.log*"
        "*/.npm"
        "*/.eslintcache"
        "*/coverage/*"
        "*/.nyc_output/*"
        "*/.vscode/*"
        "*/.idea/*"
        "*.log"
        "*.swp"
        "*.swo"
        "*~"
        "*/__pycache__/*"
        "*/.pyc"
        "*/.pyo"
        "*/venv/*"
        "*/target/*"
        "*/build/*"
        "*/dist/*"
        "*/.pytest_cache/*"
        "*/.mypy_cache/*"
    )
    
    for pattern in "${COMMON_EXCLUDES[@]}"; do
        EXCLUDE_ARGS+=("-x" "$pattern")
    done
    
    # Add node_modules exclusion if needed
    if [[ "$EXCLUDE_NODE_MODULES" == true ]]; then
        EXCLUDE_ARGS+=("-x" "*/node_modules/*")
    fi
    
    if [[ "$EXCLUDE_NODE_MODULES" == true ]]; then
        echo -e "${BLUE}Creating zip archive (excluding node_modules and build artifacts)...${NC}"
        echo -e "${YELLOW}Excluding:${NC} node_modules, .git, .DS_Store, logs, build artifacts, and dev files"
    else
        echo -e "${BLUE}Creating zip archive (including node_modules)...${NC}"
        echo -e "${YELLOW}Including:${NC} node_modules folder (may be large)"
        echo -e "${YELLOW}Excluding:${NC} .git, .DS_Store, logs, and dev files"
    fi
else
    echo -e "${BLUE}Creating zip archive (no exclusions)...${NC}"
    echo -e "${YELLOW}Including:${NC} All files and folders"
fi

echo ""

# Create zip with appropriate exclusions
if [[ ${#EXCLUDE_ARGS[@]} -gt 0 ]]; then
    zip -r "${OUTPUT_PATH}" "${FOLDER_NAME}" "${EXCLUDE_ARGS[@]}" > /dev/null 2>&1
else
    zip -r "${OUTPUT_PATH}" "${FOLDER_NAME}" > /dev/null 2>&1
fi

# Check if zip was successful
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Archive created successfully!${NC}"
    echo ""
    
    # Get file size
    if [[ -f "${OUTPUT_PATH}" ]]; then
        ZIP_SIZE=$(ls -lh "${OUTPUT_PATH}" | awk '{print $5}')
        echo -e "${GREEN}Archive Details:${NC}"
        echo -e "  File: ${YELLOW}${OUTPUT_PATH}${NC}"
        echo -e "  Size: ${YELLOW}${ZIP_SIZE}${NC}"
        echo ""
        
        # List contents (first 20 files)
        echo -e "${BLUE}Archive Contents (first 20 files):${NC}"
        unzip -l "${OUTPUT_PATH}" | head -20
        echo ""
        
        # Count total files
        TOTAL_FILES=$(unzip -l "${OUTPUT_PATH}" | tail -1 | awk '{print $2}')
        if [[ -n "$TOTAL_FILES" ]]; then
            echo -e "${GREEN}Total files in archive: ${TOTAL_FILES}${NC}"
        fi
    fi
    
    # Create timestamped version if requested
    if [[ "$CREATE_TIMESTAMPED" == true ]]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        OUTPUT_DIR="$(dirname "${OUTPUT_PATH}")"
        OUTPUT_BASE="$(basename "${OUTPUT_PATH}" .zip)"
        TIMESTAMPED_PATH="${OUTPUT_DIR}/${OUTPUT_BASE}_${TIMESTAMP}.zip"
        cp "${OUTPUT_PATH}" "${TIMESTAMPED_PATH}"
        echo ""
        echo -e "${GREEN}✓ Timestamped version created: ${TIMESTAMPED_PATH}${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}   ✓ Zip Archive Ready!${NC}"
    echo -e "${GREEN}=================================${NC}"
    
else
    echo -e "${RED}✗ Error creating archive${NC}"
    exit 1
fi

echo ""
