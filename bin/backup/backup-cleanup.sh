#!/bin/bash
#start
#-----------------------------------------------------------------------
find /backup/databases/ -name '*.gz' -mtime +3 | xargs rm -f;
find /backup/directories/ -name '*.tgz' -mtime +3 | xargs rm -f;
# Are Weekly Backups Implemented?
# find /backup/weekly/ -name '*.gz' -mtime +30 | xargs rm -f;
#-----------------------------------------------------------------------
#end

# Example Schedule
# Remove Backups Greater than 1 Days Old Daily @ 10:00 PM
# 0 22 * * * root /etc/cron.daily/backup-cleanup
