#!/bin/bash
#Author: Rohtash Lakra
# Generates the local links for the major scripts
#
export CUR_DIR="${PWD}"
export USER_HOME="${HOME}"
export WORKSPACE_HOME="${USER_HOME}/Workspace"
export SCRIPTS_HOME="${WORKSPACE_HOME}/Scripts"
export GIT_HOME="${WORKSPACE_HOME}/VCS/Git"
echo
#echo "${WORKSPACE_HOME} not found or is symlink to $(readlink -f ${WORKSPACE_HOME})."

# Check the Workspaces folder is under documents or not.
if [ ! -d "${WORKSPACE_HOME}" -a ! -h "${WORKSPACE_HOME}" ]; then 
    SCRIPTS_HOME="${SCRIPTS_HOME}"
fi
echo "SCRIPTS_HOME: ${SCRIPTS_HOME}"
echo
# Generate Symbolic Links
ln -sf "${GIT_HOME}/removeBranch.sh" ~/removeGitBranch
ln -sf "${GIT_HOME}/syncBranches.sh" ~/syncBranches
ln -sf "${GIT_HOME}/tagBranch.sh" ~/tagGitBranch

# Generate SyncroSVNClient Link
# brew install openjdk@11
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
SYNCRO_SVN_CLIENT_HOME="/Applications/syncroSVNClient"
ln -sf "${SYNCRO_SVN_CLIENT_HOME}/diffDirsMac.sh" ~/diffFolders

# move back to current dir
cd $CUR_DIR
echo

