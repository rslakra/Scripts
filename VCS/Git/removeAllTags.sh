#!/bin/bash
#Author: Rohtash Lakra

#Delete local tags.
allGitTags=$(git tag -l)
echo
echo "Deleting local tags: ${allGitTags}"
echo "git tag -d ${allGitTags}"
git tag -d $(git tag -l)

#Fetch remote tags.
echo
echo "Fetching remote tags"
echo "git fetch"
git fetch

#Delete remote tags.
echo
echo "Deleting remote tags: ${allGitTags}"
echo "git push origin --delete ${allGitTags}"
git push origin --delete $(git tag -l) # Pushing once should be faster than multiple times

#Delete local tags.
echo
echo "Deleting local tags: ${allGitTags}"
echo "git tag -d ${allGitTags}"
git tag -d $(git tag -l)
echo
