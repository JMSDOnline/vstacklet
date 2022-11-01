#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: www-permissions.sh
# @version: 3.1.1058
# @description: This script will add a new www-data group on your server
# and set permissions for ${www_root:-/var/www/html}.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: setup/www-permissions.sh
#
# @brief: Quickly create a new www-data group and set permissions for
# ${www_root:-/var/www/html}.
#
# - [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
# - [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
#
# This script will do the following:
# - Checks the www-data group exists, if not, create it.
# - Checks the user group exists, if not, create it.
# - Checks the user exists, if not, create it.
# - Checks the user is a member of the www-data group, if not, add them.
# - Set the correct permissions for the web root directory.
#
# #### examples:
# ```bash
#  vstacklet -www-perms -wwwR "/var/www/html"
#  vstacklet -www-perms -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html"
# ```
#
# #### or as a standalone script:
# ```bash
#  /opt/vstacklet/setup/www-permissions.sh -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html"
# ```
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
# Copyright (C) 2016-2022, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
www_permissions_version="$(grep -E '^# @version:' "/opt/vstacklet/setup/www-permissions.sh" | awk '{print $3}')"
################################################################################
# @name: vstacklet::wwwperms::args() (3)
# process options
# @description: Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L68-L99)
#
# notes:
# - This script function is responsible for processing the options passed to the
# script.
#
# @param: $1 (string) - The option to process.
# @param: $2 (string) - The value of the option to process.
# @break
################################################################################
vstacklet::wwwperms::args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-wwwU* | --www_user*)

			declare -g www_user="${2}"
			shift 2
			;;
		-wwwG* | --www_group*)
			declare -g www_group="${2}"
			shift 2
			;;
		-wwwR* | --www_root*)
			declare -g www_root="${2}"
			shift 2
			;;
		-h | --help)
			vstacklet::wwwperms::help
			exit 0
			;;
		-v | --version)
			declare -gi skip_intro="1"
			vstacklet::wwwperms::version
			exit 0
			;;
		*)
			vstacklet::shell::text::error "Unknown option: $1"
			exit 1
			;;
		esac
	done
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L108-L178)
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::functions() {
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
	vstacklet::shell::text::continue() {
		declare -g shell_color shell_icon
		shell_color=$(tput setaf 5)
		shell_icon="arrow"
		vstacklet::shell::output "$@"
	}
}

##################################################################################
# @name: vstacklet::environment::checkroot (1)
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L187-L192)
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		vstacklet::shell::text::error "you must be root to run this script."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::intro (4)
# @description: Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L201-L212)
# @script-note: This function is required for the installation of
# the vStacklet software.
# @break
##################################################################################
vstacklet::intro() {
	vstacklet::shell::text::white "Welcome to the vStacklet Web Root Permissions Utility."
	vstacklet::shell::text::white "This script will add a new www-data group on your server and set permissions for ${www_root:-/var/www/html}."
	vstacklet::shell::text::white "Please ensure you have read the documentation before continuing."
	vstacklet::shell::text::white "Documentation can be found at:"
	vstacklet::shell::text::white "https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/www-permissions.sh.md"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Press any key to continue..."
	read -r -n 1
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "checking permissions ... " && vstacklet::environment::checkroot
}

