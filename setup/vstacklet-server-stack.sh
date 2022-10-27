#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 3.1.1202
# @description: Lightweight script to quickly install a LEMP stack with Nginx, 
# Varnish, PHP7.4/8.1 (PHP-FPM), OPCode Cache, IonCube Loader, MariaDB, Sendmail 
# and more on a fresh Ubuntu 18.04/20.04 or
# Debian 9/10/11 server for website-based server applications.
# @project_name: vstacklet
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
# shellcheck disable=1091,2068,2312
# This script is designed to be run on a fresh Ubuntu 18.04/20.04 or
# Debian 9/10/11 server.
# It will install and configure the following:
#   - Nginx
#   - PHP 7.4 (FPM) with common extensions
#   - PHP 8.1 (FPM) with common extensions
#   - MariaDB 10.7
#   - Varnish
#   - CSF Firewall
#   - and more...
################################################################################

##################################################################################
# @name: vstacklet::environment::init
# @description: setup the environment and set variables
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::init() {
	shopt -s extglob
	# first check if we can switch directories
	cd "${HOME}" || setup::clean::rollback 1
	declare -g vstacklet_base_path server_ip server_hostname
	vstacklet_base_path="/etc/vstacklet"
	server_ip=$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
	server_hostname=$(hostname -s)
	# vstacklet directories
	local_setup_dir="/etc/vstacklet/setup/"
	local_php8_dir="/etc/vstacklet/php8/"
	local_php7_dir="/etc/vstacklet/php7/"
	local_hhvm_dir="/etc/vstacklet/hhvm/"
	#local_nginx_dir="/etc/vstacklet/nginx/"
	local_varnish_dir="/etc/vstacklet/varnish/"
	# script console colors
	black=$(tput setaf 0)
	red=$(tput setaf 1)
	green=$(tput setaf 2)
	yellow=$(tput setaf 3)
	magenta=$(tput setaf 5)
	cyan=$(tput setaf 6)
	white=$(tput setaf 7)
	on_green=$(tput setab 2)
	bold=$(tput bold)
	standout=$(tput smso)
	reset_standout=$(tput rmso)
	normal=$(tput sgr0)
	title=${standout}
	repo_title=${black}${on_green}
}

##################################################################################
# @name: vstacklet::args::process
# @description: process the options and values passed to the script
# @option: $1 - the option/flag to process
# @arg: $2 - the value of the option/flag
# @note: This function is required for the installation of
# the vStacklet software.
##################################################################################
# @option: `--help` - show help
# @option: `--version` - show version
# @option: `--non-interactive` - run in non-interactive mode
#
# @option: `-e | --email` - mail address to use for the Let's Encrypt SSL certificate
#
# @option: `-ftp | --ftp_port` - port to use for the FTP server
# @option: `-ssh | --ssh_port` - port to use for the SSH server
# @option: `-http | --http_port` - port to use for the HTTP server
# @option: `-https | --https_port` - port to use for the HTTPS server
#
# @option: `-h | --hostname` - hostname to use for the server
# @option: `-d | --domain` - domain name to use for the server
#
# @option: `-php | --php` - PHP version to install (7.4, 8.1)
# @option: `-mc | --memcached` - install Memcached
# @option: `-hhvm | --hhvm` - install HHVM
#
# @option: `-nginx | --nginx` - install Nginx
#
# @option: `-varnish | --varnish` - install Varnish
# @option: `-varnishP | --varnish_port` - port to use for the Varnish server
#
# @option: `-mariadb | --mariadb` - install MariaDB
# @option: `-mariadbP | --mariadb_port` - port to use for the MariaDB server
# @option: `-mariadbU | --mariadb_user` - user to use for the MariaDB server
# @option: `-mariadbPw | --mariadb-password` - password to use for the MariaDB root user
# 
# @option: `-redis | --redis` - install Redis
# @option: `-postgre | --postgre` - install PostgreSQL
#
# @option: `-pma | --phpmyadmin` - install phpMyAdmin
# @option: `-csf | --csf` - install CSF firewall
# @option: `-sendmail | --sendmail` - install Sendmail
#
# @option: `-wr | --web_root` - the web root directory to use for the server
# @option: `-wp | --wordpress` - install WordPress
#
# @option: `--reboot` - reboot the server after the installation
##################################################################################
# @example: ./vstacklet.sh --help
# @example: ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -h "yourhostname" -d "yourdomain.com" -php 8.1 -mc -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -csf -sendmail -wr "/var/www/html" -wp
# @example: ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -h "yourhostname" -d "yourdomain.com" -hhvm -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -sendmail -wr "/var/www/html" -wp --reboot
# @break
##################################################################################
vstacklet::args::process() {
	while [[ $# -gt 0 ]]; do
		case "${1}" in
		--non-interactive)
			declare -gi non_interactive="1"
			shift
			;;
		--reboot)
			declare -gi setup_reboot="1"
			shift
			;;
		--help)
			script::help::print
			;;
		-csf | --csf)
			declare -gi csf="1"
			shift
			[[ -z ${email} ]] && _error "Please provide an email address to use for the sendmail alias required by CSF." && exit 1
			;;
		-d* | --domain*)
			declare -gi domain_ssl=1
			declare -g domain="${2}"
			shift
			shift
			[[ -n ${domain} && $(echo "${domain}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && vstacklet::clean::rollback 3
			;;
		-e* | --email*)
			declare -g email="${2}"
			shift
			shift
			;;
		-ftp* | --ftp_port*)
			declare -gi ftp_port="${2}"
			shift
			shift
			[[ -n ${ftp_port} && ${ftp_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 4
			[[ -n ${ftp_port} && ${ftp_port} -lt 1 || ${ftp_port} -gt 65535 ]] && _error "Invalid FTP port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 4
			[[ -z ${ftp_port} ]] && declare -gi ftp_port="21"
			;;
		-hhvm | --hhvm)
			declare -gi hhvm="1"
			shift
			;;
		-h* | --hostname*)
			declare -g hostname="${2}"
			shift
			shift
			[[ -n ${hostname} && $(echo "${hostname}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && vstacklet::clean::rollback 5
			[[ -z ${hostname} ]] && declare -g hostname && hostname=$(echo "${server_hostname}" | cut -d. -f1)
			;;
		-mariadb | --mariadb)
			declare -gi mariadb="1"
			shift
			;;
		-mariadbU* | --mariadb_user*)
			declare -g mariadb_user="${2}"
			shift
			shift
			;;
		-mariadbPw* | --mariadb_password*)
			declare -g mariadb_password="${2}"
			shift
			shift
			[[ -n ${mariadb_password} && ${#mariadb_password} -lt 8 ]] && _error "The MariaDB password must be at least 8 characters long." && vstacklet::clean::rollback 6
			;;
		-mariadbP* | --mariadb_port*)
			declare -gi mariadb_port="${2}"
			shift
			shift
			[[ -n ${mariadb_port} && ${mariadb_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 7
			[[ -n ${mariadb_port} && ${mariadb_port} -lt 1 || ${mariadb_port} -gt 65535 ]] && _error "Invalid MariaDB port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 7
			[[ -z ${mariadb_port} ]] && declare -gi mariadb_port="3306"
			;;
		-mc | --memcached)
			declare -gi memcached="1"
			shift
			;;
		-mysql | --mysql)
			declare -gi mysql="1"
			shift
			;;
		-mysqlU* | --mysql_user*)
			declare -g mysql_user="${2}"
			shift
			shift
			;;
		-mysqlPw* | --mysql_password*)
			declare -g mysql_password="${2}"
			shift
			shift
			[[ -n ${mysql_password} && ${#mysql_password} -lt 8 ]] && _error "The MySQL password must be at least 8 characters long." && vstacklet::clean::rollback 8
			;;
		-mysqlP* | --mysql_port*)
			declare -gi mysql_port="${2}"
			shift
			shift
			[[ -n ${mysql_port} && ${mysql_port} != ?(-)+([0-9]) ]] && _error "The MySQL port must be a number." && vstacklet::clean::rollback 9
			[[ -n ${mysql_port} && ${mysql_port} -lt 1 || ${mysql_port} -gt 65535 ]] && _error "Invalid MySQL port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 9
			[[ -z ${mysql_port} ]] && declare -gi mysql_port="3306"
			;;
		-nginx | --nginx)
			declare -gi nginx="1"
			shift
			;;
		-postgre | --postgre)
			declare -gi postgre="1"
			shift
			;;
		-pma | --phpmyadmin)
			declare -gi phpmyadmin="1"
			shift
			;;
		-php* | --php*)
			declare -gi php_set="1"
			declare -gi php="${2}"
			shift
			shift
			[[ -n ${php} && ${php} != "7" && ${php} != "8" && ${php} != "7.4" && ${php} != "8.1"  ]] && _error "Invalid PHP version. Please enter either 7 (7.4), or 8 (8.4)." && vstacklet::clean::rollback 10
			[[ -n ${php} && ${php} -lt 1 || ${php} -gt 9 ]] && _error "Invalid PHP version. Please enter a number between 1 and 9." && vstacklet::clean::rollback 10
			[[ ${php} == *"7"* ]] && declare -gi php="7.4"
			[[ ${php} == *"8"* ]] && declare -gi php="8.1"
			[[ -z ${php} ]] && declare -gi php="8.1"
			;;
		-ioncube | --ioncube)
			declare -gi ioncube="1"
			shift
			;;
		-https* | --https_port*)
			declare -gi https_port="${2}"
			shift
			shift
			[[ -n ${https_port} && ${https_port} != ?(-)+([0-9]) ]] && _error "The HTTPS port must be a number." && vstacklet::clean::rollback 11
			[[ -n ${https_port} && ${https_port} -lt 1 || ${https_port} -gt 65535 ]] && _error "Invalid HTTPS port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 11
			[[ -z ${https_port} ]] && declare -gi https_port="443"
			;;
		-http* | --http_port*)
			declare -gi http_port="${2}"
			shift
			shift
			[[ -n ${http_port} && ${http_port} != ?(-)+([0-9]) ]] && _error "The HTTP port must be a number." && vstacklet::clean::rollback 12
			[[ -n ${http_port} && ${http_port} -lt 1 || ${http_port} -gt 65535 ]] && _error "Invalid HTTP port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 12
			[[ -z ${http_port} ]] && declare -gi http_port="80"
			;;
		-redis | --redis)
			declare -gi redis="1"
			shift
			;;
		-sendmail | --sendmail)
			declare -gi sendmail="1"
			shift
			[[ -z ${email} ]] && _error "An email is needed to register the server aliases.
