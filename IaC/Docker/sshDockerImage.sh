#!/bin/bash
# Author: Rohtash Lakra
clear
echo
HOME_DIR=$PWD
IMAGE_ID=${1:-""}
echo

# Usage
usage() {
   echo
   echo "Usage: ~/sshDockerImage <ImageId>"
   echo "Options:"
   echo "ImageId    - ID of a docker image"
   echo
   echo "Example: ~/sshDockerImage 916940ae3b01"
   echo
}

# check which files/folders to remove
if [[ "$#" -eq 1 ]]; then  # No Arguments Supplied
  echo "Accessing ${IMAGE_ID} via SSH"
  docker run --rm -it --entrypoint=/bin/bash $IMAGE_ID
else
  usage
fi
echo