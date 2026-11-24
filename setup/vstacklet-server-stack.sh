#!/bin/bash
##################################################################################
# <START METADATA>
# @file_name: vstacklet-server-stack.sh
# @version: 3.1.2239
# @description: Lightweight script to quickly install a LEMP stack with Nginx,
# Varnish, PHP 8.3/8.4/8.5 (PHP-FPM), OPCode Cache, IonCube Loader, MariaDB, Sendmail
# and more on a fresh Ubuntu 20.04/22.04 or Debian 11/12 server for
# website-based server applications.
#
# @project_name: vstacklet
#
# @path: setup/vstacklet-server-stack.sh
#
# @brief: This script is designed to be run on a fresh Ubuntu 20.04/22.04 or
# Debian 11/12 server. I have done my best to keep it tidy and with as much
# error checking as possible. Couple this with loads of comments and you should
# have a pretty good idea of what is going on. If you have any questions,
# comments, or suggestions, please feel free to open an issue on GitHub.
#
# vStacklet will install and configure the following:
# - NGinx 1.25.+ (mainline) | 1.18.+ (extras) (HTTP Server)
# - PHP 8.3, 8.4 (default) or 8.5 (FPM) with common extensions
# - MariaDB 10.11.+ (MySQL Database)
# - Varnish 7.4.x (HTTP Cache)
# - and more!
#
# Important Links:
# - :pencil: GITHUB REPO:   https://github.com/JMSDOnline/vstacklet
# - :bug: ISSUE TRACKER: https://github.com/JMSDOnline/vstacklet/issues
#
# :book: vStacklet Function Documentation:
# - [vstacklet::environment::init()](#vstackletenvironmentinit)
# - [vstacklet::args::process()](#vstackletargsprocess)
#   - [options](#options)
#   - [arguments](#arguments)
#   - [return codes](#return-codes)
#   - [examples](#examples)
# - [vstacklet::environment::store_flags_args()](#vstackletenvironmentstore_flags_args)
# - [vstacklet::environment::functions()](#vstackletenvironmentfunctions)
# - [vstacklet::log::check()](#vstackletlogcheck)
# - [vstacklet::apt::update()](#vstackletaptupdate)
# - [vstacklet::dependencies::install()](#vstackletdependenciesinstall)
#    - [return codes](#return-codes-1)
# - [vstacklet::intro()](#vstackletintro)
# - [vstacklet::dependencies::array()](#vstackletdependenciesarray)
# - [vstacklet::base::dependencies()](#vstackletbasedependencies)
#    - [return codes](#return-codes-4)
# - [vstacklet::source::dependencies()](#vstackletsourcedependencies)
#    - [return codes](#return-codes-5)
# - [vstacklet::bashrc::set()](#vstackletbashrcset)
# - [vstacklet::hostname::set()](#vstacklethostnameset)
#   - [options](#options-1)
#   - [arguments](#arguments-1)
#   - [examples](#examples-1)
# - [vstacklet::webroot::set()](#vstackletwebrootset)
#   - [options](#options-2)
#   - [arguments](#arguments-2)
#   - [examples](#examples-2)
# - [vstacklet::ssh::set()](#vstackletsshset)
#   - [options](#options-3)
#   - [arguments](#arguments-3)
#   - [return codes](#return-codes-6)
#   - [examples](#examples-3)
# - [vstacklet::ftp::set()](#vstackletftpset)
#   - [options](#options-4)
#   - [arguments](#arguments-4)
#   - [return codes](#return-codes-7)
#   - [examples](#examples-4)
# - [vstacklet::block::ssdp()](#vstackletblockssdp)
#   - [return codes](#return-codes-8)
# - [vstacklet::sources::update()](#vstackletsourcesupdate)
# - [vstacklet::gpg::keys()](#vstackletgpgkeys)
# - [vstacklet::locale::set()](#vstackletlocaleset)
#   - [return codes](#return-codes-9)
# - [vstacklet::php::install()](#vstackletphpinstall)
#   - [options](#options-5)
#   - [arguments](#arguments-5)
#   - [return codes](#return-codes-10)
#   - [examples](#examples-5)
#   - [options](#options-6)
#   - [return codes](#return-codes-11)
#   - [examples](#examples-6)
# - [vstacklet::nginx::install()](#vstackletnginxinstall)
#   - [options](#options-7)
#   - [return codes](#return-codes-12)
#   - [examples](#examples-7)
# - [vstacklet::varnish::install()](#vstackletvarnishinstall)
#   - [options](#options-8)
#   - [arguments](#arguments-6)
#   - [return codes](#return-codes-13)
#   - [examples](#examples-8)
# - [vstacklet::permissions::adjust()](#vstackletpermissionsadjust)
# - [vstacklet::ioncube::install()](#vstackletioncubeinstall)
#   - [options](#options-9)
#   - [return codes](#return-codes-14)
#   - [examples](#examples-9)
# - [vstacklet::mariadb::install()](#vstackletmariadbinstall)
#   - [options](#options-10)
#   - [arguments](#arguments-7)
#   - [return codes](#return-codes-15)
#   - [examples](#examples-10)
# - [vstacklet::mysql::install()](#vstackletmysqlinstall)
#   - [options](#options-11)
#   - [arguments](#arguments-8)
#   - [return codes](#return-codes-16)
#   - [examples](#examples-11)
# - [vstacklet::postgre::install()](#vstackletpostgreinstall)
#   - [options](#options-12)
#   - [arguments](#arguments-9)
#   - [return codes](#return-codes-17)
#   - [examples](#examples-12)
# - [vstacklet::redis::install()](#vstackletredisinstall)
#   - [options](#options-13)
#   - [arguments](#arguments-10)
#   - [return codes](#return-codes-18)
#   - [examples](#examples-13)
# - [vstacklet::phpmyadmin::install()](#vstackletphpmyadmininstall)
#   - [options](#options-14)
#   - [arguments](#arguments-11)
#   - [return codes](#return-codes-19)
#   - [examples](#examples-14)
#   - [options](#options-15)
#   - [arguments](#arguments-12)
#   - [return codes](#return-codes-20)
#   - [examples](#examples-15)
#   - [options](#options-16)
#   - [return codes](#return-codes-21)
#   - [examples](#examples-16)
# - [vstacklet::sendmail::install()](#vstackletsendmailinstall)
#   - [options](#options-17)
#   - [parameters](#parameters)
#   - [return codes](#return-codes-22)
#   - [examples](#examples-17)
# - [vstacklet::wordpress::install()](#vstackletwordpressinstall)
#   - [options](#options-18)
#   - [return codes](#return-codes-23)
#   - [examples](#examples-18)
# - [vstacklet::domain::ssl()](#vstackletdomainssl)
#   - [options](#options-19)
#   - [arguments](#arguments-12)
#   - [return codes](#return-codes-23)
#   - [examples](#examples-20)
# - [vstacklet::clean::complete()](#vstackletcleancomplete)
# - [vstacklet::message::complete()](#vstackletmessagecomplete)
# - [vstacklet::error::display()](#vstackleterrordisplay)
# - [vstacklet::rollback()](#vstackletrollback)
# - [vstacklet::update::check()](#vstackletupdatecheck)
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
# >>> vstacklet modules: the installer's functions live in setup/lib/ (one file per area); the loader trusts only root-owned, non-writable regular files whose SHA-256 matches this list, so a copy and a checkout from different versions never mix. Regenerate the list with developer_resources/pin-modules.sh in the same commit as any module change.
declare -gar VSTACKLET_MODULES=("core" "ui" "gate" "args" "environment" "apt" "system" "php" "nginx" "varnish" "database" "redis" "phpmyadmin" "wordpress" "tls" "ssh" "ftp" "mail" "rollback" "update")
declare -gA VSTACKLET_MODULE_SHA256=([core]="68f3e1532b77f4f9752d3e2701dd1661216c351583fc377d531d70d30d641bad" [ui]="13b062770986a3ef7e7aa964fcdd681bed8b12ec386707268d4aa7c75bd17800" [gate]="aceaa0123aa0ae38988e46399c79f85b89552918141258261761ae53e8f44da5" [args]="5eba423774da73676a03d47d17126b3bc9e2a135ee846019ffeadc8ac464e7d2" [environment]="a37cc3fd4152a8594065823713344ff5bc81e6eb24fcb37549f51656f874f4b2" [apt]="5659e024f3470423f1585a8906c1de04f70a996eb13b891a8b9677ddf9fbd97a" [system]="7a5523b3f18c0b236593be7cfbe013550eac6e20ab120d7674db24e3e9aac9d0" [php]="aee92eb42d89183408588e211f72370e24f2156efb4e959651fe8fe4a40198ca" [nginx]="0a557c7d136709cb9adbadc69ac69749ed45bfdfd8f9f35e85f7d58755ffe0b3" [varnish]="6c6eda90f02ffce04fac062bb3ce9906a576004a7428b6bcd06a6bb08058b364" [database]="fcee78c22bfd2f5c6b4c2b5caf140039301117efc324a97910ea77914fbbf590" [redis]="b8ab1217304731e1edb7de1b51b708f3988b0456ac586c590e70c0b025c7e427" [phpmyadmin]="625a57eb811e5de0da43069349b6c9770242a40b039b41a50d8f50662b0a565f" [wordpress]="781595d2990c2c0263905ada79fdf4a5fd72948e48ad28569cf1cb83bd68bbee" [tls]="d9d8e4de501654c57a59487190b83eeeb060bb48ea15d8d7003edd59b05ba2af" [ssh]="ea5e3383ce696db54b8b01c50cd1a731070131851767a69b8bdb74fa96767e27" [ftp]="a262099a9e080f27a8bd312b1920de38b497710a89f82578151c549270058b86" [mail]="4b0c1c4b22bbe432f6656f143325fa11cdf535e3e98704329fe8115e7b31ea99" [rollback]="f8e84027cd7be6341f5b5a628422de4d3bef85270ff33ae79da50eb173964b01" [update]="b2f41fcb57e3fe07c1eeee40c232afac614f2250650e09afef38635190b5f66a")
vstacklet::lib::load() {
	local lib="${vstacklet_base_path}/setup/lib" m f p sum
	for p in "${vstacklet_base_path}" "${vstacklet_base_path}/setup" "${lib}"; do
		[[ -d ${p} && ! -L ${p} && $(stat -c %u "${p}") == 0 && $(( 0$(stat -c %a "${p}") & 022 )) -eq 0 ]] || { printf 'vStacklet: %s must be a root-owned folder that only root can write; restore it with: git -C %s checkout -- setup/lib (or run the bootstrap again on a fresh server). Nothing was changed.\n' "${p}" "${vstacklet_base_path}" >&2; exit 1; }
	done
	for m in "${VSTACKLET_MODULES[@]}"; do
		f="${lib}/${m}.sh"
		[[ -f ${f} && ! -L ${f} && $(stat -c %u "${f}") == 0 && $(( 0$(stat -c %a "${f}") & 022 )) -eq 0 ]] || { printf 'vStacklet: module %s is missing, not a root-owned regular file, or writable by others; restore it with: git -C %s checkout -- setup/lib. Nothing was changed.\n' "${f}" "${vstacklet_base_path}" >&2; exit 1; }
		sum="$(sha256sum "${f}" | cut -d" " -f1)"
		[[ ${sum} == "${VSTACKLET_MODULE_SHA256[${m}]}" ]] || { printf 'vStacklet: module %s does not match this installer (a different version); install the matching copy with: install -m 0755 %s/setup/vstacklet-server-stack.sh /usr/local/bin/vstacklet. Nothing was changed.\n' "${f}" "${vstacklet_base_path}" >&2; exit 1; }
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
vstacklet::gate::system                       #(0) root, release, support dates, architecture: before any change
vstacklet::gate::interim "${codename}"        # until the 4.0 package sources are in: Debian 12 only
vstacklet::args::process "$@"                 #(3)
vstacklet::gate::install                      #(3.i) PHP support dates, fresh server only: before any change
vstacklet::environment::init                  #(1) the first change to the server
vstacklet::environment::store_flags_args "$@" # @script-note: store the flags and arguments to a file for rollback
vstacklet::log::check                         #(4)
vstacklet::apt::update                        #(5)
vstacklet::dependencies::install              #(6)
vstacklet::intro                              #(9)
vstacklet::ask::continue                      #(10)
vstacklet::dependencies::array                #(11)
vstacklet::base::dependencies                 #(12)
vstacklet::source::dependencies               #(13)
if [[ ${vstacklet_installed} -eq 0 ]]; then
	vstacklet::bashrc::set   #(14)
	vstacklet::hostname::set #(15)
	vstacklet::webroot::set  #(16)
	vstacklet::ssh::set      #(17)
	vstacklet::ftp::set      #(18)
	vstacklet::block::ssdp   #(19)
fi
vstacklet::sources::update                                                                            #(20)
vstacklet::gpg::keys                                                                                  #(21)
vstacklet::apt::update                                                                                #(5)
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
