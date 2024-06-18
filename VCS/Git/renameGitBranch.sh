#!/bin/bash
clear
oldBranch=$1
newBranch=$2
if [[ -z "${oldBranch}" || -z "${newBranch}" ]]; then
   echo
   echo "This utility renames the existing GIT branch to the new branch. The parameters are mendatory."
   echo "<Old Branch Name>: - The branch to be renamed"
   echo "<New Branch Name>: - The new name of the branch"
   echo
   echo "Syntax:"
   echo "./renameGitBranch <Old Branch Name> <New Branch Name>"
   echo
   echo "For Example:"
   echo "./renameGitBranch feature1 feature2"
   echo "The 'feature1' branch will be renamed to 'feature2'."
   echo
   exit 1;
else
   echo "Renaming GIT branch:'${oldBranch}' to '${newBranch}' ..."
fi

echo
echo "Switching to the local '${oldBranch}' branch, which you want to rename"
git checkout ${oldBranch}
echo "Renaming the local '${oldBranch}' branch with new '${newBranch}' branch name."
git branch -m ${newBranch}
echo "Deleting the '${oldBranch}' remote branch, if it's already pushed to the remote repository"
git push origin --delete ${oldBranch}
echo "Finally, pushing the '${newBranch}' local branch and reset the upstream branch"
git push origin -u ${newBranch}
echo "'${oldBranch}' branch is renamed successfully to '${newBranch}' branch."
echo
