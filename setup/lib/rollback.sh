#!/usr/bin/env bash
# vStacklet installer module: rollback. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

################################################################################
# @name: vstacklet::rollback::baseline
# @description: Records the server's state before the installer's first change, so vstacklet --rollback can bring it back: every installed or half-installed package by its full name, the manual marks, the apt sources and keys, the enabled units, root's crontab, five system files, and which installer paths existed. Each install that passes the fresh-server gate records afresh. The record is built in a temporary folder and ends with a manifest (machine id, release, architecture, a hash of every file) that the rollback checks before it changes anything. Stored in /root/vstacklet/baseline (mode 700).
# @return_code: 1 - the record could not be written; nothing was changed.
################################################################################
vstacklet::rollback::paths() {
	printf '%s\n' /etc/vstacklet /etc/nginx /etc/nginx-pre-vstacklet /etc/systemd/system/nginx.service.d /etc/php /etc/mysql /var/lib/mysql /etc/varnish /etc/redis /var/lib/redis /etc/postgresql /var/lib/postgresql /etc/phpmyadmin /usr/share/phpmyadmin /etc/iptables /etc/vsftpd.conf /etc/vsftpd.chroot_list /etc/vsftpd /etc/mail /root/.my.cnf /root/.acme.sh /root/acme.sh /usr/local/bin/wp /var/www /usr/share/keyrings/nginx-archive-keyring.gpg /usr/share/keyrings/redis-archive-keyring.gpg
}

vstacklet::rollback::files() {
	printf '%s\n' /etc/hosts /etc/hostname /etc/ssh/sshd_config /root/.bashrc /root/.profile
}

# @script-note: the apt sources the record keeps and the rollback restores; one list, so the record, the plan and the restore cannot drift
vstacklet::rollback::apt_dirs() {
	printf '%s\n' sources.list sources.list.d keyrings trusted.gpg.d preferences.d
}

# @script-note: installed packages with their versions, one "name version" per line (a separate file, so the name comparisons stay as they are)
vstacklet::rollback::versions() {
	dpkg-query -W -f='${db:Status-Status} ${binary:Package} ${Version}\n' | awk '$1 != "not-installed" && $1 != "config-files" {print $2, $3}' | LC_ALL=C sort -u
}

# @script-note: true when the current sources offer VERSION of NAME (the installed copy alone, /var/lib/dpkg/status, does not count)
vstacklet::rollback::offered() {
	LC_ALL=C apt-cache policy "$1" 2>/dev/null | awk -v v="$2" '/^ (\*\*\*|   ) [^ ]+ -?[0-9]+$/ {cur=($1=="***")?$2:$1; next} /^ +-?[0-9]+ / && cur == v && $2 != "/var/lib/dpkg/status" {f=1} END {exit !f}'
}

vstacklet::rollback::installed() {
	dpkg-query -W -f='${db:Status-Status} ${binary:Package}\n' | awk '$1 != "not-installed" && $1 != "config-files" {print $2}' | LC_ALL=C sort -u
}

vstacklet::rollback::units() {
	systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | LC_ALL=C sort -u
}

vstacklet::rollback::identity() {
	printf 'machine-id=%s\nrelease=%s %s\narch=%s\n' "$(cat /etc/machine-id 2>/dev/null)" "${distro}" "${codename}" "${vstacklet_arch}"
}

