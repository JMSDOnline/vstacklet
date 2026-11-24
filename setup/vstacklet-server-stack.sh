#!/bin/bash
##################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 3.1.2239
# @description: Lightweight script to quickly install a LEMP stack with Nginx,
# Varnish, PHP 8.3/8.4/8.5 (PHP-FPM), OPCode Cache, IonCube Loader, MariaDB, Sendmail
# and more on a fresh Ubuntu 20.04/22.04 or Debian 11/12 server for
# website-based server applications.
#
# @project_name: vstacklet
#
# @path: setup/vstacklet-server-stack.sh
#
# @brief: This script is designed to be run on a fresh Ubuntu 20.04/22.04 or
# Debian 11/12 server. I have done my best to keep it tidy and with as much
# error checking as possible. Couple this with loads of comments and you should
# have a pretty good idea of what is going on. If you have any questions,
# comments, or suggestions, please feel free to open an issue on GitHub.
#
# vStacklet will install and configure the following:
# - NGinx 1.25.+ (mainline) | 1.18.+ (extras) (HTTP Server)
# - PHP 8.3, 8.4 (default) or 8.5 (FPM) with common extensions
# - MariaDB 10.11.+ (MySQL Database)
# - Varnish 7.4.x (HTTP Cache)
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
# - [vstacklet::environment::store_flags_args()](#vstackletenvironmentstore_flags_args)
# - [vstacklet::environment::functions()](#vstackletenvironmentfunctions)
# - [vstacklet::log::check()](#vstackletlogcheck)
# - [vstacklet::apt::update()](#vstackletaptupdate)
# - [vstacklet::dependencies::install()](#vstackletdependenciesinstall)
#    - [return codes](#return-codes-1)
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
# - [vstacklet::redis::install()](#vstackletredisinstall)
#   - [options](#options-13)
#   - [arguments](#arguments-10)
#   - [return codes](#return-codes-18)
#   - [examples](#examples-13)
# - [vstacklet::phpmyadmin::install()](#vstackletphpmyadmininstall)
#   - [options](#options-14)
#   - [arguments](#arguments-11)
#   - [return codes](#return-codes-19)
#   - [examples](#examples-14)
#   - [options](#options-15)
#   - [arguments](#arguments-12)
#   - [return codes](#return-codes-20)
#   - [examples](#examples-15)
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
#   - [arguments](#arguments-12)
#   - [return codes](#return-codes-23)
#   - [examples](#examples-20)
# - [vstacklet::clean::complete()](#vstackletcleancomplete)
# - [vstacklet::message::complete()](#vstackletmessagecomplete)
# - [vstacklet::error::display()](#vstackleterrordisplay)
# - [vstacklet::rollback()](#vstackletrollback)
# - [vstacklet::update::check()](#vstackletupdatecheck)
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
##################################################################################
# shellcheck disable=1091,2068,2119,2249,2312
# @script-note: the one default PHP version and the tested range; the version checks and every template use these
# @script-note: where the bootstrap clones vStacklet; fixed, so -V, the rollback and the update check never depend on install order
declare -gr vstacklet_base_path="/opt/vstacklet"
declare -gr DEFAULT_PHP="8.4"
declare -gar SUPPORTED_PHP=("8.3" "8.4" "8.5")
# @script-note: written at the end of a completed 4.x install; its presence means the server is not fresh
declare -gr VSTACKLET_MARKER="/etc/vstacklet/installed"
# >>> vstacklet gate: this block is kept identical in setup/vstacklet.sh and setup/vstacklet-server-stack.sh
##################################################################################
# @name: vstacklet::gate (0)
# @description: Runs before anything on the server is changed: root, the release and its support dates, the architecture.
#
# Support dates come from the vendors' own pages, read 2026-11-23:
# - Debian: https://www.debian.org/releases/bookworm/ , https://www.debian.org/releases/trixie/ , https://wiki.debian.org/LTS
# - Ubuntu: https://ubuntu.com/about/release-cycle (states a month only; the gate uses the last day of that month)
# - PHP:    https://www.php.net/supported-versions.php
# A release counts as supported until its free security support ends: for Debian the end of Debian LTS (a Debian
# project), for Ubuntu the end of standard support. Paid extended support (Freexian ELTS for Debian, Ubuntu ESM) is
# not counted. A Debian release past its regular security support but inside Debian LTS installs with a notice.
# Row: id|version|codename|regular security end|free security end|end as the vendor states it|who supports it until then
##################################################################################
declare -ga VSTACKLET_GATE_RELEASES=(
	"debian|12|bookworm|2026-07-11|2028-06-30|30 June 2028|Debian LTS"
	"debian|13|trixie|2028-08-09|2030-06-30|30 June 2030|Debian LTS"
	"ubuntu|24.04|noble|2029-05-31|2029-05-31|May 2029 (month only)|Ubuntu standard support"
	"ubuntu|26.04|resolute|2031-05-31|2031-05-31|May 2031 (month only)|Ubuntu standard support"
)
# Row: PHP version|end of active support|end of security support
declare -ga VSTACKLET_GATE_PHP=(
	"8.3|2025-12-31|2027-12-31"
	"8.4|2026-12-31|2028-12-31"
	"8.5|2027-12-31|2029-12-31"
)
vstacklet::gate::refuse() {
	printf 'vStacklet: %s\n' "$@" >&2
	printf 'vStacklet: the install has stopped before any change was made to this server.\n' >&2
	exit 1
}
vstacklet::gate::notice() {
	printf 'vStacklet notice: %s\n' "$@" >&2
}
vstacklet::gate::system() {
	local key value os_id="" os_version="" os_codename="" row r_id r_ver r_code r_regular r_free r_shown r_who today arch
	[[ ${EUID} -eq 0 ]] || vstacklet::gate::refuse "run the installer as root."
	[[ -r /etc/os-release ]] || vstacklet::gate::refuse "cannot read /etc/os-release, so the release cannot be checked."
	# @script-note: read three keys only; the file is never sourced
	while IFS='=' read -r key value; do
		value="${value%\"}" && value="${value#\"}"
		case "${key}" in
		ID) os_id="${value}" ;;
		VERSION_ID) os_version="${value}" ;;
		VERSION_CODENAME) os_codename="${value}" ;;
		esac
	done </etc/os-release
	today="$(date +%F)"
	for row in "${VSTACKLET_GATE_RELEASES[@]}"; do
		IFS='|' read -r r_id r_ver r_code r_regular r_free r_shown r_who <<<"${row}"
		[[ ${os_id} == "${r_id}" && ${os_version} == "${r_ver}" ]] || continue
		[[ -z ${os_codename} || ${os_codename} == "${r_code}" ]] || vstacklet::gate::refuse "${os_id} ${os_version} reports the codename '${os_codename}', expected '${r_code}'; the release cannot be confirmed."
		if [[ ${today} > "${r_free}" ]]; then
			vstacklet::gate::refuse "${os_id} ${os_version} reached the end of its free security support (${r_who}, ${r_shown}). Rebuild the server on a supported release: Debian 12 or 13, Ubuntu 24.04 or 26.04."
		fi
		[[ ${today} > "${r_regular}" ]] && vstacklet::gate::notice "${os_id} ${os_version} has left regular security support and is covered by ${r_who} until ${r_shown}, for fewer packages and architectures. Plan a move to a newer release."
		arch="$(dpkg --print-architecture 2>/dev/null)"
		[[ ${arch} == "amd64" || ${arch} == "arm64" ]] || vstacklet::gate::refuse "the architecture '${arch:-unknown}' is not supported (amd64 or arm64)."
		declare -g distro codename vstacklet_arch="${arch}"
		codename="${r_code}"
		[[ ${r_id} == "debian" ]] && distro="Debian"
		[[ ${r_id} == "ubuntu" ]] && distro="Ubuntu"
		return 0
	done
	vstacklet::gate::refuse "${os_id:-unknown} ${os_version:-unknown} is not supported. Supported: Debian 12 and 13, Ubuntu 24.04 and 26.04. For Debian 11 or Ubuntu 20.04 and 22.04, the last 3.x release is the tag v3.1.2239, which is no longer maintained."
}
# <<< vstacklet gate
# @script-note: interim, until the 4.0 package sources are written: on Debian 13 and Ubuntu the 3.x sources code would rewrite the release's own sources, so this build stops there before any change
vstacklet::gate::interim() {
	[[ ${1-} == "bookworm" ]] || vstacklet::gate::refuse "this development build of vStacklet 4.0 installs on Debian 12 only for now; Debian 13 and Ubuntu 24.04 and 26.04 follow before the 4.0 release."
}
##################################################################################
# @name: vstacklet::environment::init (1)
# @description: Setup the environment and set variables. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L184-L205)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @break
##################################################################################
vstacklet::environment::init() {
	shopt -s extglob
	declare -g vstacklet_base_path server_ip local_setup_dir local_php8_dir local_varnish_dir
	server_ip=$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
	# @script-note: vstacklet directories
	local_setup_dir="${vstacklet_base_path:=/opt/vstacklet}/setup"
	local_php8_dir="/opt/vstacklet/config/php8"
	local_nginx_dir="/opt/vstacklet/config/nginx"
	local_varnish_dir="/opt/vstacklet/config/varnish"
	# @script-note: record the server's state before the first change (afresh on every install that passed the gate), for vstacklet --rollback
	vstacklet::rollback::baseline || { vstacklet::shell::text::error "could not record the server's state in /root/vstacklet/baseline; nothing was changed." && exit 1; }
	# @script-note: from here on the installer changes the server; a failure after this point means a rollback or a rebuild
	declare -gi vstacklet_changes_started=1
	# @script-note: create vstacklet directories
	mkdir -p "${vstacklet_base_path}/setup_temp"    # temporary setup directory - stores default files edited by vStacklet
	mkdir -p "${vstacklet_base_path}/config/system" # system configuration directory - stores dependencies, keys, and other system files
	# @script-note: script start time
	vstacklet_start_time=$(date +%s)
	# @script-note: check if nginx is installed
	declare -gi nginx_installed vstacklet_installed
	nginx_installed=$(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed")
	vstacklet_installed=$(find /opt/vstacklet/config/system -maxdepth 1 -type f -name ".install_complete" | wc -l)
}

##################################################################################
# @name: vstacklet::args::info
# @description: Prints the help or the version and exits when -h or -V is given. Runs before the gate, since printing changes nothing on the server.
##################################################################################
vstacklet::args::info() {
	local a
	for a in "$@"; do
		case "${a}" in
		-h | --help) vstacklet::help::display ;;
		-V | --version) vstacklet::version::display ;;
		esac
	done
	return 0
}