Please set an email with ' -e your@email.com '" && vstacklet::clean::rollback 13
			;;
		-ssh* | --ssh_port*)
			declare -gi ssh_port="${2}"
			shift
			shift
			[[ -n ${ssh_port} && ${ssh_port} != ?(-)+([0-9]) ]] && _error "The SSH port must be a number." && vstacklet::clean::rollback 14
			[[ -n ${ssh_port} && ${ssh_port} -lt 1 || ${ssh_port} -gt 65535 ]] && _error "Invalid SSH port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 14
			[[ -z ${ssh_port} ]] && declare -gi ssh_port="22"
			;;
		-varnish | --varnish)
			declare -gi varnish="1"
			shift
			;;
		-varnishP* | --varnish_port*)
			declare -gi varnish_port="${2}"
			shift
			shift
			[[ -n ${varnish_port} && ${varnish_port} != ?(-)+([0-9]) ]] && _error "The Varnish port must be a number." && vstacklet::clean::rollback 15
			[[ -n ${varnish_port} && ${varnish_port} -lt 1 || ${varnish_port} -gt 65535 ]] && _error "Invalid Varnish port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 15
			[[ -z ${varnish_port} ]] && declare -gi varnish_port=6081
			;;
		-wr* | --web_root*)
			declare -g web_root="${2}"
			shift
			shift
			[[ -n ${web_root} && $(sed -e 's/[\\/]/\\/g;s/[\/\/]/\\\//g;' <<<"${web_root}") == "" ]] && _error "Invalid web root. Please enter a valid path. (ex: /var/www/html)" && vstacklet::clean::rollback 16
			[[ -z ${web_root} ]] && declare -g web_root="/var/www/html"
			;;
		-wp | --wordpress)
			declare -gi wordpress="1"
			shift
			;;
		*)
			invalid_option+=("$1")
			shift
			;;
		esac
	done
	[[ ${#invalid_option[@]} -gt 0 ]] && vstacklet::clean::rollback 9
}

##################################################################################
# @name: vstacklet::environment::functions
# @description: stage various functions for the setup environment
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::functions() {
	_warn() {
		echo "${bold}${red}WARNING: ${normal}${white}$1${normal}"
	}
	_success() {
		echo "${bold}${green}SUCCESS: ${normal}${white}$1${normal}"
	}
	_info() {
		echo "${bold}${cyan}INFO: ${normal}${white}$1${normal}"
	}
	_error() {
		echo "${bold}${red}ERROR: ${normal}${white}$1${normal}"
	}
	vstacklet::array::contains() {
		if [[ $# -lt 2 ]]; then
			_result=2
			_warn "[${_result}]: ${FUNCNAME[0]} is missing arguments for ${_named_array}"
		fi
		declare _named_array="$2"
		declare _value="$1"
		shift
		declare -a _array=("$@")
		local _result=1
		for _element in "${_array[@]}"; do
			if [[ ${_element} == "${_value}" ]]; then
				_result=0
				_success "[${_result}]: ${_named_array} array contains ${_value}"
				break
			fi
		done
		[[ ${_result} == "1" ]] && _warn "[${_result}]: ${_named_array} array does not contain ${_value}"
		return "${_result}"
	}
}

##################################################################################
# @name: vstacklet::environment::checkroot
# @description: check if the user is root
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::checkroot() {
	declare -g codename distro
	declare -a allowed_codename=("bionic" "focal" "stretch" "buster" "bullseye")
	codename=$(lsb_release -cs)
	distro=$(lsb_release -is)
	if ! vstacklet::array::contains "${codename}" "supported distro" ${allowed_codename[@]}; then
		declare allowed_codename_string="${allowed_codename[*]}"
		echo "supported distros: "
		echo "${allowed_codename_string//${IFS:0:1}/, }"
		vstacklet::clean::rollback 10
	fi
}

##################################################################################
# @name: vstacklet::environment::checkdistro
# @description: check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::checkdistro() {
	if [[ $(id -u) != 0 ]]; then
		_error "You must be root to run this script."
		exit 1
	fi
	_success "Congrats! You're running as root. Let's continue"
}

##################################################################################
# @name: vstacklet::intro (1)
# @description: prints the intro message
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::intro() {
	echo
	echo
	echo "[${repo_title}VStacklet${normal}] ${title} VStacklet Webserver Installation ${normal}  "
	echo
	echo "   ${title}               Heads Up!               ${normal} "
	echo "   ${message_title}  VStacklet works with the following  ${normal} "
	echo "   ${message_title}  Ubuntu 18.04/20.04 & Debian 9/10/11     ${normal} "
	echo
	echo
	echo "${green}Checking distribution ...${normal}"
	vstacklet::distro::check
	echo
	# shellcheck disable=SC2005
	echo "$(lsb_release -a)"
	echo
}

##################################################################################
# @name: vstacklet::log::check (2)
# @description: check if the log file exists and create it if it doesn't
# @noargs:
# @nooptions:
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::log::check() {
	declare -g log_file vslog
	log_file="/var/log/vstacklet/vstacklet.${PPID}.log"
	if [[ ! -d /var/log/vstacklet ]]; then
		mkdir -p /var/log/vstacklet
	fi
	if [[ -f ${log_file} ]]; then
		vslog="/var/log/vstacklet/vstacklet.${PPID}.log"
		echo "${bold}Output is being sent to /var/log/vstacklet/vstacklet.${magenta}${PPID}${normal}${bold}.log${normal}"
	fi
	if [[ ! -d /root/tmp ]]; then
		sed -i 's/noexec//g' /etc/fstab
		mount -o remount /tmp >>"${vslog}" 2>&1
		mkdir -p /root/tmp
		mount --bind /tmp /root/tmp >>"${vslog}" 2>&1
		mount -o remount,exec /tmp >>"${vslog}" 2>&1
	fi
}

# shall we continue? function (3)
vstacklet::ask::continue() {
	echo
	echo "Press ${standout}${green}ENTER${normal} when you're ready to begin or ${standout}${red}Ctrl+Z${normal} to cancel"
	read -r -s -n 1
	echo
}

##################################################################################
# @name: vstacklet::bashrc::set (4)
# @description: set ~/.bashrc and ~/.profile for vstacklet
# @nooptions:
# @noargs:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::bashrc::set() {
	\cp -f "${local_setup_dir}/templates/bashrc.template" /root/.bashrc
	if [[ -n ${domain} ]]; then
		sed -i "s/HOSTNAME/${domain}/g" /root/.bashrc
	else
		sed -i "s/HOSTNAME/${hostname}/g" /root/.bashrc
	fi
	profile="/root/.profile"
	if [[ -f ${profile} ]]; then
		\cp -f "${local_setup_dir}/templates/profile.template" /root/.profile
	fi
}

##################################################################################
# @name: vstacklet::hostname::set (5)
# @description: set system hostname
# - hostname must be a valid hostname.
#   - It can contain only letters, numbers, and hyphens.
#   - It must start with a letter and end with a letter or number.
#   - It must not contain consecutive hyphens.
#   - If hostname is not provided, it will be set to the domain name if provided.
#   - If domain name is not provided, it will be set to the server hostname.
# @option: $1 - `-h | --hostname` (optional) (takes one argument)
# @arg: $2 - `[hostname]` - the hostname to set for the system (optional) 
# @example: ./vstacklet.sh -h myhostname 
# ./vstacklet.sh --hostname myhostname
# @break
##################################################################################
vstacklet::hostname::set() {
	if [[ -n ${hostname} ]]; then
		echo "${bold}Setting hostname to ${magenta}${hostname}${normal}${bold} ...${normal}" >>"${vslog}" 2>&1
		hostnamectl set-hostname "${hostname}" >>"${vslog}" 2>&1
	fi
	if [[ -z ${hostname} && -n ${domain} ]]; then
		echo "${bold}Setting hostname name to ${magenta}${domain}${normal}${bold} ...${normal}" >>"${vslog}" 2>&1
		hostnamectl set-hostname "${domain}" >>"${vslog}" 2>&1
	fi
	if [[ -z ${hostname} && -z ${domain} ]]; then
		echo "${bold}Setting hostname to ${magenta}${server_hostname}${normal}${bold} ...${normal}" >>"${vslog}" 2>&1
		hostnamectl set-hostname "${server_hostname}" >>"${vslog}" 2>&1
	fi
}

##################################################################################
# @name: vstacklet::webroot::set (6)
# @description: set main web root directory
# - if the directory already exists, it will be used.
# - if the directory does not exist, it will be created.
# - if `-wr | --web_root` is not set, the default directory will be used.
#   e.g. `/var/www/html/{public,logs,ssl}`
# @option: $1 - `-wr | --web_root` (optional) (takes one argument)
# @arg: $2 - `[web_root_directory]` - (optional) (default: /var/www/html)
# @return: none
# @example: ./vstacklet.sh -wr /var/www/mydirectory
# ./vstacklet.sh --web_root /srv/www/mydirectory
# @break
##################################################################################
vstacklet::webroot::set() {
	if [[ -n ${web_root} ]]; then
		echo "${bold}Setting web root directory to ${magenta}${web_root}${normal}${bold} ...${normal}"
		(
			mkdir -p "${web_root}"/{public,logs,ssl}
			chown -R www-data:www-data "${web_root}"
			chmod -R 755 "${web_root}"
		) >>"${vslog}" 2>&1
	else
		echo "${bold}Setting web root directory to ${magenta}/var/www/html/${normal}${bold} ...${normal}" >>"${vslog}" 2>&1
		(
			mkdir -p /var/www/html/{public,logs,ssl}
			chown -R www-data:www-data /var/www/html
			chmod -R 755 /var/www/html
		) >>"${vslog}" 2>&1
	fi
}

##################################################################################
# @name: vstacklet::ssh::set (7)
# @description: set ssh port to custom port (if nothing is set, default port is 22)
# @option: $1 - `-ssh | --ssh_port` (optional) (takes one argument)
# @arg: $2 - `[port]` (default: 22) - the port to set for ssh
# @return: none
# @example: ./vstacklet.sh -ssh 2222
# ./vstacklet.sh --ssh_port 2222
# @break
##################################################################################
vstacklet::ssh::set() {
	if [[ -n ${ssh_port} ]]; then
		(
			echo "${bold}Setting ssh port to ${magenta}${ssh_port}${normal}${bold} ...${normal}"
			sed -i "s/^.*Port .*/Port ${ssh_port}/g" /etc/ssh/sshd_config
			service ssh restart
		) >>"${vslog}" 2>&1
	fi
}

##################################################################################
# @name: vstacklet::block::ssdp (13)
# @description: blocks an insecure port 1900 that may lead to
# DDoS masked attacks. Only remove this function if you absolutely
# need port 1900. In most cases, this is a junk port.
# @noargs:
# @nooptions:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::block::ssdp() {
	(
		echo "${bold}Blocking port 1900 ...${normal}"
		iptables -A INPUT -p udp --dport 1900 -j DROP
		iptables -A INPUT -p tcp --dport 1900 -j DROP
		iptables-save >>/etc/iptables/rules.v4
	) >>"${vslog}" 2>&1
}

##################################################################################
# @name: vstacklet::update::packages (14)
# @description: This function updates the package list and upgrades the system.
# @noargs:
# @nooptions:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::update::packages() {
	(
		apt-get update -y
		apt-get upgrade -y
		apt-get autoremove -y
		apt-get autoclean -y
		apt-get clean -y
	) >>"${vslog}" 2>&1
	if lsb_release 2>/dev/null; then
		echo "lsb_release is installed, continuing..."
	else
		apt-get install -y lsb-release >>"${vslog}" 2>&1
		if [[ -e /usr/bin/lsb_release ]]; then
			echo "lsb_release installed successfully, continuing..."
		else
			echo "lsb_release failed to install, exiting..."
			exit 1
		fi
	fi
	if [[ ${distro} == "Debian" ]]; then
		cat >/etc/apt/sources.list <<EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL DEBIAN REPOS                             #
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://ftp.nl.debian.org/debian testing main contrib non-free
deb-src http://ftp.nl.debian.org/debian testing main contrib non-free

###### Debian Update Repos
deb http://ftp.debian.org/debian/ ${codename}-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ ${codename}-updates main contrib non-free
deb http://security.debian.org/ ${codename}/updates main contrib non-free
deb-src http://security.debian.org/ ${codename}/updates main contrib non-free

#Debian Backports Repos
#http://backports.debian.org/debian-backports stretch-backports main
EOF
	elif [[ ${distro} == "Ubuntu" ]]; then
		cat >/etc/apt/sources.list <<EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#

###### Ubuntu Main Repos
deb http://nl.archive.ubuntu.com/ubuntu/ ${codename} main restricted universe multiverse
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${codename} main restricted universe multiverse

###### Ubuntu Update Repos
deb http://nl.archive.ubuntu.com/ubuntu/ ${codename}-updates main restricted universe multiverse
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${codename}-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu ${codename}-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu ${codename}-security main restricted universe multiverse

#Ubuntu Backports Repos
#deb http://nl.archive.ubuntu.com/ubuntu/ ${codename}-backports main restricted universe multiverse
#deb-src http://nl.archive.ubuntu.com/ubuntu/ ${codename}-backports main restricted universe multiverse
EOF
	elif [[ ${distro} == "Ubuntu" && ${codename} == "bionic" ]]; then
		cat >/etc/apt/sources.list <<EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#

###### Ubuntu Main Repos
deb http://nl.archive.ubuntu.com/ubuntu/ ${codename} main restricted universe
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${codename} main restricted universe

###### Ubuntu Update Repos
deb http://nl.archive.ubuntu.com/ubuntu/ ${codename}-updates main restricted universe
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${codename}-updates main restricted universe
deb http://security.ubuntu.com/ubuntu ${codename}-security main restricted universe
deb-src http://security.ubuntu.com/ubuntu ${codename}-security main restricted universe
EOF
	fi
	echo -n "Updating packages, please wait..."
	if [[ ${distro} == "Debian" ]]; then
		export DEBIAN_FRONTEND=noninteractive
		(
			yes '' | apt-get -y update
			apt-get -u purge samba samba-common
			yes '' | apt-get -y upgrade
		) >>"${vslog}" 2>&1
	else
		export DEBIAN_FRONTEND=noninteractive
		(
			apt-get -y update
			apt-get -y purge samba samba-common
			apt-get -y upgrade
		) >>"${vslog}" 2>&1
	fi
	clear
}

