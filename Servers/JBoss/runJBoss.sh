#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Run JBoss Server"
#export JAVA_HOME=$(/usr/libexec/java_home)
export JBOSS_HOME=/Applications/jboss-4.2.3.GA
echo -e "${AQUA}JBOSS_HOME=${NC}${JBOSS_HOME}"

echo -e "${INDIGO}----Deleting JBOSS junk dirs----${NC}"
echo -e "${INDIGO}Deleting ${AQUA}$JBOSS_HOME/server/default/log${NC}"
rm -rf $JBOSS_HOME/server/default/log

echo -e "${INDIGO}Deleting ${AQUA}$JBOSS_HOME/server/default/tmp${NC}"
rm -rf $JBOSS_HOME/server/default/tmp

echo -e "${INDIGO}Deleting ${AQUA}$JBOSS_HOME/server/default/work${NC}"
rm -rf $JBOSS_HOME/server/default/work

#rm -rf ~/out.log

> ~/out.log

echo -e "${INDIGO}----Starting JBoss----${NC}"
nohup $JBOSS_HOME/bin/run.sh -b 0.0.0.0 > ~/out.log &
print_success "JBoss started in background!"
echo

#$JBOSS_HOME/bin/run.sh -b 0.0.0.0

#tail -f out.log

