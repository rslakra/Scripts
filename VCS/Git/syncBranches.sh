#!/bin/bash
# Author: Rohtash Lakra
#
BRANCHES_HOME=$PWD
echo
echo "Syncing ${BRANCHES_HOME} ..."
echo
for entry in "${BRANCHES_HOME}"/*
do
  if [[ -d "$entry" ]]; then
      echo
      echo "$entry"
      cd "$entry"
      git reset --hard
      git config pull.ff only
      git pull
      cd ..
      echo
  #else
  #    echo "$entry is not a directory"
  fi
done
echo

