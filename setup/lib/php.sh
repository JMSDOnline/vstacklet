#!/usr/bin/env bash
# vStacklet installer module: php. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
