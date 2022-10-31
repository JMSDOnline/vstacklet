#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: vstacklet.sh
# @version: 3.1.1003
# @description: Lightweight script to quickly install a LEMP stack with Nginx,
# Varnish, PHP7.4/8.1 (PHP-FPM), OPCode Cache, IonCube Loader, MariaDB, Sendmail
# and more on a fresh Ubuntu 18.04/20.04 or Debian 9/10/11 server for
# website-based server applications.
#
# @project_name: vstacklet
#
# @brief: This script is designed to be run on a fresh Ubuntu 18.04/20.04 or
# Debian 9/10/11 server. I have done my best to keep it tidy and with as much
# error checking as possible. Couple this with loads of comments and you should
# have a pretty good idea of what is going on. If you have any questions,
# comments, or suggestions, please feel free to open an issue on GitHub.
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
# Copyright (C) 2016-2022, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
# shellcheck disable=SC2068,SC1091
################################################################################

################################################################################
# @name: setup::download
# @description: Setup the environment and download vStacklet
#
# notes:
# - This script function is responsible for downloading vStacklet from GitHub
# and setting up the environment for the installation.
# - This script function will also check for the existence of the required
# packages and install them if they are not found.
# - This script function will additionally call the server stack installation
# and process the given options/flags and arguments.
# - For the various setup options available: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
#
# @option: $1 - the option/flag to process
# @arg: $2 - the value of the option/flag
# @break
################################################################################

setup::download() {
	whoami=$(whoami)
	local -r vstacklet_url="https://github.com/JMSDOnline/vstacklet/raw/development/setup/vstacklet-server-stack.sh"
	local -r vstacklet_path="/usr/local/bin/vstacklet-server-stack"
	[[ ${whoami} != "root" ]] && { printf -- "%s\n" "ERROR: Install as root or via sudo." && exit 1; }
	cd "${HOME}" || { printf -- "%s\n" "Error: Unable to move to ${HOME}" && exit 1; }
	# Remove old install script
	[[ -f ${vstacklet_path} ]] && rm -f "${vstacklet_path}"
	# Adjust .bashrc TERM
	if ! grep -q "export TERM=xterm" /root/.bashrc; then
		echo -en "export TERM=xterm" >>"/root/.bashrc"
	fi
	source "${HOME}/.bashrc"
	# Create vstacklet & backup directory strucutre
	mkdir -p /backup/{directories,databases} /tmp/vstacklet_packages || { printf -- "%s\n" "Error: Unable to create /backup/{directories,databases} /tmp/vstacklet_packages" && exit 1; }
	git clone https://github.com/JMSDOnline/vstacklet_packages.git /tmp/vstacklet_packages || { printf -- "%s\n" "Error: Unable to clone vstacklet_packages" && exit 1; }
	# Send vStacklet backup (vs-backup) to /usr/local/bin
	cp -f /tmp/vstacklet_packages/vs-backup /usr/local/bin/vs-backup || { printf -- "%s\n" "Error: Unable to copy vs-backup to /usr/local/bin" && exit 1; }
	chmod +x /usr/local/bin/vs-backup || { printf -- "%s\n" "Error: Unable to chmod +x /usr/local/bin/vs-backup" && exit 1; }
	# Run apt update and upgrade
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >/dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to run apt-upgrade, please check your apt with 'apt -y update && apt -y upgrade'" && exit 1; }
	# Install curl, sudo, and wget
	apt-get -yqq install curl sudo wget --allow-unauthenticated >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to install wget, sudo, and curl" && exit 1; }
	# Download the installation script
	curl -sSL "${vstacklet_url}" -o "${vstacklet_path}" || { printf -- "%s\n" "Error: Unable to download the installation script." && exit 1; }
	# Make the installation script executable
	chmod +x "${vstacklet_path}" || { printf -- "%s\n" "Error: Unable to make the installation script executable." && exit 1; }
	# Execute the installation script
	[[ -f "${vstacklet_path}" ]] && /"${vstacklet_path}" "$@" && rm -f "${HOME}/vstacklet.sh"
}

setup::download "$@"
exit 1
