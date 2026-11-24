#!/usr/bin/env bash
# vStacklet installer module: environment. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::environment::init (1)
# @description: Setup the environment and set variables. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L184-L205)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @break
##################################################################################
vstacklet::environment::init() {
	shopt -s extglob
	declare -g vstacklet_base_path server_ip local_setup_dir local_php8_dir local_varnish_dir
	server_ip=$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
	# @script-note: vstacklet directories
	local_setup_dir="${vstacklet_base_path:=/opt/vstacklet}/setup"
	local_php8_dir="/opt/vstacklet/config/php8"
	local_nginx_dir="/opt/vstacklet/config/nginx"
	local_varnish_dir="/opt/vstacklet/config/varnish"
	# @script-note: record the server's state before the first change (afresh on every install that passed the gate), for vstacklet --rollback
	vstacklet::rollback::baseline || { vstacklet::shell::text::error "could not record the server's state in /root/vstacklet/baseline; nothing was changed." && exit 1; }
	# @script-note: from here on the installer changes the server; a failure after this point means a rollback or a rebuild
	declare -gi vstacklet_changes_started=1
	{ mkdir -p "${VSTACKLET_STARTED%/*}" && date '+%F %H:%M %Z' >"${VSTACKLET_STARTED}"; } || { vstacklet::shell::text::error "could not write ${VSTACKLET_STARTED}; stopping." && exit 1; }
	# @script-note: create vstacklet directories
	mkdir -p "${vstacklet_base_path}/setup_temp"    # temporary setup directory - stores default files edited by vStacklet
	mkdir -p "${vstacklet_base_path}/config/system" # system configuration directory - stores dependencies, keys, and other system files
	# @script-note: script start time
	vstacklet_start_time=$(date +%s)
	# @script-note: check if nginx is installed
	declare -gi nginx_installed vstacklet_installed
	nginx_installed=$(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed")
	vstacklet_installed=$(find /opt/vstacklet/config/system -maxdepth 1 -type f -name ".install_complete" | wc -l)
}

##################################################################################
# @name: vstacklet::environment::store_flags_args (3.a)
# @description: Store the flags and arguments to a file for rollback if needed.  [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L517-L535)
#
# @param: command_string
#
# @example: vstacklet::environment::store_flags_args "command_string"
# @null
# @break
##################################################################################
vstacklet::environment::store_flags_args() {
	local timestamp flags_args_file
	timestamp=$(date +%Y-%m-%d-%H-%M-%S)
	flags_args_file="/root/vstacklet/setup_temp/vstacklet_install_command.${timestamp}.txt"
	local command_string=""
	# @script-note: ensure the directory structure exists
	mkdir -p "$(dirname "${flags_args_file}")"
	# @script-note: construct the command string
	for arg in "$@"; do
		command_string+=" ${arg}"
	done
	# @script-note: mask the mariadb and mysql passwords
	command_string=$(echo "${command_string}" | sed -E -e 's/(-mariadbPw|--mariadb_password|--mariadb-password|-mysqlPw|--mysql_password|-postgrePw|--postgresql_password|-redisPw|--redis_password)[[:space:]]+[^[:space:]]+/\1 ********/g')
	# @script-note: store the command string
	echo "Command:${command_string}" >"${flags_args_file}"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::yellow "Command string has been stored at: ${flags_args_file}"
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L544-L727)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
# @break
##################################################################################
vstacklet::environment::functions() {
	vstacklet::array::contains() {
		if [[ $# -lt 2 ]]; then
			_result=2
			vstacklet::shell::text::yellow "[${_result}]: ${FUNCNAME[0]} is missing arguments for ${_named_array}"
		fi
		declare _named_array="$2"
		declare _value="$1"
		shift
		declare -a _array=("$@")
		local _result=1
		for _element in "${_array[@]}"; do
			if [[ ${_element} == "${_value}" ]]; then
				_result=0
				#vstacklet::shell::text::success "[${_result}]: ${_named_array} array contains ${_value}"
				break
			fi
		done
		[[ ${_result} == "1" ]] && vstacklet::shell::text::error "[${_result}]: ${_named_array} array does not contain ${_value}" # && exit 1
		return "${_result}"                                                                                                       # 0 if found, 1 if not found, 2 if missing arguments
	}
	vstacklet::shell::output() {
		declare shell_reset
		shell_reset=$(tput sgr0)
		if [[ -z ${shell_newline} ]]; then
			declare shell_newline="\n"
		else
			unset shell_newline
		fi
		if [[ -n ${shell_icon} && -n "$*" ]]; then
			declare shell_newline="\n"
		elif [[ -n ${shell_icon} && -z "$*" ]]; then
			unset shell_newline
		fi
		case "${shell_option}" in
		bold) shell_option=$(tput bold) ;;
		underline) shell_option=$(tput smul) ;;
		standout) shell_option=$(tput smso) ;;
		esac
		case "${shell_icon}" in
		arrow) shell_icon="➜ ${shell_reset}" ;;
		warning) shell_icon="⚠ warning: ${shell_reset}" && shell_warning="1" ;;
		check) shell_icon="✓ ${shell_reset}" ;;
		cross) shell_icon="✗ ${shell_reset}" ;;
		success) shell_icon="✓ success: ${shell_reset}" && shell_success="1" ;;
		error) shell_icon="✗ error: ${shell_reset}" && shell_error="1" ;;
		rollback) shell_icon="⎌ rollback: ${shell_reset}" && shell_rollback="1" ;;
		esac
		if [[ ${shell_success} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		elif [[ ${shell_warning} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		elif [[ ${shell_error} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		elif [[ ${shell_rollback} == "1" ]]; then
			printf -- "${shell_reset}$(tput bold)${shell_color}${shell_icon}${shell_reset} ${output_color}%s${shell_newline}${shell_reset}" "$@"
		else
			printf -- "${shell_reset}${shell_color}${shell_icon}${shell_option}%s${shell_newline}${shell_reset}" "$@"
		fi
		unset shell_color shell_newline shell_option shell_icon
	}
	vstacklet::shell::misc::nl() {
		printf "\n"
	}
	vstacklet::shell::text::white() {
		declare -g shell_color
		shell_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::white::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::error() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 1)
		shell_icon="error"
		output_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::red() {
		declare -g shell_color
		shell_color=$(tput setaf 1)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::red::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 1)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::success() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 2)
		shell_icon="success"
		output_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::green() {
		declare -g shell_color
		shell_color=$(tput setaf 2)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::green::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 2)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::warning() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 3)
		shell_icon="warning"
		output_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::yellow() {
		declare -g shell_color
		shell_color=$(tput setaf 3)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::yellow::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 3)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::magenta() {
		declare -g shell_color
		shell_color=$(tput setaf 5)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::magenta::sl() {
		declare -g shell_color shell_newline=0
		shell_color=$(tput setaf 5)
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::text::rollback() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 5)
		shell_icon="rollback"
		output_color=$(tput setaf 7)
		vstacklet::shell::output "$@"
	}
	# shellcheck disable=SC2120
	vstacklet::shell::icon::arrow::white() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 7)
		shell_icon="arrow"
		vstacklet::shell::output "$@"
	}
	vstacklet::shell::icon::check::green() {
		declare -g shell_color shell_icon shell_newline=0
		shell_color=$(tput setaf 2)
		shell_icon="check"
		vstacklet::shell::output "$@"
	}
}
