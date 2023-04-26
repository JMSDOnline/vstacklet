#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: directory-backup.sh
# @version: 3.1.1117
# @description: This script will create a backup of specified directories.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: bin/backup/directory-backup.sh
#
# @brief: Create a backup of specified directories
#
# This script will do the following:
# - Create a backup of specified directories
#
# #### options:
# | Short | Long                       | Description
# | ----- | -------------------------- | ------------------------------------------
# |  `-t` | `--temporary_directory`    | Path to temporary directory (default: /tmp/vstacklet/backup/directories/) [optional]
# |  `-d` | `--destination_directory`  | Path to backup directories (default: /backup/directories/) [optional]
# |  `-f` | `--file`                   | File/Directory to backup (default: /var/www/html)
# |  `-a` | `--all`                    | Backup all files in directory (default: false)
# |  `-ec`| `--example_cron`           | Display example cron entry
# |  `-h` | `--help`                   | Display this help message
# |  `-V` | `--version`                | Display version information
#
# #### examples:
# ```bash
#  /opt/vstacklet/bin/backup/directory-backup.sh -f /var/www/html -d /backup/directories/ -t /tmp/directories/ -a
# ```
#
# notes:
# - This script is intended to be used with the vstacklet backup script.
# - When using the `-a` option, the script will backup all files in the directory
# specified with the `-f` option.
# - When using the `-f` option, the script will backup the specified file only.
#
# @dependencies: tar, gzip, find, xargs, rm
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
##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/directory-backup.sh#L63-L142)
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
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/directory-backup.sh#L149-L154)
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		vstacklet::shell::text::error "you must be root to run this script."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::backup::main (3)
# @description: The main function of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/directory-backup.sh#L161-L272)
# @break
##################################################################################
vstacklet::backup::main() {
	# set the version of the backup script
	VERSION="$(grep -E '^# @version:' "/opt/vstacklet/bin/backup/vs-backup.sh" | awk '{print $3}')"
	# set the backup destination
	TMP_DIR_DEST="${TMP_DIR_DEST:-/tmp/vstacklet/backup/directories}"
	DIR_DEST="${DIR_DEST:-/backup/directories}"
	# set the backup source
	DIR_BFILES="${DIR_BFILES:-/var/www/html}"
	# set the backup package
	PACKAGE="${PACKAGE:-$(date +%Y-%m-%d-%H-%M-%S).tar.gz}"
	# set the backup package
	ALL="${ALL:-false}"
	# set the backup package
	HELP="${HELP:-false}"
	# set the backup package
	VERSION="${VERSION:-false}"
	# set the backup package
	DESTINATION="${DESTINATION:-false}"
	# set the backup package
	TEMPORARY="${TEMPORARY:-false}"
	# set the backup package
	FILE="${FILE:-false}"
	# parse the command line arguments
	while [ $# -gt 0 ]; do
		case "${1}" in
		-h | --help)
			HELP=true
			shift
			;;
		-ec | --example_cron)
			EXAMPLE_CRON=true
			shift
			;;
		-V | --version)
			VERSION=true
			shift
			;;
		-d | --destination_directory)
			DESTINATION="${2}"
			shift
			shift
			;;
		-t | --temporary_directory)
			TEMPORARY="${2}"
			shift
			shift
			;;
		-f | --file)
			FILE="${2}"
			shift
			shift
			;;
		-a | --all)
			ALL=true
			shift
			;;
		*)
			vstacklet::shell::text::red "Invalid argument: ${1}"
			vstacklet::shell::misc::nl
			vstacklet::backup::usage
			exit 1
			;;
		esac
	done
	# check if the help flag was set
	[ "${HELP}" = true ] && vstacklet::backup::usage && exit 0
	# check if the example cron flag was set
	[ "${EXAMPLE_CRON}" = true ] && vstacklet::backup::example_cron && exit 0
	# check if the version flag was set
	[ "${VERSION}" = true ] && vstacklet::backup::version && exit 0
	# check if the destination directory flag was set
	[ "${DESTINATION}" != false ] && DIR_DEST="${DESTINATION}"
	# check if the temporary directory flag was set
	[ "${TEMPORARY}" != false ] && TMP_DIR_DEST="${TEMPORARY}"
	# check if the file flag was set
	[ "${FILE}" != false ] && DIR_BFILES="${FILE}"
	# check if the all flag was set
	[ "${ALL}" = true ] && DIR_BFILES="${DIR_BFILES}/*"
	# ensure the directories needed exist
	vstacklet::shell::text::white "Creating backup directories if they don't exist..."
	vstacklet::shell::misc::nl
	[[ ! "${TMP_DIR_DEST:-/tmp/vstacklet/backup/directories}" ]] && mkdir -p "${TMP_DIR_DEST:-/tmp/vstacklet/backup/directories}" 2>&1
	[[ ! "${DIR_DEST:-/backup/directories}" ]] && mkdir -p "${DIR_DEST:-/backup/directories}" 2>&1
	vstacklet::shell::text::success "Backup directories created successfully."
	vstacklet::shell::misc::nl
	# check if the destination directory exists
	[ ! -d "${DIR_DEST}" ] && vstacklet::shell::text::red "Destination directory does not exist: ${DIR_DEST}" && vstacklet::shell::misc::nl && exit 1
	# check if the temporary directory exists
	[ ! -d "${TMP_DIR_DEST}" ] && vstacklet::shell::text::red "Temporary directory does not exist: ${TMP_DIR_DEST}" && vstacklet::shell::misc::nl && exit 1
	# check if the backup source directory exists
	[ ! -d "${DIR_BFILES}" ] && vstacklet::shell::text::red "Backup source directory does not exist: ${DIR_BFILES}" && vstacklet::shell::misc::nl && exit 1
	# check if the backup source directory is empty
	[ -z "$(ls -A "${DIR_BFILES}")" ] && vstacklet::shell::text::red "Backup source directory is empty: ${DIR_BFILES}" && vstacklet::shell::misc::nl && exit 1
	# check if the destination backup package exists
	[ -f "${DIR_DEST}/${PACKAGE}" ] && vstacklet::shell::text::red "Backup package already exists: ${DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
	# check if the temporary backup package exists
	[ -f "${TMP_DIR_DEST}/${PACKAGE}" ] && vstacklet::shell::text::red "Backup package already exists: ${TMP_DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
	# create the backup package
	tar -czf "${TMP_DIR_DEST}/${PACKAGE}" -C "${DIR_BFILES}" .
	# move the backup package to the destination directory
	mv "${TMP_DIR_DEST}/${PACKAGE}" "${DIR_DEST}/${PACKAGE}"
	# check if the destination backup package exists
	[ ! -f "${DIR_DEST}/${PACKAGE}" ] && vstacklet::shell::text::red "Backup package does not exist: ${DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
	# check if the temporary backup package exists
	[ ! -f "${TMP_DIR_DEST}/${PACKAGE}" ] && vstacklet::shell::text::red "Backup package does not exist: ${TMP_DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
	# check if the destination backup package is empty
	[ -z "$(ls -A "${DIR_DEST}/${PACKAGE}")" ] && vstacklet::shell::text::red "Backup package is empty: ${DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
	# check if the temporary backup package is empty
	[ -z "$(ls -A "${TMP_DIR_DEST}/${PACKAGE}")" ] && vstacklet::shell::text::red "Backup package is empty: ${TMP_DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
	# check if the backup package is the correct size
	[ "$(stat -c%s "${DIR_DEST}/${PACKAGE}")" != "$(stat -c%s "${TMP_DIR_DEST}/${PACKAGE}")" ] && vstacklet::shell::text::red "Backup package is the incorrect size: ${DIR_DEST}/${PACKAGE}" && vstacklet::shell::misc::nl && exit 1
}

