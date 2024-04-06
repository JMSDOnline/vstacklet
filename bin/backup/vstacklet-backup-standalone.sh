#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: vstacklet-backup-standalone.sh
# @version: 3.1.1147
# @description: This script will grab the latest version of vs-backup and
# install it on your server.
#
# @project_name: vstacklet
#
# @brief: vs-backup can be used on any server to backup files, directories and mysql
# databases, but it is designed to work with the vStacklet server stack.
# This script will backup your database and files.
# Please ensure you have read the documentation before continuing.
#
# - [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
# - [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)
# - [vStacklet VS-Backup Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vs-backup.md)
#
# This script will do the following:
# - Download the latest version of vs-backup.
# - Convert vs-backup shell scripts to executable.
# - Move `vs-backup` to /usr/local/bin for system execution.
# - From there, you can run `vs-backup` from anywhere on your server to do the following:
#   - Backup your database.
#   - Backup your files.
#   - Compress the backup files. (default: tar.gz - for files and sql.gz - for database)
#   - Automatically encrypt the backup files. (password: set to your database password by default - `-dbpass`)
#   - Retain the backup files based on the retention options. (default: 7 days)
#   - see `vs-backup -h` for more information.
#
# @path: bin/backup/vstacklet-backup-standalone.sh
#
# @save_tasks:
#  automated_versioning: true
#  automated_documentation: true
#
# @build_tasks:
#  automated_comment_strip: false
#  automated_encryption: false
#
# @author: Jason Matthews (JMSolo)
# @author_contact: https://github.com/JMSDOnline/vstacklet
#
# @license: MIT License (Included in LICENSE)
# Copyright (C) 2016-2024, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################

################################################################################
# @name: vstacklet::vsbackup::standalone
# @description: This function will download the latest version of vs-backup
# and install it on your server. It will also convert vs-backup shell scripts
# to executable. From there, you can run vs-backup from anywhere on your server.
# [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vstacklet-backup-standalone.sh#L60-L67)
#
# @break
################################################################################
vstacklet::vsbackup::standalone() {
	# @script-note: download the latest version of vs-backup
	curl -s "https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/bin/backup/vs-backup" >/usr/local/bin/vs-backup
	# @script-note: copy the backup script to the /opt/vstacklet/bin/backup directory
	cp -f /usr/local/bin/vs-backup /opt/vstacklet/bin/backup/vs-backup
	# @script-note: convert vs-backup shell scripts to executable
	chmod +x /usr/local/bin/vs-backup /opt/vstacklet/bin/backup/vs-backup
}

################################################################################
# @name: vstacklet::vsbackup::outro
# @description: This function will display the outro. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vstacklet-backup-standalone.sh#L75-L87)
#
# @break
################################################################################
vstacklet::vsbackup::outro() {
	# @script-note: display the outro
	echo "vs-backup has been installed on your server."
	echo "You can now run vs-backup from anywhere on your server."
	echo "Please see the documentation for more information."
	echo ""
	echo "Documentation can be found here:"
	echo "https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vs-backup.md"
	echo ""
	echo "You can also run the following command for more information:"
	echo "vs-backup -h"
	echo ""
}

################################################################################
# @description: Calls functions in required order.
# @break
################################################################################
vstacklet::vsbackup::standalone
vstacklet::vsbackup::outro
