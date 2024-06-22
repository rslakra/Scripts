#Global Variable
export USR_LOCAL_HOME=/usr/local
export OPT_HOME="${USR_LOCAL_HOME}/opt"
export CELLAR_HOME="${USR_LOCAL_HOME}/Cellar"
#export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export JAVA_HOME=`/usr/libexec/java_home -v 11`
export MYSQL_HOME="${OPT_HOME}/mysql"
export RUBY_HOME="${OPT_HOME}/ruby"
export GRADLE_HOME="${CELLAR_HOME}/gradle/7.1"
export MAVEN_HOME="${OPT_HOME}/maven@3.8"
export LDFLAGS="-L${RUBY_HOME}/lib"
export CPPFLAGS="-I${RUBY_HOME}/include"
export TOOLS_HOME=/Applications/Tools
export ANDROID_HOME="${TOOLS_HOME}/Android"
export DEX2JAR_HOME="${TOOLS_HOME}/dex2jar-2.0"
export GROOVY_HOME="${OPT_HOME}/groovy/libexec"
export NODE_HOME="${OPT_HOME}/node@14"
export GRADLE_HOME="${USR_LOCAL_HOME}/bin"

# Set Path
export PATH="${PATH}:${JAVA_HOME}/bin"
export PATH="${PATH}:${MYSQL_HOME}/bin"
export PATH="${PATH}:${RUBY_HOME}/bin"
export PATH="${PATH}:${GRADLE_HOME}/bin"
export PATH="${PATH}:${MAVEN_HOME}/bin"
export PATH="${PATH}:${ANDROID_HOME}"
export PATH="${PATH}:${DEX2JAR_HOME}"
export PATH="${PATH}:${GROOVY_HOME}"
export PATH="${PATH}:${NODE_HOME}/bin"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
