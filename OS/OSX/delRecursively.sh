#!/bin/bash
# Author: Rohtash Lakra
# Removes the spam/unwanted/specified file(s) recursively.
# Usage:
#   ./delRecursively 'fileName'
#   OR
#   ./delRecursively 'fileName'
clear
echo
HOME_DIR=$PWD
echo

# Usage
usage() {
   echo
   echo "Usage: ./delRecursively"
   echo "OR"
   echo "Usage: ./delRecursively 'FileName'"
   echo
}

# files/folders to be removed
listEntries=".DS_Store __pycache__ .pyc .pyo venv target build dist"
# check which files/folders to remove
if [[ -z "$1" ]]; then  # No Arguments Supplied
    for entry in $listEntries; do
        filePath="${HOME_DIR}/${entry}"
        # Folders
        echo "Analyzing '${entry}' under [${HOME_DIR}] ..."
        echo
        if [[ -f "${filePath}" ]]; then # File
          echo "${filePath} is a file."
        elif [[ -d "${filePath}" ]]; then # Folder
          echo "${filePath} is a folder."
        fi
        if [[ "${entry:0:1}" == "." ]]; then
            # Files
            echo "Removing '${entry}' file(s) recursively ..."
            echo
            # find . -type f -name "${entry}" -print -exec echo {} \;
            find . -type f -name "${entry}" -print -exec rm -rf {} \;
            echo
#        elif [[ "${entry:0:2}" == "__" && "${entry:9:11}"  == "__" ]]; then
        elif [[ "${entry}" == "__pycache__" || "${entry}" == "venv" || "${entry}" == "target" ]]; then
            echo "Removing '${entry}' folders recursively ..."
            echo
#            sudo find "${HOME_DIR}" -type d -name "${entry}" -print -exec rm -rf {} \;
            sudo find "${HOME_DIR}" -type d -path "*/${entry}" -print -exec rm -rf {} \;
            # Define the input file
#            TEMP_FILE_PATH="${HOME_DIR}/fileTypes"
#            echo "TEMP_FILE_PATH=${TEMP_FILE_PATH}"
#            find "${HOME_DIR}" -type d -name "${entry}" > $TEMP_FILE_PATH
#            # ls -la "${TEMP_FILE_PATH}"
#            IFS=$'\n' # set the Internal Field Separator to newline
#            # read file contents
#            while read -r filePath; do
#                # printf '%s\n' "$filePath"
#                # check the path contains '/venv'
#                if [[ $filePath != *"${HOME_DIR}/venv"* ]]; then
#                #     # ignore 'venv' folder
#                #     echo "Ignoring [${filePath}] ..."
#                # else
#                    # echo "[${filePath}] ..."
#                    rm -rf "${filePath}"
#                fi
#            done < "$TEMP_FILE_PATH"
#            # remove temp file
#            sudo rm -rf "${TEMP_FILE_PATH}"
        # else
        #     # Folders
        #     echo "Removing '${filePath}' folder ..."
        #     echo
        #     find . -type d -name "${entry}" -print -exec echo {} \;
        #     # find . -type d -name "$1" -print -exec rm -rf {} \;
        #     # find . -type d -depth 4 -name "${entry}" -print;
        #     echo
        fi
    done
elif [ -n "$1" ]; then
    echo "Removing '$1' file(s) recursively ..."
    echo
    #find . -type f -name "$1" -print -exec echo {} \;
    find . -type f -name "$1" -print -exec rm -rf {} \;
fi
echo
