#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: vstacklet.sh
# @version: 3.1.1086
# @description: This script will download and install the vStacklet server stack
# on your server (this only handles downloading and setting up the vStacklet scripts).
# It will also download and install the vStacklet VS-Perms
# (www-permissions.sh) and VS-Backup (vs-backup) scripts. Please ensure you have
# read the documentation before continuing. You can find documentation on the main
# vStacklet script, the vStacklet server stack, and the vStacklet VS-Perms and
# VS-Backup scripts at the links seen below.
#
# @project_name: vstacklet
#
# @path: /usr/local/bin/vstacklet
#
# @brief: This script is designed to be run on a fresh Ubuntu 20.04/22.04 or
# Debian 11/12 server. I have done my best to keep it tidy and with as much
# error checking as possible. Couple this with loads of comments and you should
# have a pretty good idea of what is going on. If you have any questions,
# comments, or suggestions, please feel free to open an issue on GitHub.
#
# - Documentation is available at: [/docs/](https://github.com/JMSDOnline/vstacklet/tree/main/docs)
#   - :book: [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
#   - :book: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)
#   - :book: [vStacklet VS-Perms (www-permissions.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions.sh.md)
#     - :book: [vStacklet vs-perms (www-permissions-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions-standalone.sh.md)
#   - :book: [vStacklet VS-Backup (vs-backup) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vs-backup.md)
#     - :book: [vStacklet vs-backup (vstacklet-backup-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vstacklet-backup-standalone.sh.md)
#
# vStacklet will install and configure the following:
# - NGinx 1.25.+ (mainline) | 1.18.+ (extras) (HTTP Server)
# - PHP 7.4 (FPM) with common extensions
# - PHP 8.1 (FPM) with common extensions
# - PHP 8.3 (FPM) with common extensions
# - MariaDB 10.11.+ (MySQL Database)
# - Varnish 7.4.x (HTTP Cache)
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
# Copyright (C) 2016-2024, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
# shellcheck disable=SC2068,SC2034,SC1091
################################################################################

##################################################################################
# @name: vstacklet::environment::checkroot (1)
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L66-L71)
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		printf -- "%s\n" "Please run this script as root. Elevate your privileges with (sudo su -) and try again."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::setup::variables (2)
# @description: Set the variables for the setup. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L80-L132)
#
# notes: this script function is responsible for setting the variables for the setup.
# @break
##################################################################################
vstacklet::setup::variables() {
	help="${help:-false}"
	version="${version:-false}"
	while [ $# -gt 0 ]; do
		case "${1}" in
		-V | --version)
			version=true
			shift
			;;
		-h | --help)
			help=true
			shift
			;;
		-b | --branch)
			branch="${2}"
			shift
			shift
			;;
		*)
			printf -- "%s\n" "Invalid argument: ${1}"
			exit 1
			;;
		esac
	done
	# @script-note: Set the necessary declarations
	declare -g vstacklet_base_path vstacklet_setup_path vstacklet_config_path vstacklet_config_php8_path vstacklet_config_php7_path vstacklet_config_hhvm_path vstacklet_config_nginx_path vstacklet_config_varnish_path server_ip server_hostname vstacklet_server_stack_script vstacklet_git vstacklet_git_branch
	# @script-note: Set the vstacklet base path
	vstacklet_base_path="${vstacklet_base_path:-/opt/vstacklet}"
	# @script-note: Set the vstacklet setup path
	vstacklet_setup_path="${vstacklet_setup_path:-${vstacklet_base_path}/setup}"
	# @script-note: Set the vstacklet config path
	vstacklet_config_path="${vstacklet_config_path:-${vstacklet_base_path}/config}"
	# @script-note: Set the vstacklet config php8 path
	vstacklet_config_php8_path="${vstacklet_config_php8_path:-${vstacklet_config_path}/php8}"
	# @script-note: Set the vstacklet config php7 path
	vstacklet_config_php7_path="${vstacklet_config_php7_path:-${vstacklet_config_path}/php7}"
	# @script-note: Set the vstacklet config hhvm path
	vstacklet_config_hhvm_path="${vstacklet_config_hhvm_path:-${vstacklet_config_path}/hhvm}"
	# @script-note: Set the vstacklet config nginx path
	vstacklet_config_nginx_path="${vstacklet_config_nginx_path:-${vstacklet_config_path}/nginx}"
	# @script-note: Set the vstacklet config varnish path
	vstacklet_config_varnish_path="${vstacklet_config_varnish_path:-${vstacklet_config_path}/varnish}"
	# @script-note: Set the IP address of the server
	server_ip="${server_ip:-$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)}"
	# @script-note: Set the hostname of the server
	server_hostname="${server_hostname:-$(hostname --fqdn)}"
	# @script-note: Set the local vstacklet server stack script (this is the script that will be loaded to /usr/local/bin/vstacklet)
	vstacklet_server_stack_script="${vstacklet_base_path}/setup/vstacklet-server-stack.sh"
	# @script-note: Set the vstacklet github repository url
	vstacklet_git="https://github.com/JMSDOnline/vstacklet.git"
	# @script-note: Set the vstacklet github repository branch (default: main)
	vstacklet_git_branch="${vstacklet_git_branch:-${branch:-main}}"
}

