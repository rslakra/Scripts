#!/bin/bash
# Logs only the logs of my app.
# Syntax:
# adb -d logcat <your package name>:<log level> *:S
# -d denotes an actual device, and 
# -e denotes an emulator.
# If there's more than 1 emulator running you can use -s emulator-<emulator number> (eg, -s emulator-5558)
#
# Example:
# adb -d logcat com.rslakra.MyApp:I *:S
#
clear
export PKG_NAME="$1"
adb -d logcat ${PKG_NAME}:D *:S
