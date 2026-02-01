#!/bin/bash
# Author: Rohtash Lakra
# Generates the local links for the major scripts
# Usage:
#   ./linkGenerator.sh              # Generate all symbolic links
#   ./linkGenerator.sh --remove     # Remove all broken symbolic links in ~
#   ./linkGenerator.sh --soft-links # List all symbolic links in ~

# ----------------< Variables >----------------
export CUR_DIR="${PWD}"
export USER_HOME="${HOME}"
export APPS_HOME="/Applications"

# Bootstrap: Find and source script_utils.sh, then setup environment
# Note: linkGenerator.sh is at the root, so source script_utils.sh from the same directory
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")" && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./linkGenerator.sh${NC}           # Generate all symbolic links"
    echo -e "  ${AQUA}./linkGenerator.sh --remove${NC}  # Remove all broken symbolic links in ~"
    echo -e "  ${AQUA}./linkGenerator.sh --soft-links${NC} # List all symbolic links in ~"
    echo
}

# Function to remove broken symbolic links
remove_broken_links() {
    print_header "Remove Broken Symbolic Links"
    echo -e "${INDIGO}Scanning for broken symbolic links in ${AQUA}${USER_HOME}${INDIGO}...${NC}"
    echo ""
    
    local removed_count=0
    local broken_links=()
    
    # Find all symbolic links in home directory (maxdepth 1, only direct children)
    while IFS= read -r link; do
        if [ -n "$link" ]; then
            # Check if the link is broken (target doesn't exist)
            # Use test -e to check if the resolved target exists
            if [ ! -e "$link" ]; then
                broken_links+=("$link")
            fi
        fi
    done < <(find "$USER_HOME" -maxdepth 1 -type l 2>/dev/null)
    
    if [ ${#broken_links[@]} -eq 0 ]; then
        print_success "No broken symbolic links found!"
        echo
        return 0
    fi
    
    echo -e "${BROWN}Found ${#broken_links[@]} broken symbolic link(s):${NC}"
    echo
    
    # Remove each broken link
    for link in "${broken_links[@]}"; do
        local link_name=$(basename "$link")
        local target=$(readlink "$link" 2>/dev/null || echo "unknown")
        
        echo -e "${BROWN}Removing: ${AQUA}${link_name}${BROWN} -> ${RED}${target}${NC} (broken)"
        rm -f "$link"
        
        if [ $? -eq 0 ]; then
            print_success "Removed: ${link_name}"
            ((removed_count++))
        else
            print_error "Failed to remove: ${link_name}"
        fi
    done
    
    echo
    if [ $removed_count -gt 0 ]; then
        print_success "Removed ${removed_count} broken symbolic link(s)!"
    else
        print_warning "No links were removed"
    fi
    echo
}

# Function to list all symbolic links
list_soft_links() {
    print_header "Symbolic Links in Home Directory"
    echo -e "${INDIGO}Listing all symbolic links in ${AQUA}${USER_HOME}${INDIGO}...${NC}"
    echo ""
    
    local all_links=()
    local total_count=0
    
    # Find all symbolic links in home directory (maxdepth 1, only direct children)
    while IFS= read -r link; do
        if [ -n "$link" ]; then
            all_links+=("$link")
            ((total_count++))
        fi
    done < <(find "$USER_HOME" -maxdepth 1 -type l 2>/dev/null | sort)
    
    if [ $total_count -eq 0 ]; then
        print_warning "No symbolic links found in ${USER_HOME}"
        echo
        return 0
    fi
    
    echo -e "${BROWN}Found ${total_count} symbolic link(s):${NC}"
    echo ""
    
    # Display each link with details
    for link in "${all_links[@]}"; do
        local link_name=$(basename "$link")
        local target=$(readlink "$link" 2>/dev/null || echo "unknown")
        local status=""
        
        # Check if link is broken
        if [ ! -e "$link" ]; then
            status="${RED}(broken)${NC}"
        else
            status="${GREEN}(valid)${NC}"
        fi
        
        # Display in ls -l format
        local link_info=$(ls -ld "$link" 2>/dev/null)
        if [ -n "$link_info" ]; then
            echo -e "${link_info} ${status}"
        else
            echo -e "${AQUA}${link_name}${NC} -> ${BROWN}${target}${NC} ${status}"
        fi
    done
    
    echo
    echo -e "${GREEN}Total: ${AQUA}${total_count}${GREEN} symbolic link(s)${NC}"
    echo
}

# Parse arguments
if [ "$1" == "--remove" ]; then
    remove_broken_links
    exit 0
elif [ "$1" == "--soft-links" ]; then
    list_soft_links
    exit 0
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
elif [ $# -gt 0 ]; then
    print_error "Unknown option: $1"
    usage
    exit 1
fi

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

# ----------------<VCS Links>----------------
export VCS_DIR="${SCRIPTS_HOME}/VCS"
echo -e "${BLUEVIOLET}VCS Links${NC}"

# VCS General Links
ln -fs "${VCS_DIR}/migrate-repository.sh" "${USER_HOME}/migrateRepository" && print_success "migrateRepository"

# ----------------<Git Links>----------------
export GIT_DIR="${VCS_DIR}/Git"
echo -e "${INDIGO}  Git Links${NC}"
ln -fs "${GIT_DIR}/addSSHKeys.sh" "${USER_HOME}/addSSHKeys" && print_success "addSSHKeys"
ln -fs "${GIT_DIR}/fetchTags.sh" "${USER_HOME}/fetchTags" && print_success "fetchTags"
ln -fs "${GIT_DIR}/fixEmailPrivacyRestrictions.sh" "${USER_HOME}/fixEmailPrivacyRestrictions" && print_success "fixEmailPrivacyRestrictions"
ln -fs "${GIT_DIR}/mergeBranches.sh" "${USER_HOME}/mergeBranches" && print_success "mergeBranches"
ln -fs "${GIT_DIR}/removeBranch.sh" "${USER_HOME}/removeBranch" && print_success "removeBranch"
ln -fs "${GIT_DIR}/setGitDetails.sh" "${USER_HOME}/setGitDetails" && print_success "setGitDetails"
ln -fs "${GIT_DIR}/showGitCommits.sh" "${USER_HOME}/showGitCommits" && print_success "showGitCommits"
ln -fs "${GIT_DIR}/showGitConfigs.sh" "${USER_HOME}/showGitConfigs" && print_success "showGitConfigs"
ln -fs "${GIT_DIR}/showGitVersion.sh" "${USER_HOME}/showGitVersion" && print_success "showGitVersion"
ln -fs "${GIT_DIR}/syncBranches.sh" "${USER_HOME}/syncBranches" && print_success "syncBranches"
ln -fs "${GIT_DIR}/tagBranch.sh" "${USER_HOME}/tagGitBranch" && print_success "tagGitBranch"
ln -fs "${GIT_DIR}/tagRemove.sh" "${USER_HOME}/tagRemove" && print_success "tagRemove"

# ----------------<SVN Links>----------------
export SVN_DIR="${VCS_DIR}/SVN"
echo -e "${INDIGO}  SVN Links${NC}"
ln -fs "${SVN_DIR}/makeRepository.sh" "${USER_HOME}/makeRepository" && print_success "makeRepository"

# JDK Links
echo -e "${BLUEVIOLET}JDK Links${NC}"
ln -fs "${SCRIPTS_HOME}/Java/jdkSwitch.sh" "${USER_HOME}/jdkSwitch" && print_success "jdkSwitch"

# ----------------<MyOSConfigs Links>----------------
echo -e "${BLUEVIOLET}MyOSConfigs Links${NC}"
export MY_OS_CONFIGS="${SCRIPTS_HOME}/MyOSConfigs"
ln -fs "${MY_OS_CONFIGS}/dotConfigs.sh" "${USER_HOME}/dotConfigs" && print_success "dotConfigs"

# ----------------<Network Links>----------------
echo -e "${BLUEVIOLET}Network Links${NC}"
export NETWORK_DIR="${SCRIPTS_HOME}/Network"
ln -fs "${NETWORK_DIR}/ipAddress.sh" "${USER_HOME}/ipAddress" && print_success "ipAddress"
ln -fs "${NETWORK_DIR}/portUsage.sh" "${USER_HOME}/portUsage" && print_success "portUsage"

# ----------------<OSX Links>----------------
echo -e "${BLUEVIOLET}OSX Links${NC}"
export OSX_DIR="${SCRIPTS_HOME}/OS/OSX"
ln -fs "${OSX_DIR}/diskCleanup.sh" "${USER_HOME}/diskCleanup" && print_success "diskCleanup"
ln -fs "${OSX_DIR}/findLargeSizeFiles.sh" "${USER_HOME}/findLargeSizeFiles" && print_success "findLargeSizeFiles"
ln -fs "${OSX_DIR}/xcode.sh" "${USER_HOME}/xcode" && print_success "xcode"
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

