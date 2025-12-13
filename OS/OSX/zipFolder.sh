#!/bin/bash
# Author: Rohtash Lakra
# Creates a zip archive of the specified folder.
# Usage:
#   ./zipFolder.sh                             # Zips current directory
#   OR
#   ./zipFolder.sh <folder_path>               # Creates zip file in the same directory as the folder
#   OR
#   ./zipFolder.sh <folder_path> <output_path> # Creates zip file at the specified output path
clear
echo

# Usage function
usage() {
   echo
   echo "Usage: ./zipFolder.sh [folder_path] [output_path]"
   echo "  folder_path:  Folder to zip (default: current directory)"
   echo "  output_path:  Output zip file path (default: same directory as folder)"
   echo
   echo "Examples:"
   echo "  ./zipFolder.sh                    # Zips current directory"
   echo "  ./zipFolder.sh /path/to/folder     # Zips specified folder"
   echo "  ./zipFolder.sh /path/to/folder /output/path  # Zips to specified output path"
   echo
}

# Default to current directory if no folder path is provided
FOLDER_PATH=${1:-.}
OUTPUT_PATH="$2"

# Check if folder exists
if [[ ! -d "${FOLDER_PATH}" ]]; then
   echo "Error: Folder '${FOLDER_PATH}' does not exist."
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
   OUTPUT_PATH="${FOLDER_PARENT}/${FOLDER_NAME}.zip"
else
   # If output path is provided, check if it's a directory or file
   if [[ -d "${OUTPUT_PATH}" ]]; then
      # If it's a directory, create zip file with folder name
      OUTPUT_PATH="${OUTPUT_PATH}/${FOLDER_NAME}.zip"
   fi
   # If it's a file path, use it as is
fi

echo "Zipping folder: ${FOLDER_ABS_PATH}"
echo "Output file: ${OUTPUT_PATH}"
echo

# Create zip file
cd "${FOLDER_PARENT}"
zip -r "${OUTPUT_PATH}" "${FOLDER_NAME}" -q

if [[ $? -eq 0 ]]; then
   echo "Successfully created: ${OUTPUT_PATH}"
   # Display zip file size
   if [[ -f "${OUTPUT_PATH}" ]]; then
      ZIP_SIZE=$(ls -lh "${OUTPUT_PATH}" | awk '{print $5}')
      echo "Zip file size: ${ZIP_SIZE}"
   fi
else
   echo "Error: Failed to create zip file."
   exit 1
fi

echo

