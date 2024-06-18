#!/bin/bash
clear
echo
#Validate the parameter provided or not.
if [ -n "$1" ]; then
    echo "Removing Quarantine Flag, if any, of '$1' ..."
    echo
    xattr -dr com.apple.quarantine $1
    echo
else
   echo "Please, provide full path of either app name or root folder name of an application."    
   echo
   echo "Syntax:"
   echo "./removeAuarantineFlag.sh /Applications/AppName.app/"
   echo "OR"
   echo "./removeAuarantineFlag.sh /Applications/FolderName/"
   echo
fi
