#!/bin/bash
# Author: Rohtash Lakra
#clear

#
# ----------------< Global Configs >----------------
#

# ----------------< /Applications >----------------
export APP_DIR="/Applications"
export TOOLS_HOME="${APP_DIR}/Tools"
export ANDROID_HOME="${TOOLS_HOME}/Android"
export DEX2JAR_HOME="${TOOLS_HOME}/dex2jar-2.0"

# /bin
export BIN_DIR="/bin"
# /opt
export OPT_DIR="/opt"
# /usr
export USR_DIR="/usr"
# ----------------< /usr/local >----------------
export USR_LOCAL_DIR="${USR_DIR}/local"
# ----------------< /Library/Frameworks >----------------
export LIB_FWKS_DIR="/Library/Frameworks"

# ----------------< Homebrew Configs >----------------
export HOMEBREW_DIR="${OPT_DIR}/homebrew"
export CELLAR_HOME="${HOMEBREW_DIR}/Cellar"
export HOMEBREW_OPT_DIR="${HOMEBREW_DIR}/opt"
# Evaluate Homebrew shell env
eval "$(/opt/homebrew/bin/brew shellenv)"
#brew -v
#echo


# ----------------< Gradle Configs >----------------
# export GRADLE_HOME="${USR_LOCAL_DIR}/bin"
export GRADLE_HOME="${CELLAR_HOME}/gradle/7.1"

# ----------------< Groovy Configs >----------------
export GROOVY_HOME="${HOMEBREW_OPT_DIR}/groovy/libexec"

# ----------------< Java/JDK Configs >----------------
JDK_VER=11
export JAVA_HOME="${HOMEBREW_OPT_HOME}/openjdk@${JDK_VER}"
export CPPFLAGS="-I${JAVA_HOME}/include"
# export JAVA_HOME=`/usr/libexec/java_home -v 11`

# ----------------< Maven Configs >----------------
export MAVEN_HOME="${HOMEBREW_OPT_DIR}/maven@3.8"

# ----------------< MySQL Configs >----------------
export MYSQL_HOME="${HOMEBREW_OPT_DIR}/mysql"

# ----------------< Node.js Configs >----------------
export NODE_HOME="${HOMEBREW_OPT_DIR}/node@14"

# ----------------< Python Configs >----------------
# $HOMEBREW_PREFIX/opt/python@3.10
# $HOMEBREW_PREFIX/opt/python@3.10/libexec/bin
PYTHON_VER=3.10
# export PYTHON_FRAMEWORK="${LIB_FWKS_DIR}/Python.framework/Versions/${PYTHON_VER}"
# export PYTHON_HOME="${HOMEBREW_OPT_DIR}/python@${PYTHON_VER}"
export PYTHON_HOME="${HOMEBREW_OPT_DIR}/python@${PYTHON_VER}/libexec"
#sudo ln -s -f $(which python3) $(which python)

# ----------------< Ruby Configs >----------------
export RUBY_HOME="${HOMEBREW_OPT_DIR}/ruby"
export LDFLAGS="-L${RUBY_HOME}/lib"
export CPPFLAGS="-I${RUBY_HOME}/include"


# ----------------< Update PATH Variable >----------------
PATH="${PATH}:${APP_DIR}:${TOOLS_HOME}"
PATH="${PATH}:${ANDROID_HOME}:${DEX2JAR_HOME}"
PATH="${PATH}:${OPT_DIR}"
PATH="${PATH}:${USR_LOCAL_DIR}"
PATH="${PATH}:${GRADLE_HOME}/bin"
PATH="${PATH}:${GROOVY_HOME}/bin"
PATH="${PATH}:${JAVA_HOME}/bin"
PATH="${PATH}:${MAVEN_HOME}/bin"
PATH="${PATH}:${MYSQL_HOME}/bin"
PATH="${PATH}:${NODE_HOME}/bin"
PATH="${PATH}:${PYTHON_HOME}/bin"
PATH="${PATH}:${RUBY_HOME}/bin"
#echo $PATH
export PATH


# ----------------< Initialize Ruby Env >----------------
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

