#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#

# Create vstacklet & backup directory strucutre
mkdir -p vstacklet /backup/{directories,databases}
cd vstacklet

# Download the needed scripts for VStacklet
curl -LO https://bitbucket.org/JMSDOnline/vstacklet/raw/vstacklet-trusty-stack.sh >/dev/null 2>&1;
curl -LO https://bitbucket.org/JMSDOnline/vstacklet/raw/files-backup.sh >/dev/null 2>&1;
curl -LO https://bitbucket.org/JMSDOnline/vstacklet/raw/database-backup.sh >/dev/null 2>&1;
curl -LO https://bitbucket.org/JMSDOnline/vstacklet/raw/package-backups.sh >/dev/null 2>&1;
curl -LO https://bitbucket.org/JMSDOnline/vstacklet/raw/backup-cleanup.sh >/dev/null 2>&1;

# Convert all shell scripts to executable
chmod +x *.sh
cd

# Download VStacklet System Backup Executable
curl -LO https://bitbucket.org/JMSDOnline/vstacklet/raw/vs-backup >/dev/null 2>&1;
chmod +x vs-backup
mv vs-backup /usr/local/bin

DIR="vstacklet"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/vstacklet-trusty-stack.sh"
