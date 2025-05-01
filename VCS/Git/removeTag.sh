#!/bin/bash
#Author: Rohtash Lakra
echo
tagName=$1
echo "Deleting local tag: ${tagName}"
echo "git tag -d ${tagName}"
git tag -d $tagName
echo
echo "Deleting remote tag: ${tagName}"
echo "git push --delete origin ${tagName}"
git push --delete origin $tagName
echo
