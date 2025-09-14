#!/bin/bash
# Author: Rohtash Lakra
# Free Port Usage
#
echo
PORT=${1:-8080}
PORT=$((PORT))
echo "Free ${PORT} port usage"
#sudo lsof -i ticp:$PORT
sudo lsof -i -P | grep $PORT | awk '{ print $2 }' | sudo xargs kill -9
echo
