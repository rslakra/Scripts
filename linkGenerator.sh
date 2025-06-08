#!/bin/bash
# Author: Rohtash Lakra
# Generates the local links for the major scripts
#

# ----------------< Variables >----------------
export CUR_DIR="${PWD}"
export USER_HOME="${HOME}"
export APPS_HOME="/Applications"
export WORKSPACE_HOME="${USER_HOME}/Workspace"
export SCRIPTS_HOME="${WORKSPACE_HOME}/Scripts"

# --------<Tweak Paths, if needed>--------
echo
#echo "${WORKSPACE_HOME} not found or is symlink to $(readlink -f ${WORKSPACE_HOME})."

# Check the Workspaces folder is under documents or not.
if [ ! -d "${WORKSPACE_HOME}" -a ! -h "${WORKSPACE_HOME}" ]; then 
    SCRIPTS_HOME="${WORKSPACE_HOME}/Scripts"
fi
echo "SCRIPTS_HOME: ${SCRIPTS_HOME}"
echo

# ----------------<Generate Symbolic Links>----------------

# ----------------<AWS Links>----------------
export AWS_DIR="${SCRIPTS}/AWS"
ln -fs "${AWS_DIR}/sshInstance.sh" ~/sshInstance

# ----------------<BuildTools Links>----------------
export BUILD_TOOLS="${SCRIPTS}/BuildTools"
ln -fs "${BUILD_TOOLS}/Homebrew/installHomebrew.sh" ~/installHomebrew

# ----------------<Docker Links>----------------
export DOCKER_DIR="${SCRIPTS}/Docker"
ln -fs "${DOCKER_DIR}/buildDockerImage.sh" ~/buildDockerImage
ln -fs "${DOCKER_DIR}/listDockerImages.sh" ~/listDockerImages
ln -fs "${DOCKER_DIR}/sshDockerImage.sh" ~/sshDockerImage

# ----------------<Git Links>----------------
export GIT_DIR="${SCRIPTS_HOME}/VCS/Git"
ln -fs "${GIT_DIR}/addSSHKeys.sh" ~/addSSHKeys
ln -sf "${GIT_DIR}/fixEmailPrivacyRestrictions.sh" ~/fixEmailPrivacyRestrictions
ln -fs "${GIT_DIR}/logGitCommits.sh" ~/logGitCommits
ln -fs "${GIT_DIR}/removeBranch.sh" ~/removeGitBranch
ln -sf "${GIT_DIR}/removeTag.sh" ~/removeGitTag
ln -sf "${GIT_DIR}/removeAllTags.sh" ~/removeAllGitTags
ln -sf "${GIT_DIR}/setContributors.sh" ~/setContributors
ln -sf "${GIT_DIR}/showCommitGraph.sh" ~/showCommitGraph
ln -sf "${GIT_DIR}/showGitVersionHash.sh" ~/showGitVersionHash
ln -fs "${GIT_DIR}/syncBranches.sh" ~/syncBranches
ln -fs "${GIT_DIR}/syncOriginBranches.sh" ~/syncOriginBranches
ln -fs "${GIT_DIR}/tagBranch.sh" ~/tagGitBranch

# JDK Links
ln -sf "${SCRIPTS_HOME}/JDK/jdkSwitch.sh" ~/jdkSwitch

# ----------------<MyOSConfigs Links>----------------
export MY_OS_CONFIGS="${SCRIPTS_HOME}/MyOSConfigs"
ln -fs "${MY_OS_CONFIGS}/backUpLocalConfigs.sh" ~/backUpLocalConfigs

# ----------------<OSX Links>----------------
export OSX_DIR="${SCRIPTS_HOME}/OS/OSX"
ln -fs "${OSX_DIR}/checkPortUsage.sh" ~/checkPortUsage
ln -fs "${OSX_DIR}/delRecursively.sh" ~/delRecursively
ln -sf "${OSX_DIR}/findLargeSizeFiles.sh" ~/findLargeSizeFiles
ln -sf "${OSX_DIR}/installXCode.sh" ~/installXCode
ln -fs "${OSX_DIR}/showComputerName.sh" ~/showComputerName

# ----------------<Variables>----------------

# ----------------<syncroSVNClient Links>----------------
# Generate syncroSVNClient Link
# brew install openjdk@11
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
SYNCRO_SVN_CLIENT_HOME="${APPS_HOME}/syncroSVNClient"
ln -sf "${SYNCRO_SVN_CLIENT_HOME}/diffDirsMac.sh" ~/diffFolders

# move back to current dir
cd $CUR_DIR
echo

