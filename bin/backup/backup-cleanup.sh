#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: backup-cleanup.sh
# @version: 3.1.1105
# @description: This script will add a new www-data group on your server
# and set permissions for ${www_root:-/var/www/html}.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: bin/backup/backup-cleanup.sh
#
# @brief: Cleanup old backups
#
# This script will do the following:
# - Remove backups older than X days
# - Remove backups older than X weeks
#
# #### options:
# | Short  | Long                         | Description
# | ------ | ---------------------------- | ------------------------------------------
# |  -fbd  | --file_backup_directory      | Path to backup files
# |  -dbbd | --database_backup_directory  | Path to backup databases
# |  -d    | --days                       | Number of days to keep backups (default: 3)
# |  -w    | --weeks                      | Number of weeks to keep backups (default: 4)
# |  -ec   | --example_cron               | Display example cron entry
# |  -h    | --help                       | Display this help message
# |  -V    | --version                    | Display version information
#
# #### examples:
# ```bash
#  /opt/vstacklet/bin/backup/backup-cleanup.sh -fbd /backup/files/ -dbbd /backup/databases/ [ -d 3 ] [ -w 4 ]
# ```
#
# @dependencies: find, xargs, rm
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
# Copyright (C) 2016-2023, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
# @name: vstacklet::backup::args() (3)
# process options
# @description: Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L66-L117)
#
# notes:
# - This script function is responsible for processing the options passed to the
# script.
#
# @param: $1 (string) - The option to process.
# @param: $2 (string) - The value of the option to process.
# @break
################################################################################
vstacklet::backup::args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-fbd | --file_backup_directory)
			# Path to backup files
			#fbd="/backup/files/"
			shift
			fbd="$1"
			shift
			;;
		-dbbd | --database_backup_directory)
			# Path to backup databases
			#dbbd="/backup/databases/"
			shift
			dbbd="$1"
			shift
			;;
		-d | --days)
			# Number of days to keep daily backups
			#days=3
			shift
			days="$1"
			shift
			;;
		-w | --weeks)
			# Number of days to keep weekly backups
			#weeks=4
			shift
			weeks="$1"
			shift
			;;
		-ec | --example_cron)
			vstacklet::backup::example_cron
			exit 0
			;;
		-h | --help)
			vstacklet::backup::usage
			exit 0
			;;
		-V | --version)
			vsbackup_version="$(grep -E '^# @version:' "/opt/vstacklet/bin/backup/vs-backup" | awk '{print $3}')"
			echo "vStacklet Backup Version: ${vsbackup_version}"
			exit 0
			;;
		*)
			echo "Invalid argument: $1"
			vstacklet::backup::usage
			exit 1
			;;
		esac
	done
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L125-L204)
# @script-note: This function is required for the installation of the vStacklet software.
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
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L211-L216)
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		vstacklet::shell::text::error "you must be root to run this script."
		exit 1
	}
}

##################################################################################
# @name: vstacklet::backup::clean (4)
# @description: Main function for cleaning up backups. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L223-L244)
# @break
##################################################################################
vstacklet::backup::clean() {
	[[ -n "${days}" ]] && {
		declare -i days
		days="${days:-3}"
		# Remove directory backups older than X days
		vstacklet::shell::text::white "Removing directory backups older than ${days:-3} days..."
		find "${fbd:-/backup/files/}" -name '*.tgz' -mtime +"${days:-3}" -exec rm -f {} \;
		# Remove database backups older than X days
		vstacklet::shell::text::white "Removing database backups older than ${days:-3} days..."
		find "${dbbd:-/backup/databases/}" -name '*.gz' -mtime +"${days:-3}" -exec rm -f {} \;
	}
	[[ -n "${weeks}" ]] && {
		# Convert weeks to days
		declare -i days
		days=$(echo "(7 * ${weeks:-4})" | bc)
		# Remove directory backups older than X days (converted from weeks)
		vstacklet::shell::text::white "Removing daily backups older than ${days:-7} weeks..."
		find "${fbd:-/backup/files/}" -name '*.gz' -mtime +"${days:-7}" -exec rm -f {} \;
		vstacklet::shell::text::white "Removing database backups older than ${days:-7} weeks..."
		find "${dbbd:-/backup/databases/}" -name '*.gz' -mtime +"${days:-7}" -exec rm -f {} \;
	}
}

##################################################################################
# @name: vstacklet::backup::usage
# @description: Display usage information for the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L251-L280)
# @break
##################################################################################
vstacklet::backup::usage() {
	vstacklet::shell::text::white "Usage: ${0} [OPTION]..."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Clean up old backups older than X days or X weeks."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Options:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -h, --help"
	vstacklet::shell::text::white "    Display this help message."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -fbd, --file_backup_directory"
	vstacklet::shell::text::white "    Path to backup files.
	Default: /backup/files/"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -dbbd, --database_backup_directory"
	vstacklet::shell::text::white "    Path to backup databases.
	Default: /backup/databases/"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -d, --days"
	vstacklet::shell::text::white "    Number of days to keep backups.
	Default: 3"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -w, --weeks"
	vstacklet::shell::text::white "    Number of weeks to keep backups.
	Default: 4"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -V, --version"
	vstacklet::shell::text::white "    Display version information."
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::backup::example_cron
# @description: Example cron job for the backup script.
# @break
##################################################################################
vstacklet::backup::example_cron() {
	vstacklet::shell::text::white "Example Cron Job:"
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  # Example Schedule"
	vstacklet::shell::text::white "  # Remove Backups Greater than 3 Days Old Daily @ 10:00 PM"
	vstacklet::shell::text::white "  0 22 * * * root /opt/vstacklet/bin/backup/backup-cleanup.sh -fbd \"/backup/files/\" -dbbd \"/backup/databases/\" -d 3"
	vstacklet::shell::misc::nl
}

################################################################################
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::checkroot #(1)
vstacklet::environment::functions #(2)
vstacklet::backup::args "$@"
vstacklet::backup::clean
