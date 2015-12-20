#!/bin/bash
#start
#-----------------------------------------------------------------------

#verify directory structure exists prior to running this job
backup_files="/backup";
# Where to backup to.
dest="/backup/";

# Create archive filename.
day=$(date +%b-%d-%y);
hostname=$(hostname -s);
additional_code="packaged"
archive_file="$hostname-$day-$additional_code.tgz";

# Print start status message.
  echo "Backing up $backup_files to $dest$archive_file"
  date
  echo

# Backup the files using tar.
  tar -cpzf $dest$archive_file $backup_files;

# Print end status message.
  echo
  echo "Backup finished"
  date

# Long listing of files in $dest to check file sizes.
  ls -lh $dest;
#-----------------------------------------------------------------------
#end