#!/usr/bin/env bash
# vStacklet installer module: gate. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

# @script-note: interim, until the 4.0 package sources are written: on Debian 13 and Ubuntu the 3.x sources code would rewrite the release's own sources, so this build stops there before any change
vstacklet::gate::interim() {
	[[ ${1-} == "bookworm" ]] || vstacklet::gate::refuse "this development build of vStacklet 4.0 installs on Debian 12 only for now; Debian 13 and Ubuntu 24.04 and 26.04 follow before the 4.0 release."
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
	[[ -n ${ioncube} && ${vstacklet_arch} == "arm64" ]] && vstacklet::gate::refuse "ionCube Loader is not offered on arm64 by this installer; run without -ioncube."
	# @script-note: Docker's published ports bypass ufw and its rules conflict with direct nftables use, so the firewall vStacklet sets up could not be trusted
	if command -v docker >/dev/null 2>&1 || [[ $(dpkg-query -W -f='${Status}' docker-ce docker.io moby-engine 2>/dev/null) == *"ok installed"* ]]; then
		vstacklet::gate::refuse "Docker is installed on this server. vStacklet manages the firewall with ufw, and Docker's published ports bypass ufw, so vStacklet installs on servers without Docker only."
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
