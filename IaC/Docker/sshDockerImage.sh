#!/bin/bash
# Author: Rohtash Lakra

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
echo
HOME_DIR=$PWD
IMAGE_ID=${1:-""}
echo

# Usage
usage() {
   echo
   echo -e "${DARKBLUE}Usage:${NC} ~/sshDockerImage <ImageId>"
   echo -e "${BROWN}Options:${NC}"
   echo -e "  ${AQUA}ImageId${NC}    - ID of a docker image"
   echo
   echo -e "${BROWN}Example:${NC} ~/sshDockerImage 916940ae3b01"
   echo
}

# check which files/folders to remove
if [[ "$#" -eq 1 ]]; then  # No Arguments Supplied
  print_header "Docker Image SSH"
  echo -e "${INDIGO}Accessing ${AQUA}${IMAGE_ID}${INDIGO} via SSH${NC}"
  docker run --rm -it --entrypoint=/bin/bash $IMAGE_ID
else
  usage
fi
echo