##################################################################################
# @name: vstacklet::wwwdata::create (5)
# @description: Adds a new www-data group and sets permissions for ${www_root:-/var/www/html}. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L229-L260)
# @option: $1 `-wwwU | --www_user` - The user to add to the www-data group. (default: www-data)
# @option: $2 `-wwwG | --www_group` - The group to create. (default: www-data) (optional)
# @option: $3 `-wwwR | --www_root` - The root directory to set permissions for. (default: /var/www/html) (optional)
# @option: $4 `-h | --help` - Prints the help message.
# @option: $5 `-v | --version` - Prints the version number.
# @arg: $1 - The username to add to the www-data group.
# @arg: $2 - The groupname to add to the www-data group.
# @arg: $3 - The web root directory to set permissions for.
# @arg: $4 - (no args) - Prints the help message.
# @arg: $5 - (no args) - Prints the version number.
# @break
##################################################################################
vstacklet::wwwdata::create() {
	# check if the www-data group exists
	if ! getent group www-data >/dev/null 2>&1; then
		vstacklet::shell::text::white "adding www-data group ... "
		groupadd www-data || {
			vstacklet::shell::text::error "failed to add www-data group."
			exit 1
		}
	fi
	# check if the group exists
	if ! getent group "${www_group:-www-data}" >/dev/null 2>&1; then
		vstacklet::shell::text::white "adding ${www_group:-www-data} group ... "
		groupadd "${www_group:-www-data}" || {
			vstacklet::shell::text::error "failed to add ${www_group:-www-data} group."
			exit 1
		}
	fi
	# check if the user exists
	if ! getent passwd "${www_user:-www-data}" >/dev/null 2>&1; then
		vstacklet::shell::text::white "adding ${www_user:-www-data} user ... "
		useradd -m -g "${www_group:-www-data}" "${www_user:-www-data}" || {
			vstacklet::shell::text::error "failed to add ${www_user:-www-data} user."
			exit 1
		}
	fi
	# add the user to the www-data group
	vstacklet::shell::text::white "adding ${www_user:-www-data} to www-data group ... "
	usermod -a -G www-data "${www_user:-www-data}" || {
		vstacklet::shell::text::error "failed to add ${www_user:-www-data} to www-data group."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::permissions::adjust (6)
# @description: Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L323-L326)
#
# notes:
# - Permissions are adjusted based the following variables:
#   - adjustments are made to the assigned web root on the `-wwwR | --www_root`
#    option
#   - adjustments are made to the default web root of `/var/www/html`
#   if the `-wwwR | --www_root` option is not used.
# - permissions are adjusted to the following:
#   - `root:www-data` (user:group)
#   - `755` (directory)
#   - `644` (file)
#   - `g+rw` (group read/write)
#   - `g+s` (group sticky)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::permissions::adjust() {
	vstacklet::shell::text::white "adjusting permissions ... "
	# change the ownership of everything under web root to root:${www_group:-www-data}
	vstacklet::shell::text::white "changing ownership of ${www_root:-/var/www/html} recursively to ${www_user:-www-data}:${www_group:-www-data} ... "
	chown "${www_user:-www-data}":"${www_group:-www-data}" -R "${www_root:-/var/www/html}" || {
		vstacklet::shell::text::error "failed to change ownership of ${www_root:-/var/www/html} to ${www_user:-www-data}:${www_group:-www-data}."
		exit 1
	}
	# change the ownership of web root to root:${www_group:-www-data}
	vstacklet::shell::text::white "changing ownership of ${www_root:-/var/www/html} to root:${www_group:-www-data} ... "
	chown root:"${www_group:-www-data}" "${www_root:-/var/www/html}" || {
		vstacklet::shell::text::error "failed to change ownership of ${www_root:-/var/www/html} to root:${www_group:-www-data}."
		exit 1
	}
	# change the permissions of directories under web root ${www_root} to 2775
	vstacklet::shell::text::white "changing permissions of ${www_root:-/var/www/html} to 2775 ... "
	find "${www_root:-/var/www/html}" -type d -exec chmod 2775 {} + || {
		vstacklet::shell::text::error "failed to change directory permissions of ${www_root:-/var/www/html} to 2775."
		exit 1
	}
	# change the permissions of files under web root ${www_root} to 0664
	vstacklet::shell::text::white "changing permissions of ${www_root:-/var/www/html} to 0664 ... "
	find "${www_root:-/var/www/html}" -type f -exec chmod 0664 {} + || {
		vstacklet::shell::text::error "failed to change file permissions of ${www_root:-/var/www/html} to 0664."
		exit 1
	}
	# sticky group permissions
	vstacklet::shell::text::white "setting sticky group permissions ... "
	find "${www_root:-/var/www/html}" -type d -exec chmod g+s {} + || {
		vstacklet::shell::text::error "failed to set sticky group permissions."
		exit 1
	}
	# sticky group read/write permissions
	vstacklet::shell::text::white "setting sticky group read/write permissions ... "
	chmod -R g+rw "${www_root:-/var/www/html}" || {
		vstacklet::shell::text::error "failed to set sticky group read/write permissions."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::permissions::complete (7)
# @description: Complete the permissions adjustment process. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L326-L329)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::permissions::complete() {
	vstacklet::shell::text::success "permissions adjustment complete."
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::wwwperms::help (8)
# @description: Prints the help message for the www-data group. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L335-L366)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::wwwperms::help() {
	vstacklet::shell::text::white "usage: vstacklet -www-perms [options] [args]"
	vstacklet::shell::text::white "file version: ${www_permissions_version}"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "options:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -wwwU | --www_user"
	vstacklet::shell::text::white "  -wwwG | --www_group"
	vstacklet::shell::text::white "  -wwwR | --www_root"
	vstacklet::shell::text::white "  -h | --help"
	vstacklet::shell::text::white "  -v | --version"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "args:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  [www_user] - the user to add to the www-data group"
	vstacklet::shell::text::white "  [www_group] - the group to add to the www-data group"
	vstacklet::shell::text::white "  [www_root] - the web root to adjust permissions for"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "examples:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  vstacklet -www-perms -wwwU \"www-data\" -wwwG \"www-data\" -wwwR \"/var/www/html\""
	vstacklet::shell::text::white "  vstacklet -www-perms -h"
	vstacklet::shell::text::white "  vstacklet -www-perms -v"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "standalone:"
	vstacklet::shell::text::white "  /opt/vstacklet/setup/www-permissions.sh -wwwU \"www-data\" -wwwG \"www-data\" -wwwR \"/var/www/html\""
	vstacklet::shell::text::white "  /opt/vstacklet/setup/www-permissions.sh --help"
	vstacklet::shell::text::white "  /opt/vstacklet/setup/www-permissions.sh --version"
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::wwwperms::version (9)
# @description: Prints the version of the www-permissions script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/www-permissions.sh#L375-L378)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::wwwperms::version() {
	vstacklet::shell::text::white "vStacklet www-permissions.sh file version: ${www_permissions_version}"
	vstacklet::shell::misc::nl
}

################################################################################
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::checkroot #(1)
vstacklet::environment::functions #(2)
vstacklet::wwwperms::args "$@"    #(3)
if [[ -z ${skip_intro} ]]; then
	vstacklet::intro #(4)
fi
vstacklet::wwwdata::create                                                             #(5)
vstacklet::permissions::adjust                                                         #(6)
vstacklet::permissions::complete                                                       #(7)
[[ "$*" =~ "-v" ]] || [[ "$*" =~ "--version" ]] && vstacklet::wwwperms::version #(8)
[[ "$*" =~ "-h" ]] || [[ "$*" =~ "--help" ]] && vstacklet::wwwperms::help       #(9)