##################################################################################
# @name: vstacklet::locale::set (5) ? vstacklet::locale::set::en_US.UTF-8 (15)
# @description: This function sets the locale to en_US.UTF-8
# and sets the timezone to UTC.
# @note: This function is required for the installation of
# the vStacklet software.
# @wip: This function is still a work in progress. It is planned
# to add additional parameters to select the timezone and locale.
# @break
##################################################################################
vstacklet::locale::set() {
	echo "${bold}Setting locale to en_US.UTF-8 ...${normal}"
	apt-get -y install language-pack-en-base >>"${vslog}" 2>&1
	sed -i "s/^.*en_US.UTF-8 UTF-8.*/en_US.UTF-8 UTF-8/g" /etc/locale.gen
	if [[ -e /usr/sbin/locale-gen ]]; then
		locale-gen
	else
		(
			apt-get -y update
			apt-get -y install locales locale-gen
			locale-gen
		) >>"${vslog}" 2>&1
		export LANG="en_US.UTF-8"
		export LC_ALL="en_US.UTF-8"
		export LANGUAGE="en_US.UTF-8"
	fi
	update-locale LANG=en_US.UTF-8
}

##################################################################################
# @name: vstacklet::packages::softcommon (6)
# @description: This function updates the system packages and installs
# the required common property packages for the vStacklet software.
# @nooptions:
# @noargs:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::packages::softcommon() {
	# package and repo addition (a) _install common properties_
	apt-get -y install software-properties-common python-software-properties apt-transport-https >>"${vslog}" 2>&1
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::packages::depends (7)
# @description: This function installs the required software packages
# for the vStacklet software.
# @nooptions:
# @noargs:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::packages::depends() {
	# package and repo addition (b) _install softwares and packages_
	apt-get -y install nano unzip git dos2unix htop iotop bc libwww-perl dnsutils curl sudo rsync >>"${vslog}" 2>&1
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::packages::keys (8)
# @description: This function sets the required software package keys
# and sources for the vStacklet software.
# - keys and sources are set for the following software packages:
#   - hhvm (only if option `-hhvm|--hhvm` is set)
#   - nginx (only if option `-nginx|--nginx` is set)
#   - varnish (only if option `-varnish|--varnish` is set)
#   - php (only if option `-php|--php` is set)
#   - mariadb (only if option `-mariadb|--mariadb` is set)
# @nooptions:
# @noargs:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @note: apt-key is being deprecated, use gpg instead
# @break
##################################################################################
vstacklet::packages::keys() {
	# package and repo addition (c) _add signed keys_
	echo "${bold}Adding signed keys and sources for required software packages...${normal}"
	mkdir -p /etc/apt/sources.list.d /etc/apt/keyrings
	if [[ -n ${hhvm} ]]; then
		# hhvm
		curl -fsSL https://dl.hhvm.com/conf/hhvm.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/hhvm.gpg
		echo "deb [signed-by=/etc/apt/keyrings/hhvm.gpg] https://dl.hhvm.com/${distro} ${codename} main" | tee /etc/apt/sources.list.d/hhvm.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${nginx} ]]; then
		# nginx
		curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /etc/apt/keyrings/nginx.gpg
		echo "deb [signed-by=/etc/apt/keyrings/nginx.gpg] https://nginx.org/packages/mainline/${distro}/ ${codename} nginx" | tee /etc/apt/sources.list.d/nginx.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${varnish} ]]; then
		# varnish
		curl -fsSL "https://packagecloud.io/varnishcache/varnish72/gpgkey" | gpg --dearmor >"/etc/apt/keyrings/varnishcache_varnish72-archive-keyring.gpg"
		curl -sSf "https://packagecloud.io/install/repositories/varnishcache/varnish72/config_file.list?os=${distro,,}&dist=${codename}&source=script" >"/etc/apt/sources.list.d/varnishcache_varnish72.list"
	fi
	if [[ -n ${php} ]]; then
		# php
		curl -fsSL https://packages.sury.org/php/apt.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/php.gpg
		echo "deb [signed-by=/etc/apt/keyrings/php.gpg] https://packages.sury.org/php/ ${codename} main" | tee /etc/apt/sources.list.d/php-sury.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${mariadb} ]]; then
		# mariadb
		wget -qO- https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor >/etc/apt/trusted.gpg.d/mariadb.gpg
		cat >/etc/apt/sources.list.d/mariadb.list <<EOF
