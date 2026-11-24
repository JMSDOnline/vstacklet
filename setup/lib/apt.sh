#!/usr/bin/env bash
# vStacklet installer module: apt. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::apt::pins
# @description: The vendor repositories vStacklet may add, and the primary-key fingerprints it trusts for each.
#
# notes:
# - a key file holding any other primary key is refused; a pinned key that is expired or revoked is left out of the
#   keyring with a notice, and the repository is refused when no pinned key is left
# - a vendor that moves to a new primary key needs an updated vStacklet, because the pins live here
# @break
##################################################################################
vstacklet::apt::pins() {
	declare -gA VS_REPO_KEY_URL=(
		[nginx]="https://nginx.org/keys/nginx_signing.key"
		[sury]="https://packages.sury.org/php/apt.gpg"
	)
	# @script-note: nginx: read from the vendor's key file on 2026-11-24. 573BFD6B... is the fingerprint nginx.org publishes; 8540A6F1... and 9E9BE90E... carry its certification, and 8540A6F1... signs the repository's Release files.
	# @script-note: sury: read from the vendor's key file on 2026-11-24 (no fingerprint is published); the same key ships in the vendor's debsuryorg-archive-keyring 2025.11.18 package.
	declare -gA VS_REPO_FPRS=(
		[nginx]="573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 8540A6F18833A80E9C1653A42FD21310B49F6B46 9E9BE90EACBCDE69FE9B204CBCDCD8A38D88A2B3"
		[sury]="15058500A0235D97F5D10063B188E2B695BD4743"
	)
	# @script-note: the Origin field of each vendor's Release file, as apt reports it (o=)
	declare -gA VS_REPO_ORIGIN=([nginx]="nginx" [sury]="deb.sury.org")
	# @script-note: vendor libraries that may replace an installed release package, per release and PHP, read from the vendor's package index; none is needed for bookworm with PHP 8.4 (read 2026-11-24), and none for bookworm with 8.3 or 8.5 (lab install and rollback, 2026-11-24, S4-S12). A pair whose plan replaces any other installed package from a vendor is refused.
	declare -gA VS_PHP_LIBS=()
}

##################################################################################
# @name: vstacklet::php::origin
# @description: Where the chosen PHP comes from on this release: the release's own archive when it ships that version, otherwise packages.sury.org. Prints "os" or "sury".
##################################################################################
vstacklet::php::origin() {
	case "${codename}-${php}" in
	trixie-8.4 | noble-8.3 | resolute-8.5) printf 'os\n' ;;
	*) printf 'sury\n' ;;
	esac
}

##################################################################################
# @name: vstacklet::dependencies::array (11)
# @description: The one list of packages the install adds through apt, for the options chosen: the installer's own tools, PHP and its extensions, nginx and MariaDB. The gate checks this list and the install installs exactly it, in one apt call.
#
# notes:
# - PHP extensions are split into required (a missing one stops the install) and optional (a missing one is skipped with a message)
# - no 3.x build tools, no FTP server, no NFS client, no PPA tooling
# @break
##################################################################################
vstacklet::dependencies::array() {
	declare -ga vs_packages=() vs_php_required=() vs_php_optional=() vs_php_skipped=()
	vs_packages=("lsb-release" "curl" "wget" "git" "gpg" "bind9-dnsutils" "dialog" "ssl-cert" "openssl" "ca-certificates" "apache2-utils" "sudo" "debconf-utils" "locales" "net-tools" "iproute2" "rsync" "dos2unix" "jq" "bc" "nano" "zip" "unzip" "htop" "vnstat" "vnstati" "iptables" "iptables-persistent" "openssh-server")
	[[ ${distro} == "Ubuntu" ]] && vs_packages+=("language-pack-en-base")
	if [[ -n ${php} ]]; then
		vs_php_required=("fpm" "cli" "common" "xml" "mbstring" "curl" "zip" "gd" "intl")
		[[ -n ${mariadb} ]] && vs_php_required+=("mysql")
		vs_php_optional=("bcmath" "gmp" "readline" "soap" "igbinary" "msgpack" "imagick" "memcached")
		# @script-note: PHP 8.5 builds OPcache into PHP itself, so there is no package to install; its php.ini settings apply either way (lab, S4-S12)
		[[ ${php} == "8.3" || ${php} == "8.4" ]] && vs_php_optional=("opcache" "${vs_php_optional[@]}")
	fi
	[[ -n ${nginx} ]] && vs_packages+=("nginx")
	[[ -n ${mariadb} ]] && vs_packages+=("mariadb-server" "mariadb-client")
	return 0
}

