#!/bin/bash
#
# Finds and deletes the files resursively.
#
clear
echo
echo
echo "Deleting the '$1' files ..."
echo
find . -name $1 -delete
echo
