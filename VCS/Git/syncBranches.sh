#!/bin/bash
# Author: Rohtash Lakra
#
CURR_DIR=$PWD
WORKSPACE_DIR="${HOME}/Workspace"
echo
branches="master staging develop"
echo "Syncing ${WORKSPACE_DIR} ..."
echo
folders=" "
for entry in $folders
do
  pathEntry="${WORKSPACE_DIR}/${entry}"
  if [[ -d "${pathEntry}" ]]; then
      echo
      echo "Syncing [${pathEntry}] ..."
      echo
      cd "${pathEntry}"
      git reset --hard
      for branch in $branches
      do
#        pathEntry="${WORKSPACE_DIR}/${entry}"
        echo
        echo "Checking out [${branch}] ..."
        echo
#        cd "$entry"
        git checkout "$branch"
        #git reset --hard
        git reset --hard origin/$branch
        git config pull.ff only
        git pull
        echo
      done
      git checkout develop
#      cd ..
      echo
  else
      echo "${pathEntry} is not a directory"
  fi
done
cd $CURR_DIR
echo