deb [arch=amd64,i386,arm64,ppc64el] http://mirrors.syringanetworks.net/mariadb/repo/10.7/${distro} ${codename} main
deb-src http://mirrors.syringanetworks.net/mariadb/repo/10.7/${distro}/ ${codename} main
EOF
	fi
	# Remove excess sources known to
	# cause issues with conflicting package sources
	[[ -f "/etc/apt/sources.list.d/proposed.list" ]] && mv -f /etc/apt/sources.list.d/proposed.list /etc/apt/sources.list.d/proposed.list.BAK
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::apt::update (9)
# @description: update apt sources and packages - this is a wrapper for apt-get update
# @nooptions:
# @noargs:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::apt::update() {
	# package and repo addition (d) _update and upgrade_
	echo -n "Updating system ... "
	(
		apt-get update >>"${vslog}" 2>&1
	) || {
		_warn "Failed to update system"
		exit 1
	}
	(
		DEBIAN_FRONTEND=noninteractive apt-get -y upgrade >>"${vslog}" 2>&1
	) || {
		_warn "Failed to upgrade system"
		exit 1
	}
	(
		apt-get -y autoremove
		apt-get -y autoclean
	) >>"${vslog}" 2>&1 || {
		_warn "Failed to clean system"
		exit 1
	}
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::php::install (11)
# @description: install php and php modules (optional) (default: not installed)
# versioning
# - php < "7.4" - not supported, deprecated
# - php = "7.4" - supported
# - php = "8.0" - superceded by php="8.1"
# - php = "8.1" - supported
# - chose either php or hhvm, not both
# - php modules are installed based on the following variables:
#   - `-php [php version]` (default: 8.1) - php version to install
#   - php_modules are installed based on the php version and neccessity
# - the php_modules installed/enabled on vstacklet are:
#   - "opcache"
#   - "xml"
#   - "igbinary"
#   - "imagick"
#   - "intl"
#   - "mbstring"
#   - "gmp"
#   - "bcmath"
#   - "msgpack"
# @option: $1 - `-php | --php`
# @arg: $2 - `[version]` - `7.4` | `8.1`
# @example: ./vstacklet.sh -php 8.1
# ./vstacklet.sh --php 7.4
# @null
# @break
##################################################################################
vstacklet::php::install() {
	if [[ -n ${php} && ${php_set} == "1" ]]; then
		# php version sanity check
		[[ ${php} == *"8"* ]] && php="8.1"
		[[ ${php} == *"7"* ]] && php="7.4"
		echo -n "Installing and Adjusting php${magenta}php${php}-fpm${normal}-fpm w/ OPCode Cache ... "
		# install php dependencies and php
		(
			apt-get -y install "php${php}-fpm" "php${php}-zip" "php${php}-cgi" "php${php}-cli" "php${php}-common" "php${php}-curl" "php${php}-dev" "php${php}-gd" "php${php}-bcmath" "php${php}-gmp" "php${php}-imap" "php${php}-intl" "php${php}-ldap" "php${php}-mbstring" "php${php}-mysql" "php${php}-opcache" "php${php}-pspell" "php${php}-readline" "php${php}-soap" "php${php}-xml" "php${php}-imagick" "php${php}-msgpack" "php${php}-igbinary" "libmcrypt-dev" "mcrypt" >>"${vslog}" 2>&1
		) || {
			_warn "Failed to install PHP${php}"
			exit 1
		}
		if [[ -n ${memcached} ]]; then
			# memcached
			(
				apt-get -y install "php${php}-memcached" >>"${vslog}" 2>&1
			) || {
				_warn "Failed to install PHP${php} Memcached"
				exit 1
			}
		fi
		if [[ -n ${redis} ]]; then
			# redis
			(
				apt-get -y install "php${php}-redis" >>"${vslog}" 2>&1
			) || {
				_warn "Failed to install PHP${php} Redis"
				exit 1
			}
		fi
		# tweak php.ini
		declare -a php_files=("/etc/php/${php}/fpm/php.ini" "/etc/php/${php}/cli/php.ini")
		# shellcheck disable=SC2215
		for file in "${php_files[@]}"; do
			sed -i.bak -e "s/.*post_max_size =.*/post_max_size = 92M/" -e "s/.*upload_max_filesize =.*/upload_max_filesize = 92M/" -e "s/.*expose_php =.*/expose_php = Off/" -e "s/.*memory_limit =.*/memory_limit = 768M/" -e "s/.*session.cookie_secure =.*/session.cookie_secure = 1/" -e "s/.*session.cookie_httponly =.*/session.cookie_httponly = 1/" -e "s/.*session.cookie_samesite =.*/cookie_samesite.cookie_secure = Lax/" -e "s/.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/" -e "s/.*opcache.enable=.*/opcache.enable=1/" -e "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" -e "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" "${file}"
		done
		sleep 3
		# enable modules
		phpmods=("opcache" "xml" "igbinary" "imagick" "intl" "mbstring" "gmp" "bcmath" "msgpack")
		for i in "${phpmods[@]}"; do
			phpenmod -v "${php}" "${i}"
		done
		[[ -n ${memcached} ]] && phpenmod -v "${php}" memcached
		[[ -n ${redis} ]] && phpenmod -v "${php}" redis
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::nginx::install (12)
# @description: install nginx (optional) (default: not installed)
# @option: $1 - `-nginx | --nginx` (optional) (takes no arguments)
# @example: ./vstacklet.sh -nginx
# ./vstacklet.sh --nginx
# @break
##################################################################################
vstacklet::nginx::install() {
	if [[ -n ${nginx} ]]; then
		echo -n "Installing and Adjusting ${magenta}nginx${normal} ... "
		(
			apt-get -y install nginx >>"${vslog}" 2>&1
		) || {
			_warn "Failed to install nginx"
			exit 1
		}
		systemctl stop nginx >>"${vslog}" 2>&1
		mv /etc/nginx /etc/nginx-pre-vstacklet
		mkdir -p /etc/nginx/{conf.d,cache,ssl}
		sleep 3
		rsync -aP --exclude=/pagespeed --exclude=LICENSE --exclude=README --exclude=.git "${vstacklet_base_path}/nginx"/* /etc/nginx/ >>"${vslog}" 2>&1
		\cp -rf /etc/nginx-pre-vstacklet/uwsgi_params /etc/nginx-pre-vstacklet/fastcgi_params /etc/nginx/
		chown -R www-data:www-data /etc/nginx/cache
		chmod -R 755 /etc/nginx/cache
		chmod -R g+rw /etc/nginx/cache
		sh -c 'find /etc/nginx/cache -type d -print0 | sudo xargs -0 chmod g+s'
		# import nginx reverse config files from vStacklet
		if [[ -n ${domain} ]]; then
			if [[ ${php} == *"8"* ]]; then
				cp "${local_php8_dir}nginx/conf.d/default.php8.conf.save" "/etc/nginx/conf.d/${domain}.conf"
			fi
			if [[ ${php} == *"7"* ]]; then
				cp "${local_php7_dir}nginx/conf.d/default.php7.conf.save" "/etc/nginx/conf.d/${domain}.conf"
			fi
			if [[ -n ${hhvm} ]]; then
				cp "${local_hhvm_dir}nginx/conf.d/default.hhvm.conf.save" "/etc/nginx/conf.d/${domain}.conf"
			fi
		else
			if [[ ${php} == *"8"* ]]; then
				default="vsdefault"
				cp "${local_php8_dir}nginx/conf.d/default.php8.conf.save" "/etc/nginx/conf.d/${default}.conf"
			fi
			if [[ ${php} == *"7"* ]]; then
				default="vsdefault"
				cp "${local_php7_dir}nginx/conf.d/default.php7.conf.save" "/etc/nginx/conf.d/${default}.conf"
			fi
			if [[ -n ${hhvm} ]]; then
				default="vsdefault"
				cp "${local_hhvm_dir}nginx/conf.d/default.hhvm.conf.save" "/etc/nginx/conf.d/${default}.conf"
			fi
		fi
		# stage checkinfo.php for verification
		if [[ -n ${web_root} ]]; then
			echo '<?php phpinfo(); ?>' >"${web_root}/public/checkinfo.php"
			chown -R www-data:www-data "${web_root}"
			chmod -R 755 "${web_root}"
			chmod -R g+rw "${web_root}"
			sh -c 'find "${web_root}" -type d -print0 | sudo xargs -0 chmod g+s'
		else
			echo '<?php phpinfo(); ?>' >/var/www/html/public/checkinfo.php
			chown -R www-data:www-data /var/www/html
			chmod -R 755 /var/www/html
			chmod -R g+rw /var/www/html
			sh -c 'find /var/www/html -type d -print0 | sudo xargs -0 chmod g+s'
		fi
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::hhvm::install (13)
# @description: install hhvm
# @option: $1 - `-hhvm | --hhvm` (optional) (takes no arguments)
# @example: ./vstacklet.sh -hhvm 
# ./vstacklet.sh --hhvm
# @note: chose either php or hhvm, not both
# @break
##################################################################################
vstacklet::hhvm::install() {
	if [[ -n ${hhvm} ]]; then
		echo -n "Installing and Adjusting ${magenta}hhvm${normal} ... "
		(
			apt-get -y install hhvm
			/usr/share/hhvm/install_fastcgi.sh
		) >>"${vslog}" 2>&1 || {
			_warn "Failed to install hhvm"
			exit 1
		}
		/usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60 >>"${vslog}" 2>&1
		# get off the port and use socket - vStacklet nginx configurations already know this
		cp -f "${local_hhvm_dir}server.ini.template" /etc/hhvm/server.ini
		cp -f "${local_hhvm_dir}php.ini.template" /etc/hhvm/php.ini
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::permissions::adjust (14)
# @description: adjust permissions for web root
# @nooptions:
# @noargs:
# @return: none
# @note: This function is required for the installation of
# the vStacklet software.
# @note: permissions are adjusted based on the following variables:
# @note: -wr | --web_root
# @break
##################################################################################
vstacklet::permissions::adjust() {
	if [[ -n ${web_root} ]]; then
		chown -R www-data:www-data "${web_root}"
		chmod -R 755 "${web_root}"
		chmod -R g+rw "${web_root}"
		sh -c 'find "${web_root}" -type d -print0 | sudo xargs -0 chmod g+s'
	else
		chown -R www-data:www-data /var/www/html
		chmod -R 755 /var/www/html
		chmod -R g+rw /var/www/html
		sh -c 'find /var/www/html -type d -print0 | sudo xargs -0 chmod g+s'
	fi
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::varnish::install (15)
# @description: install varnish and configure
# @option: $1 - `-varnish | --varnish` (optional) (takes no arguments)
# @option: $2 - `-varnishP | --varnish_port` (optional) (takes one argument)
# @option: $3 - `-http | --http_port` (optional) (takes one argument)
# @option: $4 - `-https | --https_port` (optional) (takes one argument)
# @arg: $2 - `[varnish_port_number]` (optional) (default: 6081)
# @arg: $3 - `[http_port_number]` (optional) (default: 80)
# @arg: $4 - `[https_port_number]` (optional) (default: 443)
# @example: ./vstacklet.sh -varnish -varnishP 6081 -http 80
# ./vstacklet.sh --varnish --varnish_port 6081 --http_port 80
# ./vstacklet.sh -varnish -varnishP 6081 -http 80 -https 443
# @null
# @note: varnish is installed based on the following variables:
# - -varnish (optional) (default: nginx)
# - -varnishP|--varnish_port (optional) (default: 6081)
# - -http|--http_port (optional) (default: 80)
# @note: chose either varnish or nginx, not both
# @break
##################################################################################
vstacklet::varnish::install() {
	if [[ -n ${varnish} ]]; then
		echo -n "Installing and Adjusting ${magenta}varnish${normal} ... "
		(
			apt-get -y install varnish
		) >>"${vslog}" 2>&1 || {
			_warn "Failed to install varnish"
			exit 1
		}
		cd /etc/varnish || _error "/etc/varnish does not exist" && exit 1
		mv default.vcl default.vcl.ORIG
		# import varnish config files from vStacklet
		cp -f "${local_varnish_dir}default.vcl.save" "/etc/varnish/default.vcl"
		# adjust varnish config files
		sed -i "s|{{server_ip}}|${server_ip}|g" /etc/varnish/default.vcl
		sed -i "s|6081|${http_port}|g" /etc/default/varnish
		# adjust varnish service
		cp -f /lib/systemd/system/varnishlog.service /etc/systemd/system/
		cp -f /lib/systemd/system/varnish.service /etc/systemd/system/
		sed -i "s|6081|${http_port}|g" /etc/systemd/system/varnish.service
		sed -i "s|6081|${http_port}|g" /lib/systemd/system/varnish.service
		(
			systemctl daemon-reload
		) >>"${vslog}" 2>&1 || {
			_warn "Failed to reload systemctl service daemon"
			exit 1
		}
		cd "${HOME}" || _error "Failed to change directory to ${HOME}" && exit 1
		echo "${OK}"
	fi
}

##################################################################################
# @name: _memcached (null)
# @description: install memcached (optional) - internal function
# @note: archiving function for memcached as this is handled
# by the vStacklet::php::install function
# @todo: remove this function
# @break
##################################################################################
#function _memcached() {
#	if [[ ${memcached} == "yes" ]]; then
#		echo -n "Installing Memcached for PHP 8 ... "
#		apt-get -y install php${php}-dev git pkg-config build-essential libmemcached-dev >/dev/null 2>&1
#		apt-get -y install php-memcached memcached >/dev/null 2>&1
#	fi
#	echo "${OK}"
#}

##################################################################################
# @name: vstacklet::ioncube::install (16)
# @description: install ioncube (optional)
# - the ioncube loader will be available for the php version specified
# from the `-php | --php` option.
# @option: $1 - `-ioncube | --ioncube` (optional) (takes no arguments)
# @example: ./vstacklet.sh -ioncube -php 8.1
# ./vstacklet.sh --ioncube --php 8.1
# ./vstacklet.sh -ioncube -php 7.4
# ./vstacklet.sh --ioncube --php 7.4
# @break
##################################################################################
vstacklet::ioncube::install() {
	if [[ -n ${ioncube} ]]; then
		echo -n "${green}Installing IonCube Loader${normal} ... "
		(
			apt-get -y install php${php}-dev git pkg-config build-essential libmemcached-dev
			apt-get -y install php-memcached memcached
		) >>"${vslog}" 2>&1 || {
			_warn "Failed to install php-memcached and memcached"
			exit 1
		}
		# install ioncube loader for php 7.4
		if [[ ${php} == "7.4" ]]; then
			(
				cd /tmp || _error "Failed to change directory to /tmp" && exit 1
				wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
				tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
				cd ioncube || _error "Failed to change directory to /tmp/ioncube" && exit 1
				cp -f ioncube_loader_lin_7.4.so /usr/lib/php/20190902/ || _error "Failed to copy ioncube_loader_lin_7.4.so to /usr/lib/php/20190902/" && exit 1
				echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" >/etc/php/7.4/mods-available/ioncube.ini
				ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/cli/conf.d/20-ioncube.ini
				ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/fpm/conf.d/20-ioncube.ini
				phpenmod -v 7.4 ioncube
				systemctl restart php7.4-fpm
				systemctl restart apache2
			) >>"${vslog}" 2>&1 || {
				_warn "Failed to install ioncube loader for php 7.4"
				exit 1
			}
		fi
		# install ioncube loader for php 8.1
		if [[ ${php} == "8.1" ]]; then
			(
				cd /tmp || _error "Failed to change directory to /tmp" && exit 1
				wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
				tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
				cd ioncube || _error "Failed to change directory to /tmp/ioncube" && exit 1
				cp -f ioncube_loader_lin_8.1.so /usr/lib/php/20210902/ || _error "Failed to copy ioncube_loader_lin_8.1.so to /usr/lib/php/20210902/" && exit 1
				echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" >/etc/php/8.1/mods-available/ioncube.ini
				{ echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" >> "$(php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||")"; } || {
					_warn "Failed to add ioncube loader to php.ini"
					exit 1
				}
				ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/cli/conf.d/20-ioncube.ini
				ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/fpm/conf.d/20-ioncube.ini
				phpenmod -v 8.1 ioncube
			) >>"${vslog}" 2>&1 || {
				_warn "Failed to install ioncube loader for php 8.1"
				exit 1
			}
		fi
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::mariadb::install (17)
# @description: install mariadb and configure
# @option: $1 - `-mariadb | --mariadb` (optional) (takes no arguments)
# @option: $2 - `-mariadbP | --mariadb_port` (optional) (takes one argument)
# @option: $3 - `-mariadbU | --mariadb_user` (optional) (takes one argument)
# @option: $4 - `-mariadbPw | --mariadb_password` (optional) (takes one argument)
# @arg: $2 - `[port]` (optional) (default: 3306)
# @arg: $3 - `[user]` (optional) (default: root)
# @arg: $4 - `[password]` (optional) (default: password auto-generated)
# @example: ./vstacklet.sh -mariadb -mariadbP 3306 -mariadbU root -mariadbPw password
# ./vstacklet.sh --mariadb --mariadb_port 3306 --mariadb_user root --mariadb_password password
# @break
##################################################################################
vstacklet::mariadb::install() {
	if [[ -n ${mariadb} ]]; then
		[[ -z ${mariadb_port} ]] && mariadb_port=3306
		[[ -z ${mariadb_user} ]] && mariadb_user="root"
		[[ -z ${mariadb_password} ]] && mariadb_password=$(openssl rand -base64 12)
		echo -n "${green}Installing MariaDB${normal} ... "
		(
			DEBIAN_FRONTEND=noninteractive apt-get --allow-unauthenticated -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install mariadb-server mariadb-client
		) >>"${vslog}" 2>&1 || {
			_warn "Failed to install MariaDB"
			exit 1
		}
		# configure mariadb
		echo -n "${green}Configuring MariaDB${normal} ... "
		# set mariadb root password
		mysqladmin -u root password "${mariadb_password}" >>"${vslog}" 2>&1 || {
			_warn "Failed to set MariaDB root password"
			exit 1
		}
		# create mariadb user
		mysql -u root -p"${mariadb_password}" -e "CREATE USER '${mariadb_user}'@'localhost' IDENTIFIED BY '${mariadb_password}';" >>"${vslog}" 2>&1 || {
			_warn "Failed to create MariaDB user"
			exit 1
		}
		# grant privileges to mariadb user
		mysql -u root -p"${mariadb_password}" -e "GRANT ALL PRIVILEGES ON *.* TO '${mariadb_user}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || {
			_warn "Failed to grant privileges to MariaDB user"
			exit 1
		}
		# flush privileges
		mysql -u root -p"${mariadb_password}" -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || {
			_warn "Failed to flush privileges"
			exit 1
		}
		# set mariadb client and server configuration
		{
			echo -e "[client]"
			echo -e "port = ${mariadb_port}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "[mysqld]"
			echo -e "port = ${mariadb_port}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"

		} >/etc/mysql/conf.d/vstacklet.cnf || {
			_warn "Failed to set MariaDB client and server configuration" 
			vstacklet::clean::rollback 
		} 
		echo "configuration file saved to /etc/mysql/conf.d/vstacklet.cnf"
		echo "mariaDB client and server configuration set to:"
		cat /etc/mysql/conf.d/vstacklet.cnf
		echo "mariadb root password: ${mariadb_password}"
		echo "mariadb user: ${mariadb_user}"
		echo "mariadb port: ${mariadb_port}"
		echo
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::phpmyadmin::install (18)
# @description: install phpmyadmin and configure
# @option: $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments)
# @option: $2 - `-phpmyadminP | --phpmyadmin_port` (optional) (takes one argument)
# @option: $3 - `-phpmyadminU | --phpmyadmin_user` (optional) (takes one argument)
# @option: $4 - `-phpmyadminPw | --phpmyadmin_password` (optional) (takes one argument)
# @arg: $2 - `[port]` (optional) (default: 8080)
# @arg: $3 - `[user]` (optional) (default: root)
# @arg: $4 - `[password]` (optional) (default: password auto-generated)
# @example: ./vstacklet.sh -phpmyadmin -phpmyadminP 8080 -phpmyadminU root -phpmyadminPw password
# ./vstacklet.sh --phpmyadmin --phpmyadmin_port 8080 --phpmyadmin_user root --phpmyadmin_password password
# @break
##################################################################################
vstacklet::phpmyadmin::install() {
	if [[ -n ${phpmyadmin} && -n ${mariadb} || ${mysql} ]]; then
		declare pma_version=$(curl -s https://www.phpmyadmin.net/home_page/version.json | jq -r '.version')
		[[ -n ${http_port} ]] && phpmyadmin_port=${http_port}
		[[ -z ${http_port} ]] && phpmyadmin_port=80
		[[ -n ${mariadb} || -n ${mysql} && -z ${mariadb_user} || -z ${mysql_user} ]] && phpmyadmin_user="root"
		[[ -n ${mariadb} || -n ${mysql} && -z ${mariadb_password} || -z ${mysql_password} ]] && phpmyadmin_password=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)
		[[ -n ${domain} ]] && phpmyadmin_domain=${domain}
		[[ -z ${domain} ]] && phpmyadmin_domain=${server_ip}
		pma_bf=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..31')
		echo -n "${green}Installing phpMyAdmin${normal} ... "
		(
			DEBIAN_FRONTEND=noninteractive apt-get --allow-unauthenticated -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install phpmyadmin
		) >>"${vslog}" 2>&1 || {
			_warn "Failed to install phpMyAdmin"
			exit 1
		}
		cd /usr/share || {
			_warn "Failed to change directory to /usr/share"
			exit 1
		}
		rm -rf phpmyadmin || {
			_warn "Failed to remove phpmyadmin"
			exit 1
		}
		wget https://files.phpmyadmin.net/phpMyAdmin/${pma_version}/phpMyAdmin-${pma_version}-all-languages.tar.gz >>"${vslog}" 2>&1 || {
			_warn "Failed to download phpMyAdmin"
			exit 1
		}
		tar -xzf phpMyAdmin-${pma_version}-all-languages.tar.gz >>"${vslog}" 2>&1 || {
			_warn "Failed to extract phpMyAdmin"
			exit 1
		}
		mv phpMyAdmin-${pma_version}-all-languages phpmyadmin || {
			_warn "Failed to rename phpMyAdmin"
			exit 1
		}
		rm -rf phpMyAdmin-${pma_version}-all-languages.tar.gz || {
			_warn "Failed to remove phpMyAdmin"
			exit 1
		}
		mkdir -p /var/lib/phpmyadmin/tmp || {
			_warn "Failed to create directory /var/lib/phpmyadmin/tmp"
			exit 1
		}
		[[ -n ${web_root} ]] && ln -sf /usr/share/phpmyadmin "${web_root}/public" || {
			_warn "Failed to create symlink to phpmyadmin"
			exit 1
		}
		[[ -z ${web_root} ]] && ln -sf /usr/share/phpmyadmin /var/www/html/public || {
			_warn "Failed to create symlink to phpmyadmin"
			exit 1
		}
		# configure phpmyadmin
		echo -n "${green}Configuring phpMyAdmin${normal} ... "
		# set phpmyadmin configuration
		{
			echo -e "<?php"
			echo -e "/* Servers configuration */"
			echo -e "\$i = 0;"
			echo -e "/* Server: localhost [1] */"
			echo -e "\$i++;"
			echo -e "\$cfg['Servers'][\$i]['verbose'] = 'localhost';"
			echo -e "\$cfg['Servers'][\$i]['host'] = 'localhost';"
			echo -e "\$cfg['Servers'][\$i]['port'] = '${mariadb_port}';"
			echo -e "\$cfg['Servers'][\$i]['socket'] = '';"
			echo -e "\$cfg['Servers'][\$i]['connect_type'] = 'tcp';"
			echo -e "\$cfg['Servers'][\$i]['extension'] = 'mysqli';"
			echo -e "\$cfg['Servers'][\$i]['compress'] = false;"
			echo -e "\$cfg['Servers'][\$i]['auth_type'] = 'cookie';"
			echo -e "\$cfg['Servers'][\$i]['user'] = '${phpmyadmin_user}';"
			echo -e "\$cfg['Servers'][\$i]['password'] = '${phpmyadmin_password}';"
			echo -e "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;"
			echo -e "/* End of servers configuration */"
			echo -e "\$cfg['blowfish_secret'] = '${pma_bf}';"
			echo -e "\$cfg['DefaultLang'] = 'en';"
			echo -e "\$cfg['ServerDefault'] = 1;"
			echo -e "\$cfg['UploadDir'] = '';"
			echo -e "\$cfg['SaveDir'] = '';"
			echo -e "?>"
		} >/etc/phpmyadmin/config.inc.php || { 
			_warn "Failed to set phpMyAdmin configuration" 
			vstacklet::clean::rollback 
		}
		echo "configuration file saved to /etc/phpmyadmin/config.inc.php"
		echo "Access phpMyAdmin at http://${phpmyadmin_domain}:${phpmyadmin_port}/phpmyadmin"
		echo "phpmyadmin user: ${phpmyadmin_user}"
		echo "phpmyadmin password: ${phpmyadmin_password}"
		echo "phpmyadmin port: ${phpmyadmin_port}"
		echo
		echo "${OK}"
		else
		_warn "phpMyAdmin requires MariaDB or MySQL" && vstacklet::clean::rollback
	fi
}


