#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: vstacklet.sh
# @version: 3.1.1096
# @description: This script will download and install the vStacklet server stack
# on your server (this only handles downloading and setting up the vStacklet scripts).
# The 3.x VS-Perms and VS-Backup tools stay in the repository for 3.x servers and are
# not installed by vStacklet 4. Please ensure you have
# read the documentation before continuing. You can find documentation on the main
# vStacklet script, the vStacklet server stack, and the vStacklet VS-Perms and
# VS-Backup scripts at the links seen below.
#
# @project_name: vstacklet
#
# @path: /usr/local/bin/vstacklet
#
# @brief: This script is designed to be run on a fresh Ubuntu 20.04/22.04 or
# Debian 11/12 server. I have done my best to keep it tidy and with as much
# error checking as possible. Couple this with loads of comments and you should
# have a pretty good idea of what is going on. If you have any questions,
# comments, or suggestions, please feel free to open an issue on GitHub.
#
# - Documentation is available at: [/docs/](https://github.com/JMSDOnline/vstacklet/tree/main/docs)
#   - :book: [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
#   - :book: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)
#   - :book: [vStacklet VS-Perms (www-permissions.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions.sh.md)
#     - :book: [vStacklet vs-perms (www-permissions-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions-standalone.sh.md)
#   - :book: [vStacklet VS-Backup (vs-backup) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vs-backup.md)
#     - :book: [vStacklet vs-backup (vstacklet-backup-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vstacklet-backup-standalone.sh.md)
#
# vStacklet will install and configure the following:
# - NGinx 1.25.+ (mainline) | 1.18.+ (extras) (HTTP Server)
# - PHP 8.3, 8.4 (default) or 8.5 (FPM) with common extensions
# - MariaDB 10.11.+ (MySQL Database)
# - Varnish 7.4.x (HTTP Cache)
# - and more!
#
# @save_tasks:
#  automated_versioning: true
#  automated_documentation: true
#
# @build_tasks:
#  automated_comment_strip: false
#  automated_encryption: false
#
# @author: Jason Matthews (JMSolo)
# @author_contact: https://github.com/JMSDOnline/vstacklet
#
# @license: MIT License (Included in LICENSE)
# Copyright (C) 2016-2024, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
# shellcheck disable=SC2068,SC2034,SC1091
################################################################################
# >>> vstacklet gate: this block is kept identical in setup/vstacklet.sh and setup/vstacklet-server-stack.sh
##################################################################################
# @name: vstacklet::gate (0)
# @description: Runs before anything on the server is changed: root, the release and its support dates, the architecture.
#
# Support dates come from the vendors' own pages, read 2026-11-23:
# - Debian: https://www.debian.org/releases/bookworm/ , https://www.debian.org/releases/trixie/ , https://wiki.debian.org/LTS
# - Ubuntu: https://ubuntu.com/about/release-cycle (states a month only; the gate uses the last day of that month)
# - PHP:    https://www.php.net/supported-versions.php
# A release counts as supported until its free security support ends: for Debian the end of Debian LTS (a Debian
# project), for Ubuntu the end of standard support. Paid extended support (Freexian ELTS for Debian, Ubuntu ESM) is
# not counted. A Debian release past its regular security support but inside Debian LTS installs with a notice.
# Row: id|version|codename|regular security end|free security end|end as the vendor states it|who supports it until then
##################################################################################
declare -ga VSTACKLET_GATE_RELEASES=(
	"debian|12|bookworm|2026-07-11|2028-06-30|30 June 2028|Debian LTS"
	"debian|13|trixie|2028-08-09|2030-06-30|30 June 2030|Debian LTS"
	"ubuntu|24.04|noble|2029-05-31|2029-05-31|May 2029 (month only)|Ubuntu standard support"
	"ubuntu|26.04|resolute|2031-05-31|2031-05-31|May 2031 (month only)|Ubuntu standard support"
)
# Row: PHP version|end of active support|end of security support
declare -ga VSTACKLET_GATE_PHP=(
	"8.3|2025-12-31|2027-12-31"
	"8.4|2026-12-31|2028-12-31"
	"8.5|2027-12-31|2029-12-31"
)
vstacklet::gate::refuse() {
	printf 'vStacklet: %s\n' "$@" >&2
	printf 'vStacklet: the install has stopped before any change was made to this server.\n' >&2
	exit 1
}
vstacklet::gate::notice() {
	printf 'vStacklet notice: %s\n' "$@" >&2
}
vstacklet::gate::system() {
	local key value os_id="" os_version="" os_codename="" row r_id r_ver r_code r_regular r_free r_shown r_who today arch
	[[ ${EUID} -eq 0 ]] || vstacklet::gate::refuse "run the installer as root."
	[[ -r /etc/os-release ]] || vstacklet::gate::refuse "cannot read /etc/os-release, so the release cannot be checked."
	# @script-note: read three keys only; the file is never sourced
	while IFS='=' read -r key value; do
		value="${value%\"}" && value="${value#\"}"
		case "${key}" in
		ID) os_id="${value}" ;;
		VERSION_ID) os_version="${value}" ;;
		VERSION_CODENAME) os_codename="${value}" ;;
		esac
	done </etc/os-release
	today="$(date +%F)"
	for row in "${VSTACKLET_GATE_RELEASES[@]}"; do
		IFS='|' read -r r_id r_ver r_code r_regular r_free r_shown r_who <<<"${row}"
		[[ ${os_id} == "${r_id}" && ${os_version} == "${r_ver}" ]] || continue
		[[ -z ${os_codename} || ${os_codename} == "${r_code}" ]] || vstacklet::gate::refuse "${os_id} ${os_version} reports the codename '${os_codename}', expected '${r_code}'; the release cannot be confirmed."
		if [[ ${today} > "${r_free}" ]]; then
			vstacklet::gate::refuse "${os_id} ${os_version} reached the end of its free security support (${r_who}, ${r_shown}). Rebuild the server on a supported release: Debian 12 or 13, Ubuntu 24.04 or 26.04."
		fi
		[[ ${today} > "${r_regular}" ]] && vstacklet::gate::notice "${os_id} ${os_version} has left regular security support and is covered by ${r_who} until ${r_shown}, for fewer packages and architectures. Plan a move to a newer release."
		arch="$(dpkg --print-architecture 2>/dev/null)"
		[[ ${arch} == "amd64" || ${arch} == "arm64" ]] || vstacklet::gate::refuse "the architecture '${arch:-unknown}' is not supported (amd64 or arm64)."
		declare -g distro codename vstacklet_arch="${arch}"
		codename="${r_code}"
		[[ ${r_id} == "debian" ]] && distro="Debian"
		[[ ${r_id} == "ubuntu" ]] && distro="Ubuntu"
		return 0
	done
	vstacklet::gate::refuse "${os_id:-unknown} ${os_version:-unknown} is not supported. Supported: Debian 12 and 13, Ubuntu 24.04 and 26.04. For Debian 11 or Ubuntu 20.04 and 22.04, the last 3.x release is the tag v3.1.2239, which is no longer maintained."
}
# <<< vstacklet gate
# @script-note: interim, until the 4.0 package sources are written: on Debian 13 and Ubuntu the 3.x sources code would rewrite the release's own sources, so this build stops there before any change
vstacklet::gate::interim() {
	[[ ${1-} == "bookworm" ]] || vstacklet::gate::refuse "this development build of vStacklet 4.0 installs on Debian 12 only for now; Debian 13 and Ubuntu 24.04 and 26.04 follow before the 4.0 release."
}

