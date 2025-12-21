#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Copy JAR"
#set JBOSS_HOME
echo -e "${INDIGO}Setting Environment Variables${NC}"
export JBOSS_HOME=/Applications/JBoss-4.2.3.GA
export JBOSS_HOME_BR=/Applications/JBoss-4.2.3.GA_BlackRock
export JBOSS_DEPLOY_DIR=server/default/deploy
export EAR_NAME=BlackRock.ear

echo
if test -d $JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME; then
echo -e "${GREEN}[${AQUA}$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME${GREEN}] directory exists.${NC}"
else
echo -e "${INDIGO}Creating [${AQUA}$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME${INDIGO}] directory.${NC}"
mkdir $JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME
fi

echo
echo -e "${INDIGO}Copying [${AQUA}$JBOSS_HOME_BR/$JBOSS_DEPLOY_DIR/$EAR_NAME${INDIGO}] to [${AQUA}$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME${INDIGO}]${NC}"
cp -R $JBOSS_HOME_BR/$JBOSS_DEPLOY_DIR/$EAR_NAME $JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME
print_success "JAR copied successfully!"
echo
