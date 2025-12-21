#!/bin/bash
# Author: Rohtash Lakra
# Backups the local OS configs into local folder
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# ----------------< Variables >----------------
ARG_TYPE=${1}
CUR_DIR=${PWD}
USER_HOME="${HOME}"
DOT_CONFIGS_HOME="${USER_HOME}/Workspace/Scripts/MyOSConfigs/OSX/DotConfigs"
DOT_AWS_DIR=".aws"
DOT_AWS_HOME="${DOT_CONFIGS_HOME}/${DOT_AWS_DIR}"
DOT_SSH_DIR=".ssh"
DOT_SSH_HOME="${DOT_CONFIGS_HOME}/${DOT_SSH_DIR}"
COMPUTER_NAME=$(eval sudo scutil --get ComputerName)
echo -e "${AQUA}CUR_DIR:${NC} ${CUR_DIR}"
echo -e "${AQUA}USER_HOME:${NC} ${USER_HOME}"
echo -e "${AQUA}DOT_CONFIGS_HOME:${NC} ${DOT_CONFIGS_HOME}"
echo -e "${AQUA}DOT_AWS_HOME:${NC} ${DOT_AWS_HOME}"
echo -e "${AQUA}DOT_SSH_HOME:${NC} ${DOT_SSH_HOME}"
echo -e "${AQUA}COMPUTER_NAME:${NC} ${COMPUTER_NAME}"
echo


# Usage
usage() {
   echo
   echo -e "${DARKBLUE}Usage:${NC}"
   echo -e "./dotConfigs <backup/restore>"
   echo
   echo -e "${BROWN}Example:${NC}"
   echo -e "./dotConfigs backup"
   echo
   echo -e "${BROWN}OR${NC}"
   echo
   echo -e "./dotConfigs restore"
   echo
}

case "${ARG_TYPE}" in
  "backup")
    print_header "Backing up DotConfig files"

    # Check .aws folder exists
    if [ -d "${USER_HOME}/${DOT_AWS_DIR}" ]; then
      echo -e "${INDIGO}Back up ${USER_HOME}/${DOT_AWS_DIR} ...${NC}"
#      cp -R "${USER_HOME}/${DOT_AWS_DIR}" "${DOT_AWS_HOME}/."
      cp "${USER_HOME}/${DOT_AWS_DIR}/config" "${DOT_AWS_HOME}/."
      cp "${USER_HOME}/${DOT_AWS_DIR}/credentials" "${DOT_AWS_HOME}/."
      print_success "AWS config backed up"
    fi

    # Check .ssh folder exists
    if [ -d "${USER_HOME}/${DOT_SSH_DIR}" ]; then
      echo -e "${INDIGO}Back up ${USER_HOME}/${DOT_SSH_DIR} ...${NC}"
      cp "${USER_HOME}/${DOT_SSH_DIR}/config" "${DOT_SSH_HOME}/."
      print_success "SSH config backed up"
    fi

    # Check .git files
    cp -R "${USER_HOME}/.gitconfig" "${USER_HOME}/.gitignore_global" "${DOT_CONFIGS_HOME}/."
    print_success "Git configs backed up"

    # Check .zshrc and .zprofile files
    cp "${USER_HOME}/.zprofile" "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zprofile"
    cp "${USER_HOME}/.zshrc" "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zshrc"
    print_success "Shell configs backed up"

    print_completed "Backup completed!"
    ;;

  "restore")
    print_header "Restoring DotConfig files"
    cp -R "${DOT_AWS_HOME}/." "${USER_HOME}/${DOT_AWS_DIR}"
    cp -R "${DOT_SSH_HOME}/." "${USER_HOME}/${DOT_SSH_DIR}"

    cp -R "${DOT_CONFIGS_HOME}/.gitconfig" "${USER_HOME}/."
    cp -R "${DOT_CONFIGS_HOME}/.gitignore_global" "${USER_HOME}/."

    cp -R "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zprofile" "${USER_HOME}/."
    cp -R "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zshrc" "${USER_HOME}/."

    print_completed "Restore completed!"
    ;;

  *)
    usage
    ;;
esac

echo
