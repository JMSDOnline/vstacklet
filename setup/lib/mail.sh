#!/usr/bin/env bash
# vStacklet installer module: mail. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
