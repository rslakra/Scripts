#!/bin/bash
#Author: Rohtash Lakra
# Tags the branch with given version and message.
# git tag -a v1.4 -m "my version 1.4"
version="$1"
message="$2"
#if [ -z "${version}" ] || [ -z "${message}" ]; then
if [ -z "${version}" ]; then
    echo
    echo "Creates an annotated tag on the GIT branch."
    echo
    echo "Usage:"
    echo
    echo -e "\t~/tagBranch.sh <version> <message>"
    echo
    echo -e "\t<message> is optional"
    echo
    echo "Example:"
    echo
    echo -e "\t~/tagBranch.sh 1.0.0"
    echo
    echo -e "\tOR"
    echo
    echo -e "\t~/tagBranch.sh 1.0.0 \"v1.0.0 ready for production release.\""
    echo
    echo
    exit
fi

if [ -z "${message}" ]; then
  message="v${version} ready for production release."
fi

echo
echo "git tag -a v${version} -m \"${message}\""
git tag -a "v${version}" -m "${message}"
git push origin "v${version}"
echo