##################################################################################
# @name: vstacklet::environment::checkroot (1)
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L66-L71)
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		printf -- "%s\n" "Please run this script as root. Elevate your privileges with (sudo su -) and try again."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L80-L245)
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

##################################################################################
# @name: vstacklet::setup::variables (3)
# @description: Set the variables for the setup. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L254-L312)
#
# notes: this script function is responsible for setting the variables for the setup.
# @break
##################################################################################
vstacklet::setup::variables() {
	# @script-note: options come from the command line only, never from variables already set in the caller's shell
	help=false
	version=false
	unset branch vstacklet_git_branch
	while [ $# -gt 0 ]; do
		case "${1}" in
		-V | --version)
			version=true
			shift
			;;
		-h | --help)
			help=true
			shift
			;;
		-b | --branch)
			# @script-note: a branch name only (letters, digits, . _ / -), never another option
			[[ $# -ge 2 && ${2} =~ ^[A-Za-z0-9][A-Za-z0-9._/-]{0,99}$ && ${2} != *..* ]] || { printf -- "%s\n" "Invalid branch name for -b: '${2-}'" && exit 1; }
			branch="${2}"
			shift
			shift
			;;
		*)
			printf -- "%s\n" "Invalid argument: ${1}"
			exit 1
			;;
		esac
	done
	# @script-note: Set the necessary declarations
	declare -g vstacklet_base_path vstacklet_setup_path vstacklet_config_path vstacklet_config_php8_path vstacklet_config_nginx_path vstacklet_config_varnish_path server_ip server_hostname vstacklet_server_stack_script vstacklet_git vstacklet_git_branch
	# @script-note: Set the vstacklet base path
	# @script-note: fixed install path (the installer expects it; the -P option was removed in 4.0, it passed its value to rm -rf)
	vstacklet_base_path="/opt/vstacklet"
	# @script-note: Set the vstacklet setup path
	vstacklet_setup_path="${vstacklet_setup_path:-${vstacklet_base_path}/setup}"
	# @script-note: Set the vstacklet config path
	vstacklet_config_path="${vstacklet_config_path:-${vstacklet_base_path}/config}"
	# @script-note: Set the vstacklet config php8 path
	vstacklet_config_php8_path="${vstacklet_config_php8_path:-${vstacklet_config_path}/php8}"
	# @script-note: Set the vstacklet config nginx path
	vstacklet_config_nginx_path="${vstacklet_config_nginx_path:-${vstacklet_config_path}/nginx}"
	# @script-note: Set the vstacklet config varnish path
	vstacklet_config_varnish_path="${vstacklet_config_varnish_path:-${vstacklet_config_path}/varnish}"
	# @script-note: Set the IP address of the server
	server_ip="${server_ip:-$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)}"
	# @script-note: Set the hostname of the server
	server_hostname="${server_hostname:-$(hostname --fqdn)}"
	# @script-note: Set the local vstacklet server stack script (this is the script that will be loaded to /usr/local/bin/vstacklet)
	vstacklet_server_stack_script="${vstacklet_base_path}/setup/vstacklet-server-stack.sh"
	# @script-note: Set the vstacklet github repository url
	vstacklet_git="https://github.com/JMSDOnline/vstacklet.git"
	# @script-note: Set the vstacklet github repository branch (default: main)
	vstacklet_git_branch="${vstacklet_git_branch:-${branch:-main}}"
}

