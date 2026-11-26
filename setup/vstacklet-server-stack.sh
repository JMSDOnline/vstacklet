#!/bin/bash
##################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 4.0.0
# @description: Installs and configures a LEMP stack and WordPress on a fresh Debian 12 or Debian 13 server, in one run.
#
# @project_name: vstacklet
#
# @path: setup/vstacklet-server-stack.sh
#
# @brief: vStacklet 4.0 installs and configures a LEMP stack and WordPress on a fresh Debian 12 (bookworm) or Debian 13 (trixie) server, run as root. Ubuntu 24.04 and 26.04 are not supported yet; the installer refuses them, and every option it does not offer, before making any change. The bootstrap (setup/vstacklet.sh) installs this script as the `vstacklet` command; its functions live in setup/lib/, one file per area, and the loader accepts only the files whose SHA-256 it pins.
#
# vStacklet 4.0 installs and configures the following:
# - Nginx from nginx.org, with HTTP/2 and IPv6, and a self-signed certificate on 443 to start with
# - PHP 8.3, 8.4 (default) or 8.5 (FPM) on Debian 12; PHP 8.4 on Debian 13; with OPcache, and the Memcached, igbinary and Imagick PHP extensions where the release offers them
# - MariaDB from the release's own archive (10.11 on Debian 12, 11.8 on Debian 13), with a database and user staged for WordPress
# - WordPress, staged in your web root
#
# Options offered in vStacklet 4.0:
#
# | Short | Long | Description |
# | ----- | ---- | ----------- |
# | -h | --help | show the help |
# | -V | --version | show the version |
# | -hn | --hostname | hostname to use for the server |
# | -ssh | --ssh_port | port to use for the SSH server |
# | -http | --http_port | port to use for the HTTP server |
# | -https | --https_port | port to use for the HTTPS server |
# | -nginx | --nginx | install Nginx |
# | -php | --php | PHP version to install (8.3, 8.4 or 8.5 on Debian 12; 8.4 on Debian 13; default 8.4) |
# | -mariadb | --mariadb | install MariaDB |
# | -mariadbP | --mariadb_port | port to use for the MariaDB server |
# | -mariadbU | --mariadb_user | the MariaDB admin account to create (do not use root) |
# | -mariadbPw | --mariadb_password | password for that account |
# | -wr | --web_root | web root, a folder under /var/www/ |
# | -wp | --wordpress | install WordPress (needs -nginx and -mariadb) |
# | -r | --reboot | reboot the server after the install |
# | | --rollback | undo an install: restore the state recorded before its first change; run it on its own |
# | | --refresh-keys | re-fetch the vendor repository keys, accepted only if their pinned fingerprints still match |
# | | --check_update | check the installed branch for a newer 4.x release |
#
# Example:
#
# ```bash
# vstacklet -hn 'server.example.com' -nginx -php '8.4' -mariadb -mariadbU 'db_username' -mariadbPw 'db_password' -wr '/var/www/html/vsapp' -wp
# ```
#
# Not offered in vStacklet 4.0 (refused before any change): -e, --email; -d, --domain; --dns, --dns_provider; -ftp; -ioncube; -mysql, -mysqlU, -mysqlPw, -mysqlP; -postgre and its options; -redis and its options; -pma; -sendmail, -sendmailP; -varnish, -varnishP; -csf, -csfCf; -hhvm.
#
# Rollback: `vstacklet --rollback` lists what it will do and asks before changing anything. It also works after a release leaves regular support, while its packages are still on the Debian mirrors; once a release has moved to archive.debian.org, it cannot restore the release's package sources, and the server must be rebuilt from a fresh image. A server upgraded to a new release since its install cannot be rolled back.
#
# vStacklet 4.0 is tested on Debian 12 and Debian 13 amd64 lab servers; arm64 installs but has not had the same test run yet.
#
# Important Links:
# - :pencil: GITHUB REPO:   https://github.com/JMSDOnline/vstacklet
# - :bug: ISSUE TRACKER: https://github.com/JMSDOnline/vstacklet/issues
#
# @save_tasks:
#  automated_versioning: false
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
##################################################################################
# shellcheck disable=1091,2034,2068,2119,2154,2249,2312
# @script-note: the one default PHP version and the tested range; the version checks and every template use these
# @script-note: where the bootstrap clones vStacklet; fixed, so -V, the rollback and the update check never depend on install order
declare -gr vstacklet_base_path="/opt/vstacklet"
declare -gr DEFAULT_PHP="8.4"
declare -gar SUPPORTED_PHP=("8.3" "8.4" "8.5")
# @script-note: written at the end of a completed 4.x install; its presence means the server is not fresh
declare -gr VSTACKLET_MARKER="/etc/vstacklet/installed"
# @script-note: written at the first change of an install; only a complete rollback removes it
declare -gr VSTACKLET_STARTED="/etc/vstacklet/started"
# >>> vstacklet gate: this block is kept identical in setup/vstacklet.sh and setup/vstacklet-server-stack.sh
##################################################################################
# @name: vstacklet::gate (0)
# @description: Runs before anything on the server is changed: root, the release and its support dates, the architecture.
#
# Support dates come from the vendors' own pages, read 2026-11-23:
# - Debian: https://www.debian.org/releases/bookworm/ , https://www.debian.org/releases/trixie/ , https://wiki.debian.org/LTS
# - Ubuntu: https://ubuntu.com/about/release-cycle (states a month only; the gate uses the last day of that month)
# - PHP:    https://www.php.net/supported-versions.php
#
# A release counts as supported until its free security support ends: for Debian the end of Debian LTS (a Debian project), for Ubuntu the end of standard support. Paid extended support (Freexian ELTS for Debian, Ubuntu ESM) is not counted. A Debian release past its regular security support but inside Debian LTS installs with a notice.
#
# Row: id|version|codename|regular security end|free security end|end as the vendor states it|who supports it until then
# @break
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
			vstacklet::gate::refuse "${os_id} ${os_version} reached the end of its free security support (${r_who}, ${r_shown}). Rebuild the server on a supported release: Debian 12 or 13."
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
	vstacklet::gate::refuse "${os_id:-unknown} ${os_version:-unknown} is not supported. Supported: Debian 12 and 13 (Ubuntu 24.04 and 26.04 not yet). For Debian 11 or Ubuntu 20.04 and 22.04, the last 3.x release is the tag v3.1.2239, which is no longer maintained."
}
# <<< vstacklet gate
# >>> vstacklet modules: the installer's functions live in setup/lib/ (one file per area); the loader trusts only root-owned, non-writable regular files whose SHA-256 matches this list, so a copy and a checkout from different versions never mix. Regenerate the list with developer_resources/pin-modules.sh in the same commit as any module change.
declare -gar VSTACKLET_MODULES=("core" "ui" "gate" "args" "environment" "apt" "system" "php" "nginx" "varnish" "database" "redis" "phpmyadmin" "wordpress" "tls" "ssh" "ftp" "mail" "rollback" "update")
declare -gA VSTACKLET_MODULE_SHA256=([core]="719601e02657e8804271b9416ae72024163a1079c2098388d11389ef288af47b" [ui]="2b4edf75ff4eb85a67ab1d6957240951b44aa8aaac28809807661f5c3bbdfd46" [gate]="079dacac045e220838a363b7c100f588333fec50c7ec5f157efb6c8005468dd8" [args]="7940457c361ef77506a4c8f46213d855d6325169c7da404ac68c949be42a1ce3" [environment]="a37cc3fd4152a8594065823713344ff5bc81e6eb24fcb37549f51656f874f4b2" [apt]="8b1045433f48343e9d607ba645e99bebc76ecf651d3dc94b7dc0d52e6a0adab9" [system]="890db15d4008381cab8c956b186ceef26066b824dd1947e3049064faf1af8ea0" [php]="e13a9c0cd7140f539a431b5c4fff7123a6ea9469d26453efdfce36bc8fd66051" [nginx]="a0069ab174bca5db19a27ce0d85bb0ce830e0b1136f2bb61b8543291ac3a9a18" [varnish]="1104d569974ccfb80a54fe1c86d704dfdcb703f1bbaff27d99b42c888e09eea3" [database]="3e41baad3cf3c595833fb67df3efbe4585ec88d8bf1148fb173018ce14efb395" [redis]="b8ab1217304731e1edb7de1b51b708f3988b0456ac586c590e70c0b025c7e427" [phpmyadmin]="625a57eb811e5de0da43069349b6c9770242a40b039b41a50d8f50662b0a565f" [wordpress]="73df6bacec982493cd93d4289faf7ec32e7331f69d24723400c7e76f263c3920" [tls]="d9d8e4de501654c57a59487190b83eeeb060bb48ea15d8d7003edd59b05ba2af" [ssh]="ea5e3383ce696db54b8b01c50cd1a731070131851767a69b8bdb74fa96767e27" [ftp]="a262099a9e080f27a8bd312b1920de38b497710a89f82578151c549270058b86" [mail]="4b0c1c4b22bbe432f6656f143325fa11cdf535e3e98704329fe8115e7b31ea99" [rollback]="c95147131a8a5d6107c17cbdca8ca68106f276ddbfd2339f47c210ec78d6566f" [update]="b2f41fcb57e3fe07c1eeee40c232afac614f2250650e09afef38635190b5f66a")
vstacklet::lib::load() {
	local lib="${vstacklet_base_path}/setup/lib" m f p sum
	[[ -d ${vstacklet_base_path} ]] || { printf 'vStacklet: %s is missing; restore it with: git clone --branch <branch> https://github.com/JMSDOnline/vstacklet.git %s (the branch you installed from, main if unsure), then run vstacklet again. Nothing was changed.\n' "${vstacklet_base_path}" "${vstacklet_base_path}" >&2; exit 1; }
	for p in "${vstacklet_base_path}" "${vstacklet_base_path}/setup" "${lib}"; do
		[[ -L ${p} ]] && { printf 'vStacklet: %s is a symbolic link; vStacklet runs only from a real folder at %s. Nothing was changed.\n' "${p}" "${vstacklet_base_path}" >&2; exit 1; }
		[[ -d ${p} ]] || { printf 'vStacklet: %s is missing; restore it with: git -C %s checkout -- setup. Nothing was changed.\n' "${p}" "${vstacklet_base_path}" >&2; exit 1; }
		[[ $(stat -c %u "${p}") == 0 && $(( 0$(stat -c %a "${p}") & 022 )) -eq 0 ]] || { printf 'vStacklet: %s must be owned by root and writable only by root; fix it with: chown root:root %s && chmod go-w %s. Nothing was changed.\n' "${p}" "${p}" "${p}" >&2; exit 1; }
	done
	for m in "${VSTACKLET_MODULES[@]}"; do
		f="${lib}/${m}.sh"
		[[ -L ${f} ]] && { printf 'vStacklet: module %s is a symbolic link; restore it with: rm %s && git -C %s checkout -- setup/lib. Nothing was changed.\n' "${f}" "${f}" "${vstacklet_base_path}" >&2; exit 1; }
		[[ -f ${f} ]] || { printf 'vStacklet: module %s is missing; restore it with: git -C %s checkout -- setup/lib. Nothing was changed.\n' "${f}" "${vstacklet_base_path}" >&2; exit 1; }
		[[ $(stat -c %u "${f}") == 0 && $(( 0$(stat -c %a "${f}") & 022 )) -eq 0 ]] || { printf 'vStacklet: module %s must be owned by root and writable only by root; fix it with: chown root:root %s && chmod go-w %s. Nothing was changed.\n' "${f}" "${f}" "${f}" >&2; exit 1; }
		sum="$(sha256sum "${f}" | cut -d" " -f1)"
		[[ ${sum} == "${VSTACKLET_MODULE_SHA256[${m}]}" ]] || { printf 'vStacklet: module %s does not match this installer (a different version); restore it with: git -C %s checkout -- setup/lib, or install the matching copy with: install -m 0755 %s/setup/vstacklet-server-stack.sh /usr/local/bin/vstacklet. Nothing was changed.\n' "${f}" "${vstacklet_base_path}" "${vstacklet_base_path}" >&2; exit 1; }
		# shellcheck source=/dev/null
		source "${f}"
	done
}
vstacklet::lib::load
# <<< vstacklet modules

