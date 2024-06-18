#!/bin/bash
#Removes the specified file(s) recursively.
clear
echo
#Validate the parameter provided or not.
if [ -n "$1" ]; then
    echo "Removing '$1' file(s) recursively ..."
    echo
    #find . -type f -name "$1" -print -exec echo {} \;
    find . -type f -name "$1" -print -exec rm -rf {} \;    
    echo
else
   echo "Please, provide file name to be deleted recursively."    
   echo
   echo "Usage: ./delFilesRecursively.sh 'FileName'"
   echo
fi

