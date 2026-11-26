#!/usr/bin/env bash
# vStacklet installer module: gate. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

# @script-note: interim, until the Ubuntu pairs are proven: the 4.0 package sources only add vendor deb822 files (apt.sh), and Debian 12 and 13 are open; Ubuntu stops here before any change
vstacklet::gate::interim() {
	[[ ${1-} == "bookworm" || ${1-} == "trixie" ]] || vstacklet::gate::refuse "vStacklet installs on Debian 12 and 13. Ubuntu 24.04 and 26.04 are not supported yet; vStacklet refuses them before making any change."
}

##################################################################################
# @name: vstacklet::gate::rollback_first
# @description: With --rollback, runs the rollback before the release gates, after the root check, so a server whose release has left support since its install can still roll back. --rollback runs on its own only. The release is worked out from /etc/os-release the way vstacklet::gate::system does (by ID and VERSION_ID through the release table); a server whose release changed since the install (an OS upgrade) is refused by name, because a rollback would put back the old release's packages, and the refusal lists, read-only, what vStacklet added so it can be removed by hand.
##################################################################################
vstacklet::gate::release_name() {
	local row r_id r_ver r_code r_rest
	for row in "${VSTACKLET_GATE_RELEASES[@]}"; do
		IFS='|' read -r r_id r_ver r_code r_rest <<<"${row}"
		[[ ${r_code} == "${2-}" ]] && { printf '%s %s (%s)' "${1-}" "${r_ver}" "${r_code}" && return 0; }
	done
	printf '%s %s' "${1-}" "${2-}"
}
vstacklet::gate::rollback_first() {
	local a found=0 key value os_id="" os_version="" os_codename="" row r_id r_ver r_code r_rest rec rec_code f
	for a in "$@"; do [[ ${a} == "--rollback" ]] && found=1; done
	((found)) || return 0
	[[ ${EUID} -eq 0 ]] || { printf 'vStacklet: run the installer as root.\n' >&2 && exit 1; }
	(($# == 1)) || { printf 'vStacklet: --rollback takes no other options; run vstacklet --rollback on its own. Nothing was changed.\n' >&2 && exit 1; }
	[[ -r /etc/os-release ]] || { printf 'vStacklet: cannot read /etc/os-release, so the release cannot be checked; nothing was changed.\n' >&2 && exit 1; }
	# @script-note: read three keys only, as vstacklet::gate::system does; the file is never sourced
	while IFS='=' read -r key value; do
		value="${value%\"}" && value="${value#\"}"
		case "${key}" in
		ID) os_id="${value}" ;;
		VERSION_ID) os_version="${value}" ;;
		VERSION_CODENAME) os_codename="${value}" ;;
		esac
	done </etc/os-release
	declare -g distro="" codename="" vstacklet_arch
	for row in "${VSTACKLET_GATE_RELEASES[@]}"; do
		IFS='|' read -r r_id r_ver r_code r_rest <<<"${row}"
		[[ ${os_id} == "${r_id}" && ${os_version} == "${r_ver}" ]] && codename="${r_code}" && break
	done
	[[ -n ${codename} ]] || codename="${os_codename}"
	[[ -n ${codename} ]] || { printf "vStacklet: cannot read this server's release codename, so the release cannot be checked against the install record; nothing was changed.\n" >&2 && exit 1; }
	[[ ${os_id} == "debian" ]] && distro="Debian"
	[[ ${os_id} == "ubuntu" ]] && distro="Ubuntu"
	vstacklet_arch="$(dpkg --print-architecture 2>/dev/null)"
	if [[ -f /root/vstacklet/baseline/complete ]]; then
		rec="$(sed -n '2p' /root/vstacklet/baseline/complete)"
		if [[ ${rec} == release=* && ${rec} != "release=${distro} ${codename}" ]]; then
			rec="${rec#release=}" && rec_code="${rec##* }"
			printf 'vStacklet: this server was recorded on %s and now runs %s; a rollback would put back the packages of the old release, so nothing was changed.\n' "$(vstacklet::gate::release_name "${rec% *}" "${rec_code}")" "$(vstacklet::gate::release_name "${distro}" "${codename}")" >&2
			printf 'vStacklet: what this install added, to remove by hand (nothing here was changed):\n' >&2
			for f in /etc/apt/sources.list.d/vstacklet-*.sources /etc/apt/keyrings/vstacklet-*.gpg /etc/apt/preferences.d/vstacklet-*; do
				[[ -e ${f} ]] && printf '  %s\n' "${f}" >&2
			done
			if [[ -f /root/vstacklet/baseline/paths.checked ]]; then
				while IFS= read -r f; do
					[[ -n ${f} && -e ${f} ]] || continue
					grep -qxF -- "${f}" /root/vstacklet/baseline/paths.present 2>/dev/null || printf '  %s\n' "${f}" >&2
				done </root/vstacklet/baseline/paths.checked
			fi
			for f in /root/vstacklet/setup_temp/vstacklet_install_command.*.txt; do
				[[ -f ${f} ]] && printf '  the install options: %s\n' "$(sed -n '1s/^Command://p' "${f}")" >&2
			done
			printf 'vStacklet: remove these by hand, or rebuild the server from a fresh image.\n' >&2
			exit 1
		fi
	fi
	declare -gi rollback=1
	vstacklet::rollback
	exit 1
}

