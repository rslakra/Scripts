#!/bin/bash
# showComputerName.sh
# This script is used to display computer name.
#
clear
echo 'Host Name:'
sudo scutil --get HostName
echo
echo 'Local Host Name:'
sudo scutil --get LocalHostName
echo
echo 'Computer Name:'
sudo scutil --get ComputerName
