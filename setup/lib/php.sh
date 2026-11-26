#!/usr/bin/env bash
# vStacklet installer module: php. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::php::install (23)
# @description: Configure PHP after the one package install: php.ini for FPM and CLI, exactly one PHP version at the end.
#
# notes:
# - supported: "8.3", "8.4" (default, DEFAULT_PHP) and "8.5" (SUPPORTED_PHP); any other value is refused
# - where PHP comes from: the release's own archive when it ships that version (Debian 13 with 8.4, Ubuntu 24.04 with 8.3, Ubuntu 26.04 with 8.5), otherwise packages.sury.org with a pin that keeps every other package there below the release's archive
# - extensions installed when offered for the release and version: required fpm, cli, common, xml, mbstring, curl, zip, gd, intl, and mysql with a database (a missing one stops the install); optional opcache, bcmath, gmp, readline, soap, igbinary, msgpack, imagick, memcached (a missing one is skipped with a message)
# @option: $1 - `-php | --php`
# @arg: $2 - `[version]` - `8.3` | `8.4` | `8.5`
# @example: vstacklet -php 8.4
# @example: vstacklet --php 8.5
# @null
# @break
##################################################################################
vstacklet::php::install() {
	[[ -n ${php} ]] || return 0
	local file n
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "configuring PHP ${php} ... "
	# @script-note: the packages are installed by vstacklet::packages::install (one apt call for the whole list); the extensions enable themselves on install
	for file in "/etc/php/${php}/fpm/php.ini" "/etc/php/${php}/cli/php.ini"; do
		[[ -f ${file} ]] || vstacklet::apt::fail "${file} is missing after the PHP install"
		sed -i.bak -e "s/.*post_max_size =.*/post_max_size = 92M/" -e "s/.*upload_max_filesize =.*/upload_max_filesize = 92M/" -e "s/.*expose_php =.*/expose_php = Off/" -e "s/.*memory_limit =.*/memory_limit = 768M/" -e "s/.*session.cookie_secure =.*/session.cookie_secure = 1/" -e "s/.*session.cookie_httponly =.*/session.cookie_httponly = 1/" -e "s/.*session.cookie_samesite =.*/session.cookie_samesite = Lax/" -e "s/.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/" -e "s/.*opcache.enable=.*/opcache.enable=1/" -e "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=4000/" "${file}" || vstacklet::apt::fail "could not edit ${file}"
	done
	# @script-note: exactly one PHP on the server at the end
	n="$(dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' 'php*-common' 2>/dev/null | awk '$1 == "ii" && $2 ~ /^php[0-9]+\.[0-9]+-common/' | wc -l)"
	[[ ${n} -eq 1 ]] || vstacklet::apt::fail "expected exactly one PHP version on this server after the install, found ${n}"
	vstacklet::log systemctl restart "php${php}-fpm"
	vstacklet::shell::text::green "PHP ${php} configured${vs_php_skipped:+; extensions not offered here and skipped: ${vs_php_skipped[*]}}."
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
		vstacklet::shell::text::yellow "ionCube Loader is not offered in vStacklet 4.0. Skipping ..."
	fi
}
