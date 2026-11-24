#!/usr/bin/env bash
# shellcheck disable=SC2034 # rb_versions, OFFER and CAND are read by the sourced functions and the stubs
# Offline test of the rollback's version step (vstacklet::rollback::versions_restore): which version a changed package moves to, with apt-cache and apt-get replaced by stubs. Needs no root and changes nothing.
set -uo pipefail
main() {
	local root fails=0
	root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
	# shellcheck source=/dev/null
	source "${root}/setup/lib/rollback.sh"
	vstacklet::shell::text::white() { printf '%s\n' "$*"; }
	vstacklet::shell::text::warning() { printf 'warning: %s\n' "$*"; }
	vstacklet::rollback::plan() { return 0; }
	# stub data: for each package, the versions the restored sources offer and the candidate
	declare -gA OFFER=() CAND=()
	apt-cache() {
		local p="$2" v
		printf '%s:\n  Installed: x\n  Candidate: %s\n  Version table:\n' "${p}" "${CAND[${p}]:-(none)}"
		for v in ${OFFER[${p}]-}; do printf '     %s 500\n        500 http://deb.example.org/debian bookworm/main amd64 Packages\n' "${v}"; done
		printf ' *** %s 100\n        100 /var/lib/dpkg/status\n' "installed-copy"
	}
	apt-get() { return 0; }
	declare -ga rb_versions=()
	check() {
		local name="$1" want="$2" out
		out="$(vstacklet::rollback::versions_restore 1 2>/dev/null; echo "rc=$?")"
		if [[ ${out} == *"${want}"* ]]; then echo "ok   ${name}"; else echo "FAIL ${name}: ${out//$'\n'/ | }"; fails=$((fails + 1)); fi
	}
	# a) the system raised it to a version the restored sources still offer: kept
	rb_versions=("libx 1.0 1.2") OFFER=([libx]="1.0 1.2") CAND=([libx]="1.2")
	check "updated by the system and still offered: kept" "updated by the system since the record, kept"
	# b) recorded 1.0, security update 1.1 installed, 1.2 now offered and 1.1 gone: up to the candidate 1.2, never back to 1.0
	rb_versions=("libx 1.0 1.1") OFFER=([libx]="1.0 1.2") CAND=([libx]="1.2")
	check "installed version gone, a newer candidate exists: up to it (S4-M1)" "to the release's versions: libx=1.2"
	# c) a vendor build 9.0 whose source is gone, the release offers its own 1.0 (also the recorded one): back to 1.0
	rb_versions=("php-common 1.0 9.0") OFFER=([php-common]="1.0") CAND=([php-common]="1.0")
	check "vendor build with its source gone: back to the release's version" "to the release's versions: php-common=1.0"
	# d) nothing offers it and there is no candidate: left as it is, the step fails closed
	rb_versions=("liby 1.0 2.0") OFFER=() CAND=()
	check "no source and no candidate: left as it is, failure reported" "left as it is"
	echo "test-rollback-versions: $((4 - fails))/4 passed"
	[[ ${fails} -eq 0 ]]
}
main "$@"
