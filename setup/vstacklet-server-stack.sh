#!/bin/bash
##################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 3.1.1391
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
# Important Links:
# - :pencil: GITHUB REPO:   https://github.com/JMSDOnline/vstacklet
# - :bug: ISSUE TRACKER: https://github.com/JMSDOnline/vstacklet/issues
#
# :book: vStacklet Function Documentation:
# - [vstacklet::environment::init()](#vstackletenvironmentinit)
# - [vstacklet::args::process()](#vstackletargsprocess)
#   - [options](#options)
#   - [arguments](#arguments)
#   - [examples](#examples)
# - [vstacklet::environment::functions()](#vstackletenvironmentfunctions)
# - [vstacklet::environment::checkroot()](#vstackletenvironmentcheckroot)
# - [vstacklet::environment::checkdistro()](#vstackletenvironmentcheckdistro)
# - [vstacklet::intro()](#vstackletintro)
# - [vstacklet::log::check()](#vstackletlogcheck)
# - [vstacklet::bashrc::set()](#vstackletbashrcset)
# - [vstacklet::hostname::set()](#vstacklethostnameset)
#   - [options](#options-1)
#   - [arguments](#arguments-1)
#   - [examples](#examples-1)
# - [vstacklet::webroot::set()](#vstackletwebrootset)
#   - [options](#options-2)
#   - [arguments](#arguments-2)
#   - [examples](#examples-2)
# - [vstacklet::ssh::set()](#vstackletsshset)
#   - [options](#options-3)
#   - [arguments](#arguments-3)
#   - [examples](#examples-3)
# - [vstacklet::block::ssdp()](#vstackletblockssdp)
# - [vstacklet::update::packages()](#vstackletupdatepackages)
# - [vstacklet::locale::set()](#vstackletlocaleset)
# - [vstacklet::packages::softcommon()](#vstackletpackagessoftcommon)
# - [vstacklet::packages::depends()](#vstackletpackagesdepends)
# - [vstacklet::packages::keys()](#vstackletpackageskeys)
# - [vstacklet::apt::update()](#vstackletaptupdate)
# - [vstacklet::php::install()](#vstackletphpinstall)
#   - [options](#options-4)
#   - [arguments](#arguments-4)
#   - [examples](#examples-4)
# - [vstacklet::nginx::install()](#vstackletnginxinstall)
#   - [options](#options-5)
#   - [examples](#examples-5)
# - [vstacklet::hhvm::install()](#vstacklethhvminstall)
#   - [options](#options-6)
#   - [examples](#examples-6)
# - [vstacklet::permissions::adjust()](#vstackletpermissionsadjust)
# - [vstacklet::varnish::install()](#vstackletvarnishinstall)
#   - [options](#options-7)
#   - [arguments](#arguments-5)
#   - [examples](#examples-7)
# - [vstacklet::ioncube::install()](#vstackletioncubeinstall)
#   - [options](#options-8)
#   - [examples](#examples-8)
# - [vstacklet::mariadb::install()](#vstackletmariadbinstall)
#   - [options](#options-9)
#   - [arguments](#arguments-6)
#   - [examples](#examples-9)
# - [vstacklet::mysql::install()](#vstackletmysqlinstall)
#   - [options](#options10)
#   - [arguments](#arguments-7)
#   - [examples](#examples-10)
# - [vstacklet::phpmyadmin::install()](#vstackletphpmyadmininstall)
#   - [options](#options-11)
#   - [arguments](#arguments-8)
#   - [examples](#examples-11)
# - [vstacklet::csf::install()](#vstackletcsfinstall)
#   - [options](#options-12)
#   - [arguments](#arguments-9)
#   - [examples](#examples-12)
# - [vstacklet::sendmail::install()](#vstackletsendmailinstall)
#   - [options](#options-13)
#   - [parameters](#parameters)
#   - [examples](#examples-13)
# - [vstacklet::cloudflare::csf()](#vstackletcloudflarecsf)
#   - [options](#options-14)
#   - [examples](#examples-14)
# - [vstacklet::nginx::location()](#vstackletnginxlocation)
# - [vstacklet::nginx::security()](#vstackletnginxsecurity)
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
##################################################################################
# shellcheck disable=1091,2068,2312
##################################################################################
# @name: vstacklet::environment::init
# @description: Setup the environment and set variables.
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::init() {
	shopt -s extglob
	# first check if we can switch directories
	cd "${HOME}" || exit 1
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
	message_title=${bold}${green}
}

##################################################################################
# @name: vstacklet::args::process
# @description: Process the options and values passed to the script.
# @option: $1 - the option/flag to process
# @arg: $2 - the value of the option/flag
# @script-note: This function is required for the installation of
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
# @option: `-sendmailP | --sendmail_port` - port to use for the Sendmail server
#
# @option: `-wr | --web_root` - the web root directory to use for the server
# @option: `-wp | --wordpress` - install WordPress
#
# @option: `--reboot` - reboot the server after the installation
##################################################################################
# @example: ./vstacklet.sh --help
# @example: ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -h "yourhostname" -d "yourdomain.com" -php 8.1 -mc -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -csf -sendmail -wr "/var/www/html" -wp
# @example: ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -h "yourhostname" -d "yourdomain.com" -hhvm -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -sendmail -wr "/var/www/html" -wp --reboot
# @null
# @return_code: 1 - Please provide a valid email address to use for the sendmail alias required by CSF.
# @return_code: 2 - Please provide a valid domain name.
# @return_code: 3 - Please provide a valid port number for the FTP server.
# @return_code: 4 - Invalid FTP port number. Please enter a number between 1 and 65535.
# @return_code: 5 - The MariaDB password must be at least 8 characters long.
# @return_code: 6 - Please provide a valid port number for the MariaDB server.
# @return_code: 7 - Invalid MariaDB port number. Please enter a number between 1 and 65535.
# @return_code: 8 - The MySQL password must be at least 8 characters long.
# @return_code: 9 - The MySQL port must be a number.
# @return_code: 10 - Invalid MySQL port number. Please enter a number between 1 and 65535.
# @return_code: 11 - Invalid PHP version. Please enter either 7 (7.4), or 8 (8.1).
# @return_code: 13 - The HTTPS port must be a number.
# @return_code: 14 - Invalid HTTPS port number. Please enter a number between 1 and 65535.
# @return_code: 15 - The HTTP port must be a number.
# @return_code: 16 - Invalid HTTP port number. Please enter a number between 1 and 65535.
# @return_code: 17 - Invalid hostname. Please enter a valid hostname.
# @return_code: 18 - An email is needed to register the server aliases. Please set an email with ' -e your@email.com '
# @return_code: 19 - The Sendmail port must be a number.
# @return_code: 20 - Invalid Sendmail port number. Please enter a number between 1 and 65535.
# @return_code: 21 - The SSH port must be a number.
# @return_code: 22 - Invalid SSH port number. Please enter a number between 1 and 65535.
# @return_code: 23 - The Varnish port must be a number.
# @return_code: 24 - Invalid Varnish port number. Please enter a number between 1 and 65535.
# @return_code: 25 - Invalid web root. Please enter a valid path. (e.g. /var/www/html)
# @return_code: 26 - Invalid option(s): ${invalid_option[*]}
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
			declare -gi sendmail_skip="1"
			declare -gi csf="1"
			shift
			[[ -z ${email} ]] && _error "Please provide a valid email address to use for the sendmail alias required by CSF." && vstacklet::clean::rollback 1
			;;
		-d* | --domain*)
			declare -gi domain_ssl=1
			declare -g domain="${2}"
			shift
			shift
			[[ -n ${domain} && $(echo "${domain}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && _error "Please provide a valid domain name." && vstacklet::clean::rollback 2
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
			[[ -n ${ftp_port} && ${ftp_port} != ?(-)+([0-9]) ]] && _error "Please provide a valid port number for the FTP server." && vstacklet::clean::rollback 3
			[[ -n ${ftp_port} && ${ftp_port} -lt 1 || ${ftp_port} -gt 65535 ]] && _error "Invalid FTP port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 4
			[[ -z ${ftp_port} ]] && declare -gi ftp_port="21"
			;;
		-hhvm | --hhvm)
			declare -gi hhvm="1"
			shift
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
			[[ -n ${mariadb_password} && ${#mariadb_password} -lt 8 ]] && _error "The MariaDB password must be at least 8 characters long." && vstacklet::clean::rollback 5
			;;
		-mariadbP* | --mariadb_port*)
			declare -gi mariadb_port="${2}"
			shift
			shift
			[[ -n ${mariadb_port} && ${mariadb_port} != ?(-)+([0-9]) ]] && _error "Please provide a valid port number for the MariaDB server." && vstacklet::clean::rollback 6
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
			[[ -n ${mysql_port} && ${mysql_port} -lt 1 || ${mysql_port} -gt 65535 ]] && _error "Invalid MySQL port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 10
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
			[[ -n ${php} && ${php} != "7" && ${php} != "8" && ${php} != "7.4" && ${php} != "8.1" ]] && _error "Invalid PHP version. Please enter either 7 (7.4), or 8 (8.1)." && vstacklet::clean::rollback 11
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
			[[ -n ${https_port} && ${https_port} != ?(-)+([0-9]) ]] && _error "The HTTPS port must be a number." && vstacklet::clean::rollback 13
			[[ -n ${https_port} && ${https_port} -lt 1 || ${https_port} -gt 65535 ]] && _error "Invalid HTTPS port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 14
			[[ -z ${https_port} ]] && declare -gi https_port="443"
			;;
		-http* | --http_port*)
			declare -gi http_port="${2}"
			shift
			shift
			[[ -n ${http_port} && ${http_port} != ?(-)+([0-9]) ]] && _error "The HTTP port must be a number." && vstacklet::clean::rollback 15
			[[ -n ${http_port} && ${http_port} -lt 1 || ${http_port} -gt 65535 ]] && _error "Invalid HTTP port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 16
			[[ -z ${http_port} ]] && declare -gi http_port="80"
			;;
		-h* | --hostname*)
			declare -g hostname="${2}"
			shift
			shift
			[[ -n ${hostname} && $(echo "${hostname}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && _error "Invalid hostname. Please enter a valid hostname." && vstacklet::clean::rollback 17
			[[ -z ${hostname} ]] && declare -g hostname && hostname=$(echo "${server_hostname}" | cut -d. -f1)
			;;
		-redis | --redis)
			declare -gi redis="1"
			shift
			;;
		-sendmail | --sendmail)
			declare -gi sendmail="1"
			shift
			[[ -z ${email} ]] && _error "An email is needed to register the server aliases.
Please set an email with ' -e your@email.com '" && vstacklet::clean::rollback 18
			;;
		-sendmailP | --sendmail_port)
			declare -gi sendmail_port="${2}"
			shift
			shift
			[[ -n ${sendmail_port} && ${sendmail_port} != ?(-)+([0-9]) ]] && _error "The Sendmail port must be a number." && vstacklet::clean::rollback 19
			[[ -n ${sendmail_port} && ${sendmail_port} -lt 1 || ${sendmail_port} -gt 65535 ]] && _error "Invalid Sendmail port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 20
			[[ -z ${sendmail_port} ]] && declare -gi sendmail_port="25"
			;;
		-ssh* | --ssh_port*)
			declare -gi ssh_port="${2}"
			shift
			shift
			[[ -n ${ssh_port} && ${ssh_port} != ?(-)+([0-9]) ]] && _error "The SSH port must be a number." && vstacklet::clean::rollback 21
			[[ -n ${ssh_port} && ${ssh_port} -lt 1 || ${ssh_port} -gt 65535 ]] && _error "Invalid SSH port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 22
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
			[[ -n ${varnish_port} && ${varnish_port} != ?(-)+([0-9]) ]] && _error "The Varnish port must be a number." && vstacklet::clean::rollback 23
			[[ -n ${varnish_port} && ${varnish_port} -lt 1 || ${varnish_port} -gt 65535 ]] && _error "Invalid Varnish port number. Please enter a number between 1 and 65535." && vstacklet::clean::rollback 24
			[[ -z ${varnish_port} ]] && declare -gi varnish_port=6081
			;;
		-wr* | --web_root*)
			declare -g web_root="${2}"
			shift
			shift
			[[ -n ${web_root} && $(sed -e 's/[\\/]/\\/g;s/[\/\/]/\\\//g;' <<<"${web_root}") == "" ]] && _error "Invalid web root. Please enter a valid path. (e.g. /var/www/html)" && vstacklet::clean::rollback 25
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
	[[ ${#invalid_option[@]} -gt 0 ]] && _error "Invalid option(s): ${invalid_option[*]}" && vstacklet::clean::rollback 26
}

##################################################################################
# @name: vstacklet::environment::functions
# @description: Stage various functions for the setup environment.
# @script-note: This function is required for the installation of
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
# @name: vstacklet::environment::checkdistro
# @description: Check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::checkdistro() {
	declare -g codename distro
	declare -a allowed_codename=("bionic" "focal" "stretch" "buster" "bullseye")
	codename=$(lsb_release -cs)
	distro=$(lsb_release -is)
	if ! vstacklet::array::contains "${codename}" "supported distro" ${allowed_codename[@]}; then
		declare allowed_codename_string="${allowed_codename[*]}"
		echo "supported distros: "
		echo "${allowed_codename_string//${IFS:0:1}/, }"
		_error "Unsupported distro. Please use Ubuntu 18.04/20.04 or Debian 9/10/11." && vstacklet::clean::rollback 27
	fi
}

##################################################################################
# @name: vstacklet::environment::checkroot
# @description: Check if the user is root.
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(id -u) != 0 ]] && _error "You must be root to run this script." && vstacklet::clean::rollback 28
	[[ $(id -u) == 0 ]] && _success "Congrats! You're running as root. Let's continue..."
}

