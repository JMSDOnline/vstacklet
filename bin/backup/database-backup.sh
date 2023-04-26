#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: database-backup.sh
# @version: 3.1.1094
# @description: This script will create a backup of all databases.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: bin/backup/database-backup.sh
#
# @brief: Create database backups
#
# This script will do the following:
# 1. Create a backup of all databases
#
# @usage: database-backup.sh [OPTIONS]
#
# Options:
#   -tmp_dir, --tmp_dir             Path to temporary directory
#   -backup_dir, --backup_dir       Path to backup directory
#   -db, --databases                Database name
#   -db_user, --database_user       Database user
#   -db_pwd, --database_password    Database password
#   -h, --help                      Display this help message
#   -v, --version                   Display version information
#
# #### examples:
# ```bash
#  /opt/vstacklet/bin/backup/database-backup.sh -tmp_dir /tmp/backup/databases/ -backup_dir /backup/databases/ -db database_name -db_user database_user -db_pwd database_password
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
		-tmp_dir | --tmp_dir)
			# Path to backup directories
			declare -g TMP_DIR="${2}"
			shift
			;;
		-backup_dir | --backup_dir)
			# Path to backup directories
			declare -g BACKUP_DIR="${2}"
			shift
			;;
		-db | --databases)
			# Datebase name
			declare -a DB_LIST=("${2}")
			shift
			;;
		-dbuser | --database_user)
			# Datebase user
			declare -g DB_USER="${2}"
			shift
			;;
		-dbpass | --database_password)
			# Datebase password
			declare -g DB_PWD="${2}"
			shift
			;;
		-h | --help)
			# Display help
			vstacklet::backup::usage
			exit 0
			;;
		-v | --version)
			# Display version
			echo "Version: ${vsbackup_version}"
			exit 0
			;;
		*)
			# Unknown option
			echo "Unknown option: $1"
			vstacklet::backup::usage
			exit 1
			;;
		esac
		shift
	done
}

##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L123)
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
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L187-L192)
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
# @name: vstacklet::backup::database (4)
# @description: Backup a database to a file.
# @script-note: This function is required for the installation of the
# vStacklet software.
# @break
##################################################################################
vstacklet::backup::database() {
	DATE_STAMP=$(date +%b-%d-%y)
	# Create directories if they don't exist.
	vstacklet::shell::text::white "Creating backup directories if they don't exist..."
	vstacklet::shell::misc::nl
	[[ ! -d "${TMP_DIR:-/tmp/vstacklet/backup/databases/}" ]] && mkdir -p "${TMP_DIR:-/tmp/vstacklet/backup/databases/}"
	[[ ! -d "${BACKUP_DIR:-/backup/databases/}" ]] && mkdir -p "${BACKUP_DIR:-/backup/databases/}"
	# Print start status message.
	vstacklet::shell::text::white "Backing up ${DB_LIST[*]} database(s) to ${BACKUP_DIR}${DATE_STAMP}..."
	vstacklet::shell::text::white "Date: ${DATE_STAMP}"
	vstacklet::shell::misc::nl
	for DB in "${DB_LIST[@]}"; do
		mysqldump --opt -u"${DB_USER}" -p"${DB_PWD}" --add-drop-table --lock-tables --databases "${DB}" >"${TMP_DIR}${DATE_STAMP}.${DB}.sql"
		tar zcf "${BACKUP_DIR}${DATE_STAMP}.${DB}.tar.gz" "${TMP_DIR}${DATE_STAMP}.${DB}.sql"
		rm "${TMP_DIR}${DATE_STAMP}.${DB}.sql"
	done
	vstacklet::shell::text::white "Backup finished"
	vstacklet::shell::misc::nl
	# Long listing of files in $BACKUP_DIR to check file sizes.
	ls -lh "${BACKUP_DIR}"
	vstacklet::shell::misc::nl
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
	vstacklet::shell::text::white "Backup a database to a file."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -db, --databases=DATABASE                Database to backup."
	vstacklet::shell::text::white "  -db_user, --database_user=USER           Database user."
	vstacklet::shell::text::white "  -db_pwd, --database_password=PASSWORD    Database password."
	vstacklet::shell::text::white "  -h, --help                               Display this help and exit."
	vstacklet::shell::text::white "  -v, --version                            Output version information and exit."
	vstacklet::shell::misc::nl
}

################################################################################
# @description: Calls functions in required order.
################################################################################
vstacklet::environment::checkroot #(1)
vstacklet::environment::functions #(2)
vstacklet::backup::args "$@"      #(3)
vstacklet::backup::database       #(4)

################################################################################
# Example Cron Job
# Backup Databases Daily @ 12:30 AM
# 30 00 * * * root /opt/vstacklet/bin/backup/database-backup.sh -db="db1 db2 db3 db4" -db_user="dbuser" -db_pwd="dbpass"
################################################################################
