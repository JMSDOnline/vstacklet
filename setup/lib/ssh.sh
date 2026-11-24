#!/usr/bin/env bash
# vStacklet installer module: ssh. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