vstacklet::rollback::baseline() {
	local -x LC_ALL=C
	local - p
	set -o pipefail
	local root=/root/vstacklet b=/root/vstacklet/baseline t=/root/vstacklet/baseline.new
	if [[ -n $(dpkg --audit 2>&1) ]]; then
		vstacklet::shell::text::error "apt or dpkg is busy, or a package is half-installed. Wait for it to finish (or run dpkg --configure -a), then run the installer again."
		return 1
	fi
	if [[ -L ${root} || -L ${b} ]]; then
		vstacklet::shell::text::error "${root} or ${b} is a symbolic link; remove it, then run the installer again."
		return 1
	fi
	{ mkdir -p "${root}" && chmod 700 "${root}" && rm -rf "${t}" && mkdir -p "${t}/apt" && chmod 700 "${t}"; } || return 1
	vstacklet::rollback::installed >"${t}/packages" || return 1
	vstacklet::rollback::versions >"${t}/packages.versions" || return 1
	for p in dpkg apt base-files; do
		grep -qxE "${p}(:[a-z0-9]+)?" "${t}/packages" || return 1
	done
	apt-mark showmanual | sort -u >"${t}/packages.manual" || return 1
	vstacklet::rollback::units >"${t}/units.enabled" || return 1
	[[ -s ${t}/packages.manual && -s ${t}/units.enabled ]] || return 1
	crontab -l -u root >"${t}/crontab.root" 2>/dev/null || rm -f "${t}/crontab.root"
	while IFS= read -r p; do
		if [[ -e /etc/apt/${p} ]]; then cp -a "/etc/apt/${p}" "${t}/apt/" || return 1; fi
	done < <(vstacklet::rollback::apt_dirs)
	while IFS= read -r p; do
		if [[ -f ${p} ]]; then cp -a "${p}" "${t}/files${p//\//_}" || return 1; fi
	done < <(vstacklet::rollback::files)
	vstacklet::rollback::paths >"${t}/paths.checked" || return 1
	while IFS= read -r p; do
		if [[ -e ${p} || -L ${p} ]]; then printf '%s\n' "${p}"; fi
	done <"${t}/paths.checked" >"${t}/paths.present"
	{
		vstacklet::rollback::identity
		printf 'recorded=%s\n' "$(date '+%F %H:%M %Z')"
		(cd "${t}" && find . -type f ! -name 'complete*' -print0 | sort -z | xargs -0 -r sha256sum)
	} >"${t}/complete.tmp" || return 1
	{ sync && mv "${t}/complete.tmp" "${t}/complete" && rm -rf "${b}" && mv "${t}" "${b}" && sync; } || return 1
}

################################################################################
# @name: vstacklet::rollback::check
# @description: Succeeds only when /root/vstacklet/baseline is a complete record of this server: real folders owned by root with mode 700, the same machine id, release and architecture, every file listed in the manifest and every hash matching.
################################################################################
vstacklet::rollback::check() {
	local -x LC_ALL=C
	local root=/root/vstacklet b=/root/vstacklet/baseline f
	[[ -d ${root} && ! -L ${root} && -d ${b} && ! -L ${b} && -f ${b}/complete && ! -L ${b}/complete ]] || return 1
	[[ $(stat -c '%u %a' "${root}") == "0 700" && $(stat -c '%u %a' "${b}") == "0 700" ]] || return 1
	[[ $(head -n 3 "${b}/complete") == "$(vstacklet::rollback::identity)" ]] || return 1
	for f in packages packages.versions packages.manual units.enabled paths.checked paths.present; do
		grep -qE "^[0-9a-f]{64}  \./${f}\$" "${b}/complete" || return 1
	done
	[[ $(cd "${b}" && find . -type f ! -name complete | wc -l) -eq $(grep -cE '^[0-9a-f]{64}  \./' "${b}/complete") ]] || return 1
	(cd "${b}" && grep -E '^[0-9a-f]{64}  \./' complete | sha256sum --quiet --strict -c - >/dev/null 2>&1) || return 1
}

