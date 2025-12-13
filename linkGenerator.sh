#!/bin/bash
# Author: Rohtash Lakra
# Generates the local links for the major scripts
#

# ----------------< Variables >----------------
export CUR_DIR="${PWD}"
export USER_HOME="${HOME}"
export APPS_HOME="/Applications"

# Detect script location and set SCRIPTS_HOME to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_HOME="${SCRIPT_DIR}"

echo
echo "SCRIPTS_HOME: ${SCRIPTS_HOME}"
echo

# ----------------<Generate Symbolic Links>----------------

# ----------------<AWS Links>----------------
export AWS_DIR="${SCRIPTS_HOME}/AWS"
ln -fs "${AWS_DIR}/sshInstance.sh" ~/sshInstance

# ----------------<BuildTools Links>----------------
export BUILD_TOOLS="${SCRIPTS_HOME}/BuildTools"
ln -fs "${BUILD_TOOLS}/Homebrew/installHomebrew.sh" ~/installHomebrew

# ----------------<Docker Links>----------------
export DOCKER_DIR="${SCRIPTS_HOME}/IaC/Docker"
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
ln -sf "${SCRIPTS_HOME}/Java/jdkSwitch.sh" ~/jdkSwitch

# ----------------<MyOSConfigs Links>----------------
export MY_OS_CONFIGS="${SCRIPTS_HOME}/MyOSConfigs"
ln -fs "${MY_OS_CONFIGS}/dotConfigs.sh" ~/dotConfigs

# ----------------<OSX Links>----------------
export OSX_DIR="${SCRIPTS_HOME}/OS/OSX"
ln -fs "${OSX_DIR}/checkPortUsage.sh" ~/checkPortUsage
ln -fs "${OSX_DIR}/cleanBuildArtifacts.sh" ~/cleanBuildArtifacts
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

