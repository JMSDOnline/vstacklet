#!/bin/bash
#start
#-----------------------------------------------------------------------

# verify directory structure exists prior to running this job
# if you are using the standalone, modify this according to
# your current and/or future directory structures preferred paths
backup_files="/srv/www /etc /root";

# Where to backup to.
dest="/backup/directories/";

# Create archive filename.
day=$(date +%b-%d-%y);
hostname=$(hostname -s);
archive_file="$hostname-$day.tgz";

# Print start status message.
  echo "Backing up $backup_files to $dest$archive_file"
  date
  echo

# Backup the files using tar.
  tar -cpzf $dest$archive_file $backup_files;

# This gets pushed to the vs-backup command
# Print end status message.
# echo
# echo "Backup finished"
# date

# Long listing of files in $dest to check file sizes.
  ls -lh $dest;
#-----------------------------------------------------------------------
#end

# Example Schedule
# Backup Website Files Daily @ 12:45 AM
# 45 00 * * * root /etc/cron.daily/backup-website-files