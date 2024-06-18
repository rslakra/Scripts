#!/bin/bash
# Author:Rohtash Singh
# macLogcatLogs.sh
# This script is used to capture the logcat logs.
#
clear
adb logcat AndroidRuntime:E *:S
