#!/bin/zsh
# Author: Rohtash Lakra
echo
echo "Delete remote branch"
echo "git push -d origin $1"
git push -d origin $1
echo
echo "Delete local branch"
echo "git branch -D $1"
git branch -D $1
echo

