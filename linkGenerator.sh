#!/bin/bash
#Author: Rohtash Lakra
# Generates the local links for the major scripts
#

# ----------------< Variables >----------------
export CUR_DIR="${PWD}"
export USER_HOME="${HOME}"
export APPS_HOME="/Applications"
export WORKSPACE_HOME="${USER_HOME}/Workspace"
export SCRIPTS_HOME="${WORKSPACE_HOME}/Scripts"

echo
#echo "${WORKSPACE_HOME} not found or is symlink to $(readlink -f ${WORKSPACE_HOME})."

# Check the Workspaces folder is under documents or not.
if [ ! -d "${WORKSPACE_HOME}" -a ! -h "${WORKSPACE_HOME}" ]; then 
    SCRIPTS_HOME="${WORKSPACE_HOME}/Scripts"
fi
echo "SCRIPTS_HOME: ${SCRIPTS_HOME}"
echo
export GIT_HOME="${SCRIPTS_HOME}/VCS/Git"

# Generate Symbolic Links

# GIT Links
ln -sf "${SCRIPTS_HOME}/GIT/fixEmailPrivacyRestrictions.sh" ~/fixEmailPrivacyRestrictions
ln -sf "${SCRIPTS_HOME}/GIT/removeBranch.sh" ~/removeGitBranch
ln -sf "${SCRIPTS_HOME}/GIT/removeTag.sh" ~/removeGitTag
ln -sf "${SCRIPTS_HOME}/GIT/removeAllTags.sh" ~/removeAllGitTags
ln -sf "${SCRIPTS_HOME}/OSX/resetXCode.sh" ~/resetXCode
ln -sf "${SCRIPTS_HOME}/GIT/setContributors.sh" ~/setContributors
ln -sf "${SCRIPTS_HOME}/GIT/showCommitGraph.sh" ~/showCommitGraph
ln -sf "${SCRIPTS_HOME}/GIT/showGitVersionHash.sh" ~/showGitVersionHash
ln -sf "${SCRIPTS_HOME}/GIT/tagBranch.sh" ~/tagGitBranch

# JDK Links
ln -sf "${SCRIPTS_HOME}/JDK/jdkSwitch.sh" ~/jdkSwitch


# OSX Links
ln -sf "${SCRIPTS_HOME}/OSX/checkPortUsage.sh" ~/checkPortUsage
ln -sf "${SCRIPTS_HOME}/OSX/findLargeSizeFiles.sh" ~/findLargeSizeFiles
ln -sf "${SCRIPTS_HOME}/OSX/installXCode.sh" ~/installXCode


# Generate syncroSVNClient Link
# brew install openjdk@11
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
SYNCRO_SVN_CLIENT_HOME="${APPS_HOME}/syncroSVNClient"
ln -sf "${SYNCRO_SVN_CLIENT_HOME}/diffDirsMac.sh" ~/diffFolders

# move back to current dir
cd $CUR_DIR
echo

