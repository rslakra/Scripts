#!/bin/bash
# Author: Rohtash Lakra
# Your local branch is now an exact copy (commits and all) of the remote branch.
REMOTE_BRANCH=$1
echo
echo "Syncing local branch with remote [${REMOTE_BRANCH}] branch ..."
echo
# Validate the parameter provided or not.
if [ -n "${REMOTE_BRANCH}" ]; then
    git fetch origin && git reset --hard origin/$REMOTE_BRANCH && git clean -f -d
else
   echo "Please, provide <REMOTE_BRANCH> name."    
   echo
   echo "Syntax:"
   echo "./syncBranchWithRemote <REMOTE_BRANCH>"
   echo
   echo "./syncBranchWithRemote develop"
   echo
fi
echo