################################################################################
# @name: vstacklet::setup::download() (4)
# @description: Setup the environment and download vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L337-L396)
#
# notes:
# - This script function is responsible for downloading vStacklet from GitHub
# and setting up the environment for the installation.
#   - VStacklet will be downloaded to `/opt/vstacklet`.
#   - `vstacklet-server-stack.sh` will be loaded to `/usr/local/bin/vstacklet`. This
# will allow you to run `vstacklet [options] [args]` from anywhere on the server.
# - This script function will also check for the existence of the required
# packages and install them if they are not found.
#   - these include:
#     ```bash
#     curl sudo wget git apt-transport-https lsb-release dnsutils openssl
#     ```
#
# @break
################################################################################
vstacklet::setup::download() {
	# @script-note: move to the home directory (as root, this would be `/root`)
	cd "${HOME}" || { printf -- "%s\n" "Error: Unable to move to ${HOME}" && exit 1; }
	# @script-note: run apt update and upgrade (quietly and non-interactive)
	DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update >/dev/null 2>&1
	# @script-note: upgrade only a fresh server; on a server vStacklet already changed, an upgrade would move the state its rollback compares against
	if [[ ! -e /root/vstacklet/baseline/complete && ! -e /etc/vstacklet ]]; then
		DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to run apt-upgrade, please check your apt with 'apt -y update && apt -y upgrade'" && exit 1; }
	fi
	# @script-note: install the essential dependencies
	apt-get -yqq install curl sudo wget git apt-transport-https lsb-release dnsutils openssl bc >/dev/null 2>&1 || { printf -- "%s\n" "Error: Unable to install script dependencies" && exit 1; }
	# @script-note: adjust .bashrc TERM variable if not set (fixes some issues with nano)
	if ! grep -q "export TERM=xterm" /root/.bashrc; then
		echo -en "export TERM=xterm" >>"/root/.bashrc"
	fi
	# @script-note: source the .bashrc
	source "${HOME}/.bashrc"
	# @script-note: create vstacklet & backup directory strucutre
	mkdir -p /backup/{files,databases} || { printf -- "%s\n" "Error: Unable to create /backup/{files,databases}" && exit 1; }
	# @script-note: download vStacklet
	if [[ -d "${vstacklet_base_path}/.git" ]]; then
		# @script-note: update vStacklet: a fresh clone replaces the checkout, so it stays a real git checkout of the branch (the installer's repair text relies on that); only the installer's own state in config/system is carried over
		local vs_tmp
		vs_tmp="$(mktemp -d)" || { printf -- "%s\n" "Error: Unable to create a temporary folder" && exit 1; }
		git clone --quiet --branch "${vstacklet_git_branch}" "${vstacklet_git}" "${vs_tmp}/vstacklet" || { rm -rf "${vs_tmp}"; printf -- "%s\n" "Error: Unable to update vStacklet from GitHub" && exit 1; }
		if [[ -d ${vstacklet_base_path}/config/system ]]; then
			if ! { mkdir -p "${vs_tmp}/vstacklet/config/system" && cp -a "${vstacklet_base_path}/config/system/." "${vs_tmp}/vstacklet/config/system/"; }; then
				rm -rf "${vs_tmp}"
				printf -- "%s\n" "Error: Unable to keep ${vstacklet_base_path}/config/system"
				exit 1
			fi
		fi
		if ! { rm -rf "${vstacklet_base_path}" && mv "${vs_tmp}/vstacklet" "${vstacklet_base_path}"; }; then
			printf -- "%s\n" "Error: Unable to replace ${vstacklet_base_path}"
			exit 1
		fi
		rm -rf "${vs_tmp}"
	else
		# @script-note: install vStacklet
		[[ -d ${vstacklet_base_path} ]] && rm -rf "${vstacklet_base_path}"
		git clone --quiet --branch "${vstacklet_git_branch}" "${vstacklet_git}" "${vstacklet_base_path}" || { printf -- "%s\n" "Error: Unable to clone vStacklet from GitHub" && exit 1; }
	fi
	# @script-note: the 3.x tools (bin/backup/vs-backup, bin/www-permissions.sh) stay frozen for 3.x servers and are not installed here
	# @script-note: send vStacklet server stack script to /usr/local/bin
	cp -f "${vstacklet_server_stack_script}" "/usr/local/bin/vstacklet" || { printf -- "%s\n" "Error: Unable to copy vstacklet to /usr/local/bin" && exit 1; }
	# @script-note: make vstacklet executable
	chmod +x "/usr/local/bin/vstacklet" || { printf -- "%s\n" "Error: Unable to make the installation script executable." && exit 1; }
	# @script-note: create vstacklet directories
	mkdir -p "${vstacklet_base_path}/setup_temp"    # temporary setup directory - stores default files edited by vStacklet
	mkdir -p "${vstacklet_base_path}/config/system" # system configuration directory - stores dependencies, keys, and other system files
	# @script-note: store the branch in the vstacklet config for future reference and updates
	echo "${vstacklet_git_branch}" >"${vstacklet_base_path}/config/system/branch" || { printf -- "%s\n" "Error: Unable to store the branch in the vstacklet config" && exit 1; }
	# Execute the installation script (let's get this party started!)
	# Allow for the installation script to be run from anywhere on the server
	# by the user through calling `vstacklet [options] [args]`
	# @script-note: display the outro
	echo "The vStacklet installer has been installed on your server."
	echo "You can now run vstacklet from anywhere on your server."
	echo "Please see the documentation for more information."
	echo ""
	echo "Documentation can be found here:"
	echo "https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/setup/vstacklet-server-stack.sh.md"
	echo ""
	echo "You can also run the following command for more information:"
	echo "vstacklet -h"
	echo ""
}

