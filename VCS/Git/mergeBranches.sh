#!/bin/bash
# Author: Rohtash Lakra
# mergeBranches  # Merges the branches
#

# Usage:
usage () {
    echo
    echo "Usage:"
    echo
    echo -e "\t~/mergeBranches <SOURCE_BRANCH> <TARGET_BRANCH>"
    echo
    echo "Example:"
    echo
    echo -e "\t~/mergeBranches staging develop"
    echo
    exit 2
}

# Branches
SOURCE_BRANCH=$1
TARGET_BRANCH=$2
# check no. of args
if [ $# -eq 0 ]; then
  usage
elif [ $# -le 2 ]; then
  usage
else
  echo
  echo "Merging ${SOURCE_BRANCH} into ${TARGET_BRANCH} ..."
  echo
  git checkout $SOURCE_BRANCH;
  git pull
  git merge --ff-only origin/$TARGET_BRANCH;
  git push;
fi
echo

