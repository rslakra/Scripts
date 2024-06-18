#!/bin/bash
# Rohtash Lakra
# When the AVD prompts you to place your finger against the sensor, 
# fake a fingerprint touch event by typing the following command into 
# your Terminal window:
# Syntax: -
#./adb -s <emulator-ID> emu finger touch <fingerprint ID>
#
# For Example: -
clear
./adb -s emulator-5554 emu finger touch 1

