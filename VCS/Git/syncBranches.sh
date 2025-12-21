#!/bin/bash
# Author: Rohtash Lakra
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

CURR_DIR=$PWD
WORKSPACE_DIR="${HOME}/Workspace"
print_header "Sync Branches"
branches="master staging develop"
echo -e "${INDIGO}Syncing ${AQUA}${WORKSPACE_DIR}${INDIGO} ...${NC}"
echo
folders=" "
for entry in $folders
do
  pathEntry="${WORKSPACE_DIR}/${entry}"
  if [[ -d "${pathEntry}" ]]; then
      echo
      echo -e "${INDIGO}Syncing [${AQUA}${pathEntry}${INDIGO}] ...${NC}"
      echo
      cd "${pathEntry}"
      git reset --hard
      for branch in $branches
      do
#        pathEntry="${WORKSPACE_DIR}/${entry}"
        echo
        echo -e "${INDIGO}Checking out [${AQUA}${branch}${INDIGO}] ...${NC}"
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
      print_warning "${pathEntry} is not a directory"
  fi
done
cd $CURR_DIR
print_success "Sync completed!"
echo

