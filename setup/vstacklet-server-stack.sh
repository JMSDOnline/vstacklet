#!/bin/bash
##################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 3.1.1519
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
# @name: vstacklet::environment::init (1)
# @description: Setup the environment and set variables.
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::init() {
	shopt -s extglob
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
	# create vstacklet directories
	mkdir -p "${vstacklet_base_path}/setup_temp"    # temporary setup directory - stores default files edited by vStacklet
	mkdir -p "${vstacklet_base_path}/config/system" # system configuration directory - stores dependencies, keys, and other system files
	# vstacklet script timing
	S=$(date +%s)
	E=$(date +%s)
	DIFF=$(echo "${E}" - "${S}" | bc)
	FIN=$(echo "${DIFF}" / 60 | bc)
}

##################################################################################
# @name: vstacklet::log::check (3)
# @description: Check if the log file exists and create it if it doesn't.
# @noargs:
# @nooptions:
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::log::check() {
	vstacklet::shell::text::white "checking log file ... "
	declare -g log_file vslog
	log_file="/var/log/vstacklet/vstacklet.${PPID}.log"
	if [[ ! -d /var/log/vstacklet ]]; then
		mkdir -p /var/log/vstacklet
	fi
	rm -f /var/log/vstacklet/vstacklet.*.log
	if [[ ! -f ${log_file} ]]; then
		touch "${log_file}"
		vslog="/var/log/vstacklet/vstacklet.${PPID}.log"
		vstacklet::shell::text::yellow "output is being sent to /var/log/vstacklet/vstacklet.${PPID}.log"
	fi
	vstacklet::log() {
		if [[ -z ${verbosity} ]]; then
			($1 >>"${log_file}" 2>&1)
		else
			$1 |& tee -a "${log_file}"
		fi
	}
}

##################################################################################
# @name: vstacklet::environment::checkroot (4)
# @description: Check if the user is root.
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 1 = You must be root to run this script.
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && vstacklet::clean::rollback 1
}

##################################################################################
# @name: vstacklet::environment::checkdistro (5)
# @description: Check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 2 = This script only supports Ubuntu 18.04/20.04 | Debian 9/10/11
# @break
##################################################################################
vstacklet::environment::checkdistro() {
	declare -g codename distro
	declare -a allowed_codename=("bionic" "focal" "stretch" "buster" "bullseye")
	codename=$(lsb_release -cs)
	distro=$(lsb_release -is)
	if ! vstacklet::array::contains "${codename}" "supported distro" ${allowed_codename[@]}; then
		declare allowed_codename_string="${allowed_codename[*]}"
		vstacklet::shell::text::yellow::sl "supported distros: "
		vstacklet::shell::text::white "${allowed_codename_string//${IFS:0:1}/, }"
		vstacklet::clean::rollback 2
	fi
}