##################################################################################
# @name: vstacklet::intro (1)
# @description: Prints the intro message
# @script-note: This function is required for the installation of
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
# @description: Check if the log file exists and create it if it doesn't.
# @noargs:
# @nooptions:
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::log::check() {
	_info "Checking log file..."
	declare -g log_file vslog
	log_file="/var/log/vstacklet/vstacklet.${PPID}.log"
	if [[ ! -d /var/log/vstacklet ]]; then
		mkdir -p /var/log/vstacklet
	fi
	rm -f /var/log/vstacklet/vstacklet.*.log
	if [[ ! -f ${log_file} ]]; then
		touch "${log_file}"
		vslog="/var/log/vstacklet/vstacklet.${PPID}.log"
		echo "${bold}Output is being sent to /var/log/vstacklet/vstacklet.${magenta}${PPID}${normal}${bold}.log${normal}"
	fi
	_info "Setting up /root/tmp mount..."
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
# @description: Set ~/.bashrc and ~/.profile for vstacklet.
# @nooptions:
# @noargs:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::bashrc::set() {
	_info "Setting ~/.bashrc and ~/.profile for vstacklet"
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
# @description: Set system hostname.
#
# notes:
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
		echo "${bold}Setting hostname to ${magenta}${hostname}${normal}${bold} ...${normal}"
		hostnamectl set-hostname "${hostname}" >>"${vslog}" 2>&1
	fi
	if [[ -z ${hostname} && -n ${domain} ]]; then
		echo "${bold}Setting hostname name to ${magenta}${domain}${normal}${bold} ...${normal}"
		hostnamectl set-hostname "${domain}" >>"${vslog}" 2>&1
	fi
	if [[ -z ${hostname} && -z ${domain} ]]; then
		echo "${bold}Setting hostname to ${magenta}${server_hostname}${normal}${bold} ...${normal}"
		hostnamectl set-hostname "${server_hostname}" >>"${vslog}" 2>&1
	fi
}

##################################################################################
# @name: vstacklet::webroot::set (6)
# @description: Set main web root directory.
#
# notes:
# - if the directory already exists, it will be used.
# - if the directory does not exist, it will be created.
# - the addition of subdirectories will be handled by the vStacklet software.
#   the subdirectories created in the web root directory will be:
#   - ~/public
#   - ~/logs
#   - ~/ssl
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
		echo "${bold}Setting web root directory to ${magenta}/var/www/html/${normal}${bold} ...${normal}"
		(
			mkdir -p /var/www/html/{public,logs,ssl}
			chown -R www-data:www-data /var/www/html
			chmod -R 755 /var/www/html
		) >>"${vslog}" 2>&1
	fi
}

##################################################################################
# @name: vstacklet::ssh::set (7)
# @description: Set ssh port to custom port (if nothing is set, default port is 22)
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
# @description: Blocks an insecure port 1900 that may lead to
# DDoS masked attacks. Only remove this function if you absolutely
# need port 1900. In most cases, this is a junk port.
# @noargs:
# @nooptions:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::block::ssdp() {
	(
		_info "Blocking port 1900 ..."
		iptables -A INPUT -p udp --dport 1900 -j DROP
		iptables -A INPUT -p tcp --dport 1900 -j DROP
		iptables-save >>/etc/iptables/rules.v4
	) >>"${vslog}" 2>&1 || { _warn "Failed to block port 1900"; }
}

##################################################################################
# @name: vstacklet::update::packages (14)
# @description: This function updates the package list and upgrades the system.
# @noargs:
# @nooptions:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::update::packages() {
	_info "Updating package list ..."
	(
		apt-get update -y
		apt-get upgrade -y
		apt-get autoremove -y
		apt-get autoclean -y
		apt-get clean -y
	) >>"${vslog}" 2>&1 || { _error "Failed to update packages" && vstacklet::clean::rollback 29; }
	if lsb_release 2>/dev/null; then
		_success "lsb_release is installed, continuing..."
	else
		apt-get install -y lsb-release >>"${vslog}" 2>&1
		if [[ -e /usr/bin/lsb_release ]]; then
			_success "lsb_release installed successfully, continuing..."
		else
			_error "lsb_release failed to install, exiting..." && vstacklet::clean::rollback 29
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
	echo -n "Updating new package sources, please wait..."
	if [[ ${distro} == "Debian" ]]; then
		export DEBIAN_FRONTEND=noninteractive
		(
			yes '' | apt-get -y update
			apt-get -u purge samba samba-common
			yes '' | apt-get -y upgrade
		) >>"${vslog}" 2>&1 || { _error "Failed to update new source packages" && vstacklet::clean::rollback 30; }
	else
		export DEBIAN_FRONTEND=noninteractive
		(
			apt-get -y update
			apt-get -y purge samba samba-common
			apt-get -y upgrade
		) >>"${vslog}" 2>&1 || { _error "Failed to update new source packages" && vstacklet::clean::rollback 30; }
	fi
	clear
}

