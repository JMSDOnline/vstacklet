#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: www-permissions.sh
# @version: 3.1.1074
# @description: This script will add a new www-data group on your server
# and set permissions for ${www_root:-/var/www/html}.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: bin/backup/backup-cleanup
#
# @brief: Cleanup old backups
#
# This script will do the following:
# 1. Remove backups older than X days
# 2. Remove backups older than X weeks
#
# @usage: backup-cleanup [OPTIONS]
#
# Options:
#   -dir, --directories  Path to backup directories
#   -db, --databases     Path to backup databases
#   -d, --days           Number of days to keep daily backups
#   -w, --weeks          Number of days to keep weekly backups
#   -h, --help           Display this help message
#   -v, --version        Display version information
#
# #### examples:
# ```bash
#  /opt/vstacklet/bin/backup/backup-cleanup.sh -dir /backup/directories/ -db /backup/databases/ -d 1 -w 30
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
# Copyright (C) 2016-2022, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################
vsbackup_version="$(grep -E '^# @version:' "/opt/vstacklet/bin/backup/vs-backup.sh" | awk '{print $3}')"
################################################################################
# @name: vstacklet::backup::args() (3)
# process options
# @description: Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L67)
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
		-dir | --directories)
			# Path to backup directories
			#DIRS="/backup/directories/"
			shift
			DIRS="$1"
			shift
			;;
		-db | --databases)
			# Path to backup databases
			#DBS="/backup/databases/"
			shift
			DBS="$1"
			shift
			;;
		-d | --days)
			# Number of days to keep daily backups
			#DAYS=3
			shift
			DAYS="$1"
			shift
			;;
		-w | --weeks)
			# Number of days to keep weekly backups
			#WEEKS=30
			shift
			WEEKS="$1"
			shift
			;;
		-h | --help)
			vstacklet::backup::usage
			exit 0
			;;
		-v | --version)
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
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L121)
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
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L208)
# @script-note: This function is required for the installation of the vStacklet software.
# @break
##################################################################################
vstacklet::environment::checkroot() {
	[[ $(whoami) != "root" ]] && {
		vstacklet::shell::text::error "you must be root to run this script."
		exit 1
	}
}

vstacklet::backup::clean() {
	# Remove directory backups older than X days
	vstacklet::shell::text::white "Removing directory backups older than ${DAYS:-3} days..."
	find "${DIRS:-/backup/directories/}" -name '*.tgz' -mtime +"${DAYS:-3}" -exec rm -f {} \;
	# Remove database backups older than X days
	vstacklet::shell::text::white "Removing database backups older than ${DAYS:-3} days..."
	find "${DBS:-/backup/databases/}" -name '*.gz' -mtime +"${DAYS:-3}" -exec rm -f {} \;
	# Remove weekly backups older than X days
	vstacklet::shell::text::white "Removing weekly backups older than ${WEEKS:-30} days..."
	find "${WEEKLY:-/backup/weekly/}" -name '*.gz' -mtime +"${WEEKS:-30}" -exec rm -f {} \;
}

vstacklet::backup::usage() {
	echo "Usage: backup-cleanup [OPTIONS]"
	echo "Options:"
	echo "  -dir, --directories  Path to backup directories"
	echo "  -db, --databases     Path to backup databases"
	echo "  -d, --days           Number of days to keep daily backups"
	echo "  -w, --weeks          Number of days to keep weekly backups"
	echo "  -h, --help           Display this help message"
	echo "  -v, --version        Display version information"
}

################################################################################
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::checkroot #(1)
vstacklet::environment::functions #(2)
vstacklet::backup::args "$@"
vstacklet::backup::clean

################################################################################
# Example Cronjob
# Remove Backups Greater than 1 Days Old Daily @ 10:00 PM
# 0 22 * * * root /opt/vstacklet/bin/backup/backup-cleanup.sh -dir /backup/directories/ -db /backup/databases/ -d 1 -w 30
################################################################################
