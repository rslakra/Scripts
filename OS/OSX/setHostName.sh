#!/bin/bash
# Author: Rohtash Lakra
# Display Computer Name
#
clear
COMPUTER_NAME=$(sudo scutil --get ComputerName)
# Check .aws folder exists
if [ -z "${COMPUTER_NAME}" ]; then
  COMPUTER_NAME="JG2MVTYWPW"
fi
echo
echo "Set Host Name: ${COMPUTER_NAME}"
echo
sudo scutil --set HostName $COMPUTER_NAME
sudo scutil --set LocalHostName $COMPUTER_NAME
sudo scutil --set ComputerName $COMPUTER_NAME
dscacheutil -flushcache
# Restart your Mac for the changes to fully apply.
# You can also restart directly from the terminal using:
# echo "sudo shutdown -r now".

echo 'Host Name:'
sudo scutil --get HostName
echo
echo 'Local Host Name:'
sudo scutil --get LocalHostName
echo
echo 'Computer Name:'
sudo scutil --get ComputerName
echo