##################################################################################
# @name: vstacklet::locale::set (5) ? vstacklet::locale::set::en_US.UTF-8 (15)
# @description: This function sets the locale to en_US.UTF-8
# and sets the timezone to UTC.
#
# todo: This function is still a work in progress.
# - [ ] implement arguments to set the locale
# - [ ] implement arguments to set the timezone (or a seperate function)
# @noargs
# @nooptions
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::locale::set() {
	_info "Setting locale to en_US.UTF-8 ..."
	apt-get -y install language-pack-en-base >>"${vslog}" 2>&1
	if [[ -e /usr/sbin/locale-gen ]]; then
		(
			locale-gen en_US.UTF-8
			dpkg-reconfigure locales
		) >>"${vslog}" 2>&1 || { _error "Failed to set locale" && vstacklet::clean::rollback 31; }
	else
		(
			apt-get -y update
			apt-get -y install locales locale-gen
			locale-gen en_US.UTF-8
			dpkg-reconfigure locales
		) >>"${vslog}" 2>&1 || { _error "Failed to set locale" && vstacklet::clean::rollback 31; }

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
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::packages::softcommon() {
	# package and repo addition (a) _install common properties_
	apt-get -y install software-properties-common python-software-properties apt-transport-https >>"${vslog}" 2>&1 || { _error "Failed to install common properties" && vstacklet::clean::rollback 32; }
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::packages::depends (7)
# @description: This function installs the required software packages
# for the vStacklet software.
# @nooptions:
# @noargs:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::packages::depends() {
	# package and repo addition (b) _install softwares and packages_
	apt-get -y install nano unzip git dos2unix htop iotop bc libwww-perl dnsutils curl sudo rsync >>"${vslog}" 2>&1 || { _error "Failed to install required packages" && vstacklet::clean::rollback 33; }
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::packages::keys (8)
# @description: This function sets the required software package keys
# and sources for the vStacklet software.
#
# notes:
# - keys and sources are set for the following software packages:
#   - hhvm (only if option `-hhvm|--hhvm` is set)
#   - nginx (only if option `-nginx|--nginx` is set)
#   - varnish (only if option `-varnish|--varnish` is set)
#   - php (only if option `-php|--php` is set)
#   - mariadb (only if option `-mariadb|--mariadb` is set)
#   - redis (only if option `-redis|--redis` is set)
#   - postgresql (only if option `-postgre|--postgresql` is set)
# - apt-key is being deprecated, using gpg instead
# @nooptions:
# @noargs:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::packages::keys() {
	# package and repo addition (c) _add signed keys_
	_info "Adding signed keys and sources for required software packages ... "
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
deb [arch=amd64,i386,arm64,ppc64el] http://mirrors.syringanetworks.net/mariadb/repo/10.6/${distro} ${codename} main
deb-src http://mirrors.syringanetworks.net/mariadb/repo/10.6/${distro}/ ${codename} main
EOF
	fi
	# Remove excess sources known to
	# cause issues with conflicting package sources
	[[ -f "/etc/apt/sources.list.d/proposed.list" ]] && mv -f /etc/apt/sources.list.d/proposed.list /etc/apt/sources.list.d/proposed.list.BAK
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::apt::update (9)
# @description: Update apt sources and packages - this is a wrapper for apt-get update
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
		_error "Failed to update system"
		vstacklet::clean::rollback 34
	}
	(
		DEBIAN_FRONTEND=noninteractive apt-get -y upgrade >>"${vslog}" 2>&1
	) || {
		_error "Failed to upgrade system"
		vstacklet::clean::rollback 35
	}
	(
		apt-get -y autoremove
		apt-get -y autoclean
	) >>"${vslog}" 2>&1 || {
		_error "Failed to clean system"
		vstacklet::clean::rollback 36
	}
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::php::install (11)
# @description: Install PHP and PHP modules.
#
# notes:
# - versioning:
#   - php < "7.4" - not supported, deprecated
#   - php = "7.4" - supported
#   - php = "8.0" - superceded by php="8.1"
#   - php = "8.1" - supported
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
		# check for hhvm
		[[ -n ${hhvm} ]] && _error "PHP and HHVM cannot be installed at the same time. Please choose one or the other." && vstacklet::clean::rollback 37
		# check for nginx \\ to maintain modularity, nginx is not required for PHP
		#[[ -z ${nginx} ]] && _error "PHP requires nginx. Please install nginx." && vstacklet::clean::rollback
		# php version sanity check
		[[ ${php} == *"8"* ]] && php="8.1"
		[[ ${php} == *"7"* ]] && php="7.4"
		_info "Installing and Adjusting php${magenta}php${php}-fpm${normal}-fpm w/ OPCode Cache ... "
		# install php dependencies and php
		(
			apt-get -y install "php${php}-fpm" "php${php}-zip" "php${php}-cgi" "php${php}-cli" "php${php}-common" "php${php}-curl" "php${php}-dev" "php${php}-gd" "php${php}-bcmath" "php${php}-gmp" "php${php}-imap" "php${php}-intl" "php${php}-ldap" "php${php}-mbstring" "php${php}-mysql" "php${php}-opcache" "php${php}-pspell" "php${php}-readline" "php${php}-soap" "php${php}-xml" "php${php}-imagick" "php${php}-msgpack" "php${php}-igbinary" "libmcrypt-dev" "mcrypt" >>"${vslog}" 2>&1
		) || { _error "Failed to install PHP${php}" && vstacklet::clean::rollback 38; }
		if [[ -n ${memcached} ]]; then
			# memcached
			(
				apt-get -y install "php${php}-memcached" >>"${vslog}" 2>&1
			) || { _error "Failed to install PHP${php} Memcached" && vstacklet::clean::rollback 39; }
		fi
		if [[ -n ${redis} ]]; then
			# redis
			(
				apt-get -y install "php${php}-redis" >>"${vslog}" 2>&1
			) || { _error "Failed to install PHP${php} Redis" && vstacklet::clean::rollback 40; }
		fi
		# tweak php.ini
		_info "Tweaking php.ini ... "
		declare -a php_files=("/etc/php/${php}/fpm/php.ini" "/etc/php/${php}/cli/php.ini")
		# shellcheck disable=SC2215
		for file in "${php_files[@]}"; do
			sed -i.bak -e "s/.*post_max_size =.*/post_max_size = 92M/" -e "s/.*upload_max_filesize =.*/upload_max_filesize = 92M/" -e "s/.*expose_php =.*/expose_php = Off/" -e "s/.*memory_limit =.*/memory_limit = 768M/" -e "s/.*session.cookie_secure =.*/session.cookie_secure = 1/" -e "s/.*session.cookie_httponly =.*/session.cookie_httponly = 1/" -e "s/.*session.cookie_samesite =.*/cookie_samesite.cookie_secure = Lax/" -e "s/.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/" -e "s/.*opcache.enable=.*/opcache.enable=1/" -e "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" -e "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" "${file}"
		done
		sleep 3
		# enable modules
		_info "Enabling PHP Modules ... "
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
# @description: Install NGinx and configure.
# @option: $1 - `-nginx | --nginx` (optional) (takes no arguments)
# @example: ./vstacklet.sh -nginx
# ./vstacklet.sh --nginx
# @break
##################################################################################
vstacklet::nginx::install() {
	if [[ -n ${nginx} ]]; then
		_info "Installing and Adjusting ${magenta}nginx${normal} ... "
		(
			apt-get -y install nginx >>"${vslog}" 2>&1
		) || { _error "Failed to install nginx" && vstacklet::clean::rollback 41; }
		systemctl stop nginx >>"${vslog}" 2>&1
		mv /etc/nginx /etc/nginx-pre-vstacklet
		mkdir -p /etc/nginx/{conf.d,cache,ssl}
		sleep 3
		rsync -aP --exclude=/pagespeed --exclude=LICENSE --exclude=README --exclude=.git "${vstacklet_base_path}/nginx"/* /etc/nginx/ >>"${vslog}" 2>&1
		\cp -rf /etc/nginx-pre-vstacklet/uwsgi_params /etc/nginx-pre-vstacklet/fastcgi_params /etc/nginx/
		chown -R www-data:www-data /etc/nginx/cache
		chmod -R 755 /etc/nginx/cache
		sh -c 'find /etc/nginx -type f -exec chmod 644 {} \;'
		chmod -R g+rw /etc/nginx/cache
		sh -c 'find /etc/nginx/cache -type d -print0 | sudo xargs -0 chmod g+s'
		# import nginx reverse config files from vStacklet
		if [[ -n ${domain} ]]; then
			if [[ ${php} == *"8"* ]]; then
				cp -f "${local_php8_dir}nginx/conf.d/default.php8.conf.save" "/etc/nginx/conf.d/${domain}.conf"
			fi
			if [[ ${php} == *"7"* ]]; then
				cp -f "${local_php7_dir}nginx/conf.d/default.php7.conf.save" "/etc/nginx/conf.d/${domain}.conf"
			fi
			if [[ -n ${hhvm} ]]; then
				cp -f "${local_hhvm_dir}nginx/conf.d/default.hhvm.conf.save" "/etc/nginx/conf.d/${domain}.conf"
			fi
		else
			if [[ ${php} == *"8"* ]]; then
				default="vsdefault"
				cp -f "${local_php8_dir}nginx/conf.d/default.php8.conf.save" "/etc/nginx/conf.d/${default}.conf"
			fi
			if [[ ${php} == *"7"* ]]; then
				default="vsdefault"
				cp -f "${local_php7_dir}nginx/conf.d/default.php7.conf.save" "/etc/nginx/conf.d/${default}.conf"
			fi
			if [[ -n ${hhvm} ]]; then
				default="vsdefault"
				cp -f "${local_hhvm_dir}nginx/conf.d/default.hhvm.conf.save" "/etc/nginx/conf.d/${default}.conf"
			fi
		fi
		# stage checkinfo.php for verification
		_info "Staging checkinfo.php ... "
		if [[ -n ${web_root} ]]; then
			echo '<?php phpinfo(); ?>' >"${web_root}/public/checkinfo.php" || { _error "Failed to stage checkinfo.php" && vstacklet::clean::rollback 42; }
			chown -R www-data:www-data "${web_root}"
			chmod -R 755 "${web_root}"
			chmod -R g+rw "${web_root}"
			sh -c 'find "${web_root}" -type d -print0 | sudo xargs -0 chmod g+s'
		else
			echo '<?php phpinfo(); ?>' >/var/www/html/public/checkinfo.php || { _error "Failed to stage checkinfo.php" && vstacklet::clean::rollback 42; }
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
# @description: Install HHVM and configure.
#
# notes:
# - HHVM is not compatible with PHP, so choose one or the other.
# @option: $1 - `-hhvm | --hhvm` (optional) (takes no arguments)
# @example: ./vstacklet.sh -hhvm
# ./vstacklet.sh --hhvm
# @break
##################################################################################
vstacklet::hhvm::install() {
	if [[ -n ${hhvm} && -z ${php} ]]; then
		# check for php
		[[ -n ${php} ]] && _error "HHVM and PHP cannot be installed at the same time. Please choose one or the other." && vstacklet::clean::rollback 43
		# check for nginx \\ to maintain modularity, nginx is not required for HHVM
		#[[ -z ${nginx} ]] && _error "HHVM requires nginx. Please install nginx." && vstacklet::clean::rollback
		# install hhvm
		_info "Installing and Adjusting ${magenta}hhvm${normal} ... "
		(
			apt-get -y install hhvm
			/usr/share/hhvm/install_fastcgi.sh
		) >>"${vslog}" 2>&1 || { _error "Failed to install hhvm" && vstacklet::clean::rollback 44; }
		/usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60 >>"${vslog}" 2>&1 || { _error "Failed to update php alternatives" && vstacklet::clean::rollback 44; }
		# get off the port and use socket - vStacklet nginx configurations already know this
		cp -f "${local_hhvm_dir}server.ini.template" /etc/hhvm/server.ini
		cp -f "${local_hhvm_dir}php.ini.template" /etc/hhvm/php.ini
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::permissions::adjust (14)
# @description: Adjust permissions for the web root.
#
# notes:
# - Permissions are adjusted based the following variables:
#   - adjustments are made to the assigned web root on the `-wr | --web-root`
#    option
#   - adjustments are made to the default web root of `/var/www/html`
#   if the `-wr | --web-root` option is not used
# - permissions are adjusted to the following:
#   - `www-data:www-data` (user:group)
#   - `755` (directory)
#   - `644` (file)
#   - `g+rw` (group read/write)
#   - `g+s` (group sticky)
# @nooptions:
# @noargs:
# @return: none
# @break
##################################################################################
vstacklet::permissions::adjust() {
	_info "Adjusting permissions ... "
	if [[ -n ${web_root} ]]; then
		chown -R www-data:www-data "${web_root}"
		chmod -R 755 "${web_root}"
		sh -c 'find "${web_root}" -type f -print0 | sudo xargs -0 chmod 644'
		chmod -R g+rw "${web_root}"
		sh -c 'find "${web_root}" -type d -print0 | sudo xargs -0 chmod g+s'
	else
		chown -R www-data:www-data /var/www/html
		chmod -R 755 /var/www/html
		sh -c 'find /var/www/html -type f -print0 | sudo xargs -0 chmod 644'
		chmod -R g+rw /var/www/html
		sh -c 'find /var/www/html -type d -print0 | sudo xargs -0 chmod g+s'
	fi
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::varnish::install (15)
# @description: Install Varnish and configure.
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
# @script-note: varnish is installed based on the following variables:
# - `-varnish` (optional) (default: nginx)
# - `-varnishP|--varnish_port` (optional) (default: 6081)
# - `-http|--http_port` (optional) (default: 80)
# - if you are not familiar with Varnish, please read the following:
#   - https://www.varnish-cache.org/
# @break
##################################################################################
vstacklet::varnish::install() {
	if [[ -n ${varnish} ]]; then
		_info "Installing and Adjusting ${magenta}varnish${normal} ... "
		(
			apt-get -y install varnish
		) >>"${vslog}" 2>&1 || { _error "Failed to install varnish" && vstacklet::clean::rollback 45; }
		cd /etc/varnish || _error "/etc/varnish does not exist" && vstacklet::clean::rollback 46
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
		) >>"${vslog}" 2>&1 || { _warn "Failed to reload systemctl service daemon" && vstacklet::clean::rollback 47; }
		cd "${HOME}" || _error "Failed to change directory to ${HOME}" && vstacklet::clean::rollback 48
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
# @description: Install ioncube loader.
#
# notes:
# - the ioncube loader will be available for the php version specified
#   from the `-php | --php` option.
# @option: $1 - `-ioncube | --ioncube` (optional) (takes no arguments)
# @example: ./vstacklet.sh -ioncube -php 8.1
# ./vstacklet.sh --ioncube --php 8.1
# ./vstacklet.sh -ioncube -php 7.4
# ./vstacklet.sh --ioncube --php 7.4
# @break
##################################################################################
vstacklet::ioncube::install() {
	if [[ -n ${ioncube} ]]; then
		_info "Installing IonCube Loader for PHP-${magenta}${php}${normal} ... "
		(
			apt-get -y install php${php}-dev git pkg-config build-essential libmemcached-dev
			apt-get -y install php-memcached memcached
		) >>"${vslog}" 2>&1 || { _error "Failed to install php-memcached and memcached" 49; }
		# install ioncube loader for php 7.4
		if [[ ${php} == "7.4" ]]; then
			(
				cd /tmp || _error "Failed to change directory to /tmp" && vstacklet::clean::rollback 50
				wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
				tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
				cd ioncube || _error "Failed to change directory to /tmp/ioncube" && vstacklet::clean::rollback 51
				cp -f ioncube_loader_lin_7.4.so /usr/lib/php/20190902/ || _error "Failed to copy ioncube_loader_lin_7.4.so to /usr/lib/php/20190902/" && vstacklet::clean::rollback 52
				echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" >/etc/php/7.4/mods-available/ioncube.ini
				ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/cli/conf.d/20-ioncube.ini
				ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/fpm/conf.d/20-ioncube.ini
				phpenmod -v 7.4 ioncube
				systemctl restart php7.4-fpm
				systemctl restart apache2
			) >>"${vslog}" 2>&1 || { _error "Failed to install ioncube loader for php 7.4" && vstacklet::clean::rollback 53; }
		fi
		# install ioncube loader for php 8.1
		if [[ ${php} == "8.1" ]]; then
			(
				cd /tmp || _error "Failed to change directory to /tmp" && vstacklet::clean::rollback 50
				wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
				tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
				cd ioncube || _error "Failed to change directory to /tmp/ioncube" && vstacklet::clean::rollback 51
				cp -f ioncube_loader_lin_8.1.so /usr/lib/php/20210902/ || _error "Failed to copy ioncube_loader_lin_8.1.so to /usr/lib/php/20210902/" && vstacklet::clean::rollback 52
				echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" >/etc/php/8.1/mods-available/ioncube.ini
				{ echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" >>"$(php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||")"; } || { _warn "Failed to add ioncube loader to php.ini"; }
				ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/cli/conf.d/20-ioncube.ini
				ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/fpm/conf.d/20-ioncube.ini
				phpenmod -v 8.1 ioncube
			) >>"${vslog}" 2>&1 || { _error "Failed to install ioncube loader for php 8.1" && vstacklet::clean::rollback 53; }
		fi
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::mariadb::install (17)
# @description: Install mariaDB and configure.
#
# notes:
# - if `-mysql | --mysql` is specified, then mariadb will not be installed. choose either mariadb or mysql.
# - actual mariadb version installed is 10.6.+ LTS.
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
	if [[ -n ${mariadb} && -z ${mysql} ]]; then
		[[ -z ${mariadb_port} ]] && declare mariadb_port="3306"
		[[ -z ${mariadb_user} ]] && declare mariadb_user="root"
		[[ -z ${mariadb_password} ]] && declare mariadb_password && mariadb_password="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		_inf "Installing MariaDB ... "
		(
			DEBIAN_FRONTEND=noninteractive apt-get --allow-unauthenticated -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install mariadb-server mariadb-client
		) >>"${vslog}" 2>&1 || { _error "Failed to install MariaDB" && vstacklett::rollback::cleanup 54; }
		# configure mariadb
		_info "Configuring MariaDB ... "
		# set mariadb root password
		mysqladmin -u root password "${mariadb_password}" >>"${vslog}" 2>&1 || { _error "Failed to set MariaDB root password" && vstacklet::clean::rollback 55; }
		# create mariadb user
		mysql -u root -p"${mariadb_password}" -e "CREATE USER '${mariadb_user}'@'localhost' IDENTIFIED BY '${mariadb_password}';" >>"${vslog}" 2>&1 || { _error "Failed to create MariaDB user" && vstacklet::clean::rollback 56; }
		# grant privileges to mariadb user
		mysql -u root -p"${mariadb_password}" -e "GRANT ALL PRIVILEGES ON *.* TO '${mariadb_user}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || { _error "Failed to grant privileges to MariaDB user" && vstacklet::clean::rollback 57; }
		# flush privileges
		mysql -u root -p"${mariadb_password}" -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || { _error "Failed to flush privileges" && vstacklet::clean::rollback 58; }
		# set mariadb client and server configuration
		{
			echo -e "[client]"
			echo -e "port = ${mariadb_port}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "[mysqld]"
			echo -e "port = ${mariadb_port}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"

		} >/etc/mysql/conf.d/vstacklet.cnf || { _error "Failed to set MariaDB client and server configuration" && vstacklet::clean::rollback 59; }
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
# @name: vstacklet::mysql::install (18)
# @description: Install mySQL and configure.
#
# notes:
# - if `-mariadb | --mariadb` is specified, then mysql will not be installed. choose either mysql or mariadb.
# - apt-deb mysql version is 0.8.24-1_all.deb
# - actual mysql version installed is 8.0.+
# @option: $1 - `-mysql | --mysql` (optional) (takes no arguments)
# @option: $2 - `-mysqlP | --mysql_port` (optional) (takes one argument)
# @option: $3 - `-mysqlU | --mysql_user` (optional) (takes one argument)
# @option: $4 - `-mysqlPw | --mysql_password` (optional) (takes one argument)
# @arg: $2 - `[mysql_port]` (optional) (default: 3306)
# @arg: $3 - `[mysql_user]` (optional) (default: root)
# @arg: $4 - `[mysql_password]` (optional) (default: password auto-generated)
# @example: ./vstacklet.sh -mysql -mysqlP 3306 -mysqlU root -mysqlPw password
# ./vstacklet.sh --mysql --mysql_port 3306 --mysql_user root --mysql_password password
# @break
##################################################################################
vstacklet::mysql::install() {
	if [[ -n ${mysql} && -z ${mariadb} ]]; then
		mysql_deb_version="mysql-apt-config_0.8.24-1_all.deb"
		[[ -z ${mysql_port} ]] && declare mysql_port="3306"
		[[ -z ${mysql_user} ]] && declare mysql_user="root"
		[[ -z ${mysql_password} ]] && declare mysql_password && mysql_password="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		_info "Installing MySQL ... "
		wget -qO - "https://dev.mysql.com/get/mysql-apt-config_${mysql_deb_version}_all.deb" -O "/tmp/mysql-apt-config_${mysql_deb_version}_all.deb" >>"${vslog}" 2>&1 || { _error "Failed to download mysql-apt-config_${mysql_deb_version}_all.deb" && vstacklet::clean::rollback 60; }
		(
			DEBIAN_FRONTEND=noninteractive dpkg -i "/tmp/mysql-apt-config_${mysql_deb_version}_all.deb"
			DEBIAN_FRONTEND=noninteractive apt-get -y update
			DEBIAN_FRONTEND=noninteractive apt-get --allow-unauthenticated -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install mysql-server mysql-client
		) >>"${vslog}" 2>&1 || { _error "Failed to install MySQL" && vstacklet::clean::rollback 61; }
		# configure mysql
		_info "Configuring MySQL ... "
		# set mysql root password
		mysqladmin -u root password "${mysql_password}" >>"${vslog}" 2>&1 || { _error "Failed to set MySQL root password" && vstacklet::clean::rollback 62; }
		# create mysql user
		mysql -u root -p"${mysql_password}" -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_password}';" >>"${vslog}" 2>&1 || { _error "Failed to create MySQL user" && vstacklet::clean::rollback 63; }
		# grant privileges to mysql user
		mysql -u root -p"${mysql_password}" -e "GRANT ALL PRIVILEGES ON *.* TO '${mysql_user}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || { _error "Failed to grant privileges to MySQL user" && vstacklet::clean::rollback 64; }
		# flush privileges
		mysql -u root -p"${mysql_password}" -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || { _error "Failed to flush privileges" && vstacklet::clean::rollback 65; }
		# set mysql client and server configuration
		{
			echo -e "[client]"
			echo -e "port = ${mysql_port}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "[mysqld]"
			echo -e "port = ${mysql_port}"
			echo -e "socket = /var/run/mysql/mysql.sock"
			echo -e "bind-address = 127.0.0.1"
		} >/etc/mysql/conf.d/vstacklet.cnf || { _error "Failed to set MySQL client and server configuration" && vstacklet::clean::rollback 66; }
		echo "configuration file saved to /etc/mysql/conf.d/vstacklet.cnf"
		echo "mysql client and server configuration set to:"
		cat /etc/mysql/conf.d/vstacklet.cnf
		echo "mysql root password: ${mysql_password}"
		echo "mysql user: ${mysql_user}"
		echo "mysql port: ${mysql_port}"
		echo
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::phpmyadmin::install (19)
# @description: Install phpMyAdmin and configure.
#
# notes:
# - phpMyAdmin no longer supports HHVM due to the project now just focusing on
#   their own Hack language rather than PHP compatibility.
# - phpMyAdmin requires a web server to run. You must select a web server from the list below.
#   - nginx
#   - varnish
# - phpMyAdmin requires a database server to run. You must select a database server from the list below.
#   - mariadb
#   - mysql
# - phpMyAdmin requires php to run. You must select a php version from the list below.
#   - 8.1
#   - 7.4
# - phpMyAdmin requires a web port to run. This argmuent is supplied by the `-http | --http_port` option.
# - phpMyAdmin will use the following options to configure itself:
#   - web server: nginx, varnish
#     - Nginx usage: `-nginx | --nginx`
#     - Varnish usage: `-varnish | --varnish`
#   - database server: mariadb, mysql
#     - mariaDB usage: `-mariadbU [user] | --mariadb_user [user]` & `-mariadbPw [password] | --mariadb_password [password]`
#     - mysql usage: `-mysqlU [user] | --mysql_user [user]` & `-mysqlPw [password] | --mysql_password [password]`
#     - note: if no user or password is provided, the default user and password will be used. (root, auto-generated password)
#   - php version: php7.4, php8.1
#     - PHP usage: `-php [version] | --php [version]`
#   - port: http
#     - usage: `-http [port] | --http [port]`
#     - note: if no port is provided, the default port will be used. (80)
# @option: $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments) (default: not installed)
# @arg: `-phpmyadmin | --phpmyadmin` does not take any arguments. However, it requires the options as expressed above.
# @example: ./vstacklet.sh -phpmyadmin -nginx -mariadbU root -mariadbPw password -php 8.1 -http 80
# ./vstacklet.sh --phpmyadmin --nginx --mariadb_user root --mariadb_password password --php 8.1 --http 80
# ./vstacklet.sh -phpmyadmin -varnish -mysqlU root -mysqlPw password -php 7.4 -http 80
# ./vstacklet.sh --phpmyadmin --varnish --mysql_user root --mysql_password password --php 7.4 --http 80
# @break
##################################################################################
vstacklet::phpmyadmin::install() {
	# If you prefer a more modular installation, you can comment out the following 3 lines.
	[[ -z ${mariadb} || -z ${mysql} ]] && { _error "You must install a database server before installing phpMyAdmin" && vstacklet::clean::rollback 67; }
	[[ -z ${nginx} && -z ${varnish} ]] && { _error "You must install a web server before installing phpMyAdmin" && vstacklet::clean::rollback 68; }
	[[ -z ${php} ]] && { _error "You must install php before installing phpMyAdmin" && vstacklet::clean::rollback 69; }
	# check if hhvm is selected and throw an error if it is
	[[ -n ${hhvm} ]] && { _error "phpMyAdmin does not support HHVM" && vstacklet::clean::rollback 70; }
	if [[ -n ${phpmyadmin} && -n ${mariadb} || -n ${mysql} || -n ${nginx} || -n ${varnish} && -n ${php} ]]; then
		declare pma_version
		pma_version=$(curl -s https://www.phpmyadmin.net/home_page/version.json | jq -r '.version')
		[[ -n ${http_port} ]] && phpmyadmin_port="${http_port}"
		[[ -z ${http_port} ]] && phpmyadmin_port="80"
		[[ -n ${mariadb} || -n ${mysql} && -z ${mariadb_user} || -z ${mysql_user} ]] && phpmyadmin_user="root"
		[[ -n ${mariadb} || -n ${mysql} && -z ${mariadb_password} || -z ${mysql_password} ]] && phpmyadmin_password=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)
		[[ -n ${domain} ]] && phpmyadmin_domain="${domain}"
		[[ -z ${domain} ]] && phpmyadmin_domain="${server_ip}"
		pma_bf=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..31')
		_info "Installing phpMyAdmin ... "
		(
			DEBIAN_FRONTEND=noninteractive apt-get --allow-unauthenticated -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install phpmyadmin
		) >>"${vslog}" 2>&1 || { _error "Failed to install phpMyAdmin" && vstacklet::clean::rollback 71; }
		cd /usr/share || { _error "Failed to change directory to /usr/share" && vstacklet::clean::rollback 72; }
		rm -rf phpmyadmin || { _error "Failed to remove phpmyadmin" && vstacklet::clean::rollback 73; }
		wget "https://files.phpmyadmin.net/phpMyAdmin/${pma_version}/phpMyAdmin-${pma_version}-all-languages.tar.gz" >>"${vslog}" 2>&1 || { _error "Failed to download phpMyAdmin" && vstacklet::clean::rollback 74; }
		tar -xzf "phpMyAdmin-${pma_version}-all-languages.tar.gz" >>"${vslog}" 2>&1 || { _error "Failed to extract phpMyAdmin" && vstacklet::clean::rollback 75; }
		mv "phpMyAdmin-${pma_version}-all-languages" phpmyadmin || { _error "Failed to rename phpMyAdmin" && vstacklet::clean::rollback 76; }
		rm -rf "phpMyAdmin-${pma_version}-all-languages.tar.gz" || { _error "Failed to remove phpMyAdmin" && vstacklet::clean::rollback 77; }
		# trunk-ignore(shellcheck/SC2015)
		mkdir -p /usr/share/phpmyadmin/tmp && chown -R www-data:www-data /usr/share/phpmyadmin/tmp || { _error "Failed to create directory /usr/share/phpmyadmin/tmp" && vstacklet::clean::rollback 78; }
		# trunk-ignore(shellcheck/SC2015)
		[[ -n ${web_root} ]] && ln -sf /usr/share/phpmyadmin "${web_root}/public" || { _error "Failed to create symlink to phpmyadmin" && vstacklet::clean::rollback 79; }
		# trunk-ignore(shellcheck/SC2015)
		[[ -z ${web_root} ]] && ln -sf /usr/share/phpmyadmin /var/www/html/public || { _error "Failed to create symlink to phpmyadmin" && vstacklet::clean::rollback 80; }
		# configure phpmyadmin
		_info "Configuring phpMyAdmin ... "
		# set phpmyadmin configuration
		{
			echo -e "<?php"
			echo -e "/* Servers configuration */"
			echo -e "\$i = 0;"
			echo -e "/* Server: localhost [1] */"
			echo -e "\$i++;"
			echo -e "\$cfg['Servers'][\$i]['verbose'] = 'localhost';"
			echo -e "\$cfg['Servers'][\$i]['host'] = 'localhost';"
			echo -e "\$cfg['Servers'][\$i]['port'] = '${phpmyadmin_port}';"
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
			_error "Failed to set phpMyAdmin configuration" && vstacklet::clean::rollback 81
		}
		echo "configuration file saved to /etc/phpmyadmin/config.inc.php"
		echo "Access phpMyAdmin at http://${phpmyadmin_domain}:${phpmyadmin_port}/phpmyadmin"
		echo "phpmyadmin user: ${phpmyadmin_user}"
		echo "phpmyadmin password: ${phpmyadmin_password}"
		echo "phpmyadmin port: ${phpmyadmin_port}"
		echo
		echo "${OK}"
	else
		_error "phpMyAdmin requires MariaDB or MySQL" && vstacklet::clean::rollback 82
	fi
}

