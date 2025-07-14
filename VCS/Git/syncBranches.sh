#!/bin/bash
# Author: Rohtash Lakra
#
CURR_DIR=$PWD
WORKSPACE_DIR="${HOME}/Workspace"
echo
branches="master staging develop"
echo "Syncing ${WORKSPACE_DIR} ..."
echo
folders="tod-admin tod-backend tod-frontend honda-service-call tod-iac Tod-DataService tod-mobile-qa tod-quicksight
tod-readme tod-webhook tod-eks-config backend-e2e-tests tod-iac-hub tod-liquibase mobile-build-config tod-versioning-poc"
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
        git reset --hard
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

