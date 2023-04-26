#!/bin/bash
################################################################################
# <START METADATA>
# @file_name: database-backup.sh
# @version: 3.1.1127
# @description: This script will create a backup of all databases.
# Please ensure you have read the documentation before continuing.
#
# @project_name: vstacklet
#
# @path: bin/backup/database-backup.sh
#
# @brief: Create a backup of specified databases
#
# This script will do the following:
# - Create necessary directories
# - Create a backup of all databases
# - Compress the backup file
# - Encrypt the backup file
#  - e.g. database_name-2016-01-01-00-00-00.sql.gz.enc
#  - encryption password is the same as the database password
#
# #### options:
# | Short | Long                       | Description
# | ----- | -------------------------- | ------------------------------------------
# |  -t | --temporary_directory             | Path to temporary directory
# |  -b | --backup_directory       | Path to backup directory
# |  -db | --database                 | Database name
# |  -dbuser | --database_user       | Database user
# |  -dbpass | --database_password    | Database password
# |  -h | --help                      | Display this help message
# |  -V | --version                   | Display version information
#
# #### examples:
# ```bash
#  /opt/vstacklet/bin/backup/database-backup.sh -t "/tmp/backup/databases/" -b "/backup/databases/" -db "database_name" -dbuser "database_user" -dbpass "database_password"
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
##################################################################################
# @name: vstacklet::environment::functions (2)
# @description: Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L59-L138)
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
# @description: Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L145-L150)
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
# @description: The main function of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L162-L363
#
# notes:
# - The retention variables are only used if the backup file compression is set to gzip.
# These values are currently not in use with this script. They are here for future use.
#
# @break
##################################################################################
vstacklet::backup::main() {
	##################################################################################
	# @name: vstacklet::backup::main::variables (a)
	# @description: The variables used in the backup script.
	##################################################################################
	# set the version of the backup script
	VERSION="$(grep -E '^# @version:' "/opt/vstacklet/bin/backup/vs-backup.sh" | awk '{print $3}')"
	# set the date stamp format
	DATE_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
	# set the backup directory
	BACKUP_DIR="${BACKUP_DIR:-/backup/databases/}"
	# set the temporary directory
	TMP_DIR="${TMP_DIR:-/tmp/vstacklet/backup/databases/}"
	# set the backup file name
	BACKUP_FILE="${BACKUP_FILE:-${DATE_STAMP}.sql}"
	# set the destination backup file path
	BACKUP_FILE_PATH="${BACKUP_DIR}${BACKUP_FILE}"
	# set the temporary backup file path
	BACKUP_FILE_PATH_TMP="${TMP_DIR}${BACKUP_FILE}"
	# set the database list
	DB_LIST=("${DB_LIST:-$(mysql -e "show databases;" | grep -Ev "(Database|information_schema|performance_schema)")}")
	#set the individual database
	DB="${DB:-}"
	# set the database user
	DB_USER="${DB_USER:-root}"
	# set the database password
	DB_PASS="${DB_PASS:-}"
	# set the database options
	DB_OPTIONS="${DB_OPTIONS:---opt}"
	# set the database dump options
	DB_DUMP_OPTIONS="${DB_DUMP_OPTIONS:---add-drop-table --lock-tables --databases}"
	# set the backup file compression
	COMPRESSION="${COMPRESSION:-gzip}"
	# set the backup file compression options
	COMPRESSION_OPTIONS="${COMPRESSION_OPTIONS:--9}"
	# set the backup file retention
	RETENTION="${RETENTION:-7}"
	# set the backup file retention options
	RETENTION_OPTIONS="${RETENTION_OPTIONS:--mtime +${RETENTION}}"
	# set the backup file retention path
	RETENTION_PATH="${RETENTION_PATH:-${BACKUP_DIR}}"
	# set the backup file retention path options
	RETENTION_PATH_OPTIONS="${RETENTION_PATH_OPTIONS:--type f -name '*.sql.gz'}"
	# parse the command line options
	while [ $# -gt 0 ]; do
		case "${1}" in
		-h | --help)
			vstacklet::backup::usage
			exit 0
			;;
		-ec | --example_cron)
			vstacklet::backup::example_cron
			exit 0
			;;
		-V | --version)
			vstacklet::backup::version
			exit 0
			;;
		-t | --temporary_directory)
			shift
			TMP_DIR="${1}"
			;;
		-b | --backup_directory)
			shift
			BACKUP_DIR="${1}"
			;;
		-db | --database)
			shift
			DB="${1}"
			;;
		-dbuser | --database_user)
			shift
			DB_USER="${1}"
			;;
		-dbpass | --database_password)
			shift
			DB_PASS="${1}"
			;;
		-dblist | --database_list)
			shift
			DB_LIST=("${1}")
			;;
		-dbop | --database_options)
			shift
			DB_OPTIONS="${1}"
			;;
		-dbdop | --database_dump_options)
			shift
			DB_DUMP_OPTIONS="${1}"
			;;
		-c | --compression)
			shift
			COMPRESSION="${1}"
			;;
		-co | --compression_options)
			shift
			COMPRESSION_OPTIONS="${1}"
			;;
		-r | --retention)
			shift
			RETENTION="${1}"
			;;
		-ro | --retention_options)
			shift
			RETENTION_OPTIONS="${1}"
			;;
		-rp | --retention_path)
			shift
			RETENTION_PATH="${1}"
			;;
		-rpo | --retention_path_options)
			shift
			RETENTION_PATH_OPTIONS="${1}"
			;;
		*)
			vstacklet::backup::usage
			exit 1
			;;
		esac
		shift
	done
	##################################################################################
	# @name: vstacklet::backup::main::checks (b)
	# @description: The checks used in the backup script.
	##################################################################################
	# check if the backup directory exists
	[[ ! -d "${BACKUP_DIR}" ]] && { vstacklet::shell::text::error "The backup directory ${BACKUP_DIR} does not exist." && exit 1; }
	# check if the temporary directory exists
	[[ ! -d "${TMP_DIR}" ]] && { vstacklet::shell::text::error "The temporary directory ${TMP_DIR} does not exist." && exit 1; }
	# check if the destination backup file exists
	[[ -f "${BACKUP_FILE_PATH}" ]] && { vstacklet::shell::text::error "The backup file ${BACKUP_FILE_PATH} already exists." && exit 1; }
	# check if the temporary backup file exists
	[[ -f "${BACKUP_FILE_PATH_TMP}" ]] && { vstacklet::shell::text::error "The backup file ${BACKUP_FILE_PATH_TMP} already exists." && exit 1; }
	# check if the database is empty
	[[ -z "${DB}" ]] && DB="${DB_LIST[*]}"
	# check if the database list is empty
	[[ -z "${DB_LIST[*]}" ]] && { vstacklet::shell::text::error "The database list is empty." && exit 1; }
	# check if either the database or the database list is empty
	[[ -z "${DB}" && -z "${DB_LIST[*]}" ]] && { vstacklet::shell::text::error "The database or the database list is empty." && exit 1; }
	# if database is not empty, check if it exists in the database list
	[[ -n "${DB}" && ! " ${DB_LIST[*]} " =~ ${DB} ]] && { vstacklet::shell::text::error "The database ${DB} does not exist in the database list." && exit 1; }
	# check if the database user is empty
	[[ -z "${DB_USER}" ]] && { vstacklet::shell::text::error "The database user is empty." && exit 1; }
	# check if the database password is empty
	[[ -z "${DB_PASS}" ]] && { vstacklet::shell::text::error "The database password is empty." && exit 1; }
	# check if the database options is empty
	[[ -z "${DB_OPTIONS}" ]] && { vstacklet::shell::text::error "The database options is empty." && exit 1; }
	# check if the database dump options is empty
	[[ -z "${DB_DUMP_OPTIONS}" ]] && { vstacklet::shell::text::error "The database dump options is empty." && exit 1; }
	# check if the compression is empty
	[[ -z "${COMPRESSION}" ]] && { vstacklet::shell::text::error "The compression is empty." && exit 1; }
	# check if the compression options is empty
	[[ -z "${COMPRESSION_OPTIONS}" ]] && { vstacklet::shell::text::error "The compression options is empty." && exit 1; }
	# check if the retention is empty
	[[ -z "${RETENTION}" ]] && { vstacklet::shell::text::error "The retention is empty." && exit 1; }
	# check if the retention options is empty
	[[ -z "${RETENTION_OPTIONS}" ]] && { vstacklet::shell::text::error "The retention options is empty." && exit 1; }
	# check if the retention path is empty
	[[ -z "${RETENTION_PATH}" ]] && { vstacklet::shell::text::error "The retention path is empty." && exit 1; }
	# check if the retention path options is empty
	[[ -z "${RETENTION_PATH_OPTIONS}" ]] && { vstacklet::shell::text::error "The retention path options is empty." && exit 1; }
	##################################################################################
	# @name: vstacklet::backup::main::directories (c)
	# @description: The directories used in the backup script.
	# @script-note: The directories are created if they don't exist.
	##################################################################################
	vstacklet::shell::text::white "Creating backup directories if they don't exist..."
	vstacklet::shell::misc::nl
	[[ ! -d "${TMP_DIR:-/tmp/vstacklet/backup/databases/}" ]] && mkdir -p "${TMP_DIR:-/tmp/vstacklet/backup/databases/}"
	[[ ! -d "${BACKUP_DIR:-/backup/databases/}" ]] && mkdir -p "${BACKUP_DIR:-/backup/databases/}"
	##################################################################################
	# @name: vstacklet::backup::main::message (d)
	# @description: The message used in the backup script to display the backup status.
	##################################################################################
	vstacklet::shell::text::white "Backing up ${DB_LIST[*]} database(s) to ${BACKUP_DIR}${DATE_STAMP}..."
	vstacklet::shell::misc::nl
	##################################################################################
	# @name: vstacklet::backup::main::backup (e)
	# @description: The backup loop function used in the backup script.
	##################################################################################
	for DB in "${DB_LIST[@]}"; do
		vstacklet::shell::text::white "Backing up ${DB}..."
		vstacklet::shell::misc::nl
		# Create the backup and compress it on the fly, then encrypt it.
		# shellcheck disable=SC2086
		mysqldump ${DB_OPTIONS} -u"${DB_USER}" -p"${DB_PASS}" ${DB} | ${COMPRESSION} ${COMPRESSION_OPTIONS} >"${TMP_DIR:-/tmp/vstacklet/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}" &&
			openssl enc -aes-256-cbc -salt -in "${TMP_DIR:-/tmp/vstacklet/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}" -out "${BACKUP_DIR:-/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}.enc" -k "${DB_PASS}" &&
			rm -f "${TMP_DIR:-/tmp/vstacklet/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}"
		# Check if the backup succeeded.
		#if [[ "${?}" -eq 0 ]]; then # use the below if statement instead of this one for proper success/failure reporting
		if [[ -f "${BACKUP_DIR:-/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}.enc" ]]; then
			vstacklet::shell::text::green "The backup of ${DB} was successful!"
			vstacklet::shell::misc::nl
			# Long listing of files in ${BACKUP_DIR} to check file sizes.
			ls -lh "${BACKUP_DIR:-/backup/databases/}"
			vstacklet::shell::misc::nl
		else
			vstacklet::shell::text::red "The backup of ${DB} failed!"
			vstacklet::shell::misc::nl
		fi
	done
}

