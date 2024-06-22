# Author: Rohtash Lakra
#clear

#Homebew
HOMEBREW_HOME="/opt/homebrew"
CELLAR_HOME="${HOMEBREW_HOME}/Cellar"
HOMEBREW_OPT_HOME="${HOMEBREW_HOME}/opt"

# Python
PYTHON_VER=3.10
PYTHON_HOME="${HOMEBREW_OPT_HOME}/python"
PYTHON_FRAMEWORK="/Library/Frameworks/Python.framework/Versions/${PYTHON_VER}"
#echo

# Evaluate Homebrew shell env
eval "$(/opt/homebrew/bin/brew shellenv)"
#brew -v
#echo

# Java Settings
JAVA_HOME="${HOMEBREW_OPT_HOME}/openjdk@11"
export CPPFLAGS="-I${JAVA_HOME}/include"

# Setting PATH
PATH="${BREW_HOME}:${PATH}"
PATH="${CELLAR_HOME}:${PATH}"
PATH="${HOMEBREW_OPT_HOME}:${PATH}"
PATH="${PYTHON_HOME}/bin:${PYTHON_FRAMEWORK}/bin:${PATH}"
PATH="${JAVA_HOME}/bin:${PATH}"

#echo $PATH
export PATH

