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

# Source colors configuration
source "${SCRIPTS_HOME}/colors.sh"

echo
echo -e "${DARKBLUE}=================================${NC}"
echo -e "${DARKBLUE}   Symbolic Link Generator${NC}"
echo -e "${DARKBLUE}=================================${NC}"
echo ""
echo -e "${AQUA}SCRIPTS_HOME:${NC} ${SCRIPTS_HOME}"
echo ""

# ----------------<Generate Symbolic Links>----------------
echo -e "${INDIGO}Generating symbolic links...${NC}"
echo ""

# ----------------<AWS Links>----------------
echo -e "${BLUEVIOLET}AWS Links${NC}"
export AWS_DIR="${SCRIPTS_HOME}/AWS"
ln -fs "${AWS_DIR}/sshInstance.sh" "${USER_HOME}/sshInstance" && echo -e "  ${GREEN}✓${NC} sshInstance"

# ----------------<BuildTools Links>----------------
echo -e "${BLUEVIOLET}BuildTools Links${NC}"
export BUILD_TOOLS="${SCRIPTS_HOME}/BuildTools"
ln -fs "${BUILD_TOOLS}/Homebrew/installHomebrew.sh" "${USER_HOME}/installHomebrew" && echo -e "  ${GREEN}✓${NC} installHomebrew"

# ----------------<Docker Links>----------------
echo -e "${BLUEVIOLET}Docker Links${NC}"
export DOCKER_DIR="${SCRIPTS_HOME}/IaC/Docker"
ln -fs "${DOCKER_DIR}/buildDockerImage.sh" "${USER_HOME}/buildDockerImage" && echo -e "  ${GREEN}✓${NC} buildDockerImage"
ln -fs "${DOCKER_DIR}/listDockerImages.sh" "${USER_HOME}/listDockerImages" && echo -e "  ${GREEN}✓${NC} listDockerImages"
ln -fs "${DOCKER_DIR}/sshDockerImage.sh" "${USER_HOME}/sshDockerImage" && echo -e "  ${GREEN}✓${NC} sshDockerImage"

# ----------------<Git Links>----------------
echo -e "${BLUEVIOLET}Git Links${NC}"
export GIT_DIR="${SCRIPTS_HOME}/VCS/Git"
ln -fs "${GIT_DIR}/addSSHKeys.sh" "${USER_HOME}/addSSHKeys" && echo -e "  ${GREEN}✓${NC} addSSHKeys"
ln -fs "${GIT_DIR}/fixEmailPrivacyRestrictions.sh" "${USER_HOME}/fixEmailPrivacyRestrictions" && echo -e "  ${GREEN}✓${NC} fixEmailPrivacyRestrictions"
ln -fs "${GIT_DIR}/logGitCommits.sh" "${USER_HOME}/logGitCommits" && echo -e "  ${GREEN}✓${NC} logGitCommits"
ln -fs "${GIT_DIR}/removeBranch.sh" "${USER_HOME}/removeGitBranch" && echo -e "  ${GREEN}✓${NC} removeGitBranch"
ln -fs "${GIT_DIR}/removeTag.sh" "${USER_HOME}/removeGitTag" && echo -e "  ${GREEN}✓${NC} removeGitTag"
ln -fs "${GIT_DIR}/removeAllTags.sh" "${USER_HOME}/removeAllGitTags" && echo -e "  ${GREEN}✓${NC} removeAllGitTags"
ln -fs "${GIT_DIR}/setContributors.sh" "${USER_HOME}/setContributors" && echo -e "  ${GREEN}✓${NC} setContributors"
ln -fs "${GIT_DIR}/showCommitGraph.sh" "${USER_HOME}/showCommitGraph" && echo -e "  ${GREEN}✓${NC} showCommitGraph"
ln -fs "${GIT_DIR}/showGitVersionHash.sh" "${USER_HOME}/showGitVersionHash" && echo -e "  ${GREEN}✓${NC} showGitVersionHash"
ln -fs "${GIT_DIR}/syncBranches.sh" "${USER_HOME}/syncBranches" && echo -e "  ${GREEN}✓${NC} syncBranches"
ln -fs "${GIT_DIR}/syncOriginBranches.sh" "${USER_HOME}/syncOriginBranches" && echo -e "  ${GREEN}✓${NC} syncOriginBranches"
ln -fs "${GIT_DIR}/tagBranch.sh" "${USER_HOME}/tagGitBranch" && echo -e "  ${GREEN}✓${NC} tagGitBranch"

# JDK Links
echo -e "${BLUEVIOLET}JDK Links${NC}"
ln -fs "${SCRIPTS_HOME}/Java/jdkSwitch.sh" "${USER_HOME}/jdkSwitch" && echo -e "  ${GREEN}✓${NC} jdkSwitch"

# ----------------<MyOSConfigs Links>----------------
echo -e "${BLUEVIOLET}MyOSConfigs Links${NC}"
export MY_OS_CONFIGS="${SCRIPTS_HOME}/MyOSConfigs"
ln -fs "${MY_OS_CONFIGS}/dotConfigs.sh" "${USER_HOME}/dotConfigs" && echo -e "  ${GREEN}✓${NC} dotConfigs"

# ----------------<OSX Links>----------------
echo -e "${BLUEVIOLET}OSX Links${NC}"
export OSX_DIR="${SCRIPTS_HOME}/OS/OSX"
ln -fs "${OSX_DIR}/checkPortUsage.sh" "${USER_HOME}/checkPortUsage" && echo -e "  ${GREEN}✓${NC} checkPortUsage"
ln -fs "${OSX_DIR}/cleanBuildArtifacts.sh" "${USER_HOME}/cleanBuildArtifacts" && echo -e "  ${GREEN}✓${NC} cleanBuildArtifacts"
ln -fs "${OSX_DIR}/findLargeSizeFiles.sh" "${USER_HOME}/findLargeSizeFiles" && echo -e "  ${GREEN}✓${NC} findLargeSizeFiles"
ln -fs "${OSX_DIR}/installXCode.sh" "${USER_HOME}/installXCode" && echo -e "  ${GREEN}✓${NC} installXCode"
ln -fs "${OSX_DIR}/showComputerName.sh" "${USER_HOME}/showComputerName" && echo -e "  ${GREEN}✓${NC} showComputerName"
ln -fs "${OSX_DIR}/zipFolder.sh" "${USER_HOME}/zipFolder" && echo -e "  ${GREEN}✓${NC} zipFolder"

# ----------------<Variables>----------------

# ----------------<syncroSVNClient Links>----------------
# Generate syncroSVNClient Link
# brew install openjdk@11
# sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
echo -e "${BLUEVIOLET}syncroSVNClient Links${NC}"
SYNCRO_SVN_CLIENT_HOME="${APPS_HOME}/syncroSVNClient"
ln -fs "${SYNCRO_SVN_CLIENT_HOME}/diffDirsMac.sh" "${USER_HOME}/diffFolders" && echo -e "  ${GREEN}✓${NC} diffFolders"

# move back to current dir
cd $CUR_DIR
echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}   ✓ All Links Created!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