##################################################################################
# @name: vstacklet::backup::usage (5)
# @description: Display the usage of the backup script.
# @script-note: This function is required for the installation of the
# vStacklet software.
# @break
##################################################################################
vstacklet::backup::usage() {
	vstacklet::shell::text::white "Usage: ${0} [OPTION]..."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Backup specified directories to a local directory."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Options:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -h, --help"
	vstacklet::shell::text::white "    Display this help message."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -d, --destination_directory"
	vstacklet::shell::text::white "    Specify the destination directory for the backup."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -t, --temporary_directory"
	vstacklet::shell::text::white "    Specify the temporary directory for the backup."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -f, --file"
	vstacklet::shell::text::white "    Specify the file to backup."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -a, --all"
	vstacklet::shell::text::white "    Backup all files in the specified directory."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -ec, --example_cron"
	vstacklet::shell::text::white "    Display an example cron entry."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -V, --version"
	vstacklet::shell::text::white "    Display the version of this script."
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::backup::example_cron (6)
# @description: Example cron job for the backup script.
# @break
##################################################################################
vstacklet::backup::example_cron() {
	vstacklet::shell::text::white "Example Cron Job:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  # Example Schedule"
	vstacklet::shell::text::white "  # Backup Website Direcory Daily @ 12:45 AM"
	vstacklet::shell::text::white "  45 00 * * * root /opt/vstacklet/bin/backup/directory-backup.sh -d /backups/website-files -t /tmp/website-files -f /var/www/html -a"
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::backup::version (7)
# @description: Display the version of the backup script.
# @break
##################################################################################
vstacklet::backup::version() {
	vstacklet::shell::text::white "vStacklet Backup Script v${VERSION}"
	vstacklet::shell::misc::nl
}

################################################################################
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::functions
vstacklet::environment::checkroot
vstacklet::backup::main "${@}"
