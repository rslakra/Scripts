#!/bin/zsh
#git rev-parse --short HEAD
echo v2.0.5-`git rev-parse --short HEAD`-`date +"%Y%m%d-%H%M%S"`
