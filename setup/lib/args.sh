#!/usr/bin/env bash
# vStacklet installer module: args. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
# | -e    | --email                    | not offered in 4.0
# | -ftp  | --ftp_port                 | not offered in 4.0
# | -ssh  | --ssh_port                 | port to use for the SSH server
# | -http | --http_port                | port to use for the HTTP server
# | -https| --https_port               | port to use for the HTTPS server
# | -ioncube | --ioncube               | not offered in 4.0
# | -hn   | --hostname                 | hostname to use for the server
# | -d    | --domain                   | not offered in 4.0
# | -php  | --php                      | PHP version to install (8.3, 8.4, 8.5; default 8.4)
# | -hhvm | --hhvm                     | refused: HHVM is no longer supported
# | -nginx| --nginx                    | install Nginx
# | -varnish | --varnish               | not offered in 4.0
# | -varnishP | --varnish_port         | not offered in 4.0
# | -mariadb | --mariadb               | install MariaDB
# | -mariadbP | --mariadb_port         | port to use for the MariaDB server
# | -mariadbU | --mariadb_user         | user to use for the MariaDB server<br>Avoid using 'root' as the username
# | -mariadbPw | --mariadb-password    | password to use for the MariaDB user
# | -pma | --phpmyadmin                | not offered in 4.0
# | -csf | --csf                       | refused: CSF is no longer supported
# | -csfCf | --csf_cloudflare          | refused: CSF is no longer supported
# | -sendmail | --sendmail              | not offered in 4.0
# | -sendmailP | --sendmail_port        | not offered in 4.0
# | --dns | --dns_provider             | not offered in 4.0
# | -wr | --web_root				   | web root to use for the server
# | -wp | --wordpress				   | install WordPress
# | -r | --reboot					   | reboot the server after installation
# | --rollback						   | undo an install: restore the state recorded before its first change
# | --check_update					   | check the installed branch for a newer 4.x release
#
# @example: vstacklet --help
# @example: vstacklet -hn "server.example.com" -nginx -php "8.4" -mariadb -mariadbU "db_user" -mariadbPw "db_password" -wr "/var/www/html/vsapp" -wp
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
			vstacklet::args::not_yet "$1"
			;;
		-e | --email)
			vstacklet::shell::text::error "${1} is not offered in vStacklet 4.0; with -wp, the installer asks for the WordPress admin email. Nothing was changed." && exit 1
			;;
		-ftp | --ftp_port)
			vstacklet::args::not_yet "$1"
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
			vstacklet::shell::text::error "ionCube Loader is not offered in vStacklet 4.0; run without -ioncube." && exit 1
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
			vstacklet::args::not_yet "$1"
			;;
		-mysqlU | --mysql_user)
			vstacklet::args::not_yet "$1"
			;;
		-mysqlPw | --mysql_password)
			vstacklet::args::not_yet "$1"
			;;
		-mysqlP | --mysql_port)
			vstacklet::args::not_yet "$1"
			;;
		-nginx | --nginx)
			declare -gi nginx="1"
			shift
			;;
		-postgre | --postgresql)
			vstacklet::args::not_yet "$1"
			;;
		-postgreU | --postgresql_user)
			vstacklet::args::not_yet "$1"
			;;
		-postgrePw | --postgresql_password)
			vstacklet::args::not_yet "$1"
			;;
		-postgreP | --postgresql_port)
			vstacklet::args::not_yet "$1"
			;;
		-pma | --phpmyadmin)
			vstacklet::args::not_yet "$1"
			;;
		-php | --php)
			vstacklet::args::need_value "$1" $# "${2-}"
			declare -g php="${2}"
			shift 2
			;;
		-redis | --redis)
			vstacklet::args::not_yet "$1"
			;;
		-redisPw | --redis_password)
			vstacklet::args::not_yet "$1"
			;;
		-redisP | --redis_port)
			vstacklet::args::not_yet "$1"
			;;
		-sendmail | --sendmail)
			vstacklet::args::not_yet "$1"
			;;
		-sendmailP | --sendmail_port)
			vstacklet::args::not_yet "$1"
			;;
		--dns | --dns_provider)
			vstacklet::args::not_yet "$1"
			;;
		-ssh | --ssh_port)
			[[ ${distro} == "Ubuntu" ]] && vstacklet::shell::text::error "-ssh is not offered on Ubuntu in vStacklet 4.0." && exit 1
			vstacklet::args::need_value "$1" $# "${2-}"
			vstacklet::args::port "$1" "$2"
			declare -gi ssh_port=$((10#$2))
			shift 2
			;;
		-varnish | --varnish)
			vstacklet::args::not_yet "$1"
			;;
		-varnishP | --varnish_port)
			vstacklet::args::not_yet "$1"
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
		--refresh-keys)
			vstacklet::apt::refresh_keys
			exit $?
			;;
		--rollback)
			# @script-note: --rollback is handled by vstacklet::gate::rollback_first before the release gates and never returns; reaching this line is an internal error
			printf 'vStacklet: internal error: --rollback reached the option reader. Nothing was changed.\n' >&2
			exit 1
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
	[[ -n ${mariadb_password} && -z ${mariadb_user} ]] && vstacklet::shell::text::error "-mariadbPw sets the password of the admin account; name the account with -mariadbU." && exit 1
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
	# @script-note: /var/www only in this build: the rollback records and removes /var/www, so a web root elsewhere would survive it
	local re='^/var/www(/[A-Za-z0-9][A-Za-z0-9._-]*)+$'
	if [[ ${#2} -gt 200 || ! $2 =~ ${re} ]]; then
		vstacklet::shell::text::error "option '$1': '$2' is not an allowed web root; use a folder under /var/www/ (for example: /var/www/html/vsapp)." && exit 1
	fi
}

##################################################################################
# @name: vstacklet::args::not_yet
# @description: Refuses an option whose feature has not been rewritten for 4.0 yet, before any change, so no 3.x code runs.
##################################################################################
vstacklet::args::not_yet() {
	vstacklet::shell::text::error "${1} is not offered in vStacklet 4.0. Nothing was changed."
	exit 1
}
