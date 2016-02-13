#!/bin/bash
#start
#-----------------------------------------------------------------------
find /backup/databases/ -name '*.gz' | xargs rm -f;
find /backup/directories/ -name '*.tgz' | xargs rm -f;
# Are Weekly Backups Implemented? 
# find /backup/weekly/ -name '*.gz' -mtime +30 | xargs rm -f;
#-----------------------------------------------------------------------
#end

# Example Schedule
# Remove Backups Greater than 7 Days Old Daily @ 01:00 AM
# 00 01 * * * root /etc/cron.daily/backup-cleanup