##################################################################################
# @name: vstacklet::args::process (3)
# @description: Process the options and values passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L252-L505)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
#
# #### options:
# | Short | Long                       | Description
# | ----- | -------------------------- | ------------------------------------------
# | -h    | --help                     | show help
# | -V    | --version                  | show version
# | -e    | --email                    | mail address to use for the Let's Encrypt SSL certificate
# | -ftp  | --ftp_port                 | port to use for the FTP server
# | -ssh  | --ssh_port                 | port to use for the SSH server
# | -http | --http_port                | port to use for the HTTP server
# | -https| --https_port               | port to use for the HTTPS server
# | -ioncube | --ioncube               | install IonCube Loader
# | -hn   | --hostname                 | hostname to use for the server
# | -d    | --domain                   | domain name to use for the server
# | -php  | --php                      | PHP version to install (8.3, 8.4, 8.5; default 8.4)
# | -hhvm | --hhvm                     | refused: HHVM is no longer supported
# | -nginx| --nginx                    | install Nginx
# | -varnish | --varnish               | install Varnish
# | -varnishP | --varnish_port         | port to use for the Varnish server
# | -mariadb | --mariadb               | install MariaDB
# | -mariadbP | --mariadb_port         | port to use for the MariaDB server
# | -mariadbU | --mariadb_user         | user to use for the MariaDB server<br>Avoid using 'root' as the username
# | -mariadbPw | --mariadb-password    | password to use for the MariaDB user
# | -pma | --phpmyadmin                | install phpMyAdmin
# | -csf | --csf                       | refused: CSF is no longer supported
# | -csfCf | --csf_cloudflare          | refused: CSF is no longer supported
# | -sendmail | --sendmail              | install Sendmail
# | -sendmailP | --sendmail_port        | port to use for the Sendmail server
# | --dns | --dns_provider             | DNS provider for SSL cert verification (e.g., cloudflare)
# | -wr | --web_root				   | web root to use for the server
# | -wp | --wordpress				   | install WordPress
# | -r | --reboot					   | reboot the server after installation
# | --rollback						   | undo an install: restore the state recorded before its first change
# | --check_update					   | check the installed branch for a newer 4.x release
#
# @example: vstacklet --help
# @example: vstacklet -e "your@email.com" -ftp "2133" -ssh "2244" -hn "yourhostname" -php "8.3" -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "db_user" -mariadbPw "db_password" -pma -wr "/var/www/html/vsapp" -wp
# @example: vstacklet -e "your@email.com" -ftp "2121" -ssh "2222" -http "8080" -d "yourdomain.com" -php "8.4" -nginx -varnish -varnishP "80" -mariadb -mariadbU "db_user" -mariadbPw "db_password" -sendmail -wr "/var/www/html/vsapp" -wp --reboot
# @example: vstacklet -e "your@email.com" -d "example.com" -php "8.3" -nginx -mariadb -mariadbU "db_user" -mariadbPw "db_password" --dns "cloudflare"
# @null
# @break
##################################################################################
vstacklet::args::process() {
	# @script-note: strict option values (4.0): every option is matched exactly, every value-taking option needs a
	# value that is present and is not another option, and every value is checked against a strict pattern before
	# it is stored. Numbers are checked as text before any integer assignment, so a value is never evaluated as
	# arithmetic (bash evaluates the value of an integer variable, which can run commands).
	while [[ $# -gt 0 ]]; do
		case "${1}" in
		-V | --version)
			vstacklet::version::display
			;;
		-r | --reboot)
			declare -gi setup_reboot="1"
			shift
			;;
		-h | --help)
			vstacklet::help::display
			;;
		-csf | --csf | -csfCf | --csf_cloudflare)
			vstacklet::shell::text::error "CSF is no longer supported by vStacklet 4.0." && exit 1
			;;
		-d | --domain)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::fqdn "$1" "$2"
			declare -gi domain_ssl=1
			declare -g domain="${2}"
			shift 2
			;;
		-e | --email)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::email "$1" "$2"
			declare -g email="${2}"
			shift 2
			;;
		-ftp | --ftp_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi ftp_port=$((10#$2))
			shift 2
			;;
		-hhvm | --hhvm)
			vstacklet::shell::text::error "HHVM is no longer supported. Use -php (${SUPPORTED_PHP[*]}; default ${DEFAULT_PHP})." && exit 1
			;;
		-hn | --hostname)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::fqdn "$1" "$2"
			declare -g hostname="${2}"
			shift 2
			;;
		-https | --https_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi https_port=$((10#$2))
			shift 2
			;;
		-http | --http_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi http_port=$((10#$2))
			shift 2
			;;
		-ioncube | --ioncube)
			declare -gi ioncube="1"
			shift
			;;
		-mariadb | --mariadb)
			declare -gi mariadb="1"
			shift
			;;
		-mariadbU | --mariadb_user)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::dbuser "$1" "$2"
			declare -g mariadb_user="${2}"
			shift 2
			;;
		-mariadbPw | --mariadb_password | --mariadb-password)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::password "$1" "$2"
			declare -g mariadb_password="${2}"
			shift 2
			;;
		-mariadbP | --mariadb_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi mariadb_port=$((10#$2))
			shift 2
			;;
		-mysql | --mysql)
			declare -gi mysql="1"
			shift
			;;
		-mysqlU | --mysql_user)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::dbuser "$1" "$2"
			declare -g mysql_user="${2}"
			shift 2
			;;
		-mysqlPw | --mysql_password)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::password "$1" "$2"
			declare -g mysql_password="${2}"
			shift 2
			;;
		-mysqlP | --mysql_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi mysql_port=$((10#$2))
			shift 2
			;;
		-nginx | --nginx)
			declare -gi nginx="1"
			shift
			;;
		-postgre | --postgresql)
			declare -gi postgresql="1"
			shift
			;;
		-postgreU | --postgresql_user)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::dbuser "$1" "$2"
			declare -g postgresql_user="${2}"
			shift 2
			;;
		-postgrePw | --postgresql_password)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::password "$1" "$2"
			declare -g postgresql_password="${2}"
			shift 2
			;;
		-postgreP | --postgresql_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi postgresql_port=$((10#$2))
			shift 2
			;;
		-pma | --phpmyadmin)
			declare -gi phpmyadmin="1"
			shift
			;;
		-php | --php)
			vstacklet::args::need_value "$1" $# "${2-}"
			declare -g php="${2}"
			shift 2
			;;
		-redis | --redis)
			declare -gi redis="1"
			shift
			;;
		-redisPw | --redis_password)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::password "$1" "$2"
			declare -g redis_password="${2}"
			shift 2
			;;
		-redisP | --redis_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi redis_port=$((10#$2))
			shift 2
			;;
		-sendmail | --sendmail)
			declare -gi sendmail="1"
			shift
			;;
		-sendmailP | --sendmail_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi sendmail_port=$((10#$2))
			shift 2
			;;
		--dns | --dns_provider)
			vstacklet::args::need_value "$1" $# "${2-}"
			[[ ${2} != "cloudflare" ]] && vstacklet::shell::text::error "currently only 'cloudflare' is supported as DNS provider." && exit 1
			declare -gi dns_verification="1"
			declare -g dns_provider="${2}"
			shift 2
			;;
		-ssh | --ssh_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi ssh_port=$((10#$2))
			shift 2
			;;
		-varnish | --varnish)
			declare -gi varnish="1"
			shift
			;;
		-varnishP | --varnish_port)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi varnish_port=$((10#$2))
			shift 2
			;;
		-wp | --wordpress)
			declare -gi wordpress="1"
			shift
			;;
		-wr | --web_root)
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::webroot "$1" "$2"
			declare -g web_root="${2}"
			shift 2
			;;
		--rollback)
			declare -gi rollback="1" && vstacklet::rollback
			shift
			;;
		--check_update)
			vstacklet::update::check
			;;
		*)
			invalid_option+=("$1")
			shift
			;;
		esac
	done
	[[ ${#invalid_option[@]} -gt 0 ]] && vstacklet::shell::text::error "invalid option(s): ${invalid_option[*]}" && exit 1
	# @script-note: run sanity checks on the options provided
	[[ -n ${domain} && -z ${email} ]] && vstacklet::shell::text::error "an email is needed to register with Let's Encrypt. please set an email with \`-e\`." && exit 1
	[[ -n ${mariadb} && -n ${mysql} ]] && vstacklet::shell::text::error "mariadb and mysql cannot be installed together. choose either mariadb or mysql." && exit 1
	[[ -n ${sendmail} && -z ${email} ]] && vstacklet::shell::text::error "an email is needed to register the server aliases. please set an email with \`-e your@email.com\`." && exit 1
	if [[ -n ${wordpress} ]]; then
		[[ (-z ${mariadb}) && (-z ${mysql}) && (-z ${postgresql}) ]] && vstacklet::shell::text::error "WordPress requires a database to be installed." && exit 1
		[[ (-z ${nginx}) && (-z ${varnish}) ]] && vstacklet::shell::text::error "WordPress requires a webserver to be installed." && exit 1
	fi
	if [[ -n ${domain_ssl} ]]; then
		[[ -z ${email} ]] && vstacklet::shell::text::error "please provide an email address with \`-e\`." && exit 1
		[[ -z ${nginx} && ${nginx_installed} -eq 0 ]] && vstacklet::shell::text::error "nginx is required to install an SSL certificate. please install nginx with \`-nginx\`." && exit 1
	fi
	if [[ -n ${dns_verification} ]]; then
		[[ -z ${domain_ssl} ]] && vstacklet::shell::text::error "DNS verification requires a domain to be specified with \`-d\`." && exit 1
		[[ ${dns_provider} == "cloudflare" && -z ${CF_Token} ]] && declare -gi cf_token_required="1"
	fi
	# @script-note: PHP is the default version unless -php names one; only an exact version in the tested range is accepted
	[[ -z ${php} ]] && declare -g php="${DEFAULT_PHP}"
	declare php_ok="" v
	for v in "${SUPPORTED_PHP[@]}"; do [[ ${php} == "${v}" ]] && php_ok=1; done
	if [[ -z ${php_ok} ]]; then
		vstacklet::shell::text::error "PHP '${php}' is not in the tested range (${SUPPORTED_PHP[*]}; default ${DEFAULT_PHP}). Versions newer than ${SUPPORTED_PHP[-1]} are not tested yet; older ones are no longer supported." && exit 1
	fi
	# @script-note: no two services on one port (the web ports count with their defaults when a web server is installed)
	declare -A port_owner=()
	declare name port
	for name in ssh_port ftp_port http_port https_port varnish_port mariadb_port mysql_port postgresql_port redis_port sendmail_port; do
		port="${!name}"
		if [[ -z ${port} && (-n ${nginx} || -n ${varnish}) ]]; then
			[[ ${name} == "http_port" ]] && port=80
			[[ ${name} == "https_port" ]] && port=443
			[[ ${name} == "varnish_port" && -n ${varnish} ]] && port=6081
		fi
		[[ -z ${port} ]] && continue
		if [[ -n ${port_owner[${port}]} ]]; then
			vstacklet::shell::text::error "port ${port} is set for both ${port_owner[${port}]} and ${name}; each service needs its own port." && exit 1
		fi
		port_owner[${port}]="${name}"
	done
}

##################################################################################
# @name: vstacklet::args::need_value (3.b)
# @description: Strict option values. Exits unless the option has a value that is present, not empty and not another option.
# @param: $1 - the option, $2 - the number of words left including the option, $3 - the value
##################################################################################
vstacklet::args::need_value() {
	if [[ $2 -lt 2 || -z $3 || $3 == -* ]]; then
		vstacklet::shell::text::error "option '$1' needs a value." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::port (3.c)
# @description: Exits unless the value is a port number from 1 to 65535, checked as text before it is used as a number.
##################################################################################
vstacklet::args::port() {
	if [[ ! $2 =~ ^[0-9]{1,5}$ ]] || ((10#$2 < 1 || 10#$2 > 65535)); then
		vstacklet::shell::text::error "option '$1': '$2' is not a port number from 1 to 65535." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::fqdn (3.d)
# @description: Exits unless the value is a fully qualified domain name: letters, digits and inner hyphens per label, a letter-only top level, 253 characters at most.
##################################################################################
vstacklet::args::fqdn() {
	local re='^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$'
	if [[ ${#2} -gt 253 || ! $2 =~ ${re} ]]; then
		vstacklet::shell::text::error "option '$1': '$2' is not a valid domain name (for example: example.com)." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::email (3.e)
# @description: Exits unless the value is a plain address (local part of letters, digits and . _ % + -, then a domain name).
##################################################################################
vstacklet::args::email() {
	local re='^[A-Za-z0-9._%+-]{1,64}@([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$'
	if [[ ${#2} -gt 254 || ! $2 =~ ${re} ]]; then
		vstacklet::shell::text::error "option '$1': '$2' is not a valid email address." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::dbuser (3.f)
# @description: Exits unless the value is a database user name (a lowercase letter or underscore, then up to 31 lowercase letters, digits or underscores) other than root.
##################################################################################
vstacklet::args::dbuser() {
	local re='^[a-z_][a-z0-9_]{0,31}$'
	if [[ ! $2 =~ ${re} ]]; then
		vstacklet::shell::text::error "option '$1': '$2' is not a valid user name (lowercase letters, digits and underscores, 32 at most)." && exit 1
	fi
	if [[ $2 == "root" ]]; then
		vstacklet::shell::text::error "option '$1': the database user cannot be 'root'; choose another name." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::password (3.g)
# @description: Exits unless the value is 8 to 128 characters from letters, digits and ! # % * + , . : ; = ? @ ^ _ ~ -. Quotes, backslashes, dollar signs, spaces and other shell or SQL characters are refused until every secret is passed on stdin.
##################################################################################
vstacklet::args::password() {
	local re='^[A-Za-z0-9!#%*+,.:;=?@^_~-]{8,128}$'
	if [[ ! $2 =~ ${re} ]]; then
		vstacklet::shell::text::error "option '$1': the password must be 8 to 128 characters from letters, digits and ! # % * + , . : ; = ? @ ^ _ ~ -" && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::webroot (3.h)
# @description: Exits unless the value is a folder under /var/www/ or /srv/ whose every part starts with a letter or digit and holds only letters, digits and . _ - (no .., no hidden parts, no system folders).
##################################################################################
vstacklet::args::webroot() {
	local re='^/(var/www|srv)(/[A-Za-z0-9][A-Za-z0-9._-]*)+$'
	if [[ ${#2} -gt 200 || ! $2 =~ ${re} ]]; then
		vstacklet::shell::text::error "option '$1': '$2' is not an allowed web root; use a folder under /var/www/ or /srv/ (for example: /var/www/html/vsapp)." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::gate::install (3.i)
# @description: Runs after the options are read and before anything on the server is changed: the PHP version's support dates, ionCube on arm64, fresh servers only (no earlier vStacklet install, no apache2, no nginx site of its own, the web ports free).
##################################################################################
vstacklet::gate::install() {
	local row r_ver r_active r_security today f p
	today="$(date +%F)"
	for row in "${VSTACKLET_GATE_PHP[@]}"; do
		IFS='|' read -r r_ver r_active r_security <<<"${row}"
		[[ ${php} == "${r_ver}" ]] || continue
		[[ ${today} > "${r_security}" ]] && vstacklet::gate::refuse "PHP ${php} reached the end of its security support on ${r_security}; choose a newer version with -php."
		[[ ${today} > "${r_active}" ]] && vstacklet::gate::notice "PHP ${php} receives security fixes only (until ${r_security}); a newer version gets bug fixes too."
	done
	[[ -n ${ioncube} && ${vstacklet_arch} == "arm64" ]] && vstacklet::gate::refuse "ionCube Loader is not offered on arm64 by this installer; run without -ioncube."
	# @script-note: fresh servers only
	for f in "${VSTACKLET_MARKER}" /opt/vstacklet/config/system/.install_complete /var/log/vstacklet; do
		[[ -e ${f} ]] || continue
		if [[ -f /root/vstacklet/baseline/complete ]]; then
			vstacklet::gate::refuse "an earlier vStacklet install or install attempt was found (${f}). vStacklet 4 installs on fresh servers only: run vstacklet --rollback to undo it, or rebuild the server."
		fi
		vstacklet::gate::refuse "an earlier vStacklet install was found (${f}) with no install record to roll back. vStacklet 4 installs on fresh servers only: rebuild the server, or see the upgrade checklist in the README."
	done
	if [[ -n ${nginx} || -n ${varnish} ]]; then
		[[ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null) == *"ok installed"* ]] && vstacklet::gate::refuse "apache2 is installed. vStacklet installs nginx on fresh servers only."
		[[ -e /etc/nginx ]] && vstacklet::gate::refuse "nginx is already installed on this server (/etc/nginx). vStacklet installs nginx on fresh servers only."
		command -v ss >/dev/null 2>&1 || vstacklet::gate::refuse "the ss command (iproute2) is missing, so the web ports cannot be checked."
		for p in "${http_port:-80}" "${https_port:-443}" ${varnish:+"${varnish_port:-6081}"}; do
			[[ -n $(ss -Hltn "sport = :${p}" 2>/dev/null) ]] && vstacklet::gate::refuse "port ${p} is already in use on this server."
		done
	fi
	return 0
}

##################################################################################
# @name: vstacklet::environment::store_flags_args (3.a)
# @description: Store the flags and arguments to a file for rollback if needed.  [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L517-L535)
#
# @param: command_string
#
# @example: vstacklet::environment::store_flags_args "command_string"
# @null
# @break
##################################################################################
vstacklet::environment::store_flags_args() {
	local timestamp flags_args_file
	timestamp=$(date +%Y-%m-%d-%H-%M-%S)
	flags_args_file="/root/vstacklet/setup_temp/vstacklet_install_command.${timestamp}.txt"
	local command_string=""
	# @script-note: ensure the directory structure exists
	mkdir -p "$(dirname "${flags_args_file}")"
	# @script-note: construct the command string
	for arg in "$@"; do
		command_string+=" ${arg}"
	done
	# @script-note: mask the mariadb and mysql passwords
	command_string=$(echo "${command_string}" | sed -E -e 's/(-mariadbPw|--mariadb_password|--mariadb-password|-mysqlPw|--mysql_password|-postgrePw|--postgresql_password|-redisPw|--redis_password)[[:space:]]+[^[:space:]]+/\1 ********/g')
	# @script-note: store the command string
	echo "Command:${command_string}" >"${flags_args_file}"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::yellow "Command string has been stored at: ${flags_args_file}"
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L544-L727)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
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
	# shellcheck disable=SC2120
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

##################################################################################
# The following three functions are used for the progress spinner.
##################################################################################
# create the spinner
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
# start the spinner and save the function's PID
vs::stat::progress::start() {
	declare -g pg_pid
	vs::stat::progress &
	pg_pid=$!
	# @script-note: only on exit; INT, TERM and HUP stay with the installer's own trap, which also stops the spinner
	trap 'kill -9 ${pg_pid} 2>/dev/null' EXIT
}
# stop the spinner and remove the function's PID
vs::stat::progress::stop() {
	vstacklet::shell::icon::check::green "done"
	kill -9 ${pg_pid} >/dev/null 2>&1
	unset pg_pid
}

##################################################################################
# @name: vstacklet::log::check (4)
# @description: Check if the log file exists and create it if it doesn't. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L741-L761)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
#
# notes:
# - one log per run: /var/log/vstacklet/vstacklet.<date-time>.<pid>.log (mode 600); earlier logs are kept
# - vstacklet::log takes a command as separate words ("$@"), never a string, and stops the install when it fails;
#   vstacklet::log::try logs and returns the status for the few calls whose failure is tolerated today
# @noargs
# @nooptions
# @break
##################################################################################
vstacklet::log::check() {
	vstacklet::shell::text::white "checking log file ... "
	declare -g log_file vslog
	# @script-note: one log per run, kept after the run (an earlier run's log is never removed), readable by root only
	install -d -m 0700 /var/log/vstacklet || { vstacklet::shell::text::error "cannot create /var/log/vstacklet"; exit 1; }
	log_file="/var/log/vstacklet/vstacklet.$(date +%Y%m%d-%H%M%S).$$.log"
	(umask 077 && : >"${log_file}") || { vstacklet::shell::text::error "cannot create the log file ${log_file}"; exit 1; }
	vslog="${log_file}"
	vstacklet::shell::text::yellow "output is being sent to ${log_file}"
	# @script-note: run one command given as separate words, never as a string, so arguments are not split or
	# globbed again and shell operators are never passed in. Returns the command's own exit status.
	# usage: vstacklet::log apt-get -y install "${package}"
	# A failed command stops the install (fail closed): the error names the command and its exit status.
	vstacklet::log() {
		local rc
		vstacklet::log::try "$@"
		rc=$?
		if [[ ${rc} -ne 0 ]]; then
			declare -g vstacklet_failed_step="$* (exit ${rc})"
			vstacklet::error::display log
		fi
		return 0
	}
	# The same, for the few calls whose failure is tolerated today; it logs and returns the status, never stops.
	# Each one goes when its part of the installer is rewritten.
	vstacklet::log::try() {
		[[ $# -gt 0 ]] || return 2
		if [[ -z ${verbosity} ]]; then
			"$@" >>"${log_file}" 2>&1
		else
			"$@" 2>&1 | tee -a "${log_file}"
			return "${PIPESTATUS[0]}"
		fi
	}
}

##################################################################################
# @name: vstacklet::apt::update (5)
# @description: Updates server via apt-get. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L772-L781)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::apt::update() {
	vstacklet::shell::text::white "running apt update ... "
	# @script-note: a repository that fails to fetch is an error (--error-on=any), not a silent skip
	DEBIAN_FRONTEND=noninteractive apt-get -yqq --error-on=any -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >>"${vslog:-/dev/null}" 2>&1 || vstacklet::error::display apt
	if [[ -n ${apt_upgrade} ]]; then
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" autoremove >/dev/null 2>&1
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" autoclean >/dev/null 2>&1
	fi
	unset apt_upgrade
}

##################################################################################
# @name: vstacklet::dependencies::install (6)
# @description: Installs dependencies for vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L793-L815)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
# @return_code: 3 - failed to install script dependencies.
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
		vstacklet::log apt-get -y install "${install}" --allow-unauthenticated || vstacklet::error::display 3
		install_list+=("${install}")
	done
	clear
}

##################################################################################
# @name: vstacklet::intro (9)
# @description: Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L857-L880)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
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
	vstacklet::shell::text::white "https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet installation log can be found at:"
	vstacklet::shell::text::yellow "${vslog}"
	vstacklet::shell::misc::nl
}

# shall we continue? function (10)
vstacklet::ask::continue() {
	vstacklet::shell::text::green "Press any key to continue $(tput setaf 7)(${shell_reset}$(tput setaf 3)ctrl+C${shell_reset} $(tput setaf 7)on PC or $(tput setaf 7)${shell_reset}$(tput setaf 3)⌘+C${shell_reset} $(tput setaf 7)on Mac to ${shell_reset}$(tput setaf 1)exit${shell_reset}$(tput setaf 7)) ..."
	read -r -n 1
	vstacklet::shell::misc::nl
}

################################################################################
# @name: vstacklet::dependencies::array (11)
# @description: Handles various dependencies for the vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L909-L938)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
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
	declare -ga php_dependencies=("php${php}-fpm" "php${php}-zip" "php${php}-cgi" "php${php}-cli" "php${php}-common" "php${php}-curl" "php${php}-dev" "php${php}-gd" "php${php}-bcmath" "php${php}-gmp" "php${php}-imap" "php${php}-intl" "php${php}-ldap" "php${php}-mbstring" "php${php}-opcache" "php${php}-pspell" "php${php}-readline" "php${php}-soap" "php${php}-xml" "php${php}-imagick" "php${php}-msgpack" "php${php}-igbinary" "libmcrypt-dev" "mcrypt" "libmemcached-dev" "php-memcached" "php${php}-ssh2")
	[[ -n ${redis} ]] && php_dependencies+=("php${php}-redis")
	[[ -n ${mariadb} || -n ${mysql} ]] && php_dependencies+=("php${php}-mysql")
	# @script-note: install nginx dependencies
	declare -ga nginx_dependencies=("nginx")
	# @script-note: install varnish dependencies
	declare -ga varnish_dependencies=("varnish")
	# @script-note: install mariadb dependencies
	declare -ga mariadb_dependencies=("mariadb-server" "mariadb-client")
	# @script-note: install mysql dependencies
	declare -ga mysql_dependencies=("mysql-server" "mysql-client" "libmysqlclient-dev")
	# @script-note: install postgresql dependencies
	declare -ga postgresql_dependencies=("postgresql" "postgresql-contrib")
	# @script-note: install redis dependencies
	declare -ga redis_dependencies=("redis")
	# @script-note: install phpmyadmin dependencies
	declare -ga phpmyadmin_dependencies=("phpmyadmin")
	# @script-note: install sendmail dependencies
	declare -ga sendmail_dependencies=("sendmail" "sendmail-bin" "sendmail-cf" "mailutils" "libsasl2-modules")
}

################################################################################
# @name: vstacklet::base::dependencies (12)
# @description: Handles base dependencies for the vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L948-L973)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @return_code: 4 - failed to install base dependencies.
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
		DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 4
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
# @description: Installs required sources for vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L985-L1012)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
# @return_code: 5 - failed to install source dependencies.
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
		vstacklet::log apt-get -y install "${install}" --allow-unauthenticated || vstacklet::error::display 5
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
# @description: Set ~/.bashrc and ~/.profile for vstacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1023-L1031)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
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
# @description: Set system hostname. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1052-L1066)
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
# @return: 6 - failed to set hostname
# @break
##################################################################################
vstacklet::hostname::set() {
	if [[ -n ${hostname} && -z ${domain} ]]; then
		vstacklet::shell::text::white "setting hostname to ${hostname} ... "
		hostnamectl set-hostname "${hostname}" >>"${vslog}" 2>&1 || vstacklet::error::display 6
		vstacklet::shell::misc::nl
	elif [[ -n ${domain} && -z ${hostname} ]]; then
		vstacklet::shell::text::white "setting hostname to ${domain} ... "
		hostnamectl set-hostname "${domain}" >>"${vslog}" 2>&1 || vstacklet::error::display 6
		vstacklet::shell::misc::nl
	else
		vstacklet::shell::text::white "setting hostname to $(hostname --fqdn) ... "
		hostnamectl set-hostname "$(hostname --fqdn)" >>"${vslog}" 2>&1 || vstacklet::error::display 6
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::webroot::set (16)
# @description: Set main web root directory. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1088-L1095)
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
#   e.g. `/var/www/html/vsapp/{public,logs,ssl}`
# @option: $1 - `-wr | --web_root` (optional) (takes one argument)
# @arg: $2 - `[web_root_directory]` - (optional) (default: /var/www/html/vsapp)
# @example: vstacklet -wr /var/www/mydirectory
# @example: vstacklet --web_root /srv/www/mydirectory
# @break
##################################################################################
vstacklet::webroot::set() {
	if [[ -n ${web_root} ]]; then
		vstacklet::shell::text::white "setting web root directory to ${web_root:-/var/www/html/vsapp} ... "
		mkdir -p "${web_root:-/var/www/html/vsapp}"/{public,logs,ssl}
		vstacklet::log chown -R www-data:www-data "${web_root:-/var/www/html/vsapp}"
		vstacklet::log chmod -R 755 "${web_root:-/var/www/html/vsapp}"
	fi
}

##################################################################################
# @name: vstacklet::ssh::set (17)
# @description: Set ssh port to custom port (if nothing is set, default port is 22) [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1109-L1116)
# @option: $1 - `-ssh | --ssh_port` (optional) (takes one argument)
# @arg: $2 - `[port]` (default: 22) - the port to set for ssh
# @example: vstacklet -ssh 2222
# @example: vstacklet --ssh_port 2222
# @null
# @return_code: 7 - failed to set SSH port.
# @return_code: 8 - failed to restart SSH daemon service.
# @break
##################################################################################
vstacklet::ssh::set() {
	if [[ -n ${ssh_port} ]]; then
		vstacklet::shell::text::white "setting ssh port to ${ssh_port:-22} ... "
		cp -f /etc/ssh/sshd_config "${vstacklet_base_path}/config/system/sshd_config"
		sed -i "s/^.*Port .*/Port ${ssh_port:-22}/g" /etc/ssh/sshd_config || vstacklet::error::display 7
		vstacklet::log systemctl restart sshd || vstacklet::error::display 8
	fi
}

##################################################################################
# @name: vstacklet::ftp::set (18)
# @description: Set ftp port to custom port (if nothing is set, default port is 21) [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1130-L1141)
# @option: $1 - `-ftp | --ftp_port` (optional) (takes one argument)
# @arg: $2 - `[port]` (default: 21) - the port to set for ftp
# @example: vstacklet -ftp 2121
# @example: vstacklet --ftp_port 2121
# @null
# @return_code: 9 - failed to set FTP port.
# @return_code: 10 - failed to restart FTP service.
# @break
##################################################################################
vstacklet::ftp::set() {
	if [[ -n ${ftp_port} ]]; then
		vstacklet::shell::text::white "setting ftp port to ${ftp_port:-21} ... "
		cp -f /etc/vsftpd.conf "${vstacklet_base_path}/config/system/vsftpd.conf"
		openssl req -config "${local_setup_dir}/templates/ssl/openssl.conf" -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem >/dev/null 2>&1
		cp -f "${local_setup_dir}/templates/vsftpd/vsftpd.conf" /etc/vsftpd.conf
		sed -i.bak -e "s|{{ftp_port}}|${ftp_port:-21}|g" -e "s|{{server_ip}}|${server_ip}|g" /etc/vsftpd.conf >>"${vslog}" 2>&1 || vstacklet::error::display 9
		vstacklet::log systemctl restart vsftpd || vstacklet::error::display 10
		vstacklet::log iptables -I INPUT -p tcp --destination-port 10090:10100 -j ACCEPT
		echo "" >/etc/vsftpd.chroot_list
	fi
}

##################################################################################
# @name: vstacklet::block::ssdp (19)
# @description: Blocks an insecure port 1900 that may lead to
# DDoS masked attacks. Only remove this function if you absolutely
# need port 1900. In most cases, this is a junk port. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1154-L1159)
# @noargs
# @nooptions
# @return_code: 11 - failed to block SSDP port.
# @return_code: 12 - failed to save iptables rules.
# @break
##################################################################################
vstacklet::block::ssdp() {
	vstacklet::shell::text::white "blocking port 1900 ..."
	mkdir -p /etc/iptables/
	vstacklet::log iptables -I INPUT 1 -p udp -m udp --dport 1900 -j DROP || vstacklet::error::display 11
	iptables-save >/etc/iptables/rules.v4 || vstacklet::error::display 12
}

##################################################################################
# @name: vstacklet::sources::update (20)
# @description: This function updates the package list and upgrades the system. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1170-L1279)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @noargs
# @nooptions
# @break
##################################################################################
vstacklet::sources::update() {
	vstacklet::shell::text::white "updating package list ..."
	if [[ ${distro} == "Debian" && ${codename} != "bookworm" ]]; then
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
	elif [[ ${distro} == "Debian" && ${codename} == "bookworm" ]]; then
		cat >/etc/apt/sources.list <<EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL DEBIAN REPOS                             #
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://ftp.debian.org/debian/ ${codename} main contrib non-free non-free-firmware
deb-src http://ftp.debian.org/debian/ ${codename} main contrib non-free non-free-firmware

deb http://ftp.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware
deb-src http://ftp.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware

deb http://security.debian.org/ ${codename}-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/ ${codename}-security main contrib non-free non-free-firmware

deb http://ftp.debian.org/debian ${codename}-backports main
deb-src http://ftp.debian.org/debian ${codename}-backports main

#------------------------------------------------------------------------------#
#                      UNOFFICIAL  REPOS
#------------------------------------------------------------------------------#

###### 3rd Party Binary Repos
###Debian Multimedia
#deb [arch=amd64,i386] https://www.deb-multimedia.org ${codename} main non-free non-free-firmware

###### nginx
#deb [arch=amd64,i386] http://nginx.org/packages/debian/ ${codename} nginx
#deb-src [arch=amd64,i386] http://nginx.org/packages/debian/ ${codename} nginx

###### Missing Dependencies
EOF
	elif [[ ${distro} == "Ubuntu" && ${codename} != "bionic" ]]; then
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
# required by added sources. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1302-L1364)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
#
# notes:
# - keys and sources are set for the following software packages:
#   - nginx (only if option `-nginx|--nginx` is set)
#   - varnish (only if option `-varnish|--varnish` is set)
#   - php (only if option `-php|--php` is set)
#   - mariadb (only if option `-mariadb|--mariadb` is set)
#   - redis (only if option `-redis|--redis` is set)
#   - postgresql (only if option `-postgre|--postgresql` is set)
# - apt-key is being deprecated, using gpg instead
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::gpg::keys() {
	# @script-note: package and repo addition (c) _add signed keys_
	vstacklet::shell::text::white "adding signed keys and sources for required software packages ... "
	mkdir -p /etc/apt/sources.list.d /etc/apt/keyrings
	if [[ -n ${nginx} ]]; then
		# @script-note: nginx
		if [[ ${distro,,} == "debian" ]]; then
			curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/keyrings/nginx.gpg >>"${vslog}" 2>&1
			echo "deb [signed-by=/etc/apt/keyrings/nginx.gpg] https://nginx.org/packages/mainline/${distro,,} ${codename} nginx" | tee /etc/apt/sources.list.d/nginx.list >>"${vslog}" 2>&1
		elif [[ ${distro,,} == "ubuntu" ]]; then
			curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >>"${vslog}" 2>&1
			echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/mainline/${distro,,} ${codename} nginx" | tee /etc/apt/sources.list.d/nginx.list >>"${vslog}" 2>&1
		fi
	fi
	if [[ -n ${varnish} ]]; then
		# @script-note: varnish
		if [[ ${distro,,} == "debian" ]]; then
			curl -fsSL "https://packagecloud.io/varnishcache/varnish74/gpgkey" | gpg --dearmor -o "/etc/apt/keyrings/varnishcache_varnish74-archive-keyring.gpg" >>"${vslog}" 2>&1
			curl -sSf "https://packagecloud.io/install/repositories/varnishcache/varnish74/config_file.list?os=${distro,,}&dist=${codename}&source=script" >"/etc/apt/sources.list.d/varnishcache_varnish74.list"
		elif [[ ${distro,,} == "ubuntu" ]]; then
			curl -fsSL "https://packagecloud.io/varnishcache/varnish74/gpgkey" | gpg --dearmor -o "/etc/apt/trusted.gpg.d/varnish.gpg" >>"${vslog}" 2>&1
			sudo tee /etc/apt/sources.list.d/varnishcache_varnish74.list >/dev/null <<-EOF
				deb https://packagecloud.io/varnishcache/varnish74/${distro,,}/ ${codename} main
				deb-src https://packagecloud.io/varnishcache/varnish74/${distro,,}/ ${codename} main
			EOF
		fi
	fi
	if [[ -n ${php} ]]; then
		# @script-note: php
		if [[ ${distro,,} == "debian" ]]; then
			curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/php.gpg >>"${vslog}" 2>&1
			echo "deb [signed-by=/etc/apt/keyrings/php.gpg] https://packages.sury.org/php/ ${codename} main" | tee /etc/apt/sources.list.d/php-sury.list >>"${vslog}" 2>&1
		elif [[ ${distro,,} == "ubuntu" ]]; then
			LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php >>"${vslog}" 2>&1
		fi
	fi
	if [[ -n ${mariadb} ]]; then
		# @script-note: mariadb
		curl -fsSL https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor -o /etc/apt/keyrings/mariadb.gpg >>"${vslog}" 2>&1
		echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg] http://mirror.its.dal.ca/mariadb/repo/10.11/${distro,,} ${codename} main" | tee /etc/apt/sources.list.d/mariadb.list >>"${vslog}" 2>&1
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
	# @script-note: Remove excess sources known to cause issues with conflicting package sources
	[[ -f "/etc/apt/sources.list.d/proposed.list" ]] && mv -f /etc/apt/sources.list.d/proposed.list /etc/apt/sources.list.d/proposed.list.save
	declare -gi apt_upgrade="1"
}

##################################################################################
# @name: vstacklet::locale::set (22)
# @description: This function sets the locale to en_US.UTF-8
# and sets the timezone to UTC. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1381-L1401)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
#
# todo: This function is still a work in progress.
# - [ ] implement arguments to set the locale
# - [ ] implement arguments to set the timezone (or a seperate function)
# @noargs
# @nooptions
# @return_code: 13 - failed to set locale.
# @break
##################################################################################
vstacklet::locale::set() {
	vstacklet::shell::text::white "setting locale to en_US.UTF-8 ..."
	apt-get -y install language-pack-en-base >>"${vslog}" 2>&1
	if [[ -e /usr/sbin/locale-gen ]]; then
		(
			update-locale "LANGUAGE=en_US.UTF-8" >/dev/null 2>&1
			dpkg-reconfigure --frontend noninteractive locales
		) >>"${vslog}" 2>&1 || vstacklet::error::display 13
	else
		(
			vstacklet::log apt-get -y update
			[[ ${distro,,} == "debian" ]] && vstacklet::log apt-get -y install locales
			[[ ${distro,,} == "ubuntu" ]] && vstacklet::log apt-get -y install locales
			update-locale "LANGUAGE=en_US.UTF-8" >/dev/null 2>&1
			dpkg-reconfigure --frontend noninteractive locales
		) >>"${vslog}" 2>&1 || vstacklet::error::display 13
	fi
	[[ ${distro,,} == "debian" ]] && vstacklet::log::try locale-gen locales
	[[ ${distro,,} == "ubuntu" ]] && vstacklet::log::try locale-gen en_US.UTF-8
	declare -xg LANGUAGE="en_US.UTF-8"
}

##################################################################################
# @name: vstacklet::php::install (23)
# @description: Install PHP and PHP modules. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1439-L1490)
#
# notes:
# - versioning:
#   - supported: "8.3", "8.4" (default, DEFAULT_PHP) and "8.5" (SUPPORTED_PHP); any other value is refused
# - php modules are installed based on the following variables:
#   - `-php [php version]` (default: 8.4) - php version to install
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
# @arg: $2 - `[version]` - `8.3` | `8.4` | `8.5`
# @example: vstacklet -php 8.4
# @example: vstacklet --php 8.5
# @null
# @return_code: 15 - failed to install PHP dependencies.
# @break
##################################################################################
vstacklet::php::install() {
	if [[ -n ${php} ]]; then
		# @script-note: check for nginx \\ to maintain modularity, nginx is not required for PHP
		#[[ -z ${nginx} ]] && vstacklet::error::display "PHP requires nginx. please install nginx."
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 15
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
		phpmods=("opcache" "xml" "igbinary" "imagick" "intl" "mbstring" "gmp" "bcmath" "msgpack" "memcached" "curl")
		for i in "${phpmods[@]}"; do
			phpenmod -v "${php}" "${i}" >>"${vslog}" 2>&1
		done
		[[ -n ${redis} ]] && phpmods+=("redis")
		vs::stat::progress::stop # stop progress status
		# @script-note: php installation complete
	fi
}

##################################################################################
# @name: vstacklet::nginx::install (25)
# @description: Install NGinx and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1601-L1709)
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
# - These config can be found at [/etc/nginx/server.configs/](https://github.com/JMSDOnline/vstacklet/tree/main/config/nginx/server.configs)
# @option: $1 - `-nginx | --nginx` (optional) (takes no arguments)
# @example: vstacklet -nginx
# @example: vstacklet --nginx
# @example: vstacklet -nginx -php 8.4 -varnish -varnishP 80 -http 8080 -https 443
# @example: vstacklet --nginx --php 8.4 --varnish --varnishP 80 --http 8080 --https 443
# @null
# @return_code: 20 - failed to install NGINX dependencies.
# @return_code: 21 - failed to edit NGINX configuration file.
# @return_code: 22 - failed to enable NGINX configuration file.
# @return_code: 23 - failed to generate dhparam file.
# @return_code: 24 - failed to generate self-signed certificate.
# @return_code: 25 - failed to create the web root's public folder.
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
			vstacklet::log apt-get -y install "${install}" --allow-unauthenticated || vstacklet::error::display 20
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${nginx_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		vstacklet::log systemctl stop nginx
		mkdir -p "${local_setup_dir}/nginx/temp"
		[[ -f /etc/nginx/nginx.conf ]] && mv -f /etc/nginx/nginx.conf "${local_setup_dir}/nginx/temp/nginx.conf"
		[[ -f /etc/nginx/sites-enabled/default ]] && mv -f /etc/nginx/sites-enabled/default "${local_setup_dir}/nginx/temp/default"
		mv /etc/nginx /etc/nginx-pre-vstacklet
		mkdir -p /etc/nginx/{conf.d,cache,ssl,sites-enabled,sites-available}
		sed -i "s|{{server_ip}}|${server_ip}|g" "${local_nginx_dir}/server.configs/directives/cloudflare-real-ip.conf"
		wr_sanitize=$(echo "${web_root:-/var/www/html/vsapp}" | sed 's/\//\\\//g')
		sed -i "s|{{webroot}}|${wr_sanitize}|g" "${local_nginx_dir}/server.configs/location/letsencrypt.conf"
		sleep 3
		rsync -aP --exclude=LICENSE --exclude=README --exclude=.git "${local_nginx_dir}"/* /etc/nginx/ >/dev/null 2>&1
		\cp -rf /etc/nginx-pre-vstacklet/uwsgi_params /etc/nginx-pre-vstacklet/fastcgi_params /etc/nginx/
		chown -R www-data:www-data /etc/nginx/cache
		chmod -R 755 /etc/nginx/cache
		sh -c 'find /etc/nginx -type f -exec chmod 644 {} \;'
		chmod -R g+rw /etc/nginx/cache
		sh -c 'find /etc/nginx/cache -type d -print0 | sudo xargs -0 chmod g+s'
		# @script-note: import nginx reverse config files from vStacklet
		if [[ ${php} == *"8"* ]]; then
			[[ -z ${varnish} ]] && cp -f "${local_php8_dir}/nginx/default.php8.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
			# @script-note: import nginx reverse modified for varnish and nginx ssl termination
			[[ -n ${varnish} ]] && cp -f "${local_php8_dir}/nginx/varnish/default.php8.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		fi
		vstacklet::shell::text::yellow::sl "configuring NGinx and generating self-signed certificates ... " &
		vs::stat::progress::start # start progress status
		# @script-note: post necessary edits to nginx config files
		sed -i "s|{{php}}|${php:-${DEFAULT_PHP}}|g" "/etc/nginx/wordpress.conf" >/dev/null 2>&1
		if [[ -z ${varnish} ]]; then
			sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{domain}}|${domain:-${hostname:-vs-site1}}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-${DEFAULT_PHP}}|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" || vstacklet::error::display 21
		fi
		if [[ -n ${varnish} ]]; then
			sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{varnish_port}}|${varnish_port:-6081}|g" -e "s|{{domain}}|${domain:-${hostname:-vs-site1}}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-${DEFAULT_PHP}}|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" || vstacklet::error::display 21
		fi
		# @script-note: enable site
		ln -sf "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" "/etc/nginx/sites-enabled/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1 || vstacklet::error::display 22
		# @script-note: generate Diffie-Hellman parameters file and self-signed ssl cert
		if [[ ! -f /etc/nginx/ssl/dhparam.pem ]]; then
			openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 >>"${vslog}" 2>&1 || vstacklet::error::display 23
		fi
		if [[ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]]; then
			openssl req -config "${vstacklet_base_path}/setup/templates/ssl/openssl.conf" -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem >>"${vslog}" 2>&1 || vstacklet::error::display 24
		fi
		vs::stat::progress::stop # stop progress status
		vstacklet::shell::text::yellow::sl "adjusting permissions on ${web_root:-/var/www/html/vsapp} ... " &
		vs::stat::progress::start # start progress status
		# Create the public directory if it doesn't exist
		mkdir -p "${web_root:-/var/www/html/vsapp}/public" || vstacklet::error::display 25
		# @script-note: no public phpinfo() page: it showed the server's full PHP and environment details to anyone
		chown -R www-data:www-data "${web_root:-/var/www/html/vsapp}"
		chmod -R 755 "${web_root:-/var/www/html/vsapp}"
		chmod -R g+rw "${web_root:-/var/www/html/vsapp}"
		sh -c "find ${web_root:-/var/www/html/vsapp} -type d -print0 | sudo xargs -0 chmod g+s"
		# @script-note: if wordpress option is enabled, edit nginx config file to include wordpress specific directives
		# no need to log this one as it's not a critical step (helpful, but not critical)
		[[ -n ${wordpress} && -z ${varnish} ]] && sed -i -e '/# include wordpress.conf;/s/#//' -e '/# include restrictions.conf;/s/#//' "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		# @dev-note: if varnish option is enabled, comment out location / block from /etc/nginx/wordpress.conf file (archived for reference)
		#[[ -n ${varnish} ]] && sed -i '/location \/ {/,/}/s/^/#/' /etc/nginx/wordpress.conf
		# @dev-note: if varnish option is disabled, remove location / block from /etc/nginx/wordpress.conf file (archived for reference)
		#[[ -n ${varnish} ]] && sed -i '/location \/ {/,/}/d' /etc/nginx/wordpress.conf
		# @script-note: set override for nginx pid file
		mkdir -p /etc/systemd/system/nginx.service.d >/dev/null 2>&1
		printf "[Service]\nExecStartPost=/bin/sleep 1\n" >"/etc/systemd/system/nginx.service.d/override.conf"
		vstacklet::log systemctl daemon-reload && vstacklet::log systemctl restart nginx
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
	fi
}

##################################################################################
# @name: vstacklet::varnish::install (26)
# @description: Install Varnish and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1741-L1811)
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
# @return_code: 26 - failed to install Varnish dependencies.
# @return_code: 27 - could not switch to /etc/varnish directory.
# @return_code: 28 - failed to edit the Varnish default config file.
# @return_code: 29 - failed to reload the systemd daemon.
# @return_code: 30 - failed to switch to ~/
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
			vstacklet::log apt-get -y install "${install}" --allow-unauthenticated || vstacklet::error::display 26
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${varnish_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		cd /etc/varnish || vstacklet::error::display 27
		vstacklet::shell::text::yellow::sl "configuring Varnish ... " &
		vs::stat::progress::start # start progress status
		mv default.vcl default.vcl.ORIG
		# @script-note: import varnish config files from vStacklet
		# - the custom.vcl file is a custom Varnish config file that can be used to override the default.vcl file.
		# - the default.vcl file is the default Varnish config file that is used to configure Varnish.
		# - the custom.vcl file imported from vStacklet is setup to function with phpmyadmin and wordpress.
		# - the commented out lines of code below are for reference only.
		cp -f "${local_varnish_dir}/custom.vcl" "/etc/varnish/custom.vcl"
		# adjust varnish config files
		if [[ -n ${nginx} ]]; then
			# @script-note: if nginx is installed, then use nginx as the backend. this is assigned by way of the http_port variable
			sed -i -e "s|{{server_ip}}|${server_ip}|g" -e "s|{{varnish_port}}|${http_port:-80}|g" -e "s|{{domain}}|${domain:-${server_ip}}|g" "/etc/varnish/custom.vcl"
			#if [[ ${distro,,} == "debian" ]]; then
			#	sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" -e "s|You probably want to change it|custom.vcl has been set by vStacklet|g" "/etc/default/varnish" || vstacklet::error::display 28
			#fi
		else
			# @script-note: if nginx is not installed, then use varnish as the backend.
			# this is assigned by way of the varnish_port variable (this is not useful for most people)
			sed -i -e "s|{{server_ip}}|${server_ip}|g" -e "s|{{varnish_port}}|${varnish_port:-6081}|g" -e "s|{{domain}}|${domain:-${server_ip}}|g" "/etc/varnish/custom.vcl"
			#if [[ ${distro,,} == "debian" ]]; then
			#	sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" -e "s|You probably want to change it|custom.vcl has been set by vStacklet|g" "/etc/default/varnish" || vstacklet::error::display 28
			#fi
		fi
		# @script-note: adjust varnish service
		cp -f "${local_varnish_dir}/varnish.service" /lib/systemd/system/varnish.service
		cp -f /lib/systemd/system/varnish.service /etc/systemd/system/
		sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" "/etc/systemd/system/varnish.service"
		sed -i -e "s|6081|${varnish_port:-6081}|g" -e "s|default.vcl|custom.vcl|g" -e "s|malloc,256m|malloc,${varnish_memory:-1g}|g" "/lib/systemd/system/varnish.service"
		# @script-note: create varnish secret file
		uuidgen | sudo tee /etc/varnish/secret >/dev/null
		# @script-note: reload systemd=daemon
		vstacklet::log systemctl daemon-reload || vstacklet::error::display 29
		cd "${HOME}" || vstacklet::error::display 30
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
# @description: Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1833-L1841)
#
# notes:
# - Permissions are adjusted based the following variables:
#   - adjustments are made to the assigned web root on the `-wr | --web-root`
#    option
#   - adjustments are made to the default web root of `/var/www/html/vsapp`
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
	chown -R www-data:www-data "${web_root:-/var/www/html/vsapp}"
	chmod -R 755 "${web_root:-/var/www/html/vsapp}"
	sh -c "find ${web_root:-/var/www/html/vsapp} -type f -print0 | sudo xargs -0 chmod 644"
	chmod -R g+rw "${web_root:-/var/www/html/vsapp}"
	sh -c "find ${web_root:-/var/www/html/vsapp} -type d -print0 | sudo xargs -0 chmod g+s"
}

##################################################################################
# @name: vstacklet::ioncube::install (28)
# @description: Install ionCube loader. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1863-L1901)
#
# notes:
# - the ioncube loader will be available for the php version specified
#   from the `-php | --php` option.
# @option: $1 - `-ioncube | --ioncube` (optional) (takes no arguments)
# @example: vstacklet -ioncube -php 8.4
# @null
# @return_code: 31 - failed to switch to /tmp directory.
# @return_code: 32 - failed to download ionCube loader.
# @return_code: 33 - failed to extract ionCube loader.
# @return_code: 34 - failed to switch to /tmp/ioncube directory.
# @return_code: 35 - failed to copy ionCube loader to /usr/lib/php/ directory.
# @break
##################################################################################
vstacklet::ioncube::install() {
	if [[ -n ${ioncube} ]]; then
		vstacklet::shell::misc::nl
		# @script-note: the 3.x loader paths covered PHP 7.4 and 8.1 only; the 4.0 loader install (pinned download, every supported PHP) is not written yet
		vstacklet::shell::text::yellow "ionCube Loader is not installed by this development build for PHP ${php}. Skipping ..."
	fi
}

##################################################################################
# @name: vstacklet::mariadb::install (29)
# @description: Install mariaDB and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1935-L2057)
#
# notes:
# - if `-mysql | --mysql` is specified, then mariadb will not be installed. choose either mariadb or mysql.
# - actual mariadb version installed is 10.11.+ LTS.
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
# @return_code: 36 - failed to install MariaDB dependencies.
# @return_code: 37 - failed to initialize MariaDB secure installation.
# @return_code: 38 - failed to set MariaDB client and server configuration.
# @return_code: 39 - failed to set MariaDB .my.cnf configuration.
# @return_code: 40 - failed to create MariaDB user.
# @return_code: 41 - failed to create MariaDB user privileges.
# @return_code: 42 - failed to flush privileges.
# @break
##################################################################################
vstacklet::mariadb::install() {
	if [[ -n ${mariadb} ]]; then
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 36
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
		) >>"${vslog}" 2>&1 || vstacklet::error::display 37
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
			echo -e "max_heap_table_size = 16M"
			echo -e "max_sp_recursion_depth = 255"
			echo -e "max_binlog_size = 100M"
			echo -e "max_binlog_cache_size = 1M"
			echo -e "max_binlog_stmt_cache_size = 1M"
			echo -e "max_sort_length = 1024"
			echo -e "max_join_size = 1000000"
			echo -e "max_length_for_sort_data = 1024"
			echo -e "max_seeks_for_key = 4294967295"
			echo -e "max_write_lock_count = 4294967295"
			echo -e "max_tmp_tables = 32"
			echo -e "max_prepared_stmt_count = 16382"
			echo -e "max_delayed_threads = 20"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::error::display 38
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
		} >/root/.my.cnf || vstacklet::error::display 39
		vstacklet::log systemctl daemon-reload
		vstacklet::log systemctl restart mariadb
		#mysqladmin -u root -h localhost password "${mariadb_password:-${mariadb_autoPw}}"
		# @script-note: create mariadb user
		mysql -u root -e "CREATE USER '${mariadb_user:-admin}'@'localhost' IDENTIFIED BY '${mariadb_password:-${mariadb_autoPw}}';" >>"${vslog}" 2>&1 || vstacklet::error::display 40
		mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${mariadb_user:-admin}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || vstacklet::error::display 41
		mysql -u root -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::error::display 42
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
# @description: Install mySQL and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2088-L2211)
#
# notes:
# - if `-mariadb | --mariadb` is specified, then mysql will not be installed. choose either mysql or mariadb.
# - apt-deb mysql version is 0.8.29-1_all.deb
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
# @return_code: 43 - failed to download MySQL deb package.
# @return_code: 44 - failed to install MySQL deb package.
# @return_code: 45 - failed to install MySQL dependencies.
# @return_code: 46 - failed to set MySQL client and server configuration.
# @return_code: 47 - failed to set MySQL .my.cnf file.
# @return_code: 48 - failed to create MySQL user.
# @return_code: 49 - failed to grant MySQL user privileges.
# @return_code: 50 - failed to flush MySQL privileges.
# @break
# shellcheck disable=SC2034,SC2155
##################################################################################
vstacklet::mysql::install() {
	if [[ -n ${mysql} ]]; then
		declare mysql_autoPw
		mysql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		local mysql_deb_version=$(curl -s4 "https://dev.mysql.com/downloads/repo/apt/" | grep -Eo "mysql-apt-config_[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" | head -n 1)
		[[ -f "/tmp/${mysql_deb_version}_all.deb" ]] && rm -f "/tmp/${mysql_deb_version}.*"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring MySQL ... "
		# @script-note: install mysql deb
		vstacklet::log wget "https://dev.mysql.com/get/${mysql_deb_version}_all.deb" -O "/tmp/${mysql_deb_version}_all.deb" || vstacklet::error::display 43
		declare DEBIAN_FRONTEND=noninteractive
		yes | DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install "/tmp/${mysql_deb_version}_all.deb" --allow-change-held-packages >>"${vslog}" 2>&1 || vstacklet::error::display 44
		# @script-note: run apt maintenance to ensure environment is up-to-date
		DEBIAN_FRONTEND=noninteractive apt-get -y update
		apt-get -y upgrade
		apt-get -y autoremove
		apt-get -y autoclean >>"${vslog}" 2>&1
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 45
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${mysql_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		vstacklet::log systemctl enable mysql
		vstacklet::log systemctl start mysql
		# @script-note: configure mysql
		vstacklet::shell::text::yellow::sl "configuring MySQL ... " &
		vs::stat::progress::start # start progress status
		# @script-note: set mysql client and server configuration
		{
			echo -e "[client]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysqld]"
			echo -e "port = ${mysql_port:-3306}"
			echo -e "socket = /run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"
			echo -e "mysqlx-bind-address = 127.0.0.1"
			echo -e "datadir = /var/lib/mysql"
			echo -e "log-error = /var/log/mysql/error.log"
			echo -e "pid-file = /var/run/mysqld/mysqld.pid"
			echo -e "key_buffer_size = 16M"
			echo -e "myisam-recover-options = BACKUP"
			echo -e "max_allowed_packet = 16M"
			echo -e "max_heap_table_size = 16M"
			echo -e "max_sp_recursion_depth = 255"
			echo -e "max_binlog_size = 100M"
			echo -e "max_binlog_cache_size = 1M"
			echo -e "max_binlog_stmt_cache_size = 1M"
			echo -e "max_sort_length = 1024"
			echo -e "max_join_size = 1000000"
			echo -e "max_length_for_sort_data = 1024"
			echo -e "max_seeks_for_key = 4294967295"
			echo -e "max_write_lock_count = 4294967295"
			echo -e "max_prepared_stmt_count = 16382"
			echo -e "max_delayed_threads = 20"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::error::display 46
		# @script-note: set mysql privileges
		{
			echo -e "########################################################################"
			echo -e "# MySQL database privileges"
			echo -e "# Uncomment the following lines to disable MySQL database privileges"
			echo -e "########################################################################"
			echo -e ""
			echo -e "#[mysqld]"
			echo -e "#skip-grant-tables"
			echo -e ""
		} >/etc/mysql/conf.d/vstacklet-grant.cnf >>"${vslog}" 2>&1
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
		} >"${HOME}/.my.cnf" || vstacklet::error::display 47
		vstacklet::log systemctl daemon-reload
		vstacklet::log systemctl enable mysql
		vstacklet::log systemctl restart mysql
		#mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_password:-${mysql_autoPw}}';\"" || vstacklet::error::display 79
		mysql -u root -e "CREATE USER '${mysql_user:-admin}'@'localhost' IDENTIFIED BY '${mysql_password:-${mysql_autoPw}}';" >>"${vslog}" 2>&1 || vstacklet::error::display 48
		mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${mysql_user:-admin}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || vstacklet::error::display 49
		mysql -u root -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::error::display 50
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
# @description: Install and configure PostgreSQL. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2235-L2322)
#
# note: postgresql is not installed by default and is currently untested.
# this function is a work in progress. it is intended as a future feature.
#
# @option: $1 - `-postgre | --postgresql` (optional)
# @arg: $2 - `[postgresql_port]` (optional) (default: 5432)
# @arg: $3 - `[postgresql_user]` (optional) (default: admin)
# @arg: $4 - `[postgresql_password]` (optional) (default: password auto-generated)
# @example: vstacklet -postgre -postgreP 5432 -postgreU admin -postgrePw password
# @example: vstacklet --postgresql --postgresql_port 5432 --postgresql_user admin --postgresql_password password
# @return_code: 51 - failed to install PostgreSQL dependencies.
# @return_code: 52 - failed to switch to /etc/postgresql/${postgre_version}/main directory.
# @return_code: 53 - failed to set PostgreSQL password.
# @return_code: 54 - failed to create PostgreSQL user.
# @return_code: 55 - failed to grant PostgreSQL user privileges.
# @return_code: 56 - failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file.
# @return_code: 57 - failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file.
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 51
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
		# @script-note: to make alterations to postgresql, we must first switch to a directory that postgresql has access to
		cd "/etc/postgresql/${postgre_version}/main" || vstacklet::error::display 52
		# @script-note: set postgresql root password
		(
			sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';"
			sleep 2
		) >>"${vslog}" 2>&1 || vstacklet::error::display 53
		# @script-note: create postgresql user
		(
			sudo -u postgres psql -c "CREATE USER ${postgresql_user:-admin} WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';"
			sleep 2
		) >>"${vslog}" 2>&1 || vstacklet::error::display 54
		# @script-note: grant postgresql user privileges
		(
			sudo -u postgres psql -c "ALTER USER ${postgresql_user:-admin} WITH SUPERUSER;"
			sleep 2
		) >>"${vslog}" 2>&1 || vstacklet::error::display 55
		# @script-note: set postgre client and server configuration
		cp -f "/etc/postgresql/${postgre_version}/main/postgresql.conf" "/etc/postgresql/${postgre_version}/main/postgresql.conf.default-bak"
		{
			echo -e "port = ${postgresql_port:-5432}"
			echo -e "listen_addresses = 'localhost'"
		} >"/etc/postgresql/${postgre_version}/main/postgresql.conf" || vstacklet::error::display 56
		cp -f "/etc/postgresql/${postgre_version}/main/pg_hba.conf" "/etc/postgresql/${postgre_version}/main/pg_hba.conf.default-bak"
		{
			echo -e "# Database administrative login by Unix domain socket"
			echo -e "local   all             postgres                                peer"
			echo
			echo -e "# TYPE  DATABASE        USER            ADDRESS                 METHOD"
			echo
			echo -e "# \"local\" is for Unix domain socket connections only"
			echo -e "local   all             all                                     md5"
		} >"/etc/postgresql/${postgre_version}/main/pg_hba.conf" || vstacklet::error::display 57
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
# @description: Install and configure Redis. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2349-L2403)
#
# note: redis is not installed by default and is currently untested.
# this function is a work in progress. it is intended as a future feature.
#
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
# @return_code: 58 - failed to install Redis dependencies.
# @return_code: 59 - failed to backup the Redis configuration file.
# @return_code: 60 - failed to import the Redis configuration file.
# @return_code: 61 - failed to modify the Redis configuration file.
# @return_code: 62 - failed to restart the Redis service.
# @return_code: 63 - failed to set the Redis password.
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 58
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
		cp -f /etc/redis/redis.conf /etc/redis/redis.conf.bak || vstacklet::error::display 59
		cp -f "${local_setup_dir}/templates/redis/redis.conf" /etc/redis/redis.conf || vstacklet::error::display 60
		sed -i.bak "s/{{redis_port}}/${redis_port:-6379}/g" /etc/redis/redis.conf || vstacklet::error::display 61
		# @script-note: restart redis
		vstacklet::log systemctl restart redis-server || vstacklet::error::display 62
		# @script-note: set redis password
		redis-cli -a "" -h localhost -p "${redis_port:-6379}" config set requirepass "${redis_password:-${redis_autoPw}}" >>"${vslog}" 2>&1 || vstacklet::error::display 63
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
# @description: Install phpMyAdmin and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2455-L2549)
#
# notes:
# - phpMyAdmin requires a web server to run. You must select a web server from the list below.
#   - nginx
#   - varnish
# - phpMyAdmin requires a database server to run. You must select a database server from the list below.
#   - mariadb
#   - mysql
# - phpMyAdmin requires php to run. You must select a php version from the list below.
#   - 8.3, 8.4 or 8.5
# - phpMyAdmin requires a web port to run. This argmuent is supplied by the `-http | --http_port` option.
# - phpMyAdmin will use the following options to configure itself:
#   - web server: nginx, varnish
#     - Nginx usage: `-nginx | --nginx`
#     - Varnish usage: `-varnish | --varnish`
#   - database server: mariadb, mysql
#     - mariaDB usage: `-mariadbU [user] | --mariadb_user [user]` & `-mariadbPw [password] | --mariadb_password [password]`
#     - mysql usage: `-mysqlU [user] | --mysql_user [user]` & `-mysqlPw [password] | --mysql_password [password]`
#     - note: if no user or password is provided, the default user and password will be used. (admin, auto-generated password)
#   - php version: 8.3, 8.4 or 8.5
#     - PHP usage: `-php [version] | --php [version]`
#   - port: http
#     - usage: `-http [port] | --http [port]`
#     - note: if no port is provided, the default port will be used. (80)
# @option: $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments) (default: not installed)
# @arg: `-phpmyadmin | --phpmyadmin` does not take any arguments. However, it requires the options as expressed above.
# @example: vstacklet -phpmyadmin -nginx -mariadbU admin -mariadbPw password -php 8.3 -http 80
# @example: vstacklet --phpmyadmin --nginx --mariadb_user admin --mariadb_password password --php 8.3 --http 80
# @null
# @return_code: 64 - failed to install phpMyAdmin dependencies.
# @return_code: 65 - failed to switch to /usr/share directory.
# @return_code: 66 - failed to download phpMyAdmin.
# @return_code: 67 - failed to extract phpMyAdmin.
# @return_code: 68 - failed to move phpMyAdmin to /usr/share directory.
# @return_code: 69 - failed to remove phpMyAdmin .tar.gz file.
# @return_code: 70 - failed to set ownership of phpMyAdmin directory.
# @return_code: 71 - failed to set permissions of phpMyAdmin directory.
# @return_code: 72 - failed to create /usr/share/phpmyadmin/tmp directory.
# @return_code: 73 - failed to set symlink of ./phpmyadmin to ${web_root}/public/phpmyadmin.
# @return_code: 74 - failed to create htpasswd file.
# @return_code: 75 - failed to create phpMyAdmin configuration file.
# @break
##################################################################################
vstacklet::phpmyadmin::install() {
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
				DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 64
				install_list+=("${install}")
			done
			[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
			for depend in "${phpmyadmin_dependencies[@]}"; do
				echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
			done
			unset depend depend_list install
			cd /usr/share || vstacklet::error::display 65
			[[ -d phpmyadmin ]] && rm -rf phpmyadmin
			wget -q "https://files.phpmyadmin.net/phpMyAdmin/${pma_version}/phpMyAdmin-${pma_version}-all-languages.tar.gz" || vstacklet::error::display 66
			tar -xzf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::error::display 67
			mv phpMyAdmin-"${pma_version}"-all-languages phpmyadmin || vstacklet::error::display 68
			rm -rf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::error::display 69
			chown -R www-data:www-data phpmyadmin || vstacklet::error::display 70
			chmod -R 755 phpmyadmin || vstacklet::error::display 71
			# trunk-ignore(shellcheck/SC2015)
			if ! (mkdir -p /usr/share/phpmyadmin/tmp && chown -R www-data:www-data /usr/share/phpmyadmin/tmp); then
				vstacklet::error::display 72
			fi
			ln -sf /usr/share/phpmyadmin "${web_root:-/var/www/html/vsapp}/public" || vstacklet::error::display 73
			# @script-note: configure phpmyadmin
			vstacklet::shell::text::yellow::sl "configuring phpMyAdmin ... " &
			vs::stat::progress::start # start progress status
			# @script-note: create phpmyadmin htpasswd file - this is used for basic authentication, not for the database
			# this is only used if/when the user opts to use basic authentication (a post install courtesy)
			htpasswd -b -c /usr/share/phpmyadmin/.htpasswd "${mariadb_user:-${mysql_user:-admin}}" "${pma_password}" >>"${vslog}" 2>&1 || vstacklet::error::display 74
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
			} >/usr/share/phpmyadmin/config.inc.php || vstacklet::error::display 75
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
			vstacklet::shell::text::green "${web_root:-/var/www/html/vsapp}/public"
		fi
	fi
}

##################################################################################
# @name: vstacklet::sendmail::install (35)
# @description: Install and configure sendmail. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2785-L2876)
#
# notes:
# - The `-e | --email` option is required for this function to run properly.
#   the email address provided will be used to configure sendmail.
# @option: $1 - `-sendmail | --sendmail` (optional) (takes no arguments)
# @noargs
# @example: vstacklet -sendmail -e "your@email.com"
# @example: vstacklet --sendmail --email "your@email.com"
# @null
# @return_code: 88 - failed to install sendmail dependencies.
# @return_code: 89 - failed to edit aliases file.
# @return_code: 90 - failed to edit sendmail.cf file.
# @return_code: 91 - failed to edit main.cf file.
# @return_code: 92 - failed to edit master.cf file.
# @return_code: 93 - failed to create sasl_passwd file.
# @return_code: 94 - postmap failed.
# @return_code: 95 - failed to source new aliases.
# @break
##################################################################################
vstacklet::sendmail::install() {
	if [[ -n ${sendmail} ]]; then
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
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 88
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
		# @script-note: begin initial sendmail configuration - auto-configure sendmail by answering yes to all questions
		"yes" | sendmailconfig >>"${vslog}" 2>&1 || vstacklet::error::display 88
		# @script-note: modify aliases
		if [[ -f "/etc/mail/aliases" ]]; then
			# @script-note: backup aliases
			cp /etc/mail/aliases /etc/mail/aliases.orig >>"${vslog}" 2>&1 || vstacklet::error::display 89
			# @script-note: check if /etc/mail/aliases is empty - if so, modify it
			if [[ $(wc -l <"/etc/mail/aliases") -eq 0 ]]; then
				cat <<EOF >/etc/mail/aliases
mailer-daemon: postmaster
postmaster: root
nobody: root
hostmaster: root
usenet: root
news: root
webmaster: root
www: root
ftp: root
abuse: root
noc: root
security: root
root: ${email}
EOF
			else
				# @script-note: check if root alias exists in /etc/mail/aliases - if not, add it
				if [[ $(grep -c "^root:" /etc/mail/aliases) -eq 0 ]]; then
					echo "root: ${email}" >>/etc/mail/aliases || vstacklet::error::display 89
				fi
			fi
		fi
		# @script-note: run silent update for newaliases
		newaliases >>"${vslog}" 2>&1 || vstacklet::error::display 95
		# @script-note: modify /etc/mail/sendmail.cf
		sed -i.bak -e "s/^DS.*$/DS${email}/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::error::display 90
		# @script-note: modify for sendmail to use domain or hostname
		if [[ -n ${domain} ]]; then
			# @script-note: check if MASQUERADE_AS is present in sendmail config - if not, add it
			if [[ $(grep -c "^MASQUERADE_AS" /etc/mail/sendmail.cf) -eq 0 ]]; then
				sed -i -e "s/#CL root/CL root\nMASQUERADE_AS(${domain})/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::error::display 90
			else
				sed -i -e "s/#CL root/CL root/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::error::display 90
				sed -i -e "s/^MASQUERADE_AS.*$/MASQUERADE_AS(${domain})/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::error::display 90
			fi
		else
			sed -i.bak -e "s/^#MASQUERADE_AS($(hostname --fqdn))/MASQUERADE_AS($(hostname --fqdn))/g" /etc/mail/sendmail.cf >>"${vslog}" 2>&1 || vstacklet::error::display 90
		fi
		vs::stat::progress::stop # stop progress status
		# @script-note: sendmail installation complete
		vstacklet::shell::text::green "sendmail installed and configured. see details below:"
		vstacklet::shell::text::white::sl "sendmail port: "
		vstacklet::shell::text::green "${sendmail_port:-587}"
		vstacklet::shell::text::white::sl "sendmail email: "
		vstacklet::shell::text::green "${email}"
		vstacklet::shell::text::white::sl "sendmail hostname: "
		if [[ -n ${domain} ]]; then
			vstacklet::shell::text::green "${domain}"
		else
			vstacklet::shell::text::green "$(hostname --fqdn)"
		fi
	fi
}

##################################################################################
# @name: vstacklet::wordpress::install (36)
# @description: Install WordPress. This will also configure WordPress to use
# the database that was created during the installation process. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2921-L3127)
#
# notes:
# - this function is only called under the following conditions:
#   - the option `-wp` is used directly
# - this function will install wordpress and configure the database.
# - wordpress is an active build option and requires active intput from the user (for now).
# these arguments are:
#   - wordpress database name
#   - wordpress database user
#   - wordpress database password
# - this function requires the following options to be used:
#   - database: `-mariadb | --mariadb` or `-mysql | --mysql` (only one can be used)
#   - webserver: `-nginx | --nginx` or `-varnish | --varnish` (both can be used)
#   - php: `-php | --php`
# - this function will optionally use the following options:
#   - web root: `-wr | --web_root` (default: /var/www/html/vsapp)
#
# @option: $1 - `-wp | --wordpress` (optional)
# @noargs
# @example: vstacklet -wp -mariadb -nginx -php "8.4" -wr "/var/www/html/vsapp"
# @example: vstacklet -wp -mysql -nginx -php "8.4"
# @example: vstacklet -wp -mariadb -nginx -php "8.4" -varnish -varnishP 80 -http 8080 -https 443
# @null
# @return_code: 96 - failed to download WordPress.
# @return_code: 97 - failed to extract WordPress.
# @return_code: 98 - failed to move WordPress to the web root.
# @return_code: 99 - failed to create WordPress upload directory.
# @return_code: 100 - failed to create WordPress configuration file.
# @return_code: 101 - failed to modify WordPress configuration file.
# @return_code: 102 - failed to create WordPress database.
# @return_code: 103 - failed to create WordPress database user.
# @return_code: 104 - failed to grant WordPress database user privileges.
# @return_code: 105 - failed to flush WordPress database privileges.
# @return_code: 106 - failed to remove WordPress installation files.
# @return_code: 107 - failed to install WordPress.
# @return_code: 108 - failed to install WordPress plugins [varnish-http-purge].
# @break
##################################################################################
vstacklet::wordpress::install() {
	# @script-note: check if WordPress has been selected
	if [[ -n ${wordpress} ]]; then
		declare wp_db_name wp_db_user wp_db_password
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "please enter the following information for WordPress:"
		# @script-note: get WordPress database name
		vstacklet::wp::db() {
			vstacklet::shell::text::white::sl "WordPress database name: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_db_name; do
				[[ -z ${wp_db_name} ]] && vstacklet::shell::text::error "WordPress database name cannot be empty." && vstacklet::shell::text::white::sl "WordPress database name: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress database user
		vstacklet::wp::user() {
			vstacklet::shell::text::white::sl "WordPress database user: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_db_user; do
				# @script-note: check if WordPress database user already exists, if so, use current user
				db_user_present="$(mysql -u root -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${wp_db_user}')")"
				if [[ "${db_user_present}" == "1" ]]; then
					vstacklet::shell::text::magenta::sl "Database user already exists: "
					vstacklet::shell::text::white "Using previously created database ${wp_db_user} user."
					[[ -n "${mysql_user}" ]] && wp_db_user="${mysql_user}"
					[[ -n "${mariadb_user}" ]] && wp_db_user="${mariadb_user}"
					#break
				fi
				# @script-note: check if WordPress database user is empty
				[[ -z ${wp_db_user} ]] && vstacklet::shell::text::error "WordPress database user cannot be empty." && vstacklet::shell::text::white::sl "WordPress database user: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress database password
		vstacklet::wp::password() {
			# @script-note: check if user_exists is set, if so, use current password
			if [[ "${db_user_present}" == "1" ]]; then
				vstacklet::shell::text::magenta::sl "Database user already exists: "
				vstacklet::shell::text::white "Using previously created database password for ${wp_db_user}."
				[[ -n "${mysql_password}" ]] && wp_db_password="${mysql_password}"
				[[ -n "${mariadb_password}" ]] && wp_db_password="${mariadb_password}"
			else
				vstacklet::shell::text::white::sl "WordPress database password: "
				vstacklet::shell::icon::arrow::white
				while read -r wp_db_password; do
					[[ -z ${wp_db_password} ]] && vstacklet::shell::text::error "WordPress database password cannot be empty." && vstacklet::shell::text::white::sl "WordPress database password: " && vstacklet::shell::icon::arrow::white && continue
					break
				done
			fi
		}
		# @script-note: get WordPress Site URL
		vstacklet::wp::site_url() {
			if [[ -n ${domain} ]]; then
				wp_site_url="https://${domain}"
			else
				wp_site_url="https://${server_ip}"
			fi
		}
		# @script-note: get WordPress Site Title
		vstacklet::wp::site_title() {
			vstacklet::shell::text::white::sl "WordPress Site Title: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_site_title; do
				[[ -z ${wp_site_title} ]] && vstacklet::shell::text::error "WordPress Site Title cannot be empty." && vstacklet::shell::text::white::sl "WordPress Site Title: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress Admin Username
		vstacklet::wp::admin_user() {
			vstacklet::shell::text::white::sl "WordPress Admin Username: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_admin_user; do
				[[ -z ${wp_admin_user} ]] && vstacklet::shell::text::error "WordPress Admin Username cannot be empty." && vstacklet::shell::text::white::sl "WordPress Admin Username: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress Admin Password
		vstacklet::wp::admin_password() {
			vstacklet::shell::text::white::sl "WordPress Admin Password: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_admin_password; do
				[[ -z ${wp_admin_password} ]] && vstacklet::shell::text::error "WordPress Admin Password cannot be empty." && vstacklet::shell::text::white::sl "WordPress Admin Password: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress Admin Email
		vstacklet::wp::admin_email() {
			vstacklet::shell::text::white::sl "WordPress Admin Email: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_admin_email; do
				[[ -z ${wp_admin_email} ]] && vstacklet::shell::text::error "WordPress Admin Email cannot be empty." && vstacklet::shell::text::white::sl "WordPress Admin Email: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: call Wordpress information functions
		vstacklet::wp::db
		vstacklet::wp::user
		vstacklet::wp::password
		vstacklet::wp::site_url
		vstacklet::wp::site_title
		vstacklet::wp::admin_user
		vstacklet::wp::admin_password
		vstacklet::wp::admin_email
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white::sl "Are the entered details correct? "
		vstacklet::shell::text::green::sl "[y]"
		vstacklet::shell::text::white::sl "es"
		vstacklet::shell::text::white::sl " or "
		vstacklet::shell::text::red::sl "[n]"
		vstacklet::shell::text::white::sl "o: "
		vstacklet::shell::icon::arrow::white
		read -r wp_input
		# @script-note: while loop to check if entered details are correct, if not, repeat
		while [[ ${wp_input,,} =~ ^(no|n)$ ]]; do
			vstacklet::wp::db
			vstacklet::wp::user
			vstacklet::wp::password
			vstacklet::wp::site_url
			vstacklet::wp::site_title
			vstacklet::wp::admin_user
			vstacklet::wp::admin_password
			vstacklet::wp::admin_email
			vstacklet::shell::misc::nl
			vstacklet::shell::text::white::sl "Are the entered details correct? "
			vstacklet::shell::text::green::sl "[y]"
			vstacklet::shell::text::white::sl "es"
			vstacklet::shell::text::white::sl " or "
			vstacklet::shell::text::red::sl "[n]"
			vstacklet::shell::text::white::sl "o: "
			vstacklet::shell::icon::arrow::white
			read -r wp_input
		done
		vstacklet::shell::misc::nl
		[[ ${wp_input,,} =~ ^(yes|y)$ ]] && declare wp_input_continue="true"
		if [[ ${wp_input_continue} == "true" ]]; then
			vstacklet::shell::text::white "installing and configuring WordPress ... "
			# @script-note: download WordPress
			vstacklet::log wget -q -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz || vstacklet::error::display 96
			# @script-note: extract WordPress
			vstacklet::log tar -xzf /tmp/wordpress.tar.gz -C /tmp || vstacklet::error::display 97
			# @script-note: move WordPress to the web root
			mv /tmp/wordpress/* "${web_root:-/var/www/html/vsapp}/public" || vstacklet::error::display 98
			# @script-note: create the uploads directory
			mkdir -p "${web_root:-/var/www/html/vsapp}/public/wp-content/uploads" || vstacklet::error::display 99
			# @script-note: download the WordPress CLI
			vstacklet::log wget -q -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
			# @script-note: set the correct permissions
			vstacklet::log chmod +x /usr/local/bin/wp
			vstacklet::shell::text::yellow::sl "configuring WordPress ... " &
			vs::stat::progress::start # @script-note: start progress status
			# @script-note: create the wp-config.php file
			vstacklet::log cp -f "${web_root:-/var/www/html/vsapp}/public/wp-config-sample.php" "${web_root:-/var/www/html/vsapp}/public/wp-config.php" || vstacklet::error::display 100
			# @script-note: modify the wp-config.php file
			sed -i \
				-e "s/database_name_here/${wp_db_name}/g" \
				-e "s/username_here/${wp_db_user}/g" \
				-e "s/password_here/${wp_db_password}/g" \
				-e "s/utf8mb4/utf8/g" \
				"${web_root:-/var/www/html/vsapp}/public/wp-config.php" || vstacklet::error::display 101
			# @script-note: remove old salt keys
			sed -i -e "/define( 'AUTH_KEY',/d" -e "/define( 'SECURE_AUTH_KEY',/d" -e "/define( 'LOGGED_IN_KEY',/d" -e "/define( 'NONCE_KEY',/d" -e "/define( 'AUTH_SALT',/d" -e "/define( 'SECURE_AUTH_SALT',/d" -e "/define( 'LOGGED_IN_SALT',/d" -e "/define( 'NONCE_SALT',/d" "${web_root:-/var/www/html/vsapp}/public/wp-config.php"
			# @script-note: import updated salt keys
			wp_salts=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
			sed -i "/#@-/r /dev/stdin" "${web_root:-/var/www/html/vsapp}/public/wp-config.php" <<<"${wp_salts}"
			# @script-note: add security constants to wp-config.php (disable file editor and set FS_METHOD to ssh2 for secure file transfers)
			sed -i "/Add any custom values between this line and the \"stop editing\" line./a \\\n/**\n * The plugins and themes file editor is a very convenient tool because it\n * enables you to make quick changes without the need to use FTP.\n *\n * Unfortunately, it's also a security issue because it not only shows the\n * PHP source code, it also enables attackers to inject malicious code into\n * your site if they manage to gain access to admin.\n * To prevent this, you can disable the file editor.\n *\n * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#disable-the-plugin-and-theme-file-editor\n */\n\ndefine('DISALLOW_FILE_EDIT', true);\ndefine('FS_METHOD', 'ssh2');\n" "${web_root:-/var/www/html/vsapp}/public/wp-config.php"
			# @script-note: create the database
			mysql -e "CREATE DATABASE ${wp_db_name};" >>"${vslog}" 2>&1 || vstacklet::error::display 102
			if [[ "${db_user_present}" != "1" ]]; then
				# @script-note: create the database user
				mysql -e "CREATE USER '${wp_db_user}'@'localhost' IDENTIFIED BY '${wp_db_password}';" >>"${vslog}" 2>&1 || vstacklet::error::display 103
			fi
			# @script-note: grant privileges to the database user
			mysql -e "GRANT ALL PRIVILEGES ON ${wp_db_name}.* TO '${wp_db_user}'@'localhost';" >>"${vslog}" 2>&1 || vstacklet::error::display 104
			# @script-note: flush privileges
			mysql -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::error::display 105
			# @script-note: remove the WordPress installation files
			vstacklet::log rm -rf /tmp/wordpress /tmp/wordpress.tar.gz || vstacklet::error::display 106
			# @script-note: run wp core install
			wp --path="${web_root:-/var/www/html/vsapp}/public" core install --url="${wp_site_url}" --title="${wp_site_title}" --admin_user="${wp_admin_user}" --admin_password="${wp_admin_password}" --admin_email="${wp_admin_email}" --allow-root >>"${vslog}" 2>&1 || vstacklet::error::display 107
			vs::stat::progress::stop # stop progress status
			if [[ -n ${varnish} ]]; then
				vstacklet::shell::text::yellow::sl "installing Proxy Cache Purge plugin ... " &
				# @script-note: if varnish is installed, install the varnish-http-purge plugin and activate it
				wp --path="${web_root:-/var/www/html/vsapp}/public" plugin install varnish-http-purge --activate --allow-root >>"${vslog}" 2>&1 || vstacklet::error::display 108
				vs::stat::progress::stop # stop progress status
			fi
			# @script-note: wordpress installation complete
			vstacklet::shell::text::green "WordPress installed and configured. see details below:"
			vstacklet::shell::text::white::sl "WordPress Database Name: "
			vstacklet::shell::text::green "${wp_db_name}"
			vstacklet::shell::text::white::sl "WordPress Database User: "
			vstacklet::shell::text::green "${wp_db_user}"
			vstacklet::shell::text::white::sl "WordPress Database Password: "
			vstacklet::shell::text::green "${wp_db_password}"
			vstacklet::shell::text::white::sl "WordPress Admin User: "
			vstacklet::shell::text::green "${wp_admin_user}"
			vstacklet::shell::text::white::sl "WordPress Admin Password: "
			vstacklet::shell::text::green "${wp_admin_password}"
			vstacklet::shell::text::white::sl "WordPress Admin Email: "
			vstacklet::shell::text::green "${wp_admin_email}"
			vstacklet::shell::text::white::sl "Login to your WordPress installation at: "
			vstacklet::shell::text::green "https://${domain:-${server_ip}}/wp-login.php"
			# @script-note: adjust web root permissions
			vstacklet::permissions::adjust
		fi
	fi
}

##################################################################################
# @name: vstacklet::cloudflare::token::setup (37)
# @description: Setup CloudFlare API token for DNS verification. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3145-L3175)
#
# notes:
# - This function prompts the user for their CloudFlare API token
# - Stores the token in the acme.sh account configuration
# - Required for DNS-based SSL certificate verification with CloudFlare
# - Must be called AFTER acme.sh installation to prevent account.conf overwrite
#
# @nooptions
# @noargs
# @return_code: 121 - failed to write CloudFlare token to account.conf.
# @break
##################################################################################
vstacklet::cloudflare::token::setup() {
	if [[ -n ${cf_token_required} ]]; then
		vstacklet::shell::misc::nl
		vstacklet::shell::text::yellow "CloudFlare DNS verification requires an API token."
		vstacklet::shell::text::white "Please create a CloudFlare API token with the following permissions:"
		vstacklet::shell::text::white "  - Zone:Zone:Read"
		vstacklet::shell::text::white "  - Zone:DNS:Edit"
		vstacklet::shell::text::white "Visit: https://dash.cloudflare.com/profile/api-tokens"
		vstacklet::shell::misc::nl

		read -rp "Enter your CloudFlare API Token: " CF_Token
		[[ -z ${CF_Token} ]] && vstacklet::shell::text::error "CloudFlare API token is required for DNS verification." && exit 1

		# Verify acme.sh config directory exists (should be created by acme.sh installation)
		if [[ ! -d "/root/.acme.sh" ]]; then
			vstacklet::shell::text::error "acme.sh configuration directory not found. This should not happen." && exit 1
		fi

		# Store the CloudFlare token in account.conf
		echo "CF_Token='${CF_Token}'" >>"/root/.acme.sh/account.conf" || vstacklet::error::display 121

		vstacklet::shell::text::success "CloudFlare API token configured successfully."
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::domain::ssl (38)
# @description: The following function installs the SSL certificate
#   for the domain. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3173-L3236)
#
# notes:
# - This function is only called under the following conditions:
#   - the option for `-d` is used (optional)
# - The following options are required for this function:
#   - `-d` or `--domain`
#   - `-e` or `--email`
# - The following options are optional for this function:
#   - `-http` or `--http`
#   - `-https` or `--https`
# - If you are using a custom port for HTTP and/or HTTPS, you can specify the port(s) using the `-http` and `-https` options.
# > [!TIP]
# > this is especially useful if you are using a reverse proxy like Varnish with Nginx.
# - The `-http` option is used to specify the custom port for HTTP.
# - The `-https` option is used to specify the custom port for HTTPS.
# @option: $1 - `-d | --domain` - The domain to install the SSL certificate for.
# @arg: $1 - `[domain]` (required)
# @option: $1 - `-e | --email` - The email address to use for the SSL certificate.
# @arg: $1 - `[email]` (required)
# @option: $1 - `--dns` - DNS provider for DNS-based verification (optional)
# @arg: $1 - `[dns_provider]` (optional, currently supports 'cloudflare')
# @option: $1 - `-http` (optional)
# @arg: $1 - `[http_port]` (optional)
# @option: $1 - `-https` (optional)
# @arg: $1 - `[https_port]` (optional)
# @example: vstacklet -nginx -d "example.com" -e "your@email.com"
# vstacklet --nginx --domain example.com --email "your@email.com"
# vstacklet -d "example.com" -e "your@email.com" -http "8080"
# vstacklet -d "example.com" -e "your@email.com" --dns "cloudflare"
# @null
# @return_code: 109 - failed to change directory to /root.
# @return_code: 110 - failed to create directory ${web_root}/.well-known/acme-challenge.
# @return_code: 111 - failed to clone acme.sh.
# @return_code: 112 - failed to switch to /root/acme.sh directory.
# @return_code: 113 - failed to install acme.sh.
# @return_code: 114 - failed to reload nginx.
# @return_code: 115 - failed to register the account with Let's Encrypt.
# @return_code: 116 - failed to set the default CA to Let's Encrypt.
# @return_code: 117 - failed to issue the certificate.
# @return_code: 118 - failed to install the certificate.
# @return_code: 119 - failed to edit /etc/nginx/sites-available/${domain}.conf.
# @return_code: 121 - failed to write CloudFlare token to account.conf.
# @break
##################################################################################
vstacklet::domain::ssl() {
	if [[ -n ${domain_ssl} ]]; then
		# @script-note: signal a service daemon reload and restart nginx
		[[ -f /run/nginx.pid ]] && rm -f /run/nginx.pid
		systemctl daemon-reload >>"${vslog}" 2>&1
		[[ -n ${varnish} ]] && systemctl restart varnish >>"${vslog}" 2>&1
		systemctl restart nginx >>"${vslog}" 2>&1
		# @script-note: testing:
		systemctl status nginx >>"${vslog}" 2>&1
		sleep 3
		vstacklet::shell::misc::nl
		if [[ -n ${dns_verification} ]]; then
			vstacklet::shell::text::white "installing SSL certificate for ${domain} using DNS verification ... "
		else
			vstacklet::shell::text::white "installing SSL certificate for ${domain} using HTTP verification ... "
		fi

		# @script-note: build acme.sh for Let's Encrypt SSL
		cd "/root" || vstacklet::error::display 109
		[[ -d "/root/.acme.sh" ]] && rm -rf "/root/.acme.sh" >>"${vslog}" 2>&1

		# @script-note: Only create webroot directories for HTTP verification
		if [[ -z ${dns_verification} ]]; then
			mkdir -p "${web_root:-/var/www/html/vsapp}/.well-known/acme-challenge" || vstacklet::error::display 110
			chown -R root:www-data "${web_root:-/var/www/html/vsapp}/.well-known" >>"${vslog}" 2>&1
			chmod -R 755 "${web_root:-/var/www/html/vsapp}/.well-known" >>"${vslog}" 2>&1
		fi

		if [[ ! -d "/root/acme.sh" ]]; then
			git clone "https://github.com/Neilpang/acme.sh.git" >>"${vslog}" 2>&1 || vstacklet::error::display 111
			cd "/root/acme.sh" || vstacklet::error::display 112
			./acme.sh --install --home "/root/.acme.sh" >>"${vslog}" 2>&1 || vstacklet::error::display 113
		else
			cd "/root/acme.sh" || vstacklet::error::display 112
		fi

		# @script-note: Setup CloudFlare token AFTER acme.sh installation to prevent overwriting
		[[ -n ${dns_verification} ]] && vstacklet::cloudflare::token::setup

		# @script-note: create nginx directory for SSL
		mkdir -p "/etc/nginx/ssl/${domain:?}"

		# @script-note: Only create nginx acme config for HTTP verification
		if [[ -z ${dns_verification} ]]; then
			# @script-note: create SSL certificate
			cp -f "${local_setup_dir}/templates/nginx/acme" "/etc/nginx/sites-enabled/"
			# @script-note: post necessary edits to nginx acme file
			wr_sanitize=$(echo "${web_root:-/var/www/html/vsapp}" | sed 's/\//\\\//g')
			sed -i -e "s|{{domain}}|${domain}|g" -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-${DEFAULT_PHP}}|g" /etc/nginx/sites-enabled/acme
			systemctl reload nginx.service >>"${vslog}" 2>&1 || vstacklet::error::display 114
		fi

		./acme.sh --register-account -m "${email:?}" >>"${vslog}" 2>&1 || vstacklet::error::display 115
		./acme.sh --set-default-ca --server letsencrypt >>"${vslog}" 2>&1 || vstacklet::error::display 116

		# @script-note: Issue certificate using appropriate verification method
		if [[ -n ${dns_verification} && ${dns_provider} == "cloudflare" ]]; then
			# DNS verification with CloudFlare
			./acme.sh --issue -d "${domain}" --dns dns_cf --server letsencrypt --debug >>"${vslog}" 2>&1 || vstacklet::error::display 117
		else
			# HTTP verification (default)
			./acme.sh --issue -d "${domain}" -w "${web_root:-/var/www/html/vsapp}" --server letsencrypt --debug >>"${vslog}" 2>&1 || vstacklet::error::display 117
		fi

		./acme.sh --install-cert -d "${domain}" --keylength ec-256 --cert-file "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" --key-file "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" --fullchain-file "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" --log "/var/log/vstacklet/${domain}.log" --reloadcmd "systemctl reload nginx.service" >>"${vslog}" 2>&1 || vstacklet::error::display 118
		# @script-note: post necessary edits to nginx config file
		crt_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" | sed 's/\//\\\//g')
		key_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" | sed 's/\//\\\//g')
		#chn_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" | sed 's/\//\\\//g')
		[[ -f "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" ]] && cp -f "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" "${vstacklet_base_path:?}/config/system/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1
		# @script-note: place generated ssl to nginx config file
		sed -i.bak -e "/ssl_certificate .*/c\        ssl_certificate ${crt_sanitize};" -e "/ssl_certificate_key .*/c\        ssl_certificate_key ${key_sanitize};" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1 || vstacklet::error::display 119
		# @script-note: remove acme ssl template (only if HTTP verification was used)
		[[ -f "/etc/nginx/sites-enabled/acme" ]] && rm -f "/etc/nginx/sites-enabled/acme" >>"${vslog}" 2>&1
		# @script-note: ssl installation complete
		if [[ -n ${dns_verification} ]]; then
			vstacklet::shell::text::green "Let's Encrypt SSL certificate installed for ${domain} using DNS verification! see details below:"
		else
			vstacklet::shell::text::green "Let's Encrypt SSL certificate installed for ${domain} using HTTP verification! see details below:"
		fi
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
#   This function will also enable and start services that were installed. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3250-L3277)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
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
	# @script-note: memcached only when its server package is installed (PHP is always set now, the memcached server is not)
	[[ -n ${php} && $(dpkg-query -W -f='${Status}' memcached 2>/dev/null) == *"ok installed"* ]] && services+=("memcached")
	[[ -n ${mysql} ]] && services+=("mysql")
	[[ -n ${mariadb} ]] && services+=("mariadb")
	[[ -n ${postgresql} ]] && services+=("postgresql")
	[[ -n ${sendmail} ]] && services+=("sendmail")
	#services+=("sshd")
	rm -rf "${vstacklet_base_path}/setup_temp"
	for service in "${services[@]}"; do
		vstacklet::log systemctl enable "${service}.service"
		vstacklet::log systemctl restart "${service}.service"
	done
	[[ -n ${nginx} ]] && rm -rf /etc/apache2 && rm -rf /usr/sbin/apache2
	iptables-save >/etc/iptables/rules.v4 2>>"${log_file}" || vstacklet::error::display 12
	unset service services
}

################################################################################
# @name: vstacklet::message::complete (39)
# @description: Outputs success message on completion of setup. This function
#   is called after the installation is complete. It outputs a success message
#   to the user and provides them with the necessary information to access their
#   new server. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3291-L3366)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::message::complete() {
	# @script-note: vstacklet end time
	vstacklet_end_time="$(date +%s)"
	# @script-note: vstacklet total time
	vstacklet_total_time="$((vstacklet_end_time - vstacklet_start_time))"
	# @script-note: vstacklet total time in minutes
	vstacklet_total_time_minutes="$((vstacklet_total_time / 60))"
	# @script-note: display success message
	vstacklet::shell::misc::nl
	vstacklet::shell::text::green "vStacklet Server Installation Complete! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
	vstacklet::shell::text::green " - Installation Completed in: ${vstacklet_total_time_minutes}/min"
	vstacklet::shell::text::white " - SSH port: ${ssh_port:-22}"
	vstacklet::shell::text::white " - FTP port: ${ftp_port:-21}"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Be sure to review the above output from the vStacklet installation process"
	vstacklet::shell::text::white "for relevant information regarding your new server and connection details."
	vstacklet::shell::misc::nl
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
	# @script-note: reload bashrc
	source /root/.bashrc
}

##################################################################################
# @name: vstacklet::marker::write (38.1)
# @description: Writes the 4.x install marker after every step has finished. The gate refuses a second install where it exists, and --check_update needs it.
# @return_code: 120 - failed to write the install marker.
##################################################################################
vstacklet::marker::write() {
	local version branch
	version="$(awk '/^# @version:/ {print $3; exit}' "${vstacklet_base_path}/setup/vstacklet-server-stack.sh")"
	branch="$(cat "${vstacklet_base_path}/config/system/branch" 2>/dev/null || true)"
	{ mkdir -p "${VSTACKLET_MARKER%/*}" && printf 'version=%s\nbranch=%s\ninstalled=%s\n' "${version:-unknown}" "${branch:-unknown}" "$(date +%F)" >"${VSTACKLET_MARKER}"; } || vstacklet::error::display 120
}

################################################################################
# @name: vstacklet::help::display (40)
# @description: Displays the help menu for vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3347-L3448)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::help::display() {
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet Help Menu"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -h, --help"
	vstacklet::shell::text::white "    Displays this help menu."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -V, --version"
	vstacklet::shell::text::white "    Displays the current version of vStacklet."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -r, --reboot"
	vstacklet::shell::text::white "    Reboots the server after installation is complete."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -d, --domain"
	vstacklet::shell::text::white "    Sets the domain name for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -dns, --dns"
	vstacklet::shell::text::white "    Enables DNS-based SSL certificate verification (useful for local development)."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -e, --email"
	vstacklet::shell::text::white "    Sets the email address for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -ftp, --ftp"
	vstacklet::shell::text::white "    Sets the FTP port for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -hn, --hostname"
	vstacklet::shell::text::white "    Sets the hostname for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -https, --https_port"
	vstacklet::shell::text::white "    Sets the HTTPS port for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -http, --http_port"
	vstacklet::shell::text::white "    Sets the HTTP port for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -ioncube, --ioncube"
	vstacklet::shell::text::white "    Installs IonCube."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mariadb, --mariadb"
	vstacklet::shell::text::white "    Installs and configures MariaDB."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mariadbU, --mariadb_user"
	vstacklet::shell::text::white "    Sets the MariaDB username."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mariadbPw, --mariadb_password"
	vstacklet::shell::text::white "    Sets the MariaDB password."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mariadbP, --mariadb_port"
	vstacklet::shell::text::white "    Sets the MariaDB port."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysql, --mysql"
	vstacklet::shell::text::white "    Installs and configures MySQL."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysqlU, --mysql_user"
	vstacklet::shell::text::white "    Sets the MySQL username."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysqlPw, --mysql_password"
	vstacklet::shell::text::white "    Sets the MySQL password."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysqlP, --mysql_port"
	vstacklet::shell::text::white "    Sets the MySQL port."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -nginx, --nginx"
	vstacklet::shell::text::white "    Installs and configures Nginx."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -pma, --phpmyadmin"
	vstacklet::shell::text::white "    Installs and configures phpMyAdmin."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -php, --php"
	vstacklet::shell::text::white "    Installs and configures PHP."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -sendmail, --sendmail"
	vstacklet::shell::text::white "    Installs and configures Sendmail."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -sendmailP, --sendmail_port"
	vstacklet::shell::text::white "    Sets the Sendmail port."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -ssh, --ssh_port"
	vstacklet::shell::text::white "    Sets the SSH port."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -varnish, --varnish"
	vstacklet::shell::text::white "    Installs and configures Varnish."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -varnishP, --varnish_port"
	vstacklet::shell::text::white "    Sets the Varnish port."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -wp, --wordpress"
	vstacklet::shell::text::white "    Installs and configures WordPress."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -wr, --web_root"
	vstacklet::shell::text::white "    Sets the web root for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "example with standard HTTP-based SSL verification: "
	vstacklet::shell::text::white "vstacklet -nginx -php '8.3' -mariadb -mariadbU 'username' -mariadbPw 'password' -varnish -wp -pma -ioncube -wr '/var/www/html/vsapp' -d 'example.com' -e 'your@email.com'"
	vstacklet::shell::misc::nl
	# Example with DNS-based SSL verification
	vstacklet::shell::text::white "example with DNS-based SSL verification: "
	vstacklet::shell::text::white "vstacklet -nginx -php '8.3' -mariadb -mariadbU 'username' -mariadbPw 'password' -wp -pma -wr '/var/www/html/vsapp' -d 'example.com' -e 'your@email.com' --dns 'cloudflare'"
	vstacklet::shell::misc::nl
	exit 0
}

################################################################################
# @name: vstacklet::version::display (41)
# @description: Displays the current version of vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3459-L3468)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::version::display() {
	vstacklet_version="$(grep -oP '(?<=Version: v)[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' <"${vstacklet_base_path}"/README.md)"
	vstacklet_sa_version="$(grep -E '^# @version:' "${vstacklet_base_path}/setup/vstacklet-server-stack.sh" | awk '{print $3}')"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet Full Kit Version: ${vstacklet_version}"
	vstacklet::shell::text::white "vStacklet Server Stack Version: ${vstacklet_sa_version}"
	vstacklet::shell::text::white "vStacklet Branch: $(cat "${vstacklet_base_path}"/config/system/branch)"
	vstacklet::shell::misc::nl
	exit 0
}

################################################################################
# @name: vstacklet::error::display - vStacklet Error Messages
# @description: Displays error messages for vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3478-L3648)
#
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::error::display() {
	declare error
	# @script-note: stop the progress spinner first, so it does not draw over the error
	[[ -n ${pg_pid} ]] && kill -9 "${pg_pid}" 2>/dev/null
	if [[ -n $1 ]]; then
		case $1 in
		# vstacklet::environment::checkroot (7)
		1) error="you must be root to run this script." ;;
		# vstacklet::environment::checkdistro (8)
		2) error="this script only supports Ubuntu 20.04/22.04 and Debian 11/12." ;;
		# vstacklet::dependencies::install (6)
		3) error="failed to install script dependencies." ;;
		# vstacklet::base::dependencies (12)
		4) error="failed to install base dependencies." ;;
		# vstacklet::source::dependencies (13)
		5) error="failed to install source dependencies." ;;
		# vstacklet::hostname::set (15)
		6) error="failed to set hostname." ;;
		# vstacklet::ssh::set (17)
		7) error="failed to set SSH port." ;;
		8) error="failed to restart SSH daemon service." ;;
		# vstacklet::ftp::set (18)
		9) error="failed to set FTP port." ;;
		10) error="failed to restart FTP daemon service." ;;
		# vstacklet::block::ssdp (19)
		11) error="failed to block SSDP port." ;;
		12) error="failed to save iptables rules." ;;
		# vstacklet::locale::set (22)
		13) error="failed to set locale." ;;
		# vstacklet::php::install (23)
		15) error="failed to install PHP dependencies." ;;
		# vstacklet::nginx::install (25)
		20) error="failed to install NGINX dependencies." ;;
		21) error="failed to edit NGINX configuration file." ;;
		22) error="failed to enable NGINX configuration." ;;
		23) error="failed to generate dhparam file." ;;
		24) error="failed to generate self-signed certificate." ;;
		25) error="failed to create the web root's public folder." ;;
		# vstacklet::varnish::install (26)
		26) error="failed to install Varnish dependencies." ;;
		27) error="could not switch to /etc/varnish directory." ;;
		28) error="failed to edit the Varnish default configuration file." ;;
		29) error="failed to reload the systemd daemon." ;;
		30) error="failed to switch to ~/" ;;
		# vstacklet::ioncube::install (28)
		31) error="failed to switch to /tmp directory." ;;
		32) error="failed to download ionCube Loader." ;;
		33) error="failed to extract ionCube Loader." ;;
		34) error="failed to switch to /tmp/ioncube directory." ;;
		35) error="failed to copy ionCube loader to /usr/lib/php/ directory." ;;
		# vstacklet::mariadb::install (29)
		36) error="failed to install MariaDB dependencies." ;;
		37) error="failed to initialize MariaDB secure installation." ;;
		38) error="failed to set MariaDB client and server configuration." ;;
		39) error="failed to set MariaDB .my.cnf configuration." ;;
		40) error="failed to create MariaDB user." ;;
		41) error="failed to create MariaDB user privileges." ;;
		42) error="failed to flush MariaDB privileges." ;;
		# vstacklet::mysql::install (30)
		43) error="failed to download MySQL deb package." ;;
		44) error="failed to install MySQL deb package." ;;
		45) error="failed to install MySQL dependencies." ;;
		46) error="failed to set MySQL client and server configuration." ;;
		47) error="failed to set MySQL .my.cnf file." ;;
		48) error="failed to create MySQL user." ;;
		49) error="failed to grant MySQL user privileges." ;;
		50) error="failed to flush MySQL privileges." ;;
		# vstacklet::postgresql::install (31)
		51) error="failed to install PostgreSQL dependencies." ;;
		52) error="could not switch to /etc/postgresql/${postgre_version}/main directory." ;;
		53) error="failed to set PostgreSQL password." ;;
		54) error="failed to create PostgreSQL user." ;;
		55) error="failed to grant PostgreSQL user privileges." ;;
		56) error="failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file." ;;
		57) error="failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file." ;;
		# vstacklet::redis::install (32)
		58) error="failed to install Redis dependencies." ;;
		59) error="failed to backup the Redis configuration file." ;;
		60) error="failed to import the Redis configuration file." ;;
		61) error="failed to modify the Redis configuration file." ;;
		62) error="failed to restart Redis service." ;;
		63) error="failed to set the Redis password." ;;
		# vstacklet::phpmyadmin::install (33)
		64) error="failed to install phpMyAdmin dependencies." ;;
		65) error="failed to switch to /usr/share directory." ;;
		66) error="failed to download phpMyAdmin." ;;
		67) error="failed to extract phpMyAdmin." ;;
		68) error="failed to move phpMyAdmin to /usr/share directory." ;;
		69) error="failed to remove phpMyAdmin .tar.gz file." ;;
		70) error="failed to set ownership of phpMyAdmin directory." ;;
		71) error="failed to set permissions of phpMyAdmin directory." ;;
		72) error="failed to create /usr/share/phpmyadmin/tmp directory." ;;
		73) error="failed to set symlink of ./phpmyadmin to ${web_root}/public/phpmyadmin." ;;
		74) error="failed to create htpasswd file." ;;
		75) error="failed to create phpMyAdmin configuration file." ;;
		# vstacklet::sendmail::install (35)
		88) error="failed to install sendmail dependencies." ;;
		89) error="failed to edit aliases file." ;;
		90) error="failed to edit sendmail.cf file." ;;
		91) error="failed to edit main.cf file." ;;
		92) error="failed to edit master.cf file." ;;
		93) error="failed to create sasl_passwd file." ;;
		94) error="postmap failed." ;;
		95) error="failed to source new aliases." ;;
		# vstacklet::wordpress::install (36)
		96) error="failed to download WordPress." ;;
		97) error="failed to extract WordPress." ;;
		98) error="failed to move WordPress to ${web_root:-/var/www/html/vsapp}/public directory." ;;
		99) error="failed to create WordPress upload directory." ;;
		100) error="failed to create WordPress configuration file." ;;
		101) error="failed to modify WordPress configuration file." ;;
		102) error="failed to create WordPress database." ;;
		103) error="failed to create WordPress database user." ;;
		104) error="failed to grant WordPress database user privileges." ;;
		105) error="failed to flush WordPress database privileges." ;;
		106) error="failed to remove WordPress installation files." ;;
		107) error="failed to install WordPress core." ;;
		108) error="failed to install WordPress plugins [varnish-http-purge]." ;;
		# vstacklet::domain::ssl (37)
		109) error="failed to change directory to /root." ;;
		110) error="failed to create directory ${web_root:-/var/www/html/vsapp}/.well-known/acme-challenge." ;;
		111) error="failed to clone acme.sh." ;;
		112) error="failed to switch to /root/acme.sh directory." ;;
		113) error="failed to install acme.sh." ;;
		114) error="failed to reload nginx." ;;
		115) error="failed to register the account with Let's Encrypt." ;;
		116) error="failed to set the default CA to Let's Encrypt." ;;
		117) error="failed to issue the certificate." ;;
		118) error="failed to install the certificate." ;;
		119) error="failed to edit /etc/nginx/sites-available/${domain}.conf." ;;
		# vstacklet::marker::write (38.1)
		120) error="failed to write the install marker." ;;
		log) error="a step failed: ${vstacklet_failed_step:-unknown}" ;;
		apt) error="apt-get update failed: a package repository could not be fetched or verified (the failing repository is named in the log)." ;;
		*) error="Unknown error" ;;
		esac
		vstacklet::shell::text::error "${error}"
	else
		vstacklet::shell::text::warning "installer has been interrupted"
	fi
	if [[ "${rollback}" != "1" ]]; then
		# @script-note: fail closed (4.0): a failed step stops the install; nothing is undone, the server is rebuilt
		vstacklet::shell::misc::nl
		if [[ -n ${vstacklet_changes_started} ]]; then
			vstacklet::shell::text::error "the install has stopped and this server is now partly configured. To bring it back to the state recorded when the installer first changed it (the bootstrap's own tools stay), run:"
			vstacklet::shell::text::white "vstacklet --rollback"
			vstacklet::shell::text::error "If the rollback cannot bring the server back to a clean state, rebuild it from a fresh image."
		else
			vstacklet::shell::text::error "the install has stopped before any change was made to this server."
		fi
		vstacklet::shell::text::white " - log of this run: ${vslog:-none (stopped before the log was created)}"
		vstacklet::shell::text::white " - to report a problem: https://github.com/JMSDOnline/vstacklet/issues (include the error above, the log, the vStacklet version ${vstacklet_version:-unknown} and the server's OS and version)"
		vstacklet::shell::misc::nl
	else
		if [[ -n ${rollback_started} ]]; then
			vstacklet::shell::text::error "The rollback stopped part-way. Run vstacklet --rollback again to finish it."
		else
			vstacklet::shell::text::error "The rollback process has been cancelled; nothing was changed."
		fi
		vstacklet::shell::misc::nl
	fi
	exit 1
}
trap '[[ -n ${pg_pid} ]] && kill -9 "${pg_pid}" 2>/dev/null; vstacklet::error::display' SIGINT SIGTERM SIGHUP

