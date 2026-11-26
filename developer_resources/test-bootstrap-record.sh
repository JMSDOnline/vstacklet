#!/usr/bin/env bash
# shellcheck disable=2016,2317
# Checks offline: the bootstrap's TERM line is added once as a line of its own (vstacklet::setup::term_line), and the installer's record takes the bootstrap's earlier record only when it is valid (vstacklet::rollback::pre_ok).
# Usage: bash developer_resources/test-bootstrap-record.sh
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
pass=0 fail=0
check() {
	local name="$1" want="$2" got="$3"
	if [[ ${got} == "${want}" ]]; then pass=$((pass + 1)) && printf 'ok   %s\n' "${name}"; else fail=$((fail + 1)) && printf 'FAIL %s\n  wanted: %q\n  got: %q\n' "${name}" "${want}" "${got}"; fi
}

# the TERM line: the function alone, taken from the bootstrap
sed -n '/^vstacklet::setup::term_line() {$/,/^}$/p' "${here}/setup/vstacklet.sh" >"${tmp}/term.sh"
# shellcheck source=/dev/null
source "${tmp}/term.sh"
f="${tmp}/bashrc"
printf 'alias ll=ls' >"${f}"
vstacklet::setup::term_line "${f}"
check "a file without a closing newline gets one before the line" $'alias ll=ls\nexport TERM=xterm\nx' "$(cat "${f}"; printf x)"
vstacklet::setup::term_line "${f}"
check "a second run adds nothing" "1" "$(grep -cxF 'export TERM=xterm' "${f}")"
printf 'export TERM=xterm\nmore\n' >"${f}"
vstacklet::setup::term_line "${f}"
check "an exact line already there is left alone" $'export TERM=xterm\nmore\nx' "$(cat "${f}"; printf x)"
rm -f "${f}"
vstacklet::setup::term_line "${f}"
check "a missing file gets just the line" $'export TERM=xterm\nx' "$(cat "${f}"; printf x)"
printf 'echo hi\nexport TERM=xtermPS1=x\n' >"${f}"
vstacklet::setup::term_line "${f}"
check "a line joined to another by an earlier version is not taken as the line" "1" "$(grep -cxF 'export TERM=xterm' "${f}")"

# pre_ok: the function alone, with its paths pointed at the test folder
sed -n '/^vstacklet::rollback::pre_ok() {$/,/^}$/p' "${here}/setup/lib/rollback.sh" | sed -e "s#/etc/machine-id#${tmp}/machine-id#g" >"${tmp}/pre.sh"
# shellcheck source=/dev/null
source "${tmp}/pre.sh"
stat() { if [[ $* == *"%u %a"* ]]; then printf '0 %s\n' "$(command stat -c '%a' "${@: -1}")"; else command stat "$@"; fi; }
printf 'abc\n' >"${tmp}/machine-id"
pre="${tmp}/pre-bootstrap"
make_pre() { rm -rf "${pre}"; mkdir -p "${pre}"; chmod 700 "${pre}"; printf 'apt\nbase-files\ndpkg\n' >"${pre}/packages"; printf 'apt\n' >"${pre}/packages.manual"; printf 'machine-id=%s\nrecorded=%s\n' "${1:-abc}" "${2:-$(date +%s)}" >"${pre}/complete"; }
printf 'apt\nbase-files\ndpkg\ngit\ngnupg\n' >"${tmp}/now"
make_pre
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a fresh record from this machine with only additions since is taken" "yes" "${r}"
make_pre other
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a record from another machine is not taken" "no" "${r}"
make_pre abc "$(($(date +%s) - 30000))"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a record older than 6 hours is not taken" "no" "${r}"
make_pre abc "$(($(date +%s) + 600))"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a record from the future is not taken" "no" "${r}"
make_pre
printf 'apt\ndpkg\ngit\n' >"${tmp}/now2"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now2" && r=yes || r=no
check "a record holding a package that has gone since is not taken" "no" "${r}"
make_pre
chmod 755 "${pre}"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a record folder that isn't root-only is not taken" "no" "${r}"
rm -rf "${pre}"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "no record: nothing is taken" "no" "${r}"

printf '%s passed, %s failed\n' "${pass}" "${fail}"
[[ ${fail} -eq 0 ]]
