#!/usr/bin/env bash
# shellcheck disable=2016,2317
# Checks vstacklet::gate::rollback_first offline: --rollback runs on its own, the release is read the way the install gate reads it (an empty VERSION_CODENAME is mapped through the release table), and a release change is refused by name with what the install added listed; also the version list in the Debian 13 PHP refusal. Runs a copy of the function with /etc/os-release, the install record and the vendor apt files moved into a temporary folder, and with root and the rollback itself stubbed.
# Usage: bash developer_resources/test-rollback-first.sh
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
pass=0 fail=0
releases="$(sed -n '/^declare -ga VSTACKLET_GATE_RELEASES=(/,/^)/p' "${here}/setup/vstacklet-server-stack.sh")"
sed -e "s#/etc/os-release#${tmp}/os-release#g" -e "s#/root/vstacklet#${tmp}/vstacklet#g" -e "s#/etc/apt/#${tmp}/apt/#g" -e 's#\${EUID}#${TEST_EUID}#g' "${here}/setup/lib/gate.sh" >"${tmp}/gate.sh"

# run CASE_ARGS...: prints what the function printed and its exit code
run() {
	(
		eval "${releases}"
		vstacklet::rollback() { printf 'ROLLBACK RAN\n'; exit 0; }
		dpkg() { printf 'amd64\n'; }
		# shellcheck source=/dev/null
		source "${tmp}/gate.sh"
		vstacklet::gate::rollback_first "$@"
		printf 'RETURNED\n'
	) 2>&1
	printf 'rc=%s\n' "$?"
}
check() {
	local name="$1" want="$2" out="$3"
	if [[ ${out} == *"${want}"* ]]; then pass=$((pass + 1)) && printf 'ok   %s\n' "${name}"; else fail=$((fail + 1)) && printf 'FAIL %s\n  wanted: %s\n  got: %s\n' "${name}" "${want}" "${out}"; fi
}
osr() { printf '%s\n' "$@" >"${tmp}/os-release"; }
record() {
	mkdir -p "${tmp}/vstacklet/baseline" "${tmp}/vstacklet/setup_temp"
	printf 'machine-id=x\nrelease=%s\narch=amd64\n' "$1" >"${tmp}/vstacklet/baseline/complete"
	printf '/etc/nginx\n' >"${tmp}/vstacklet/baseline/paths.checked"
	: >"${tmp}/vstacklet/baseline/paths.present"
	printf 'Command: -nginx -php 8.4\n' >"${tmp}/vstacklet/setup_temp/vstacklet_install_command.1.txt"
}

export TEST_EUID=0
osr 'ID=debian' 'VERSION_ID="12"' 'VERSION_CODENAME=bookworm'
check "without --rollback it returns and reads nothing" "RETURNED" "$(run -nginx)"
check "--rollback with another option is refused" "takes no other options" "$(run -nginx --rollback)"
check "a value spelled --rollback is refused, not run" "takes no other options" "$(run -e --rollback)"
check "--rollback as a non-root user is refused" "run the installer as root" "$(TEST_EUID=1000 run --rollback)"
record "Debian bookworm"
check "the same release runs the rollback" "ROLLBACK RAN" "$(run --rollback)"
osr 'ID=debian' 'VERSION_ID="12"'
check "an empty VERSION_CODENAME is mapped through the release table, no false release change" "ROLLBACK RAN" "$(run --rollback)"
osr 'ID=debian' 'VERSION_ID="99"'
check "an unknown release with no codename is refused by name" "cannot read this server's release codename" "$(run --rollback)"
osr 'ID=debian' 'VERSION_ID="13"' 'VERSION_CODENAME=trixie'
mkdir -p "${tmp}/apt/sources.list.d" && : >"${tmp}/apt/sources.list.d/vstacklet-nginx.sources"
out="$(run --rollback)"
check "a release change is refused, naming both releases by number" "recorded on Debian 12 (bookworm) and now runs Debian 13 (trixie)" "${out}"
check "the refusal lists the vendor files the install added" "vstacklet-nginx.sources" "${out}"
check "the refusal lists the install options" "the install options:  -nginx -php 8.4" "${out}"
check "the refusal changes nothing and never runs the rollback" "rc=1" "${out}"
# the PHP refusal on Debian 13 joins the versions for a sentence and picks the verb by count
php_list() {
	# shellcheck source=/dev/null
	(source "${tmp}/gate.sh" && vstacklet::gate::versions "$@")
}
check "one PHP version reads 'is'" "PHP 8.3 is not offered" "PHP $(php_list 8.3) not offered"
check "two PHP versions read 'and ... are'" "PHP 8.3 and 8.5 are not offered" "PHP $(php_list 8.3 8.5) not offered"
check "three PHP versions are joined with commas" "PHP 8.1, 8.3 and 8.5 are not offered" "PHP $(php_list 8.1 8.3 8.5) not offered"
# the option reader: -e and --email are refused before any change, like every option vStacklet 4.0 does not offer
args_run() {
	(
		vstacklet::shell::text::error() { printf 'ERROR %s\n' "$*"; }
		vstacklet::update::check() { printf 'UPDATE RAN\n'; exit 0; }
		# shellcheck source=/dev/null
		source "${here}/setup/lib/args.sh"
		vstacklet::args::process "$@"
		printf 'RETURNED\n'
	) 2>&1
	printf 'rc=%s\n' "$?"
}
check "-e is refused with the 4.0 line" "ERROR -e is not offered in vStacklet 4.0; with -wp, the installer asks for the WordPress admin email. Nothing was changed."$'\n'"rc=1" "$(args_run -e 'owner@example.com' -nginx)"
check "--email is refused with the 4.0 line" "ERROR --email is not offered in vStacklet 4.0; with -wp, the installer asks for the WordPress admin email. Nothing was changed."$'\n'"rc=1" "$(args_run --email 'owner@example.com')"
printf 'test-rollback-first: %s/%s passed\n' "${pass}" "$((pass + fail))"
((fail == 0))