################################################################################
# @name: vstacklet::setup::download() (3)
# @description: Setup the environment and download vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L157-L216)
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
vstacklet::setup::download() {
	# @script-note: move to the home directory (as root, this would be `/root`)
	cd "${HOME}" || { printf -- "%s\n" "Error: Unable to move to ${HOME}" && exit 1; }
	# @script-note: run apt update and upgrade (quietly and non-interactive)
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >/dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to run apt-upgrade, please check your apt with 'apt -y update && apt -y upgrade'" && exit 1; }
	# @script-note: install the essential dependencies
	apt-get -yqq install curl sudo wget git apt-transport-https lsb-release dnsutils openssl bc --allow-unauthenticated >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to install script dependencies" && exit 1; }
	# @script-note: adjust .bashrc TERM variable if not set (fixes some issues with nano)
	if ! grep -q "export TERM=xterm" /root/.bashrc; then
		echo -en "export TERM=xterm" >>"/root/.bashrc"
	fi
	# @script-note: source the .bashrc
	source "${HOME}/.bashrc"
	# @script-note: create vstacklet & backup directory strucutre
	mkdir -p /backup/{files,databases} || { printf -- "%s\n" "Error: Unable to create /backup/{files,databases}" && exit 1; }
	# @script-note: download vStacklet
	rm -rf /tmp/vstacklet
	if [[ -d "${vstacklet_base_path}/.git" ]]; then
		# @script-note: update vStacklet
		git clone --quiet --branch "${vstacklet_git_branch}" "${vstacklet_git}" /tmp/vstacklet || { printf -- "%s\n" "Error: Unable to update vStacklet from GitHub" && exit 1; }
		cp -rf /tmp/vstacklet/* "${vstacklet_base_path}" || { printf -- "%s\n" "Error: Unable to copy vStacklet files to ${vstacklet_base_path}" && exit 1; }
		rm -rf /tmp/vstacklet
	else
		# @script-note: install vStacklet
		[[ -d ${vstacklet_base_path} ]] && rm -rf "${vstacklet_base_path}"
		git clone --quiet --branch "${vstacklet_git_branch}" "${vstacklet_git}" "${vstacklet_base_path}" || { printf -- "%s\n" "Error: Unable to clone vStacklet from GitHub" && exit 1; }
	fi
	# @script-note: send vStacklet backup (www-permissions.sh) to /usr/local/bin
	cp -f "${vstacklet_base_path}/bin/www-permissions.sh" "/usr/local/bin/vs-perms" || { printf -- "%s\n" "Error: Unable to copy vs-backup to /usr/local/bin" && exit 1; }
	# @script-note: make vs-perms executable
	chmod +x "/usr/local/bin/vs-perms" || { printf -- "%s\n" "Error: Unable to make vs-perms executable" && exit 1; }
	# @script-note: send vStacklet backup (vs-backup) to /usr/local/bin
	cp -f "${vstacklet_base_path}/bin/backup/vs-backup" "/usr/local/bin/vs-backup" || { printf -- "%s\n" "Error: Unable to copy vs-backup to /usr/local/bin" && exit 1; }
	# @script-note: make vs-backup executable
	chmod +x "/usr/local/bin/vs-backup" || { printf -- "%s\n" "Error: Unable to chmod +x /usr/local/bin/vs-backup" && exit 1; }
	# @script-note: send vStacklet server stack script to /usr/local/bin
	cp -f "${vstacklet_server_stack_script}" "/usr/local/bin/vstacklet" || { printf -- "%s\n" "Error: Unable to copy vstacklet to /usr/local/bin" && exit 1; }
	# @script-note: make vstacklet executable
	chmod +x "/usr/local/bin/vstacklet" || { printf -- "%s\n" "Error: Unable to make the installation script executable." && exit 1; }
	# @script-note: create vstacklet directories
	mkdir -p "${vstacklet_base_path}/setup_temp"    # temporary setup directory - stores default files edited by vStacklet
	mkdir -p "${vstacklet_base_path}/config/system" # system configuration directory - stores dependencies, keys, and other system files
	# @script-note: store the branch in the vstacklet config for future reference and updates
	echo "${vstacklet_git_branch}" >"${vstacklet_base_path}/config/system/branch" || { printf -- "%s\n" "Error: Unable to store the branch in the vstacklet config" && exit 1; }
	# Execute the installation script (let's get this party started!)
	# Allow for the installation script to be run from anywhere on the server
	# by the user through calling `vstacklet [options] [args]`
	# @script-note: display the outro
	echo "The vStacklet installer has been installed on your server."
	echo "You can now run vstacklet from anywhere on your server."
	echo "Please see the documentation for more information."
	echo ""
	echo "Documentation can be found here:"
	echo "https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/setup/vstacklet-server-stack.sh.md"
	echo ""
	echo "You can also run the following command for more information:"
	echo "vstacklet -h"
	echo ""
}

##################################################################################
# @name: vstacklet::setup::help()
# @description: Display the help menu for the setup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L223-L243)
# @break
##################################################################################
vstacklet::setup::help() {
	cat <<EOF
Usage: vstacklet [options] [args]

Options:
  -V, --version   Display the version of vStacklet
  -h, --help      Display this help menu
  -b, --branch    Specify the branch to install from (default: main)

Examples:
  # Install vStacklet from the main branch
  bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh)

  # Install vStacklet from the development branch
  bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh) -b development

  # Display the help menu
  bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh) -h

EOF
}

##################################################################################
# @name: vstacklet::setup::version()
# @description: Display the version of vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L250-L256)
# @break
##################################################################################
vstacklet::version::display() {
	vstacklet_version="$(grep -E '^# @version:' "${vstacklet_base_path}/setup/vstacklet-server-stack.sh" | awk '{print $3}')"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet Version: ${vstacklet_version}"
	# @script-note: display the current branch
	vstacklet::shell::text::white "vStacklet Branch: $(cat "${vstacklet_base_path}"/config/system/branch)"
	vstacklet::shell::misc::nl
	exit 0
}

################################################################################
# @description: Calls functions in required order.
# @break
################################################################################
vstacklet::setup::main() {
	vstacklet::environment::checkroot
	vstacklet::setup::variables "$@"
	[[ "${help}" == "true" ]] && vstacklet::setup::help && exit 0
	[[ "${version}" == "true" ]] && vstacklet::version::display && exit 0
	vstacklet::setup::download
}

# @script-note: call the main function
vstacklet::setup::main "$@"
# @script-note: unset the variables
unset vstacklet_base_path vstacklet_setup_path vstacklet_config_path vstacklet_config_php8_path vstacklet_config_php7_path vstacklet_config_hhvm_path vstacklet_config_nginx_path vstacklet_config_varnish_path server_ip server_hostname vstacklet_git vstacklet_git_branch vstacklet_server_stack_script vstacklet_version help version branch
# @script-note: exit the script
exit 0
