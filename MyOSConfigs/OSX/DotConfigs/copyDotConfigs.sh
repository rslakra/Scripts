#!/bin/bash
# Author: Rohtash Lakra
# Copies the backup files into the local OS configs
#
cp -R .aws ~/.   
cp -R .ssh ~/.
cp -R .gitconfig .gitignore_global ~/.
