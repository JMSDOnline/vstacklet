#!/usr/bin/env bash
# vStacklet installer module: varnish. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

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