##################################################################################
# @name: vstacklet::csf::install (20)
# @description: Install CSF firewall.
#
# notes:
# - https://configserver.com/cp/csf.html
# - installing CSF will also install LFD (Linux Firewall Daemon)
# - CSF will be configured to allow SSH, FTP, HTTP, HTTPS, MySQL, Redis,
#   Postgres, and Varnish
# - CSF will be configured to block all other ports
# - CSF requires sendmail to be installed. if the `-sendmail` option is not
#   specified, sendmail will automatically be installed and configured to use the
#   specified email address from the `-email` option.
# - As expressed above, CSF will also require the `-email` option to be
#   specified.
# - if your domain is routed through Cloudflare, you will need to add use the
#   `-cloudflare` option to allow Cloudflare IPs through CSF.
# @option: $1 - `-csf | --csf` (optional) (takes no argument)
# @arg: `-csf | --csf` does not take any arguments. However, it requires the options as expressed above.
# @example: ./vstacklet.sh -csf -e "your@email.com" -cloudflare -sendmail
# ./vstacklet.sh --csf --email "your@email.com" --cloudflare --sendmail
# @break
##################################################################################
vstacklet::csf::install() {
	# check if csf is installed
	if [[ -f /etc/csf/csf.conf ]]; then
		_warn "CSF appears to be installed already. Skipping CSF installation" && return 0
	fi
	_info "Installing CSF (ConfigServer Security & Firewall) firewall"
	echo -n "${green}Installing required apt packages for CSF${normal} ... "
	# e2fsprogs libwww-perl liblwp-protocol-https-perl libgd-graph-perl
	(
		DEBIAN_FRONTEND=noninteractive apt-get --allow-unauthenticated -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install e2fsprogs libwww-perl liblwp-protocol-https-perl libgd-graph-perl
	) >>"${vslog}" 2>&1 || { _error "Failed to install CSF" && vstacklet::clean::rollback 83; }
	# install csf
	wget -O - https://download.configserver.com/csf.tgz | tar -xz -C /usr/local/src >>"${vslog}" 2>&1 || { _error "Failed to download CSF" && vstacklet::clean::rollback 84; }
	(
		cd /usr/local/src/csf || { _error "Failed to change directory to /usr/local/src/csf" && vstacklet::clean::rollback 85; }
		sh install.sh
	) >>"${vslog}" 2>&1 || { _error "Failed to install CSF" && vstacklet::clean::rollback 86; }
	# configure csf
	_info "Configuring CSF ... "
	perl /usr/local/csf/bin/csftest.pl >>"${vslog}" 2>&1 || { _error "Failed to configure CSF" && vstacklet::clean::rollback 87; }
	# modify csf blocklists - essentiallly like Cloudflare, but for CSF
	# https://www.configserver.com/cp/csf.html#blocklists
	sed -i.bak -e 's/^SPAMDROP|86400|0|/SPAMDROP|86400|100|/g' -e 's/^SPAMEDROP|86400|0|/SPAMEDROP|86400|100|/g' -e 's/^DSHIELD|86400|0|/DSHIELD|86400|100|/g' -e 's/^TOR|86400|0|/TOR|86400|100|/g' -e 's/^ALTTOR|86400|0|/ALTTOR|86400|100|/g' -e 's/^BOGON|86400|0|/BOGON|86400|100|/g' -e 's/^HONEYPOT|86400|0|/HONEYPOT|86400|100|/g' -e 's/^CIARMY|86400|0|/CIARMY|86400|100|/g' -e 's/^BFB|86400|0|/BFB|86400|100|/g' -e 's/^OPENBL|86400|0|/OPENBL|86400|100|/g' -e 's/^AUTOSHUN|86400|0|/AUTOSHUN|86400|100|/g' -e 's/^MAXMIND|86400|0|/MAXMIND|86400|100|/g' -e 's/^BDE|3600|0|/BDE|3600|100|/g' -e 's/^BDEALL|86400|0|/BDEALL|86400|100|/g' /etc/csf/csf.blocklists >>"${vslog}" 2>&1 || { _error "Failed to modify CSF blocklists" && vstacklet::clean::rollback 88; }
	# modify csf.ignore - ignore nginx, varnish, mysql, redis, postgresql, and phpmyadmin
	{
		echo
		echo "[ vStacklet Additions ]"
		[[ -n ${nginx} ]] && echo "nginx"
		[[ -n ${varnish} ]] && echo "varnish" && echo "varnishd"
		[[ -n ${mysql} ]] && echo "mysql" && echo "mysqld"
		[[ -n ${redis} ]] && echo "redis" && echo "redis-server"
		[[ -n ${postgre} ]] && echo "postgres" && echo "postgresql"
		[[ -n ${phpmyadmin} ]] && echo "phpmyadmin"
		echo "rsyslog"
		echo "rsyslogd"
		echo "systemd-timesyncd"
		echo "systemd-resolved"
	} >>/etc/csf/csf.ignore || { _error "Failed to modify CSF ignore list" && vstacklet::clean::rollback 89; }
	# modify csf.allow - allow ssh, http, https, mysql, mariadb, postgresql, redis, and varnish
	{
		echo
		echo "[ vStacklet Additions ]"
		echo "${ssh_port}"
		echo "${ftp_port}"
		echo "${http_port}"
		echo "${https_port}"
		[[ -n ${mysql_port} ]] && echo "${mysql_port}" && declare -g mysql_port="${mysql_port}"
		[[ -n ${mariadb_port} ]] && echo "${mariadb_port}" && declare -g mariadb_port="${mariadb_port}"
		[[ -n ${postgre_port} ]] && echo "${postgre_port}" && declare -g postgre_port="${postgre_port}"
		[[ -n ${redis_port} ]] && echo "${redis_port}" && declare -g redis_port="${redis_port}"
		[[ -n ${varnish_port} ]] && echo "${varnish_port}" && declare -g varnish_port="${varnish_port}"
		[[ -n ${sendmail_port} ]] && echo "${sendmail_port}" && declare -g sendmail_port="${sendmail_port}"
	} >>/etc/csf/csf.allow || { _error "Failed to modify CSF allow list" && vstacklet::clean::rollback 90; }
	declare -a csf_allow_ports=("${ssh_port}" "${ftp_port}" "${http_port}" "${https_port}" "${mysql_port}" "${mariadb_port}" "${postgre_port}" "${redis_port}" "${varnish_port}" "${sendmail_port}")
	# modify csf.conf - allow ssh, ftp, http, https, mysql, mariadb, postgresql, redis, sendmail, and varnish
	for p in "${csf_allow_ports[@]}"; do
		sed -i.bak -e "s/^TCP_IN = \"\$TCP_IN\"/TCP_IN = \"\$TCP_IN ${p}\"/g" -e "s/^TCP6_IN = \"\$TCP6_IN\"/TCP6_IN = \"\$TCP6_IN ${p}\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || { _error "Failed to modify TCP_IN in CSF allow list" && vstacklet::clean::rollback 91; }
		sed -i.bak -e "s/^TCP_OUT = \"\$TCP_OUT\"/TCP_OUT = \"\$TCP_OUT ${p}\"/g" -e "s/^TCP6_OUT = \"\$TCP6_OUT\"/TCP6_OUT = \"\$TCP6_OUT ${p}\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || { _error "Failed to modify TCP_OUT in CSF allow list" && vstacklet::clean::rollback 92; }
	done
	# modify csf.conf - this is to be further refined
	sed -i.bak -e "s/^TESTING = \"1\"/TESTING = \"0\"/g" -e "s/^RESTRICT_SYSLOG = \"0\"/RESTRICT_SYSLOG = \"1\"/g" -e "s/^DENY_TEMP_IP_LIMIT = \"100\"/DENY_TEMP_IP_LIMIT = \"1000\"/g" -e "s/^SMTP_ALLOW_USER = \"\"/SMTP_ALLOW_USER = \"root\"/g" -e "s/^PT_USERMEM = \"200\"/PT_USERMEM = \"1000\"/g" -e "s/^PT_USERTIME = \"1800\"/PT_USERTIME = \"7200\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || { _error "Failed to modify CSF configuration" && vstacklet::clean::rollback 93; }
	[[ -z ${sendmail} || ${sendmail_skip} -eq 1 ]] && vstacklet::sendmail::install
	echo "${OK}"
}