################################################################################
# @name: vstacklet::rollback::baseline
# @description: Records the server's state before the installer's first change, so vstacklet --rollback can bring it back: every installed or half-installed package by its full name, the manual marks, the apt sources and keys, the enabled units, root's crontab, five system files, and which installer paths existed. Each install that passes the fresh-server gate records afresh. The record is built in a temporary folder and ends with a manifest (machine id, release, architecture, a hash of every file) that the rollback checks before it changes anything. Stored in /root/vstacklet/baseline (mode 700).
# @return_code: 1 - the record could not be written; nothing was changed.
################################################################################
vstacklet::rollback::paths() {
	printf '%s\n' /etc/vstacklet /etc/nginx /etc/nginx-pre-vstacklet /etc/systemd/system/nginx.service.d /etc/php /etc/mysql /var/lib/mysql /etc/varnish /etc/redis /var/lib/redis /etc/postgresql /var/lib/postgresql /etc/phpmyadmin /usr/share/phpmyadmin /etc/iptables /etc/vsftpd.conf /etc/vsftpd.chroot_list /etc/vsftpd /etc/mail /root/.my.cnf /root/.acme.sh /root/acme.sh /usr/local/bin/wp /var/www /usr/share/keyrings/nginx-archive-keyring.gpg /usr/share/keyrings/redis-archive-keyring.gpg
}
vstacklet::rollback::files() {
	printf '%s\n' /etc/hosts /etc/hostname /etc/ssh/sshd_config /root/.bashrc /root/.profile
}
vstacklet::rollback::installed() {
	dpkg-query -W -f='${db:Status-Status} ${binary:Package}\n' | awk '$1 != "not-installed" && $1 != "config-files" {print $2}' | LC_ALL=C sort -u
}
vstacklet::rollback::units() {
	systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | LC_ALL=C sort -u
}
vstacklet::rollback::identity() {
	printf 'machine-id=%s\nrelease=%s %s\narch=%s\n' "$(cat /etc/machine-id 2>/dev/null)" "${distro}" "${codename}" "${vstacklet_arch}"
}
vstacklet::rollback::baseline() {
	local -x LC_ALL=C
	local - p
	set -o pipefail
	local root=/root/vstacklet b=/root/vstacklet/baseline t=/root/vstacklet/baseline.new
	if [[ -n $(dpkg --audit 2>&1) ]]; then
		vstacklet::shell::text::error "apt or dpkg is busy, or a package is half-installed. Wait for it to finish (or run dpkg --configure -a), then run the installer again."
		return 1
	fi
	if [[ -L ${root} || -L ${b} ]]; then
		vstacklet::shell::text::error "${root} or ${b} is a symbolic link; remove it, then run the installer again."
		return 1
	fi
	{ mkdir -p "${root}" && chmod 700 "${root}" && rm -rf "${t}" && mkdir -p "${t}/apt" && chmod 700 "${t}"; } || return 1
	vstacklet::rollback::installed >"${t}/packages" || return 1
	for p in dpkg apt base-files; do
		grep -qxE "${p}(:[a-z0-9]+)?" "${t}/packages" || return 1
	done
	apt-mark showmanual | sort -u >"${t}/packages.manual" || return 1
	vstacklet::rollback::units >"${t}/units.enabled" || return 1
	[[ -s ${t}/packages.manual && -s ${t}/units.enabled ]] || return 1
	crontab -l -u root >"${t}/crontab.root" 2>/dev/null || rm -f "${t}/crontab.root"
	for p in /etc/apt/sources.list /etc/apt/sources.list.d /etc/apt/keyrings /etc/apt/trusted.gpg.d /etc/apt/preferences.d; do
		if [[ -e ${p} ]]; then cp -a "${p}" "${t}/apt/" || return 1; fi
	done
	while IFS= read -r p; do
		if [[ -f ${p} ]]; then cp -a "${p}" "${t}/files${p//\//_}" || return 1; fi
	done < <(vstacklet::rollback::files)
	vstacklet::rollback::paths >"${t}/paths.checked" || return 1
	while IFS= read -r p; do
		if [[ -e ${p} || -L ${p} ]]; then printf '%s\n' "${p}"; fi
	done <"${t}/paths.checked" >"${t}/paths.present"
	{
		vstacklet::rollback::identity
		printf 'recorded=%s\n' "$(date '+%F %H:%M %Z')"
		(cd "${t}" && find . -type f ! -name 'complete*' -print0 | sort -z | xargs -0 -r sha256sum)
	} >"${t}/complete.tmp" || return 1
	{ sync && mv "${t}/complete.tmp" "${t}/complete" && rm -rf "${b}" && mv "${t}" "${b}" && sync; } || return 1
}

