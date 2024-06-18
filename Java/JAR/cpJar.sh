clear
#set JBOSS_HOME
echo Setting Environment Variables
export JBOSS_HOME=/Applications/JBoss-4.2.3.GA
export JBOSS_HOME_BR=/Applications/JBoss-4.2.3.GA_BlackRock
export JBOSS_DEPLOY_DIR=server/default/deploy
export EAR_NAME=BlackRock.ear

echo
if test -d $JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME; then
echo [$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME] directory exist.
else
echo Creating [$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME] directory.
mkdir $JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME
fi

echo
echo Coping [$JBOSS_HOME_BR/$JBOSS_DEPLOY_DIR/$EAR_NAME] to [$JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME
cp -R $JBOSS_HOME_BR/$JBOSS_DEPLOY_DIR/$EAR_NAME $JBOSS_HOME/$JBOSS_DEPLOY_DIR/$EAR_NAME