trap '[[ -n ${pg_pid} ]] && kill -9 "${pg_pid}" 2>/dev/null; vstacklet::error::display' SIGINT SIGTERM SIGHUP

################################################################################
# @description: Calls functions in required order.
################################################################################
# the following functions are called in the order they are listed and
# are used for post-installation setup.
################################################################################
vstacklet::environment::functions             #(2)
vstacklet::args::info "$@"                    # -h and -V only print: before the gate, no root or supported release needed
vstacklet::gate::rollback_first "$@"          # --rollback: root, then the rollback, before the release gates, so a server whose release left support can still roll back
vstacklet::gate::system                       #(0) root, release, support dates, architecture: before any change
vstacklet::gate::interim "${codename}"        # until the Ubuntu pairs are proven: Debian 12 and 13
vstacklet::args::process "$@"                 #(3)
vstacklet::gate::install                      #(3.i) PHP support dates, fresh server only: before any change
vstacklet::intro                              #(9) before any change, so taking the offered exit leaves nothing to roll back
vstacklet::ask::continue                      #(10)
vstacklet::environment::init                  #(1) the first change to the server
vstacklet::environment::store_flags_args "$@" # @script-note: store the flags and arguments to a file for rollback
vstacklet::log::check                         #(4)
vstacklet::packages::install                  #(5) one apt call for the whole list the gate checked
if [[ ${vstacklet_installed} -eq 0 ]]; then
	vstacklet::bashrc::set   #(14)
	vstacklet::hostname::set #(15)
	vstacklet::webroot::set  #(16)
	vstacklet::ssh::set      #(17)
	vstacklet::ftp::set      #(18)
	vstacklet::block::ssdp   #(19)
fi
vstacklet::locale::set                                                                                #(22)
vstacklet::php::install                                                                               #(23)
vstacklet::nginx::install                                                                             #(25)
vstacklet::varnish::install                                                                           #(26)
vstacklet::permissions::adjust                                                                        #(27)
vstacklet::ioncube::install                                                                           #(28)
vstacklet::mariadb::install                                                                           #(29)
vstacklet::mysql::install                                                                             #(30)
vstacklet::postgre::install                                                                           #(31)
vstacklet::redis::install                                                                             #(32)
vstacklet::phpmyadmin::install                                                                        #(33)
[[ -n ${sendmail} ]] && vstacklet::sendmail::install                                                  #(35)
vstacklet::wordpress::install                                                                         #(36)
vstacklet::domain::ssl                                                                                #(37)
vstacklet::clean::complete                                                                            #(38)
vstacklet::marker::write                                                                              #(38.1)
[[ ${vstacklet_installed} -eq 0 ]] && vstacklet::message::complete && rm -rf ~/vstacklet.sh && exit 0 #(39)
################################################################################
# @description: End of script.
################################################################################
