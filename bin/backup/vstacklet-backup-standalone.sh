#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#

#Script Console Colors
normal=$(tput sgr0);
underline=$(tput smul);

sub_title=${bold}${yellow};
repo_title=${black}${on_green};

PROGNAME=${0##*/}
VERSION="0.1"

cat <<EOF
  $PROGNAME ver. $VERSION
  This is a standalone backup utility for vstacklet.
  You do not need VStacklet (full) to use this utility.

  The primary use of this script is for running
  manual backups on user specified directories
  and databases.

  This script will also package your directories
  and databases into one archive and perform a
  backup cleanup.

  Please review the following scripts and make the
  necessary changes to ensure successful backups.

  ${underline}Directory Backup:${normal}
  /root/vstacklet/files-backup.sh

  ${underline}Database Backup:${normal}
  /root/vstacklet/database-backup.sh
EOF

# Create vstacklet & backup directory strucutre
mkdir -p /etc/vstacklet /backup/{directories,databases}
mkdir -p /tmp/vstacklet /tmp/vstacklet/backup/{directories,databases}

# Download the needed scripts for VStacklet
git clone https://github.com/JMSDOnline/vstacklet_packages.git /etc/vstacklet >/dev/null 2>&1;
cd /etc/vstacklet/vstacklet_packages/backup

# Convert all shell scripts to executable
chmod +x *.sh
chmod +x vs-backup

# Move `vs-backup` executable to /usr/local/bin for system execution
if [[ -f /etc/vstacklet/packages/backup/vs-backup ]]; then
  ln -sf /etc/vstacklet/packages/backup/vs-backup /usr/local/bin/vs-backup
  else
  ln -s /etc/vstacklet/packages/backup/vs-backup /usr/local/bin/vs-backup
fi

###############################################################################
echo
echo
echo "VS-Backup is now installed. Please make the needed changes in";
echo "the required files.";
echo
echo "Once changes are perform, you can run the script by simply typing:";
echo "${bold}${green}vs-backup${normal}";
echo
echo
###############################################################################
