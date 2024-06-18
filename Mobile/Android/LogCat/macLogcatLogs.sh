#!/bin/bash
# Author:Rohtash Singh
# macLogcatLogs.sh
# This script is used to capture the logcat logs.
#
clear

# Set ANDROID environment variable
export ANDROID_DIR=/Applications/Android
export ANDROID_HOME=${ANDROID_DIR}/android-sdks
export ADB_HOME=${ANDROID_HOME}/platform-tools

adb=${ANDROID_HOME}/adb
timestamp=$(date +%Y%m%d-%H%M%S);
logFilePath=~/Desktop/App-LogCat-$timestamp.txt;
echo ${logFilePath};
$adb logcat -d > ${logFilePath};
$adb logcat -c;
