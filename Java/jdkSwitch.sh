#!/bin/bash
#Author: Rohtash Lakra
# Switches the JDK version
#jdkSwitch         #switches to latest java
#jdkSwitch -v 8    #switches to java 8
#jdkSwitch -v 11   #switches to java 11

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

usage () {
    echo
    echo -e "${DARKBLUE}Switches the JDK version.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./jdkSwitch <version>${NC}"
    echo -e "  ${AQUA}./jdkSwitch -v <version>${NC}"
    echo -e "  ${AQUA}./jdkSwitch --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./jdkSwitch 11${NC}       # Switch to Java 11"
    echo -e "  ${AQUA}./jdkSwitch -v 8${NC}     # Switch to Java 8"
    echo
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

clear
echo
JAVA_HOME_CMD="/usr/libexec/java_home"
# check no. of args
if [ $# -eq 0 ]; then
  usage
  exit 2
elif [ $# -eq 1 ]; then
  JAVA_HOME_CMD="${JAVA_HOME_CMD} -v $@"
else
  JAVA_HOME_CMD="${JAVA_HOME_CMD} $@"
fi

echo -e "${AQUA}JAVA_HOME_CMD:${NC} ${JAVA_HOME_CMD}"
echo
export JAVA_HOME="${JAVA_HOME_CMD}"
echo -e "${GREEN}JAVA_HOME:${NC} $JAVA_HOME"
echo -e "${GREEN}java -version:${NC}"
java -version
echo
