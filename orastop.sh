#!/bin/bash
#
# Script to status of the Database and Alert if it is down
# 
. /home/oracle/.profile
ORACLE_SID=test
export ORACLE_SID
hsname=`hostname`

echo "********************************************************"
echo 
echo "Stopping all Oracle Databases & Listener"
echo
echo "*********************************************************"

dbstop ()
{
echo "Stopping Database $1"
$ORACLE_HOME/bin/sqlplus "/ as sysdba" << EOT
    shutdown immediate
    exit
EOT
}

echo 
echo "Step 1: Stopping DB Listener"
echo 
$ORACLE_HOME/bin/lsnrctl stop listener
echo 
echo  
 

# Kill all LOCAL=NO connections
ps -ef | grep "LOCAL=NO" | grep -v grep | awk '{ print $2 }' > /tmp/killoras
echo 
echo 
echo "Step2 : Killing all Oracle Connections"
echo 
echo 

for i in `cat /tmp/killoras`
do
 kill -9 $i
done

cat /etc/oratab | grep -v '#'| cut -f1 -d":" > /tmp/SID_List 
for i in `cat /tmp/SID_List`
do
ORACLE_SID=$i
check_stat=`ps -ef|grep ${ORACLE_SID}|grep pmon`

echo
echo "Step 3: Stopping Databases"
echo
echo 

if [ -z "$check_stat" ]
then
      echo "$ORACLE_SID DB is already down" 
else 
      dbstop $ORACLE_SID
fi
done
rm /tmp/SID_List

