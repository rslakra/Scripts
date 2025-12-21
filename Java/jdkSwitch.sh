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
    echo -e "${DARKBLUE}Usage:${NC}"
    echo
    echo -e "\t${AQUA}~/jdkSwitch <version>${NC}"
    echo
    echo -e "\t${BROWN}OR${NC}"
    echo
    echo -e "\t${AQUA}~/jdkSwitch -v <version>${NC}"
    echo
    echo -e "${BROWN}Example:${NC}"
    echo
    echo -e "\t~/jdkSwitch 11"
    echo
    echo -e "\t${BROWN}OR${NC}"
    echo
    echo -e "\t~/jdkSwitch -v 11"
    echo
    exit 2
}

# function to switch jdk version
#jdkSwitch () {
#  export JAVA_HOME=`/usr/libexec/java_home $@`
#  echo "JAVA_HOME:" $JAVA_HOME
#  echo "java -version:"
#  java -version
#}

clear
echo
JAVA_HOME_CMD="/usr/libexec/java_home"
# check no. of args
if [ $# -eq 0 ]; then
  usage
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