##################################################################################
# @name: vstacklet::backup::usage
# @description: Display the usage of the backup script.
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
	vstacklet::shell::text::white "  -db, --database"
	vstacklet::shell::text::white "    Backup specified databases."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -dbuser, --database_user"
	vstacklet::shell::text::white "    Database user."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -dbpass, --database_password"
	vstacklet::shell::text::white "    Database password."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -t, --temporary_directory"
	vstacklet::shell::text::white "    Temporary backup directory. [optional]
	This directory is used to store the backup before it is encrypted.
	The default is /tmp/vstacklet/backup/databases/."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -b, --backup_directory"
	vstacklet::shell::text::white "    Backup directory. [optional]
	This directory is used to store the encrypted backup.
	The default is /backup/databases/."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -ec, --example_cron"
	vstacklet::shell::text::white "    Display an example cron job."
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "  -V, --version"
	vstacklet::shell::text::white "    Display the version of the backup script."
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
	vstacklet::shell::text::white "  # Backup Databases Daily @ 12:30 AM"
	vstacklet::shell::text::white "  30 00 * * * root /opt/vstacklet/bin/backup/database-backup.sh -db=\"database\" -db_user=\"dbuser\" -db_pwd=\"dbpass\""
	vstacklet::shell::misc::nl
}

##################################################################################
# @name: vstacklet::backup::version
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
vstacklet::environment::checkroot #(1)
vstacklet::environment::functions #(2)
vstacklet::backup::main "${@}"    #(3)
