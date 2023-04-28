#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: vstacklet.sh
# @version: 3.1.1059
# @description: Lightweight script to quickly install a LEMP stack with Nginx,
# Varnish, PHP7.4/8.1 (PHP-FPM), OPCode Cache, IonCube Loader, MariaDB, Sendmail
# and more on a fresh Ubuntu 18.04/20.04 or Debian 9/10/11 server for
# website-based server applications.
#
# @project_name: vstacklet
#
# @path: /usr/local/bin/vstacklet
#
# @brief: This script is designed to be run on a fresh Ubuntu 18.04/20.04 or
# Debian 9/10/11 server. I have done my best to keep it tidy and with as much
# error checking as possible. Couple this with loads of comments and you should
# have a pretty good idea of what is going on. If you have any questions,
# comments, or suggestions, please feel free to open an issue on GitHub.
#
# - Documentation is available at: [/docs/](https://github.com/JMSDOnline/vstacklet/tree/development/docs)
#   - :book: [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
#   - :book: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
#   - :book: [vStacklet VS-Perms (www-permissions.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions.sh.md)
#     - :book: [vStacklet vs-perms (www-permissions-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions-standalone.sh.md)
#   - :book: [vStacklet VS-Backup (vs-backup) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/backup/vs-backup.md)
#     - :book: [vStacklet vs-backup (vstacklet-backup-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/backup/vstacklet-backup-standalone.sh.md)
#
# vStacklet will install and configure the following:
# - NGinx 1.23.+ (HTTP Server)
# - PHP 7.4 (FPM) with common extensions
# - PHP 8.1 (FPM) with common extensions
# - MariaDB 10.6.+ (MySQL Database)
# - Varnish 7.2.+ (HTTP Cache)
# - CSF 14.+ (Config Server Firewall)
# - and more!
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
# shellcheck disable=SC2068,SC2034,SC1091
################################################################################
# @name: setup::download() (1)
# @description: Setup the environment and download vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet.sh#L78-L148)
#
# notes:
# - This script function is responsible for downloading vStacklet from GitHub
# and setting up the environment for the installation.
#   - VStacklet will be downloaded to `/opt/vstacklet`.
#   - `vstacklet-server-stack.sh` will be loaded to `/usr/local/bin/vstacklet`. This
# will allow you to run `vstacklet [options] [args]` from anywhere on the server.
#   - `vs-backup` will be loaded to `/usr/local/bin/vs-backup`. This
# will allow you to run `vs-backup` from anywhere on the server.
#   - `www-permissions.sh` will be loaded to `/usr/local/bin/vs-perms`. This
# will allow you to run `vs-perms` from anywhere on the server.
# - This script function will also check for the existence of the required
# packages and install them if they are not found.
#   - these include:
#     ```bash
#     curl sudo wget git apt-transport-https lsb-release dnsutils openssl
#     ```
#
# @break
################################################################################
setup::download() {
	whoami=$(whoami)
	declare -g vstacklet_base_path server_ip server_hostname local_setup_dir local_php8_dir local_php7_dir local_hhvm_dir local_varnish_dir
	server_ip=$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
	server_hostname=$(hostname -s)
	# vstacklet directories
	local_setup_dir="${vstacklet_base_path:=/opt/vstacklet}/setup"
	local_php8_dir="/opt/vstacklet/config/php8/"
	local_php7_dir="/opt/vstacklet/config/php7/"
	local_hhvm_dir="/opt/vstacklet/config/hhvm/"
	local_nginx_dir="/opt/vstacklet/config/nginx/"
	local_varnish_dir="/opt/vstacklet/config/varnish/"
	# create vstacklet directories
	mkdir -p "${vstacklet_base_path}/setup_temp"    # temporary setup directory - stores default files edited by vStacklet
	mkdir -p "${vstacklet_base_path}/config/system" # system configuration directory - stores dependencies, keys, and other system files
	local -r vstacklet_server_stack_script="/opt/vstacklet/setup/vstacklet-server-stack.sh"
	local -r vstacklet_git="https://github.com/JMSDOnline/vstacklet.git"
	[[ ${whoami} != "root" ]] && { printf -- "%s\n" "Error: Install as root or via sudo." && exit 1; }
	cd "${HOME}" || { printf -- "%s\n" "Error: Unable to move to ${HOME}" && exit 1; }
	# Run apt update and upgrade
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >/dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to run apt-upgrade, please check your apt with 'apt -y update && apt -y upgrade'" && exit 1; }
	# Install curl, sudo, wget, and git
	apt-get -yqq install curl sudo wget git apt-transport-https lsb-release dnsutils openssl bc --allow-unauthenticated >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to install script dependencies" && exit 1; }
	# Adjust .bashrc TERM
	if ! grep -q "export TERM=xterm" /root/.bashrc; then
		echo -en "export TERM=xterm" >>"/root/.bashrc"
	fi
	source "${HOME}/.bashrc"
	# Create vstacklet & backup directory strucutre
	mkdir -p /backup/{directories,databases} || { printf -- "%s\n" "Error: Unable to create /backup/{directories,databases}" && exit 1; }
	# Download vStacklet
	rm -rf /tmp/vstacklet
	if [[ -d /opt/vstacklet/.git ]]; then
		git clone --quiet --branch "development" "${vstacklet_git}" /tmp/vstacklet || { printf -- "%s\n" "Error: Unable to update vStacklet from GitHub" && exit 1; }
		cp -rf /tmp/vstacklet/* /opt/vstacklet || { printf -- "%s\n" "Error: Unable to copy vStacklet files to /opt/vstacklet" && exit 1; }
		rm -rf /tmp/vstacklet
	else
		# Remove old install script
		[[ -d ${vstacklet_base_path} ]] && rm -rf "${vstacklet_base_path}"
		git clone --quiet --branch "development" "${vstacklet_git}" /opt/vstacklet || { printf -- "%s\n" "Error: Unable to clone vStacklet from GitHub" && exit 1; }
	fi
	# Send vStacklet backup (www-permissions.sh) to /usr/local/bin
	cp -f /opt/vstacklet/bin/www-permissions.sh /usr/local/bin/vs-perms || { printf -- "%s\n" "Error: Unable to copy vs-backup to /usr/local/bin" && exit 1; }
	# Make www-permissions.sh executable
	chmod +x /usr/local/bin/vs-perms || { printf -- "%s\n" "Error: Unable to make vs-perms executable" && exit 1; }
	# Send vStacklet backup (vs-backup) to /usr/local/bin
	cp -f /opt/vstacklet/bin/backup/vs-backup /usr/local/bin/vs-backup || { printf -- "%s\n" "Error: Unable to copy vs-backup to /usr/local/bin" && exit 1; }
	chmod +x /usr/local/bin/vs-backup || { printf -- "%s\n" "Error: Unable to chmod +x /usr/local/bin/vs-backup" && exit 1; }
	# Make the installation script executable
	cp -f "${vstacklet_server_stack_script}" /usr/local/bin/vstacklet || { printf -- "%s\n" "Error: Unable to copy vstacklet to /usr/local/bin" && exit 1; }
	chmod +x /usr/local/bin/vstacklet || { printf -- "%s\n" "Error: Unable to make the installation script executable." && exit 1; }
	# Execute the installation script (let's get this party started!)
	# Allow for the installation script to be run from anywhere on the server
	# by the user through calling `vstacklet [options] [args]`
	#[[ -f "/usr/local/bin/vstacklet" ]] && "/usr/local/bin/vstacklet" "$@" && exit 0
	# @script-note: display the outro
	echo "vstacklet has been installed on your server."
	echo "You can now run vstacklet from anywhere on your server."
	echo "Please see the documentation for more information."
	echo ""
	echo "Documentation can be found here:"
	echo "https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/setup/vstacklet-server-stack.sh.md"
	echo ""
	echo "You can also run the following command for more information:"
	echo "vstacklet -h"
	echo ""
}

setup::download "$@"
exit 0
