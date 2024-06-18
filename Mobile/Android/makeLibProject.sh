#!/bin/bash
# Rohtash Lakra
SRC_DIR_PATH=AuthModule
SRC_PKG_NAME=com.rslakra.authmodule
MODULE_NAME=AuthModule
$ANDROID_HOME/tools/android - create lib-project -n "${MODULE_NAME}" -t 1 -k "${SRC_PKG_NAME}" -p "${SRC_DIR_PATH}" -g -v 2.2.0
echo