##################################################################################
# @name: vstacklet::sendmail::install (21)
# @description: Install and configure sendmail. This is a required component for
# CSF to function properly.
#
# notes:
# - The `-e | --email` option is required for this function to run properly.
#   the email address provided will be used to configure sendmail.
# - If installing CSF, this function will be called automatically. As such, it
#   is not necessary to call this function manually with the `-csf | --csf` option.
# @param: $1 - sendmail_skip installation (this is siliently passed if `-csf` is used)
# @option: $1 - `-sendmail | --sendmail` (optional) (takes no arguments)
# @noargs
# @example: ./vstacklet.sh -sendmail -e "your@email.com"
# ./vstacklet.sh --sendmail --email "your@email.com"
# ./vstacklet.sh -csf -e "your@email.com"
# @break
##################################################################################
vstacklet::sendmail::install() {
	[[ -z ${email} ]] && { _error "The email address is required for sendmail" && vstacklet::clean::rollback 94; }
	if [[ -n ${sendmail} || -z ${sendmail_skip} ]]; then
		_info "Installing sendmail ... "
		(
			export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_NOWARNINGS=yes && apt-get -y install sendmail sendmail-bin sendmail-cf mailutils >>"${vslog}" 2>&1
		) || { _error "Failed to install sendmail" && vstacklet::rollback::clean 95; }
		_info "Configuring sendmail ... "
		# modify aliases
		sed -i.bak -e "s/^root:.*$/root: ${email}/g" /etc/aliases >>"${vslog}" 2>&1 || { _error "Failed to modify sendmail aliases" && vstacklet::rollback::clean 96; }
		# modify /etc/mail/sendmail.cf
		sed -i.bak -e "s/^DS.*$/DS${email}/g" \
			-e "s/^O DaemonPortOptions=Addr=${sendmail_port}, Name=MTA-v4/O DaemonPortOptions=Addr=${sendmail_port}, Name=MTA-v4, Family=inet/g" \
			-e "s/^O PrivacyOptions=authwarnings,novrfy,noexpnO PrivacyOptions=authwarnings,novrfy,noexpn/O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun/g" \
			-e "s/^O AuthInfo=.*/O AuthInfo=${email}:*:${email}/g" \
			-e "s/^O Mailer=smtp, Addr=${server_ip}, Port=smtp, Name=MTA-v4/O Mailer=smtp, Addr=${server_ip}, Port=smtp, Name=MTA-v4, Family=inet/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || { _error "Failed to modify sendmail configuration" && vstacklet::rollback::clean 97; }
		# modify /etc/postfix/main.cf
		sed -i.bak -e "s/^#myhostname = host.domain.tld/myhostname = ${server_hostname}/g" \
			-e "s/^#mydomain = domain.tld/mydomain = ${domain}/g" \
			-e "s/^#myorigin = \$mydomain/myorigin = \$mydomain/g" \
			-e "s/^#mydestination = \$myhostname, localhost.\$mydomain, localhost/mydestination = \$myhostname, localhost.\$mydomain, localhost/g" \
			-e "s/^#relayhost =/relayhost = ${server_ip}:${sendmail_port}/g" /etc/postfix/main.cf >>"${vslog}" 2>&1 || { _error "Failed to modify postfix main configuration" && vstacklet::rollback::clean 98; }
		# modify /etc/postfix/master.cf
		sed -i.bak -e "s/^#submission/submission/g" \
			-e "s/^#  -o syslog_name=postfix\/submission/  -o syslog_name=postfix\/submission/g" \
			-e "s/^#  -o smtpd_tls_security_level=encrypt/  -o smtpd_tls_security_level=encrypt/g" \
			-e "s/^#  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes/g" \
			-e "s/^#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/g" \
			-e "s/^#  -o milter_macro_daemon_name=ORIGINATING/  -o milter_macro_daemon_name=ORIGINATING/g" /etc/postfix/master.cf >>"${vslog}" 2>&1 || { _error "Failed to modify postfix master configuration" && vstacklet::rollback::clean 99; }
		# modify /etc/postfix/sasl_passwd
		echo "[${server_ip}]:${sendmail_port} ${email}:${email}" >/etc/postfix/sasl_passwd >>"${vslog}" 2>&1 || { _error "Failed to modify postfix configuration" && vstacklet::rollback::clean 100; }
		# modify /etc/postfix/sasl_passwd
		postmap /etc/postfix/sasl_passwd >>"${vslog}" 2>&1 || { _error "Failed to modify postfix configuration" && vstacklet::rollback::clean 101; }
		newaliases >>"${vslog}" 2>&1 || { _error "Failed to modify postfix configuration" && vstacklet::rollback::clean 102; }
		# restart sendmail
		service sendmail restart >>"${vslog}" 2>&1 || { _error "Failed to restart sendmail" && vstacklet::rollback::clean 103; }
		echo "${OK}"
	fi
}

