#!/bin/bash
##################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 3.1.1819
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
#   - [return codes](#return-codes)
#   - [examples](#examples)
# - [vstacklet::environment::functions()](#vstackletenvironmentfunctions)
# - [vstacklet::log::check()](#vstackletlogcheck)
# - [vstacklet::apt::update()](#vstackletaptupdate)
# - [vstacklet::dependencies::install()](#vstackletdependenciesinstall)
#    - [return codes](#return-codes-1)
# - [vstacklet::environment::checkroot()](#vstackletenvironmentcheckroot)
#    - [return codes](#return-codes-2)
# - [vstacklet::environment::checkdistro()](#vstackletenvironmentcheckdistro)
#    - [return codes](#return-codes-3)
# - [vstacklet::intro()](#vstackletintro)
# - [vstacklet::dependencies::array()](#vstackletdependenciesarray)
# - [vstacklet::base::dependencies()](#vstackletbasedependencies)
#    - [return codes](#return-codes-4)
# - [vstacklet::source::dependencies()](#vstackletsourcedependencies)
#    - [return codes](#return-codes-5)
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
#   - [return codes](#return-codes-6)
#   - [examples](#examples-3)
# - [vstacklet::ftp::set()](#vstackletftpset)
#   - [options](#options-4)
#   - [arguments](#arguments-4)
#   - [return codes](#return-codes-7)
#   - [examples](#examples-4)
# - [vstacklet::block::ssdp()](#vstackletblockssdp)
#   - [return codes](#return-codes-8)
# - [vstacklet::sources::update()](#vstackletsourcesupdate)
# - [vstacklet::gpg::keys()](#vstackletgpgkeys)
# - [vstacklet::locale::set()](#vstackletlocaleset)
#   - [return codes](#return-codes-9)
# - [vstacklet::php::install()](#vstackletphpinstall)
#   - [options](#options-5)
#   - [arguments](#arguments-5)
#   - [return codes](#return-codes-10)
#   - [examples](#examples-5)
# - [vstacklet::hhvm::install()](#vstacklethhvminstall)
#   - [options](#options-6)
#   - [return codes](#return-codes-11)
#   - [examples](#examples-6)
# - [vstacklet::nginx::install()](#vstackletnginxinstall)
#   - [options](#options-7)
#   - [return codes](#return-codes-12)
#   - [examples](#examples-7)
# - [vstacklet::varnish::install()](#vstackletvarnishinstall)
#   - [options](#options-8)
#   - [arguments](#arguments-6)
#   - [return codes](#return-codes-13)
#   - [examples](#examples-8)
# - [vstacklet::permissions::adjust()](#vstackletpermissionsadjust)
# - [vstacklet::ioncube::install()](#vstackletioncubeinstall)
#   - [options](#options-9)
#   - [return codes](#return-codes-14)
#   - [examples](#examples-9)
# - [vstacklet::mariadb::install()](#vstackletmariadbinstall)
#   - [options](#options-10)
#   - [arguments](#arguments-7)
#   - [return codes](#return-codes-15)
#   - [examples](#examples-10)
# - [vstacklet::mysql::install()](#vstackletmysqlinstall)
#   - [options](#options-11)
#   - [arguments](#arguments-8)
#   - [return codes](#return-codes-16)
#   - [examples](#examples-11)
# - [vstacklet::postgre::install()](#vstackletpostgreinstall)
#   - [options](#options-12)
#   - [arguments](#arguments-9)
#   - [return codes](#return-codes-17)
#   - [examples](#examples-12)
# - [vstacklet::redis::install()](vstackletredisinstall)
#   - [options](#options-13)
#   - [arguments](#arguments-10)
#   - [return codes](#return-codes-18)
#   - [examples](#examples-13)
# - [vstacklet::phpmyadmin::install()](#vstackletphpmyadmininstall)
#   - [options](#options-14)
#   - [arguments](#arguments-11)
#   - [return codes](#return-codes-19)
#   - [examples](#examples-14)
# - [vstacklet::csf::install()](#vstackletcsfinstall)
#   - [options](#options-15)
#   - [arguments](#arguments-12)
#   - [return codes](#return-codes-20)
#   - [examples](#examples-15)
# - [vstacklet::cloudflare::csf()](#vstackletcloudflarecsf)
#   - [options](#options-16)
#   - [return codes](#return-codes-21)
#   - [examples](#examples-16)
# - [vstacklet::sendmail::install()](#vstackletsendmailinstall)
#   - [options](#options-17)
#   - [parameters](#parameters)
#   - [return codes](#return-codes-22)
#   - [examples](#examples-17)
# - [vstacklet::wordpress::install()](#vstackletwordpressinstall)
#   - [options](#options-18)
#   - [return codes](#return-codes-23)
#   - [examples](#examples-18)
# - [vstacklet::domain::ssl()](#vstackletdomainssl)
#   - [options](#options-19)
#   - [arguments](#arguments-13)
#   - [return codes](#return-codes-24)
#   - [examples](#examples-19)
# - [vstacklet::clean::complete()](#vstackletcleancomplete)
# - [vstacklet::message::complete()](#vstackletmessagecomplete)
# - [vstacklet::clean::rollback()](#vstackletcleanrollback)
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
# shellcheck disable=1091,2068,2119,2312
##################################################################################
# @name: vstacklet::environment::init (1)
# @description: Setup the environment and set variables. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L178-L198)
# @note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::init() {
	shopt -s extglob
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
	# script start time
	vstacklet_start_time=$(date +%s)
}