##################################################################################
# @name: vstacklet::apt::repos
# @description: The vendor repositories this install adds, from the options and the release.
##################################################################################
vstacklet::apt::repos() {
	declare -ga vs_repos=()
	[[ -n ${nginx} ]] && vs_repos+=("nginx")
	[[ -n ${php} && $(vstacklet::php::origin) == "sury" ]] && vs_repos+=("sury")
	return 0
}

##################################################################################
# @name: vstacklet::apt::sources_text
# @description: The deb822 source file for a vendor repository. The gate's private copy and the file written to the server come from here; only the Signed-By path differs.
# @arg: $1 - repository name; $2 - keyring path for Signed-By
##################################################################################
vstacklet::apt::sources_text() {
	local uri comp
	case "$1" in
	nginx) uri="https://nginx.org/packages/${distro,,}" comp="nginx" ;;
	sury) uri="https://packages.sury.org/php" comp="main" ;;
	*) return 1 ;;
	esac
	printf 'Types: deb\nURIs: %s\nSuites: %s\nComponents: %s\nArchitectures: %s\nSigned-By: %s\n' "${uri}" "${codename}" "${comp}" "${vstacklet_arch}" "$2"
}

##################################################################################
# @name: vstacklet::apt::prefs_text
# @description: The apt preferences file for a vendor repository.
##################################################################################
vstacklet::apt::prefs_text() {
	local libs="${VS_PHP_LIBS[${codename}-${php}]-}"
	case "$1" in
	nginx) printf '%s\n' "# vStacklet: nginx comes from nginx.org, never from the release's own archive." "Package: *" "Pin: origin nginx.org" "Pin-Priority: 900" ;;
	sury) printf '%s\n' "# vStacklet: PHP ${php} comes from packages.sury.org; every other package there stays below the release's own archive." "# The order matters: apt uses the first stanza that matches a package." "Package: php${php} php${php}-* php-common${libs:+ ${libs}}" "Pin: origin packages.sury.org" "Pin-Priority: 990" "" "Package: *" "Pin: origin packages.sury.org" "Pin-Priority: 100" ;;
	*) return 1 ;;
	esac
}

##################################################################################
# @name: vstacklet::apt::conflicts
# @description: Reads the server's own package sources (never writes them) and refuses, before any change, a CD-ROM source or an existing entry for a repository vStacklet would add or that would pull the stack away from the release's archive.
##################################################################################
vstacklet::apt::conflicts() {
	local f line host
	local -a files=()
	[[ -f /etc/apt/sources.list ]] && files+=("/etc/apt/sources.list")
	while IFS= read -r -d '' f; do files+=("${f}"); done < <(find /etc/apt/sources.list.d -maxdepth 1 -type f \( -name '*.list' -o -name '*.sources' \) -print0 2>/dev/null | sort -z)
	for f in "${files[@]}"; do
		# @script-note: active lines only: comments dropped; in deb822 files, a stanza with "Enabled: no" is skipped
		while IFS= read -r line; do
			[[ ${line} == *cdrom:* ]] && vstacklet::gate::refuse "this server lists a CD-ROM as a package source (${f}). Remove or comment out that line, then run vstacklet again."
			for host in packages.sury.org ppa.launchpadcontent.net/ondrej ppa.launchpad.net/ondrej nginx.org/packages packages.redis.io apt.postgresql.org packagecloud.io/varnishcache packages.varnish-software.com mariadb.org dlm.mariadb.com /mariadb/repo repo.mysql.com; do
				[[ ${line} == *"${host}"* ]] && vstacklet::gate::refuse "this server already has a package source for ${host%%/*} (${f}). vStacklet adds the repositories it needs itself and installs on fresh servers only."
			done
		done < <(awk 'BEGIN{RS=""; FS="\n"} { if ($0 ~ /(^|\n)[Ee]nabled:[ \t]*no/) next; n=split($0, l, "\n"); for (i=1;i<=n;i++) if (l[i] !~ /^[ \t]*#/) print l[i] }' "${f}")
	done
	return 0
}

