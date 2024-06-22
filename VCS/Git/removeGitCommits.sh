#!/bin/zsh
# Author: Rohtash Lakra
#Deletes the commits up until a specific commit
#https://articles.assembla.com/en/articles/2941346-how-to-delete-commits-from-a-branch-in-git
#
GIT_SHA1_COMMIT_ID=$1
echo
echo "Deletes the commits up until <${GIT_SHA1_COMMIT_ID}> commit."
echo "git reset --hard <${GIT_SHA1_COMMIT_ID}>"
# discard all working tree changes and move HEAD to the commit chosen
git reset --hard $GIT_SHA1_COMMIT_ID
echo
#if you have already pushed your changes you will need to run the following code
git push origin HEAD --force
echo