##################################################################################
# @name: vstacklet::cloudflare::csf
# @description: Configure Cloudflare IP addresses in CSF. This is to be used
# when Cloudflare is used as a CDN. This will allow CSF to
# recognize Cloudflare IPs as trusted.
#
# notes:
# - This function is only called under the following conditions:
#   - the option `-csf` is used (required)
#   - the option `-cloudflare` is used directly
# - This function is only utilized if the option for `-csf` is used.
# - This function adds the Cloudflare IP addresses to the CSF allow list. This
#   is done to ensure that the server can be accessed by Cloudflare. The list
#   is located in /etc/csf/csf.allow.
# @option: $1 - `-cloudflare | --cloudflare` (optional)
# @noargs
# @example: ./vstacklet.sh -cloudflare -csf -e "your@email.com"
# @break
##################################################################################
vstacklet::cloudflare::csf() {
	# check if CSF has been selected
	[[ -z ${csf} ]] && _error "CSF is not enabled with the -csf option." && vstacklet::rollback::clean 104
	# check if Cloudflare has been selected
	if [[ -n ${cloudflare} ]]; then
		# check if the csf.allow file exists
		[[ ! -f "/etc/csf/csf.allow" ]] || { _error "CSF allow file does not exist." && vstacklet::rollback::clean 105; }
		# add Cloudflare IP addresses to the allow list
		_info "Adding Cloudflare IP addresses to the allow list ... "
		{
			echo "# Cloudflare IP addresses"
			# trunk-ignore(shellcheck/SC2005)
			echo "$(curl -s https://www.cloudflare.com/ips-v4)"
			# trunk-ignore(shellcheck/SC2005)
			echo "$(curl -s https://www.cloudflare.com/ips-v6)"
			echo "# End Cloudflare IP addresses"
		} >>/tmp/csf.allow
		echo "${OK}"
	fi
}