################################################################################
# @name: vstacklet::rollback::check
# @description: Succeeds only when /root/vstacklet/baseline is a complete record of this server: real folders owned by root with mode 700, the same machine id, release and architecture, every file listed in the manifest and every hash matching.
################################################################################
vstacklet::rollback::check() {
	local -x LC_ALL=C
	local root=/root/vstacklet b=/root/vstacklet/baseline f
	[[ -d ${root} && ! -L ${root} && -d ${b} && ! -L ${b} && -f ${b}/complete && ! -L ${b}/complete ]] || return 1
	[[ $(stat -c '%u %a' "${root}") == "0 700" && $(stat -c '%u %a' "${b}") == "0 700" ]] || return 1
	[[ $(head -n 3 "${b}/complete") == "$(vstacklet::rollback::identity)" ]] || return 1
	for f in packages packages.manual units.enabled paths.checked paths.present; do
		grep -qE "^[0-9a-f]{64}  \./${f}\$" "${b}/complete" || return 1
	done
	[[ $(cd "${b}" && find . -type f ! -name complete | wc -l) -eq $(grep -cE '^[0-9a-f]{64}  \./' "${b}/complete") ]] || return 1
	(cd "${b}" && grep -E '^[0-9a-f]{64}  \./' complete | sha256sum --quiet --strict -c - >/dev/null 2>&1) || return 1
}

