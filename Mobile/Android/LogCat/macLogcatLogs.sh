#!/bin/bash
# Author:Rohtash Singh
# macLogcatLogs.sh
# This script is used to capture the logcat logs.
#

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Capture Logcat Logs"

# Set ANDROID environment variable
export ANDROID_DIR=/Applications/Android
export ANDROID_HOME=${ANDROID_DIR}/android-sdks
export ADB_HOME=${ANDROID_HOME}/platform-tools

adb=${ANDROID_HOME}/adb
timestamp=$(date +%Y%m%d-%H%M%S);
logFilePath=~/Desktop/App-LogCat-$timestamp.txt;
echo -e "${INDIGO}Log file path: ${AQUA}${logFilePath}${NC}"
$adb logcat -d > ${logFilePath};
$adb logcat -c;
print_success "Logcat logs captured successfully!"
echo
