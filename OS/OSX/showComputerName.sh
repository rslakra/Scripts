#!/bin/bash
# Author: Rohtash Lakra
# Display Computer Name
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