################################################################################
# @name: vstacklet::rollback::plan
# @description: Works out what a rollback would change and stops before any change when it would remove something that was there before: the packages added since the record (boot, kernel, SSH and package-manager packages are left in place and listed), a simulated purge that must not take any recorded package with it, the units to disable and to enable again, the installer paths to delete (named in plain words when they hold sites or databases), and the files and apt sources that differ. With "quiet" it only refreshes the lists.
################################################################################
vstacklet::rollback::plan() {
	local -x LC_ALL=C
	local - p out size
	set -o pipefail
	local b=/root/vstacklet/baseline
	local -a added=() lost=()
	declare -ga rb_purge=() rb_kept=() rb_units_off=() rb_units_on=() rb_paths=() rb_files=() rb_apt=()
	mapfile -t added < <(comm -13 <(sort -u "${b}/packages") <(vstacklet::rollback::installed))
	for p in "${added[@]}"; do
		if [[ ${p%%:*} =~ ^(linux-(image|modules|headers)|linux-.*-signed|grub|shim|initramfs-tools|firmware-|openssh-|systemd|cloud-init|qemu-guest-agent|sudo$|apt$|dpkg$) ]]; then rb_kept+=("${p}"); else rb_purge+=("${p}"); fi
	done
	if ((${#rb_purge[@]})); then
		if ! out="$(apt-get -s purge "${rb_purge[@]}" 2>&1)"; then
			vstacklet::shell::text::error "apt could not plan the removal of the added packages; nothing was changed."
			printf '%s\n' "${out}" | tail -n 5
			return 1
		fi
		mapfile -t lost < <(printf '%s\n' "${out}" | awk '$1 == "Purg" || $1 == "Remv" {print $2}' | sed 's/:.*//' | sort -u | comm -12 - <(sed 's/:.*//' "${b}/packages" | sort -u))
		if ((${#lost[@]})); then
			vstacklet::shell::text::error "removing the added packages would also remove packages that were here before: ${lost[*]}. Nothing was changed. Rebuild the server from a fresh image."
			return 1
		fi
	fi
	mapfile -t rb_units_off < <(comm -13 <(sort -u "${b}/units.enabled") <(vstacklet::rollback::units))
	mapfile -t rb_units_on < <(comm -23 <(sort -u "${b}/units.enabled") <(vstacklet::rollback::units))
	while IFS= read -r p; do
		[[ -n ${p} && ${p} == /* ]] || continue
		grep -qxF -- "${p}" "${b}/paths.checked" || continue
		grep -qxF -- "${p}" "${b}/paths.present" && continue
		if [[ -e ${p} || -L ${p} ]]; then rb_paths+=("${p}"); fi
	done < <(vstacklet::rollback::paths)
	while IFS= read -r p; do
		if [[ -f ${b}/files${p//\//_} ]] && ! cmp -s "${b}/files${p//\//_}" "${p}"; then rb_files+=("${p}"); fi
	done < <(vstacklet::rollback::files)
	for p in sources.list sources.list.d keyrings trusted.gpg.d preferences.d; do
		if [[ -e ${b}/apt/${p} || -e /etc/apt/${p} ]] && ! diff -rq "${b}/apt/${p}" "/etc/apt/${p}" >/dev/null 2>&1; then rb_apt+=("/etc/apt/${p}"); fi
	done
	[[ ${1-} == "quiet" ]] && return 0
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet will bring this server back to the state it recorded on $(sed -n 's/^recorded=//p' "${b}/complete") (the bootstrap's own tools stay). It will:"
	vstacklet::shell::text::white " - remove ${#rb_purge[@]} packages added since then: ${rb_purge[*]:-none}"
	((${#rb_kept[@]})) && vstacklet::shell::text::white " - leave in place ${#rb_kept[@]} boot, kernel, SSH or package-manager packages added since then (remove them yourself if you do not want them): ${rb_kept[*]}"
	vstacklet::shell::text::white " - disable ${#rb_units_off[@]} services added since then: ${rb_units_off[*]:-none}; enable again: ${rb_units_on[*]:-none}"
	vstacklet::shell::text::white " - restore the package sources that differ: ${rb_apt[*]:-none}; restore these files: ${rb_files[*]:-none}"
	for p in "${rb_paths[@]}"; do
		size="$(du -sh -- "${p}" 2>/dev/null | cut -f1)"
		case "${p}" in
		/var/lib/mysql | /var/lib/postgresql) vstacklet::shell::text::warning " - delete ${p} (${size:-?}): every database on this server" ;;
		/var/www) vstacklet::shell::text::warning " - delete ${p} (${size:-?}): every site and file under it" ;;
		*) vstacklet::shell::text::white " - delete ${p} (${size:-?})" ;;
		esac
	done
	return 0
}

################################################################################
# @name: vstacklet::rollback::restore
# @description: Applies the plan: finishes any interrupted dpkg run, swaps the recorded apt sources back in, disables the services added since the record, removes exactly the planned packages, reinstalls recorded packages that went missing, applies only the differences in the manual marks, deletes the planned installer paths, restores the files, root's crontab and the SSH listener, then compares packages, units, paths and sources with the record. Succeeds only when nothing differs.
################################################################################
vstacklet::rollback::restore() {
	local -x LC_ALL=C DEBIAN_FRONTEND=noninteractive
	local - p u rc=0 apt_ok=1 left gone port
	set -o pipefail
	local b=/root/vstacklet/baseline s=/etc/apt/.vstacklet-restore
	local -a apt_opts=(-y -o DPkg::Lock::Timeout=300 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold) missing=()
	vstacklet::rollback::check || { vstacklet::shell::text::error "the install record changed after it was checked; nothing was changed." && return 1; }
	vstacklet::shell::text::white "finishing any interrupted package operation ..."
	if ! dpkg --configure -a >/dev/null 2>&1 || [[ -n $(dpkg --audit 2>&1) ]]; then
		vstacklet::shell::text::error "dpkg could not finish an interrupted package operation (see dpkg --audit); nothing else was changed."
		return 1
	fi
	vstacklet::rollback::plan quiet || return 1
	vstacklet::shell::text::white "restoring the package sources ..."
	rm -rf "${s}" && mkdir -p "${s}" || return 1
	for p in sources.list sources.list.d keyrings trusted.gpg.d preferences.d; do
		if [[ -e ${b}/apt/${p} ]] && ! cp -a "${b}/apt/${p}" "${s}/"; then
			rm -rf "${s}"
			vstacklet::shell::text::error "could not copy the recorded apt sources; nothing was changed."
			return 1
		fi
	done
	for p in sources.list sources.list.d keyrings trusted.gpg.d preferences.d; do
		rm -rf "/etc/apt/${p:?}"
		if [[ -e ${s}/${p} ]]; then mv "${s}/${p}" /etc/apt/ || rc=1; fi
	done
	rm -rf "${s}"
	vstacklet::shell::text::white "stopping and disabling services added since the record ..."
	for u in "${rb_units_off[@]}"; do
		systemctl disable --now "${u}" >/dev/null 2>&1 || rc=1
		vstacklet::shell::text::white " - ${u}"
	done
	if ! apt-get -o DPkg::Lock::Timeout=300 -qq update --error-on=any >/dev/null 2>&1; then
		apt_ok=0
		vstacklet::shell::text::warning "apt-get update could not fetch every restored source; packages that went missing will not be reinstalled."
	fi
	vstacklet::shell::text::white "removing the ${#rb_purge[@]} packages added since the record ..."
	if ((${#rb_purge[@]})); then
		apt-get "${apt_opts[@]}" purge "${rb_purge[@]}" >/dev/null 2>&1 || { rc=1 && vstacklet::shell::text::warning "apt-get purge reported a problem; the comparison below shows what is left."; }
	fi
	mapfile -t missing < <(comm -23 <(sort -u "${b}/packages") <(vstacklet::rollback::installed))
	if ((${#missing[@]})); then
		if ((apt_ok)); then
			vstacklet::shell::text::white "reinstalling ${#missing[@]} recorded packages that went missing ..."
			apt-get "${apt_opts[@]}" --no-install-recommends install "${missing[@]}" >/dev/null 2>&1 || rc=1
		else
			rc=1
		fi
	fi
	vstacklet::shell::text::white "restoring the manual package marks ..."
	comm -12 <(comm -13 <(apt-mark showmanual | sort -u) <(sort -u "${b}/packages.manual")) <(dpkg-query -W -f='${Package}\n' | sort -u) | xargs -r apt-mark manual >/dev/null 2>&1 || rc=1
	comm -23 <(apt-mark showmanual | sort -u) <(sort -u "${b}/packages.manual") | xargs -r apt-mark auto >/dev/null 2>&1 || rc=1
	vstacklet::shell::text::white "removing installer paths that did not exist before the record ..."
	for p in "${rb_paths[@]}"; do
		rm -rf -- "${p}" || rc=1
		vstacklet::shell::text::white " - ${p}"
	done
	for p in "${rb_files[@]}"; do
		if [[ ${p} == /etc/ssh/sshd_config ]] && ! sshd -t -f "${b}/files${p//\//_}" >/dev/null 2>&1; then
			vstacklet::shell::text::warning "the recorded ${p} does not pass sshd -t here; the current one is kept."
			rc=1
			continue
		fi
		cp -a "${b}/files${p//\//_}" "${p}" || rc=1
		vstacklet::shell::text::white " - restored ${p}"
	done
	if [[ -f ${b}/crontab.root ]]; then
		crontab -l -u root 2>/dev/null | cmp -s - "${b}/crontab.root" || crontab -u root "${b}/crontab.root" || rc=1
	elif crontab -l -u root >/dev/null 2>&1; then
		crontab -r -u root || rc=1
	fi
	[[ -f /etc/hostname ]] && { hostnamectl set-hostname "$(cat /etc/hostname)" >/dev/null 2>&1 || rc=1; }
	while iptables -D INPUT -p udp -m udp --dport 1900 -j DROP 2>/dev/null; do :; done
	while iptables -D INPUT -p tcp --destination-port 10090:10100 -j ACCEPT 2>/dev/null; do :; done
	systemctl daemon-reload >/dev/null 2>&1
	for u in "${rb_units_on[@]}"; do systemctl enable "${u}" >/dev/null 2>&1 || rc=1; done
	if systemctl is-enabled --quiet ssh.socket 2>/dev/null; then systemctl restart ssh.socket >/dev/null 2>&1 || rc=1; else systemctl restart ssh.service >/dev/null 2>&1 || rc=1; fi
	apt-get -y autoclean >/dev/null 2>&1
	# @script-note: compare with the record, so "rolled back" means nothing differs
	vstacklet::rollback::plan quiet || rc=1
	left=$(comm -13 <(sort -u "${b}/packages") <(vstacklet::rollback::installed) | wc -l)
	gone=$(comm -23 <(sort -u "${b}/packages") <(vstacklet::rollback::installed) | wc -l)
	vstacklet::shell::text::white "differences from the record: packages ${left} added and ${gone} missing (${#rb_kept[@]} of the added left in place on purpose), services ${#rb_units_off[@]} added and ${#rb_units_on[@]} missing, installer paths ${#rb_paths[@]}, package sources ${#rb_apt[@]}, files ${#rb_files[@]}"
	port="$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}')"
	vstacklet::shell::text::white "SSH is configured on port ${port:-unknown}; open a new session to check it before you close this one."
	[[ ${rc} -eq 0 && $((left - ${#rb_kept[@]})) -eq 0 && ${gone} -eq 0 && ${#rb_units_off[@]} -eq 0 && ${#rb_units_on[@]} -eq 0 && ${#rb_paths[@]} -eq 0 && ${#rb_apt[@]} -eq 0 && ${#rb_files[@]} -eq 0 ]]
}

################################################################################
# @name: vstacklet::rollback
# @description: Brings a server back to the state recorded before vStacklet's first change. It refuses, changing nothing, when the record is missing (a server set up by an earlier vStacklet version), damaged or from another server. It shows the full plan first, including any sites and databases it would delete, and goes ahead only on the word yes. A lock stops a second rollback, a dropped connection does not stop this one, and the run is logged in /root/vstacklet. The install markers are cleared, so the installer can run again, only when nothing differs from the record afterwards.
# @nooptions
# @noargs
#
# @example: vstacklet --rollback
# @break
################################################################################
vstacklet::rollback() {
	local confirm u rc=0
	local -a held=()
	if ! vstacklet::rollback::check; then
		if [[ -e /root/vstacklet/baseline ]]; then
			vstacklet::shell::text::error "this server's install record (/root/vstacklet/baseline) is damaged or belongs to another server; nothing was changed. Rebuild the server from a fresh image."
		else
			vstacklet::shell::text::error "No install record was found on this server (it was set up by an earlier vStacklet version, or the record was removed). vStacklet 4 cannot roll it back safely; nothing was changed. Rebuild the server from a fresh image, or see the upgrade checklist in the README."
		fi
		exit 1
	fi
	vstacklet::rollback::plan || exit 1
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Type yes to roll back as listed above (run this inside screen or tmux if your connection may drop):"
	vstacklet::shell::text::white::sl "> "
	read -r confirm || confirm=""
	[[ ${confirm} == "yes" ]] || { vstacklet::shell::text::error "Rollback cancelled; nothing was changed." && exit 1; }
	exec 9>/root/vstacklet/rollback.lock
	flock -n 9 || { vstacklet::shell::text::error "a rollback is already running on this server." && exit 1; }
	trap '' SIGHUP
	declare -gi rollback_started=1
	exec > >(tee -a "/root/vstacklet/rollback-$(date +%Y%m%d-%H%M%S).log") 2>&1
	for u in apt-daily.timer apt-daily-upgrade.timer unattended-upgrades.service; do
		systemctl is-active --quiet "${u}" 2>/dev/null && held+=("${u}")
	done
	((${#held[@]})) && systemctl stop "${held[@]}" >/dev/null 2>&1
	if vstacklet::rollback::restore; then
		rm -rf /root/vstacklet/setup_temp >/dev/null 2>&1
		rm -f /opt/vstacklet/config/system/.install_complete "${VSTACKLET_MARKER}" >/dev/null 2>&1
		if [[ -d ${VSTACKLET_MARKER%/*} ]]; then rmdir --ignore-fail-on-non-empty "${VSTACKLET_MARKER%/*}" || true; fi
		[[ -d /var/log/vstacklet ]] && mv /var/log/vstacklet "/var/log/vstacklet-rolled-back-$(date +%Y%m%d-%H%M%S)"
		vstacklet::shell::text::success "Server rolled back to its recorded state. You may run the installer again."
	else
		rc=1
		vstacklet::shell::text::error "The rollback stopped before the server matched its record (see above). The install markers are kept, so the installer stays closed. Run vstacklet --rollback again, or rebuild the server from a fresh image."
	fi
	((${#held[@]})) && systemctl start "${held[@]}" >/dev/null 2>&1
	exit "${rc}"
}

################################################################################
# @name: vstacklet::update::check
# @description: Checks the branch this server was installed from for a newer 4.x release tag and, on a yes, moves /opt/vstacklet to that tag and installs its installer as /usr/local/bin/vstacklet. Runs only on a server with a completed 4.x install; the 3.x tools are never installed.
#
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::update::check() {
	local branch current latest input
	[[ -f ${VSTACKLET_MARKER} ]] || { vstacklet::shell::text::error "no completed vStacklet 4 install was found on this server (${VSTACKLET_MARKER}); --check_update works on 4.x installs only." && exit 1; }
	[[ -d ${vstacklet_base_path}/.git ]] || { vstacklet::shell::text::error "${vstacklet_base_path} is not a git checkout of vStacklet; rerun the bootstrap to restore it." && exit 1; }
	branch="$(cat "${vstacklet_base_path}/config/system/branch" 2>/dev/null || true)"
	[[ ${branch} =~ ^[A-Za-z0-9][A-Za-z0-9._/-]{0,99}$ && ${branch} != *..* ]] || { vstacklet::shell::text::error "the stored branch name in ${vstacklet_base_path}/config/system/branch is missing or not valid." && exit 1; }
	vstacklet::shell::text::yellow "Checking branch ${branch} for a newer vStacklet 4 release ..."
	git -C "${vstacklet_base_path}" fetch --quiet --tags origin "refs/heads/${branch}" || { vstacklet::shell::text::error "could not fetch branch ${branch} from the vStacklet repository." && exit 1; }
	current="$(git -C "${vstacklet_base_path}" describe --tags --match 'v4.*' --abbrev=0 HEAD 2>/dev/null || true)"
	latest="$(git -C "${vstacklet_base_path}" describe --tags --match 'v4.*' --abbrev=0 FETCH_HEAD 2>/dev/null || true)"
	if [[ -z ${latest} ]]; then
		vstacklet::shell::text::white "No vStacklet 4 release is tagged on branch ${branch} yet; nothing to update."
		exit 0
	fi
	if [[ ${latest} == "${current}" ]]; then
		vstacklet::shell::text::green "vStacklet is up to date (${current}, branch ${branch})."
		exit 0
	fi
	vstacklet::shell::text::yellow "A newer release is available on branch ${branch}: ${latest} (installed: ${current:-untagged})."
	vstacklet::shell::text::yellow "Type yes to update the vStacklet scripts. The update changes nothing else on this server."
	vstacklet::shell::icon::arrow::white && read -r input
	[[ ${input,,} == "yes" || ${input,,} == "y" ]] || { vstacklet::shell::text::yellow "Update cancelled." && exit 0; }
	git -C "${vstacklet_base_path}" checkout --quiet --detach "refs/tags/${latest}" || { vstacklet::shell::text::error "could not switch ${vstacklet_base_path} to ${latest}; local changes there may block it (see git -C ${vstacklet_base_path} status)." && exit 1; }
	install -m 0755 "${vstacklet_base_path}/setup/vstacklet-server-stack.sh" /usr/local/bin/vstacklet || { vstacklet::shell::text::error "could not install the ${latest} installer as /usr/local/bin/vstacklet." && exit 1; }
	vstacklet::shell::text::success "vStacklet scripts updated to ${latest}."
	exit 0
}

################################################################################
# @description: Calls functions in required order.
################################################################################
# the following functions are called in the order they are listed and
# are used for post-installation setup.
################################################################################
vstacklet::environment::functions             #(2)
vstacklet::args::info "$@"                    # -h and -V only print: before the gate, no root or supported release needed
vstacklet::gate::system                       #(0) root, release, support dates, architecture: before any change
vstacklet::gate::interim "${codename}"        # until the 4.0 package sources are in: Debian 12 only
vstacklet::args::process "$@"                 #(3)
vstacklet::gate::install                      #(3.i) PHP support dates, fresh server only: before any change
vstacklet::environment::init                  #(1) the first change to the server
vstacklet::environment::store_flags_args "$@" # @script-note: store the flags and arguments to a file for rollback
vstacklet::log::check                         #(4)
vstacklet::apt::update                        #(5)
vstacklet::dependencies::install              #(6)
vstacklet::intro                              #(9)
vstacklet::ask::continue                      #(10)
vstacklet::dependencies::array                #(11)
vstacklet::base::dependencies                 #(12)
vstacklet::source::dependencies               #(13)
if [[ ${vstacklet_installed} -eq 0 ]]; then
	vstacklet::bashrc::set   #(14)
	vstacklet::hostname::set #(15)
	vstacklet::webroot::set  #(16)
	vstacklet::ssh::set      #(17)
	vstacklet::ftp::set      #(18)
	vstacklet::block::ssdp   #(19)
fi
vstacklet::sources::update                                                                            #(20)
vstacklet::gpg::keys                                                                                  #(21)
vstacklet::apt::update                                                                                #(5)
vstacklet::locale::set                                                                                #(22)
vstacklet::php::install                                                                               #(23)
vstacklet::nginx::install                                                                             #(25)
vstacklet::varnish::install                                                                           #(26)
vstacklet::permissions::adjust                                                                        #(27)
vstacklet::ioncube::install                                                                           #(28)
vstacklet::mariadb::install                                                                           #(29)
vstacklet::mysql::install                                                                             #(30)
vstacklet::postgre::install                                                                           #(31)
vstacklet::redis::install                                                                             #(32)
vstacklet::phpmyadmin::install                                                                        #(33)
[[ -n ${sendmail} ]] && vstacklet::sendmail::install                                                  #(35)
vstacklet::wordpress::install                                                                         #(36)
vstacklet::domain::ssl                                                                                #(37)
vstacklet::clean::complete                                                                            #(38)
vstacklet::marker::write                                                                              #(38.1)
[[ ${vstacklet_installed} -eq 0 ]] && vstacklet::message::complete && rm -rf ~/vstacklet.sh && exit 0 #(39)
################################################################################
# @description: End of script.
################################################################################
