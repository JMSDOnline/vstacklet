#!/usr/bin/env bash
# vStacklet installer module: core. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# The following three functions are used for the progress spinner.
##################################################################################
# create the spinner
vs::stat::progress() {
	spinner="/|\\-/|\\-"
	while :; do
		for i in $(seq 0 7); do
			echo -n "${spinner:$i:1}"
			echo -en "\010"
			sleep 1
		done
	done
}

# start the spinner and save the function's PID
vs::stat::progress::start() {
	declare -g pg_pid
	vs::stat::progress &
	pg_pid=$!
	# @script-note: only on exit; INT, TERM and HUP stay with the installer's own trap, which also stops the spinner
	trap 'kill -9 ${pg_pid} 2>/dev/null' EXIT
}

# stop the spinner and remove the function's PID
vs::stat::progress::stop() {
	vstacklet::shell::icon::check::green "done"
	# shellcheck disable=SC2086
	kill -9 ${pg_pid} >/dev/null 2>&1
	unset pg_pid
}

##################################################################################
# @name: vstacklet::log::check (4)
# @description: Check if the log file exists and create it if it doesn't. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L741-L761)
#
# ![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)
#
# notes:
# - one log per run: /var/log/vstacklet/vstacklet.<date-time>.<pid>.log (mode 600); earlier logs are kept
# - vstacklet::log takes a command as separate words ("$@"), never a string, and stops the install when it fails;
#   vstacklet::log::try logs and returns the status for the few calls whose failure is tolerated today
# @noargs
# @nooptions
# @break
##################################################################################
vstacklet::log::check() {
	vstacklet::shell::text::white "checking log file ... "
	declare -g log_file vslog
	# @script-note: one log per run, kept after the run (an earlier run's log is never removed), readable by root only
	install -d -m 0700 /var/log/vstacklet || { vstacklet::shell::text::error "cannot create /var/log/vstacklet"; exit 1; }
	log_file="/var/log/vstacklet/vstacklet.$(date +%Y%m%d-%H%M%S).$$.log"
	(umask 077 && : >"${log_file}") || { vstacklet::shell::text::error "cannot create the log file ${log_file}"; exit 1; }
	vslog="${log_file}"
	vstacklet::shell::text::yellow "output is being sent to ${log_file}"
	# @script-note: run one command given as separate words, never as a string, so arguments are not split or
	# globbed again and shell operators are never passed in. Returns the command's own exit status.
	# usage: vstacklet::log apt-get -y install "${package}"
	# A failed command stops the install (fail closed): the error names the command and its exit status.
	vstacklet::log() {
		local rc
		vstacklet::log::try "$@"
		rc=$?
		if [[ ${rc} -ne 0 ]]; then
			declare -g vstacklet_failed_step="$* (exit ${rc})"
			vstacklet::error::display log
		fi
		return 0
	}
	# The same, for the few calls whose failure is tolerated today; it logs and returns the status, never stops.
	# Each one goes when its part of the installer is rewritten.
	vstacklet::log::try() {
		[[ $# -gt 0 ]] || return 2
		if [[ -z ${verbosity} ]]; then
			"$@" >>"${log_file}" 2>&1
		else
			"$@" 2>&1 | tee -a "${log_file}"
			return "${PIPESTATUS[0]}"
		fi
	}
}

################################################################################
# @name: vstacklet::error::display - vStacklet Error Messages
# @description: Displays error messages for vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3478-L3648)
#
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::error::display() {
	declare error
	# @script-note: stop the progress spinner first, so it does not draw over the error
	[[ -n ${pg_pid} ]] && kill -9 "${pg_pid}" 2>/dev/null
	if [[ -n $1 ]]; then
		case $1 in
		# vstacklet::environment::checkroot (7)
		1) error="you must be root to run this script." ;;
		# vstacklet::environment::checkdistro (8)
		2) error="this script only supports Ubuntu 20.04/22.04 and Debian 11/12." ;;
		# vstacklet::dependencies::install (6)
		3) error="failed to install script dependencies." ;;
		# vstacklet::base::dependencies (12)
		4) error="failed to install base dependencies." ;;
		# vstacklet::source::dependencies (13)
		5) error="failed to install source dependencies." ;;
		# vstacklet::hostname::set (15)
		6) error="failed to set hostname." ;;
		# vstacklet::ssh::set (17)
		7) error="failed to set SSH port." ;;
		8) error="failed to restart SSH daemon service." ;;
		# vstacklet::ftp::set (18)
		9) error="failed to set FTP port." ;;
		10) error="failed to restart FTP daemon service." ;;
		# vstacklet::block::ssdp (19)
		11) error="failed to block SSDP port." ;;
		12) error="failed to save iptables rules." ;;
		# vstacklet::locale::set (22)
		13) error="failed to set locale." ;;
		# vstacklet::php::install (23)
		15) error="failed to install PHP dependencies." ;;
		# vstacklet::nginx::install (25)
		20) error="failed to install NGINX dependencies." ;;
		21) error="failed to edit NGINX configuration file." ;;
		22) error="failed to enable NGINX configuration." ;;
		23) error="failed to generate dhparam file." ;;
		24) error="failed to generate self-signed certificate." ;;
		25) error="failed to create the web root's public folder." ;;
		# vstacklet::varnish::install (26)
		26) error="failed to install Varnish dependencies." ;;
		27) error="could not switch to /etc/varnish directory." ;;
		28) error="failed to edit the Varnish default configuration file." ;;
		29) error="failed to reload the systemd daemon." ;;
		30) error="failed to switch to ~/" ;;
		# vstacklet::ioncube::install (28)
		31) error="failed to switch to /tmp directory." ;;
		32) error="failed to download ionCube Loader." ;;
		33) error="failed to extract ionCube Loader." ;;
		34) error="failed to switch to /tmp/ioncube directory." ;;
		35) error="failed to copy ionCube loader to /usr/lib/php/ directory." ;;
		# vstacklet::mariadb::install (29)
		36) error="failed to install MariaDB dependencies." ;;
		37) error="failed to initialize MariaDB secure installation." ;;
		38) error="failed to set MariaDB client and server configuration." ;;
		39) error="failed to set MariaDB .my.cnf configuration." ;;
		40) error="failed to create MariaDB user." ;;
		41) error="failed to create MariaDB user privileges." ;;
		42) error="failed to flush MariaDB privileges." ;;
		# vstacklet::mysql::install (30)
		43) error="failed to download MySQL deb package." ;;
		44) error="failed to install MySQL deb package." ;;
		45) error="failed to install MySQL dependencies." ;;
		46) error="failed to set MySQL client and server configuration." ;;
		47) error="failed to set MySQL .my.cnf file." ;;
		48) error="failed to create MySQL user." ;;
		49) error="failed to grant MySQL user privileges." ;;
		50) error="failed to flush MySQL privileges." ;;
		# vstacklet::postgresql::install (31)
		51) error="failed to install PostgreSQL dependencies." ;;
		52) error="could not switch to /etc/postgresql/${postgre_version}/main directory." ;;
		53) error="failed to set PostgreSQL password." ;;
		54) error="failed to create PostgreSQL user." ;;
		55) error="failed to grant PostgreSQL user privileges." ;;
		56) error="failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file." ;;
		57) error="failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file." ;;
		# vstacklet::redis::install (32)
		58) error="failed to install Redis dependencies." ;;
		59) error="failed to backup the Redis configuration file." ;;
		60) error="failed to import the Redis configuration file." ;;
		61) error="failed to modify the Redis configuration file." ;;
		62) error="failed to restart Redis service." ;;
		63) error="failed to set the Redis password." ;;
		# vstacklet::phpmyadmin::install (33)
		64) error="failed to install phpMyAdmin dependencies." ;;
		65) error="failed to switch to /usr/share directory." ;;
		66) error="failed to download phpMyAdmin." ;;
		67) error="failed to extract phpMyAdmin." ;;
		68) error="failed to move phpMyAdmin to /usr/share directory." ;;
		69) error="failed to remove phpMyAdmin .tar.gz file." ;;
		70) error="failed to set ownership of phpMyAdmin directory." ;;
		71) error="failed to set permissions of phpMyAdmin directory." ;;
		72) error="failed to create /usr/share/phpmyadmin/tmp directory." ;;
		73) error="failed to set symlink of ./phpmyadmin to ${web_root}/public/phpmyadmin." ;;
		74) error="failed to create htpasswd file." ;;
		75) error="failed to create phpMyAdmin configuration file." ;;
		# vstacklet::sendmail::install (35)
		88) error="failed to install sendmail dependencies." ;;
		89) error="failed to edit aliases file." ;;
		90) error="failed to edit sendmail.cf file." ;;
		91) error="failed to edit main.cf file." ;;
		92) error="failed to edit master.cf file." ;;
		93) error="failed to create sasl_passwd file." ;;
		94) error="postmap failed." ;;
		95) error="failed to source new aliases." ;;
		# vstacklet::wordpress::install (36)
		96) error="failed to download WordPress." ;;
		97) error="failed to extract WordPress." ;;
		98) error="failed to move WordPress to ${web_root:-/var/www/html/vsapp}/public directory." ;;
		99) error="failed to create WordPress upload directory." ;;
		100) error="failed to create WordPress configuration file." ;;
		101) error="failed to modify WordPress configuration file." ;;
		102) error="failed to create WordPress database." ;;
		103) error="failed to create WordPress database user." ;;
		104) error="failed to grant WordPress database user privileges." ;;
		105) error="failed to flush WordPress database privileges." ;;
		106) error="failed to remove WordPress installation files." ;;
		107) error="failed to install WordPress core." ;;
		108) error="failed to install WordPress plugins [varnish-http-purge]." ;;
		# vstacklet::domain::ssl (37)
		109) error="failed to change directory to /root." ;;
		110) error="failed to create directory ${web_root:-/var/www/html/vsapp}/.well-known/acme-challenge." ;;
		111) error="failed to clone acme.sh." ;;
		112) error="failed to switch to /root/acme.sh directory." ;;
		113) error="failed to install acme.sh." ;;
		114) error="failed to reload nginx." ;;
		115) error="failed to register the account with Let's Encrypt." ;;
		116) error="failed to set the default CA to Let's Encrypt." ;;
		117) error="failed to issue the certificate." ;;
		118) error="failed to install the certificate." ;;
		119) error="failed to edit /etc/nginx/sites-available/${domain}.conf." ;;
		# vstacklet::marker::write (38.1)
		120) error="failed to write the install marker." ;;
		log) error="a step failed: ${vstacklet_failed_step:-unknown}" ;;
		apt) error="apt-get update failed: a package repository could not be fetched or verified (the failing repository is named in the log)." ;;
		*) error="Unknown error" ;;
		esac
		vstacklet::shell::text::error "${error}"
	else
		vstacklet::shell::text::warning "installer has been interrupted"
	fi
	if [[ "${rollback}" != "1" ]]; then
		# @script-note: fail closed (4.0): a failed step stops the install; nothing is undone, the server is rebuilt
		vstacklet::shell::misc::nl
		if [[ -n ${vstacklet_changes_started} ]]; then
			vstacklet::shell::text::error "the install has stopped and this server is now partly configured. To bring it back to the state recorded when the installer first changed it (the bootstrap's own tools stay), run:"
			vstacklet::shell::text::white "vstacklet --rollback"
			vstacklet::shell::text::error "If the rollback cannot bring the server back to a clean state, rebuild it from a fresh image."
		else
			vstacklet::shell::text::error "the install has stopped before any change was made to this server."
		fi
		vstacklet::shell::text::white " - log of this run: ${vslog:-none (stopped before the log was created)}"
		vstacklet::shell::text::white " - to report a problem: https://github.com/JMSDOnline/vstacklet/issues (include the error above, the log, the vStacklet version ${vstacklet_version:-unknown} and the server's OS and version)"
		vstacklet::shell::misc::nl
	else
		if [[ -n ${rollback_started} ]]; then
			vstacklet::rollback::apt_resume
			vstacklet::shell::text::error "The rollback stopped part-way. Run vstacklet --rollback again to finish it."
		else
			vstacklet::shell::text::error "The rollback process has been cancelled; nothing was changed."
		fi
		vstacklet::shell::misc::nl
	fi
	exit 1
}
