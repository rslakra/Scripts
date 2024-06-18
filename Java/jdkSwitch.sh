#!/bin/bash
#Author: Rohtash Lakra
# Switches the JDK version
#jdkSwitch         #switches to latest java
#jdkSwitch -v 8    #switches to java 8
#jdkSwitch -v 11   #switches to java 11

usage () {
    echo
    echo "Usage:"
    echo
    echo -e "\t~/jdkSwitch <version>"
    echo
    echo -e "\tOR"
    echo
    echo -e "\t~/jdkSwitch -v <version>"
    echo
    echo "Example:"
    echo
    echo -e "\t~/jdkSwitch 11"
    echo
    echo -e "\tOR"
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

echo "JAVA_HOME_CMD: ${JAVA_HOME_CMD}"
echo
export JAVA_HOME="${JAVA_HOME_CMD}"
echo "JAVA_HOME:" $JAVA_HOME
echo "java -version:"
java -version
echo
