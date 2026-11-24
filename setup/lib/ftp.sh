#!/usr/bin/env bash
# vStacklet installer module: ftp. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
