#!/bin/bash
# Author: Rohtash Lakra
# Removes build artifacts and cache files recursively, or a specified file/folder.
# Usage:
#   ./cleanBuildArtifacts.sh                    # Removes default build artifacts
#   OR
#   ./cleanBuildArtifacts.sh 'file or folder name'         # Removes specified file/folder recursively
clear
echo
HOME_DIR=$PWD
echo

# Usage
usage() {
   echo
   echo "Usage: ./cleanBuildArtifacts.sh                    # Removes default build artifacts"
   echo "OR"
   echo "Usage: ./cleanBuildArtifacts.sh 'FileName'         # Removes specified file/folder recursively"
   echo
}

# files/folders to be removed
defaultCleanupEntries=".DS_Store .idea .mvn .pyc .pyo .svn .terraform .tmp .venv __pycache__ bower_components build dist node_modules target venv"
# check which files/folders to remove
if [[ -z "$1" ]]; then  # No Arguments Supplied
    for entry in $defaultCleanupEntries; do
        echo "Removing '${entry}' recursively ..."
        echo
        # Remove both files and folders with the given name
        find . -name "${entry}" -print -exec rm -rf {} \;
        echo
    done
elif [ -n "$1" ]; then
    echo "Removing '$1' recursively ..."
    echo
    # Remove both files and folders with the given name
    find . -name "$1" -print -exec rm -rf {} \;
fi
echo
