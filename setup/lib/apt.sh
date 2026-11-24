#!/usr/bin/env bash
# vStacklet installer module: apt. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
