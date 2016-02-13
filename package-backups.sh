#!/bin/bash
#start
#-----------------------------------------------------------------------

green=$(tput setaf 2);
magenta=$(tput setaf 5);
normal=$(tput sgr0);
OK=$(echo -e "[ ${green}DONE${normal} ]")
OUTTO="/root/vs-backup.log"

#verify directory structure exists prior to running this job
PACBfiles="/backup";
# Where to backup to.
PACDest="/";

# Create archive filename.
PACDay=$(date +%b-%d-%y);
PACHostname=$(hostname -s);
additional_code="packaged"
PACAfile="$PACHostname-$PACDay-$additional_code.tgz";

# Print start status message.
  echo -n "Packaging the contents of ${magenta}$PACBfiles${normal} to ${magenta}/backup$PACDest$PACAfile${normal} ... ";
  date >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;

# Backup the files using tar.
  tar -cpzf $PACDest$PACAfile $PACBfiles >>"${OUTTO}" 2>&1 &&
  cd $PACDest
  mv $PACHostname-$PACDay-$additional_code.tgz /backup &&
  cd /root/vstacklet
    echo -n "${OK}"
    echo

# Print end status message.
  echo >>"${OUTTO}" 2>&1;
  echo "Backup finished" >>"${OUTTO}" 2>&1;
  date >>"${OUTTO}" 2>&1;

# Long listing of files in $dest to check file sizes.
  ls -lh $PACBfiles >>"${OUTTO}" 2>&1;
#-----------------------------------------------------------------------
#end