#################################################################
# @name: vstacklet::nginx::location
# @description: The following security & enhancements cover basic
# security measures to protect against common exploits.
# Enhancements covered are adding cache busting, cross domain
# font support, expires tags and protecting system files.
#
# notes:
# - You can find the included files at the following directory:
#   - /etc/nginx/server.configs/location/
# - Not all profiles are included, review your [-d | -h].conf
#   for additions made by the script & adjust accordingly.
# - This function is only called under the following conditions:
#   - the option for `-nginx` is used (required)
# - The following profiles are included:
#   - cache-busting.conf
#   - cross-domain-fonts.conf
#   - expires.conf
#   - protect-system-files.conf
#   - letsencrypt.conf
# @nooptons
# @noargs
# @break
#################################################################
vstacklet::nginx::location() {
	# Round 1 - Location
	[[ -z ${nginx} ]] && _error "The -nginx|--nginx option is required" && vstacklet::rollback::clean 106
	_info "Configuring Nginx location ... "
	declare cache_busting="include server.configs\/location\/cache-busting.conf;"
	declare cross_domain_fonts="include server.configs\/location\/cross-domain-fonts.conf;"
	declare expires="include server.configs\/location\/expires.conf;"
	declare protect_system_files="include server.configs\/location\/protect-system-files.conf;"
	declare letsencrypt="include server.configs\/location\/letsencrypt.conf;"
	declare -a locations=("${cache_busting}" "${cross_domain_fonts}" "${expires}" "${protect_system_files}" "${letsencrypt}")
	entry="1"
	if [[ -n ${domain} ]]; then
		for i in "${locations[@]}"; do
			sed -i "s/{{locconf${entry}}}/${i}/g" "/etc/nginx/conf.d/${domain}.conf" >>"${vslog}" 2>&1 || { _error "Failed to modify nginx configuration : ${i}" && vstacklet::rollback::clean 107; }
			((entry++))
		done
	else
		for i in "${locations[@]}"; do
			sed -i "s/{{locconf${entry}/${i}}}/g" "/etc/nginx/conf.d/${server_hostname}.conf" >>"${vslog}" 2>&1 || { _error "Failed to modify nginx configuration : ${i}" && vstacklet::rollback::clean 107; }
			((entry++))
		done
	fi
	echo "${OK}"
}

