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
ln -fs "${AWS_DIR}/sshInstance.sh" "${USER_HOME}/sshInstance"

# ----------------<BuildTools Links>----------------
export BUILD_TOOLS="${SCRIPTS_HOME}/BuildTools"
ln -fs "${BUILD_TOOLS}/Homebrew/installHomebrew.sh" "${USER_HOME}/installHomebrew"

# ----------------<Docker Links>----------------
export DOCKER_DIR="${SCRIPTS_HOME}/IaC/Docker"
ln -fs "${DOCKER_DIR}/buildDockerImage.sh" "${USER_HOME}/buildDockerImage"
ln -fs "${DOCKER_DIR}/listDockerImages.sh" "${USER_HOME}/listDockerImages"
ln -fs "${DOCKER_DIR}/sshDockerImage.sh" "${USER_HOME}/sshDockerImage"

# ----------------<Git Links>----------------
export GIT_DIR="${SCRIPTS_HOME}/VCS/Git"
ln -fs "${GIT_DIR}/addSSHKeys.sh" "${USER_HOME}/addSSHKeys"
ln -fs "${GIT_DIR}/fixEmailPrivacyRestrictions.sh" "${USER_HOME}/fixEmailPrivacyRestrictions"
ln -fs "${GIT_DIR}/logGitCommits.sh" "${USER_HOME}/logGitCommits"
ln -fs "${GIT_DIR}/removeBranch.sh" "${USER_HOME}/removeGitBranch"
ln -fs "${GIT_DIR}/removeTag.sh" "${USER_HOME}/removeGitTag"
ln -fs "${GIT_DIR}/removeAllTags.sh" "${USER_HOME}/removeAllGitTags"
ln -fs "${GIT_DIR}/setContributors.sh" "${USER_HOME}/setContributors"
ln -fs "${GIT_DIR}/showCommitGraph.sh" "${USER_HOME}/showCommitGraph"
ln -fs "${GIT_DIR}/showGitVersionHash.sh" "${USER_HOME}/showGitVersionHash"
ln -fs "${GIT_DIR}/syncBranches.sh" "${USER_HOME}/syncBranches"
ln -fs "${GIT_DIR}/syncOriginBranches.sh" "${USER_HOME}/syncOriginBranches"
ln -fs "${GIT_DIR}/tagBranch.sh" "${USER_HOME}/tagGitBranch"

# JDK Links
ln -fs "${SCRIPTS_HOME}/Java/jdkSwitch.sh" "${USER_HOME}/jdkSwitch"

# ----------------<MyOSConfigs Links>----------------
export MY_OS_CONFIGS="${SCRIPTS_HOME}/MyOSConfigs"
ln -fs "${MY_OS_CONFIGS}/dotConfigs.sh" "${USER_HOME}/dotConfigs"

# ----------------<OSX Links>----------------
export OSX_DIR="${SCRIPTS_HOME}/OS/OSX"
ln -fs "${OSX_DIR}/checkPortUsage.sh" "${USER_HOME}/checkPortUsage"
ln -fs "${OSX_DIR}/cleanBuildArtifacts.sh" "${USER_HOME}/cleanBuildArtifacts"
ln -fs "${OSX_DIR}/findLargeSizeFiles.sh" "${USER_HOME}/findLargeSizeFiles"
ln -fs "${OSX_DIR}/installXCode.sh" "${USER_HOME}/installXCode"
ln -fs "${OSX_DIR}/showComputerName.sh" "${USER_HOME}/showComputerName"
ln -fs "${OSX_DIR}/zipFolder.sh" "${USER_HOME}/zipFolder"

# ----------------<Variables>----------------

# ----------------<syncroSVNClient Links>----------------
# Generate syncroSVNClient Link
# brew install openjdk@11
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
SYNCRO_SVN_CLIENT_HOME="${APPS_HOME}/syncroSVNClient"
ln -fs "${SYNCRO_SVN_CLIENT_HOME}/diffDirsMac.sh" "${USER_HOME}/diffFolders"

# move back to current dir
cd $CUR_DIR
echo

