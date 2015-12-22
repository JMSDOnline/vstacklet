#!/bin/bash
#start
#-----------------------------------------------------------------------
#verify directory structure exists prior to running this job
BackUpDIR="/backup/databases/";
DateStamp=$(date +%b-%d-%y);

#Format of DBList="db1 db2 db3 db4"
DBList="dblist";
#I have a server system administrator account with access to all dbs, typically named sysadmin
DBUser="dbuser";
DBPwd="dbpasswd";

# Print start status message.
# echo "Backing up $DBList to $BackUpDIR"
# date
# echo

for DB in $DBList;
do
mysqldump --opt -u$DBUser -p$DBPwd --add-drop-table --lock-tables --databases $DB > $BackUpDIR$DateStamp.$DB.sql;
  tar zcf "$BackUpDIR$DateStamp.DB.$DB.tar.gz" -P $BackUpDIR$DateStamp.$DB.sql;
  rm -rf $BackUpDIR$DateStamp.$DB.sql;
  mysqldump --opt -u$DBUser -p$DBPwd --add-drop-table --lock-tables $DB > $BackUpDIR$DateStamp.$DB.tbls.sql;
  tar zcf "$BackUpDIR$DateStamp.DB.$DB.tbls.tar.gz" -P $BackUpDIR$DateStamp.$DB.tbls.sql;
  rm -rf $BackUpDIR$DateStamp.$DB.tbls.sql;
done

# This gets pushed to the vs-backup command
# Print end status message.
# echo
# echo "Backup finished"
# date

# Long listing of files in $dest to check file sizes.
  ls -lh $BackUpDIR;
#-----------------------------------------------------------------------
#end

# Example Schedule
# Backup Databases Daily @ 12:30 AM
# 30 00 * * * root /etc/cron.daily/backup-databases