################################################################################
# @name: vstacklet::rollback::plan
# @description: Works out what a rollback would change and stops before any change when it would remove something that was there before: the packages added since the record (boot, kernel, SSH and package-manager packages are left in place and listed), a simulated purge that must not take any recorded package with it, the units to disable and to enable again, the installer paths to delete (named in plain words when they hold sites or databases), and the files and apt sources that differ. With "quiet" it only refreshes the lists.
################################################################################
vstacklet::rollback::plan() {
	local -x LC_ALL=C
	local - p out size
	set -o pipefail
	local b=/root/vstacklet/baseline
	local -a added=() lost=()
	declare -ga rb_purge=() rb_kept=() rb_units_off=() rb_units_on=() rb_paths=() rb_files=() rb_apt=() rb_versions=()
	mapfile -t added < <(comm -13 <(sort -u "${b}/packages") <(vstacklet::rollback::installed))
	for p in "${added[@]}"; do
		if [[ ${p%%:*} =~ ^(linux-(image|modules|headers)|linux-.*-signed|grub|shim|initramfs-tools|firmware-|openssh-|systemd|cloud-init|qemu-guest-agent|sudo$|apt$|dpkg$) ]]; then rb_kept+=("${p}"); else rb_purge+=("${p}"); fi
	done
	if ((${#rb_purge[@]})); then
		if ! out="$(apt-get -s purge "${rb_purge[@]}" 2>&1)"; then
			vstacklet::shell::text::error "apt could not plan the removal of the added packages; nothing was changed."
			printf '%s\n' "${out}" | tail -n 5
			return 1
		fi
		mapfile -t lost < <(printf '%s\n' "${out}" | awk '$1 == "Purg" || $1 == "Remv" {print $2}' | sed 's/:.*//' | sort -u | comm -12 - <(sed 's/:.*//' "${b}/packages" | sort -u))
		if ((${#lost[@]})); then
			vstacklet::shell::text::error "removing the added packages would also remove packages that were here before: ${lost[*]}. Nothing was changed. Rebuild the server from a fresh image."
			return 1
		fi
	fi
	mapfile -t rb_units_off < <(comm -13 <(sort -u "${b}/units.enabled") <(vstacklet::rollback::units))
	mapfile -t rb_units_on < <(comm -23 <(sort -u "${b}/units.enabled") <(vstacklet::rollback::units))
	while IFS= read -r p; do
		[[ -n ${p} && ${p} == /* ]] || continue
		grep -qxF -- "${p}" "${b}/paths.checked" || continue
		grep -qxF -- "${p}" "${b}/paths.present" && continue
		if [[ -e ${p} || -L ${p} ]]; then rb_paths+=("${p}"); fi
	done < <(vstacklet::rollback::paths)
	while IFS= read -r p; do
		if [[ -f ${b}/files${p//\//_} ]] && ! cmp -s "${b}/files${p//\//_}" "${p}"; then rb_files+=("${p}"); fi
	done < <(vstacklet::rollback::files)
	while IFS= read -r p; do
		if [[ -e ${b}/apt/${p} || -e /etc/apt/${p} ]] && ! diff -rq "${b}/apt/${p}" "/etc/apt/${p}" >/dev/null 2>&1; then rb_apt+=("/etc/apt/${p}"); fi
	done < <(vstacklet::rollback::apt_dirs)
	# @script-note: recorded packages whose installed version changed since the record (by the install, or by the system's own updates)
	mapfile -t rb_versions < <(LC_ALL=C join <(sort "${b}/packages.versions") <(vstacklet::rollback::versions) | awk '$2 != $3 {print $1 " " $2 " " $3}')
	[[ ${1-} == "quiet" ]] && return 0
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "vStacklet will bring this server back to the state it recorded on $(sed -n 's/^recorded=//p' "${b}/complete") (the bootstrap's own tools stay). It will:"
	vstacklet::shell::text::white " - remove ${#rb_purge[@]} packages added since then: ${rb_purge[*]:-none}"
	((${#rb_kept[@]})) && vstacklet::shell::text::white " - leave in place ${#rb_kept[@]} boot, kernel, SSH or package-manager packages added since then (remove them yourself if you do not want them): ${rb_kept[*]}"
	vstacklet::shell::text::white " - disable ${#rb_units_off[@]} services added since then: ${rb_units_off[*]:-none}; enable again: ${rb_units_on[*]:-none}"
	vstacklet::shell::text::white " - restore the package sources that differ: ${rb_apt[*]:-none}; restore these files: ${rb_files[*]:-none}"
	if ((${#rb_versions[@]})); then
		vstacklet::shell::text::white " - check ${#rb_versions[@]} packages whose version changed since the record: a version the restored sources still offer is kept (updated by the system since the record); any other goes back to the recorded version, or to the release's own version if the recorded one is gone (a downgrade, simulated first):"
		for p in "${rb_versions[@]}"; do vstacklet::shell::text::white "   ${p% *} -> now ${p##* }"; done
	fi
	for p in "${rb_paths[@]}"; do
		size="$(du -sh -- "${p}" 2>/dev/null | cut -f1)"
		case "${p}" in
		/var/lib/mysql | /var/lib/postgresql) vstacklet::shell::text::warning " - delete ${p} (${size:-?}): every database on this server" ;;
		/var/www) vstacklet::shell::text::warning " - delete ${p} (${size:-?}): every site and file under it" ;;
		*) vstacklet::shell::text::white " - delete ${p} (${size:-?})" ;;
		esac
	done
	return 0
}

################################################################################
# @name: vstacklet::rollback::restore
# @description: Applies the plan: finishes any interrupted dpkg run, swaps the recorded apt sources back in, disables the services added since the record, removes exactly the planned packages, reinstalls recorded packages that went missing, applies only the differences in the manual marks, deletes the planned installer paths, restores the files, root's crontab and the SSH listener, then compares packages, units, paths and sources with the record. Succeeds only when nothing differs.
################################################################################
vstacklet::rollback::restore() {
	local -x LC_ALL=C DEBIAN_FRONTEND=noninteractive
	local - p u rc=0 apt_ok=1 left gone port
	set -o pipefail
	local b=/root/vstacklet/baseline s=/etc/apt/.vstacklet-restore
	local -a apt_opts=(-y -o DPkg::Lock::Timeout=300 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold) missing=()
	vstacklet::rollback::check || { vstacklet::shell::text::error "the install record changed after it was checked; nothing was changed." && return 1; }
	vstacklet::shell::text::white "finishing any interrupted package operation ..."
	local dpkg_err
	if ! dpkg_err="$(dpkg --configure -a 2>&1 >/dev/null)" || [[ -n $(dpkg --audit 2>&1) ]]; then
		if [[ ${dpkg_err} == *lock* ]]; then
			vstacklet::shell::text::error "another package operation is running (apt or dpkg holds its lock); wait for it to finish, then run vstacklet --rollback again. Nothing was changed."
		else
			vstacklet::shell::text::error "dpkg could not finish an interrupted package operation (see dpkg --audit); nothing else was changed."
		fi
		return 1
	fi
	vstacklet::rollback::plan quiet || return 1
	vstacklet::shell::text::white "restoring the package sources ..."
	rm -rf "${s}" && mkdir -p "${s}" || return 1
	while IFS= read -r p; do
		if [[ -e ${b}/apt/${p} ]] && ! cp -a "${b}/apt/${p}" "${s}/"; then
			rm -rf "${s}"
			vstacklet::shell::text::error "could not copy the recorded apt sources; nothing was changed."
			return 1
		fi
	done < <(vstacklet::rollback::apt_dirs)
	while IFS= read -r p; do
		rm -rf "/etc/apt/${p:?}"
		if [[ -e ${s}/${p} ]]; then mv "${s}/${p}" /etc/apt/ || rc=1; fi
	done < <(vstacklet::rollback::apt_dirs)
	rm -rf "${s}"
	vstacklet::shell::text::white "stopping and disabling services added since the record ..."
	for u in "${rb_units_off[@]}"; do
		systemctl disable --now "${u}" >/dev/null 2>&1 || rc=1
		vstacklet::shell::text::white " - ${u}"
	done
	if ! apt-get -o DPkg::Lock::Timeout=300 -qq update --error-on=any >/dev/null 2>&1; then
		apt_ok=0
		vstacklet::shell::text::warning "apt-get update could not fetch every restored source; packages that went missing will not be reinstalled."
	fi
	vstacklet::shell::text::white "removing the ${#rb_purge[@]} packages added since the record ..."
	if ((${#rb_purge[@]})); then
		apt-get "${apt_opts[@]}" purge "${rb_purge[@]}" >/dev/null 2>&1 || { rc=1 && vstacklet::shell::text::warning "apt-get purge reported a problem; the comparison below shows what is left."; }
	fi
	mapfile -t missing < <(comm -23 <(sort -u "${b}/packages") <(vstacklet::rollback::installed))
	if ((${#missing[@]})); then
		if ((apt_ok)); then
			vstacklet::shell::text::white "reinstalling ${#missing[@]} recorded packages that went missing ..."
			apt-get "${apt_opts[@]}" --no-install-recommends install "${missing[@]}" >/dev/null 2>&1 || rc=1
		else
			rc=1
		fi
	fi
	vstacklet::rollback::versions_restore "${apt_ok}" || rc=1
	vstacklet::shell::text::white "restoring the manual package marks ..."
	comm -12 <(comm -13 <(apt-mark showmanual | sort -u) <(sort -u "${b}/packages.manual")) <(dpkg-query -W -f='${Package}\n' | sort -u) | xargs -r apt-mark manual >/dev/null 2>&1 || rc=1
	comm -23 <(apt-mark showmanual | sort -u) <(sort -u "${b}/packages.manual") | xargs -r apt-mark auto >/dev/null 2>&1 || rc=1
	vstacklet::shell::text::white "removing installer paths that did not exist before the record ..."
	for p in "${rb_paths[@]}"; do
		rm -rf -- "${p}" || rc=1
		vstacklet::shell::text::white " - ${p}"
	done
	for p in "${rb_files[@]}"; do
		if [[ ${p} == /etc/ssh/sshd_config ]] && ! sshd -t -f "${b}/files${p//\//_}" >/dev/null 2>&1; then
			vstacklet::shell::text::warning "the recorded ${p} does not pass sshd -t here; the current one is kept."
			rc=1
			continue
		fi
		cp -a "${b}/files${p//\//_}" "${p}" || rc=1
		vstacklet::shell::text::white " - restored ${p}"
	done
	if [[ -f ${b}/crontab.root ]]; then
		crontab -l -u root 2>/dev/null | cmp -s - "${b}/crontab.root" || crontab -u root "${b}/crontab.root" || rc=1
	elif crontab -l -u root >/dev/null 2>&1; then
		crontab -r -u root || rc=1
	fi
	[[ -f /etc/hostname ]] && { hostnamectl set-hostname "$(cat /etc/hostname)" >/dev/null 2>&1 || rc=1; }
	while iptables -D INPUT -p udp -m udp --dport 1900 -j DROP 2>/dev/null; do :; done
	while iptables -D INPUT -p tcp --destination-port 10090:10100 -j ACCEPT 2>/dev/null; do :; done
	systemctl daemon-reload >/dev/null 2>&1
	for u in "${rb_units_on[@]}"; do systemctl enable "${u}" >/dev/null 2>&1 || rc=1; done
	if systemctl is-enabled --quiet ssh.socket 2>/dev/null; then systemctl restart ssh.socket >/dev/null 2>&1 || rc=1; else systemctl restart ssh.service >/dev/null 2>&1 || rc=1; fi
	apt-get -y autoclean >/dev/null 2>&1
	# @script-note: compare with the record, so "rolled back" means nothing differs
	vstacklet::rollback::plan quiet || rc=1
	left=$(comm -13 <(sort -u "${b}/packages") <(vstacklet::rollback::installed) | wc -l)
	local orphaned=0
	if ((${#rb_versions[@]})); then
		while read -r p _ now; do vstacklet::rollback::offered "${p}" "${now}" || orphaned=$((orphaned + 1)); done < <(printf '%s\n' "${rb_versions[@]}")
	fi
	gone=$(comm -23 <(sort -u "${b}/packages") <(vstacklet::rollback::installed) | wc -l)
	vstacklet::shell::text::white "differences from the record: packages ${left} added and ${gone} missing (${#rb_kept[@]} of the added left in place on purpose), ${orphaned} at a version no restored source offers, services ${#rb_units_off[@]} added and ${#rb_units_on[@]} missing, installer paths ${#rb_paths[@]}, package sources ${#rb_apt[@]}, files ${#rb_files[@]}"
	port="$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}')"
	vstacklet::shell::text::white "SSH is configured on port ${port:-unknown}; open a new session to check it before you close this one."
	[[ ${rc} -eq 0 && $((left - ${#rb_kept[@]})) -eq 0 && ${gone} -eq 0 && ${orphaned} -eq 0 && ${#rb_units_off[@]} -eq 0 && ${#rb_units_on[@]} -eq 0 && ${#rb_paths[@]} -eq 0 && ${#rb_apt[@]} -eq 0 && ${#rb_files[@]} -eq 0 ]]
}

################################################################################
# @name: vstacklet::rollback
# @description: Brings a server back to the state recorded before vStacklet's first change. It refuses, changing nothing, when the record is missing (a server set up by an earlier vStacklet version), damaged or from another server. It shows the full plan first, including any sites and databases it would delete, and goes ahead only on the word yes. A lock stops a second rollback, a dropped connection does not stop this one, and the run is logged in /root/vstacklet. The install markers are cleared, so the installer can run again, only when nothing differs from the record afterwards.
# @nooptions
# @noargs
#
# @example: vstacklet --rollback
# @break
################################################################################
# @script-note: a recorded package whose version changed is kept when the restored sources still offer its version (the system updated it); otherwise it goes back to the recorded version, or to the restored candidate when that one is gone, with --allow-downgrades after a simulation that must remove nothing recorded. A version no source offers counts as a difference.
vstacklet::rollback::versions_restore() {
	local apt_ok="$1" b=/root/vstacklet/baseline p rec now target out rc=0
	local -a down=() lost=()
	vstacklet::rollback::plan quiet || return 1
	((${#rb_versions[@]})) || return 0
	((apt_ok)) || { vstacklet::shell::text::warning "the restored sources could not be read, so ${#rb_versions[@]} changed package versions were not checked."; return 1; }
	vstacklet::shell::text::white "checking ${#rb_versions[@]} packages whose version changed since the record ..."
	while read -r p rec now; do
		if vstacklet::rollback::offered "${p}" "${now}"; then
			vstacklet::shell::text::white " - ${p} ${now}: updated by the system since the record, kept"
			continue
		fi
		if vstacklet::rollback::offered "${p}" "${rec}"; then
			target="${rec}"
		else
			target="$(LC_ALL=C apt-cache policy "${p}" 2>/dev/null | awk '/Candidate:/ && $2 != "(none)" {print $2}')"
		fi
		if [[ -z ${target} ]]; then
			vstacklet::shell::text::warning " - ${p} ${now}: no restored source offers it or the recorded ${rec}; left as it is"
			rc=1
			continue
		fi
		down+=("${p}=${target}")
	done < <(printf '%s\n' "${rb_versions[@]}")
	((${#down[@]})) || return "${rc}"
	if ! out="$(LC_ALL=C apt-get -s --allow-downgrades --no-install-recommends install "${down[@]}" 2>&1)"; then
		vstacklet::shell::text::warning "apt could not plan returning ${#down[@]} packages to their recorded versions; they are left as they are."
		return 1
	fi
	mapfile -t lost < <(printf '%s\n' "${out}" | awk '$1 == "Purg" || $1 == "Remv" {print $2}' | sed 's/:.*//' | sort -u | comm -12 - <(sed 's/:.*//' "${b}/packages" | sort -u))
	if ((${#lost[@]})); then
		vstacklet::shell::text::warning "returning the packages to their recorded versions would remove recorded packages (${lost[*]}); they are left as they are."
		return 1
	fi
	vstacklet::shell::text::white "returning ${#down[@]} packages to the release's versions: ${down[*]}"
	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::Lock::Timeout=300 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold --allow-downgrades --no-install-recommends install "${down[@]}" >/dev/null 2>&1 || rc=1
	return "${rc}"
}

vstacklet::rollback::apt_resume() {
	local u
	for u in apt-daily.timer apt-daily-upgrade.timer unattended-upgrades.service; do
		if systemctl is-enabled --quiet "${u}" 2>/dev/null; then systemctl start "${u}" >/dev/null 2>&1 || true; fi
	done
}

vstacklet::rollback() {
	local confirm u rc=0
	local -a held=()
	if ! vstacklet::rollback::check; then
		if [[ -e /root/vstacklet/baseline ]]; then
			vstacklet::shell::text::error "this server's install record (/root/vstacklet/baseline) is damaged or belongs to another server; nothing was changed. Rebuild the server from a fresh image."
		else
			vstacklet::shell::text::error "No install record was found on this server (it was set up by an earlier vStacklet version, or the record was removed). vStacklet 4 cannot roll it back safely; nothing was changed. Rebuild the server from a fresh image."
		fi
		exit 1
	fi
	vstacklet::rollback::plan || exit 1
	vstacklet::shell::misc::nl
	vstacklet::shell::text::white "Type yes to roll back as listed above (run this inside screen or tmux if your connection may drop):"
	vstacklet::shell::text::white::sl "> "
	read -r confirm || confirm=""
	[[ ${confirm} == "yes" ]] || { vstacklet::shell::text::error "Rollback cancelled; nothing was changed." && exit 1; }
	exec 9>/root/vstacklet/rollback.lock
	flock -n 9 || { vstacklet::shell::text::error "a rollback is already running on this server." && exit 1; }
	trap '' SIGHUP
	declare -gi rollback_started=1
	exec > >(tee -a "/root/vstacklet/rollback-$(date +%Y%m%d-%H%M%S).log") 2>&1
	for u in apt-daily.timer apt-daily-upgrade.timer unattended-upgrades.service; do
		systemctl is-active --quiet "${u}" 2>/dev/null && held+=("${u}")
	done
	((${#held[@]})) && systemctl stop "${held[@]}" >/dev/null 2>&1
	if vstacklet::rollback::restore; then
		rm -rf /root/vstacklet/setup_temp >/dev/null 2>&1
		rm -f /opt/vstacklet/config/system/.install_complete "${VSTACKLET_MARKER}" "${VSTACKLET_STARTED}" >/dev/null 2>&1
		if [[ -d ${VSTACKLET_MARKER%/*} ]]; then rmdir --ignore-fail-on-non-empty "${VSTACKLET_MARKER%/*}" || true; fi
		[[ -d /var/log/vstacklet ]] && mv /var/log/vstacklet "/var/log/vstacklet-rolled-back-$(date +%Y%m%d-%H%M%S)"
		vstacklet::shell::text::success "Server rolled back to its recorded state. You may run the installer again."
	else
		rc=1
		vstacklet::shell::text::error "The rollback stopped before the server matched its record (see above). The install markers are kept, so the installer stays closed. Run vstacklet --rollback again, or rebuild the server from a fresh image."
	fi
	vstacklet::rollback::apt_resume
	exit "${rc}"
}
