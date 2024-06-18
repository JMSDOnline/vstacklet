#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: www-permissions.sh
# @version: 3.1.1090
# @description: This script will add a new www-data group on your server
# and set permissions for ${www_root:-/var/www/html/vsapp}.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: bin/www-permissions.sh
#
# @brief: Quickly create a new www-data group and set permissions for
# ${www_root:-/var/www/html/vsapp}.
#
# - [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
# - [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)
#
# This script will do the following:
# - Checks the www-data group exists, if not, create it.
# - Checks the user group exists, if not, create it.
# - Checks the user exists, if not, create it.
# - Checks the user is a member of the www-data group, if not, add them.
# - Set the correct permissions for the web root directory.
#
# #### examples:
# Set the correct permissions for the web root directory:
# ```bash
#  vs-perms -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html/vsapp"
# ```
# Display the help message:
# ```bash
#  vs-perms -h
# ```
# Display the version number:
# ```bash
#  vs-perms -V
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
# Copyright (C) 2016-2024, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
# @name: vstacklet::vsperms::args() (3)
# process options
# @description: Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L69-L100)
#
# notes:
# - This script function is responsible for processing the options passed to the
# script.
#
# @param: $1 (string) - The option to process.
# @param: $2 (string) - The value of the option to process.
# @break
################################################################################
vstacklet::vsperms::args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-h | --help)
			declare -gi skip_intro="1"
			vstacklet::vsperms::help
			exit 0
			;;
		-V | --version)
			declare -gi skip_intro="1"
			vstacklet::vsperms::version
			exit 0
			;;
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
		*)
			vstacklet::shell::text::error "Unknown option: $1"
			exit 1
			;;
		esac
	done
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L107-L186)
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
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L193-L198)
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		vstacklet::shell::text::error "you must be root to run this script."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::vsperms::updater (3)
# @description: Update the permissions script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L205-L219)
# @break
##################################################################################
vstacklet::vsperms::updater() {
	# @script-note: check if the version is greater than the current version
	current_version=$(grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" /usr/local/bin/vs-perms)
	upstream_version=$(curl -s "https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/bin/www-permissions.sh" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
	[[ "${current_version}" == "${upstream_version}" ]] && vstacklet::shell::text::success "The permissions script is up to date. Proceeding..." && vstacklet::shell::misc::nl
	if [[ "${current_version}" != "${upstream_version}" ]]; then
		vstacklet::shell::text::white "Updating the permissions script..."
		# @script-note: download the latest version of www-permissions (vs-perms)
		curl -s "https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/bin/www-permissions.sh" -o /usr/local/bin/vs-perms
		# @script-note: set the permissions
		chmod +x /usr/local/bin/vs-perms
		vstacklet::shell::text::success "The permissions script has been updated."
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::intro (4)
# @description: Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L226-L243)
# @break
##################################################################################
vstacklet::intro() {
	vstacklet::shell::text::white "Welcome to the vStacklet Web Root Permissions Utility."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "This script will add a new www-data group on your server and set permissions for ${www_root:-/var/www/html/vsapp}."
	vstacklet::shell::text::white "Please ensure you have read the documentation before continuing."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Documentation can be found at:"
	vstacklet::shell::text::white "https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions.sh.md"
	vstacklet::shell::misc::nl
	vstacklet::ask::continue
}

# shall we continue? function (6.a)
vstacklet::ask::continue() {
	vstacklet::shell::text::green "Press any key to continue $(tput setaf 7)(${shell_reset}$(tput setaf 3)ctrl+C${shell_reset} $(tput setaf 7)on PC or $(tput setaf 7)${shell_reset}$(tput setaf 3)⌘+C${shell_reset} $(tput setaf 7)on Mac to ${shell_reset}$(tput setaf 1)exit${shell_reset}$(tput setaf 7)) ..."
	read -r -n 1
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::vsperms::create (5)
# @description: Adds a new www-data group and sets permissions for ${www_root:-/var/www/html/vsapp}. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L260-L291)
# @option: $1 `-wwwU | --www_user` - The user to add to the www-data group. (default: www-data)
# @option: $2 `-wwwG | --www_group` - The group to create. (default: www-data) (optional)
# @option: $3 `-wwwR | --www_root` - The root directory to set permissions for. (default: /var/www/html/vsapp) (optional)
# @option: $4 `-wwwh | --www_help` - Prints the help message.
# @option: $5 `-wwwv | --www_version` - Prints the version number.
# @arg: $1 - The username to add to the www-data group.
# @arg: $2 - The groupname to add to the www-data group.
# @arg: $3 - The web root directory to set permissions for.
# @arg: $4 - (no args) - Prints the help message.
# @arg: $5 - (no args) - Prints the version number.
# @break
##################################################################################
vstacklet::vsperms::create() {
	# @script-note: check if the www-data group exists
	if ! getent group www-data >/dev/null 2>&1; then
		vstacklet::shell::text::white "adding www-data group ... "
		groupadd www-data || {
			vstacklet::shell::text::error "failed to add www-data group."
			exit 1
		}
	fi
	# @script-note: check if the group exists
	if ! getent group "${www_group:-www-data}" >/dev/null 2>&1; then
		vstacklet::shell::text::white "adding ${www_group:-www-data} group ... "
		groupadd "${www_group:-www-data}" || {
			vstacklet::shell::text::error "failed to add ${www_group:-www-data} group."
			exit 1
		}
	fi
	# @script-note: check if the user exists
	if ! getent passwd "${www_user:-www-data}" >/dev/null 2>&1; then
		vstacklet::shell::text::white "adding ${www_user:-www-data} user ... "
		useradd -m -g "${www_group:-www-data}" "${www_user:-www-data}" || {
			vstacklet::shell::text::error "failed to add ${www_user:-www-data} user."
			exit 1
		}
	fi
	# @script-note: add the user to the www-data group
	vstacklet::shell::text::white "adding ${www_user:-www-data} to www-data group ... "
	usermod -a -G www-data "${www_user:-www-data}" || {
		vstacklet::shell::text::error "failed to add ${www_user:-www-data} to www-data group."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::vsperms::adjust (6)
# @description: Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L313-L351)
#
# notes:
# - Permissions are adjusted based the following variables:
#   - adjustments are made to the assigned web root on the `-wwwR | --www_root`
#    option
#   - adjustments are made to the default web root of `/var/www/html/vsapp`
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
vstacklet::vsperms::adjust() {
	vstacklet::shell::text::white "adjusting permissions ... "
	# @script-note: change the ownership of everything under web root to root:${www_group:-www-data}
	vstacklet::shell::text::white "changing ownership of ${www_root:-/var/www/html/vsapp} recursively to ${www_user:-www-data}:${www_group:-www-data} ... "
	chown "${www_user:-www-data}":"${www_group:-www-data}" -R "${www_root:-/var/www/html/vsapp}" || {
		vstacklet::shell::text::error "failed to change ownership of ${www_root:-/var/www/html/vsapp} to ${www_user:-www-data}:${www_group:-www-data}."
		exit 1
	}
	# @script-note: change the ownership of web root to root:${www_group:-www-data}
	vstacklet::shell::text::white "changing ownership of ${www_root:-/var/www/html/vsapp} to root:${www_group:-www-data} ... "
	chown root:"${www_group:-www-data}" "${www_root:-/var/www/html/vsapp}" || {
		vstacklet::shell::text::error "failed to change ownership of ${www_root:-/var/www/html/vsapp} to root:${www_group:-www-data}."
		exit 1
	}
	# @script-note: change the permissions of directories under web root ${www_root} to 2755
	vstacklet::shell::text::white "changing permissions of ${www_root:-/var/www/html/vsapp} to 2755 ... "
	find "${www_root:-/var/www/html/vsapp}" -type d -exec chmod -R 2755 {} + || {
		vstacklet::shell::text::error "failed to change directory permissions of ${www_root:-/var/www/html/vsapp} to 2755."
		exit 1
	}
	# @script-note: change the permissions of files under web root ${www_root} to 0664
	vstacklet::shell::text::white "changing permissions of ${www_root:-/var/www/html/vsapp} to 0664 ... "
	find "${www_root:-/var/www/html/vsapp}" -type f -exec chmod -R 0664 {} + || {
		vstacklet::shell::text::error "failed to change file permissions of ${www_root:-/var/www/html/vsapp} to 0664."
		exit 1
	}
	# @script-note: sticky group permissions
	vstacklet::shell::text::white "setting sticky group permissions ... "
	find "${www_root:-/var/www/html/vsapp}" -type d -exec chmod g+s {} + || {
		vstacklet::shell::text::error "failed to set sticky group permissions."
		exit 1
	}
	# @script-note: sticky group read/write permissions
	vstacklet::shell::text::white "setting sticky group read/write permissions ... "
	chmod -R g+rw "${www_root:-/var/www/html/vsapp}" || {
		vstacklet::shell::text::error "failed to set sticky group read/write permissions."
		exit 1
	}
	# @script-note: change file permissions on config files (this is useful for WordPress installations)
	# Check the directory for wp-config.php and set the permissions to 440
	if [[ -n $(find "${www_root:-/var/www/html/vsapp}" -type f -name "wp-config.php") ]]; then
		vstacklet::shell::text::white "changing permissions of wp-config.php to 440 ... "
		find "${www_root:-/var/www/html/vsapp}" -type f -name "wp-config" -exec chmod 440 {} + || {
			vstacklet::shell::text::error "failed to change permissions of wp-config.php to 440."
			exit 1
		}
	fi
	# @script-note: check the directories for any .conf files and set the permissions to 440 (this is useful for Nginx configurations)
	# Check several levels deep for .conf files
	if [[ -n $(find "${www_root:-/var/www/html/vsapp}" -type f -name "*.conf") ]]; then
		vstacklet::shell::text::white "changing permissions of ${www_root:-/var/www/html/vsapp}/*.conf to 440 ... "
		find "${www_root:-/var/www/html/vsapp}" -type f -name "*.conf" -exec chmod 440 {} + || {
			vstacklet::shell::text::error "failed to change permissions of ${www_root:-/var/www/html/vsapp}/*.conf to 440."
			exit 1
		}
	fi
}

##################################################################################
# @name: vstacklet::vsperms::complete (7)
# @description: Prints completion of the permissions adjustment process. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L360-L365)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::vsperms::complete() {
	vstacklet::shell::text::success "permissions adjustment complete!"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Thank you for using the vStacklet Web Root Permissions Utility."
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::vsperms::help
# @description: Prints the help message for the vs-perms script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L374-L419)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::vsperms::help() {
	vstacklet::shell::text::white "Usage: ${0} [OPTION] [ARGUMENT]"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Adds a new www-data group and sets permissions for ${www_root:-/var/www/html/vsapp}."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Options:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -h, --help"
	vstacklet::shell::text::white "    Display this help message."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -V, --version"
	vstacklet::shell::text::white "    Display the version of this script."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -wwwU, --www_user"
	vstacklet::shell::text::white "    The user to add to the www-data group. (default: www-data)"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -wwwG, --www_group"
	vstacklet::shell::text::white "    The group to create. (default: www-data)"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -wwwR, --www_root"
	vstacklet::shell::text::white "    The root directory to set permissions for. (default: /var/www/html/vsapp)"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Args:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  [www_user]"
	vstacklet::shell::text::white "    The username to add to the www-data group."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  [www_group]"
	vstacklet::shell::text::white "    The groupname to add to the www-data group."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  [www_root]"
	vstacklet::shell::text::white "    The web root directory to set permissions for."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Examples:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  /opt/vstacklet/bin/www-permissions.sh -wwwU \"www-data\" -wwwG \"www-data\" -wwwR \"/var/www/html/vsapp\""
	vstacklet::shell::text::white "  /opt/vstacklet/bin/www-permissions.sh -h"
	vstacklet::shell::text::white "  /opt/vstacklet/bin/www-permissions.sh -V"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Standalone:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  vs-perms -wwwU \"www-data\" -wwwG \"www-data\" -wwwR \"/var/www/html/vsapp\""
	vstacklet::shell::text::white "  vs-perms -h"
	vstacklet::shell::text::white "  vs-perms -V"
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::vsperms::version
# @description: Prints the version of the vs-perms (www-permissions) script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L428-L435)
# @nooptions
# @noargs
# @break
##################################################################################
vstacklet::vsperms::version() {
	www_permissions_version="$(grep -E '^# @version:' "/usr/local/bin/vs-perms" | awk '{print $3}')" || {
		vstacklet::shell::text::error "failed to get www-permissions.sh file version."
		exit 1
	}
	vstacklet::shell::text::white "vStacklet vs-perms file version: ${www_permissions_version}"
	vstacklet::shell::misc::nl
}

################################################################################
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::checkroot          #(1)
vstacklet::environment::functions          #(2)
vstacklet::vsperms::updater                #(3)
vstacklet::vsperms::args "$@"              #(4)
[[ -z ${skip_intro} ]] && vstacklet::intro #(5)
vstacklet::vsperms::create                 #(6)
vstacklet::vsperms::adjust                 #(7)
vstacklet::vsperms::complete               #(8)
