#!/bin/bash
# Author: Rohtash Lakra
# Builds docker image with tag and file.
# Usage:
#   ~/buildDockerImage
#
clear

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

echo
HOME_DIR=$PWD
TAG_NAME=${1:-""}
DOCKER_FILE=${2:-"Dockerfile"}
IMAGE_NAME=${3:-"service"}
echo
echo -e "${AQUA}HOME_DIR=${NC}${HOME_DIR}, ${AQUA}TAG_NAME=${NC}${TAG_NAME}, ${AQUA}DOCKER_FILE=${NC}${DOCKER_FILE}"

# Usage
usage() {
   echo
   echo -e "${DARKBLUE}Usage:${NC} ~/buildDockerImage <TagName> <DockerFile>"
   echo -e "${BROWN}Options:${NC}"
   echo -e "  ${AQUA}TagName${NC}    - Tag for the docker image"
   echo -e "  ${AQUA}DockerFile${NC} - Dockerfile for building an image"
   echo
   echo -e "${BROWN}Example:${NC} ~/buildDockerImage ${IMAGE_NAME} infra/be/Dockerfile"
   echo
}

# check which files/folders to remove
if [[ "$#" -eq 2 ]]; then  # No Arguments Supplied
  print_building "${TAG_NAME}"
  docker build -t $TAG_NAME -f $DOCKER_FILE .
  if [[ $? -eq 0 ]]; then
    echo
    print_success "Docker image '${TAG_NAME}' built successfully!"
  else
    echo
    print_failed "Error building docker image '${TAG_NAME}'"
    exit 1
  fi
else
  usage
fi
echo
