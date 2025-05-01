#!/bin/bash
# Author: Rohtash Lakra
# Removes the spam/unwanted file(s) recursively.
# Usage:
#   ./delRecursively
clear
HOME_DIR=$PWD
# echo
# echo "Analyzing ${HOME_DIR} ..."
echo
fileExtensions=".DS_Store __pycache__"
for entry in $fileExtensions
do
    filePath="${HOME_DIR}/${entry}"
    # Folders
    echo "Analyzing '${entry}' under [${HOME_DIR}] ..."
    echo    
    if [[ "${entry:0:1}" == "." ]]; then
        # Files
        echo "Removing '${entry}' file(s) recursively ..."
        echo
        # find . -type f -name "${entry}" -print -exec echo {} \;
        find . -type f -name "${entry}" -print -exec rm -rf {} \;
        echo
    elif [[ "${entry:0:2}" == "__" ]]; then
        echo "Removing '${entry}' folders recursively ..."
        echo
        # Define the input file
        TEMP_FILE_PATH="${HOME_DIR}/fileTypes"
        find "${HOME_DIR}" -type d -name "${entry}" > $TEMP_FILE_PATH
        # ls -la "${TEMP_FILE_PATH}"
        IFS=$'\n' # set the Internal Field Separator to newline
        # read file contents
        while read -r filePath; do
            # printf '%s\n' "$filePath"
            # check the path contains '/venv'
            if [[ $filePath != *"${HOME_DIR}/venv"* ]]; then
            #     # ignore 'venv' folder
            #     echo "Ignoring [${filePath}] ..."
            # else
                # echo "[${filePath}] ..."
                rm -rf "${filePath}"
            fi
        done < "$TEMP_FILE_PATH"
        # remove temp file
        rm "${TEMP_FILE_PATH}"
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
echo
