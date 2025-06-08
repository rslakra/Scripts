#!/bin/bash
#Rohtash Lakra
echo
USER_NAME="${1}"
if [ "${USER_NAME}" == "rslakra" ]; then
  ssh-add ~/.ssh/id_ed25519_rslakra
elif [ "${USER_NAME}" == "tinker" ]; then
  ssh-add ~/.ssh/id_ed25519
else
  ssh-add ~/.ssh/id_rsa
fi

echo