##################################################################################
# @name: vstacklet::apt::key
# @description: Fetches a vendor key once into the gate's private folder, checks every primary key in it against the pins, and exports only the valid pinned keys as a binary keyring. Refuses an unpinned primary key, and a repository left with no valid pinned key; warns 90 days before a pinned key expires.
# @arg: $1 - repository name
##################################################################################
vstacklet::apt::key() {
	local name="$1" home="${vs_apt_tmp}/gnupg-$1" raw="${vs_apt_tmp}/keys/$1.raw" out="${vs_apt_tmp}/keys/$1.gpg"
	local -a pins valid=() seen=()
	local rec fpr validity expires now soon p
	read -r -a pins <<<"${VS_REPO_FPRS[${name}]}"
	install -d -m 0700 "${home}" || "${vs_refuse:-vstacklet::gate::refuse}" "could not prepare the key check for ${name}."
	curl -fsSL --proto '=https' --tlsv1.2 --max-time 60 -o "${raw}" "${VS_REPO_KEY_URL[${name}]}" || "${vs_refuse:-vstacklet::gate::refuse}" "could not download the ${name} repository key from ${VS_REPO_KEY_URL[${name}]}."
	gpg --homedir "${home}" --batch --quiet --no-autostart --import "${raw}" >/dev/null 2>&1 || "${vs_refuse:-vstacklet::gate::refuse}" "the ${name} repository key could not be read."
	now="$(date +%s)" soon=$(($(date +%s) + 90 * 86400))
	# @script-note: one "pub" record per primary key, followed by its "fpr" record; the second field is its validity (e expired, r revoked)
	while IFS=: read -r rec validity _ _ _ _ expires _ _ fpr _; do
		case "${rec}" in
		pub) p="${validity}|${expires}" ;;
		fpr)
			[[ -n ${p} ]] || continue
			validity="${p%%|*}" expires="${p#*|}" p=""
			seen+=("${fpr}")
			[[ " ${pins[*]} " == *" ${fpr} "* ]] || "${vs_refuse:-vstacklet::gate::refuse}" "the ${name} repository key holds a key vStacklet does not trust (${fpr}). If the vendor changed its key, update vStacklet."
			if [[ ${validity} == "e" || ${validity} == "r" || (-n ${expires} && ${expires} -le ${now}) ]]; then
				"${vs_notice:-vstacklet::gate::notice}" "the ${name} key ${fpr} is expired or revoked and is left out."
				continue
			fi
			if [[ -n ${expires} && ${expires} -le ${soon} ]]; then
				"${vs_notice:-vstacklet::gate::notice}" "the ${name} key ${fpr} expires on $(date -d "@${expires}" +%F); run vstacklet --refresh-keys after the vendor renews it."
				# @script-note: kept for the end summary, where it will be read (S4-S17)
				vs_key_expiry+=("the ${name} key ${fpr} expires on $(date -d "@${expires}" +%F)")
			fi
			valid+=("${fpr}")
			;;
		esac
	done < <(gpg --homedir "${home}" --batch --with-colons --fixed-list-mode --list-keys 2>/dev/null)
	((${#seen[@]})) || "${vs_refuse:-vstacklet::gate::refuse}" "the ${name} repository key file holds no key."
	((${#valid[@]})) || "${vs_refuse:-vstacklet::gate::refuse}" "the ${name} repository has no valid trusted key left; update vStacklet."
	if ! gpg --homedir "${home}" --batch --quiet --export-options export-clean --export "${valid[@]}" >"${out}" 2>/dev/null || [[ ! -s ${out} ]]; then
		"${vs_refuse:-vstacklet::gate::refuse}" "the ${name} repository key could not be exported."
	fi
	gpgconf --homedir "${home}" --kill all >/dev/null 2>&1 || true
	return 0
}

##################################################################################
# @name: vstacklet::apt::private::setup
# @description: A private apt state for the gate: copies of the server's sources, preferences and package lists, plus the candidate vendor sources, keys and pins, so the check reads exactly what the install would use and writes nothing outside its own temporary folder.
##################################################################################
vstacklet::apt::private::setup() {
	local t f
	t="$(mktemp -d /tmp/vstacklet-apt.XXXXXXXX)" || vstacklet::gate::refuse "could not make a temporary folder for the package check."
	declare -g vs_apt_tmp="${t}"
	trap 'vstacklet::exit::cleanup' EXIT
	chmod 0755 "${t}"
	mkdir -p "${t}/etc/sources.list.d" "${t}/etc/preferences.d" "${t}/etc/apt.conf.d" "${t}/state/lists" "${t}/cache/archives/partial" "${t}/log" || vstacklet::gate::refuse "could not prepare the package check."
	install -d -m 0700 "${t}/keys"
	if [[ -f /etc/apt/sources.list ]]; then cp -p /etc/apt/sources.list "${t}/etc/sources.list"; else : >"${t}/etc/sources.list"; fi
	[[ -f /etc/apt/preferences ]] && cp -p /etc/apt/preferences "${t}/etc/preferences"
	find /etc/apt/sources.list.d -maxdepth 1 -type f \( -name '*.list' -o -name '*.sources' \) -exec cp -p -t "${t}/etc/sources.list.d" {} + 2>/dev/null
	find /etc/apt/preferences.d -maxdepth 1 -type f -exec cp -p -t "${t}/etc/preferences.d" {} + 2>/dev/null
	find /etc/apt/apt.conf.d -maxdepth 1 -type f -exec cp -p -t "${t}/etc/apt.conf.d" {} + 2>/dev/null
	# @script-note: the main /etc/apt/apt.conf is read after the parts, so it is copied in as an early part instead and the real one is skipped (Dir::Etc::main below); the private settings in the last part then win
	[[ -f /etc/apt/apt.conf ]] && cp -p /etc/apt/apt.conf "${t}/etc/apt.conf.d/00vstacklet-main-apt.conf"
	# @script-note: the package lists are seeded from the server's own (read only), so only changed indexes download again
	find /var/lib/apt/lists -maxdepth 1 -type f ! -name lock -exec cp -p -t "${t}/state/lists" {} + || vstacklet::gate::refuse "could not copy the package lists into ${t} (is /tmp full?)."
	[[ -f /var/lib/apt/extended_states ]] && cp -p /var/lib/apt/extended_states "${t}/state/extended_states"
	install -d -m 0700 "${t}/state/lists/partial"
	if id -u _apt >/dev/null 2>&1; then chown _apt:root "${t}/state/lists/partial" "${t}/cache/archives/partial"; chmod 0700 "${t}/cache/archives/partial"; fi
	chmod 0755 "${t}/state" "${t}/state/lists" "${t}/cache" "${t}/cache/archives"
	# @script-note: APT_CONFIG is read before the configuration parts, so it can point apt at the private copy of them; the last part clears every hook, so no hook runs or writes during the check
	{
		printf 'Dir::Etc::Parts "%s";\nDir::Etc::main "/dev/null";\n' "${t}/etc/apt.conf.d"
	} >"${t}/apt.conf"
	{
		printf '#clear APT::Update::Pre-Invoke;\n#clear APT::Update::Post-Invoke;\n#clear APT::Update::Post-Invoke-Success;\n#clear APT::Update::Post-Invoke-Stats;\n#clear DPkg::Pre-Invoke;\n#clear DPkg::Post-Invoke;\n#clear DPkg::Pre-Install-Pkgs;\n'
		printf 'Dir::State "%s";\nDir::State::status "/var/lib/dpkg/status";\nDir::Cache "%s";\nDir::Log "%s";\n' "${t}/state" "${t}/cache" "${t}/log"
		printf 'Dir::Etc::SourceList "%s";\nDir::Etc::SourceParts "%s";\nDir::Etc::Preferences "%s";\nDir::Etc::PreferencesParts "%s";\n' "${t}/etc/sources.list" "${t}/etc/sources.list.d" "${t}/etc/preferences" "${t}/etc/preferences.d"
	} >"${t}/etc/apt.conf.d/zzzz-vstacklet-private"
	for f in "${vs_repos[@]}"; do
		vstacklet::apt::key "${f}"
		vstacklet::apt::sources_text "${f}" "${t}/keys/${f}.gpg" >"${t}/etc/sources.list.d/vstacklet-${f}.sources"
		vstacklet::apt::prefs_text "${f}" >"${t}/etc/preferences.d/vstacklet-${f}"
	done
	chmod 0644 "${t}"/keys/*.gpg 2>/dev/null || true
	chmod 0755 "${t}/keys"
	return 0
}

vstacklet::apt::private::cleanup() {
	[[ -n ${vs_apt_tmp-} && -d ${vs_apt_tmp} && ${vs_apt_tmp} == /tmp/vstacklet-apt.* ]] || return 0
	local h
	for h in "${vs_apt_tmp}"/gnupg-*; do
		[[ -d ${h} ]] && gpgconf --homedir "${h}" --kill all >/dev/null 2>&1
	done
	rm -rf -- "${vs_apt_tmp}"
}

# @script-note: apt in the private state (the gate) or the real one (the install); every call has the same options
vstacklet::apt::priv() { APT_CONFIG="${vs_apt_tmp}/apt.conf" LC_ALL=C DEBIAN_FRONTEND=noninteractive "$@"; }
vstacklet::apt::real() { LC_ALL=C DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=l "$@"; }

##################################################################################
# @name: vstacklet::apt::plan
# @description: Simulates the install of the whole list in the given state ("priv" or "real") and prints one line per package it would install: name, version, origin (o= of the source apt would use) and "new" or "replace".
##################################################################################
vstacklet::apt::plan() {
	local mode="$1" out
	shift
	local -A src_origin=()
	local key o name ver old
	if ! out="$(vstacklet::apt::"${mode}" apt-get -s -o DPkg::Lock::Timeout=300 install --no-install-recommends "$@" 2>&1)"; then
		printf 'FAIL\t%s\n' "$(printf '%s\n' "${out}" | grep -E '^E: ' | head -n 5 | tr '\n' ' ')"
		return 0
	fi
	printf '%s\n' "${out}" | awk '$1 == "Remv" {print "REMOVE\t" $2}'
	# @script-note: the origin of each source, from apt's own policy (o=), never from the label in the simulate output
	while IFS=$'\t' read -r key o; do src_origin["${key}"]="${o}"; done < <(vstacklet::apt::"${mode}" apt-cache policy 2>/dev/null | awk '/^ *-?[0-9]+ / && $2 ~ /^[a-z+]+:/ {k=$2" "$3; next} /^ +release / && k != "" {o=""; s=""; n=split($2, a, ","); for (i=1;i<=n;i++) {if (a[i] ~ /^o=/) o=substr(a[i],3); if (a[i] ~ /^n=/) s=substr(a[i],3)}; print k "\t" o "@" s; k=""}')
	local -a names=()
	local -A newver=() oldver=()
	local -a w
	while read -r -a w; do
		name="${w[1]%%:*}"
		if [[ ${w[2]} == \[* ]]; then old="${w[2]#[}" old="${old%]}" ver="${w[3]#(}"; else old="" ver="${w[2]#(}"; fi
		names+=("${name}") newver["${name}"]="${ver}" oldver["${name}"]="${old}"
	done < <(printf '%s\n' "${out}" | grep -E '^Inst ')
	((${#names[@]})) || return 0
	local pkg v s
	local -A origin_of=()
	while IFS=$'\t' read -r pkg v s; do
		[[ -n ${origin_of[${pkg}]-} || ${v} != "${newver[${pkg}]-}" ]] && continue
		origin_of["${pkg}"]="${src_origin[${s}]-unknown}"
	done < <(vstacklet::apt::"${mode}" apt-cache policy "${names[@]}" 2>/dev/null | awk '/^[^ ]/ {p=$1; sub(/:$/,"",p); sub(/:[a-z0-9]+$/,"",p); next} /^ (\*\*\*|   ) [^ ]+ -?[0-9]+$/ {v=($1=="***")?$2:$1; next} /^ +-?[0-9]+ / && $2 ~ /^[a-z+]+:/ {print p "\t" v "\t" $2" "$3}')
	for name in "${names[@]}"; do
		printf '%s\t%s\t%s\t%s\n' "${name}" "${newver[${name}]}" "${origin_of[${name}]-unknown}" "$([[ -n ${oldver[${name}]} ]] && echo replace || echo new)"
	done
}

##################################################################################
# @name: vstacklet::apt::plan::check
# @description: The rules every plan must meet: nothing removed; exactly the chosen PHP version, never another; PHP from the origin the matrix picks; nginx from nginx.org; no installed package replaced from a vendor unless the release's library list allows it.
##################################################################################
vstacklet::apt::plan::check() {
	local plan="$1" fail="$2" name ver origin kind want_php os_o o n
	[[ ${distro} == "Debian" ]] && os_o="Debian" || os_o="Ubuntu"
	[[ $(vstacklet::php::origin) == "sury" ]] && want_php="${VS_REPO_ORIGIN[sury]}" || want_php="${os_o}"
	local -a bad=()
	[[ -s ${plan} ]] || { "${fail}" "apt planned no packages; the package lists may be empty."; return 1; }
	grep -q '^FAIL' "${plan}" && { "${fail}" "apt cannot install the package list on this server: $(cut -f2 "${plan}" | head -n 1)"; return 1; }
	grep -q '^REMOVE' "${plan}" && { "${fail}" "installing would remove packages already on this server: $(awk -F'\t' '$1=="REMOVE"{printf "%s ", $2}' "${plan}")"; return 1; }
	while IFS=$'\t' read -r name ver origin kind; do
		o="${origin%@*}" n="${origin#*@}"
		# @script-note: a package from the release's own archive must come from this release (its own, -updates or -security suite), never from another release the server lists
		if [[ ${o} == "${os_o}" && ${n} != "${codename}" && ${n} != "${codename}-updates" && ${n} != "${codename}-security" ]]; then bad+=("${name} would come from ${o} ${n}, not ${codename}"); continue; fi
		origin="${o}"
		if [[ ${name} =~ ^php([0-9]+\.[0-9]+)(-|$) && ${BASH_REMATCH[1]} != "${php}" ]]; then bad+=("${name} is PHP ${BASH_REMATCH[1]}, not ${php}"); continue; fi
		if [[ ${name} == "php${php}" || ${name} == php${php}-* || ${name} == "php-common" ]]; then
			[[ ${origin} == "${want_php}" ]] || bad+=("${name} would come from ${origin}, not ${want_php}")
			continue
		fi
		if [[ -n ${nginx} && (${name} == "nginx" || ${name} == nginx-*) ]]; then
			[[ ${origin} == "${VS_REPO_ORIGIN[nginx]}" ]] || bad+=("${name} would come from ${origin}, not nginx.org")
			continue
		fi
		if [[ ${kind} == "replace" && ${origin} != "${os_o}" && " ${VS_PHP_LIBS[${codename}-${php}]-} " != *" ${name} "* ]]; then
			bad+=("${name} is installed and would be replaced from ${origin}")
		fi
		[[ ${origin} == "unknown" ]] && bad+=("${name}: apt reports no source")
	done < <(grep -vE '^(FAIL|REMOVE)' "${plan}")
	((${#bad[@]})) && { "${fail}" "the package plan breaks vStacklet's rules: ${bad[*]}"; return 1; }
	return 0
}

##################################################################################
# @name: vstacklet::apt::gate
# @description: The package check, before any change (called from vstacklet::gate::install): the server's sources, the vendor keys, one update in the private state, the release's suites, the PHP extensions on offer, and a simulated install of the whole list.
##################################################################################
vstacklet::apt::gate() {
	local out ext pol line os_o
	local -a missing=()
	vstacklet::apt::pins
	vstacklet::dependencies::array
	vstacklet::apt::repos
	vstacklet::apt::conflicts
	vstacklet::apt::private::setup
	if ! out="$(vstacklet::apt::priv apt-get -q -o DPkg::Lock::Timeout=300 --error-on=any update 2>&1)"; then
		vstacklet::gate::refuse "apt could not update the package lists: $(printf '%s\n' "${out}" | grep -E '^(E|Err):' | head -n 3 | tr '\n' ' ')"
	fi
	vstacklet::apt::warnings "${out}" vstacklet::gate::refuse
	# @script-note: the release's own suites, as apt sees them
	pol="$(vstacklet::apt::priv apt-cache policy 2>/dev/null | awk '/^ +release / {o=""; n=""; c=""; m=split($2, a, ","); for (i=1;i<=m;i++) {if (a[i] ~ /^o=/) o=substr(a[i],3); if (a[i] ~ /^n=/) n=substr(a[i],3); if (a[i] ~ /^c=/) c=substr(a[i],3)}; print o "|" n "|" c}' | sort -u)"
	[[ ${distro} == "Debian" ]] && os_o="Debian" || os_o="Ubuntu"
	for line in "${os_o}|${codename}|main" "${os_o}|${codename}-security|main"; do
		grep -qxF "${line}" <<<"${pol}" || missing+=("${line#*|}")
	done
	[[ ${distro} == "Ubuntu" ]] && { grep -qxF "${os_o}|${codename}|universe" <<<"${pol}" || missing+=("${codename}|universe"); }
	((${#missing[@]})) && vstacklet::gate::refuse "this server's package sources lack ${missing[*]//|/ }; add them, then run vstacklet again."
	grep -qxF "${os_o}|${codename}-updates|main" <<<"${pol}" || vstacklet::gate::notice "this server's package sources have no ${codename}-updates suite; packages install without the release's latest fixes until it is added."
	for ext in "${vs_repos[@]}"; do
		awk -F'|' -v o="${VS_REPO_ORIGIN[${ext}]}" -v n="${codename}" '$1 == o && $2 == n {f=1} END {exit !f}' <<<"${pol}" || vstacklet::gate::refuse "the ${ext} repository offers nothing for ${distro} ${codename} on ${vstacklet_arch}."
	done
	# @script-note: PHP extensions: a required one with no candidate stops here; an optional one is skipped with a message
	for ext in "${vs_php_required[@]}" "${vs_php_optional[@]}"; do
		if [[ -z $(vstacklet::apt::priv apt-cache policy "php${php}-${ext}" 2>/dev/null | awk '/Candidate:/ && $2 != "(none)" {print $2}') ]]; then
			if [[ " ${vs_php_required[*]} " == *" ${ext} "* ]]; then vstacklet::gate::refuse "PHP ${php} has no ${ext} extension package for ${distro} ${codename}."; fi
			vs_php_skipped+=("${ext}")
			continue
		fi
		vs_packages+=("php${php}-${ext}")
	done
	((${#vs_php_skipped[@]})) && vstacklet::gate::notice "PHP ${php} extensions not offered here and skipped: ${vs_php_skipped[*]}."
	vstacklet::apt::plan priv "${vs_packages[@]}" | LC_ALL=C sort >"${vs_apt_tmp}/plan.gate"
	vstacklet::apt::plan::check "${vs_apt_tmp}/plan.gate" vstacklet::gate::refuse
	declare -g vs_plan_count
	vs_plan_count="$(grep -cvE '^(FAIL|REMOVE)' "${vs_apt_tmp}/plan.gate")"
	# @script-note: only the checked keys and the plan are needed from here on; the private lists and caches can be large and /tmp may be in RAM
	rm -rf -- "${vs_apt_tmp:?}/state" "${vs_apt_tmp:?}/cache" "${vs_apt_tmp:?}/log"
	return 0
}

vstacklet::apt::resume_units() {
	((${#vs_held_units[@]})) && systemctl start "${vs_held_units[@]}" >/dev/null 2>&1
	vs_held_units=()
	return 0
}

# @script-note: apt's W: lines from an update: one about a source vStacklet adds (a vstacklet-* file, nginx.org, packages.sury.org) stops the run; one about the server's own sources is shown as a notice, since it is not vStacklet's to fix
vstacklet::apt::warnings() {
	local out="$1" fail="$2" ours rest
	ours="$(grep -E '^W: ' <<<"${out}" | grep -E 'vstacklet-|nginx\.org|packages\.sury\.org' | head -n 3 | tr '\n' ' ')"
	rest="$(grep -E '^W: ' <<<"${out}" | grep -vE 'vstacklet-|nginx\.org|packages\.sury\.org' | head -n 3 | tr '\n' ' ')"
	[[ -n ${rest} ]] && vstacklet::gate::notice "apt warned about this server's own package sources (not changed by vStacklet): ${rest}"
	[[ -n ${ours} ]] && "${fail}" "apt warned about a package source vStacklet adds: ${ours}"
	return 0
}

# @script-note: a failure after changes: the error path, never gate::refuse (which says no change was made)
vstacklet::apt::fail() {
	declare -g vstacklet_failed_step="$*; run vstacklet --rollback to undo this install"
	vstacklet::error::display log
}

##################################################################################
# @name: vstacklet::packages::install
# @description: After the record: writes the checked keys (the same bytes the gate checked), the vendor sources and pins, updates the real package lists, simulates once more on the real state and refuses a plan whose names or origins differ from the gate's, then installs the whole list in one apt call.
# @break
##################################################################################
vstacklet::packages::install() {
	local r out k
	vstacklet::shell::text::white "installing ${vs_plan_count} packages in one step ... "
	# @script-note: the system's own apt timers are held from here to the end of the install, so they cannot move a package between the check and the install
	local u
	declare -ga vs_held_units=()
	for u in apt-daily.timer apt-daily-upgrade.timer unattended-upgrades.service; do
		systemctl is-active --quiet "${u}" 2>/dev/null && vs_held_units+=("${u}")
	done
	((${#vs_held_units[@]})) && systemctl stop "${vs_held_units[@]}" >/dev/null 2>&1
	install -d -m 0755 /etc/apt/keyrings /etc/apt/sources.list.d /etc/apt/preferences.d || vstacklet::apt::fail "could not create the apt folders"
	for r in "${vs_repos[@]}"; do
		k="/etc/apt/keyrings/vstacklet-${r}.gpg"
		if ! install -m 0644 -o root -g root "${vs_apt_tmp}/keys/${r}.gpg" "${k}.new" || ! mv -f "${k}.new" "${k}"; then vstacklet::apt::fail "could not write the ${r} key"; fi
		cmp -s "${vs_apt_tmp}/keys/${r}.gpg" "${k}" || vstacklet::apt::fail "the ${r} key written differs from the one checked"
		vstacklet::apt::sources_text "${r}" "${k}" >"/etc/apt/sources.list.d/vstacklet-${r}.sources" || vstacklet::apt::fail "could not write the ${r} source"
		vstacklet::apt::prefs_text "${r}" >"/etc/apt/preferences.d/vstacklet-${r}" || vstacklet::apt::fail "could not write the ${r} pin"
		chmod 0644 "/etc/apt/sources.list.d/vstacklet-${r}.sources" "/etc/apt/preferences.d/vstacklet-${r}"
	done
	out="$(vstacklet::apt::real apt-get -q -o DPkg::Lock::Timeout=300 --error-on=any update 2>&1)" || { printf '%s\n' "${out}" >>"${vslog}"; vstacklet::apt::fail "apt-get update failed (see the log)"; }
	printf '%s\n' "${out}" >>"${vslog}"
	vstacklet::apt::warnings "${out}" vstacklet::apt::fail
	vstacklet::apt::plan real "${vs_packages[@]}" | LC_ALL=C sort >"${vs_apt_tmp}/plan.real"
	vstacklet::apt::plan::check "${vs_apt_tmp}/plan.real" vstacklet::apt::fail
	if ! diff -q <(cut -f1,3 "${vs_apt_tmp}/plan.gate") <(cut -f1,3 "${vs_apt_tmp}/plan.real") >/dev/null; then
		vstacklet::apt::fail "the package plan changed since the check ($(diff <(cut -f1,3 "${vs_apt_tmp}/plan.gate") <(cut -f1,3 "${vs_apt_tmp}/plan.real") | grep -E '^[<>]' | head -n 5 | tr '\t\n' ' '))"
	fi
	vstacklet::apt::real apt-get -y -q -o DPkg::Lock::Timeout=300 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install --no-install-recommends "${vs_packages[@]}" >>"${vslog}" 2>&1 || vstacklet::apt::fail "apt-get install failed (see the log)"
	vstacklet::apt::resume_units
	# @script-note: packages from a vendor outside the PHP and nginx sets are named, so a vendor library never arrives unseen
	out="$(awk -F'\t' -v os="$([[ ${distro} == "Debian" ]] && echo Debian || echo Ubuntu)" '{split($3, a, "@")} a[1] != os && $1 !~ /^(php|nginx)/ {printf "%s (%s) ", $1, a[1]}' "${vs_apt_tmp}/plan.real")"
	[[ -n ${out} ]] && vstacklet::shell::text::white "also from a vendor repository: ${out}"
	# @script-note: kept for the 3.x tools that read it
	printf '%s\n' "${vs_packages[@]}" >>"${vstacklet_base_path}/config/system/dependencies"
	# @script-note: a PHP package that a later upgrade would hold back means the pins and the vendor disagree; say so
	out="$(vstacklet::apt::real apt-get -s -o DPkg::Lock::Timeout=300 upgrade 2>/dev/null | awk '/kept back:/ {f=1; next} f && /^  / {print} f && !/^  / {f=0}' | tr -s ' \n' ' ')"
	declare -g vs_php_kept_back=""
	# shellcheck disable=SC2086 # one package name per word
	for k in ${out}; do [[ ${k} == "php${php}" || ${k} == php${php}-* || ${k} == "php-common" ]] && vs_php_kept_back+="${k} "; done
	[[ -n ${vs_php_kept_back} ]] && vstacklet::shell::text::warning "a later upgrade would hold back these PHP packages: ${vs_php_kept_back}(see the PHP pin in /etc/apt/preferences.d)."
	vstacklet::shell::text::green "packages installed."
}

##################################################################################
# @name: vstacklet::apt::refresh_keys
# @description: `vstacklet --refresh-keys`: re-fetches each vendor key vStacklet wrote (/etc/apt/keyrings/vstacklet-*.gpg), checks it against the pins, and replaces it (a temporary file renamed into place) only when it passes; then updates the package lists. A vendor that changed its primary key needs an updated vStacklet, because the pins live in the code.
##################################################################################
vstacklet::apt::refresh_keys() {
	local k name out n=0
	vstacklet::apt::refresh::refuse() { vstacklet::shell::text::error "$*"; vstacklet::shell::text::error "no key was replaced."; exit 1; }
	vstacklet::apt::refresh::notice() { vstacklet::shell::text::warning "$*"; }
	declare -g vs_refuse=vstacklet::apt::refresh::refuse vs_notice=vstacklet::apt::refresh::notice
	[[ ${EUID} -eq 0 ]] || vstacklet::apt::refresh::refuse "run vstacklet --refresh-keys as root."
	command -v gpg >/dev/null 2>&1 || vstacklet::apt::refresh::refuse "gpg is not installed; install it with apt-get install gpg."
	vstacklet::apt::pins
	declare -g vs_apt_tmp
	vs_apt_tmp="$(mktemp -d /tmp/vstacklet-apt.XXXXXXXX)" || vstacklet::apt::refresh::refuse "could not make a temporary folder."
	trap 'vstacklet::exit::cleanup' EXIT
	install -d -m 0700 "${vs_apt_tmp}/keys"
	for k in /etc/apt/keyrings/vstacklet-*.gpg; do
		[[ -f ${k} && ! -L ${k} ]] || continue
		name="${k##*/vstacklet-}" name="${name%.gpg}"
		[[ -n ${VS_REPO_KEY_URL[${name}]-} ]] || { vstacklet::apt::refresh::notice "${k} is not a key this vStacklet manages; left as it is."; continue; }
		vstacklet::apt::key "${name}"
		if cmp -s "${vs_apt_tmp}/keys/${name}.gpg" "${k}"; then
			vstacklet::shell::text::white "${name}: the key is unchanged."
			continue
		fi
		if ! install -m 0644 -o root -g root "${vs_apt_tmp}/keys/${name}.gpg" "${k}.new" || ! mv -f "${k}.new" "${k}"; then
			rm -f "${k}.new"
			vstacklet::apt::refresh::refuse "could not replace ${k}."
		fi
		vstacklet::shell::text::green "${name}: the key was renewed."
		n=$((n + 1))
	done
	out="$(LC_ALL=C apt-get -q -o DPkg::Lock::Timeout=300 --error-on=any update 2>&1)" || { printf '%s\n' "${out}" | grep -E '^(E|Err|W):' | head -n 5; vstacklet::shell::text::error "apt-get update failed after the key refresh."; return 1; }
	if grep -qE '^W: ' <<<"${out}"; then
		grep -E '^W: ' <<<"${out}" | head -n 5
		vstacklet::shell::text::error "apt warned while reading the package sources after the key refresh (above)."
		return 1
	fi
	vstacklet::shell::text::white "key refresh done: ${n} renewed."
	return 0
}
