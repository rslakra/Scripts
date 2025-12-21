#!/bin/bash
# Author: Rohtash Lakra
# Generates the local links for the major scripts
#

# ----------------< Variables >----------------
export CUR_DIR="${PWD}"
export USER_HOME="${HOME}"
export APPS_HOME="/Applications"

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Symbolic Link Generator"
echo -e "${AQUA}SCRIPTS_HOME:${NC} ${SCRIPTS_HOME}"
echo ""

# ----------------<Generate Symbolic Links>----------------
echo -e "${INDIGO}Generating symbolic links...${NC}"
echo ""

# ----------------<AWS Links>----------------
echo -e "${BLUEVIOLET}AWS Links${NC}"
export AWS_DIR="${SCRIPTS_HOME}/AWS"
ln -fs "${AWS_DIR}/sshInstance.sh" "${USER_HOME}/sshInstance" && print_success "sshInstance"

# ----------------<BuildTools Links>----------------
echo -e "${BLUEVIOLET}BuildTools Links${NC}"
export BUILD_TOOLS="${SCRIPTS_HOME}/BuildTools"
ln -fs "${BUILD_TOOLS}/Homebrew/installHomebrew.sh" "${USER_HOME}/installHomebrew" && print_success "installHomebrew"

# ----------------<Docker Links>----------------
echo -e "${BLUEVIOLET}Docker Links${NC}"
export DOCKER_DIR="${SCRIPTS_HOME}/IaC/Docker"
ln -fs "${DOCKER_DIR}/buildDockerImage.sh" "${USER_HOME}/buildDockerImage" && print_success "buildDockerImage"
ln -fs "${DOCKER_DIR}/listDockerImages.sh" "${USER_HOME}/listDockerImages" && print_success "listDockerImages"
ln -fs "${DOCKER_DIR}/sshDockerImage.sh" "${USER_HOME}/sshDockerImage" && print_success "sshDockerImage"

# ----------------<Git Links>----------------
echo -e "${BLUEVIOLET}Git Links${NC}"
export GIT_DIR="${SCRIPTS_HOME}/VCS/Git"
ln -fs "${GIT_DIR}/addSSHKeys.sh" "${USER_HOME}/addSSHKeys" && print_success "addSSHKeys"
ln -fs "${GIT_DIR}/fixEmailPrivacyRestrictions.sh" "${USER_HOME}/fixEmailPrivacyRestrictions" && print_success "fixEmailPrivacyRestrictions"
ln -fs "${GIT_DIR}/logGitCommits.sh" "${USER_HOME}/logGitCommits" && print_success "logGitCommits"
ln -fs "${GIT_DIR}/removeBranch.sh" "${USER_HOME}/removeGitBranch" && print_success "removeGitBranch"
ln -fs "${GIT_DIR}/removeTag.sh" "${USER_HOME}/removeGitTag" && print_success "removeGitTag"
ln -fs "${GIT_DIR}/removeAllTags.sh" "${USER_HOME}/removeAllGitTags" && print_success "removeAllGitTags"
ln -fs "${GIT_DIR}/setContributors.sh" "${USER_HOME}/setContributors" && print_success "setContributors"
ln -fs "${GIT_DIR}/showCommitGraph.sh" "${USER_HOME}/showCommitGraph" && print_success "showCommitGraph"
ln -fs "${GIT_DIR}/showGitVersionHash.sh" "${USER_HOME}/showGitVersionHash" && print_success "showGitVersionHash"
ln -fs "${GIT_DIR}/syncBranches.sh" "${USER_HOME}/syncBranches" && print_success "syncBranches"
ln -fs "${GIT_DIR}/syncOriginBranches.sh" "${USER_HOME}/syncOriginBranches" && print_success "syncOriginBranches"
ln -fs "${GIT_DIR}/tagBranch.sh" "${USER_HOME}/tagGitBranch" && print_success "tagGitBranch"

# JDK Links
echo -e "${BLUEVIOLET}JDK Links${NC}"
ln -fs "${SCRIPTS_HOME}/Java/jdkSwitch.sh" "${USER_HOME}/jdkSwitch" && print_success "jdkSwitch"

# ----------------<MyOSConfigs Links>----------------
echo -e "${BLUEVIOLET}MyOSConfigs Links${NC}"
export MY_OS_CONFIGS="${SCRIPTS_HOME}/MyOSConfigs"
ln -fs "${MY_OS_CONFIGS}/dotConfigs.sh" "${USER_HOME}/dotConfigs" && print_success "dotConfigs"

# ----------------<OSX Links>----------------
echo -e "${BLUEVIOLET}OSX Links${NC}"
export OSX_DIR="${SCRIPTS_HOME}/OS/OSX"
ln -fs "${OSX_DIR}/checkPortUsage.sh" "${USER_HOME}/checkPortUsage" && print_success "checkPortUsage"
ln -fs "${OSX_DIR}/cleanBuildArtifacts.sh" "${USER_HOME}/cleanBuildArtifacts" && print_success "cleanBuildArtifacts"
ln -fs "${OSX_DIR}/findLargeSizeFiles.sh" "${USER_HOME}/findLargeSizeFiles" && print_success "findLargeSizeFiles"
ln -fs "${OSX_DIR}/installXCode.sh" "${USER_HOME}/installXCode" && print_success "installXCode"
ln -fs "${OSX_DIR}/showComputerName.sh" "${USER_HOME}/showComputerName" && print_success "showComputerName"
ln -fs "${OSX_DIR}/zipFolder.sh" "${USER_HOME}/zipFolder" && print_success "zipFolder"

# ----------------<Variables>----------------

# ----------------<syncroSVNClient Links>----------------
# Generate syncroSVNClient Link
# brew install openjdk@11
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
echo -e "${BLUEVIOLET}syncroSVNClient Links${NC}"
SYNCRO_SVN_CLIENT_HOME="${APPS_HOME}/syncroSVNClient"
ln -fs "${SYNCRO_SVN_CLIENT_HOME}/diffDirsMac.sh" "${USER_HOME}/diffFolders" && print_success "diffFolders"

# move back to current dir
cd $CUR_DIR
print_completed "All Links Created!"

