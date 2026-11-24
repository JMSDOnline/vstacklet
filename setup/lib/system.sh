#!/usr/bin/env bash
# vStacklet installer module: system. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
