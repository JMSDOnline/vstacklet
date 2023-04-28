#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: www-permissions-standalone.sh
# @version: 3.1.1004
# @description: This script will grab the latest version of vs-perms and
# install it on your server.
#
# @project_name: vstacklet
#
# @brief: vs-perms can be used on any server to backup files, directories and mysql
# databases, but it is designed to work with the vStacklet server stack.
# This script will backup your database and files.
# Please ensure you have read the documentation before continuing.
#
#
# - [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
# - [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
# - [vStacklet www-permissions](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions.sh.md)
#
# This script will do the following:
# - Download the latest version of vs-perms.
# - Convert vs-perms shell scripts to executable.
# - Move `vs-perms` to /usr/local/bin for system execution.
# - From there, you can run `vs-perms` from anywhere on your server to do the following:
#   - Check the www-data group exists, if not, create it.
#   - Check the user group exists, if not, create it.
#   - Check the user exists, if not, create it.
#   - Check the user is a member of the www-data group, if not, add them.
#   - Set the correct permissions for the web root directory.
#   - see `vs-perms -h` for more information.
#
# @path: bin/www-permissions.sh
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
# Copyright (C) 2016-2023, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################

################################################################################
# @name: vstacklet::vsperms::standalone
# @description: This function will download the latest version of vs-perms
# and install it on your server. It will also convert vs-perms shell scripts
# to executable. From there, you can run vs-perms from anywhere on your server.
# [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions-standalone.sh#L60-L65)
#
# @break
################################################################################
vstacklet::vsperms::standalone() {
	# @script-note: download the latest version of vs-perms and move it to /usr/local/bin
	curl -s "https://raw.githubusercontent.com/JMSDOnline/vstacklet/development/bin/www-permissions.sh" >/usr/local/bin/vs-perms
	# @script-note: convert vs-perms shell scripts to executable
	chmod +x /usr/local/bin/vs-perms
}

################################################################################
# @name: vstacklet::vsperms::outro
# @description: This function will display the outro. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions-standalone.sh#L73-L85)
#
# @break
################################################################################
vstacklet::vsperms::outro() {
	# @script-note: display the outro
	echo "vs-perms (www-permissions) has been installed on your server."
	echo "You can now run vs-perms from anywhere on your server."
	echo "Please see the documentation for more information."
	echo ""
	echo "Documentation can be found here:"
	echo "https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions.sh.md"
	echo ""
	echo "You can also run the following command for more information:"
	echo "vs-perms -h"
	echo ""
}

################################################################################
# @description: Calls functions in required order.
# @break
################################################################################
vstacklet::vsperms::standalone
vstacklet::vsperms::outro