#################################################################
# @name: vstacklet::nginx::security
# @description: The following security & enhancements cover basic
# security measures to protect against common exploits.
# Security measures covered are adding bad bot blocking, file injection,
# and php eastereggs.
#
# notes:
# - You can find the included files at the following directory:
#   - /etc/nginx/server.configs/directives/
# - Not all profiles are included, review your [-d | -h].conf
#   for additions made by the script & adjust accordingly.
# - This function is only called under the following conditions:
#   - the option for `-nginx` is used (required)
# - The following profiles are included:
#   - bad-bots.conf
#   - file-injection.conf
#   - php-easter-eggs.conf
# @nooptons
# @noargs
# @break
#################################################################
vstacklet::nginx::security() {
	# Round 2 - Security
	[[ -z ${nginx} ]] && _error "The -nginx|--nginx option is required" && vstacklet::rollback::clean 108
	_info "Configuring Nginx security ... "
	declare bad_bots="include server.configs\/directives\/bad-bots.conf;"
	declare file_injection="include server.configs\/directives\/file-injection.conf;"
	declare php_easter_eggs="include server.configs\/directives\/php-easter-eggs.conf;"
	declare -a security=("${bad_bots}" "${file_injection}" "${php_easter_eggs}")
	entry="1"
	if [[ -n ${domain} ]]; then
		for i in "${security[@]}"; do
			sed -i "s/{{secconf${entry}}}/${i}/g" "/etc/nginx/conf.d/${domain}.conf" >>"${vslog}" 2>&1 || { _error "Failed to modify nginx configuration : ${i}" && vstacklet::rollback::clean 109; }
			((entry++))
		done
	else
		for i in "${security[@]}"; do
			sed -i "s/{{secconf${entry}}}/${i}/g" "/etc/nginx/conf.d/${server_hostname}.conf" >>"${vslog}" 2>&1 || { _error "Failed to modify nginx configuration : ${i}" && vstacklet::rollback::clean 109; }
			((entry++))
		done
	fi
	echo "${OK}"
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

vstacklet::setup::finished() {
	[[ -n ${http} ]] && web_port="${http}"
	[[ -n ${https} ]] && web_port="${https}"
	[[ -z ${domain} ]] && domain="${server_ip}"
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
	echo "${black}${on_green}    vStacklet Installation Completed    ${normal}"
	echo
	echo "${bold}Visit ${green}http://${domain}:${web_port}/checkinfo.php${normal} ${bold}to verify your install. ${normal}"
	echo "${bold}Remember to remove the checkinfo.php file after verification. ${normal}"
	echo
	echo
	echo "${standout}INSTALLATION COMPLETED in ${FIN}/min ${normal}"
	echo
}

clear

S=$(date +%s)
OK=$(echo -e "[ ${bold}${green}DONE${normal} ]")
E=$(date +%s)
DIFF=$(echo "${E}" - "${S}" | bc)
FIN=$(echo "${DIFF}" / 60 | bc)

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

################################################################################
# @description: rollback on error
# @noargs
################################################################################
vstacklet::clean::rollback() {
	declare error
	if [[ -n $1 ]]; then
		case $1 in
		1) error="Error: Please provide a valid email address to use for the sendmail alias required by CSF.";;
		2) error="Error: Please provide a valid domain name.";;
		3) error="Error: Please provide a valid port number for the FTP server.";;
		4) error="Error: Invalid FTP port number. Please enter a number between 1 and 65535.";;
		5) error="Error: The MariaDB password must be at least 8 characters long.";;
		6) error="Error: Please provide a valid port number for the MariaDB server.";;
		7) error="Error: Invalid MariaDB port number. Please enter a number between 1 and 65535.";;
		8) error="Error: The MySQL password must be at least 8 characters long.";;
		9) error="Error: Please provide a valid port number for the MySQL server.";;
		10) error="Error: Invalid MySQL port number. Please enter a number between 1 and 65535.";;
		11) error="Error: Invalid PHP version. Please enter either 7 (7.4) or 8 (8.1).";;
		13) error="Error: The HTTPS port must be a number.";;
		14) error="Error: Invalid HTTPS port number. Please enter a number between 1 and 65535.";;
		15) error="Error: The HTTP port must be a number.";;
		16) error="Error: Invalid HTTP port number. Please enter a number between 1 and 65535.";;
		17) error="Error: Invalid hostname. Please enter a valid hostname.";;
		18) error="Error: An email is needed to register the server aliases. Please set an email with the -e option.";;
		19) error="Error: The Sendmail port must be a number.";;
		20) error="Error: Invalid Sendmail port number. Please enter a number between 1 and 65535.";;
		21) error="Error: The SSH port must be a number.";;
		22) error="Error: Invalid SSH port number. Please enter a number between 1 and 65535.";;
		23) error="Error: The Varnish port must be a number.";;
		24) error="Error: Invalid Varnish port number. Please enter a number between 1 and 65535.";;
		25) error="Error: Invalid web root. Please enter a valid path (e.g. /var/www/html).";;
		26) error="Error: Invalid option(s). ${invalid_option[*]}";;

		*) error="Error: Unknown error" ;;
		esac
		printf -- "\nerror %s: %s\n" "$1" "${error}"
	else
		printf -- "\ninstaller interrupted\n"
	fi
	printf -- "%s\n" "rolling back setup..."
	declare installed removed
	[[ -n ${ssdp_block} ]] && iptables -D INPUT -p udp --dport 1900 -j DROP
	[[ -f ${vstacklet_base_path}/setup_temp/sshd_config ]] && \cp -f "${vstacklet_base_path}/setup_temp/sshd_config" /etc/ssh/sshd_config && systemctl restart sshd.service
	[[ -f ${vstacklet_base_path}/setup_temp/nginx.conf ]] && mv -f "${vstacklet_base_path}/setup_temp/nginx.conf" /etc/nginx/nginx.conf
	[[ -f ${vstacklet_base_path}/config/system/encryption_file ]] && chattr -i "${vstacklet_base_path}/config/system/encryption_file"
	[[ -d ${web_root} ]] && rm -rf "${web_root}"
	[[ -L /usr/local/bin/vstacklet ]] && unlink "/usr/local/bin/vstacklet"
	[[ -f ${vstacklet_base_path}/setup_temp/secure_path ]] && mv -f "${vstacklet_base_path}/setup_temp/secure_path" "/etc/sudoers.d/"
	find "${vstacklet_base_path}/"* ! -path "*logs*" -exec rm -rf {} + >/dev/null 2>&1
	rm -rf "/etc/nginx/ssl" "/etc/nginx/server.configs" "/etc/nginx/conf.d/${domain}.conf" "/etc/nginx/conf.d/vs-site1.conf" "/etc/nginx/sites-enabled/vs-site1.conf" "/etc/nginx/sites-enabled/${domain}.conf" "/etc/nginx/sites-available/vs-site1.conf" "/etc/nginx/sites-available/${domain}.conf" >/dev/null 2>&1
	if [[ -n ${install_list[*]} ]]; then
		for installed in "${install_list[@]}"; do
			apt-get -y remove "${installed}" >/dev/null 2>&1
			apt-get -y purge "${installed}" >/dev/null 2>&1
		done
		apt-get -y autoremove >/dev/null 2>&1
		apt-get -y autoclean >/dev/null 2>&1
	fi
	if [[ -n ${remove_list[*]} ]]; then
		for removed in "${remove_list[@]}"; do
			apt-get -y install "${removed}" --allow-unauthenticated >/dev/null 2>&1
		done
	fi
	printf -- "%s\n" "server rolled back"
	exit "${1:-1}"
}
trap 'vstacklet::clean::rollback' SIGINT

################################################################################
# @description: calls functions in required order
################################################################################
vstacklet::environment::init
vstacklet::environment::checkdistro
vstacklet::environment::checkroot
vstacklet::args::process "$@"
