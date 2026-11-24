#!/usr/bin/env bash
# vStacklet installer module: redis. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::redis::install (32)
# @description: Install and configure Redis. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2349-L2403)
#
# note: redis is not installed by default and is currently untested.
# this function is a work in progress. it is intended as a future feature.
#
# @option: $1 - `-redis | --redis` (optional)
# @option: $2 - `-redisP | --redis_port` (optional)
# @option: $3 - `-redisPw | --redis_password` (optional)
# @arg: $2 - `[redis_port]` (optional) (default: 6379)
# @arg: $3 - `[redis_password]` (optional) (default: password auto-generated)
# @example: vstacklet -redis -redisP 6379 -redisPw password
# @example: vstacklet --redis --redis_port 6379 --redis_password password
# @example: vstacklet -redis
# @example: vstacklet --redis
# @null
# @return_code: 58 - failed to install Redis dependencies.
# @return_code: 59 - failed to backup the Redis configuration file.
# @return_code: 60 - failed to import the Redis configuration file.
# @return_code: 61 - failed to modify the Redis configuration file.
# @return_code: 62 - failed to restart the Redis service.
# @return_code: 63 - failed to set the Redis password.
# @break
##################################################################################
vstacklet::redis::install() {
	if [[ -n ${redis} ]]; then
		declare redis_autoPw
		redis_autoPw="$(perl -e 'print map { (a..z,A..Z,0..9)[rand 62] } 0..15')"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring Redis ... "
		# @script-note: install redis dependencies
		declare -a depend_list install_list
		for depend in "${redis_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing Redis dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 58
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${redis_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		# @script-note: configure redis
		vstacklet::shell::text::yellow::sl "configuring Redis ... " &
		vs::stat::progress::start # start progress status
		# @script-note: set redis client and server configuration
		cp -f /etc/redis/redis.conf /etc/redis/redis.conf.bak || vstacklet::error::display 59
		cp -f "${local_setup_dir}/templates/redis/redis.conf" /etc/redis/redis.conf || vstacklet::error::display 60
		sed -i.bak "s/{{redis_port}}/${redis_port:-6379}/g" /etc/redis/redis.conf || vstacklet::error::display 61
		# @script-note: restart redis
		vstacklet::log systemctl restart redis-server || vstacklet::error::display 62
		# @script-note: set redis password
		redis-cli -a "" -h localhost -p "${redis_port:-6379}" config set requirepass "${redis_password:-${redis_autoPw}}" >>"${vslog}" 2>&1 || vstacklet::error::display 63
		vs::stat::progress::stop # stop progress status
		# @script-note: redis installation complete
		vstacklet::shell::text::green "Redis installed and configured. see details below:"
		vstacklet::shell::text::white::sl "Redis password: "
		vstacklet::shell::text::green "${redis_password:-${redis_autoPw}}"
		#vstacklet::shell::text::white::sl "Redis user: "
		#vstacklet::shell::text::green "${redis_user:-admin}"
		vstacklet::shell::text::white::sl "Redis port: "
		vstacklet::shell::text::green "${redis_port:-6379}"
		vstacklet::shell::text::white::sl "Redis socket: "
		vstacklet::shell::text::green "/var/run/redis/redis-server.sock"
		vstacklet::shell::text::white::sl "Redis configuration file: "
		vstacklet::shell::text::green "/etc/redis/redis.conf"
	fi
}
