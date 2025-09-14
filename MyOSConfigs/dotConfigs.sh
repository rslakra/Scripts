#!/bin/bash
# Author: Rohtash Lakra
# Backups the local OS configs into local folder
#
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
echo "CUR_DIR: ${CUR_DIR}"
echo "USER_HOME: ${USER_HOME}"
echo "DOT_CONFIGS_HOME: ${DOT_CONFIGS_HOME}"
echo "DOT_AWS_HOME: ${DOT_AWS_HOME}"
echo "DOT_SSH_HOME: ${DOT_SSH_HOME}"
echo "COMPUTER_NAME: ${COMPUTER_NAME}"
echo


# Usage
usage() {
   echo
   echo "Usage:"
   echo "./dotConfigs <backup/restore>"
   echo
   echo "Example:"
   echo "./dotConfigs backup"
   echo
   echo "OR"
   echo
   echo "./dotConfigs restore"
   echo
}

case "${ARG_TYPE}" in
  "backup")
    echo "Backing up DotConfig files ..."

    # Check .aws folder exists
    if [ -d "${USER_HOME}/${DOT_AWS_DIR}" ]; then
      echo "Back up ${USER_HOME}/${DOT_AWS_DIR} ..."
#      cp -R "${USER_HOME}/${DOT_AWS_DIR}" "${DOT_AWS_HOME}/."
      cp "${USER_HOME}/${DOT_AWS_DIR}/config" "${DOT_AWS_HOME}/."
      cp "${USER_HOME}/${DOT_AWS_DIR}/credentials" "${DOT_AWS_HOME}/."
    fi

    # Check .ssh folder exists
    if [ -d "${USER_HOME}/${DOT_SSH_DIR}" ]; then
      echo "Back up ${USER_HOME}/${DOT_SSH_DIR} ..."
      cp "${USER_HOME}/${DOT_SSH_DIR}/config" "${DOT_SSH_HOME}/."
    fi

    # Check .git files
    cp -R "${USER_HOME}/.gitconfig" "${USER_HOME}/.gitignore_global" "${DOT_CONFIGS_HOME}/."

    # Check .zshrc and .zprofile files
    cp "${USER_HOME}/.zprofile" "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zprofile"
    cp "${USER_HOME}/.zshrc" "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zshrc"

    ;;
  "restore")
    echo "Restoring DotConfig files ..."
    cp -R "${DOT_AWS_HOME}/." "${USER_HOME}/${DOT_AWS_DIR}"
    cp -R "${DOT_SSH_HOME}/." "${USER_HOME}/${DOT_SSH_DIR}"

    cp -R "${DOT_CONFIGS_HOME}/.gitconfig" "${USER_HOME}/."
    cp -R "${DOT_CONFIGS_HOME}/.gitignore_global" "${USER_HOME}/."

    cp -R "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zprofile" "${USER_HOME}/."
    cp -R "${DOT_CONFIGS_HOME}/${COMPUTER_NAME}.zshrc" "${USER_HOME}/."

    ;;
  *)
    usage
    ;;
esac

echo