##################################################################################
# @name: vstacklet::args::process (6)
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
# @option: `-hn | --hostname` - hostname to use for the server
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
# @example: ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -hn "yourhostname" -d "yourdomain.com" -php 8.1 -mc -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -csf -sendmail -wr "/var/www/html" -wp
# @example: ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -hn "yourhostname" -d "yourdomain.com" -hhvm -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -sendmail -wr "/var/www/html" -wp --reboot
# @null
# @return_code: 3 - Please provide a valid email address to use. (required for -csf, -sendmail, and -cloudflare)
# @return_code: 4 - Please provide a valid domain name.
# @return_code: 5 - Please provide a valid port number for the FTP server.
# @return_code: 6 - Invalid FTP port number. Please enter a number between 1 and 65535.
# @return_code: 7 - The MariaDB password must be at least 8 characters long.
# @return_code: 8 - Please provide a valid port number for the MariaDB server.
# @return_code: 9 - Invalid MariaDB port number. Please enter a number between 1 and 65535.
# @return_code: 10 - The MySQL password must be at least 8 characters long.
# @return_code: 11 - The MySQL port must be a number.
# @return_code: 12 - Invalid MySQL port number. Please enter a number between 1 and 65535.
# @return_code: 13 - Invalid PHP version. Please enter either 7 (7.4), or 8 (8.1).
# @return_code: 14 - The HTTPS port must be a number.
# @return_code: 15 - Invalid HTTPS port number. Please enter a number between 1 and 65535.
# @return_code: 16 - The HTTP port must be a number.
# @return_code: 17 - Invalid HTTP port number. Please enter a number between 1 and 65535.
# @return_code: 18 - Invalid hostname. Please enter a valid hostname.
# @return_code: 19 - An email is needed to register the server aliases. Please set an email with ' -e your@email.com '
# @return_code: 20 - The Sendmail port must be a number.
# @return_code: 21 - Invalid Sendmail port number. Please enter a number between 1 and 65535.
# @return_code: 22 - The SSH port must be a number.
# @return_code: 23 - Invalid SSH port number. Please enter a number between 1 and 65535.
# @return_code: 24 - The Varnish port must be a number.
# @return_code: 25 - Invalid Varnish port number. Please enter a number between 1 and 65535.
# @return_code: 26 - Invalid web root. Please enter a valid path. (e.g. /var/www/html)
# @return_code: 27 - Invalid option(s): ${invalid_option[*]}
# @break
##################################################################################
vstacklet::args::process() {
	while [[ $# -gt 0 ]]; do
		case "${1}" in
		# there may be options that can utilize passive builds, but for now, we'll just
		# assume that all options are passive builds triggered by the user (with the options/args set).
		# `-wp | --wordpress` is the only exception, as it is an active build, and additional information
		# is required to install WordPress. (e.g. the database name, user, and password)
		#--non-interactive)
		#	declare -gi non_interactive="1"
		#	shift
		#	;;
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
			[[ -z ${email} ]] && vstacklet::clean::rollback 3
			;;
		-d* | --domain*)
			declare -gi domain_ssl=1
			declare -g domain="${2}"
			shift
			shift
			[[ -n ${domain} && $(echo "${domain}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && vstacklet::clean::rollback 4
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
			[[ -n ${ftp_port} && ${ftp_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 5
			[[ -n ${ftp_port} && ${ftp_port} -lt 1 || ${ftp_port} -gt 65535 ]] && vstacklet::clean::rollback 6
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
			[[ -n ${mariadb_password} && ${#mariadb_password} -lt 8 ]] && vstacklet::clean::rollback 7
			;;
		-mariadbP* | --mariadb_port*)
			declare -gi mariadb_port="${2}"
			shift
			shift
			[[ -n ${mariadb_port} && ${mariadb_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 8
			[[ -n ${mariadb_port} && ${mariadb_port} -lt 1 || ${mariadb_port} -gt 65535 ]] && vstacklet::clean::rollback 9
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
			[[ -n ${mysql_password} && ${#mysql_password} -lt 8 ]] && vstacklet::clean::rollback 10
			;;
		-mysqlP* | --mysql_port*)
			declare -gi mysql_port="${2}"
			shift
			shift
			[[ -n ${mysql_port} && ${mysql_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 11
			[[ -n ${mysql_port} && ${mysql_port} -lt 1 || ${mysql_port} -gt 65535 ]] && vstacklet::clean::rollback 12
			[[ -z ${mysql_port} ]] && declare -gi mysql_port="3306"
			;;
		-nginx | --nginx)
			declare -gi nginx="1"
			shift
			;;
		-postgre | --postgresql)
			declare -gi postgresql="1"
			shift
			;;
		-postgreU* | --postgresql_user*)
			declare -g postgresql_user="${2}"
			shift
			shift
			[[ -n ${postgresql_user} && ${#postgresql_user} -lt 8 ]] && vstacklet::clean::rollback 13
			;;
		-postgrePw* | --postgresql_password*)
			declare -g postgresql_password="${2}"
			shift
			shift
			[[ -n ${postgresql_password} && ${#postgresql_password} -lt 8 ]] && vstacklet::clean::rollback 14
			;;
		-postgreP* | --postgresql_port*)
			declare -gi postgresql_port="${2}"
			shift
			shift
			[[ -n ${postgresql_port} && ${postgresql_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 15
			[[ -n ${postgresql_port} && ${postgresql_port} -lt 1 || ${postgresql_port} -gt 65535 ]] && vstacklet::clean::rollback 16
			[[ -z ${postgresql_port} ]] && declare -gi postgresql_port="5432"
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
			[[ -n ${php} && ${php} != "7" && ${php} != "8" && ${php} != "7.4" && ${php} != "8.1" ]] && vstacklet::clean::rollback 13
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
			[[ -n ${https_port} && ${https_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 14
			[[ -n ${https_port} && ${https_port} -lt 1 || ${https_port} -gt 65535 ]] && vstacklet::clean::rollback 15
			[[ -z ${https_port} ]] && declare -gi https_port="443"
			;;
		-http* | --http_port*)
			declare -gi http_port="${2}"
			shift
			shift
			[[ -n ${http_port} && ${http_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 16
			[[ -n ${http_port} && ${http_port} -lt 1 || ${http_port} -gt 65535 ]] && vstacklet::clean::rollback 17
			[[ -z ${http_port} ]] && declare -gi http_port="80"
			;;
		-hn* | --hostname*)
			declare -g hostname="${2}"
			shift
			shift
			[[ -n ${hostname} && $(echo "${hostname}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && vstacklet::clean::rollback 18
			[[ -z ${hostname} ]] && declare -g hostname="localhost"
			;;
		-redis | --redis)
			declare -gi redis="1"
			shift
			;;
		-redisU* | --redis_user*)
			declare -g redis_user="${2}"
			shift
			shift
			[[ -n ${redis_user} && ${#redis_user} -lt 8 ]] && vstacklet::clean::rollback 22
			;;
		-redisPw* | --redis_password*)
			declare -g redis_password="${2}"
			shift
			shift
			[[ -n ${redis_password} && ${#redis_password} -lt 8 ]] && vstacklet::clean::rollback 21
			;;
		-redisP* | --redis_port*)
			declare -gi redis_port="${2}"
			shift
			shift
			[[ -n ${redis_port} && ${redis_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 19
			[[ -n ${redis_port} && ${redis_port} -lt 1 || ${redis_port} -gt 65535 ]] && vstacklet::clean::rollback 20
			[[ -z ${redis_port} ]] && declare -gi redis_port="6379"
			;;
		-sendmail | --sendmail)
			declare -gi sendmail="1"
			shift
			[[ -z ${email} ]] && vstacklet::clean::rollback 19
			;;
		-sendmailP | --sendmail_port)
			declare -gi sendmail_port="${2}"
			shift
			shift
			[[ -n ${sendmail_port} && ${sendmail_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 20
			[[ -n ${sendmail_port} && ${sendmail_port} -lt 1 || ${sendmail_port} -gt 65535 ]] && vstacklet::clean::rollback 21
			[[ -z ${sendmail_port} ]] && declare -gi sendmail_port="25"
			;;
		-ssh* | --ssh_port*)
			declare -gi ssh_port="${2}"
			shift
			shift
			[[ -n ${ssh_port} && ${ssh_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 22
			[[ -n ${ssh_port} && ${ssh_port} -lt 1 || ${ssh_port} -gt 65535 ]] && vstacklet::clean::rollback 23
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
			[[ -n ${varnish_port} && ${varnish_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 24
			[[ -n ${varnish_port} && ${varnish_port} -lt 1 || ${varnish_port} -gt 65535 ]] && vstacklet::clean::rollback 25
			[[ -z ${varnish_port} ]] && declare -gi varnish_port="6081"
			;;
		-wr* | --web_root*)
			declare -g web_root="${2}"
			shift
			shift
			[[ -n ${web_root} && $(sed -e 's/[\\/]/\\/g;s/[\/\/]/\\\//g;' <<<"${web_root}") == "" ]] && vstacklet::clean::rollback 26
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
	[[ ${#invalid_option[@]} -gt 0 ]] && vstacklet::clean::rollback 27
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment.
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::functions() {
	vstacklet::array::contains() {
		if [[ $# -lt 2 ]]; then
			_result=2
			vstacklet::shell::text::yellow "[${_result}]: ${FUNCNAME[0]} is missing arguments for ${_named_array}"
		fi
		declare _named_array="$2"
		declare _value="$1"
		shift
		declare -a _array=("$@")
		local _result=1
		for _element in "${_array[@]}"; do
			if [[ ${_element} == "${_value}" ]]; then
				_result=0
				vstacklet::shell::text::green "[${_result}]: ${_named_array} array contains ${_value}"
				break
			fi
		done
		[[ ${_result} == "1" ]] && vstacklet::shell::text::yellow "[${_result}]: ${_named_array} array does not contain ${_value}"
		return "${_result}"
	}
	vstacklet::shell::output() {
		declare shell_reset
		shell_reset=$(tput sgr0)
		if [[ -z ${shell_newline} ]]; then
			declare shell_newline="\n"
		else
			unset shell_newline
		fi
		if [[ -n ${shell_icon} && -n "$*" ]]; then
			declare shell_newline="\n"
		elif [[ -n ${shell_icon} && -z "$*" ]]; then
			unset shell_newline
		fi
		case "${shell_option}" in
		bold) shell_option=$(tput bold) ;;
		underline) shell_option=$(tput smul) ;;
		standout) shell_option=$(tput smso) ;;
		esac
		case "${shell_icon}" in
		arrow) shell_icon="➜ ${shell_reset}" ;;
		warning) shell_icon="⚠ ${shell_reset}" ;;
		check) shell_icon="✓ ${shell_reset}" ;;
		cross) shell_icon="✗ ${shell_reset}" ;;
		esac
		printf -- "${shell_reset}${shell_color}${shell_icon}${shell_option}%s${shell_newline}${shell_reset}" "$@"
		[[ " ${VSLOG_FILE_LOADED[*]} " =~ log ]] && printf "${shell_icon}%s${shell_newline}" "$@" >>"${log_file}"
		unset shell_color shell_newline shell_option shell_icon
	}
	vstacklet::shell::misc::nl() {
		printf "\n"
		[[ " ${VSLOG_FILE_LOADED[*]} " =~ log ]] && printf "\n" >>"${log_file:?}"
	}
	vstacklet::shell::text::white() {
		declare -g shell_color
		shell_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::white::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::red() {
		declare -g shell_color
		shell_color=$(tput setaf 1)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::red::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 1)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::green() {
		declare -g shell_color
		shell_color=$(tput setaf 2)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::green::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 2)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::yellow() {
		declare -g shell_color
		shell_color=$(tput setaf 3)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::yellow::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 3)
		vstacklet::shell::output "$@"
	}
}

##################################################################################
# @name: vstacklet::apt::update (7)
# @description: updates server via apt-get
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::apt::update() {
	vstacklet::log "running apt update ... "
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >/dev/null 2>&1
	[[ -n ${apt_upgrade} ]] && DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1
}

##################################################################################
# @name: vstacklet::dependencies::install (8)
# @description: installs dependencies for vStacklet software
# @nooptions
# @noargs
# @return_code: 28 - failed to install dependencies - [${install}]
# @break
##################################################################################
vstacklet::dependencies::install() {
	vstacklet::log "checking for initial script dependencies ... "
	declare -ga script_dependencies
	declare -a depend_list
	declare -ga install_list
	script_dependencies=("apt-transport-https" "lsb-release" "curl" "wget" "git" "dnsutils" "dialog" "ssl-cert" "openssl")
	for depend in "${script_dependencies[@]}"; do
		if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
			depend_list+=("${depend}")
		fi
	done
	[[ -n ${depend_list[*]} ]] && printf -- "%s" "installing: "
	for install in "${depend_list[@]}"; do
		if [[ ${install} == "${depend_list[0]}" ]]; then
			vstacklet::log "${install}"
		else
			vstacklet::log "| ${install}"
		fi
		vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 28
		install_list+=("${install}")
	done
}

##################################################################################
# @name: vstacklet::intro (9)
# @description: Prints the intro message
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::intro() {
	echo
	echo
	echo "    vStacklet$ Webserver Installation Kit     "
	echo
	echo "                  Heads Up!                   "
	echo "     VStacklet works with the following       "
	echo "     Ubuntu 18.04/20.04 & Debian 9/10/11      "
	echo
	echo
	vstacklet::shell::text::green "checking distribution ... "
	vstacklet::distro::check
	echo
	# shellcheck disable=SC2005
	echo "$(lsb_release -a)"
	echo
}

# shall we continue? function (10)
vstacklet::ask::continue() {
	echo
	echo "Press ENTER when you're ready to begin or Ctrl+Z to cancel"
	read -r -s -n 1
	echo
}

################################################################################
# @name: vstacklet::dependencies::array (11)
# @description: Handles various dependencies for the vStacklet software.
# @nooptions
# @noargs
# notes:
# - stores dependencies needed for various options in an array
# - checks if dependencies are installed
# - installs dependencies if not installed
# - stores dependencies in an array for later use
# - used as a reference for the rollback function
# - the following array are used:
#   - script_dependencies
#   - source_dependencies
#   - base_dependencies
#   - php_dependencies
#   - hhvm_dependencies
#   - nginx_dependencies
#   - varnish_dependencies
#   - mariadb_dependencies
#   - mysql_dependencies
#   - phpmyadmin_dependencies
#   - sendmail_dependencies
# @break
################################################################################
vstacklet::dependencies::array() {
	# install source dependencies
	declare -ga source_dependencies=("dirmngr" "software-properties-common" "gnupg2" "ca-certificates" "gpg-agent" "apt-transport-https" "lsb-release" "curl" "wget" "git" "dnsutils" "dialog" "ssl-cert" "openssl" "sudo" "build-essential" "debconf-utils" "locales" "net-tools" "nfs-common" "iproute2")
	# install base dependencies
	declare -ga base_dependencies=("rsync" "dos2unix" "jq" "bc" "automake" "make" "cmake" "checkinstall" "nano" "zip" "unzip" "htop" "vnstat" "vnstati" "vsftpd" "subversion" "iptables")
	# install php dependencies
	[[ ${php} == *"7"* ]] && declare php="7.4"
	[[ ${php} == *"8"* ]] && declare php="8.1"
	[[ -z ${php} ]] && declare php="8.1"
	declare -ga php_dependencies=("php${php}-fpm" "php${php}-zip" "php${php}-cgi" "php${php}-cli" "php${php}-common" "php${php}-curl" "php${php}-dev" "php${php}-gd" "php${php}-bcmath" "php${php}-gmp" "php${php}-imap" "php${php}-intl" "php${php}-ldap" "php${php}-mbstring" "php${php}-mysql" "php${php}-opcache" "php${php}-pspell" "php${php}-readline" "php${php}-soap" "php${php}-xml" "php${php}-imagick" "php${php}-msgpack" "php${php}-igbinary" "libmcrypt-dev" "mcrypt" "libmemcached-dev" "php-memcached")
	# install hhvm dependencies
	declare -ga hhvm_dependencies=("hhvm")
	# install nginx dependencies
	declare -ga nginx_dependencies=("nginx-extras")
	# install varnish dependencies
	declare -ga varnish_dependencies=("varnish")
	# install mariadb dependencies
	declare -ga mariadb_dependencies=("mariadb-server" "mariadb-client")
	# install mysql dependencies
	declare -ga mysql_dependencies=("mysql-server" "mysql-client")
	# install postgresql dependencies
	declare -ga postgresql_dependencies=("postgresql" "postgresql-contrib")
	# install redis dependencies
	declare -ga redis_dependencies=("redis")
	# install phpmyadmin dependencies
	declare -ga phpmyadmin_dependencies=("phpmyadmin")
	# install csf dependencies
	declare -ga csf_dependencies=("e2fsprogs" "libwww-perl" "liblwp-protocol-https-perl" "libgd-graph-perl")
	# install sendmail dependencies
	declare -ga sendmail_dependencies=("sendmail" "sendmail-bin" "sendmail-cf" "mailutils" "libsasl2-modules")
}

################################################################################
# @description: logs dependencies to file
# @noargs
################################################################################
vstacklet::log::dependencies() {
	vstacklet::shell::text::white "saving installed dependencies..."
	declare -a logged_dependencies=("${base_dependencies[@]}" "${php_dependencies[@]}" "${nginx_dependencies[@]}" "${varnish_dependencies[@]}" "${mariadb_dependencies[@]}" "${mysql_dependencies[@]}" "${phpmyadmin_dependencies[@]}" "${sendmail_dependencies[@]}" "${csf_dependencies[@]}" "${script_dependencies[@]}" "${source_dependencies[@]}")
	for depend in "${logged_dependencies[@]}"; do
		echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
	done
}

################################################################################
# @name: vstacklet::base::dependencies (12)
# @description: Handles base dependencies for the vStacklet software.
# @return_code: 29 - failed to install base dependencies - [${install}]
# @break
################################################################################
vstacklet::base::dependencies() {
	declare depend install
	declare -a depend_list
	declare -ga install_list
	for depend in "${base_dependencies[@]}"; do
		if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
			depend_list+=("${depend}")
		fi
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing base dependencies: "
	for install in "${depend_list[@]}"; do
		if [[ ${install} == "${depend_list[0]}" ]]; then
			vstacklet::shell::text::white::sl "${install} "
		else
			vstacklet::shell::text::white::sl "| ${install} "
		fi
		vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 29
		install_list+=("${install}")
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
	unset depend depend_list install
}

##################################################################################
# @name: vstacklet::sources::install (13)
# @description: installs required sources for vStacklet software
# @nooptions
# @noargs
# @return_code: 30 - failed to install source dependencies - [${depend}]
# @break
##################################################################################
vstacklet::sources::install() {
	vstacklet::shell::text::white "checking for required software sources ... "
	declare -ga source_dependencies
	declare -a depend_list
	declare -ga install_list
	declare install depend
	source_dependencies=("dirmngr" "software-properties-common" "gnupg2" "ca-certificates" "gpg-agent")
	for depend in "${source_dependencies[@]}"; do
		if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
			depend_list+=("${depend}")
		fi
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing: "
	for install in "${depend_list[@]}"; do
		if [[ ${install} == "${depend_list[0]}" ]]; then
			vstacklet::shell::text::white::sl "${install} "
		else
			vstacklet::shell::text::white::sl "| ${install} "
		fi
		vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 30
		install_list+=("${install}")
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::bashrc::set (14)
# @description: Set ~/.bashrc and ~/.profile for vstacklet.
# @nooptions:
# @noargs:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::bashrc::set() {
	vstacklet::shell::text::white "setting ~/.bashrc and ~/.profile for vstacklet ... "
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
# @name: vstacklet::hostname::set (15)
# @description: Set system hostname.
#
# notes:
# - hostname must be a valid hostname.
#   - It can contain only letters, numbers, and hyphens.
#   - It must start with a letter and end with a letter or number.
#   - It must not contain consecutive hyphens.
#   - If hostname is not provided, it will be set to the domain name if provided.
#   - If domain name is not provided, it will be set to the server hostname.
# @option: $1 - `-hn | --hostname` (optional) (takes one argument)
# @arg: $2 - `[hostname]` - the hostname to set for the system (optional)
# @example: ./vstacklet.sh -hn myhostname
# ./vstacklet.sh --hostname myhostname
# @null
# @return: 31 - failed to set hostname
# @break
##################################################################################
vstacklet::hostname::set() {
	if [[ -n ${hostname} && -z ${domain} ]]; then
		vstacklet::shell::text::white "setting hostname to ${hostname} ... "
		vstacklet::log "hostnamectl set-hostname ${hostname}" || vstacklet::clean::rollback 31
	fi
	if [[ -z ${hostname} && -n ${domain} ]]; then
		vstacklet::shell::text::white "setting hostname name to ${domain} ... "
		vstacklet::log "hostnamectl set-hostname ${domain}" || vstacklet::clean::rollback 31
	fi
	if [[ -z ${hostname} && -z ${domain} ]]; then
		vstacklet::shell::text::white "setting hostname to ${server_hostname} ... "
		vstacklet::log "hostnamectl set-hostname ${server_hostname}" || vstacklet::clean::rollback 31
	fi
}

##################################################################################
# @name: vstacklet::webroot::set (16)
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
# @example: ./vstacklet.sh -wr /var/www/mydirectory
# ./vstacklet.sh --web_root /srv/www/mydirectory
# @break
##################################################################################
vstacklet::webroot::set() {
	if [[ -n ${web_root} ]]; then
		vstacklet::shell::text::white "setting web root directory to ${web_root:-/var/www/html} ... "
		mkdir -p "${web_root:-/var/www/html}"/{public,logs,ssl}
		vstacklet::log "chown -R www-data:www-data ${web_root:-/var/www/html}"
		vstacklet::log "chmod -R 755 ${web_root:-/var/www/html}"
	fi
}

##################################################################################
# @name: vstacklet::ssh::set (17)
# @description: Set ssh port to custom port (if nothing is set, default port is 22)
# @option: $1 - `-ssh | --ssh_port` (optional) (takes one argument)
# @arg: $2 - `[port]` (default: 22) - the port to set for ssh
# @return: none
# @example: ./vstacklet.sh -ssh 2222
# ./vstacklet.sh --ssh_port 2222
# @return_code: 32 - failed to set ssh port
# @return_code: 33 - failed to restart ssh service
# @break
##################################################################################
vstacklet::ssh::set() {
	if [[ -n ${ssh_port} ]]; then
		vstacklet::shell::text::white "setting ssh port to ${ssh_port:-22} ... "
		cp -f /etc/ssh/sshd_config "${vstacklet_base_path}/setup_temp/sshd_config"
		sed -i "s/^.*Port .*/Port ${ssh_port:-22}/g" /etc/ssh/sshd_config || vstacklet::clean::rollback 32
		vstacklet::log "systemctl restart sshd" || vstacklet::clean::rollback 33
	fi
}

##################################################################################
# @name: vstacklet::block::ssdp (18)
# @description: Blocks an insecure port 1900 that may lead to
# DDoS masked attacks. Only remove this function if you absolutely
# need port 1900. In most cases, this is a junk port.
# @noargs
# @nooptions
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 34 - failed to block ssdp port
# @return_code: 35 - failed to save iptables rules
# @break
##################################################################################
vstacklet::block::ssdp() {
	vstacklet::shell::text::white "blocking port 1900 ..."
	(
		vstacklet::log "iptables -A INPUT -p udp --dport 1900 -j DROP"
		vstacklet::log "iptables -A OUTPUT -p udp --dport 1900 -j DROP"
		vstacklet::log "iptables -A INPUT -p tcp --dport 1900 -j DROP"
		vstacklet::log "iptables -A OUTPUT -p tcp --dport 1900 -j DROP"
	) || vstacklet::clean::rollback 34
	vstacklet::log "iptables-save >/etc/iptables/rules.v4" || vstacklet::clean::rollback 35
}

##################################################################################
# @name: vstacklet::update::packages (19)
# @description: This function updates the package list and upgrades the system.
# @noargs:
# @nooptions:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::sources::update() {
	vstacklet::shell::text::white "updating package list ..."
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
	declare -gi apt_upgrade="1"
}

##################################################################################
# @name: vstacklet::packages::keys (20)
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
	vstacklet::shell::text::white "ddding signed keys and sources for required software packages ... "
	mkdir -p /etc/apt/sources.list.d /etc/apt/keyrings
	if [[ -n ${hhvm} ]]; then
		# hhvm
		curl -fsSL https://dl.hhvm.com/conf/hhvm.gpg.key | gpg --dearmor -o /etc/apt/keyrings/hhvm.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/hhvm.gpg] https://dl.hhvm.com/${distro} ${codename} main" | tee /etc/apt/sources.list.d/hhvm.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${nginx} ]]; then
		# nginx
		curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/keyrings/nginx.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/nginx.gpg] https://nginx.org/packages/mainline/${distro}/ ${codename} nginx" | tee /etc/apt/sources.list.d/nginx.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${varnish} ]]; then
		# varnish
		curl -fsSL "https://packagecloud.io/varnishcache/varnish72/gpgkey" | gpg --dearmor >"/etc/apt/keyrings/varnishcache_varnish72-archive-keyring.gpg" >>"${vslog}" 2>&1
		curl -sSf "https://packagecloud.io/install/repositories/varnishcache/varnish72/config_file.list?os=${distro,,}&dist=${codename}&source=script" >"/etc/apt/sources.list.d/varnishcache_varnish72.list"
	fi
	if [[ -n ${php} ]]; then
		# php
		curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/php.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/php.gpg] https://packages.sury.org/php/ ${codename} main" | tee /etc/apt/sources.list.d/php-sury.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${mariadb} ]]; then
		# mariadb
		wget -qO- https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor >/etc/apt/trusted.gpg.d/mariadb.gpg >>"${vslog}" 2>&1
		cat >/etc/apt/sources.list.d/mariadb.list <<EOF
deb [arch=amd64,i386,arm64,ppc64el] http://mirrors.syringanetworks.net/mariadb/repo/10.6/${distro} ${codename} main
deb-src http://mirrors.syringanetworks.net/mariadb/repo/10.6/${distro}/ ${codename} main
EOF
	fi
	if [[ -n ${redis} ]]; then
		# redis
		curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb ${codename} main" | tee /etc/apt/sources.list.d/redis.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${postgresql} ]]; then
		# postgresql
		wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor >/etc/apt/trusted.gpg.d/postgresql.gpg
		cat >/etc/apt/sources.list.d/postgresql.list <<EOF
deb [arch=amd64,arm64,ppc64el] http://apt.postgresql.org/pub/repos/apt ${codename}-pgdg main
deb-src http://apt.postgresql.org/pub/repos/apt ${codename}-pgdg main
EOF
	fi
	# Remove excess sources known to
	# cause issues with conflicting package sources
	[[ -f "/etc/apt/sources.list.d/proposed.list" ]] && mv -f /etc/apt/sources.list.d/proposed.list /etc/apt/sources.list.d/proposed.list.BAK
}

##################################################################################
# @name: vstacklet::apt::update (21)
# @description: Update apt sources and packages - this is a wrapper for apt-get update
# @nooptions
# @noargs
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 36 - apt-get update failed
# @return_code: 37 - apt-get upgrade failed
# @break
##################################################################################
vstacklet::apt::update() {
	# package and repo addition (d) _update and upgrade_
	vstacklet::shell::text::white "updating system ... "
	vstacklet::log "apt-get update" || vstacklet::clean::rollback 36
	vstacklet::log "apt-get -y upgrade" || vstacklet::clean::rollback 37
	vstacklet::log "apt-get -y autoremove"
	vstacklet::log "apt-get -y autoclean"

}

##################################################################################
# @name: vstacklet::locale::set (22)
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
# @return_code: 38 - locale-gen failed
# @break
##################################################################################
vstacklet::locale::set() {
	_info "Setting locale to en_US.UTF-8 ..."
	apt-get -y install language-pack-en-base >>"${vslog}" 2>&1
	if [[ -e /usr/sbin/locale-gen ]]; then
		(
			locale-gen en_US.UTF-8
			dpkg-reconfigure locales
		) >>"${vslog}" 2>&1 || vstacklet::clean::rollback 38
	else
		(
			apt-get -y update
			apt-get -y install locales locale-gen
			locale-gen en_US.UTF-8
			dpkg-reconfigure locales
		) >>"${vslog}" 2>&1 || vstacklet::clean::rollback 38

	fi
	update-locale LANG=en_US.UTF-8
}

##################################################################################
# @name: vstacklet::php::install (23)
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
# @return_code: 39 - php and hhvm cannot be installed at the same time, please choose one
# @return_code: 40 - failed to install php dependencies
# @return_code: 41 - failed to install php memcached extension
# @return_code: 42 - failed to install php redis extension
# @break
##################################################################################
vstacklet::php::install() {
	if [[ -n ${php} && ${php_set} == "1" ]]; then
		# check for hhvm
		[[ -n ${hhvm} ]] && vstacklet::clean::rollback 39
		# check for nginx \\ to maintain modularity, nginx is not required for PHP
		#[[ -z ${nginx} ]] && vstacklet::clean::rollback "PHP requires nginx. Please install nginx."
		# php version sanity check
		[[ ${php} == *"8"* ]] && php="8.1"
		[[ ${php} == *"7"* ]] && php="7.4"
		vstacklet::shell::text::white "installing and configuring php${php}-fpm ... "
		# install php dependencies and php
		for depend in "${php_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing php dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 40
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		if [[ -n ${memcached} ]]; then
			# memcached
			vstacklet::log "apt-get -y install php${php}-memcached" || vstacklet::clean::rollback 41
		fi
		if [[ -n ${redis} ]]; then
			# redis
			vstacklet::log "apt-get -y install php${php}-redis" || vstacklet::clean::rollback 42
		fi
		# tweak php.ini
		vstacklet::shell::text::white "tweaking php.ini ... "
		declare -a php_files=("/etc/php/${php}/fpm/php.ini" "/etc/php/${php}/cli/php.ini")
		# shellcheck disable=SC2215
		for file in "${php_files[@]}"; do
			sed -i.bak -e "s/.*post_max_size =.*/post_max_size = 92M/" -e "s/.*upload_max_filesize =.*/upload_max_filesize = 92M/" -e "s/.*expose_php =.*/expose_php = Off/" -e "s/.*memory_limit =.*/memory_limit = 768M/" -e "s/.*session.cookie_secure =.*/session.cookie_secure = 1/" -e "s/.*session.cookie_httponly =.*/session.cookie_httponly = 1/" -e "s/.*session.cookie_samesite =.*/cookie_samesite.cookie_secure = Lax/" -e "s/.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/" -e "s/.*opcache.enable=.*/opcache.enable=1/" -e "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" -e "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" "${file}"
		done
		sleep 3
		# enable modules
		vstacklet::shell::text::white "enabling PHP Modules ... "
		phpmods=("opcache" "xml" "igbinary" "imagick" "intl" "mbstring" "gmp" "bcmath" "msgpack")
		for i in "${phpmods[@]}"; do
			phpenmod -v "${php}" "${i}"
		done
		[[ -n ${memcached} ]] && phpenmod -v "${php}" memcached
		[[ -n ${redis} ]] && phpenmod -v "${php}" redis
	fi
}

##################################################################################
# @name: vstacklet::hhvm::install (24)
# @description: Install HHVM and configure.
#
# notes:
# - HHVM is not compatible with PHP, so choose one or the other.
# @option: $1 - `-hhvm | --hhvm` (optional) (takes no arguments)
# @example: ./vstacklet.sh -hhvm
# ./vstacklet.sh --hhvm
# @null
# @return_code: 43 - hhvm and php cannot be installed at the same time, please choose one
# @return_code: 44 - failed to install hhvm dependencies
# @return_code: 45 - failed to install hhvm
# @return_code: 46 - failed to update php alternatives
# @break
##################################################################################
vstacklet::hhvm::install() {
	if [[ -n ${hhvm} && -z ${php} ]]; then
		# check for php
		[[ -n ${php} ]] && vstacklet::clean::rollback 43
		# check for nginx \\ to maintain modularity, nginx is not required for HHVM
		#[[ -z ${nginx} ]] && vstacklet::clean::rollback "hhvm requires nginx. please install with -nginx."
		# install hhvm
		vstacklet::shell::text::white "installing and configuring hhvm ... "
		# install php dependencies and php
		for depend in "${hhvm_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing HHVM dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 44
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		# install hhvm
		/usr/share/hhvm/install_fastcgi.sh >>"${vslog}" 2>&1 || vstacklet::clean::rollback 45
		# update php alternatives
		/usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60 >>"${vslog}" 2>&1 || vstacklet::clean::rollback 46
		# get off the port and use socket - vStacklet nginx configurations already know this
		cp -f "${local_hhvm_dir}server.ini.template" /etc/hhvm/server.ini
		cp -f "${local_hhvm_dir}php.ini.template" /etc/hhvm/php.ini
	fi
}

##################################################################################
# @name: vstacklet::nginx::install (25)
# @description: Install NGinx and configure.
#
# notes:
# - The following profiles are included:
#   - Location profiles
#     - cache-busting
#     - cross-domain-fonts
#     - expires
#     - protect-system-files
#     - letsencrypt
#   - Security profiles
#     - ssl
#     - cloudflare-real-ip
#     - common-exploit-prevention
#     - mime-type-security
#     - reflected-xss-prevention
#     - sec-bad-bots
#     - sec-file-injection
#     - sec-php-easter-eggs
#     - server-security-options
#     - socket-settings
# - These config can be found at /etc/nginx/server.configs/
# @option: $1 - `-nginx | --nginx` (optional) (takes no arguments)
# @example: ./vstacklet.sh -nginx
# ./vstacklet.sh --nginx
# ./vstacklet.sh -nginx -php 8.1 -varnish -varnishP 80 -http 8080 -https 443
# ./vstacklet.sh --nginx --php 8.1 --varnish --varnishP 80 --http 8080 --https 443
# @null
# @return_code: 47 - failed to install nginx dependencies
# @return_code: 48 - missing required option for nginx configuration - ${e}
# @return_code: 49 - failed to edit nginx configuration
# @return_code: 50 - failed to enable nginx configuration
# @return_code: 51 - failed to generate dhparam file
# @return_code: 52 - failed to stage checkinfo.php verification file
# @break
##################################################################################
vstacklet::nginx::install() {
	if [[ -n ${nginx} ]]; then
		[[ -z ${domain} && -n ${hostname} ]] && declare -g domain="${hostname}"
		[[ -z ${domain} && -z ${hostname} ]] && declare -hn domain="vs-site1"
		vstacklet::shell::text::white "installing and Adjusting NGinx ... "
		# install nginx dependencies
		for depend in "${nginx_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing nginx dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 47
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		vstacklet::log "systemctl stop nginx"
		mkdir -p "${vstacklet_base_path}/setup/nginx/temp"
		[[ -f /etc/nginx/nginx.conf ]] && mv -f /etc/nginx/nginx.conf "${vstacklet_base_path:?}/setup/nginx/temp/nginx.conf"
		[[ -f /etc/nginx/sites-enabled/default ]] && mv -f /etc/nginx/sites-enabled/default "${vstacklet_base_path:?}/setup/nginx/temp/default"
		mv /etc/nginx /etc/nginx-pre-vstacklet
		mkdir -p /etc/nginx/{conf.d,cache,ssl,sites-enabled,sites-available}
		sed -i "s/{{server_ip}}/${server_ip};/" "${vstacklet_base_path:?}/nginx/server.configs/directives/cloudflare-real-ip.conf"
		sed -i "s/{{webroot}}/${web_root:-/var/www/html}\/public\/.well-known/g" "/etc/nginx/server.configs/location/letsencrypt.conf"
		sleep 3
		rsync -aP --exclude=/pagespeed --exclude=LICENSE --exclude=README --exclude=.git "${vstacklet_base_path:?}/nginx"/* /etc/nginx/ >/dev/null 2>&1
		\cp -rf /etc/nginx-pre-vstacklet/uwsgi_params /etc/nginx-pre-vstacklet/fastcgi_params /etc/nginx/
		chown -R www-data:www-data /etc/nginx/cache
		chmod -R 755 /etc/nginx/cache
		sh -c 'find /etc/nginx -type f -exec chmod 644 {} \;'
		chmod -R g+rw /etc/nginx/cache
		sh -c 'find /etc/nginx/cache -type d -print0 | sudo xargs -0 chmod g+s'
		# import nginx reverse config files from vStacklet
		if [[ ${php} == *"8"* ]]; then
			cp -f "${local_php8_dir}/nginx/conf.d/default.php8.conf" "/etc/nginx/sites-available/${domain}.conf"
		fi
		if [[ ${php} == *"7"* ]]; then
			cp -f "${local_php7_dir}/nginx/conf.d/default.php7.conf" "/etc/nginx/sites-available/${domain}.conf"
		fi
		if [[ -n ${hhvm} ]]; then
			cp -f "${local_hhvm_dir}/nginx/conf.d/default.hhvm.conf" "/etc/nginx/sites-available/${domain}.conf"
		fi
		vstacklet::shell::text::white "configuring NGinx ... "
		# post necessary edits to nginx config files
		wr_sanitize=$(echo "${web_root:-/var/www/html}" | sed 's/\//\\\//g')
		sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{domain}}|${domain:-${hostname:-vs-site1}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-8.1}|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" || vstacklet::rollback::clean 49
		# enable site
		ln -sf "/etc/nginx/sites-available/${domain}.conf" "/etc/nginx/sites-enabled/${domain}.conf" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 50
		# generate self-signed ssl cert and Diffie-Hellman parameters file
		[[ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]] && openssl req -config "${vstacklet_base_path}/setup/templates/ssl/openssl.conf" -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem >>"${vslog}" 2>&1
		[[ ! -f /etc/nginx/ssl/dhparam.pem ]] && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 >>"${vslog}" 2>&1
		openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 >>"${vslog}" 2>&1 || vstacklet::rollback::clean 51
		# stage checkinfo.php for verification
		vstacklet::shell::text::yellow "staging checkinfo.php ... "
		if [[ -n ${web_root} ]]; then
			echo '<?php phpinfo(); ?>' >"${web_root}/public/checkinfo.php" || vstacklet::clean::rollback 52
			chown -R www-data:www-data "${web_root}"
			chmod -R 755 "${web_root}"
			chmod -R g+rw "${web_root}"
			sh -c 'find "${web_root}" -type d -print0 | sudo xargs -0 chmod g+s'
		else
			echo '<?php phpinfo(); ?>' >/var/www/html/public/checkinfo.php || vstacklet::clean::rollback 52
			chown -R www-data:www-data /var/www/html
			chmod -R 755 /var/www/html
			chmod -R g+rw /var/www/html
			sh -c 'find /var/www/html -type d -print0 | sudo xargs -0 chmod g+s'
		fi
	fi
}

##################################################################################
# @name: vstacklet::varnish::install (26)
# @description: Install Varnish and configure.
#
# notes:
# - varnish is installed based on the following variables:
#   - `-varnish` (optional)
#   - `-varnishP|--varnish_port` (optional) (default: 6081)
#   - `-http|--http_port` (optional) (default: 80)
#  - if you are not familiar with Varnish, please read the following:
#   - https://www.varnish-cache.org/
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
# ./vstacklet.sh -varnish -varnishP 80 -nginx -http 8080 --https_port 443
# @null
# @return_code: 53 - failed to install varnish package
# @return_code: 54 - could not switch to /etc/varnish directory
# @return_code: 55 - failed to reload the systemd daemon
# @return_code: 56 - failed to switch to ~/
# @break
##################################################################################
vstacklet::varnish::install() {
	if [[ -n ${varnish} ]]; then
		vstacklet::shell::text::white "installing and configuring varnish ... "
		# install varnish dependencies
		for depend in "${varnish_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing vanish dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 53
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		cd /etc/varnish || vstacklet::clean::rollback 54
		mv default.vcl default.vcl.ORIG
		# import varnish config files from vStacklet
		cp -f "${local_varnish_dir}default.vcl" "/etc/varnish/default.vcl"
		# adjust varnish config files
		sed -i "s|{{server_ip}}|${server_ip}|g" /etc/varnish/default.vcl
		sed -i "s|{{varnish_port}}|${varnish_port:-6081}|g" /etc/default/varnish
		# adjust varnish service
		cp -f /lib/systemd/system/varnishlog.service /etc/systemd/system/
		cp -f /lib/systemd/system/varnish.service /etc/systemd/system/
		sed -i "s|{{varnish_port}}|${varnish_port:-6081}|g" /etc/systemd/system/varnish.service
		sed -i "s|{{varnish_port}}|${varnish_port:-6081}|g" /lib/systemd/system/varnish.service
		vstacklet::log "systemctl daemon-reload" || vstacklet::clean::rollback 55
		cd "${HOME}" || vstacklet::clean::rollback 56
	fi
}

##################################################################################
# @name: vstacklet::permissions::adjust (27)
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
	vstacklet::shell::text::white "adjusting permissions ... "
	chown -R www-data:www-data "${web_root:-/var/www/html}"
	chmod -R 755 "${web_root:-/var/www/html}"
	sh -c "find ${web_root:-/var/www/html} -type f -print0 | sudo xargs -0 chmod 644"
	chmod -R g+rw "${web_root:-/var/www/html}"
	sh -c "find ${web_root:-/var/www/html} -type d -print0 | sudo xargs -0 chmod g+s"
}

##################################################################################
# @name: vstacklet::ioncube::install (28)
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
# @null
# @return_code: 57 - failed to switch to /tmp directory
# @return_code: 58 - failed to download ioncube loader
# @return_code: 59 - failed to extract ioncube loader
# @return_code: 60 - failed to switch to /tmp/ioncube directory
# @return_code: 61 - failed to copy ioncube loader to /usr/lib/php/ directory
# @return_code: 62 - failed to enable ioncube loader php extension
# @break
##################################################################################
vstacklet::ioncube::install() {
	if [[ -n ${ioncube} ]]; then
		vstacklet::shell::text::white "installing IonCube Loader for php-${php} ... "
		# install ioncube loader for php 7.4
		if [[ ${php} == "7.4" ]]; then
			cd /tmp || vstacklet::clean::rollback 57
			vstacklet::log "wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 58
			vstacklet::log "tar -xvzf ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 59
			cd ioncube || vstacklet::clean::rollback 60
			cp -f ioncube_loader_lin_7.4.so /usr/lib/php/20190902/ || vstacklet::clean::rollback 61
			echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" >/etc/php/7.4/mods-available/ioncube.ini
			ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/cli/conf.d/20-ioncube.ini
			ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/fpm/conf.d/20-ioncube.ini
			phpenmod -v 7.4 ioncube || vstacklet::clean::rollback 62
		fi
		# install ioncube loader for php 8.1
		if [[ ${php} == "8.1" ]]; then
			cd /tmp || vstacklet::clean::rollback 57
			vstacklet::log "wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 58
			vstacklet::log "tar -xvzf ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 59
			cd ioncube || vstacklet::clean::rollback 60
			cp -f ioncube_loader_lin_8.1.so /usr/lib/php/20210902/ || vstacklet::clean::rollback 61
			echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" >/etc/php/8.1/mods-available/ioncube.ini
			ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/cli/conf.d/20-ioncube.ini
			ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/fpm/conf.d/20-ioncube.ini
			phpenmod -v 8.1 ioncube || vstacklet::clean::rollback 62
		fi
	fi
}

##################################################################################
# @name: vstacklet::mariadb::install (29)
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
# ./vstacklet.sh -mariadb -mariadbP 3306 -mariadbU root
# ./vstacklet.sh --mariadb --mariadb_port 3306 --mariadb_user root
# ./vstacklet.sh -mariadb -mariadbP 3306
# ./vstacklet.sh --mariadb --mariadb_port 3306
# ./vstacklet.sh -mariadb
# ./vstacklet.sh --mariadb
# @null
# @return_code: 63 - failed to install mariadb
# @return_code: 64 - failed to initialize mariadb secure installation
# @return_code: 65 - failed to create mariadb root user
# @return_code: 66 - failed to create mariadb root user password
# @return_code: 67 - failed to create mariadb root user host
# @return_code: 68 - failed to flush privileges
# @return_code: 69 - failed to set mariadb client and server configuration
# @break
##################################################################################
vstacklet::mariadb::install() {
	if [[ -n ${mariadb} && -z ${mysql} ]]; then
		declare mariadb_autoPw
		mariadb_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		vstacklet::shell::text::white "installing and configuring mariaDB ... "
		# install mariadb dependencies
		for depend in "${mariadb_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing mariaDB dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || setup::clean::rollback 63
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		# configure mariadb
		vstacklet::log "mysql_secure_installation" || vstacklet::clean::rollback 64
		vstacklet::log "mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mariadb_password:-${mariadb_autoPw}}';\"" || vstacklet::clean::rollback 65
		vstacklet::log "mysql -u root -p${mariadb_password:-${mariadb_autoPw}} -e \"CREATE USER '${mariadb_user:-root}'@'localhost' IDENTIFIED BY '${mariadb_password:-${mariadb_autoPw}}';\"" || vstacklet::clean::rollback 66
		vstacklet::log "mysql -u root -p${mariadb_password:-${mariadb_autoPw}} -e \"GRANT ALL PRIVILEGES ON *.* TO '${mariadb_user:-root}'@'localhost' WITH GRANT OPTION;\"" || vstacklet::clean::rollback 67
		vstacklet::log "mysql -u root -p${mariadb_password:-${mariadb_autoPw}} -e \"FLUSH PRIVILEGES;\"" || vstacklet::clean::rollback 68
		# set mariadb client and server configuration
		{
			echo -e "[client]"
			echo -e "port = ${mariadb_port:-3306}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "[mysqld]"
			echo -e "port = ${mariadb_port:-3306}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"

		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::clean::rollback 69
		vstacklet::shell::text::green::sl "mariaDB installed and configured. see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mariaDB password: "
		vstacklet::shell::text::green::sl "${mariadb_password:-${mariadb_autoPw}}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mariaDB user: "
		vstacklet::shell::text::green::sl "${mariadb_user:-root}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mariaDB port: "
		vstacklet::shell::text::green::sl "${mariadb_port:-3306}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mariaDB socket: "
		vstacklet::shell::text::green::sl "/var/run/mysqld/mysqld.sock"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mariaDB configuration file: "
		vstacklet::shell::text::green::sl "/etc/mysql/conf.d/vstacklet.cnf"
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::mysql::install - install and configure mysql (30)
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
# @null
# @return_code: 70 - failed to get mysql deb package
# @return_code: 71 - failed to install mysql deb package
# @return_code: 72 - failed to install mysql dependencies
# @return_code: 73 - failed to set mysql root password
# @return_code: 74 - failed to create mysql user
# @return_code: 75 - failed to grant mysql user privileges
# @return_code: 76 - failed to flush mysql privileges
# @return_code: 77 - failed to set mysql client and server configuration
# @break
##################################################################################
vstacklet::mysql::install() {
	if [[ -n ${mysql} && -z ${mariadb} ]]; then
		declare mysql_autoPw
		mysql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		mysql_deb_version="mysql-apt-config_0.8.24-1_all.deb"
		vstacklet::shell::text::white "installing and configuring mySQL ... "
		# install mysql deb
		vstacklet::log "wget https://dev.mysql.com/get/mysql-apt-config_${mysql_deb_version}_all.deb -O /tmp/mysql-apt-config_${mysql_deb_version}_all.deb" || vstacklet::clean::rollback 70
		vstacklet::log "dpkg -i ${mysql_deb_version}" || vstacklet::clean::rollback 71
		# install mysql dependencies
		declare -a depend_list install_list
		for depend in "${mysql_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing mySQL dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || setup::clean::rollback 72
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend_list install_list
		# configure mysql
		vstacklet::log "mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_password:-${mysql_autoPw}}';\"" || vstacklet::clean::rollback 73
		vstacklet::log "mysql -u root -p${mysql_password:-${mysql_autoPw}} -e \"CREATE USER '${mysql_user:-root}'@'localhost' IDENTIFIED BY '${mysql_password:-${mysql_autoPw}}';\"" || vstacklet::clean::rollback 74
		vstacklet::log "mysql -u root -p${mysql_password:-${mysql_autoPw}} -e \"GRANT ALL PRIVILEGES ON *.* TO '${mysql_user:-root}'@'localhost' WITH GRANT OPTION;\"" || vstacklet::clean::rollback 75
		vstacklet::log "mysql -u root -p${mysql_password:-${mysql_autoPw}} -e \"FLUSH PRIVILEGES;\"" || vstacklet::clean::rollback 76
		# set mysql client and server configuration
		{
			echo -e "[client]"
			echo -e "port = ${mysql_port:-3306}"
			echo -e "socket = /var/run/mysqld/mysqld.sock"
			echo -e "[mysqld]"
			echo -e "port = ${mysql_port:-3306}"
			echo -e "socket = /var/run/mysql/mysql.sock"
			echo -e "bind-address = 127.0.0.1"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::clean::rollback 77
		vstacklet::shell::text::green "mySQL installed and configured. see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mySQL password: "
		vstacklet::shell::text::green::sl "${mysql_password:-${mysql_autoPw}}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mySQL user: "
		vstacklet::shell::text::green::sl "${mysql_user:-root}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mySQL port: "
		vstacklet::shell::text::green::sl "${mysql_port:-3306}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mySQL socket: "
		vstacklet::shell::text::green::sl "/var/run/mysqld/mysqld.sock"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "mySQL configuration file: "
		vstacklet::shell::text::green::sl "/etc/mysql/conf.d/vstacklet.cnf"
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::postgre::install - install and configure postgreSQL (31)
# @description: Install and configure postgreSQL.
# @option: $1 - `-postgre | --postgresql` (optional)
# @arg: $2 - `[postgresql_port]` (optional) (default: 5432)
# @arg: $3 - `[postgresql_user]` (optional) (default: root)
# @arg: $4 - `[postgresql_password]` (optional) (default: password auto-generated)
# @example: ./vstacklet.sh -postgre -postgreP 5432 -postgreU root -postgrePw password
# @example: ./vstacklet.sh --postgresql --postgresql_port 5432 --postgresql_user root --postgresql_password password
# @return_code: 78 - postgreSQL dependencies installation failed
# @return_code: 79 - failed to switch to /etc/postgresql/${postgre_version}/main
# @break
##################################################################################
vstacklet::postgre::install() {
	if [[ -n ${postgresql} ]]; then
		declare postgresql_autoPw
		postgresql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		vstacklet::shell::text::white "installing and configuring postgreSQL ... "
		# install postgre dependencies
		declare -a depend_list install_list
		for depend in "${postgresql_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing postgreSQL dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 78
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend_list install_list
		# configure postgre
		# @script-note: scrape the version from the output of `apt-cache policy postgresql`
		# since the `psql --version` could return blank if ran too soon after the installation.
		# this also allows a faster installation as no sleep is required.
		#postgre_version="$(psql --version | awk '{print $3}' | awk -F. '{print $1"."$2}')"
		declare postgre_version
		postgre_version="$(apt-cache policy postgresql | grep -A1 "Installed:" | grep -v "Installed:" | awk '{print $2}' | awk -F. '{print $1"."$2}' | cut -d'+' -f1)"
		# to make alterations to postgresql, we must first switch to a directory
		# that postgresql has access to
		cd "/etc/postgresql/${postgre_version}/main" || vstacklet::clean::rollback 79
		# set postgresql root password
		vstacklet::log "sudo -u postgres psql -c \"ALTER USER postgres WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';\"" || vstacklet::clean::rollback 80
		# create postgresql user
		vstacklet::log "sudo -u postgres psql -c \"CREATE USER ${postgresql_user:-root} WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';\"" || vstacklet::clean::rollback 81
		# grant postgresql user privileges
		vstacklet::log "sudo -u postgres psql -c \"ALTER USER ${postgresql_user:-root} WITH SUPERUSER;\"" || vstacklet::clean::rollback 82
		# set postgre client and server configuration
		cp -f "/etc/postgresql/${postgre_version}/main/postgresql.conf" "/etc/postgresql/${postgre_version}/main/postgresql.conf.default-bak"
		{
			echo -e "port = ${postgresql_port:-5432}"
			echo -e "listen_addresses = 'localhost'"
		} >"/etc/postgresql/${postgre_version}/main/postgresql.conf" || vstacklet::clean::rollback 83
		cp -f "/etc/postgresql/${postgre_version}/main/pg_hba.conf" "/etc/postgresql/${postgre_version}/main/pg_hba.conf.default-bak"
		{
			echo -e "# Database administrative login by Unix domain socket"
			echo -e "local   all             postgres                                peer"
			echo
			echo -e "# TYPE  DATABASE        USER            ADDRESS                 METHOD"
			echo
			echo -e "# \"local\" is for Unix domain socket connections only"
			echo -e "local   all             all                                     md5"
		} >"/etc/postgresql/${postgre_version}/main/pg_hba.conf" || vstacklet::clean::rollback 84
		vstacklet::shell::text::green "postgreSQL installed and configured. see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "postgre password:"
		vstacklet::shell::text::green::sl "${postgresql_password:-${postgresql_autoPw}}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "postgre user:"
		vstacklet::shell::text::green::sl "${postgresql_user:-root}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "postgre port:"
		vstacklet::shell::text::green::sl "${postgresql_port:-5432}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "postgre socket:"
		vstacklet::shell::text::green::sl "/var/run/postgresql"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "configuration file saved to:"
		vstacklet::shell::text::green::sl "/etc/postgresql/${postgre_version}/main/postgresql.conf"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "configuration file saved to:"
		vstacklet::shell::text::green::sl "/etc/postgresql/${postgre_version}/main/pg_hba.conf"
	fi
}

##################################################################################
# @name: vstacklet::redis::install - Install and configure redis (32)
# @description: Install and configure redis.
# @option: $1 - `-redis | --redis` (optional)
# @option: $2 - `-redisP | --redis_port` (optional)
# @option: $3 - `-redisPw | --redis_password` (optional)
# @arg: $2 - `[redis_port]` (optional) (default: 6379)
# @arg: $3 - `[redis_password]` (optional) (default: password auto-generated)
# @example: ./vstacklet.sh -redis -redisP 6379 -redisPw password
# @example: ./vstacklet.sh --redis --redis_port 6379 --redis_password password
# @example: ./vstacklet.sh -redis
# @example: ./vstacklet.sh --redis
# @null
# @return_code: 90 - failed to install redis deb package
# @return_code: 91 - failed to install redis dependencies
# @return_code: 92 - failed to set redis root password
# @return_code: 93 - failed to set redis client and server configuration
# @break
##################################################################################
vstacklet::redis::install() {
	if [[ -n ${redis} ]]; then
		declare redis_autoPw
		redis_autoPw="$(perl -e 'print map { (a..z,A..Z,0..9)[rand 62] } 0..15')"
		vstacklet::shell::text::white "installing and configuring redis ... "
		# install redis dependencies
		declare -a depend_list install_list
		for depend in "${redis_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing redis dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 85
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend_list install_list
		# configure redis
		# set redis client and server configuration
		cp -f /etc/redis/redis.conf /etc/redis/redis.conf.bak || vstacklet::clean::rollback 86
		cp -f "${vstacklet_base_path}/setup/templates/redis/redis.conf" /etc/redis/redis.conf || vstacklet::clean::rollback 87
		sed -i.bak "s/{{redis_port}}/${redis_port:-6379}/g" /etc/redis/redis.conf || vstacklet::clean::rollback 88
		# restart redis
		vstacklet::log "systemctl restart redis-server" || vstacklet::clean::rollback 89
		# set redis password
		vstacklet::log "redis-cli -a \"\" -h localhost -p ${redis_port:-6379} config set requirepass ${redis_password:-${redis_autoPw}}" || vstacklet::clean::rollback 90
		vstacklet::shell::text::green "redis installed and configured. see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "redis password: "
		vstacklet::shell::text::green::sl "${redis_password:-${redis_autoPw}}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "redis port: "
		vstacklet::shell::text::green::sl "${redis_port:-6379}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "redis socket: "
		vstacklet::shell::text::green::sl "/var/run/redis/redis-server.sock"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "redis configuration: "
		vstacklet::shell::text::green::sl "/etc/redis/redis.conf"
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::phpmyadmin::install - Install and configure phpMyAdmin (33)
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
# @null
# @return_code: 78 - a database server was not selected
# @return_code: 79 - a web server was not selected
# @return_code: 80 - a php version was not selected
# @return_code: 81 - phpMyAdmin does not support HHVM
# @return_code: 82 - failed to install dependencies
# @return_code: 83 - failed to switch to /usr/share directory
# @return_code: 84 - failed to remove existing phpMyAdmin directory
# @return_code: 85 - failed to download phpMyAdmin
# @return_code: 86 - failed to extract phpMyAdmin
# @return_code: 87 - failed to move phpMyAdmin to /usr/share directory
# @return_code: 88 - failed to remove phpMyAdmin archive
# @return_code: 89 - failed to set ownership of phpMyAdmin directory
# @return_code: 90 - failed to set permissions of phpMyAdmin directory
# @return_code: 91 - failed to create /usr/share/phpmyadmin/tmp directory
# @return_code: 92 - failed to set symlink of phpMyAdmin
# @return_code: 93 - failed to create phpMyAdmin configuration file
# @break
##################################################################################
vstacklet::phpmyadmin::install() {
	# If you prefer a more modular installation, you can comment out the following 3 lines.
	[[ -z ${mariadb} || -z ${mysql} ]] && vstacklet::clean::rollback 91
	[[ -z ${nginx} && -z ${varnish} ]] && vstacklet::clean::rollback 92
	[[ -z ${php} ]] && vstacklet::clean::rollback 93
	# check if hhvm is selected and throw an error if it is
	[[ -n ${hhvm} ]] && vstacklet::clean::rollback 94
	if [[ (-n ${phpmyadmin}) && (-n ${mariadb} || -n ${mysql}) && (-n ${nginx} || -n ${varnish}) && (-n ${php}) ]]; then
		declare pma_version pma_password pma_bf
		pma_version=$(curl -s https://www.phpmyadmin.net/home_page/version.json | jq -r '.version')
		pma_password="${mariadb_password:-${mysql_password:-$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)}}"
		pma_bf=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..31')
		# install phpmyadmin
		vstacklet::shell::text::white "installing phpMyAdmin ... "
		# install phpmyadmin dependencies and phpmyadmin
		for depend in "${phpmyadmin_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing php dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 95
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		cd /usr/share || vstacklet::clean::rollback 96
		[[ -d phpmyadmin ]] && rm -rf phpmyadmin
		wget -q https://files.phpmyadmin.net/phpMyAdmin/"${pma_version}"/phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::clean::rollback 97
		tar -xzf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::clean::rollback 98
		mv phpMyAdmin-"${pma_version}"-all-languages phpmyadmin || vstacklet::clean::rollback 99
		rm -rf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::clean::rollback 100
		chown -R www-data:www-data phpmyadmin || vstacklet::clean::rollback 101
		chmod -R 755 phpmyadmin || vstacklet::clean::rollback 102
		# trunk-ignore(shellcheck/SC2015)
		mkdir -p /usr/share/phpmyadmin/tmp && chown -R www-data:www-data /usr/share/phpmyadmin/tmp || vstacklet::clean::rollback 103
		# trunk-ignore(shellcheck/SC2015)
		[[ -n ${web_root} ]] && ln -sf /usr/share/phpmyadmin "${web_root}/public" || vstacklet::clean::rollback 104
		# trunk-ignore(shellcheck/SC2015)
		[[ -z ${web_root} ]] && ln -sf /usr/share/phpmyadmin /var/www/html/public || vstacklet::clean::rollback 105
		# configure phpmyadmin
		vstacklet::shell::text::white "configuring phpMyAdmin ... "
		# create phpmyadmin htpasswd file - this is used for basic authentication, not for the database
		# this is only used if/when the user opts to use basic authentication (a post install courtesy)
		htpasswd -b -c /usr/share/phpmyadmin/.htpasswd "${mariadb_user:-${mysql_user:-root}}" "${pma_password}" >>${vslog} 2>&1 || vstacklet::clean::rollback 106
		# set phpmyadmin configuration
		{
			echo -e "<?php"
			echo -e "/* Servers configuration */"
			echo -e "\$i = 0;"
			echo -e "/* Server: localhost [1] */"
			echo -e "\$i++;"
			echo -e "\$cfg['Servers'][\$i]['verbose'] = 'localhost';"
			echo -e "\$cfg['Servers'][\$i]['host'] = 'localhost';"
			echo -e "\$cfg['Servers'][\$i]['port'] = '${http_port:-80}';"
			echo -e "\$cfg['Servers'][\$i]['socket'] = '';"
			echo -e "\$cfg['Servers'][\$i]['connect_type'] = 'tcp';"
			echo -e "\$cfg['Servers'][\$i]['extension'] = 'mysqli';"
			echo -e "\$cfg['Servers'][\$i]['compress'] = false;"
			echo -e "\$cfg['Servers'][\$i]['auth_type'] = 'cookie';"
			echo -e "\$cfg['Servers'][\$i]['user'] = '${mariadb_user:-${mysql_user:-root}}';"
			echo -e "\$cfg['Servers'][\$i]['password'] = '${pma_password}';"
			echo -e "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;"
			echo -e "/* End of servers configuration */"
			echo -e "\$cfg['blowfish_secret'] = '${pma_bf}';"
			echo -e "\$cfg['DefaultLang'] = 'en';"
			echo -e "\$cfg['ServerDefault'] = 1;"
			echo -e "\$cfg['UploadDir'] = '';"
			echo -e "\$cfg['SaveDir'] = '';"
			echo -e "?>"
		} >/etc/phpmyadmin/config.inc.php || vstacklet::clean::rollback 107
		vstacklet::shell::text::green "phpMyAdmin installed and configured. see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin version: "
		vstacklet::shell::text::green::sl "${pma_version}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin username: "
		vstacklet::shell::text::green::sl "${mariadb_user:-${mysql_user:-root}}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin password: "
		vstacklet::shell::text::green::sl "${pma_password}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin http port: "
		vstacklet::shell::text::green::sl "${http_port:-80}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin htpasswd file: "
		vstacklet::shell::text::green::sl "/usr/share/phpmyadmin/.htpasswd"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin web root: "
		vstacklet::shell::text::green::sl "${web_root:-/var/www/html}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "phpMyAdmin configuration file: "
		vstacklet::shell::text::green::sl "/etc/phpmyadmin/config.inc.php"
	fi
}

##################################################################################
# @name: vstacklet::csf::install - Install and configure CSF firewall (34)
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
# @null
# @return_code: 94 - CSF firewall dependencies failed to install
# @return_code: 95 - CSF firewall failed to download
# @return_code: 96 - failed to switch to /usr/local/src/csf directory
# @return_code: 97 - CSF firewall failed to install
# @return_code: 98 - CSF firewall failed to configure
# @return_code: 99 - failed to modify CSF blocklist
# @return_code: 100 - failed to modify CSF ignore list
# @return_code: 101 - failed to modify CSF allow list
# @return_code: 102 - failed to modify CSF allow ports (inbound)
# @return_code: 103 - failed to modify CSF allow ports (outbound)
# @return_code: 104 - failed to modify CSF configuration file (csf.conf)
# @break
##################################################################################
vstacklet::csf::install() {
	# check if csf is installed
	[[ -f /etc/csf/csf.conf ]] && vstacklet::shell::text::yellow "CSF is already installed. skipping ... " && return 0
	# install csf
	vstacklet::shell::text::white "installing CSF (ConfigServer Security & Firewall) firewall ... "
	# install csf dependencies and csf
	for depend in "${csf_dependencies[@]}"; do
		if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
			depend_list+=("${depend}")
		fi
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing CSF dependencies: "
	for install in "${depend_list[@]}"; do
		if [[ ${install} == "${depend_list[0]}" ]]; then
			vstacklet::shell::text::white::sl "${install} "
		else
			vstacklet::shell::text::white::sl "| ${install} "
		fi
		# shellcheck disable=SC2015
		DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 108
		install_list+=("${install}")
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
	unset depend depend_list install
	# install csf
	wget -O - https://download.configserver.com/csf.tgz | tar -xz -C /usr/local/src >>${vslog} 2>&1 || vstacklet::clean::rollback 109
	cd /usr/local/src/csf || vstacklet::clean::rollback 110
	sh install.sh >>"${vslog}" 2>&1 || vstacklet::clean::rollback 111
	# configure csf
	vstacklet::shell::text::white "configuring CSF ... "
	perl /usr/local/csf/bin/csftest.pl >>"${vslog}" 2>&1 || vstacklet::clean::rollback 112
	# modify csf blocklists - essentiallly like cloudflare, but for csf
	# https://www.configserver.com/cp/csf.html#blocklists
	sed -i.bak -e 's/^SPAMDROP|86400|0|/SPAMDROP|86400|100|/g' -e 's/^SPAMEDROP|86400|0|/SPAMEDROP|86400|100|/g' -e 's/^DSHIELD|86400|0|/DSHIELD|86400|100|/g' -e 's/^TOR|86400|0|/TOR|86400|100|/g' -e 's/^ALTTOR|86400|0|/ALTTOR|86400|100|/g' -e 's/^BOGON|86400|0|/BOGON|86400|100|/g' -e 's/^HONEYPOT|86400|0|/HONEYPOT|86400|100|/g' -e 's/^CIARMY|86400|0|/CIARMY|86400|100|/g' -e 's/^BFB|86400|0|/BFB|86400|100|/g' -e 's/^OPENBL|86400|0|/OPENBL|86400|100|/g' -e 's/^AUTOSHUN|86400|0|/AUTOSHUN|86400|100|/g' -e 's/^MAXMIND|86400|0|/MAXMIND|86400|100|/g' -e 's/^BDE|3600|0|/BDE|3600|100|/g' -e 's/^BDEALL|86400|0|/BDEALL|86400|100|/g' /etc/csf/csf.blocklists >>"${vslog}" 2>&1 || vstacklet::clean::rollback 113
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
	} >>/etc/csf/csf.ignore || vstacklet::clean::rollback 114
	# modify csf.allow - allow ssh, http, https, mysql, mariadb, postgresql, redis, and varnish
	{
		echo
		echo "[ vStacklet Additions ]"
		echo "${ssh_port:-22}"
		echo "${ftp_port:-21}"
		echo "${http_port:-80}"
		echo "${https_port:-443}"
		[[ -n ${nginx} ]] && echo "${nginx_port:-80}"
		[[ -n ${nginx} ]] && echo "${nginx_ssl_port:-443}"
		[[ -n ${mysql_port} ]] && echo "${mysql_port:-3306}"
		[[ -n ${mariadb_port} ]] && echo "${mariadb_port:-3306}"
		[[ -n ${postgresql_port} ]] && echo "${postgresql_port:-5432}"
		[[ -n ${redis_port} ]] && echo "${redis_port:-6379}"
		[[ -n ${varnish_port} ]] && echo "${varnish_port:-6081}"
		[[ -n ${sendmail_port} ]] && echo "${sendmail_port:-25}"
	} >>/etc/csf/csf.allow || vstacklet::clean::rollback 115
	declare -a csf_allow_ports=("${ssh_port}" "${ftp_port}" "${http_port}" "${https_port}" "${mysql_port}" "${mariadb_port}" "${postgresql_port}" "${redis_port}" "${varnish_port}" "${sendmail_port}")
	# modify csf.conf - allow ssh, ftp, http, https, mysql, mariadb, postgresql, redis, sendmail, and varnish
	for p in "${csf_allow_ports[@]}"; do
		sed -i.bak -e "s/^TCP_IN = \"\$TCP_IN\"/TCP_IN = \"\$TCP_IN ${p}\"/g" -e "s/^TCP6_IN = \"\$TCP6_IN\"/TCP6_IN = \"\$TCP6_IN ${p}\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 116
		sed -i.bak -e "s/^TCP_OUT = \"\$TCP_OUT\"/TCP_OUT = \"\$TCP_OUT ${p}\"/g" -e "s/^TCP6_OUT = \"\$TCP6_OUT\"/TCP6_OUT = \"\$TCP6_OUT ${p}\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 117
	done
	# modify csf.conf - this is to be further refined
	sed -i.bak -e "s/^TESTING = \"1\"/TESTING = \"0\"/g" -e "s/^RESTRICT_SYSLOG = \"0\"/RESTRICT_SYSLOG = \"1\"/g" -e "s/^DENY_TEMP_IP_LIMIT = \"100\"/DENY_TEMP_IP_LIMIT = \"1000\"/g" -e "s/^SMTP_ALLOW_USER = \"\"/SMTP_ALLOW_USER = \"root\"/g" -e "s/^PT_USERMEM = \"200\"/PT_USERMEM = \"1000\"/g" -e "s/^PT_USERTIME = \"1800\"/PT_USERTIME = \"7200\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 118
	[[ -z ${sendmail} || ${sendmail_skip} -eq 1 ]] && vstacklet::sendmail::install
}

##################################################################################
# @name: vstacklet::sendmail::install - Install sendmail (35)
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
# @null
# @return_code: 119 - an email address was not provided. this is required for sendmail
# to be installed.
# @return_code: 106 - sendmail dependencies failed to install.
# @return_code: 107 - failed to edit aliases file.
# @return_code: 108 - failed to edit sendmail.cf file.
# @return_code: 109 - failed to edit main.cf file.
# @return_code: 110 - failed to edit master.cf file.
# @return_code: 111 - failed to create sasl_passwd file.
# @return_code: 112 - postmap failed.
# @return_code: 113 - failed to source new aliases.
# @break
##################################################################################
vstacklet::sendmail::install() {
	[[ -z ${email} ]] && vstacklet::clean::rollback 119
	if [[ -n ${sendmail} || -z ${sendmail_skip} ]]; then
		# install sendmail
		vstacklet::shell::text::white "installing sendmail ... "
		# install sendmail dependencies and sendmail
		for depend in "${sendmail_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing sendmail dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 120
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		unset depend depend_list install
		# configure sendmail
		vstacklet::shell::text::white "configuring sendmail ... "
		# modify aliases
		sed -i.bak -e "s/^root:.*$/root: ${email}/g" /etc/aliases >>"${vslog}" 2>&1 || vstacklet::rollback::clean 121
		# modify /etc/mail/sendmail.cf
		sed -i.bak -e "s/^DS.*$/DS${email}/g" \
			-e "s/^O DaemonPortOptions=Addr=${sendmail_port:-25}, Name=MTA-v4/O DaemonPortOptions=Addr=${sendmail_port:-25}, Name=MTA-v4, Family=inet/g" \
			-e "s/^O PrivacyOptions=authwarnings,novrfy,noexpnO PrivacyOptions=authwarnings,novrfy,noexpn/O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun/g" \
			-e "s/^O AuthInfo=.*/O AuthInfo=${email}:*:${email}/g" \
			-e "s/^O Mailer=smtp, Addr=${server_ip}, Port=smtp, Name=MTA-v4/O Mailer=smtp, Addr=${server_ip}, Port=smtp, Name=MTA-v4, Family=inet/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::rollback::clean 122
		# modify /etc/postfix/main.cf
		sed -i.bak -e "s/^#myhostname = host.domain.tld/myhostname = ${hostname:-${server_hostname}}/g" \
			-e "s/^#mydomain = domain.tld/mydomain = ${domain:-${server_ip}}/g" \
			-e "s/^#myorigin = \$mydomain/myorigin = \$mydomain/g" \
			-e "s/^#mydestination = \$myhostname, localhost.\$mydomain, localhost/mydestination = \$myhostname, localhost.\$mydomain, localhost/g" \
			-e "s/^#relayhost =/relayhost = ${server_ip}:${sendmail_port:-25}/g" /etc/postfix/main.cf >>"${vslog}" 2>&1 || vstacklet::rollback::clean 123
		# modify /etc/postfix/master.cf
		sed -i.bak -e "s/^#submission/submission/g" \
			-e "s/^#  -o syslog_name=postfix\/submission/  -o syslog_name=postfix\/submission/g" \
			-e "s/^#  -o smtpd_tls_security_level=encrypt/  -o smtpd_tls_security_level=encrypt/g" \
			-e "s/^#  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes/g" \
			-e "s/^#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/g" \
			-e "s/^#  -o milter_macro_daemon_name=ORIGINATING/  -o milter_macro_daemon_name=ORIGINATING/g" /etc/postfix/master.cf >>"${vslog}" 2>&1 || vstacklet::rollback::clean 124
		# modify /etc/postfix/sasl_passwd
		echo "[${server_ip}]:${sendmail_port:-25} ${email}:${email}" >/etc/postfix/sasl_passwd >>"${vslog}" 2>&1 || vstacklet::rollback::clean 125
		# modify /etc/postfix/sasl_passwd
		postmap /etc/postfix/sasl_passwd >>"${vslog}" 2>&1 || vstacklet::rollback::clean 126
		newaliases >>"${vslog}" 2>&1 || vstacklet::rollback::clean 127
	fi
}

##################################################################################
# @name: vstacklet::cloudflare::csf - Cloudflare CSF configuration (36)
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
# @null
# @return_code: 128 - csf has not been enabled ( -csf ). this is a component of the
# cloudflare configuration for config server firewall.
# @return_code: 129 - csf allow file does not exist.
# @break
##################################################################################
vstacklet::cloudflare::csf() {
	# check if CSF has been selected
	[[ -z ${csf} ]] && vstacklet::clean::rollback 128
	# check if Cloudflare has been selected
	if [[ -n ${cloudflare} ]]; then
		# check if the csf.allow file exists
		[[ ! -f "/etc/csf/csf.allow" ]] || vstacklet::rollback::clean 129
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
	fi
}

##################################################################################
# @name: vstacklet::wordpress::install - Install WordPress (37)
# @description: Install WordPress. This will also configure WordPress to use
# the database that was created during the installation process.
#
# notes:
# - this function is only called under the following conditions:
#   - the option `-wordpress` is used directly
# - this function will install wordpress and configure the database.
# - wordpress is an active build option and requires active intput from the user (for now).
# these options are:
#   - wordpress database name
#   - wordpress database user
#   - wordpress database password
# - this function requires the following options to be used:
#   - database: `-mariadb | --mariadb`, `-mysql | --mysql`, or `-postgresql | --postgresql`
#   - webserver: `-nginx | --nginx` or `-varnish | --varnish` (both can be used)
#   - php: `-php | --php`
# - this function will optionally use the following options:
#   - web root: `-wr | --web_root` (default: /var/www/html)
#
# @option: $1 - `-wordpress | --wordpress` (optional)
# @noargs
# @example: ./vstacklet.sh -wordpress -mariadb -nginx -php "8.1"
# ./vstacklet.sh -wordpress -mysql -nginx -php "8.1"
# ./vstacklet.sh -wordpress -postgresql -nginx -php "8.1"
#./vstacklet.sh -wordpress -mariadb -nginx -php "8.1" -varnish -varnishP 80 -http 8080 -https 443
# ./vstacklet.sh --wordpress --mariadb --nginx --php "8.1" --varnish --varnish_port 80 --http 8080 --https 443
# @null
# @return_code: 116 -
# @return_code: 117 -
# @return_code: 118 -
# @return_code: 119 -
# @return_code: 120 -
# @return_code: 121 -
# @break
##################################################################################
vstacklet::wordpress::install() {
	# check if WordPress has been selected
	# If you prefer a more modular installation, you can comment out the following 3 lines.
	[[ -z ${mariadb} || -z ${mysql} ]] && vstacklet::clean::rollback 130
	[[ -z ${nginx} || -z ${varnish} ]] && vstacklet::clean::rollback 131
	[[ -z ${php} || -z ${hhvm} ]] && vstacklet::clean::rollback 132
	if [[ -n ${wordpress} ]]; then
		vstacklet::vstacklet::shell::text::white "Please enter the following information for WordPress:"
		# get WordPress database name
		read -rp "WordPress database name: " wp_db_name
		# get WordPress database user
		read -rp "WordPress database user: " wp_db_user
		# get WordPress database password
		read -rp "WordPress database password: " wp_db_password
		vstacklet::vstacklet::shell::text::white "installing and configuring WordPress ... "
		# download WordPress
		vstacklet::log "wget -q -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz" || vstacklet::rollback::clean 130
		# extract WordPress
		vstacklet::log "tar -xzf /tmp/wordpress.tar.gz -C /tmp" || vstacklet::rollback::clean 131
		# move WordPress to the web root
		mv /tmp/wordpress/* "${web_root:-/var/www/html}/public" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 132
		# create the uploads directory
		mkdir "${web_root:-/var/www/html}/public/wp-content/uploads" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 133
		# set the correct permissions
		vstacklet::permissions::adjust
		# create the wp-config.php file
		vstacklet::log "cp ${web_root:-/var/www/html}/public/wp-config-sample.php ${web_root:-/var/www/html}/public/wp-config.php" || vstacklet::rollback::clean 134
		# modify the wp-config.php file
		sed -i \
			-e "s/database_name_here/${wp_db_name}/g" \
			-e "s/username_here/${wp_db_user}/g" \
			-e "s/password_here/${wp_db_password}/g" \
			-e "s/utf8mb4/utf8/g" \
			"${web_root:-/var/www/html}/public/wp-config.php" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 135
		# create the database
		vstacklet::log "mysql -u root -p${mariadb_password:-${mysql_password:-${postgresql_password}}} -e \"CREATE DATABASE ${wp_db_name};\"" || vstacklet::rollback::clean 136
		# create the database user
		vstacklet::log "mysql -u root -p${mariadb_password:-${mysql_password:-${postgresql_password}}} -e \"CREATE USER '${wp_db_user}'@'localhost' IDENTIFIED BY '${wp_db_password}';\"" || vstacklet::rollback::clean 137
		# grant privileges to the database user
		vstacklet::log "mysql -u root -p${mariadb_password:-${mysql_password:-${postgresql_password}}} -e \"GRANT ALL PRIVILEGES ON ${wp_db_name}.* TO '${wp_db_user}'@'localhost';\"" || vstacklet::rollback::clean 138
		# flush privileges
		vstacklet::log "mysql -u root -p${mariadb_password:-${mysql_password:-${postgresql_password}}} -e \"FLUSH PRIVILEGES;\"" || vstacklet::rollback::clean 139
		# remove the WordPress installation files
		vstacklet::log "rm -rf /tmp/wordpress /tmp/wordpress.tar.gz" || vstacklet::rollback::clean 140
		# display the WordPress installation URL
		vstacklet::shell::text::green "WordPress has been installed. see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "WordPress database name:"
		vstacklet::shell::text::green::sl "${wp_db_name}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "WordPress database user:"
		vstacklet::shell::text::green::sl "${wp_db_user}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "WordPress database password:"
		vstacklet::shell::text::green::sl "${wp_db_password}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "Complete WordPress installation at:"
		vstacklet::shell::text::green::sl "http://${domain:-${server_ip}}/wp-admin/install.php"
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::domain::ssl (38)
# @description: The following function installs the SSL certificate
#   for the domain.
#
# notes:
# - This function is only called under the following conditions:
#   - the option for `-domain` is used (optional)
# - The following options are required for this function:
#   - `-domain` or `--domain`
#   - `-email` or `--email`
#   - `-nginx` or `--nginx`
# @option: $1 - `-domain | --domain` - The domain to install the
#   SSL certificate for.
# @arg: $1 - `[domain]` (required)
# @example: ./vstacklet.sh -nginx -domain example.com -e "your@email.com"
# ./vstacklet.sh --nginx --domain example.com --email "your@email.com"
# @null
# @return_code: 116 - the `-nginx|--nginx` option is required.
# @return_code: 117 - the `-e|--email` option is required.
# @return_code: 118 - failed to change directory to /root.
# @return_code: 119 - failed to create directory ${web_root}/.well-known/acme-challenge.
# @return_code: 120 - failed to clone acme.sh.
# @return_code: 121 - failed to change directory to /root/acme.sh.
# @return_code: 122 - failed to install acme.sh.
# @return_code: 123 - missing required option(s) - ${e[@]}
# @return_code: 124 - failed to edit /etc/nginx/sites-available/${domain}.conf.
# @return_code: 125 - failed to reload nginx.
# @return_code: 126 - failed to register the account with Let's Encrypt.
# @return_code: 127 - failed to set the default CA to Let's Encrypt.
# @return_code: 128 - failed to issue the certificate.
# @return_code: 129 - failed to install the certificate.
# @break
##################################################################################
vstacklet::domain::ssl() {
	[[ -z ${nginx} ]] && vstacklet::rollback::clean 116
	[[ -z ${email} ]] && vstacklet::rollback::clean 117
	if [[ -n ${domain_ssl} ]]; then
		vstacklet::shell::text::white "installing SSL certificate for ${domain} ... "
		# build acme.sh for Let's Encrypt SSL
		cd "/root" || vstacklet::rollback::clean
		[[ -d "/root/.acme.sh" ]] && rm -rf "/root/.acme.sh" >>"${vslog}" 2>&1
		mkdir -p "${web_root}/.well-known/acme-challenge"
		chown -R root:www-data "${web_root}/.well-known" >>"${vslog}" 2>&1
		chmod -R 755 "${web_root}/.well-known" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 119
		git clone "https://github.com/Neilpang/acme.sh.git" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 120
		cd "/root/acme.sh" || vstacklet::rollback::clean 121
		./acme.sh --install --home "/root/.acme.sh" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 122
		# create nginx directory for SSL
		mkdir -p "/etc/nginx/ssl/${domain:?}"
		# create SSL certificate
		cp -f "${vstacklet_base_path:?}/setup/templates/nginx/acme" "/etc/nginx/sites-enabled/"
		# post necessary edits to nginx config files
		wr_sanitize=$(echo "${web_root:-/var/www/html}" | sed 's/\//\\\//g')
		sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{domain}}|${domain}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-8.1}|g" "/etc/nginx/sites-available/${domain}.conf" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 123
		sed -i "s/{{domain}}/${domain}/g" /etc/nginx/sites-enabled/acme
		systemctl reload nginx.service >>"${vslog}" 2>&1 || vstacklet::rollback::clean 124
		./acme.sh --register-account -m "${email:?}" >>"${vslog}" 2>&1 || vstacklet::rollback::clean 125
		./acme.sh --set-default-ca --server letsencrypt >>"${vslog}" 2>&1 || vstacklet::rollback::clean 126
		./acme.sh --issue -d "${domain}" -w "${web_root}" --server letsencrypt >>"${vslog}" 2>&1 || vstacklet::rollback::clean 127
		(
			./acme.sh --install-cert -d "${domain}" \
				--keylength ec-256 \
				--cert-file "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" \
				--key-file "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" \
				--fullchain-file "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" \
				--log "/var/log/vstacklet/${domain}.log" \
				--reloadcmd "systemctl reload nginx.service"
		) >>"${vslog}" 2>&1 || vstacklet::rollback::clean 128
		# remove acme ssl template
		rm -f /etc/nginx/sites-enabled/acme
		# display success message
		vstacklet::shell::text::green "Let's Encrypt SSL certificate installed for ${domain}! see details below:"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "SSL certificate location:"
		vstacklet::shell::text::green::sl "/etc/nginx/ssl/${domain}"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "SSL certificate log location:"
		vstacklet::shell::text::green::sl "/var/log/vstacklet/${domain}.log"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "SSL certificate expiration date:"
		vstacklet::shell::text::green::sl "$(openssl x509 -enddate -noout -in "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" | cut -d= -f2)"
		vstacklet::shell::misc::nl
	fi
}

################################################################################
# @name: vstacklet::clean::complete - Cleanup on completion (39)
# @description: Cleans up the system after a successful installation. This
#   function is called after the installation is complete. It removes the
#   temporary files and directories created during the installation process.
#   This function will also enable and start services that were installed.
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::clean::complete() {
	vstacklet::shell::text::white "cleaning up setup files..."
	declare service
	declare -a services=()
	[[ -n ${nginx} ]] && services+=("nginx")
	[[ -n ${varnish} ]] && services+=("varnish")
	[[ -n ${php} ]] && services+=("php${php}-fpm")
	[[ -n ${php} ]] && services+=("memcached")
	[[ -n ${hhvm} ]] && services+=("hhvm")
	[[ -n ${mysql} ]] && services+=("mysql")
	[[ -n ${mariadb} ]] && services+=("mariadb")
	[[ -n ${sendmail} ]] && services+=("sendmail")
	services+=("sshd")
	rm -rf "${vstacklet_base_path}/setup_temp"
	for service in "${services[@]}"; do
		vstacklet::log "systemctl restart ${service}.service"
		vstacklet::log "systemctl enable ${service}.service"
	done
	# csf requires a restart with its own command
	# this will effectively stop/start csf and lfd
	# and reload the firewall and rules
	[[ -n ${csf} ]] && vstacklet::log "csf -x"
	[[ -n ${csf} ]] && vstacklet::log "csf -e"
	[[ -n ${csf} ]] && vstacklet::log "csf -r"
	[[ -n ${nginx} ]] && rm -rf /etc/apache2 && rm -rf /usr/sbin/apache2
	vstacklet::log "iptables-save > /etc/iptables/rules.v4"
	unset service services
}

################################################################################
# @name: vstacklet::message::complete - vStacklet installation complete message (40)
# @description: Outputs success message on completion of setup. This function
#   is called after the installation is complete. It outputs a success message
#   to the user and provides them with the necessary information to access their
#   new server.
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::message::complete() {
	vstacklet::shell::misc::nl
	vstacklet::shell::text::green "vStacklet Installation Complete! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
	vstacklet::shell::text::green " - Installation Completed in: ${FIN}/min"
	vstacklet::shell::text::white " - SSH port: ${ssh_port:-22}"
	vstacklet::shell::text::white " - FTP port: ${ftp_port:-21}"
	[[ (-n ${domain}) && (-n ${nginx} || -n ${varnish}) && (-n ${php} || -n ${hhvm}) ]] && vstacklet::shell::text::white " - Visit: https://${domain}/checkinfo.php to verify your installation"
	[[ (-n ${domain}) && (-n ${nginx} || -n ${varnish}) && (-n ${php} || -n ${hhvm}) ]] && vstacklet::shell::text::white " - Remember to remove or rename the checkinfo.php file after verification."
	[[ ${setup_reboot} -eq "1" ]] && vstacklet::shell::text::white "rebooting..." && reboot
	if [[ -z ${setup_reboot} ]]; then
		declare input
		vstacklet::shell::text::white::sl "do you want to reboot (recommended)? "
		vstacklet::shell::text::green::sl "[y]"
		vstacklet::shell::text::white::sl "es "
		vstacklet::shell::text::white "or [n]o:"
		vstacklet::shell::icon::arrow::white
		read -r input
		case "${input,,}" in
		[y] | [y][e][s] | "") reboot ;;
		*) ;;
		esac
	fi
	unset vstacklet_log_location
}

spinner() {
	local pid=$1
	local delay=0.25
	# shellcheck disable=SC2034,SC1003,SC2086,SC2312
	local spinstr='|/-\' # / = forward slash, \ = backslash
	while "$(ps a -o pid | awk '{ print $1 }' | grep "${pid}")"; do
		local temp=${spinstr#?}
		printf " [%c]  " "${spinstr}"
		local spinstr=${temp}${spinstr%"${temp}"}
		sleep "${delay}"
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
	echo -ne "${OK}"
}

################################################################################
# @name: vstacklet::clean::rollback - vStacklet Rollback (41)
# @description: This function is called when a rollback is required. It will
#   remove the temporary files and directories created during the installation
#   process. It will also remove the log file created during the installation
#   process.
#
# notes:
#   - this function is currently a work in progress
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::clean::rollback() {
	declare error
	if [[ -n $1 ]]; then
		case $1 in
		1) error="Error: Please provide a valid email address to use for the sendmail alias required by CSF." ;;
		2) error="Error: Please provide a valid domain name." ;;
		3) error="Error: Please provide a valid port number for the FTP server." ;;
		4) error="Error: Invalid FTP port number. Please enter a number between 1 and 65535." ;;
		5) error="Error: The MariaDB password must be at least 8 characters long." ;;
		6) error="Error: Please provide a valid port number for the MariaDB server." ;;
		7) error="Error: Invalid MariaDB port number. Please enter a number between 1 and 65535." ;;
		8) error="Error: The MySQL password must be at least 8 characters long." ;;
		9) error="Error: Please provide a valid port number for the MySQL server." ;;
		10) error="Error: Invalid MySQL port number. Please enter a number between 1 and 65535." ;;
		11) error="Error: Invalid PHP version. Please enter either 7 (7.4) or 8 (8.1)." ;;
		13) error="Error: The HTTPS port must be a number." ;;
		14) error="Error: Invalid HTTPS port number. Please enter a number between 1 and 65535." ;;
		15) error="Error: The HTTP port must be a number." ;;
		16) error="Error: Invalid HTTP port number. Please enter a number between 1 and 65535." ;;
		17) error="Error: Invalid hostname. Please enter a valid hostname." ;;
		18) error="Error: An email is needed to register the server aliases. Please set an email with the -e option." ;;
		19) error="Error: The Sendmail port must be a number." ;;
		20) error="Error: Invalid Sendmail port number. Please enter a number between 1 and 65535." ;;
		21) error="Error: The SSH port must be a number." ;;
		22) error="Error: Invalid SSH port number. Please enter a number between 1 and 65535." ;;
		23) error="Error: The Varnish port must be a number." ;;
		24) error="Error: Invalid Varnish port number. Please enter a number between 1 and 65535." ;;
		25) error="Error: Invalid web root. Please enter a valid path (e.g. /var/www/html)." ;;
		26) error="Error: Invalid option(s). ${invalid_option[*]}" ;;

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
	#[[ -f ${vstacklet_base_path}/config/system/encryption_file ]] && chattr -i "${vstacklet_base_path}/config/system/encryption_file"
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
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::init
vstacklet::environment::checkdistro
vstacklet::environment::checkroot
vstacklet::args::process "$@"
