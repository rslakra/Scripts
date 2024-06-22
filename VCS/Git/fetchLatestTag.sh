#!/bin/bash
# Author: Rohtash Lakra
$ tag=$(git describe --tags `git rev-list --tags --max-count=1`)
$ echo $tag
echo