##################################################################################
# @name: vstacklet::gate::install (3.i)
# @description: Runs after the options are read and before anything on the server is changed: the PHP version's support dates, ionCube on arm64, fresh servers only (no earlier vStacklet install, no apache2, no nginx site of its own, the web ports free), then the package check (vstacklet::apt::gate: the server's sources, the vendor keys, and a simulated install of the whole package list in a private apt state).
##################################################################################
vstacklet::gate::install() {
	local row r_ver r_active r_security today f p
	today="$(date +%F)"
	for row in "${VSTACKLET_GATE_PHP[@]}"; do
		IFS='|' read -r r_ver r_active r_security <<<"${row}"
		[[ ${php} == "${r_ver}" ]] || continue
		[[ ${today} > "${r_security}" ]] && vstacklet::gate::refuse "PHP ${php} reached the end of its security support on ${r_security}; choose a newer version with -php."
		[[ ${today} > "${r_active}" ]] && vstacklet::gate::notice "PHP ${php} receives security fixes only (until ${r_security}); a newer version gets bug fixes too."
	done
	# @script-note: on Debian 13 only the native PHP 8.4 has been through a full install and rollback; 8.3 and 8.5 come from packages.sury.org there and wait for their own run
	if [[ ${codename} == "trixie" && ${php} != "8.4" ]]; then
		local -a d13_other=()
		local v
		for v in "${SUPPORTED_PHP[@]-}"; do [[ -z ${v} || ${v} == "8.4" ]] || d13_other+=("${v}"); done
		((${#d13_other[@]})) || d13_other=("${php}")
		vstacklet::gate::refuse "PHP ${d13_other[*]} is not offered on Debian 13 yet; use -php 8.4."
	fi
	[[ -n ${ioncube} && ${vstacklet_arch} == "arm64" ]] && vstacklet::gate::refuse "ionCube Loader is not offered on arm64 by this installer; run without -ioncube."
	# @script-note: Docker's published ports bypass ufw and its rules conflict with direct nftables use, so the firewall vStacklet sets up could not be trusted
	if command -v docker >/dev/null 2>&1 || [[ $(dpkg-query -W -f='${Status}' docker-ce docker.io moby-engine 2>/dev/null) == *"ok installed"* ]]; then
		vstacklet::gate::refuse "Docker is installed on this server. Docker's published ports bypass the host firewall rules, so vStacklet installs on servers without Docker only."
	fi
	# @script-note: fresh servers only
	for f in "${VSTACKLET_MARKER}" "${VSTACKLET_STARTED}" /opt/vstacklet/config/system/.install_complete /var/log/vstacklet; do
		[[ -e ${f} ]] || continue
		if [[ -f /root/vstacklet/baseline/complete ]]; then
			vstacklet::gate::refuse "an earlier vStacklet install or install attempt was found (${f}). vStacklet 4 installs on fresh servers only: run vstacklet --rollback to undo it, or rebuild the server."
		fi
		vstacklet::gate::refuse "an earlier vStacklet install was found (${f}) with no install record to roll back. vStacklet 4 installs on fresh servers only: rebuild the server."
	done
	if [[ -n ${nginx} || -n ${varnish} ]]; then
		[[ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null) == *"ok installed"* ]] && vstacklet::gate::refuse "apache2 is installed. vStacklet installs nginx on fresh servers only."
		[[ -e /etc/nginx ]] && vstacklet::gate::refuse "nginx is already installed on this server (/etc/nginx). vStacklet installs nginx on fresh servers only."
		command -v ss >/dev/null 2>&1 || vstacklet::gate::refuse "the ss command (iproute2) is missing, so the web ports cannot be checked."
		for p in "${http_port:-80}" "${https_port:-443}" ${varnish:+"${varnish_port:-6081}"}; do
			[[ -n $(ss -Hltn "sport = :${p}" 2>/dev/null) ]] && vstacklet::gate::refuse "port ${p} is already in use on this server."
		done
	fi
	local t
	for t in gpg curl; do
		command -v "${t}" >/dev/null 2>&1 || vstacklet::gate::refuse "${t} is not installed on this server; install it with apt-get install ${t}, then run vstacklet again."
	done
	vstacklet::apt::gate
	return 0
}
