#!/usr/bin/env bash
# vStacklet installer module: ui. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
	if [[ -n ${vslog-} ]]; then
		vstacklet::shell::text::white "vStacklet installation log can be found at:"
		vstacklet::shell::text::yellow "${vslog}"
	fi
	vstacklet::shell::misc::nl
}

# shall we continue? function (10)
vstacklet::ask::continue() {
	vstacklet::shell::text::green "Press any key to continue $(tput setaf 7)(${shell_reset}$(tput setaf 3)ctrl+C${shell_reset} $(tput setaf 7)on PC or $(tput setaf 7)${shell_reset}$(tput setaf 3)⌘+C${shell_reset} $(tput setaf 7)on Mac to ${shell_reset}$(tput setaf 1)exit${shell_reset}$(tput setaf 7)) ..."
	read -r -n 1
	vstacklet::shell::misc::nl
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
	# @script-note: a vendor key that expires within 90 days, repeated from the package check so it is seen
	if [[ ${vs_key_expiry[0]+x} ]]; then
		local k
		vstacklet::shell::misc::nl
		for k in "${vs_key_expiry[@]}"; do vstacklet::shell::text::yellow " - Note: ${k}; run vstacklet --refresh-keys after the vendor renews it."; done
	fi
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Be sure to review the above output from the vStacklet installation process"
	vstacklet::shell::text::white "for relevant information regarding your new server and connection details."
	vstacklet::shell::misc::nl
	[[ ${setup_reboot} -eq "1" ]] && vstacklet::shell::text::white "rebooting ... " && reboot
	# @script-note: reboot only on -r or an explicit yes at a terminal; no answer (or no terminal) never reboots
	if [[ -z ${setup_reboot} && -t 0 ]]; then
		declare input=""
		vstacklet::shell::text::white::sl "do you want to reboot (recommended)? "
		vstacklet::shell::text::green::sl "[y]"
		vstacklet::shell::text::white::sl "es"
		vstacklet::shell::text::white::sl " or "
		vstacklet::shell::text::red::sl "[n]"
		vstacklet::shell::text::white::sl "o: "
		vstacklet::shell::icon::arrow::white
		read -r input || input=""
		case "${input,,}" in
		y | yes) vstacklet::shell::text::white "rebooting ... " && reboot ;;
		*) vstacklet::shell::text::white "not rebooting; reboot when it suits you." ;;
		esac
	elif [[ -z ${setup_reboot} ]]; then
		vstacklet::shell::text::white "not rebooting (no terminal to ask); reboot when it suits you, or pass -r next time."
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
	vstacklet::shell::text::white " --refresh-keys"
	vstacklet::shell::text::white "    Re-fetches the vendor repository keys vStacklet added and replaces each one that still matches its trusted fingerprint."
	vstacklet::shell::text::white "    A key the vendor replaces with a new one is refused; that needs an updated vStacklet."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " --rollback"
	vstacklet::shell::text::white "    Undoes an install: restores the state recorded before its first change. Run it on its own, with no other options."
	vstacklet::shell::text::white "    It also works after a release leaves regular support, while its packages are still on the Debian mirrors; once a release has moved to archive.debian.org, rebuild the server from a fresh image instead. A server upgraded to a new release since its install cannot be rolled back; rebuild it from a fresh image."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -r, --reboot"
	vstacklet::shell::text::white "    Reboots the server after installation is complete."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -d, --domain"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " --dns, --dns_provider"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -e, --email"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -ftp, --ftp"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
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
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
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
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysqlU, --mysql_user"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysqlPw, --mysql_password"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -mysqlP, --mysql_port"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -nginx, --nginx"
	vstacklet::shell::text::white "    Installs and configures Nginx."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -pma, --phpmyadmin"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -php, --php"
	vstacklet::shell::text::white "    Installs and configures PHP."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -sendmail, --sendmail"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -sendmailP, --sendmail_port"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -ssh, --ssh_port"
	vstacklet::shell::text::white "    Sets the SSH port."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -varnish, --varnish"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -varnishP, --varnish_port"
	vstacklet::shell::text::white "    Not offered in vStacklet 4.0."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -wp, --wordpress"
	vstacklet::shell::text::white "    Installs and configures WordPress."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white " -wr, --web_root"
	vstacklet::shell::text::white "    Sets the web root for the server."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "example: "
	vstacklet::shell::text::white "vstacklet -hn 'server.example.com' -nginx -php '8.4' -mariadb -mariadbU 'username' -mariadbPw 'password' -wr '/var/www/html/vsapp' -wp"
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