##################################################################################
# @name: vstacklet::setup::help()
# @description: Display the help menu for the setup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L403-L424)
# @break
##################################################################################
vstacklet::setup::help() {
	cat <<EOF
Usage: vstacklet [options] [args]

Options:
  -V, --version   Display the version of vStacklet
  -h, --help      Display this help menu
  -b, --branch    Specify the branch to install from (default: main)

Examples:
  # Install vStacklet from the main branch
  bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh)

  # Install vStacklet from the development branch
  bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh) -b 'development'

  # Display the help menu
  bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh) -h

EOF
}

##################################################################################
# @name: vstacklet::setup::version()
# @description: Display the version of vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L431-L439)
# @break
##################################################################################
vstacklet::version::display() {
	vstacklet_version="$(grep -oP '(?<=Version: v)[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' <"${vstacklet_base_path}"/README.md)"
	vstacklet_sa_version="$(grep -E '^# @version:' "${vstacklet_base_path}/setup/vstacklet-server-stack.sh" | awk '{print $3}')"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet Full Kit Version: ${vstacklet_version}"
	vstacklet::shell::text::white "vStacklet Server Stack Version: ${vstacklet_sa_version}"
	# @script-note: display the current branch
	vstacklet::shell::text::white "vStacklet Branch: $(cat "${vstacklet_base_path}"/config/system/branch)"
	vstacklet::shell::misc::nl
	exit 0
}

################################################################################
# @description: Calls functions in required order.
# @break
################################################################################
vstacklet::setup::main() {
	vstacklet::environment::checkroot
	vstacklet::environment::functions
	vstacklet::setup::variables "$@"
	[[ "${help}" == "true" ]] && vstacklet::setup::help && exit 0
	[[ "${version}" == "true" ]] && vstacklet::version::display && exit 0
	# @script-note: the release, its support dates and the architecture are checked before apt runs or anything is downloaded
	vstacklet::gate::system
	vstacklet::gate::interim "${codename}"
	vstacklet::setup::download
}

# @script-note: call the main function
vstacklet::setup::main "$@"
# @script-note: unset the variables
unset vstacklet_base_path vstacklet_setup_path vstacklet_config_path vstacklet_config_php8_path vstacklet_config_nginx_path vstacklet_config_varnish_path server_ip server_hostname vstacklet_git vstacklet_git_branch vstacklet_server_stack_script vstacklet_version help version branch
# @script-note: exit the script
exit 0
