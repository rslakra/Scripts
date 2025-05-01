#!/bin/bash
#Author: Rohtash Lakra
echo
echo "Delete local tag"
echo "git tag -d $1"
git tag -d $1
echo
echo "Delete remove tag"
echo "git push --delete origin $1"
git push --delete origin $1
echo