function _phpmyadmin() {
	if [[ ${phpmyadmin} == "yes" ]]; then
		# generate random passwords for the MySql root user
		pmapass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)
		mysqlpass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)
		pma_bf=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 31)
		mysqladmin -u root -h localhost password "${mysqlpass}"
		echo -n "${bold}Installing MySQL with user:${normal} ${bold}${green}root${normal}${bold} / passwd:${normal} ${bold}${green}${mysqlpass}${normal} ... "
		apt-get -y install debconf-utils >>"${OUTTO}" 2>&1
		export DEBIAN_FRONTEND=noninteractive
		# silently configure given options and install
		echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${mysqlpass}" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/mysql/app-pass password ${pmapass}" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/app-password-confirm password ${pmapass}" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
		apt-get -y install phpmyadmin >>"${OUTTO}" 2>&1
		cd /usr/share || _error "unable to move to /usr/share"
		rm -rf phpmyadmin
		PMA_VERSION=$(curl -i -s https://www.phpmyadmin.net/downloads/ | grep -Eo "phpMyAdmin-.*" | grep -Eo "[0-9.]+" | head -n1)
		wget -q -P /usr/share/ "https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip"
		unzip "phpMyAdmin-${PMA_VERSION}-all-languages.zip" >/dev/null 2>&1
		cp -r "phpMyAdmin-${PMA_VERSION}-all-languages" phpmyadmin
		rm -rf "phpMyAdmin-${PMA_VERSION}-all-languages"*
		cd /usr/share/phpmyadmin || _error "unable to move to /usr/share/phpmyadmin"
		cp config.sample.inc.php config.inc.php
		sed -i "s/\$cfg\['blowfish_secret'\] = .*;/\$cfg\['blowfish_secret'\] = '${pma_bf}';/g" /usr/share/phpmyadmin/config.inc.php
		mkdir tmp && chown -R www-data:www-data /usr/share/phpmyadmin/tmp
		if [[ ${sitename} == "yes" ]]; then
			# create a sym-link to live directory.
			ln -sf /usr/share/phpmyadmin "/srv/www/${site_path}/public"
		else
			# create a sym-link to live directory.
			ln -sf /usr/share/phpmyadmin "/srv/www/${hostname1}/public/phpmyadmin"
		fi
		echo "${OK}"
		# show phpmyadmin creds
		{
			echo "[client]"
			echo "user=root"
			echo "password=${mysqlpass}"
			echo ""
			echo "[mysql]"
			echo "user=root"
			echo "password=${mysqlpass}"
			echo ""
			echo "[mysqldump]"
			echo "user=root"
			echo "password=${mysqlpass}"
			echo ""
			echo "[mysqldiff]"
			echo "user=root"
			echo "password=${mysqlpass}"
			echo ""
			echo "[phpmyadmin]"
			echo "pmadbuser=phpmyadmin"
			echo "pmadbpass=${pmapass}"
			echo ""
			echo "-------------------------------------------------------------"
			echo "  Access phpMyAdmin at: "
			echo "  http://${server_ip}:8080/phpmyadmin/"
			echo "-------------------------------------------------------------"
			echo
		} >>~/.my.cnf
		# closing statement
		echo
		echo "${bold}Below are your phpMyAdmin and MySQL details.${normal}"
		echo "${bold}Details are logged in the${normal} ${bold}${green}/root/.my.cnf${normal} ${bold}file.${normal}"
		echo "Best practice is to copy this file locally then rm ~/.my.cnf"
		echo
		# show contents of .my.cnf file
		cat ~/.my.cnf
		echo
	fi
}

