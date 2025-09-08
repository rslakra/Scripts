#!/bin/bash
#Rohtash Lakra
echo
USER_NAME="${1}"
if [ "${USER_NAME}" == "rslakra" ]; then
  ssh-add ~/.ssh/id_ed25519_rslakra
else
  ssh-add ~/.ssh/id_ed25519
fi

echo

