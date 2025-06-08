#!/bin/bash
# Author: Rohtash Lakra
# Builds docker image with tag and file.
# Usage:
#   ~/buildDockerImage
#
clear
echo
HOME_DIR=$PWD
TAG_NAME=${1:-""}
DOCKER_FILE=${2:-"Dockerfile"}
echo
echo "HOME_DIR=${HOME_DIR}, TAG_NAME=${TAG_NAME}, DOCKER_FILE=${DOCKER_FILE}"

# Usage
usage() {
   echo
   echo "Usage: ~/buildDockerImage <TagName> <DockerFile>"
   echo "Options:"
   echo "TagName    - Tag for the docker image"
   echo "DockerFile - Dockerfile for building an image"
   echo
   echo "Example: ~/buildDockerImage tod/be infra/be/Dockerfile"
   echo
}

# check which files/folders to remove
if [[ "$#" -eq 2 ]]; then  # No Arguments Supplied
  docker build -t $TAG_NAME -f $DOCKER_FILE .
else
  usage
fi
echo