function _nophpmyadmin() {
	if [[ ${phpmyadmin} == "no" ]]; then
		echo "${cyan}Skipping phpMyAdmin Installation...${normal}"
	fi
}

# install and adjust config server firewall function (15)
function _askcsf() {
	echo -n "${bold}${yellow}Do you want to install CSF (Config Server Firewall)?${normal} (${bold}${green}Y${normal}/n): "
	read -r responce
	case ${responce} in
	[yY] | [yY][Ee][Ss] | "") csf=yes ;;
	[nN] | [nN][Oo]) csf=no ;;
	*)
		echo "Invalid input..."
		_askcsf
		;;
	esac
}

function _csf() {
	if [[ ${csf} == "yes" ]]; then
		echo -n "${green}Installing and Adjusting CSF${normal} ... "
		cd || _error "could not change directory to ${HOME}"
		apt-get -y install e2fsprogs >/dev/null 2>&1
		wget https://download.configserver.com/csf.tgz
		#wget http://www.configserver.com/free/csf.tgz >/dev/null 2>&1;
		tar -xzf csf.tgz >/dev/null 2>&1
		ufw disable >>"${OUTTO}" 2>&1
		cd csf || _error "could not change directory to ${HOME}/csf" && exit 1
		sh install.sh >>"${OUTTO}" 2>&1
		perl /usr/local/csf/bin/csftest.pl >>"${OUTTO}" 2>&1
		# modify csf blocklists - essentially like CloudFlare, but on your machine
		sed -i.bak -e "s/#SPAMDROP|86400|0|/SPAMDROP|86400|100|/g" \
			-e "s/#SPAMEDROP|86400|0|/SPAMEDROP|86400|100|/g" \
			-e "s/#DSHIELD|86400|0|/DSHIELD|86400|100|/g" \
			-e "s/#TOR|86400|0|/TOR|86400|100|/g" \
			-e "s/#ALTTOR|86400|0|/ALTTOR|86400|100|/g" \
			-e "s/#BOGON|86400|0|/BOGON|86400|100|/g" \
			-e "s/#HONEYPOT|86400|0|/HONEYPOT|86400|100|/g" \
			-e "s/#CIARMY|86400|0|/CIARMY|86400|100|/g" \
			-e "s/#BFB|86400|0|/BFB|86400|100|/g" \
			-e "s/#OPENBL|86400|0|/OPENBL|86400|100|/g" \
			-e "s/#AUTOSHUN|86400|0|/AUTOSHUN|86400|100|/g" \
			-e "s/#MAXMIND|86400|0|/MAXMIND|86400|100|/g" \
			-e "s/#BDE|3600|0|/BDE|3600|100|/g" \
			-e "s/#BDEALL|86400|0|/BDEALL|86400|100|/g" /etc/csf/csf.blocklists
		# modify csf ignore - ignore nginx, varnish & mysql
		{
			echo
			echo "[ VStacklet Additions - ignore nginx, varnish & mysql ]"
			echo "nginx"
			echo "varnishd"
			echo "mysqld"
			echo "rsyslogd"
			echo "systemd-timesyncd"
			echo "systemd-resolved"
		} >>/etc/csf/csf.ignore
		# modify csf allow - allow ssh, http, https, mysql, phpmyadmin, varnish
		{
			echo
			echo "[ VStacklet Additions - allow ssh, http, https, mysql, phpmyadmin, varnish ]"
			echo "22"
			echo "80"
			echo "443"
			echo "3306"
			echo "8080"
			echo "6081"
		} >>/etc/csf/csf.allow
		# modify csf conf - make suitable changes for non-cpanel environment
		sed -i.bak -e 's/TESTING = "1"/TESTING = "0"/g' \
			-e 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/g' \
			-e 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/g' \
			-e 's/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,465,587,873,993,995,8080"/g' \
			-e 's/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/g' \
			-e 's/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,465,587,873,993,995,8080"/g' \
			-e 's/DENY_TEMP_IP_LIMIT = "100"/DENY_TEMP_IP_LIMIT = "1000"/g' \
			-e 's/SMTP_ALLOWUSER = "cpanel"/SMTP_ALLOWUSER = "root"/g' \
			-e 's/PT_USERMEM = "200"/PT_USERMEM = "500"/g' \
			-e 's/PT_USERTIME = "1800"/PT_USERTIME = "7200"/g' /etc/csf/csf.conf
		echo "${OK}"
		# install sendmail as it's binary is required by CSF
		echo "${green}Installing Sendmail${normal} ... "
		apt-get -y install sendmail >>"${OUTTO}" 2>&1 || _error "could not install sendmail" && exit 1
		export DEBIAN_FRONTEND=noninteractive /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1 || _error "could not configure sendmail" && exit 1
		# add administrator email
		echo "${magenta}${bold}Add an Administrator Email Below for Aliases Inclusion${normal}"
		read -rp "${bold}Email: ${normal}" admin_email
		echo "${bold}The email ${green}${bold}${admin_email}${normal} ${bold}is now the forwarding address for root mail${normal}"
		echo -n "${green}finalizing sendmail installation${normal} ... "
		# install aliases
		echo -e "mailer-daemon: postmaster
postmaster: root
nobody: root
hostmaster: root
usenet: root
news: root
webmaster: root
www: root
ftp: root
abuse: root
        root: ${admin_email}" >/etc/aliases
		newaliases >>"${OUTTO}" 2>&1 || _error "could not issue 'newaliases' command" && exit 1
		echo "${OK}"
	fi
}

