#export JAVA_HOME=$(/usr/libexec/java_home)
export JBOSS_HOME=/Applications/jboss-4.2.3.GA
echo 'JBOSS_HOME='$JBOSS_HOME

echo '----Deleting JBOSS junk dirs----'
echo 'Deleting '$JBOSS_HOME/server/default/log
rm -rf $JBOSS_HOME/server/default/log

echo 'Deleting '$JBOSS_HOME/server/default/tmp
rm -rf $JBOSS_HOME/server/default/tmp

echo 'Deleting '$JBOSS_HOME/server/default/work
rm -rf $JBOSS_HOME/server/default/work

#rm -rf ~/out.log

> ~/out.log


echo '----Starting JBoss----'
nohup $JBOSS_HOME/bin/run.sh -b 0.0.0.0 > ~/out.log &

#$JBOSS_HOME/bin/run.sh -b 0.0.0.0

#tail -f out.log