##################################################################################
# @name: vstacklet::args::process (3)
# @description: Process the options and values passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L287-L529)
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
# @option: `-mariadbPw | --mariadb-password` - password to use for the MariaDB user
#
# @option: `-redis | --redis` - install Redis
# @option: `-postgre | --postgre` - install PostgreSQL
#
# @option: `-pma | --phpmyadmin` - install phpMyAdmin
# @option: `-csf | --csf` - install CSF firewall
# @option: `-csfCf | --csf_cloudflare` - enable Cloudflare support in CSF
# @option: `-sendmail | --sendmail` - install Sendmail
# @option: `-sendmailP | --sendmail_port` - port to use for the Sendmail server
#
# @option: `-wr | --web_root` - the web root directory to use for the server
# @option: `-wp | --wordpress` - install WordPress
#
# @option: `--reboot` - reboot the server after the installation
##################################################################################
# @example: vstacklet --help
# @example: vstacklet -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -hn "yourhostname" -php 8.1 -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -csf -sendmail -wr "/var/www/html" -wp
# @example: vstacklet -e "youremail.com" -ftp 2133 -ssh 2244 -http 8080 -https 443 -d "yourdomain.com" -hhvm -nginx -varnish -varnishP 80 -mariadb -mariadbU "user" -mariadbPw "mariadbpasswd" -sendmail -wr "/var/www/html" -wp --reboot
# @null
# @return_code: 3 - please provide a valid email address. (required for -csf, -sendmail, and -csfCf)
# @return_code: 4 - `-csfCf` requires `-csf`.
# @return_code: 5 - please provide a valid domain name.
# @return_code: 6 - please provide a valid port number for the FTP server.
# @return_code: 7 - invalid FTP port number. please enter a number between 1 and 65535.
# @return_code: 8 - the MariaDB password must be at least 8 characters long.
# @return_code: 9 - please provide a valid port number for the MariaDB server.
# @return_code: 10 - invalid MariaDB port number. please enter a number between 1 and 65535.
# @return_code: 11 - the MySQL password must be at least 8 characters long.
# @return_code: 12 - the MySQL port must be a number.
# @return_code: 13 - invalid MySQL port number. please enter a number between 1 and 65535.
# @return_code: 14 - the postgreSQL password must be at least 8 characters long.
# @return_code: 15 - please provide a valid port number for the postgreSQL server.
# @return_code: 16 - invalid postgreSQL port number. please enter a number between 1 and 65535.
# @return_code: 17 - invalid PHP version. please enter either 7 (7.4), or 8 (8.1).
# @return_code: 18 - the HTTPS port must be a number.
# @return_code: 19 - invalid HTTPS port number. please enter a number between 1 and 65535.
# @return_code: 20 - the HTTP port must be a number.
# @return_code: 21 - invalid HTTP port number. please enter a number between 1 and 65535.
# @return_code: 22 - invalid hostname. please enter a valid hostname.
# @return_code: 23 - the Redis password must be at least 8 characters long.
# @return_code: 24 - please provide a valid port number for the Redis server.
# @return_code: 25 - invalid Redis port number. please enter a number between 1 and 65535.
# @return_code: 26 - an email is needed to register the server aliases. please set an email with `-e your@email.com`.
# @return_code: 27 - the Sendmail port must be a number.
# @return_code: 28 - invalid Sendmail port number. please enter a number between 1 and 65535.
# @return_code: 29 - the SSH port must be a number.
# @return_code: 30 - invalid SSH port number. please enter a number between 1 and 65535.
# @return_code: 31 - the Varnish port must be a number.
# @return_code: 32 - invalid Varnish port number. please enter a number between 1 and 65535.
# @return_code: 33 - invalid web root. please enter a valid path. (e.g. /var/www/html)
# @return_code: 34 - invalid option(s): ${invalid_option[*]}
# @break
##################################################################################
vstacklet::args::process() {
	while [[ $# -gt 0 ]]; do
		case "${1}" in
		# there may be options that can utilize active builds, but for now, we'll just
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
			;;
		-csfCf | --csf_cloudflare)
			declare -gi csf_cloudflare="1"
			shift
			;;
		-d* | --domain*)
			declare -gi domain_ssl=1
			declare -g domain="${2}"
			shift
			shift
			[[ -n ${domain} && $(echo "${domain}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && vstacklet::clean::rollback 5
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
			[[ -n ${ftp_port} && ${ftp_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 6
			[[ -n ${ftp_port} && ${ftp_port} -lt 1 || ${ftp_port} -gt 65535 ]] && vstacklet::clean::rollback 7
			;;
		-hhvm | --hhvm)
			declare -gi hhvm="1"
			shift
			;;
		-hn* | --hostname*)
			declare -g hostname="${2}"
			shift
			shift
			[[ -n ${hostname} && $(echo "${hostname}" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)') == "" ]] && vstacklet::clean::rollback 22
			[[ -z ${hostname} ]] && declare -g hostname="localhost"
			;;
		-https* | --https_port*)
			declare -gi https_port="${2}"
			shift
			shift
			[[ -n ${https_port} && ${https_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 18
			[[ -n ${https_port} && ${https_port} -lt 1 || ${https_port} -gt 65535 ]] && vstacklet::clean::rollback 19
			;;
		-http* | --http_port*)
			declare -gi http_port="${2}"
			shift
			shift
			[[ -n ${http_port} && ${http_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 20
			[[ -n ${http_port} && ${http_port} -lt 1 || ${http_port} -gt 65535 ]] && vstacklet::clean::rollback 21
			;;
		-ioncube | --ioncube)
			declare -gi ioncube="1"
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
			[[ -n ${mariadb_password} && ${#mariadb_password} -lt 8 ]] && vstacklet::clean::rollback 8
			;;
		-mariadbP* | --mariadb_port*)
			declare -gi mariadb_port="${2}"
			shift
			shift
			[[ -n ${mariadb_port} && ${mariadb_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 9
			[[ -n ${mariadb_port} && ${mariadb_port} -lt 1 || ${mariadb_port} -gt 65535 ]] && vstacklet::clean::rollback 10
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
			[[ -n ${mysql_password} && ${#mysql_password} -lt 8 ]] && vstacklet::clean::rollback 11
			;;
		-mysqlP* | --mysql_port*)
			declare -gi mysql_port="${2}"
			shift
			shift
			[[ -n ${mysql_port} && ${mysql_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 12
			[[ -n ${mysql_port} && ${mysql_port} -lt 1 || ${mysql_port} -gt 65535 ]] && vstacklet::clean::rollback 13
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
			;;
		-pma | --phpmyadmin)
			declare -gi phpmyadmin="1"
			shift
			;;
		-php* | --php*)
			#declare -gi php_set="1"
			declare -g php="${2}"
			shift
			shift
			[[ ${php} == *"7"* ]] && declare -g php="7.4"
			[[ ${php} == *"8"* ]] && declare -g php="8.1"
			declare -a allowed_php=("7.4" "8.1")
			if ! vstacklet::array::contains "${php}" "supported php versions" ${allowed_php[@]}; then
				vstacklet::clean::rollback 17
			fi
			;;
		-redis | --redis)
			declare -gi redis="1"
			shift
			;;
		-redisPw* | --redis_password*)
			declare -g redis_password="${2}"
			shift
			shift
			[[ -n ${redis_password} && ${#redis_password} -lt 8 ]] && vstacklet::clean::rollback 23
			;;
		-redisP* | --redis_port*)
			declare -gi redis_port="${2}"
			shift
			shift
			[[ -n ${redis_port} && ${redis_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 24
			[[ -n ${redis_port} && ${redis_port} -lt 1 || ${redis_port} -gt 65535 ]] && vstacklet::clean::rollback 25
			;;
		-sendmail | --sendmail)
			declare -gi sendmail="1"
			shift
			;;
		-sendmailP* | --sendmail_port*)
			declare -gi sendmail_port="${2}"
			shift
			shift
			[[ -n ${sendmail_port} && ${sendmail_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 27
			[[ -n ${sendmail_port} && ${sendmail_port} -lt 1 || ${sendmail_port} -gt 65535 ]] && vstacklet::clean::rollback 28
			;;
		-ssh* | --ssh_port*)
			declare -gi ssh_port="${2}"
			shift
			shift
			[[ -n ${ssh_port} && ${ssh_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 29
			[[ -n ${ssh_port} && ${ssh_port} -lt 1 || ${ssh_port} -gt 65535 ]] && vstacklet::clean::rollback 30
			;;
		-varnish | --varnish)
			declare -gi varnish="1"
			shift
			;;
		-varnishP* | --varnish_port*)
			declare -gi varnish_port="${2}"
			shift
			shift
			[[ -n ${varnish_port} && ${varnish_port} != ?(-)+([0-9]) ]] && vstacklet::clean::rollback 31
			[[ -n ${varnish_port} && ${varnish_port} -lt 1 || ${varnish_port} -gt 65535 ]] && vstacklet::clean::rollback 32
			;;
		-wp | --wordpress)
			declare -gi wordpress="1"
			shift
			;;
		-wr* | --web_root*)
			declare -g web_root="${2}"
			shift
			shift
			[[ -n ${web_root} && $(sed -e 's/[\\/]/\\/g;s/[\/\/]/\\\//g;' <<<"${web_root}") == "" ]] && vstacklet::clean::rollback 33
			;;
		-www-perms* | --www_permissions*)
			declare -g www_permissions="1"
			shift
			#"${local_setup_dir}/www-permissions.sh" "$@"
			#exit $?
			;;
		*)
			invalid_option+=("$1")
			shift
			;;
		esac
	done
	# sanity checks
	[[ -n ${csfCf} && -z ${csf} ]] && vstacklet::clean::rollback 4
	[[ -n ${csf} && -z ${email} ]] && vstacklet::clean::rollback 3
	[[ -n ${domain} && -z ${email} ]] && vstacklet::shell::text::error "an email is needed to register with Let's Encrypt. please set an email with \`-e\`." && exit 1
	[[ -z ${ftp_port} ]] && declare -gi ftp_port="21"
	[[ -z ${https_port} ]] && declare -gi https_port="443"
	[[ -z ${http_port} ]] && declare -gi http_port="80"
	[[ -z ${mariadb_port} ]] && declare -gi mariadb_port="3306"
	[[ -z ${mysql_port} ]] && declare -gi mysql_port="3306"
	[[ -z ${postgresql_port} ]] && declare -gi postgresql_port="5432"
	[[ -z ${php} ]] && declare -g php="8.1"
	[[ -z ${redis_port} ]] && declare -gi redis_port="6379"
	[[ -n ${sendmail} && -z ${email} ]] && vstacklet::clean::rollback 26
	[[ -z ${sendmail_port} ]] && declare -gi sendmail_port="587"
	[[ -z ${ssh_port} ]] && declare -gi ssh_port="22"
	[[ -z ${varnish_port} ]] && declare -gi varnish_port="6081"
	[[ -z ${web_root} ]] && declare -g web_root="/var/www/html"
	[[ ${#invalid_option[@]} -gt 0 ]] && exit #vstacklet::clean::rollback 34
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L538-L671)
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
				#vstacklet::shell::text::success "[${_result}]: ${_named_array} array contains ${_value}"
				break
			fi
		done
		[[ ${_result} == "1" ]] && vstacklet::shell::text::error "[${_result}]: ${_named_array} array does not contain ${_value}" # && exit 1
		return "${_result}"                                                                                                       # 0 if found, 1 if not found, 2 if missing arguments
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
		warning) shell_icon="⚠ warning: ${shell_reset}" && shell_warning="1" ;;
		check) shell_icon="✓ ${shell_reset}" ;;
		cross) shell_icon="✗ ${shell_reset}" ;;
		success) shell_icon="✓ success: ${shell_reset}" && shell_success="1" ;;
		error) shell_icon="✗ error: ${shell_reset}" && shell_error="1" ;;
		rollback) shell_icon="⎌ rollback: ${shell_reset}" && shell_rollback="1" ;;
		esac
		if [[ ${shell_success} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		elif [[ ${shell_warning} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		elif [[ ${shell_error} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		elif [[ ${shell_rollback} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		else
			printf -- "${shell_reset}${shell_color}${shell_icon}${shell_option}%s${shell_newline}${shell_reset}" "$@"
		fi
		unset shell_color shell_newline shell_option shell_icon
	}
	vstacklet::shell::misc::nl() {
		printf "\n"
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
	vstacklet::shell::text::error() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 1)
		shell_icon="error"
		output_color=$(tput setaf 7)
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
	vstacklet::shell::text::success() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 2)
		shell_icon="success"
		output_color=$(tput setaf 7)
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
	vstacklet::shell::text::warning() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 3)
		shell_icon="warning"
		output_color=$(tput setaf 7)
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
	vstacklet::shell::text::magenta() {
		declare -g shell_color
		shell_color=$(tput setaf 5)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::magenta::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 5)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::rollback() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 5)
		shell_icon="rollback"
		output_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	# trunk-ignore(shellcheck/SC2120)
	vstacklet::shell::icon::arrow::white() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 7)
		shell_icon="arrow"
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::icon::check::green() {
		declare -g shell_color shell_icon shell_newline=0
		shell_color=$(tput setaf 2)
		shell_icon="check"
		vstacklet::shell::output "$@"
	}
}

vs::stat::progress() {
	spinner="/|\\-/|\\-"
	while :; do
		for i in $(seq 0 7); do
			echo -n "${spinner:$i:1}"
			echo -en "\010"
			sleep 1
		done
	done
}
vs::stat::progress::start() {
	declare -g pg_pid
	vs::stat::progress &
	pg_pid=$!
	trap 'kill -9 ${pg_pid} 2>/dev/null' $(seq 0 15) >/dev/null 2>&1

}
#trap 'vs::stat::progress::start' SIGINT
vs::stat::progress::stop() {
	vstacklet::shell::icon::check::green "done"
	kill -9 ${pg_pid} >/dev/null 2>&1
	unset pg_pid
}

##################################################################################
# @name: vstacklet::log::check (4)
# @description: Check if the log file exists and create it if it doesn't. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L685-L705)
#
# notes:
# - the log file is located at /var/log/vstacklet/vstacklet.${PPID}.log
# @noargs
# @nooptions
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
# @name: vstacklet::apt::update (5)
# @description: Updates server via apt-get. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L714-L723)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::apt::update() {
	vstacklet::shell::text::white "running apt update ... "
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >/dev/null 2>&1
	if [[ -n ${apt_upgrade} ]]; then
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" autoremove >/dev/null 2>&1
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" autoclean >/dev/null 2>&1
	fi
	unset apt_upgrade
}

##################################################################################
# @name: vstacklet::dependencies::install (6)
# @description: Installs dependencies for vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L733-L754)
# @nooptions
# @noargs
# @return_code: 35 - failed to install script dependencies.
# @break
##################################################################################
vstacklet::dependencies::install() {
	vstacklet::shell::text::white "checking for initial script dependencies ... "
	declare -ga script_dependencies
	declare -a depend_list
	declare -ga install_list
	script_dependencies=("apt-transport-https" "lsb-release" "curl" "wget" "git" "dnsutils" "dialog" "ssl-cert" "openssl" "expect" "apache2-utils")
	for depend in "${script_dependencies[@]}"; do
		if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
			depend_list+=("${depend}")
		fi
	done
	[[ -n ${depend_list[*]} ]] && printf -- "%s" "installing: "
	for install in "${depend_list[@]}"; do
		if [[ ${install} == "${depend_list[0]}" ]]; then
			vstacklet::shell::text::white::sl "${install} "
		else
			vstacklet::shell::text::white::sl "| ${install} "
		fi
		vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 35
		install_list+=("${install}")
	done
	clear
}

##################################################################################
# @name: vstacklet::environment::checkroot (7)
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L764-L766)
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 1 = you must be root to run this script.
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && vstacklet::clean::rollback 1
}

##################################################################################
# @name: vstacklet::environment::checkdistro (8)
# @description: Check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11 [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L776-L787)
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 2 = this script only supports Ubuntu 18.04/20.04 | Debian 9/10/11
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
# @name: vstacklet::intro (9)
# @description: Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L796-L820)
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::intro() {
	vstacklet::shell::misc::nl
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Welcome to the vStacklet Server Stack Installation Utility."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "This script will install the vStacklet Server Stack on your server."
	vstacklet::shell::text::white "The vStacklet Server Stack is a collection of software that will"
	vstacklet::shell::text::white "allow you to run a LEMP stack server."
	vstacklet::shell::text::white "Please ensure you have read the documentation before continuing."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Documentation can be found at:"
	vstacklet::shell::text::white "https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet installation log can be found at:"
	vstacklet::shell::text::yellow "${vslog}"
	vstacklet::shell::misc::nl
}

# shall we continue? function (10)
vstacklet::ask::continue() {
	vstacklet::shell::text::green "Press any key to continue $(tput setaf 7)(${shell_reset}$(tput setaf 3)ctrl+C${shell_reset} $(tput setaf 7)to ${shell_reset}$(tput setaf 1)exit${shell_reset}$(tput setaf 7)) ..."
	read -r -n 1
	vstacklet::shell::misc::nl
}

################################################################################
# @name: vstacklet::dependencies::array (11)
# @description: Handles various dependencies for the vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L847-L878)
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
	# @script-note: install source dependencies
	declare -ga source_dependencies=("dirmngr" "software-properties-common" "gnupg2" "ca-certificates" "gpg-agent" "apt-transport-https" "lsb-release" "curl" "wget" "git" "dnsutils" "dialog" "ssl-cert" "openssl" "sudo" "build-essential" "debconf-utils" "locales" "net-tools" "nfs-common" "iproute2")
	# @script-note: install base dependencies
	declare -ga base_dependencies=("rsync" "dos2unix" "jq" "bc" "automake" "make" "cmake" "checkinstall" "nano" "zip" "unzip" "htop" "vnstat" "vnstati" "vsftpd" "subversion" "iptables" "iptables-persistent" "ssh")
	# @script-note: install php dependencies
	declare -ga php_dependencies=("php${php}-fpm" "php${php}-zip" "php${php}-cgi" "php${php}-cli" "php${php}-common" "php${php}-curl" "php${php}-dev" "php${php}-gd" "php${php}-bcmath" "php${php}-gmp" "php${php}-imap" "php${php}-intl" "php${php}-ldap" "php${php}-mbstring" "php${php}-opcache" "php${php}-pspell" "php${php}-readline" "php${php}-soap" "php${php}-xml" "php${php}-imagick" "php${php}-msgpack" "php${php}-igbinary" "libmcrypt-dev" "mcrypt" "libmemcached-dev" "php-memcached")
	[[ -n ${redis} ]] && php_dependencies+=("php${php}-redis")
	[[ -n ${mariadb} || -n ${mysql} ]] && php_dependencies+=("php${php}-mysql")
	# @script-note: install hhvm dependencies
	declare -ga hhvm_dependencies=("hhvm")
	# @script-note: install nginx dependencies
	declare -ga nginx_dependencies=("nginx-extras")
	# @script-note: install varnish dependencies
	declare -ga varnish_dependencies=("varnish")
	# @script-note: install mariadb dependencies
	declare -ga mariadb_dependencies=("mariadb-server" "mariadb-client")
	# @script-note: install mysql dependencies
	declare -ga mysql_dependencies=("mysql-server" "mysql-client")
	# @script-note: install postgresql dependencies
	declare -ga postgresql_dependencies=("postgresql" "postgresql-contrib")
	# @script-note: install redis dependencies
	declare -ga redis_dependencies=("redis")
	# @script-note: install phpmyadmin dependencies
	declare -ga phpmyadmin_dependencies=("phpmyadmin")
	# @script-note: install csf dependencies
	declare -ga csf_dependencies=("e2fsprogs" "libwww-perl" "liblwp-protocol-https-perl" "libgd-graph-perl")
	# @script-note: install sendmail dependencies
	declare -ga sendmail_dependencies=("sendmail" "sendmail-bin" "sendmail-cf" "mailutils" "libsasl2-modules")
}

################################################################################
# @name: vstacklet::base::dependencies (12)
# @description: Handles base dependencies for the vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L886-L910)
# @return_code: 36 - failed to install base dependencies.
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
		# shellcheck disable=SC2015
		DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 36
		install_list+=("${install}")
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
	for depend in "${base_dependencies[@]}"; do
		echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
	done
	unset depend depend_list install
}

##################################################################################
# @name: vstacklet::source::dependencies (13)
# @description: Installs required sources for vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L920-L947)
# @nooptions
# @noargs
# @return_code: 37 - failed to install source dependencies.
# @break
##################################################################################
vstacklet::source::dependencies() {
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
		vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 37
		install_list+=("${install}")
	done
	[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
	for depend in "${source_dependencies[@]}"; do
		echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
	done
	unset depend depend_list install
}

##################################################################################
# @name: vstacklet::bashrc::set (14)
# @description: Set ~/.bashrc and ~/.profile for vstacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L959-L967)
# @nooptions:
# @noargs:
# @return: none
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::bashrc::set() {
	vstacklet::shell::text::white "setting ~/.bashrc and ~/.profile for vstacklet ... "
	bashrc_path="${HOME}/.bashrc"
	profile_path="${HOME}/.profile"
	[[ -f "${bashrc_path}" ]] && mv "${bashrc_path}" "${vstacklet_base_path}/config/system/bashrc"
	[[ -f "${profile_path}" ]] && mv "${profile_path}" "${vstacklet_base_path}/config/system/profile"
	\cp -f "${local_setup_dir}/templates/bashrc" "${bashrc_path}"
	\cp -f "${local_setup_dir}/templates/profile" "${profile_path}"
}

##################################################################################
# @name: vstacklet::hostname::set (15)
# @description: Set system hostname. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L988-L992)
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
# @example: vstacklet -hn myhostname
# @example: vstacklet --hostname myhostname
# @null
# @return: 38 - failed to set hostname
# @break
##################################################################################
vstacklet::hostname::set() {
	vstacklet::shell::text::white "setting hostname to ${domain:-${hostname:-${server_hostname}}}"
	vstacklet::log "hostnamectl set-hostname ${domain:-${hostname:-${server_hostname}}}" || vstacklet::clean::rollback 38
	hostnamectl set-hostname "${domain:-${hostname:-${server_hostname}}}" || vstacklet::clean::rollback 38
}

##################################################################################
# @name: vstacklet::webroot::set (16)
# @description: Set main web root directory. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1014-L1021)
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
# @example: vstacklet -wr /var/www/mydirectory
# @example: vstacklet --web_root /srv/www/mydirectory
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
# @description: Set ssh port to custom port (if nothing is set, default port is 22) [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1035-L1042)
# @option: $1 - `-ssh | --ssh_port` (optional) (takes one argument)
# @arg: $2 - `[port]` (default: 22) - the port to set for ssh
# @example: vstacklet -ssh 2222
# @example: vstacklet --ssh_port 2222
# @null
# @return_code: 39 - failed to set SSH port.
# @return_code: 40 - failed to restart SSH daemon service.
# @break
##################################################################################
vstacklet::ssh::set() {
	if [[ -n ${ssh_port} ]]; then
		vstacklet::shell::text::white "setting ssh port to ${ssh_port:-22} ... "
		cp -f /etc/ssh/sshd_config "${vstacklet_base_path}/setup_temp/sshd_config"
		sed -i "s/^.*Port .*/Port ${ssh_port:-22}/g" /etc/ssh/sshd_config || vstacklet::clean::rollback 39
		vstacklet::log "systemctl restart sshd" || vstacklet::clean::rollback 40
	fi
}

##################################################################################
# @name: vstacklet::ftp::set (18)
# @description: Set ftp port to custom port (if nothing is set, default port is 21) [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1056-L1067)
# @option: $1 - `-ftp | --ftp_port` (optional) (takes one argument)
# @arg: $2 - `[port]` (default: 21) - the port to set for ftp
# @example: vstacklet -ftp 2121
# @example: vstacklet --ftp_port 2121
# @null
# @return_code: 41 - failed to set FTP port.
# @return_code: 42 - failed to restart FTP service.
# @break
##################################################################################
vstacklet::ftp::set() {
	if [[ -n ${ftp_port} ]]; then
		vstacklet::shell::text::white "setting ftp port to ${ftp_port:-21} ... "
		cp -f /etc/vsftpd.conf "${vstacklet_base_path}/setup_temp/vsftpd.conf"
		openssl req -config "${local_setup_dir}/templates/ssl/openssl.conf" -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem >/dev/null 2>&1
		cp -f "${local_setup_dir}/templates/vsftpd/vsftpd.conf" /etc/vsftpd.conf
		sed -i.bak -e "s|{{ftp_port}}|${ftp_port:-21}|g" -e "s|{{server_ip}}|${server_ip}|g" /etc/vsftpd.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 41
		vstacklet::log "systemctl restart vsftpd" || vstacklet::clean::rollback 42
		vstacklet::log "iptables -I INPUT -p tcp --destination-port 10090:10100 -j ACCEPT"
		echo "" >/etc/vsftpd.chroot_list
	fi
}

##################################################################################
# @name: vstacklet::block::ssdp (19)
# @description: Blocks an insecure port 1900 that may lead to
# DDoS masked attacks. Only remove this function if you absolutely
# need port 1900. In most cases, this is a junk port. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1082-L1091)
# @noargs
# @nooptions
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 43 - failed to block SSDP port.
# @return_code: 44 - failed to save iptables rules.
# @break
##################################################################################
vstacklet::block::ssdp() {
	vstacklet::shell::text::white "blocking port 1900 ..."
	mkdir -p /etc/iptables/
	vstacklet::log "iptables -I INPUT 1 -p udp -m udp --dport 1900 -j DROP" || vstacklet::clean::rollback 43
	iptables-save >/etc/iptables/rules.v4 || vstacklet::clean::rollback 44
}

##################################################################################
# @name: vstacklet::sources::update (20)
# @description: This function updates the package list and upgrades the system. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1102-L1160)
# @noargs
# @nooptions
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
deb http://ftp.debian.org/debian/ ${codename} main contrib non-free
deb-src http://ftp.debian.org/debian/ ${codename} main contrib non-free

deb http://ftp.debian.org/debian/ ${codename}-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ ${codename}-updates main contrib non-free

deb http://security.debian.org/ ${codename}-security main contrib non-free
deb-src http://security.debian.org/ ${codename}-security main contrib non-free

deb http://ftp.debian.org/debian ${codename}-backports main
deb-src http://ftp.debian.org/debian ${codename}-backports main

#------------------------------------------------------------------------------#
#                      UNOFFICIAL  REPOS
#------------------------------------------------------------------------------#

###### 3rd Party Binary Repos
###Debian Multimedia
#deb [arch=amd64,i386] https://www.deb-multimedia.org ${codename} main non-free

###### nginx
#deb [arch=amd64,i386] http://nginx.org/packages/debian/ ${codename} nginx
#deb-src [arch=amd64,i386] http://nginx.org/packages/debian/ ${codename} nginx

###### Missing Dependencies
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

###### Ubuntu Backports Repos
#deb http://nl.archive.ubuntu.com/ubuntu/ ${codename}-backports main restricted universe multiverse
#deb-src http://nl.archive.ubuntu.com/ubuntu/ ${codename}-backports main restricted universe multiverse

###### Missing Dependencies
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

###### Missing Dependencies
EOF
	fi
}

##################################################################################
# @name: vstacklet::gpg::keys (21)
# @description: This function sets the required software package keys
# required by added sources. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1183-L1232)
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
# @nooptions
# @noargs
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::gpg::keys() {
	# @script-note: package and repo addition (c) _add signed keys_
	vstacklet::shell::text::white "adding signed keys and sources for required software packages ... "
	mkdir -p /etc/apt/sources.list.d /etc/apt/keyrings
	if [[ -n ${hhvm} ]]; then
		# @script-note: hhvm
		curl -fsSL https://dl.hhvm.com/conf/hhvm.gpg.key | gpg --dearmor -o /etc/apt/keyrings/hhvm.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/hhvm.gpg] https://dl.hhvm.com/${distro} ${codename} main" | tee /etc/apt/sources.list.d/hhvm.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${nginx} ]]; then
		# @script-note: nginx
		curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/keyrings/nginx.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/nginx.gpg] https://nginx.org/packages/mainline/${distro}/ ${codename} nginx" | tee /etc/apt/sources.list.d/nginx.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${varnish} ]]; then
		# @script-note: varnish
		curl -fsSL "https://packagecloud.io/varnishcache/varnish72/gpgkey" | gpg --dearmor >"/etc/apt/keyrings/varnishcache_varnish72-archive-keyring.gpg" >>"${vslog}" 2>&1
		curl -sSf "https://packagecloud.io/install/repositories/varnishcache/varnish72/config_file.list?os=${distro,,}&dist=${codename}&source=script" >"/etc/apt/sources.list.d/varnishcache_varnish72.list"
	fi
	if [[ -n ${php} ]]; then
		# @script-note: php
		curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/php.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/php.gpg] https://packages.sury.org/php/ ${codename} main" | tee /etc/apt/sources.list.d/php-sury.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${mariadb} ]]; then
		# @script-note: mariadb
		curl -fsSL https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor -o /etc/apt/keyrings/mariadb.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg] http://mirror.its.dal.ca/mariadb/repo/10.6/${distro,,} ${codename} main" | tee /etc/apt/sources.list.d/mariadb.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${redis} ]]; then
		# @script-note: redis
		curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb ${codename} main" | tee /etc/apt/sources.list.d/redis.list >>"${vslog}" 2>&1
	fi
	if [[ -n ${postgresql} ]]; then
		# @script-note: postgresql
		wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor >/etc/apt/trusted.gpg.d/postgresql.gpg
		cat >/etc/apt/sources.list.d/postgresql.list <<EOF
deb [arch=amd64,arm64,ppc64el] http://apt.postgresql.org/pub/repos/apt ${codename}-pgdg main
deb-src http://apt.postgresql.org/pub/repos/apt ${codename}-pgdg main
EOF
	fi
	# @script-note: Remove excess sources known to
	# cause issues with conflicting package sources
	[[ -f "/etc/apt/sources.list.d/proposed.list" ]] && mv -f /etc/apt/sources.list.d/proposed.list /etc/apt/sources.list.d/proposed.list.BAK
	declare -gi apt_upgrade="1"
}

##################################################################################
# @name: vstacklet::locale::set (22)
# @description: This function sets the locale to en_US.UTF-8
# and sets the timezone to UTC. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1249-L1267)
#
# todo: This function is still a work in progress.
# - [ ] implement arguments to set the locale
# - [ ] implement arguments to set the timezone (or a seperate function)
# @noargs
# @nooptions
# @script-note: This function is required for the installation of
# the vStacklet software.
# @return_code: 45 - failed to set locale.
# @break
##################################################################################
vstacklet::locale::set() {
	vstacklet::shell::text::white "setting locale to en_US.UTF-8 ..."
	apt-get -y install language-pack-en-base >>"${vslog}" 2>&1
	if [[ -e /usr/sbin/locale-gen ]]; then
		(
			update-locale "LANGUAGE=en_US.UTF-8" >/dev/null 2>&1
			dpkg-reconfigure --frontend noninteractive locales
			vstacklet::log "locale-gen locales"
		) >>"${vslog}" 2>&1 || vstacklet::clean::rollback 45
	else
		(
			vstacklet::log "apt-get -y update"
			vstacklet::log "apt-get -y install locales locale-gen"
			update-locale "LANGUAGE=en_US.UTF-8" >/dev/null 2>&1
			dpkg-reconfigure --frontend noninteractive locales
			vstacklet::log "locale-gen locales"
		) >>"${vslog}" 2>&1 || vstacklet::clean::rollback 45

	fi
	declare -xg LANGUAGE="en_US.UTF-8"
}

##################################################################################
# @name: vstacklet::php::install (23)
# @description: Install PHP and PHP modules. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1304-L1355)
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
# @example: vstacklet -php 8.1
# @example: vstacklet --php 7.4
# @null
# @return_code: 46 - php and hhvm cannot be installed at the same time, please choose one.
# @return_code: 47 - failed to install php dependencies.
# @return_code: 48 - failed to enable php memcached extension.
# @return_code: 49 - failed to enable php redis extension.
# @break
##################################################################################
vstacklet::php::install() {
	# @script-note: check for hhvm
	[[ -n ${php} && -n ${hhvm} ]] && vstacklet::clean::rollback 46
	if [[ -n ${php} && -z ${hhvm} ]]; then
		# @script-note: check for nginx \\ to maintain modularity, nginx is not required for PHP
		#[[ -z ${nginx} ]] && vstacklet::clean::rollback "PHP requires nginx. please install nginx."
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring PHP ${php} ... "
		# @script-note: install php dependencies and php
		for depend in "${php_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing PHP dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 47
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${php_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		# @script-note: tweak php.ini
		vstacklet::shell::text::yellow::sl "tweaking php.ini ... " &
		vs::stat::progress::start # start progress status
		declare -a php_files=("/etc/php/${php}/fpm/php.ini" "/etc/php/${php}/cli/php.ini")
		# shellcheck disable=SC2215
		for file in "${php_files[@]}"; do
			sed -i.bak -e "s/.*post_max_size =.*/post_max_size = 92M/" -e "s/.*upload_max_filesize =.*/upload_max_filesize = 92M/" -e "s/.*expose_php =.*/expose_php = Off/" -e "s/.*memory_limit =.*/memory_limit = 768M/" -e "s/.*session.cookie_secure =.*/session.cookie_secure = 1/" -e "s/.*session.cookie_httponly =.*/session.cookie_httponly = 1/" -e "s/.*session.cookie_samesite =.*/cookie_samesite.cookie_secure = Lax/" -e "s/.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=1/" -e "s/.*opcache.enable=.*/opcache.enable=1/" -e "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" -e "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" "${file}"
		done
		sleep 3
		vs::stat::progress::stop # stop progress status
		# @script-note: enable modules
		vstacklet::shell::text::yellow::sl "enabling PHP modules ... " &
		vs::stat::progress::start # start progress status
		phpmods=("opcache" "xml" "igbinary" "imagick" "intl" "mbstring" "gmp" "bcmath" "msgpack" "memcached")
		for i in "${phpmods[@]}"; do
			phpenmod -v "${php}" "${i}"
		done
		[[ -n ${redis} ]] && phpmods+=("redis")
		vs::stat::progress::stop # stop progress status
		#phpenmod -v "${php}" memcached >>${vslog} 2>&1 || { vstacklet::clean::rollback 48; } (deprecated)
		#phpenmod -v "${php}" redis >>${vslog} 2>&1 || { vstacklet::clean::rollback 49; } (deprecated)
		# @script-note: php installation complete
	fi
}

##################################################################################
# @name: vstacklet::hhvm::install (24)
# @description: Install HHVM and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1384-L1421)
#
# notes:
# - not familiar with HHMV?
#   - https://docs.hhvm.com/hhvm/FAQ/faq
#   - https://docs.hhvm.com/hhvm/configuration/INI-settings
# - this is a very basic install, it is recommended to use the official HHVM
#   documentation to configure HHVM
# - HHVM is not compatible with PHP, so choose one or the other. HHVM is
#   not a drop-in replacement for PHP, so you will need to rewrite your
#   PHP code to work with HHVM accordingly. HHVM is a dialect of PHP, not PHP itself.
# - unless you are familiar with HHVM, it is recommended to use `-php "8.1"` or `-php "7.4"` instead.
# - there may be numerous issues when using with `--wordpress` (e.g. plugins, themes, etc.)
# - phpMyAdmin is not compatible with HHVM, so if you choose HHVM,
#   you will not be able to install phpMyAdmin.
# @option: $1 - `-hhvm | --hhvm` (optional) (takes no arguments)
# @example: vstacklet -hhvm
# @example: vstacklet --hhvm
# @null
# @return_code: 50 - HHVM and PHP cannot be installed at the same time, please choose one.
# @return_code: 51 - failed to install HHVM dependencies.
# @return_code: 52 - failed to install HHVM.
# @return_code: 53 - failed to update PHP alternatives.
# @break
##################################################################################
vstacklet::hhvm::install() {
	# @script-note: check for php
	[[ -n ${hhvm} && -n ${php} ]] && vstacklet::clean::rollback 50
	if [[ -n ${hhvm} && -z ${php} ]]; then
		# @script-note: check for nginx \\ to maintain modularity, nginx is not required for HHVM
		#[[ -z ${nginx} ]] && vstacklet::clean::rollback "hhvm requires nginx. please install with -nginx."
		# @script-note: install hhvm
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring HHVM ... "
		# @script-note: install php dependencies and php
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
			vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 51
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${hhvm_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		# @script-note: install hhvm
		/usr/share/hhvm/install_fastcgi.sh >>"${vslog}" 2>&1 || vstacklet::clean::rollback 52
		vstacklet::shell::text::yellow::sl "configuring HHVM ... " &
		vs::stat::progress::start # start progress status
		# @script-note: update php alternatives
		/usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60 >>"${vslog}" 2>&1 || vstacklet::clean::rollback 53
		# @script-note: get off the port and use socket - vStacklet nginx configurations already know this
		cp -f "${local_hhvm_dir}server.ini.template" /etc/hhvm/server.ini
		cp -f "${local_hhvm_dir}php.ini.template" /etc/hhvm/php.ini
		vs::stat::progress::stop # stop progress status
		# @script-note: hhvm installation complete
	fi
}

##################################################################################
# @name: vstacklet::nginx::install (25)
# @description: Install NGinx and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1460-L1528)
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
# @example: vstacklet -nginx
# @example: vstacklet --nginx
# @example: vstacklet -nginx -php 8.1 -varnish -varnishP 80 -http 8080 -https 443
# @example:vstacklet --nginx --php 8.1 --varnish --varnishP 80 --http 8080 --https 443
# @null
# @return_code: 54 - failed to install NGINX dependencies.
# @return_code: 55 - failed to edit NGINX configuration file.
# @return_code: 56 - failed to enable NGINX configuration file.
# @return_code: 57 - failed to generate dhparam file.
# @return_code: 58 - failed to stage checkinfo.php verification file.
# @break
##################################################################################
vstacklet::nginx::install() {
	if [[ -n ${nginx} ]]; then
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring NGinx ... "
		# @script-note: install nginx dependencies
		for depend in "${nginx_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing NGinx dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 54
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${nginx_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		vstacklet::log "systemctl stop nginx"
		mkdir -p "${local_setup_dir}/nginx/temp"
		[[ -f /etc/nginx/nginx.conf ]] && mv -f /etc/nginx/nginx.conf "${local_setup_dir}/nginx/temp/nginx.conf"
		[[ -f /etc/nginx/sites-enabled/default ]] && mv -f /etc/nginx/sites-enabled/default "${local_setup_dir}/nginx/temp/default"
		mv /etc/nginx /etc/nginx-pre-vstacklet
		mkdir -p /etc/nginx/{conf.d,cache,ssl,sites-enabled,sites-available}
		sed -i "s|{{server_ip}}|${server_ip}|g" "${local_nginx_dir}/server.configs/directives/cloudflare-real-ip.conf"
		wr_sanitize=$(echo "${web_root:-/var/www/html}" | sed 's/\//\\\//g')
		sed -i "s|{{webroot}}|${wr_sanitize}|g" "${local_nginx_dir}/server.configs/location/letsencrypt.conf"
		sleep 3
		rsync -aP --exclude=/pagespeed --exclude=LICENSE --exclude=README --exclude=.git "${local_nginx_dir}"/* /etc/nginx/ >/dev/null 2>&1
		\cp -rf /etc/nginx-pre-vstacklet/uwsgi_params /etc/nginx-pre-vstacklet/fastcgi_params /etc/nginx/
		chown -R www-data:www-data /etc/nginx/cache
		chmod -R 755 /etc/nginx/cache
		sh -c 'find /etc/nginx -type f -exec chmod 644 {} \;'
		chmod -R g+rw /etc/nginx/cache
		sh -c 'find /etc/nginx/cache -type d -print0 | sudo xargs -0 chmod g+s'
		# @script-note: import nginx reverse config files from vStacklet
		if [[ ${php} == *"8"* ]]; then
			cp -f "${local_php8_dir}/nginx/default.php8.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		fi
		if [[ ${php} == *"7"* ]]; then
			cp -f "${local_php7_dir}/nginx/default.php7.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		fi
		if [[ -n ${hhvm} ]]; then
			cp -f "${local_hhvm_dir}/nginx/default.hhvm.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		fi
		vstacklet::shell::text::yellow::sl "configuring NGinx and generating self-signed certificates ... " &
		vs::stat::progress::start # start progress status
		# @script-note: post necessary edits to nginx config files
		sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{domain}}|${domain:-${hostname:-vs-site1}}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-8.1}|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" || vstacklet::clean::rollback 55
		# @script-note: enable site
		ln -sf "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" "/etc/nginx/sites-enabled/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 56
		# @script-note: generate self-signed ssl cert and Diffie-Hellman parameters file
		[[ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]] && openssl req -config "${vstacklet_base_path}/setup/templates/ssl/openssl.conf" -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem >>"${vslog}" 2>&1
		[[ ! -f /etc/nginx/ssl/dhparam.pem ]] && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 >>"${vslog}" 2>&1
		openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 >>"${vslog}" 2>&1 || vstacklet::clean::rollback 57
		vs::stat::progress::stop # stop progress status
		vstacklet::shell::text::yellow::sl "staging checkinfo.php and adjusting permissions on ${web_root:-/var/www/html} ... " &
		vs::stat::progress::start # start progress status
		echo '<?php phpinfo(); ?>' >"${web_root:-/var/www/html}/public/checkinfo.php" || vstacklet::clean::rollback 58
		chown -R www-data:www-data "${web_root:-/var/www/html}"
		chmod -R 755 "${web_root:-/var/www/html}"
		chmod -R g+rw "${web_root:-/var/www/html}"
		sh -c "find ${web_root:-/var/www/html} -type d -print0 | sudo xargs -0 chmod g+s"
		vs::stat::progress::stop # stop progress status
		# @script-note: nginx installation complete
		vstacklet::shell::text::green "NGinx and self-signed certificates installed and configured. see details below:"
		vstacklet::shell::text::white::sl "NGinx config file: "
		vstacklet::shell::text::green "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		vstacklet::shell::text::white::sl "self-signed ssl cert: "
		vstacklet::shell::text::green "/etc/ssl/certs/ssl-cert-snakeoil.pem"
		vstacklet::shell::text::white::sl "self-signed ssl key: "
		vstacklet::shell::text::green "/etc/ssl/private/ssl-cert-snakeoil.key"
		vstacklet::shell::text::white::sl "Diffie-Hellman parameters file: "
		vstacklet::shell::text::green "/etc/nginx/ssl/dhparam.pem"
		vstacklet::shell::text::white::sl "checkinfo.php: "
		vstacklet::shell::text::green "${web_root:-/var/www/html}/public/checkinfo.php"
	fi
}

##################################################################################
# @name: vstacklet::varnish::install (26)
# @description: Install Varnish and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1559-L1598)
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
# @example: vstacklet -varnish -varnishP 6081 -http 80
# @example: vstacklet --varnish --varnish_port 6081 --http_port 80
# @example: vstacklet -varnish -varnishP 80 -http 8080 -https 443
# @example: vstacklet -varnish -varnishP 80 -nginx -http 8080 --https_port 443
# @null
# @return_code: 59 - failed to install Varnish dependencies.
# @return_code: 60 - could not switch to /etc/varnish directory.
# @return_code: 61 - failed to reload the systemd daemon.
# @return_code: 62 - failed to switch to ~/
# @break
##################################################################################
vstacklet::varnish::install() {
	if [[ -n ${varnish} ]]; then
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring Varnish ... "
		# @script-note: install varnish dependencies
		for depend in "${varnish_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing Varnish dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			vstacklet::log "apt-get -y install ${install} --allow-unauthenticated" || vstacklet::clean::rollback 59
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${varnish_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		cd /etc/varnish || vstacklet::clean::rollback 60
		vstacklet::shell::text::yellow::sl "configuring Varnish ... " &
		vs::stat::progress::start # start progress status
		mv default.vcl default.vcl.ORIG
		# @script-note: import varnish config files from vStacklet
		# - the custom.vcl file is a custom Varnish config file that can be used to override the default.vcl file.
		# - the default.vcl file is the default Varnish config file that is used to configure Varnish.
		# - the custom.vcl file imported from vStacklet is setup to function with phpmyadmin and wordpress.
		cp -f "${local_varnish_dir}custom.vcl" "/etc/varnish/custom.vcl"
		# adjust varnish config files
		if [[ -n ${nginx} ]]; then
			# @script-note: if nginx is installed, then use nginx as the backend. this is assigned by way of the http_port variable
			sed -i -e "s|{{server_ip}}|${server_ip}|g" -e "s|{{varnish_port}}|${http_port:-80}|g" -e "s|{{domain}}|${domain:-${server_ip}}|g" "/etc/varnish/custom.vcl"
			sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" -e "s|You probably want to change it|custom.vcl has been set by vStacklet|g" "/etc/default/varnish"
		else
			# @script-note: if nginx is not installed, then use varnish as the backend. this is assigned by way of the varnish_port variable (this is not useful for most people)
			sed -i -e "s|{{server_ip}}|${server_ip}|g" -e "s|{{varnish_port}}|${varnish_port:-6081}|g" -e "s|{{domain}}|${domain:-${server_ip}}|g" "/etc/varnish/custom.vcl"
			sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" -e "s|You probably want to change it|custom.vcl has been set by vStacklet|g" "/etc/default/varnish"
		fi
		# @script-note: adjust varnish service
		#todo: cp -f /lib/systemd/system/varnishlog.service /etc/systemd/system/
		cp -f /lib/systemd/system/varnish.service /etc/systemd/system/
		sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" "/etc/systemd/system/varnish.service"
		sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" "/lib/systemd/system/varnish.service"
		vstacklet::log "systemctl daemon-reload" || vstacklet::clean::rollback 61
		cd "${HOME}" || vstacklet::clean::rollback 62
		vs::stat::progress::stop # stop progress status
		# @script-note: varnish installation complete
		vstacklet::shell::text::green "Varnish installed and configured. see details below:"
		vstacklet::shell::text::white::sl "Varnish port: "
		vstacklet::shell::text::green "${varnish_port:-6081}"
		vstacklet::shell::text::white::sl "Varnish config: "
		vstacklet::shell::text::green "/etc/varnish/custom.vcl"
		vstacklet::shell::text::white::sl "Varnish service: "
		vstacklet::shell::text::green "/etc/systemd/system/varnish.service"
	fi
}

##################################################################################
# @name: vstacklet::permissions::adjust (27)
# @description: Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1620-L1627)
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
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::permissions::adjust() {
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "adjusting permissions ... "
	chown -R www-data:www-data "${web_root:-/var/www/html}"
	chmod -R 755 "${web_root:-/var/www/html}"
	sh -c "find ${web_root:-/var/www/html} -type f -print0 | sudo xargs -0 chmod 644"
	chmod -R g+rw "${web_root:-/var/www/html}"
	sh -c "find ${web_root:-/var/www/html} -type d -print0 | sudo xargs -0 chmod g+s"
}

##################################################################################
# @name: vstacklet::ioncube::install (28)
# @description: Install ionCube loader. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1650-L1678)
#
# notes:
# - the ioncube loader will be available for the php version specified
#   from the `-php | --php` option.
# @option: $1 - `-ioncube | --ioncube` (optional) (takes no arguments)
# @example: vstacklet -ioncube -php 8.1
# @example: vstacklet --ioncube --php 8.1
# @example: vstacklet -ioncube -php 7.4
# @example: vstacklet --ioncube --php 7.4
# @null
# @return_code: 63 - failed to switch to /tmp directory.
# @return_code: 64 - failed to download ionCube loader.
# @return_code: 65 - failed to extract ionCube loader.
# @return_code: 66 - failed to switch to /tmp/ioncube directory.
# @return_code: 67 - failed to copy ionCube loader to /usr/lib/php/ directory.
# @return_code: 68 - failed to enable ionCube loader php extension.
# @break
##################################################################################
vstacklet::ioncube::install() {
	if [[ -n ${ioncube} ]]; then
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing IonCube Loader for php-${php} ... "
		# @script-note: install ioncube loader for php 7.4
		if [[ ${php} == *"7"* ]]; then
			cd /tmp || vstacklet::clean::rollback 63
			vstacklet::log "wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 64
			vstacklet::log "tar -xvzf ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 65
			cd ioncube || vstacklet::clean::rollback 66
			cp -f ioncube_loader_lin_7.4.so /usr/lib/php/20190902/ || vstacklet::clean::rollback 67
			echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" >/etc/php/7.4/mods-available/ioncube.ini
			ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/cli/conf.d/00-ioncube.ini
			ln -sf /etc/php/7.4/mods-available/ioncube.ini /etc/php/7.4/fpm/conf.d/00-ioncube.ini
			#phpenmod -v 7.4 ioncube || vstacklet::clean::rollback 68
		fi
		# @script-note: install ioncube loader for php 8.1
		if [[ ${php} == *"8"* ]]; then
			cd /tmp || vstacklet::clean::rollback 63
			vstacklet::log "wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 64
			vstacklet::log "tar -xvzf ioncube_loaders_lin_x86-64.tar.gz" || vstacklet::clean::rollback 65
			cd ioncube || vstacklet::clean::rollback 66
			cp -f ioncube_loader_lin_8.1.so /usr/lib/php/20210902/ || vstacklet::clean::rollback 67
			echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" >/etc/php/8.1/mods-available/ioncube.ini
			ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/cli/conf.d/00-ioncube.ini
			ln -sf /etc/php/8.1/mods-available/ioncube.ini /etc/php/8.1/fpm/conf.d/00-ioncube.ini
			#phpenmod -v 8.1 ioncube || vstacklet::clean::rollback 68
		fi
		# @script-note: ioncube installation complete
	fi
}

##################################################################################
# @name: vstacklet::mariadb::install (29)
# @description: Install mariaDB and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1712-L1774)
#
# notes:
# - if `-mysql | --mysql` is specified, then mariadb will not be installed. choose either mariadb or mysql.
# - actual mariadb version installed is 10.6.+ LTS.
# @option: $1 - `-mariadb | --mariadb` (optional) (takes no arguments)
# @option: $2 - `-mariadbP | --mariadb_port` (optional) (takes one argument)
# @option: $3 - `-mariadbU | --mariadb_user` (optional) (takes one argument)
# @option: $4 - `-mariadbPw | --mariadb_password` (optional) (takes one argument)
# @arg: $2 - `[port]` (optional) (default: 3306)
# @arg: $3 - `[user]` (optional) (default: admin)
# @arg: $4 - `[password]` (optional) (default: password auto-generated)
# @example: vstacklet -mariadb -mariadbP 3306 -mariadbU admin -mariadbPw password
# @example: vstacklet --mariadb --mariadb_port 3306 --mariadb_user admin --mariadb_password password
# @example: vstacklet -mariadb -mariadbP 3306 -mariadbU admin
# @example: vstacklet --mariadb --mariadb_port 3306 --mariadb_user admin
# @example: vstacklet -mariadb -mariadbP 3306
# @example: vstacklet --mariadb --mariadb_port 3306
# @example: vstacklet -mariadb
# @example: vstacklet --mariadb
# @null
# @return_code: 69 - failed to install MariaDB dependencies.
# @return_code: 70 - failed to initialize MariaDB secure installation.
# @return_code: 71 - failed to create MariaDB user.
# @return_code: 72 - failed to create MariaDB user password.
# @return_code: 73 - failed to create MariaDB user privileges.
# @return_code: 74 - failed to flush privileges.
# @return_code: 75 - failed to set MariaDB client and server configuration.
# @break
##################################################################################
vstacklet::mariadb::install() {
	if [[ -n ${mariadb} ]]; then
		[[ -n ${mysql} ]] && vstacklet::shell::misc::nl && vstacklet::shell::text::red "mariadb and mysql cannot be installed together. choose either mariadb or mysql." && vstacklet::clean::rollback 1
		declare mariadb_autoPw
		mariadb_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring MariaDB ... "
		# @script-note: install mariadb dependencies
		for depend in "${mariadb_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing MariaDB dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || setup::clean::rollback 69
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${mariadb_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		# @script-note: configure mariadb
		vstacklet::shell::text::yellow::sl "configuring MariaDB ... " &
		vs::stat::progress::start # start progress status
		(
			prog=/usr/bin/mysql_secure_installation
			/usr/bin/expect <<DOD
spawn "${prog}"
send "\r"
expect "(y/n)?\r"
send "n\r"
expect "(y/n)?\r"
send "n\r"
expect "(y/n)?\r"
send "y\r"
expect "(y/n)?\r"
send "y\r"
expect "(y/n)?\r"
send "y\r"
expect "(y/n)?\r"
send "y\r"
expect dof
exit
DOD
		) >>${vslog} 2>&1 || setup::clean::rollback 70
		# @script-note: set mariadb client and server configuration
		{
			echo -e "[client]"
			echo -e "user = ${mariadb_user:-admin}"
			echo -e "password = ${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo -e "[mysqld]"
			echo -e "port = ${mariadb_port:-3306}"
			echo -e "socket = /run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"
			echo -e "datadir = /var/lib/mysql"
			echo -e "log-error = /var/log/mysql/error.log"
			echo -e "pid-file = /var/run/mysqld/mysqld.pid"
			echo -e "max_allowed_packet = 16M"
			#echo -e "max_connections = 1000"
			#echo -e "max_user_connections = 1000"
			#echo -e "max_connect_errors = 1000"
			echo -e "max_heap_table_size = 16M"
			echo -e "max_sp_recursion_depth = 255"
			#echo -e "max_sp_cache_size = 4096"
			echo -e "max_binlog_size = 100M"
			echo -e "max_binlog_cache_size = 1M"
			echo -e "max_binlog_stmt_cache_size = 1M"
			echo -e "max_sort_length = 1024"
			echo -e "max_join_size = 1000000"
			echo -e "max_length_for_sort_data = 1024"
			echo -e "max_seeks_for_key = 4294967295"
			echo -e "max_write_lock_count = 4294967295"
			echo -e "max_tmp_tables = 32"
			#echo -e "max_tmp_disk_tables = 32"
			echo -e "max_prepared_stmt_count = 16382"
			echo -e "max_delayed_threads = 20"
			#echo -e "max_insert_delayed_threads = 20"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::clean::rollback 75
		# @script-note: set .my.cnf
		{
			echo "[client]"
			echo "user=${mariadb_user:-admin}"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo "[mysql]"
			echo "user=root"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo "[mysqldump]"
			echo "user=root"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo "[mysqldiff]"
			echo "user=root"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
		} >/root/.my.cnf || vstacklet::clean::rollback 75
		vstacklet::log "systemctl daemon-reload"
		vstacklet::log "systemctl restart mariadb"
		#mysqladmin -u root -h localhost password "${mariadb_password:-${mariadb_autoPw}}"
		# @script-note: create mariadb user
		mysql -e "CREATE USER '${mariadb_user:-admin}'@'localhost' IDENTIFIED BY '${mariadb_password:-${mariadb_autoPw}}';" >>${vslog} 2>&1 || vstacklet::clean::rollback 72
		mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${mariadb_user:-admin}'@'localhost' WITH GRANT OPTION;" >>${vslog} 2>&1 || vstacklet::clean::rollback 73
		mysql -e "FLUSH PRIVILEGES;" >>${vslog} 2>&1 || vstacklet::clean::rollback 74
		vs::stat::progress::stop # stop progress status
		# @script-note: mariadb installation complete
		vstacklet::shell::text::green "mariaDB installed and configured. see details below:"
		vstacklet::shell::text::white::sl "mariaDB password: "
		vstacklet::shell::text::green "${mariadb_password:-${mariadb_autoPw}}"
		vstacklet::shell::text::white::sl "mariaDB user: "
		vstacklet::shell::text::green "${mariadb_user:-admin}"
		vstacklet::shell::text::white::sl "mariaDB port: "
		vstacklet::shell::text::green "${mariadb_port:-3306}"
		vstacklet::shell::text::white::sl "mariaDB socket: "
		vstacklet::shell::text::green "/var/run/mysqld/mysqld.sock"
		vstacklet::shell::text::white::sl "mariaDB configuration file: "
		vstacklet::shell::text::green "/etc/mysql/conf.d/vstacklet.cnf"
		declare -g pma_password
		pma_password="${mariadb_password:-${mariadb_autoPw}}"
	fi
}

##################################################################################
# @name: vstacklet::mysql::install (30)
# @description: Install mySQL and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1804-L1869)
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
# @arg: $3 - `[mysql_user]` (optional) (default: admin)
# @arg: $4 - `[mysql_password]` (optional) (default: password auto-generated)
# @example: vstacklet -mysql -mysqlP 3306 -mysqlU admin -mysqlPw password
# @example: vstacklet --mysql --mysql_port 3306 --mysql_user admin --mysql_password password
# @null
# @return_code: 76 - failed to download MySQL deb package.
# @return_code: 77 - failed to install MySQL deb package.
# @return_code: 78 - failed to install MySQL dependencies.
# @return_code: 79 - failed to set MySQL password.
# @return_code: 80 - failed to create MySQL user.
# @return_code: 81 - failed to grant MySQL user privileges.
# @return_code: 82 - failed to flush MySQL privileges.
# @return_code: 83 - failed to set MySQL client and server configuration.
# @break
##################################################################################
vstacklet::mysql::install() {
	if [[ -n ${mysql} ]]; then
		[[ -n ${mariadb} ]] && vstacklet::shell::misc::nl && vstacklet::shell::text::red "mysql and mariadb cannot be installed together. choose either mysql or mariadb." && vstacklet::clean::rollback
		declare mysql_autoPw
		mysql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		mysql_deb_version="mysql-apt-config_0.8.24-1_all.deb"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring MySQL ... "
		# @script-note: install mysql deb
		vstacklet::log "wget https://dev.mysql.com/get/mysql-apt-config_${mysql_deb_version}_all.deb -O /tmp/mysql-apt-config_${mysql_deb_version}_all.deb" || vstacklet::clean::rollback 76
		vstacklet::log "dpkg -i ${mysql_deb_version}" || vstacklet::clean::rollback 77
		# @script-note: install mysql dependencies
		declare -a depend_list install_list
		for depend in "${mysql_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing MySQL dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || setup::clean::rollback 78
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${mysql_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		# @script-note: configure mysql
		vstacklet::shell::text::yellow::sl "configuring MySQL ... " &
		vs::stat::progress::start # start progress status
		# @script-note: set mysql client and server configuration
		{
			echo -e "[client]"
			echo -e "username = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysqld]"
			echo -e "port = ${mysql_port:-3306}"
			echo -e "socket = /var/run/mysql/mysql.sock"
			echo -e "bind-address = 127.0.0.1"
			echo -e "skip-external-locking"
			echo -e "key_buffer_size = 16M"
			echo -e "max_allowed_packet = 16M"
			#echo -e "table_open_cache = 64"
			echo -e "sort_buffer_size = 4M"
			echo -e "net_buffer_length = 8K"
			echo -e "read_buffer_size = 2M"
			echo -e "read_rnd_buffer_size = 1M"
			echo -e "myisam_sort_buffer_size = 64M"
			echo -e "thread_cache_size = 8"
			echo -e "query_cache_size = 32M"
			echo -e "query_cache_limit = 2M"
			echo -e "query_cache_type = 1"
			echo -e "log_error = /var/log/mysql/error.log"
			echo -e "expire_logs_days = 10"
			echo -e "max_binlog_size = 100M"
			echo -e "character-set-server = utf8mb4"
			echo -e "collation-server = utf8mb4_unicode_ci"
			echo -e "default-storage-engine = InnoDB"
			echo -e "innodb_file_per_table = 1"
			echo -e "innodb_buffer_pool_size = 128M"
			echo -e "innodb_log_file_size = 64M"
			echo -e "innodb_log_buffer_size = 8M"
			echo -e "innodb_flush_log_at_trx_commit = 1"
			echo -e "innodb_lock_wait_timeout = 50"
			echo -e "innodb_doublewrite = 1"
			echo -e "innodb_flush_method = O_DIRECT"
			echo -e "innodb_read_io_threads = 4"
			echo -e "innodb_write_io_threads = 4"
			echo -e "innodb_purge_threads = 1"
			echo -e "innodb_thread_concurrency = 0"
			echo -e "innodb_strict_mode = 1"
			echo -e "innodb_large_prefix = 1"
			echo -e "innodb_file_format = Barracuda"
			echo -e "innodb_file_format_max = Barracuda"
			echo -e "innodb_stats_on_metadata = 0"
			echo -e "innodb_autoinc_lock_mode = 2"
			echo -e "innodb_print_all_deadlocks = 1"
			echo -e "innodb_buffer_pool_instances = 1"
			echo -e "innodb_buffer_pool_load_at_startup = 1"
			echo -e "innodb_buffer_pool_dump_at_shutdown = 1"
			echo -e "innodb_buffer_pool_dump_pct = 25"
			echo -e "innodb_buffer_pool_dump_now = 1"
			echo -e "innodb_buffer_pool_load_now = 1"
			echo -e "innodb_buffer_pool_dump_filename = /var/lib/mysql/ib_buffer_pool"
			echo -e "innodb_buffer_pool_load_filename = /var/lib/mysql/ib_buffer_pool"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::clean::rollback 83
		# @script-note: set mysql privileges
		{
			echo -e "[mysqld]"
			echo -e "skip-grant-tables"
		} >/etc/mysql/conf.d/vstacklet-grant.cnf || vstacklet::clean::rollback 83
		# @script-note: set ~/.my.cnf
		{
			echo -e "[client]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysql]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysqldump]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
		} >"${HOME}/.my.cnf" || vstacklet::clean::rollback 83
		vstacklet::log "systemctl daemon-reload"
		#vstacklet::log "systemctl enable mysql"
		#vstacklet::log "systemctl restart mysql"
		#mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_password:-${mysql_autoPw}}';\"" || vstacklet::clean::rollback 79
		mysql -e "CREATE USER '${mysql_user:-admin}'@'localhost' IDENTIFIED BY '${mysql_password:-${mysql_autoPw}}';" >>${vslog} 2>&1 || vstacklet::clean::rollback 80
		mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${mysql_user:-admin}'@'localhost' WITH GRANT OPTION;" >>${vslog} 2>&1 || vstacklet::clean::rollback 81
		mysql -e "FLUSH PRIVILEGES;" >>${vslog} 2>&1 || vstacklet::clean::rollback 82
		vs::stat::progress::stop # stop progress status
		# @script-note: mysql installation complete
		vstacklet::shell::text::green "MySQL installed and configured. see details below:"
		vstacklet::shell::text::white::sl "MySQL password: "
		vstacklet::shell::text::green "${mysql_password:-${mysql_autoPw}}"
		vstacklet::shell::text::white::sl "MySQL user: "
		vstacklet::shell::text::green "${mysql_user:-admin}"
		vstacklet::shell::text::white::sl "MySQL port: "
		vstacklet::shell::text::green "${mysql_port:-3306}"
		vstacklet::shell::text::white::sl "MySQL socket: "
		vstacklet::shell::text::green "/var/run/mysqld/mysqld.sock"
		vstacklet::shell::text::white::sl "MySQL configuration file: "
		vstacklet::shell::text::green "/etc/mysql/conf.d/vstacklet.cnf"
		declare -g pma_password
		pma_password="${mysql_password:-${mysql_autoPw}}"
	fi
}

##################################################################################
# @name: vstacklet::postgre::install (31)
# @description: Install and configure PostgreSQL. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1889-L1969)
# @option: $1 - `-postgre | --postgresql` (optional)
# @arg: $2 - `[postgresql_port]` (optional) (default: 5432)
# @arg: $3 - `[postgresql_user]` (optional) (default: admin)
# @arg: $4 - `[postgresql_password]` (optional) (default: password auto-generated)
# @example: vstacklet -postgre -postgreP 5432 -postgreU admin -postgrePw password
# @example: vstacklet --postgresql --postgresql_port 5432 --postgresql_user admin --postgresql_password password
# @return_code: 84 - failed to install PostgreSQL dependencies.
# @return_code: 85 - failed to switch to /etc/postgresql/${postgre_version}/main directory.
# @return_code: 86 - failed to set PostgreSQL password.
# @return_code: 87 - failed to create PostgreSQL user.
# @return_code: 88 - failed to grant PostgreSQL user privileges.
# @return_code: 89 - failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file.
# @return_code: 90 - failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file.
# @break
##################################################################################
vstacklet::postgre::install() {
	if [[ -n ${postgresql} ]]; then
		declare postgresql_autoPw
		postgresql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring PostgreSQL ... "
		# @script-note: install postgre dependencies
		declare -a depend_list install_list
		for depend in "${postgresql_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing PostgreSQL dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 84
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${postgresql_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		# @script-note: configure postgre
		vstacklet::shell::text::yellow::sl "configuring PostgreSQL ... " &
		vs::stat::progress::start # start progress status
		# @script-note: scrape the version from the output of `apt-cache policy postgresql`
		# since the `psql --version` could return blank if ran too soon after the installation.
		# this also allows a faster installation as no sleep is required.
		#postgre_version="$(psql --version | awk '{print $3}' | awk -F. '{print $1"."$2}')"
		declare postgre_version
		postgre_version="$(apt-cache policy postgresql | grep -A1 "Installed:" | grep -v "Installed:" | awk '{print $2}' | awk -F. '{print $1"."$2}' | cut -d'+' -f1)"
		# @script-note: to make alterations to postgresql, we must first switch to a directory
		# that postgresql has access to
		cd "/etc/postgresql/${postgre_version}/main" || vstacklet::clean::rollback 85
		# set postgresql root password
		(
			sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';"
			sleep 2
		) >>${vslog} 2>&1 || vstacklet::clean::rollback 86
		# @script-note: create postgresql user
		(
			sudo -u postgres psql -c "CREATE USER ${postgresql_user:-admin} WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';"
			sleep 2
		) >>${vslog} 2>&1 || vstacklet::clean::rollback 87
		# @script-note: grant postgresql user privileges
		(
			sudo -u postgres psql -c "ALTER USER ${postgresql_user:-admin} WITH SUPERUSER;"
			sleep 2
		) >>${vslog} 2>&1 || vstacklet::clean::rollback 88
		# @script-note: set postgre client and server configuration
		cp -f "/etc/postgresql/${postgre_version}/main/postgresql.conf" "/etc/postgresql/${postgre_version}/main/postgresql.conf.default-bak"
		{
			echo -e "port = ${postgresql_port:-5432}"
			echo -e "listen_addresses = 'localhost'"
		} >"/etc/postgresql/${postgre_version}/main/postgresql.conf" || vstacklet::clean::rollback 89
		cp -f "/etc/postgresql/${postgre_version}/main/pg_hba.conf" "/etc/postgresql/${postgre_version}/main/pg_hba.conf.default-bak"
		{
			echo -e "# Database administrative login by Unix domain socket"
			echo -e "local   all             postgres                                peer"
			echo
			echo -e "# TYPE  DATABASE        USER            ADDRESS                 METHOD"
			echo
			echo -e "# \"local\" is for Unix domain socket connections only"
			echo -e "local   all             all                                     md5"
		} >"/etc/postgresql/${postgre_version}/main/pg_hba.conf" || vstacklet::clean::rollback 90
		vs::stat::progress::stop # stop progress status
		# @script-note: postgresql installation complete
		vstacklet::shell::text::green "PostgreSQL installed and configured. see details below:"
		vstacklet::shell::text::white::sl "PostgreSQL password: "
		vstacklet::shell::text::green "${postgresql_password:-${postgresql_autoPw}}"
		vstacklet::shell::text::white::sl "PostgreSQL user: "
		vstacklet::shell::text::green "${postgresql_user:-admin}"
		vstacklet::shell::text::white::sl "PostgreSQL port: "
		vstacklet::shell::text::green "${postgresql_port:-5432}"
		vstacklet::shell::text::white::sl "PostgreSQL socket: "
		vstacklet::shell::text::green "/var/run/postgresql"
		vstacklet::shell::text::white::sl "PostgreSQL configuration file: "
		vstacklet::shell::text::green "/etc/postgresql/${postgre_version}/main/postgresql.conf"
		vstacklet::shell::text::white::sl "PostgreSQL hba file: "
		vstacklet::shell::text::green "/etc/postgresql/${postgre_version}/main/pg_hba.conf"
	fi
}

##################################################################################
# @name: vstacklet::redis::install (32)
# @description: Install and configure Redis. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1992-L2044)
# @option: $1 - `-redis | --redis` (optional)
# @option: $2 - `-redisP | --redis_port` (optional)
# @option: $3 - `-redisPw | --redis_password` (optional)
# @arg: $2 - `[redis_port]` (optional) (default: 6379)
# @arg: $3 - `[redis_password]` (optional) (default: password auto-generated)
# @example: vstacklet -redis -redisP 6379 -redisPw password
# @example: vstacklet --redis --redis_port 6379 --redis_password password
# @example: vstacklet -redis
# @example: vstacklet --redis
# @null
# @return_code: 91 - failed to install Redis dependencies.
# @return_code: 92 - failed to backup the Redis configuration file.
# @return_code: 93 - failed to import the Redis configuration file.
# @return_code: 94 - failed to modify the Redis configuration file.
# @return_code: 95 - failed to restart the Redis service.
# @return_code: 96 - failed to set the Redis password.
# @break
##################################################################################
vstacklet::redis::install() {
	if [[ -n ${redis} ]]; then
		declare redis_autoPw
		redis_autoPw="$(perl -e 'print map { (a..z,A..Z,0..9)[rand 62] } 0..15')"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring Redis ... "
		# @script-note: install redis dependencies
		declare -a depend_list install_list
		for depend in "${redis_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing Redis dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 91
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${redis_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		# @script-note: configure redis
		vstacklet::shell::text::yellow::sl "configuring Redis ... " &
		vs::stat::progress::start # start progress status
		# @script-note: set redis client and server configuration
		cp -f /etc/redis/redis.conf /etc/redis/redis.conf.bak || vstacklet::clean::rollback 92
		cp -f "${local_setup_dir}/templates/redis/redis.conf" /etc/redis/redis.conf || vstacklet::clean::rollback 93
		sed -i.bak "s/{{redis_port}}/${redis_port:-6379}/g" /etc/redis/redis.conf || vstacklet::clean::rollback 94
		# @script-note: restart redis
		vstacklet::log "systemctl restart redis-server" || vstacklet::clean::rollback 95
		# @script-note: set redis password
		redis-cli -a "" -h localhost -p ${redis_port:-6379} config set requirepass "${redis_password:-${redis_autoPw}}" >>${vslog} 2>&1 || vstacklet::clean::rollback 96
		vs::stat::progress::stop # stop progress status
		# @script-note: redis installation complete
		vstacklet::shell::text::green "Redis installed and configured. see details below:"
		vstacklet::shell::text::white::sl "Redis password: "
		vstacklet::shell::text::green "${redis_password:-${redis_autoPw}}"
		#vstacklet::shell::text::white::sl "Redis user: "
		#vstacklet::shell::text::green "${redis_user:-admin}"
		vstacklet::shell::text::white::sl "Redis port: "
		vstacklet::shell::text::green "${redis_port:-6379}"
		vstacklet::shell::text::white::sl "Redis socket: "
		vstacklet::shell::text::green "/var/run/redis/redis-server.sock"
		vstacklet::shell::text::white::sl "Redis configuration file: "
		vstacklet::shell::text::green "/etc/redis/redis.conf"
	fi
}

##################################################################################
# @name: vstacklet::phpmyadmin::install (33)
# @description: Install phpMyAdmin and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2099-L2200)
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
#     - note: if no user or password is provided, the default user and password will be used. (admin, auto-generated password)
#   - php version: php7.4, php8.1
#     - PHP usage: `-php [version] | --php [version]`
#   - port: http
#     - usage: `-http [port] | --http [port]`
#     - note: if no port is provided, the default port will be used. (80)
# @option: $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments) (default: not installed)
# @arg: `-phpmyadmin | --phpmyadmin` does not take any arguments. However, it requires the options as expressed above.
# @example: vstacklet -phpmyadmin -nginx -mariadbU admin -mariadbPw password -php 8.1 -http 80
# @example: vstacklet --phpmyadmin --nginx --mariadb_user admin --mariadb_password password --php 8.1 --http 80
# @null
# @return_code: 97 - a database server was not selected.
# @return_code: 98 - a web server was not selected.
# @return_code: 99 - a php version was not selected.
# @return_code: 100 - phpMyAdmin does not support HHVM.
# @return_code: 101 - failed to install phpMyAdmin dependencies.
# @return_code: 102 - failed to switch to /usr/share directory.
# @return_code: 103 - failed to remove existing phpMyAdmin directory.
# @return_code: 104 - failed to download phpMyAdmin.
# @return_code: 105 - failed to extract phpMyAdmin.
# @return_code: 106 - failed to move phpMyAdmin to /usr/share directory.
# @return_code: 107 - failed to remove phpMyAdmin .tar.gz file.
# @return_code: 108 - failed to set ownership of phpMyAdmin directory.
# @return_code: 109 - failed to set permissions of phpMyAdmin directory.
# @return_code: 110 - failed to create /usr/share/phpmyadmin/tmp directory.
# @return_code: 111 - failed to set symlink of ./phpmyadmin to ${web_root}/public/phpmyadmin.
# @return_code: 112 - failed to create phpMyAdmin configuration file.
# @break
##################################################################################
vstacklet::phpmyadmin::install() {
	# If you prefer a more modular installation, you can comment out the following 3 lines.
	#[[ -z ${mariadb} || -z ${mysql} ]] && vstacklet::clean::rollback 97
	#[[ -z ${nginx} && -z ${varnish} ]] && vstacklet::clean::rollback 98
	#[[ -z ${php} ]] && vstacklet::clean::rollback 99
	# check if hhvm is selected and throw an error if it is
	[[ -n ${hhvm} && -n ${phpmyadmin} ]] && vstacklet::clean::rollback 100
	if [[ -n ${phpmyadmin} ]]; then
		if [[ (-n ${mariadb} || -n ${mysql}) && (-n ${nginx} || -n ${varnish}) && (-n ${php}) ]]; then
			declare pma_version pma_bf
			pma_version=$(curl -s https://www.phpmyadmin.net/home_page/version.json | jq -r '.version')
			pma_bf=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..31')
			# @script-note: install phpmyadmin
			vstacklet::shell::misc::nl
			vstacklet::shell::text::white "installing and configuring phpMyAdmin ... "
			# @script-note: install phpmyadmin dependencies and phpmyadmin
			for depend in "${phpmyadmin_dependencies[@]}"; do
				if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
					depend_list+=("${depend}")
				fi
			done
			[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing phpMyAdmin dependencies: "
			for install in "${depend_list[@]}"; do
				if [[ ${install} == "${depend_list[0]}" ]]; then
					vstacklet::shell::text::white::sl "${install} "
				else
					vstacklet::shell::text::white::sl "| ${install} "
				fi
				# shellcheck disable=SC2015
				DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 101
				install_list+=("${install}")
			done
			[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
			for depend in "${phpmyadmin_dependencies[@]}"; do
				echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
			done
			unset depend depend_list install
			cd /usr/share || vstacklet::clean::rollback 102
			[[ -d phpmyadmin ]] && rm -rf phpmyadmin
			wget -q "https://files.phpmyadmin.net/phpMyAdmin/${pma_version}/phpMyAdmin-${pma_version}-all-languages.tar.gz" || vstacklet::clean::rollback 103
			tar -xzf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::clean::rollback 104
			mv phpMyAdmin-"${pma_version}"-all-languages phpmyadmin || vstacklet::clean::rollback 105
			rm -rf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::clean::rollback 106
			chown -R www-data:www-data phpmyadmin || vstacklet::clean::rollback 107
			chmod -R 755 phpmyadmin || vstacklet::clean::rollback 108
			# trunk-ignore(shellcheck/SC2015)
			mkdir -p /usr/share/phpmyadmin/tmp && chown -R www-data:www-data /usr/share/phpmyadmin/tmp || vstacklet::clean::rollback 109
			ln -sf /usr/share/phpmyadmin "${web_root:-/var/www/html}/public" || vstacklet::clean::rollback 110
			# @script-note: configure phpmyadmin
			vstacklet::shell::text::yellow::sl "configuring phpMyAdmin ... " &
			vs::stat::progress::start # start progress status
			# @script-note: create phpmyadmin htpasswd file - this is used for basic authentication, not for the database
			# this is only used if/when the user opts to use basic authentication (a post install courtesy)
			htpasswd -b -c /usr/share/phpmyadmin/.htpasswd "${mariadb_user:-${mysql_user:-admin}}" "${pma_password}" >>${vslog} 2>&1 || vstacklet::clean::rollback 111
			# @script-note: set phpmyadmin configuration
			# - /etc/phpmyadmin/config.inc.php
			# - /usr/share/phpmyadmin/config.inc.php - this is the default config file
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
				echo -e "\$cfg['Servers'][\$i]['user'] = '${mariadb_user:-${mysql_user:-admin}}';"
				echo -e "\$cfg['Servers'][\$i]['password'] = '${pma_password}';"
				echo -e "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;"
				echo -e "/* End of servers configuration */"
				echo -e "\$cfg['blowfish_secret'] = '${pma_bf}';"
				echo -e "\$cfg['DefaultLang'] = 'en';"
				echo -e "\$cfg['ServerDefault'] = 1;"
				echo -e "\$cfg['UploadDir'] = '';"
				echo -e "\$cfg['SaveDir'] = '';"
				echo -e "?>"
			} >/usr/share/phpmyadmin/config.inc.php || vstacklet::clean::rollback 112
			vs::stat::progress::stop # stop progress status
			# @script-note: phpmyadmin installation complete
			vstacklet::shell::text::green "phpMyAdmin installed and configured. see details below:"
			vstacklet::shell::text::white::sl "phpMyAdmin username: "
			vstacklet::shell::text::green "${mariadb_user:-${mysql_user:-admin}}"
			vstacklet::shell::text::white::sl "phpMyAdmin password: "
			vstacklet::shell::text::green "${pma_password}"
			vstacklet::shell::text::white::sl "phpMyAdmin http port: "
			vstacklet::shell::text::green "${http_port:-80}"
			vstacklet::shell::text::white::sl "phpMyAdmin htpasswd file: "
			vstacklet::shell::text::green "/usr/share/phpmyadmin/.htpasswd"
			vstacklet::shell::text::white::sl "phpMyAdmin configuration file: "
			vstacklet::shell::text::green "/usr/share/phpmyadmin/config.inc.php"
			vstacklet::shell::text::white::sl "phpMyAdmin web root: "
			vstacklet::shell::text::green "${web_root:-/var/www/html}/public"
		fi
	fi
}

##################################################################################
# @name: vstacklet::csf::install (34)
# @description: Install CSF firewall. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2237-L2313)
#
# notes:
# - https://configserver.com/cp/csf.html
# - installing CSF will also install LFD (Linux Firewall Daemon)
# - CSF will be configured to allow SSH, FTP, HTTP, HTTPS, MySQL, Redis,
#   Postgres, and Varnish.
# - CSF will be configured to block all other ports.
# - CSF requires sendmail to be installed. if the `-sendmail` option is not
#   specified, sendmail will be automatically installed and configured to use the
#   specified email address from the `-email` option.
# - (`-e`|`--email` required) As expressed above, CSF will also require the `-email` option to be
#   specified. this is the email address that will be used to send CSF alerts.
# - if your domain is routing through Cloudflare, you will need to use the
#   `-csfCf | --csf_cloudflare` option in order to allow Cloudflare IPs through CSF.
# @option: $1 - `-csf | --csf` (optional) (takes no argument)
# @arg: `-csf | --csf` does not take any arguments. However, it requires the options as expressed above.
# @example: vstacklet -csf -e "your@email.com" -csfCf -sendmail
# @example: vstacklet --csf --email "your@email.com" --csf_cloudflare --sendmail
# @null
# @return_code: 113 - failed to install CSF firewall dependencies.
# @return_code: 114 - failed to download CSF firewall.
# @return_code: 115 - failed to switch to /usr/local/src/csf directory.
# @return_code: 116 - failed to install CSF firewall.
# @return_code: 117 - failed to initialize CSF firewall.
# @return_code: 118 - failed to modify CSF blocklist.
# @return_code: 119 - failed to modify CSF ignore list.
# @return_code: 120 - failed to modify CSF allow list.
# @return_code: 121 - failed to modify CSF allow ports (inbound).
# @return_code: 122 - failed to modify CSF allow ports (outbound).
# @return_code: 123 - failed to modify CSF configuration file (csf.conf).
# @break
##################################################################################
vstacklet::csf::install() {
	if [[ -n ${csf} ]]; then
		# @script-note: check if csf is installed
		vstacklet::shell::misc::nl
		[[ -f /etc/csf/csf.conf ]] && vstacklet::shell::text::yellow "CSF is already installed. skipping ... " && return 0
		# @script-note: install csf
		vstacklet::shell::text::white "installing and configuring CSF (ConfigServer Security & Firewall) firewall ... "
		# @script-note: install csf dependencies and csf
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 113
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${csf_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		# @script-note: install csf
		wget -O - https://download.configserver.com/csf.tgz | tar -xz -C /usr/local/src >>${vslog} 2>&1 || vstacklet::clean::rollback 114
		cd /usr/local/src/csf || vstacklet::clean::rollback 115
		sh install.sh >>"${vslog}" 2>&1 || vstacklet::clean::rollback 116
		# @script-note: configure csf
		vstacklet::shell::text::yellow::sl "configuring CSF ... " &
		vs::stat::progress::start # start progress status
		perl /usr/local/csf/bin/csftest.pl >>"${vslog}" 2>&1 || vstacklet::clean::rollback 117
		# @script-note: modify csf blocklists - essentiallly like cloudflare, but for csf
		# https://www.configserver.com/cp/csf.html#blocklists
		sed -i.bak -e 's/^SPAMDROP|86400|0|/SPAMDROP|86400|100|/g' -e 's/^SPAMEDROP|86400|0|/SPAMEDROP|86400|100|/g' -e 's/^DSHIELD|86400|0|/DSHIELD|86400|100|/g' -e 's/^TOR|86400|0|/TOR|86400|100|/g' -e 's/^ALTTOR|86400|0|/ALTTOR|86400|100|/g' -e 's/^BOGON|86400|0|/BOGON|86400|100|/g' -e 's/^HONEYPOT|86400|0|/HONEYPOT|86400|100|/g' -e 's/^CIARMY|86400|0|/CIARMY|86400|100|/g' -e 's/^BFB|86400|0|/BFB|86400|100|/g' -e 's/^OPENBL|86400|0|/OPENBL|86400|100|/g' -e 's/^AUTOSHUN|86400|0|/AUTOSHUN|86400|100|/g' -e 's/^MAXMIND|86400|0|/MAXMIND|86400|100|/g' -e 's/^BDE|3600|0|/BDE|3600|100|/g' -e 's/^BDEALL|86400|0|/BDEALL|86400|100|/g' /etc/csf/csf.blocklists >>"${vslog}" 2>&1 || vstacklet::clean::rollback 118
		# @script-note: the following lines are commented out as they are currently WIP. (formatting is not correct)
		# modify csf.ignore - ignore nginx, varnish, mysql, redis, postgresql, and phpmyadmin
		#{
		#	echo
		#	echo "[ vStacklet Additions ]"
		#	[[ -n ${nginx} ]] && echo "nginx"
		#	[[ -n ${varnish} ]] && echo "varnish" && echo "varnishd"
		#	[[ -n ${mysql} || ${mariadb} ]] && echo "mysql" && echo "mysqld"
		#	[[ -n ${redis} ]] && echo "redis" && echo "redis-server"
		#	[[ -n ${postgresql} ]] && echo "postgre" && echo "postgresql"
		#	[[ -n ${phpmyadmin} ]] && echo "phpmyadmin"
		#	echo "rsyslog"
		#	echo "rsyslogd"
		#	echo "systemd-timesyncd"
		#	echo "systemd-resolved"
		#} >>/etc/csf/csf.ignore || vstacklet::clean::rollback 119
		## modify csf.allow - allow ssh, http, https, mysql, mariadb, postgresql, redis, and varnish
		#{
		#	echo
		#	echo "[ vStacklet Additions ]"
		#	echo "${ssh_port:-22}"
		#	echo "${ftp_port:-21}"
		#	echo "${http_port:-80}"
		#	echo "${https_port:-443}"
		#	[[ -n ${mysql_port} ]] && echo "${mysql_port:-3306}"
		#	[[ -n ${mariadb_port} ]] && echo "${mariadb_port:-3306}"
		#	[[ -n ${postgresql_port} ]] && echo "${postgresql_port:-5432}"
		#	[[ -n ${redis_port} ]] && echo "${redis_port:-6379}"
		#	[[ -n ${varnish_port} ]] && echo "${varnish_port:-6081}"
		#	[[ -n ${sendmail_port} ]] && echo "${sendmail_port:-587}"
		#} >>/etc/csf/csf.allow || vstacklet::clean::rollback 120
		declare -a csf_allow_ports=("${ssh_port}" "${ftp_port}" "${http_port}" "${https_port}" "${mysql_port}" "${mariadb_port}" "${postgresql_port}" "${redis_port}" "${varnish_port}" "${sendmail_port}")
		# @script-note: modify csf.conf - allow ssh, ftp, http, https, mysql, mariadb, postgresql, redis, sendmail, and varnish
		for p in "${csf_allow_ports[@]}"; do
			sed -i.bak -e "s/^TCP_IN = \"\$TCP_IN\"/TCP_IN = \"\$TCP_IN ${p}\"/g" -e "s/^TCP6_IN = \"\$TCP6_IN\"/TCP6_IN = \"\$TCP6_IN ${p}\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 121
			sed -i.bak -e "s/^TCP_OUT = \"\$TCP_OUT\"/TCP_OUT = \"\$TCP_OUT ${p}\"/g" -e "s/^TCP6_OUT = \"\$TCP6_OUT\"/TCP6_OUT = \"\$TCP6_OUT ${p}\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 122
		done
		# @script-note: modify csf.conf - this is to be further refined
		sed -i.bak -e "s/^TESTING = \"1\"/TESTING = \"0\"/g" -e "s/^RESTRICT_SYSLOG = \"0\"/RESTRICT_SYSLOG = \"1\"/g" -e "s/^DENY_TEMP_IP_LIMIT = \"100\"/DENY_TEMP_IP_LIMIT = \"1000\"/g" -e "s/^SMTP_ALLOW_USER = \"\"/SMTP_ALLOW_USER = \"root\"/g" -e "s/^PT_USERMEM = \"200\"/PT_USERMEM = \"1000\"/g" -e "s/^PT_USERTIME = \"1800\"/PT_USERTIME = \"7200\"/g" /etc/csf/csf.conf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 123
		vs::stat::progress::stop # stop progress status
		# @script-note: the following signals for sendmail to be installed
		# if the `-sendmail` flag is not passed to the script. sendmail is a
		# dependency for csf to function properly.
		[[ -z ${sendmail} || ${sendmail_skip} -eq 1 ]] && vstacklet::sendmail::install
	fi
}

##################################################################################
# @name: vstacklet::cloudflare::csf (34.1)
# @description: Configure Cloudflare IP addresses in CSF. This is to be used
# when Cloudflare is used as a CDN. This will allow CSF to
# recognize Cloudflare IPs as trusted. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2338-L2356)
#
# notes:
# - This function is only called under the following conditions:
#   - the option `-csf` is used (required)
#   - the option `-csfCf` is used directly
# - This function is only utilized if the option for `-csf` is used.
# - This function adds the Cloudflare IP addresses to the CSF allow list. This
#   is done to ensure that the server can be accessed by Cloudflare. The list
#   is located in /etc/csf/csf.allow.
# @option: $1 - `-csfCf | --csf_cloudflare` (optional)
# @noargs
# @example: vstacklet -csfCf -csf -e "your@email.com"
# @null
# @return_code: 124 - CSF has not been enabled ' -csf ' (required). this is a component
# of CSF for cloudflare configuration.
# @return_code: 125 - CSF allow file does not exist.
# @break
##################################################################################
vstacklet::cloudflare::csf() {
	# @script-note: check if Cloudflare has been selected
	if [[ -n ${csf_cloudflare} ]]; then
		# @script-note: check if CSF has been selected
		[[ -z ${csf} ]] && vstacklet::clean::rollback 124
		# @script-note: check if the csf.allow file exists
		[[ ! -f "/etc/csf/csf.allow" ]] || vstacklet::clean::rollback 125
		# @script-note: add Cloudflare IP addresses to the allow list
		vstacklet::shell::text::white "adding Cloudflare IP addresses to the allow list ... "
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
# @name: vstacklet::sendmail::install (35)
# @description: Install and configure sendmail. This is a required component for
# CSF to function properly. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2387-L2443)
#
# notes:
# - The `-e | --email` option is required for this function to run properly.
#   the email address provided will be used to configure sendmail.
# - If installing CSF, this function will be called automatically. As such, it
#   is not necessary to call this function manually with the `-csf | --csf` option.
# @param: $1 - sendmail_skip installation (this is siliently passed if `-csf` is used)
# @option: $1 - `-sendmail | --sendmail` (optional) (takes no arguments)
# @noargs
# @example: vstacklet -sendmail -e "your@email.com"
# @example: vstacklet --sendmail --email "your@email.com"
# @example: vstacklet -csf -e "your@email.com"
# @null
# @return_code: 126 - an email address was not provided ' -e "your@email.com" '.
# this is required for sendmail to be installed.
# @return_code: 127 - failed to install sendmail dependencies.
# @return_code: 128 - failed to edit aliases file.
# @return_code: 129 - failed to edit sendmail.cf file.
# @return_code: 130 - failed to edit main.cf file.
# @return_code: 131 - failed to edit master.cf file.
# @return_code: 132 - failed to create sasl_passwd file.
# @return_code: 133 - postmap failed.
# @return_code: 134 - failed to source new aliases.
# @break
##################################################################################
vstacklet::sendmail::install() {
	if [[ -n ${sendmail} || -n ${sendmail_skip} ]]; then
		[[ -z ${email} ]] && vstacklet::clean::rollback 126
		# @script-note: install sendmail
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring sendmail ... "
		# @script-note: install sendmail dependencies and sendmail
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>${vslog} 2>&1 && sleep 2 || vstacklet::clean::rollback 127
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${sendmail_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		# @script-note: configure sendmail
		vstacklet::shell::text::yellow::sl "configuring sendmail ... " &
		vs::stat::progress::start # start progress status
		# @script-note: modify aliases
		sed -i.bak -e "s/^root:.*$/root: ${email}/g" /etc/aliases >>"${vslog}" 2>&1 || vstacklet::clean::rollback 128
		# @script-note: modify /etc/mail/sendmail.cf
		sed -i.bak -e "s/^DS.*$/DS${email}/g" \
			-e "s/^O DaemonPortOptions=Addr=${sendmail_port:-587}, Name=MTA-v4/O DaemonPortOptions=Addr=${sendmail_port:-587}, Name=MTA-v4, Family=inet/g" \
			-e "s/^O PrivacyOptions=authwarnings,novrfy,noexpnO PrivacyOptions=authwarnings,novrfy,noexpn/O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun/g" \
			-e "s/^O AuthInfo=.*/O AuthInfo=${email}:*:${email}/g" \
			-e "s/^O Mailer=smtp, Addr=${server_ip}, Port=smtp, Name=MTA-v4/O Mailer=smtp, Addr=${server_ip}, Port=smtp, Name=MTA-v4, Family=inet/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 129
		# @script-note: modify /etc/postfix/main.cf
		sed -i.bak -e "s/^#myhostname = host.domain.tld/myhostname = ${hostname:-${server_hostname}}/g" \
			-e "s/^#mydomain = domain.tld/mydomain = ${domain:-${server_ip}}/g" \
			-e "s/^#myorigin = \$mydomain/myorigin = \$mydomain/g" \
			-e "s/^#mydestination = \$myhostname, localhost.\$mydomain, localhost/mydestination = \$myhostname, localhost.\$mydomain, localhost/g" \
			-e "s/^#relayhost =/relayhost = ${server_ip}:${sendmail_port:-587}/g" /etc/postfix/main.cf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 130
		# @script-note: modify /etc/postfix/master.cf
		sed -i.bak -e "s/^#submission/submission/g" \
			-e "s/^#  -o syslog_name=postfix\/submission/  -o syslog_name=postfix\/submission/g" \
			-e "s/^#  -o smtpd_tls_security_level=encrypt/  -o smtpd_tls_security_level=encrypt/g" \
			-e "s/^#  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes/g" \
			-e "s/^#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/g" \
			-e "s/^#  -o milter_macro_daemon_name=ORIGINATING/  -o milter_macro_daemon_name=ORIGINATING/g" /etc/postfix/master.cf >>"${vslog}" 2>&1 || vstacklet::clean::rollback 131
		# @script-note: modify /etc/postfix/sasl_passwd
		echo "[${server_ip}]:${sendmail_port:-587} ${email}:${email}" >/etc/postfix/sasl_passwd >>"${vslog}" 2>&1 || vstacklet::clean::rollback 132
		# @script-note: modify /etc/postfix/sasl_passwd
		postmap /etc/postfix/sasl_passwd >>"${vslog}" 2>&1 || vstacklet::clean::rollback 133
		newaliases >>"${vslog}" 2>&1 || vstacklet::clean::rollback 134
		vs::stat::progress::stop # stop progress status
		# @script-note: sendmail installation complete
		vstacklet::shell::text::green "sendmail installed and configured. see details below:"
		vstacklet::shell::text::white::sl "sendmail port: "
		vstacklet::shell::text::green "${sendmail_port:-587}"
		vstacklet::shell::text::white::sl "sendmail email: "
		vstacklet::shell::text::green "${email}"
		vstacklet::shell::text::white::sl "sendmail hostname: "
		vstacklet::shell::text::green "${hostname:-${server_hostname}}"
		vstacklet::shell::text::white::sl "sendmail domain: "
		vstacklet::shell::text::green "${domain:-${server_ip}}"
	fi

}

##################################################################################
# @name: vstacklet::wordpress::install (36)
# @description: Install WordPress. This will also configure WordPress to use
# the database that was created during the installation process. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2490-L2550)
#
# notes:
# - this function is only called under the following conditions:
#   - the option `-wordpress` is used directly
# - this function will install wordpress and configure the database.
# - wordpress is an active build option and requires active intput from the user (for now).
# these arguments are:
#   - wordpress database name
#   - wordpress database user
#   - wordpress database password
# - this function requires the following options to be used:
#   - database: `-mariadb | --mariadb`, `-mysql | --mysql`, or `-postgresql | --postgresql` (only one can be used)
#   - webserver: `-nginx | --nginx` or `-varnish | --varnish` (both can be used)
#   - php: `-php | --php` or `-hhvm | --hhvm` (only one can be used)
# - this function will optionally use the following options:
#   - web root: `-wr | --web_root` (default: /var/www/html)
#
# @option: $1 - `-wordpress | --wordpress` (optional)
# @noargs
# @example: vstacklet -wp -mariadb -nginx -php "8.1" -wr "/var/www/html"
# @example: vstacklet -wp -mysql -nginx -php "8.1"
# @example: vstacklet -wp -postgresql -nginx -php "8.1"
# @example: vstacklet -wp -mariadb -nginx -php "8.1" -varnish -varnishP 80 -http 8080 -https 443
# @example: vstacklet -wp -mariadb -nginx -hhvm -wr "/var/www/html"
# @null
# @return_code: 135 - WordPress requires a database to be installed.
# @return_code: 136 - WordPress requires a webserver to be installed.
# @return_code: 137 - WordPress requires a php version to be installed.
# @return_code: 138 - failed to download WordPress.
# @return_code: 139 - failed to extract WordPress.
# @return_code: 140 - failed to move WordPress to the web root.
# @return_code: 141 - failed to create WordPress upload directory.
# @return_code: 142 - failed to create WordPress configuration file.
# @return_code: 143 - failed to modify WordPress configuration file.
# @return_code: 144 - failed to create WordPress database.
# @return_code: 145 - failed to create WordPress database user.
# @return_code: 146 - failed to grant WordPress database user privileges.
# @return_code: 147 - failed to flush WordPress database privileges.
# @return_code: 148 - failed to remove WordPress installation files.
# @break
##################################################################################
vstacklet::wordpress::install() {
	# @script-note: check if WordPress has been selected
	if [[ -n ${wordpress} ]]; then
		[[ (-z ${mariadb}) && (-z ${mysql}) && (-z ${postgresql}) ]] && vstacklet::clean::rollback 135
		[[ (-z ${nginx}) && (-z ${varnish}) ]] && vstacklet::clean::rollback 136
		[[ (-z ${php}) && (-z ${hhvm}) ]] && vstacklet::clean::rollback 137
		declare wp_db_name wp_db_user wp_db_password
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "please enter the following information for WordPress:"
		# @script-note: get WordPress database name
		vstacklet::shell::text::white::sl "WordPress database name: "
		vstacklet::shell::icon::arrow::white
		while read -r wp_db_name; do
			[[ -z ${wp_db_name} ]] && vstacklet::shell::text::error "WordPress database name cannot be empty." && vstacklet::shell::text::white::sl "WordPress database name: " && vstacklet::shell::icon::arrow::white && continue
			break
		done
		# @script-note: get WordPress database user
		vstacklet::shell::text::white::sl "WordPress database user: "
		vstacklet::shell::icon::arrow::white
		while read -r wp_db_user; do
			[[ -z ${wp_db_user} ]] && vstacklet::shell::text::error "WordPress database user cannot be empty." && vstacklet::shell::text::white::sl "WordPress database user: " && vstacklet::shell::icon::arrow::white && continue
			break
		done
		# @script-note: get WordPress database password
		vstacklet::shell::text::white::sl "WordPress database password: "
		vstacklet::shell::icon::arrow::white
		while read -r wp_db_password; do
			[[ -z ${wp_db_password} ]] && vstacklet::shell::text::error "WordPress database password cannot be empty." && vstacklet::shell::text::white::sl "WordPress database password: " && vstacklet::shell::icon::arrow::white && continue
			break
		done
		vstacklet::shell::text::white "installing and configuring WordPress ... "
		# @script-note: download WordPress
		vstacklet::log "wget -q -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz" || vstacklet::clean::rollback 138
		# @script-note: extract WordPress
		vstacklet::log "tar -xzf /tmp/wordpress.tar.gz -C /tmp" || vstacklet::clean::rollback 139
		# @script-note: move WordPress to the web root
		mv /tmp/wordpress/* "${web_root:-/var/www/html}/public" || vstacklet::clean::rollback 140
		# @script-note: create the uploads directory
		mkdir -p "${web_root:-/var/www/html}/public/wp-content/uploads" || vstacklet::clean::rollback 141
		# @script-note: set the correct permissions
		vstacklet::shell::text::yellow::sl "configuring WordPress ... " &
		vs::stat::progress::start # @script-note: start progress status
		# @script-note: create the wp-config.php file
		vstacklet::log "cp -f ${web_root:-/var/www/html}/public/wp-config-sample.php ${web_root:-/var/www/html}/public/wp-config.php" || vstacklet::clean::rollback 142
		# @script-note: modify the wp-config.php file
		sed -i \
			-e "s/database_name_here/${wp_db_name}/g" \
			-e "s/username_here/${wp_db_user}/g" \
			-e "s/password_here/${wp_db_password}/g" \
			-e "s/utf8mb4/utf8/g" \
			"${web_root:-/var/www/html}/public/wp-config.php" || vstacklet::clean::rollback 143
		# @script-note: create the database
		mysql -e "CREATE DATABASE ${wp_db_name};" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 144
		# @script-note: create the database user
		mysql -e "CREATE USER '${wp_db_user}'@'localhost' IDENTIFIED BY '${wp_db_password}';" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 145
		# @script-note: grant privileges to the database user
		mysql -e "GRANT ALL PRIVILEGES ON ${wp_db_name}.* TO '${wp_db_user}'@'localhost';" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 146
		# @script-note: flush privileges
		mysql -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 147
		# @script-note: remove the WordPress installation files
		vstacklet::log "rm -rf /tmp/wordpress /tmp/wordpress.tar.gz" || vstacklet::clean::rollback 148
		vs::stat::progress::stop # stop progress status
		# @script-note: wordpress installation complete
		vstacklet::shell::text::green "WordPress installed and configured. see details below:"
		vstacklet::shell::text::white::sl "WordPress Database Name: "
		vstacklet::shell::text::green "${wp_db_name}"
		vstacklet::shell::text::white::sl "WordPress Database User: "
		vstacklet::shell::text::green "${wp_db_user}"
		vstacklet::shell::text::white::sl "WordPress Database Password: "
		vstacklet::shell::text::green "${wp_db_password}"
		vstacklet::shell::text::white::sl "Complete the WordPress installation at: "
		vstacklet::shell::text::green "http://${domain:-${server_ip}}/wp-admin/install.php"
		vstacklet::shell::misc::nl
		vstacklet::permissions::adjust
	fi
}

##################################################################################
# @name: vstacklet::domain::ssl (37)
# @description: The following function installs the SSL certificate
#   for the domain. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2584-L2638)
#
# notes:
# - This function is only called under the following conditions:
#   - the option for `-domain` is used (optional)
# - The following options are required for this function:
#   - `-domain` or `--domain`
#   - `-e` or `--email`
#   - `-nginx` or `--nginx`
# @option: $1 - `-domain | --domain` - The domain to install the SSL certificate for.
# @arg: $1 - `[domain]` (required)
# @example: vstacklet -nginx -domain example.com -e "your@email.com"
# @example: vstacklet --nginx --domain example.com --email "your@email.com"
# @null
# @return_code: 149 - the `-nginx|--nginx` option is required.
# @return_code: 150 - the `-e|--email` option is required.
# @return_code: 151 - failed to change directory to /root.
# @return_code: 152 - failed to create directory ${web_root}/.well-known/acme-challenge.
# @return_code: 153 - failed to clone acme.sh.
# @return_code: 154 - failed to switch to /root/acme.sh directory.
# @return_code: 155 - failed to install acme.sh.
# @return_code: 156 - failed to reload nginx.
# @return_code: 157 - failed to register the account with Let's Encrypt.
# @return_code: 158 - failed to set the default CA to Let's Encrypt.
# @return_code: 159 - failed to issue the certificate.
# @return_code: 160 - failed to install the certificate.
# @return_code: 161 - failed to edit /etc/nginx/sites-available/${domain}.conf.
# @break
##################################################################################
vstacklet::domain::ssl() {
	if [[ -n ${domain_ssl} ]]; then
		[[ -z ${nginx} ]] && vstacklet::clean::rollback 149
		[[ -z ${email} ]] && vstacklet::clean::rollback 150
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing SSL certificate for ${domain} ... "
		# @script-note: build acme.sh for Let's Encrypt SSL
		cd "/root" || vstacklet::clean::rollback 151
		[[ -d "/root/.acme.sh" ]] && rm -rf "/root/.acme.sh" >>"${vslog}" 2>&1
		mkdir -p "${web_root:-/var/www/html}/.well-known/acme-challenge" || vstacklet::clean::rollback 152
		chown -R root:www-data "${web_root:-/var/www/html}/.well-known" >>"${vslog}" 2>&1
		chmod -R 755 "${web_root:-/var/www/html}/.well-known" >>"${vslog}" 2>&1
		git clone "https://github.com/Neilpang/acme.sh.git" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 153
		cd "/root/acme.sh" || vstacklet::clean::rollback 154
		./acme.sh --install --home "/root/.acme.sh" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 155
		# @script-note: create nginx directory for SSL
		mkdir -p "/etc/nginx/ssl/${domain:?}"
		# @script-note: create SSL certificate
		cp -f "${local_setup_dir}/templates/nginx/acme" "/etc/nginx/sites-enabled/"
		# @script-note: post necessary edits to nginx acme file
		sed -i "s/{{domain}}/${domain}/g" /etc/nginx/sites-enabled/acme
		systemctl reload nginx.service >>"${vslog}" 2>&1 || vstacklet::clean::rollback 156
		./acme.sh --register-account -m "${email:?}" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 157
		./acme.sh --set-default-ca --server letsencrypt >>"${vslog}" 2>&1 || vstacklet::clean::rollback 158
		./acme.sh --issue -d "${domain}" -w "${web_root:-/var/www/html}" --server letsencrypt >>"${vslog}" 2>&1 || vstacklet::clean::rollback 159
		(
			./acme.sh --install-cert -d "${domain}" \
				--keylength ec-256 \
				--cert-file "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" \
				--key-file "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" \
				--fullchain-file "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" \
				--log "/var/log/vstacklet/${domain}.log" \
				--reloadcmd "systemctl reload nginx.service"
		) >>"${vslog}" 2>&1 || vstacklet::clean::rollback 160
		# @script-note: post necessary edits to nginx config file
		crt_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" | sed 's/\//\\\//g')
		key_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" | sed 's/\//\\\//g')
		chn_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" | sed 's/\//\\\//g')
		[[ -f "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" ]] && mv "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" "${vstacklet_base_path:?}/setup_tmp/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1
		sed -i.bak -e "s|^ssl_certificate.*|ssl_certificate ${crt_sanitize};|g" -e "s|^ssl_certificate_key.*|ssl_certificate_key ${key_sanitize};|g" -e "s|^ssl_trusted_certificate.*|ssl_trusted_certificate ${chn_sanitize};|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1 || vstacklet::clean::rollback 161
		# @script-note: remove acme ssl template
		[[ -f "/etc/nginx/sites-enabled/acme" ]] && rm -f "/etc/nginx/sites-enabled/acme" >>"${vslog}" 2>&1
		# @script-note: ssl installation complete
		vstacklet::shell::text::green "Let's Encrypt SSL certificate installed for ${domain}! see details below:"
		vstacklet::shell::text::white::sl "SSL certificate location: "
		vstacklet::shell::text::green "/etc/nginx/ssl/${domain}/${domain}-ssl.pem"
		vstacklet::shell::text::white::sl "SSL certificate key location: "
		vstacklet::shell::text::green "/etc/nginx/ssl/${domain}/${domain}-privkey.pem"
		vstacklet::shell::text::white::sl "SSL certificate chain location: "
		vstacklet::shell::text::green "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem"
		vstacklet::shell::text::white::sl "SSL certificate log location: "
		vstacklet::shell::text::green "/var/log/vstacklet/${domain}.log"
		vstacklet::shell::text::white::sl "SSL certificate renewal command: "
		vstacklet::shell::text::green "/root/.acme.sh/acme.sh --renew -d ${domain} --force"
		vstacklet::shell::text::white::sl "SSL certificate renewal cronjob: "
		vstacklet::shell::text::green "0 0 * * * /root/.acme.sh/acme.sh --cron --home /root/.acme.sh >> /var/log/vstacklet/${domain}.log"
		vstacklet::shell::text::white::sl "SSL certificate expiration date: "
		vstacklet::shell::text::green "$(openssl x509 -in "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" -noout -enddate | cut -d= -f2)"
	fi
}

################################################################################
# @name: vstacklet::clean::complete (38)
# @description: Cleans up the system after a successful installation. This
#   function is called after the installation is complete. It removes the
#   temporary files and directories created during the installation process.
#   This function will also enable and start services that were installed. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2650-L2678)
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::clean::complete() {
	vstacklet::shell::misc::nl
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
	[[ -n ${postgresql} ]] && services+=("postgresql")
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
# @name: vstacklet::message::complete (39)
# @description: Outputs success message on completion of setup. This function
#   is called after the installation is complete. It outputs a success message
#   to the user and provides them with the necessary information to access their
#   new server. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2690-L2726)
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::message::complete() {
	# vstacklet end time
	vstacklet_end_time="$(date +%s)"
	# vstacklet total time
	vstacklet_total_time="$((vstacklet_end_time - vstacklet_start_time))"
	# vstacklet total time in minutes
	vstacklet_total_time_minutes="$((vstacklet_total_time / 60))"
	# display success message
	vstacklet::shell::misc::nl
	vstacklet::shell::text::green "vStacklet Installation Complete! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
	vstacklet::shell::text::green " - Installation Completed in: ${vstacklet_total_time_minutes}/min"
	vstacklet::shell::text::white " - SSH port: ${ssh_port:-22}"
	vstacklet::shell::text::white " - FTP port: ${ftp_port:-21}"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Be sure to review the above output from the vStacklet installation process"
	vstacklet::shell::text::white "for relevant information regarding your new server and connection details."
	vstacklet::shell::misc::nl
	[[ (-n ${nginx} || -n ${varnish}) && (-n ${php} || -n ${hhvm}) ]] && vstacklet::shell::text::white " - Visit: http://${domain:-${server_ip}}/checkinfo.php"
	[[ (-n ${nginx} || -n ${varnish}) && (-n ${php} || -n ${hhvm}) ]] && vstacklet::shell::text::white " - Remember to remove or rename the checkinfo.php file after verification."
	[[ ${setup_reboot} -eq "1" ]] && vstacklet::shell::text::white "rebooting ... " && reboot
	if [[ -z ${setup_reboot} ]]; then
		declare input
		vstacklet::shell::text::white::sl "do you want to reboot (recommended)? "
		vstacklet::shell::text::green::sl "[y]"
		vstacklet::shell::text::white::sl "es"
		vstacklet::shell::text::white::sl " or "
		vstacklet::shell::text::red::sl "[n]"
		vstacklet::shell::text::white::sl "o: "
		vstacklet::shell::icon::arrow::white
		read -r input
		case "${input,,}" in
		[y] | [y][e][s] | "") vstacklet::shell::text::white "rebooting ... " && reboot ;;
		[n] | [n][o]) vstacklet::shell::text::white "skipping reboot ... " ;;
		*) ;;
		esac
	fi
	vstacklet::shell::misc::nl
	unset vstacklet_log_location vstacklet_start_time vstacklet_end_time vstacklet_total_time vstacklet_total_time_minutes
}

################################################################################

################################################################################
# @name: vstacklet::clean::rollback - vStacklet Rollback (40/return_code)
# @description: This function is called when a rollback is required. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2745-L2970)
#
# notes:
# - it will remove the temporary files and directories created during the installation
#   process.
# - it will remove the vStacklet log file.
# - it will remove any dependencies installed during the installation process.
#  (only dependencies installed by vStacklet will be removed)
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
		# vstacklet::environment::checkroot (7)
		1) error="you must be root to run this script." ;;
		# vstacklet::environment::checkdistro (8)
		2) error="this script only supports Ubuntu 18.04/20.04 and Debian 9/10/11." ;;
		# vstacklet::args::process (3)
		3) error="please provide a valid email address. (required for '-csf', '-sendmail', and '-csfCf')" ;;
		4) error="'-csfCf' requires '-csf'" ;;
		5) error="please provide a valid domain name." ;;
		6) error="please provide a valid port number for the FTP server." ;;
		7) error="invalid FTP port number. please enter a number between 1 and 65535." ;;
		8) error="the MariaDB password must be at least 8 characters long." ;;
		9) error="please provide a valid port number for the MariaDB server." ;;
		10) error="invalid MariaDB port number. please enter a number between 1 and 65535." ;;
		11) error="the MySQL password must be at least 8 characters long." ;;
		12) error="please provide a valid port number for the MySQL server." ;;
		13) error="invalid MySQL port number. please enter a number between 1 and 65535." ;;
		14) error="the PostgreSQL password must be at least 8 characters long." ;;
		15) error="please provide a valid port number for the PostgreSQL server." ;;
		16) error="invalid PostgreSQL port number. please enter a number between 1 and 65535." ;;
		17) error="invalid PHP version. please enter either 7 (7.4), or 8 (8.1)." ;;
		18) error="the HTTPS port must be a number." ;;
		19) error="invalid HTTPS port number. please enter a number between 1 and 65535." ;;
		20) error="the HTTP port must be a number." ;;
		21) error="invalid HTTP port number. please enter a number between 1 and 65535." ;;
		22) error="invalid hostname. please enter a valid hostname." ;;
		23) error="the Redis password must be at least 8 characters long." ;;
		24) error="please provide a valid port number for the Redis server." ;;
		25) error="invalid Redis port number. please enter a number between 1 and 65535." ;;
		26) error="an email is needed to register the server aliases. please set an email with '-e \"your@email.com\"'." ;;
		27) error="the Sendmail port must be a number." ;;
		28) error="invalid Sendmail port number. please enter a number between 1 and 65535." ;;
		29) error="the SSH port must be a number." ;;
		30) error="invalid SSH port number. please enter a number between 1 and 65535." ;;
		31) error="the Varnish port must be a number." ;;
		32) error="invalid Varnish port number. please enter a number between 1 and 65535." ;;
		33) error="invalid web root. please enter a valid path. (e.g. '-wr \"/var/www/html\"')" ;;
		34) error="invalid option(s): ${invalid_option[*]}" ;;
		# vstacklet::dependencies::install (6)
		35) error="failed to install script dependencies." ;;
		# vstacklet::base::dependencies (12)
		36) error="failed to install base dependencies." ;;
		# vstacklet::source::dependencies (13)
		37) error="failed to install source dependencies." ;;
		# vstacklet::hostname::set (15)
		38) error="failed to set hostname." ;;
		# vstacklet::ssh::set (17)
		39) error="failed to set SSH port." ;;
		40) error="failed to restart SSH daemon service." ;;
		# vstacklet::ftp::set (18)
		41) error="failed to set FTP port." ;;
		42) error="failed to restart FTP daemon service." ;;
		# vstacklet::block::ssdp (19)
		43) error="failed to block SSDP port." ;;
		44) error="failed to save iptables rules." ;;
		# vstacklet::locale::set (22)
		45) error="failed to set locale." ;;
		# vstacklet::php::install (23)
		46) error="PHP and HHVM cannot be installed at the same time. please choose one." ;;
		47) error="failed to install PHP dependencies." ;;
		48) error="failed to enable PHP memcached extension." ;;
		49) error="failed to enable PHP redis extension." ;;
		# vstacklet::hhvm::install (24)
		50) error="HHVM and PHP cannot be installed at the same time. please choose one." ;;
		51) error="failed to install HHVM dependencies." ;;
		52) error="failed to install HHVM." ;;
		53) error="failed to update PHP alternatives." ;;
		# vstacklet::nginx::install (25)
		54) error="failed to install NGINX dependencies." ;;
		55) error="failed to edit NGINX configuration file." ;;
		56) error="failed to enable NGINX configuration." ;;
		57) error="failed to generate dhparam file." ;;
		58) error="failed to stage checkinfo.php verification file." ;;
		# vstacklet::varnish::install (26)
		59) error="failed to install Varnish dependencies." ;;
		60) error="could not switch to /etc/varnish directory." ;;
		61) error="failed to reload the systemd daemon." ;;
		62) error="failed to switch to ~/" ;;
		# vstacklet::ioncube::install (28)
		63) error="failed to switch to /tmp directory." ;;
		64) error="failed to download ionCube Loader." ;;
		65) error="failed to extract ionCube Loader." ;;
		66) error="failed to switch to /tmp/ioncube directory." ;;
		67) error="failed to copy ionCube loader to /usr/lib/php/ directory." ;;
		68) error="failed to enable ioncube loader php extension." ;;
		# vstacklet::mariadb::install (29)
		69) error="failed to install MariaDB dependencies." ;;
		70) error="failed to initialize MariaDB secure installation." ;;
		71) error="failed to create MariaDB user." ;;
		72) error="failed to create MariaDB user password." ;;
		73) error="failed to create MariaDB user privileges." ;;
		74) error="failed to flush MariaDB privileges." ;;
		75) error="failed to set MariaDB client and server configuration." ;;
		# vstacklet::mysql::install (30)
		76) error="failed to download MySQL deb package." ;;
		77) error="failed to install MySQL deb package." ;;
		78) error="failed to install MySQL dependencies." ;;
		79) error="failed to set MySQL password." ;;
		80) error="failed to create MySQL user." ;;
		81) error="failed to grant MySQL user privileges." ;;
		82) error="failed to flush MySQL privileges." ;;
		83) error="failed to set MySQL client and server configuration." ;;
		# vstacklet::postgresql::install (31)
		84) error="failed to install PostgreSQL dependencies." ;;
		85) error="could not switch to /etc/postgresql/${postgre_version}/main directory." ;;
		86) error="failed to set PostgreSQL password." ;;
		87) error="failed to create PostgreSQL user." ;;
		88) error="failed to grant PostgreSQL user privileges." ;;
		89) error="failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file." ;;
		90) error="failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file." ;;
		# vstacklet::redis::install (32)
		91) error="failed to install Redis dependencies." ;;
		92) error="failed to backup the Redis configuration file." ;;
		93) error="failed to import the Redis configuration file." ;;
		94) error="failed to modify the Redis configuration file." ;;
		95) error="failed to restart Redis service." ;;
		96) error="failed to set the Redis password." ;;
		# vstacklet::phpmyadmin::install (33)
		97) error="a database server was not selected." ;;
		98) error="a web server was not selected." ;;
		99) error="a php version was not selected." ;;
		100) error="phpMyAdmin does not support HHVM." ;;
		101) error="failed to install phpMyAdmin dependencies." ;;
		102) error="failed to switch to /usr/share directory." ;;
		103) error="failed to remove existing phpMyAdmin directory." ;;
		104) error="failed to download phpMyAdmin." ;;
		105) error="failed to extract phpMyAdmin." ;;
		106) error="failed to move phpMyAdmin to /usr/share directory." ;;
		107) error="failed to remove phpMyAdmin .tar.gz file." ;;
		108) error="failed to set ownership of phpMyAdmin directory." ;;
		109) error="failed to set permissions of phpMyAdmin directory." ;;
		110) error="failed to create phpMyAdmin tmp directory." ;;
		111) error="failed to set symlink of ./phpmyadmin to ${web_root:-/var/www/html}/public/phpmyadmin." ;;
		112) error="failed to create phpMyAdmin configuration file." ;;
		# vstacklet::csf::install (34)
		113) error="failed to install CSF firewall dependencies." ;;
		114) error="failed to download CSF firewall." ;;
		115) error="failed to switch to /usr/local/src/csf directory." ;;
		116) error="failed to install CSF firewall." ;;
		117) error="failed to initialize CSF firewall." ;;
		118) error="failed to modify CSF blocklist." ;;
		119) error="failed to modify CSF ignore list." ;;
		120) error="failed to modify CSF allow list." ;;
		121) error="failed to modify CSF allow ports (inbound4/6)." ;;
		122) error="failed to modify CSF allow ports (outbound4/6)." ;;
		123) error="failed to modify CSF configuration file (csf.conf)." ;;
		# vstacklet::cloudflare::csf (34.1)
		124) error="CSF has not been enabled '-csf' (required). this is a component of CSF for cloudflare configuration." ;;
		125) error="CSF allow file does not exist." ;;
		# vstacklet::sendmail::install (35)
		126) error="an email address was not provided '-e \"your@email.com\"'. this is required for sendmail to be installed." ;;
		127) error="failed to install sendmail dependencies." ;;
		128) error="failed to edit aliases file." ;;
		129) error="failed to edit sendmail.cf file." ;;
		130) error="failed to edit main.cf file." ;;
		131) error="failed to edit master.cf file." ;;
		132) error="failed to create sasl_passwd file." ;;
		133) error="postmap failed." ;;
		134) error="failed to source new aliases." ;;
		# vstacklet::wordpress::install (36)
		135) error="WordPress requires a database to be installed." ;;
		136) error="WordPress requires a web server to be installed." ;;
		137) error="WordPress requires a php version to be installed." ;;
		138) error="failed to download WordPress." ;;
		139) error="failed to extract WordPress." ;;
		140) error="failed to move WordPress to ${web_root:-/var/www/html}/public directory." ;;
		141) error="failed to create WordPress upload directory." ;;
		142) error="failed to create WordPress configuration file." ;;
		143) error="failed to modify WordPress configuration file." ;;
		144) error="failed to create WordPress database." ;;
		145) error="failed to create WordPress database user." ;;
		146) error="failed to grant WordPress database user privileges." ;;
		147) error="failed to flush WordPress database privileges." ;;
		148) error="failed to remove WordPress installation files." ;;
		# vstacklet::domain::ssl (37)
		149) error="the '-nginx|--nginx' option is required." ;;
		150) error="the '-e|--email' option is required." ;;
		151) error="failed to change directory to /root." ;;
		152) error="failed to create directory ${web_root:-/var/www/html}/.well-known/acme-challenge." ;;
		153) error="failed to clone acme.sh." ;;
		154) error="failed to switch to /root/acme.sh directory." ;;
		155) error="failed to install acme.sh." ;;
		156) error="failed to reload nginx." ;;
		157) error="failed to register the account with Let's Encrypt." ;;
		158) error="failed to set the default CA to Let's Encrypt." ;;
		159) error="failed to issue the certificate." ;;
		160) error="failed to install the certificate." ;;
		161) error="failed to edit /etc/nginx/sites-available/${domain}.conf." ;;
		*) error="Unknown error" ;;
		esac
		vstacklet::shell::text::error "${error}"
	else
		vstacklet::shell::text::warning "installer has been interrupted"
	fi
	vstacklet::shell::text::rollback "a fatal error has occurred, rollback has been initiated ... "
	declare installed
	[[ -n ${ssdp_block} ]] && iptables -D INPUT -p udp --dport 1900 -j DROP
	[[ -f ${vstacklet_base_path}/setup_temp/sshd_config ]] && \cp -f "${vstacklet_base_path}/setup_temp/sshd_config" /etc/ssh/sshd_config && vstacklet::log "systemctl restart sshd.service"
	[[ -d ${web_root:-/var/www/html} ]] && rm -rf "${web_root:-/var/www/html}"/{public,logs,ssl}
	#[[ -f /usr/local/bin/vstacklet ]] && rm -f "/usr/local/bin/vstacklet"
	[[ -f /usr/local/bin/vs-backup ]] && rm -f "/usr/local/bin/vs-backup"
	#rm -rf "/var/log/vstacklet"
	if [[ -n ${install_list[*]} ]]; then
		for installed in "${install_list[@]}"; do
			# trunk-ignore(shellcheck/SC2046)
			DEBIAN_FRONTEND=noninteractive apt-get -y purge $(apt-cache depends "${installed}" | awk '{ print $2 }' | tr '\n' ' ') >>"${vslog}" 2>&1
			DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove "${installed}" >>"${vslog}" 2>&1
			vstacklet::log "apt-get -y autopurge ${installed}"
			vstacklet::log "apt-get -y autoremove ${installed}"
		done
		vstacklet::log "apt-get -y update"
		vstacklet::log "apt-get -y check"
		vstacklet::log "apt-get -fy install"
		vstacklet::log "apt-get -y autoclean"
		vstacklet::log "apt-get -y autoremove"
		vstacklet::log "apt-get -y autoclean"
	fi
	# @script-note: sources list locations
	#rm -rf "/etc/apt/sources.list.d/hhvm.list" >/dev/null 2>&1
	#rm -rf "/etc/apt/sources.list.d/nginx.list" >/dev/null 2>&1
	#rm -rf "/etc/apt/sources.list.d/varnishcache_varnish72.list" >/dev/null 2>&1
	#rm -rf "/etc/apt/sources.list.d/php-sury.list" >/dev/null 2>&1
	#rm -rf "/etc/apt/sources.list.d/mariadb.list" >/dev/null 2>&1
	#rm -rf "/etc/apt/sources.list.d/redis.list" >/dev/null 2>&1
	#rm -rf "/etc/apt/sources.list.d/postgresql.list" >/dev/null 2>&1
	if [[ -n ${nginx} ]]; then
		rm -rf "/etc/nginx-pre-vstacklet" "/etc/nignx" >/dev/null 2>&1
		apt-get -y autopurge nginx* >/dev/null 2>&1
		apt-get -y autoremove nginx* >/dev/null 2>&1
		rm -rf "/etc/apt/sources.list.d/nginx.list" "/etc/apt/keyrings/nginx.gpg" >/dev/null 2>&1
	fi
	if [[ -n ${varnish} ]]; then
		rm -rf "/etc/varnish" >/dev/null 2>&1
		apt-get -y autopurge varnish* >/dev/null 2>&1
		apt-get -y autoremove varnish* >/dev/null 2>&1
		rm -rf "/etc/apt/sources.list.d/varnishcache_varnish72.list" "/etc/apt/keyrings/varnishcache_varnish72-archive-keyring.gpg" >/dev/null 2>&1
	fi
	if [[ -n ${php} ]]; then
		apt-get -y autopurge php* >/dev/null 2>&1
		apt-get -y autoremove php* >/dev/null 2>&1
		rm -rf "/etc/apt/sources.list.d/php-sury.list" "/etc/apt/keyrings/php.gpg" >/dev/null 2>&1
	fi
	if [[ -n ${mariadb} ]]; then
		rm -rf "/var/lib/mysql" "/var/run/mysqld" "/etc/mysql" "/root/.my.cnf" >/dev/null 2>&1
		apt-get -y autopurge mariadb* >/dev/null 2>&1
		apt-get -y autoremove mariadb* >/dev/null 2>&1
		rm -rf "/etc/apt/sources.list.d/mariadb.list" "/etc/apt/keyrings/mariadb.gpg" >/dev/null 2>&1
	fi
	if [[ -n ${mysql} ]]; then
		rm -rf "/var/lib/mysql" "/var/run/mysql" "/var/run/mysqld" "/etc/mysql" "/root/.my.cnf" >/dev/null 2>&1
		apt-get -y autopurge mysql* >/dev/null 2>&1
		apt-get -y autoremove mysql* >/dev/null 2>&1
	fi
	if [[ -n ${phpmyadmin} ]]; then
		apt-get -y autopurge phpmyadmin* >/dev/null 2>&1
		apt-get -y autoremove phpmyadmin* >/dev/null 2>&1
	fi
	vstacklet::log "systemctl daemon-reload"
	# should the above purge be too aggressive, the following will restore the system to a working state.
	# the following commands are not logged, but are here to ensure that the system is
	# in a clean state after a failed installation attempt.
	vstacklet::log "apt-get -yf install --reinstall ssh openssh-server openssh-client sudo curl wget ca-certificates apt-transport-https lsb-release gnupg2 software-properties-common"
	vstacklet::shell::text::success "server setup has been rolled back. you may attempt to run the installer again."
	exit "${1:-1}"
}
trap 'vstacklet::clean::rollback' SIGINT

################################################################################
# @description: Calls functions in required order.
################################################################################
# the following functions are called in the order they are listed and
# are used for post-installation setup.
################################################################################
vstacklet::environment::init      #(1)
vstacklet::environment::functions #(2)
vstacklet::args::process "$@"     #(3)
[[ "$*" =~ "-h" ]] || [[ "$*" =~ "--help" ]] && vstacklet::help && exit 0
[[ "${www_permissions}" -eq 1 ]] && "${local_setup_dir}"/www-permissions.sh "--www_help" && exit 0
vstacklet::log::check                                 #(4)
vstacklet::apt::update                                #(5)
vstacklet::dependencies::install                      #(6)
vstacklet::environment::checkroot                     #(7)
vstacklet::environment::checkdistro                   #(8)
vstacklet::intro                                      #(9)
vstacklet::ask::continue                              #(10)
vstacklet::dependencies::array                        #(11)
vstacklet::base::dependencies                         #(12)
vstacklet::source::dependencies                       #(13)
vstacklet::bashrc::set                                #(14)
vstacklet::hostname::set                              #(15)
vstacklet::webroot::set                               #(16)
vstacklet::ssh::set                                   #(17)
vstacklet::ftp::set                                   #(18)
vstacklet::block::ssdp                                #(19)
vstacklet::sources::update                            #(20)
vstacklet::gpg::keys                                  #(21)
vstacklet::apt::update                                #(5)
vstacklet::locale::set                                #(22)
vstacklet::php::install                               #(23)
vstacklet::hhvm::install                              #(24)
vstacklet::nginx::install                             #(25)
vstacklet::varnish::install                           #(26)
vstacklet::permissions::adjust                        #(27)
vstacklet::ioncube::install                           #(28)
vstacklet::mariadb::install                           #(29)
vstacklet::mysql::install                             #(30)
vstacklet::postgre::install                           #(31)
vstacklet::redis::install                             #(32)
vstacklet::phpmyadmin::install                        #(33)
vstacklet::csf::install                               #(34)
vstacklet::cloudflare::csf                            #(34.1)
vstacklet::sendmail::install                          #(35)
vstacklet::wordpress::install                         #(36)
vstacklet::domain::ssl                                #(37)
vstacklet::clean::complete                            #(38)
vstacklet::message::complete && rm -rf ~/vstacklet.sh #(39)
################################################################################