function _nocsf() {
	if [[ ${csf} == "no" ]]; then
		echo "${cyan}Skipping Config Server Firewall Installation${normal} ... "
	fi
}

# if you're using cloudlfare as a protection and/or cdn - this next bit is important
function _askcloudflare() {
	echo -n "${bold}${yellow}Would you like to whitelist CloudFlare IPs?${normal} (${bold}${green}Y${normal}/n): "
	read -r responce
	case ${responce} in
	[yY] | [yY][Ee][Ss] | "") cloudflare=yes ;;
	[nN] | [nN][Oo]) cloudflare=no ;;
	*)
		echo "Invalid input..."
		_askcloudflare
		;;
	esac
}

function _cloudflare() {
	if [[ ${cloudflare} == "yes" ]]; then
		echo -n "${green}Whitelisting Cloudflare IPs-v4 and -v6${normal} ... "
		echo -e "# BEGIN CLOUDFLARE WHITELIST
# ips-v4
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
104.16.0.0/12
108.162.192.0/18
131.0.72.0/22
141.101.64.0/18
162.158.0.0/15
172.64.0.0/13
173.245.48.0/20
188.114.96.0/20
190.93.240.0/20
197.234.240.0/22
198.41.128.0/17
199.27.128.0/21
# ips-v6
2400:cb00::/32
2405:8100::/32
2405:b500::/32
2606:4700::/32
2803:f800::/32
# END CLOUDFLARE WHITELIST
        " >>/etc/csf/csf.allow
		echo "${OK}"
	fi
}

# install sendmail function (16)
function _asksendmail() {
	echo -n "${bold}${yellow}Do you want to install Sendmail?${normal} (${bold}${green}Y${normal}/n): "
	read -r responce
	case ${responce} in
	[yY] | [yY][Ee][Ss] | "") sendmail=yes ;;
	[nN] | [nN][Oo]) sendmail=no ;;
	*)
		echo "Invalid input..."
		_asksendmail
		;;
	esac
}

function _sendmail() {
	if [[ ${sendmail} == "yes" ]]; then
		echo "${green}Installing Sendmail ... ${normal}"
		apt-get -y install sendmail >>"${OUTTO}" 2>&1 || _error "could not install sendmail" && exit 1
		export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1
		# add administrator email
		echo "${magenta}Add an Administrator Email Below for Aliases Inclusion${normal}"
		read -rp "${bold}Email: ${normal}" admin_email
		echo
		echo "${bold}The email ${green}${bold}${admin_email}${normal} ${bold}is now the forwarding address for root mail${normal}"
		echo -n "${green}finalizing sendmail installation${normal} ... "
		# install aliases
		echo -e "mailer-daemon: postmaster
postmaster: root
nobody: root
hostmaster: root
usenet: root
news: root
webmaster: root
www: root
ftp: root
abuse: root
        root: ${admin_email}" >/etc/aliases
		newaliases >>"${OUTTO}" 2>&1 || _error "could not issue 'newaliases' command" && exit 1
		echo "${OK}"
	fi
}

function _nosendmail() {
	if [[ ${sendmail} == "no" ]]; then
		echo "${cyan}Skipping Sendmail Installation...${normal}"
	fi
}

#################################################################
# The following security & enhancements cover basic security
# measures to protect against common exploits.
# Enhancements covered are adding cache busting, cross domain
# font support, expires tags and protecting system files.
#
# You can find the included files at the following directory...
# /etc/nginx/server.configs/
#
# Not all profiles are included, review your $sitename.conf
# for additions made by the script & adjust accordingly.
#################################################################

# Round 1 - Location
# enhance configuration function (17)
function _locenhance() {
	if [[ ${sitename} == "yes" ]]; then
		locconf1="include server.configs\/location\/cache-busting.conf;"
		sed -i "s/locconf1/${locconf1}/g" "/etc/nginx/conf.d/${site_path}.conf"
		locconf2="include server.configs\/location\/cross-domain-fonts.conf;"
		sed -i "s/locconf2/${locconf2}/g" "/etc/nginx/conf.d/${site_path}.conf"
		locconf3="include server.configs\/location\/expires.conf;"
		sed -i "s/locconf3/${locconf3}/g" "/etc/nginx/conf.d/${site_path}.conf"
		locconf4="include server.configs\/location\/protect-system-files.conf;"
		sed -i "s/locconf4/${locconf4}/g" "/etc/nginx/conf.d/${site_path}.conf"
		locconf5="include server.configs\/location\/letsencrypt.conf;"
		sed -i "s/locconf5/${locconf5}/g" "/etc/nginx/conf.d/${site_path}.conf"
	else
		locconf1="include server.configs\/location\/cache-busting.conf;"
		sed -i "s/locconf1/${locconf1}/g" "/etc/nginx/conf.d/${hostname1}.conf"
		locconf2="include server.configs\/location\/cross-domain-fonts.conf;"
		sed -i "s/locconf2/${locconf2}/g" "/etc/nginx/conf.d/${hostname1}.conf"
		locconf3="include server.configs\/location\/expires.conf;"
		sed -i "s/locconf3/${locconf3}/g" "/etc/nginx/conf.d/${hostname1}.conf"
		locconf4="include server.configs\/location\/protect-system-files.conf;"
		sed -i "s/locconf4/${locconf4}/g" "/etc/nginx/conf.d/${hostname1}.conf"
		locconf5="include server.configs\/location\/letsencrypt.conf;"
		sed -i "s/locconf5/${locconf5}/g" "/etc/nginx/conf.d/${hostname1}.conf"
	fi
	echo "${OK}"
}

# Round 2 - Security
# optimize security configuration function (18)
function _security() {
	if [[ ${sitename} == "yes" ]]; then
		secconf1="include server.configs\/directives\/sec-bad-bots.conf;"
		sed -i "s/secconf1/${secconf1}/g" "/etc/nginx/conf.d/${site_path}.conf"
		secconf2="include server.configs\/directives\/sec-file-injection.conf;"
		sed -i "s/secconf2/${secconf2}/g" "/etc/nginx/conf.d/${site_path}.conf"
		secconf3="include server.configs\/directives\/sec-php-easter-eggs.conf;"
		sed -i "s/secconf3/${secconf3}/g" "/etc/nginx/conf.d/${site_path}.conf"
	else
		secconf1="include server.configs\/directives\/sec-bad-bots.conf;"
		sed -i "s/secconf1/${secconf1}/g" "/etc/nginx/conf.d/${hostname1}.conf"
		secconf2="include server.configs\/directives\/sec-file-injection.conf;"
		sed -i "s/secconf2/${secconf2}/g" "/etc/nginx/conf.d/${hostname1}.conf"
		secconf3="include server.configs\/directives\/sec-php-easter-eggs.conf;"
		sed -i "s/secconf3/${secconf3}/g" "/etc/nginx/conf.d/${hostname1}.conf"
	fi
	echo "${OK}"
}

# create self-signed certificate function (19)
function _askcert() {
	echo -n "${bold}${yellow}Do you want to generate an SSL cert and configure HTTPS?${normal} (${bold}${green}Y${normal}/n): "
	read -r responce
	case ${responce} in
	[yY] | [yY][Ee][Ss] | "") cert=yes ;;
	[nN] | [nN][Oo]) cert=no ;;
	*)
		echo "${bold}${red}Invalid input...${normal}"
		_askcert
		;;
	esac
}

function _cert() {
	if [[ ${cert} == "yes" ]]; then
		if [[ ${sitename} == "yes" ]]; then
			# Using Lets Encrypt for SSL deployment is currently being developed on VStacklet
			#git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
			openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/srv/www/${site_path}/ssl/${site_path}.key" -out "/srv/www/${site_path}/ssl/${site_path}.crt"
			chmod 400 "/etc/ssl/private/${site_path}.key"
			sed -i -e "s/# listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/g" \
				-e "s/# listen *:443 ssl http2;/listen *:443 ssl http2;/g" \
				-e "s/# include vstacklet\/directive-only\/ssl.conf;/include vstacklet\/directive-only\/ssl.conf;/g" \
				-e "s/# ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/ssl_certificate \/srv\/www\/${site_path}\/ssl\/${site_path}.crt;/g" \
				-e "s/# ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/ssl_certificate_key \/srv\/www\/${site_path}\/ssl\/${site_path}.key;/g" "/etc/nginx/conf.d/${site_path}.conf"
			sed -i "s/sitename/${site_path}/g" "/etc/nginx/conf.d/${site_path}.conf"
			#sed -i "s/sitename.crt/${site_path}_access/" /etc/nginx/conf.d/${site_path}.conf
			#sed -i "s/sitename.key/${site_path}_error/" /etc/nginx/conf.d/${site_path}.conf
			#sed -i "s/sitename.crt/${site_path}.crt/" /etc/nginx/conf.d/${site_path}.conf
			#sed -i "s/sitename.key/${site_path}.key/" /etc/nginx/conf.d/${site_path}.con
		else
			openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/srv/www/${hostname1}/ssl/${hostname1}.key" -out "/srv/www/${hostname1}/ssl/${hostname1}.crt"
			chmod 400 "/etc/ssl/private/${hostname1}.key"
			sed -i -e "s/# listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/g" \
				-e "s/# listen *:443 ssl http2;/listen *:443 ssl http2;/g" \
				-e "s/# include vstacklet\/directive-only\/ssl.conf;/include vstacklet\/directive-only\/ssl.conf;/g" \
				-e "s/# ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/ssl_certificate \/srv\/www\/${hostname1}\/ssl\/${hostname1}.crt;/g" \
				-e "s/# ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/ssl_certificate_key \/srv\/www\/${hostname1}\/ssl\/${hostname1}.key;/g" "/etc/nginx/conf.d/${hostname1}.conf"
			sed -i "s/sitename/${hostname1}/" "/etc/nginx/conf.d/${hostname1}.conf"
			#sed -i "s/sitename_access/${hostname1}_access/" /etc/nginx/conf.d/${hostname1}.conf
			#sed -i "s/sitename_error/${hostname1}_error/" /etc/nginx/conf.d/${hostname1}.conf
			#sed -i "s/sitename.crt/${hostname1}.crt/" /etc/nginx/conf.d/${hostname1}.conf
			#sed -i "s/sitename.key/${hostname1}.key/" /etc/nginx/conf.d/${hostname1}.conf
		fi
		echo "${OK}"
	fi
}

function _nocert() {
	#  if [[ ${cert} == "no" ]]; then
	if [[ ${sitename} == "yes" ]]; then
		sed -i "s/sitename/${site_path}/g" "/etc/nginx/conf.d/${site_path}.conf"
	else
		sed -i "s/sitename/${hostname1}/g" "/etc/nginx/conf.d/${hostname1}.conf"
	fi
}

# finalize and restart services function (20)
function _services() {
	service apache2 stop >>"${OUTTO}" 2>&1
	for i in ssh nginx varnish php${PHPVERSION}-fpm; do
		service "${i}" restart >>"${OUTTO}" 2>&1
		systemctl enable "${i}" >>"${OUTTO}" 2>&1
	done
	if [[ ${sendmail} == "yes" ]]; then
		service sendmail restart >>"${OUTTO}" 2>&1
	fi
	if [[ ${csf} == "yes" ]]; then
		service lfd restart >>"${OUTTO}" 2>&1
		csf -r >>"${OUTTO}" 2>&1
	fi
	echo "${OK}"
	echo
}

# function to show finished data (21)
function _finished() {
	echo
	echo
	echo
	echo '                                /\                 '
	echo '                               /  \                '
	echo '                          ||  /    \               '
	echo '                          || /______\              '
	echo '                          |||        |             '
	echo '                         |  |        |             '
	echo '                         |  |        |             '
	echo '                         |__|________|             '
	echo '                         |___________|             '
	echo '                         |  |        |             '
	echo '                         |__|   ||   |\            '
	echo '                          |||   ||   | \           '
	echo '                         /|||   ||   |  \          '
	echo '                        /_|||...||...|___\         '
	echo '                          |||::::::::|             '
	echo "                ${standout}ENJOY${reset_standout}     || \::::::/              "
	echo '                o /       ||  ||__||               '
	echo '               /|         ||    ||                 '
	echo '               / \        ||     \\_______________ '
	echo '           _______________||______`--------------- '
	echo
	echo
	echo "${black}${on_green}    [vstacklet] Varnish LEMP Stack Installation Completed    ${normal}"
	echo
	echo "${bold}Visit ${green}http://${server_ip}:8080/checkinfo.php${normal} ${bold}to verify your install. ${normal}"
	echo "${bold}Remember to remove the checkinfo.php file after verification. ${normal}"
	echo
	echo
	echo "${standout}INSTALLATION COMPLETED in ${FIN}/min ${normal}"
	echo
}

clear

S=$(date +%s)
OK=$(echo -e "[ ${bold}${green}DONE${normal} ]")

spinner() {
	local pid=$1
	local delay=0.25
	# shellcheck disable=SC2034,SC1003,SC2086,SC2312
	local spinstr='|/-\' # / = forward slash, \ = backslash

	while "$(ps a -o pid | awk '{ print $1 }' | grep "${pid}")"; do
		local temp=${spinstr#?}
		printf " [${bold}${yellow}%c${normal}]  " "${spinstr}"
		local spinstr=${temp}${spinstr%"${temp}"}
		sleep "${delay}"
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
	echo -ne "${OK}"
}

_warn() {
	echo "${bold}${red}WARNING: ${normal}${bold}$1${normal}"
}

_error() {
	echo "${bold}${red}ERROR: ${normal}${bold}$1${normal}"
}

# VSTACKLET STRUCTURE
_intro
_checkroot
_logcheck
_hostname
_asksitename
if [[ ${sitename} == yes ]]; then
	_sitename
elif [[ ${sitename} == no ]]; then
	_nositename
fi
_bashrc
_askcontinue
# Begin installer prompts
_askvarnish
_askphpversion
if [[ ${PHPVERSION} == "8.1" ]]; then
	_askmemcached
fi
if [[ ${PHPVERSION} == "5.6" ]]; then
	_askioncube
fi
_askmariadb
_askphpmyadmin
_askcsf
if [[ ${csf} == "yes" ]]; then
	_askcloudflare
fi
if [[ ${csf} == "no" ]]; then
	_asksendmail
fi
#_locale;
echo -n "${bold}Installing Common Software Properties${normal} ... " && _softcommon
echo -n "${bold}Installing: nano, unzip, dos2unix, htop, iotop, libwww-perl${normal} ... " && _depends
echo -n "${bold}Installing signed keys for MariaDB, Nginx, PHP, HHVM and Varnish${normal} ... " && _keys
echo -n "${bold}Adding trusted repositories${normal} ... " && _repos
_updates
if [[ ${varnish} == "yes" ]]; then
	_varnish
elif [[ ${varnish} == "no" ]]; then
	_novarnish
fi
if [[ ${PHPVERSION} == "8.1" ]]; then
	_php8
fi
if [[ ${PHPVERSION} == "5.6" ]]; then
	_php5
fi
if [[ ${PHPVERSION} == "HHVM" ]]; then
	_hhvm
fi
if [[ ${memcached} == "yes" ]]; then
	_memcached
elif [[ ${memcached} == "no" ]]; then
	_nomemcached
fi
if [[ ${ioncube} == "yes" ]]; then
	_ioncube
elif [[ ${ioncube} == "no" ]]; then
	_noioncube
fi
echo -n "${bold}Installing and Configuring Nginx${normal} ... " && _nginx
echo -n "${bold}Adjusting Permissions${normal} ... " && _perms
#echo -n "${bold}Installing and Configuring Varnish${normal} ... ";_varnish;
if [[ ${mariadb} == "yes" ]]; then
	echo -n "${bold}Installing MariaDB Drop-in Replacement${normal} ... " && _mariadb
elif [[ ${mariadb} == "no" ]]; then
	_nomariadb
fi
if [[ ${phpmyadmin} == "yes" ]]; then
	_phpmyadmin
elif [[ ${phpmyadmin} == "no" ]]; then
	_nophpmyadmin
fi
#_askcsf;
if [[ ${csf} == "yes" ]]; then
	_csf
elif [[ ${csf} == "no" ]]; then
	_nocsf
fi
if [[ ${cloudflare} == "yes" ]]; then
	_cloudflare
fi
if [[ ${sendmail} == "yes" ]]; then
	_sendmail
elif [[ ${sendmail} == "no" ]]; then
	_nosendmail
fi
echo "${bold}Addressing Location Edits: cache busting, cross domain font support,${normal}"
echo -n "${bold}expires tags, and system file protection${normal} ... " && _locenhance
echo "${bold}Performing Security Enhancements: protecting against bad bots,${normal}"
echo -n "${bold}file injection, and php easter eggs${normal} ... " && _security
#_askcert;
#if [[ ${cert} == "yes" ]]; then
#    _cert;
#elif [[ ${cert} == "no" ]]; then
_nocert
#fi
echo -n "${bold}Completing Installation & Restarting Services${normal} ... " && _services
E=$(date +%s)
DIFF=$(echo "${E}" - "${S}" | bc)
FIN=$(echo "${DIFF}" / 60 | bc)
_finished
