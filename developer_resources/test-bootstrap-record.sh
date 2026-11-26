#!/usr/bin/env bash
# shellcheck disable=2016,2317
# Checks offline: the bootstrap's TERM line is added once as a line of its own (vstacklet::setup::term_line), and the installer's record takes the bootstrap's earlier record only when it is valid (vstacklet::rollback::pre_ok), and the branch guard reads the chosen branch's version before anything is installed and checks the checkout again after the clone (vstacklet::setup::branch_gate, clone_ok).
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
sums() { local f; for f in packages packages.manual packages.after packages.manual.after files_root_.bashrc files_root_.bashrc.after; do if [[ -f ${pre}/${f} ]]; then printf 'sha256=%s %s\n' "$(sha256sum <"${pre}/${f}" | cut -d' ' -f1)" "${f}"; fi; done; }
make_pre() {
	rm -rf "${pre}"; mkdir -p "${pre}"; chmod 700 "${pre}"
	printf 'apt\nbase-files\ndpkg\n' >"${pre}/packages"; printf 'apt\n' >"${pre}/packages.manual"
	printf 'apt\nbase-files\ndpkg\ngit\ngnupg\n' >"${pre}/packages.after"; printf 'apt\ngit\n' >"${pre}/packages.manual.after"
	local rec="${2:-$(date +%s)}"
	{ printf 'machine-id=%s\nrecorded=%s\nafter=%s\n' "${1:-abc}" "${rec}" "${rec}"; sums; } >"${pre}/complete"
}
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
make_pre
rm -f "${pre}/packages.after"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a record with no state from after the bootstrap's install (a crash in between) is not taken" "no" "${r}"
make_pre
: >"${pre}/packages.manual"; { grep -v '^sha256=' "${pre}/complete"; sums; } >"${pre}/c2" && mv "${pre}/c2" "${pre}/complete"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "an empty manual-marks file is not intact" "no" "${r}"
make_pre
printf 'apt\nbase-files\n' >"${pre}/packages"; { grep -v '^sha256=' "${pre}/complete"; sums; } >"${pre}/c2" && mv "${pre}/c2" "${pre}/complete"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a list from before without dpkg is not intact" "no" "${r}"
make_pre
printf 'apt\nbase-files\ndpkg\nfoo\n' >"${pre}/packages"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a file changed after its hash was taken is not taken" "no" "${r}"
make_pre
mv "${pre}/packages.manual" "${tmp}/pm"; ln -s "${tmp}/pm" "${pre}/packages.manual"
vstacklet::rollback::pre_ok "${pre}" "${tmp}/now" && r=yes || r=no
check "a symbolic link in place of a file is not taken" "no" "${r}"

# pre_merge: only the bootstrap's own additions go; later packages, marks and an edited .bashrc stay
sed -n '/^vstacklet::rollback::pre_merge() {$/,/^}$/p' "${here}/setup/lib/rollback.sh" >"${tmp}/merge.sh"
# shellcheck source=/dev/null
source "${tmp}/merge.sh"
make_pre
printf 'before\n' >"${pre}/files_root_.bashrc"; printf 'before\nexport TERM=xterm\n' >"${pre}/files_root_.bashrc.after"
rec="${tmp}/rec"; rm -rf "${rec}"; mkdir -p "${rec}"
printf 'apt\nbase-files\ndpkg\ngit\ngnupg\nhtop\n' >"${rec}/packages"; printf 'apt\ngit\nhtop\n' >"${rec}/packages.manual"
printf 'apt 1\nbase-files 1\ndpkg 1\ngit 1\ngnupg 1\nhtop 1\n' >"${rec}/packages.versions"
printf 'before\nexport TERM=xterm\n' >"${tmp}/bashrc-now"
vstacklet::rollback::pre_merge "${rec}" "${pre}" "${tmp}/bashrc-now" && r=yes || r=no
check "the merge runs" "yes" "${r}"
check "packages: those from before plus one added after the bootstrap" $'apt\nbase-files\ndpkg\nhtop' "$(cat "${rec}/packages")"
check "manual marks: from before, plus the later package's own mark" $'apt\nhtop' "$(cat "${rec}/packages.manual")"
check "versions only for the recorded names" "4" "$(wc -l <"${rec}/packages.versions" | tr -d ' ')"
check "an unedited .bashrc goes back to its copy from before" "before" "$(cat "${rec}/files_root_.bashrc")"
rm -rf "${rec}"; mkdir -p "${rec}"
printf 'apt\nbase-files\ndpkg\ngit\ngnupg\n' >"${rec}/packages"; printf 'apt\ngit\n' >"${rec}/packages.manual"
printf 'before\nexport TERM=xterm\nalias x=y\n' >"${tmp}/bashrc-now"
vstacklet::rollback::pre_merge "${rec}" "${pre}" "${tmp}/bashrc-now"
check "a .bashrc edited after the bootstrap is not replaced" "no" "$([[ -e ${rec}/files_root_.bashrc ]] && echo yes || echo no)"

# manual marks keep apt-mark's names: a Multi-Arch: same package is "libfoo:amd64" to dpkg and "libfoo" to apt-mark
make_pre
printf 'apt\nbase-files\ndpkg\nlibfoo:amd64\n' >"${pre}/packages"; printf 'apt\nlibfoo\n' >"${pre}/packages.manual"
printf 'apt\nbase-files\ndpkg\ngit\ngnupg\nlibfoo:amd64\n' >"${pre}/packages.after"; printf 'apt\ngit\nlibfoo\n' >"${pre}/packages.manual.after"
rm -rf "${rec}"; mkdir -p "${rec}"
printf 'apt\nbase-files\ndpkg\ngit\ngnupg\nlibbar:amd64\nlibfoo:amd64\n' >"${rec}/packages"; printf 'apt\ngit\nlibbar\nlibfoo\n' >"${rec}/packages.manual"
printf 'x\n' >"${tmp}/bashrc-now"
vstacklet::rollback::pre_merge "${rec}" "${pre}" "${tmp}/bashrc-now"
check "a manual Multi-Arch: same package from before stays manual" "yes" "$(grep -qx libfoo "${rec}/packages.manual" && echo yes || echo no)"
check "a Multi-Arch: same package marked manual after the bootstrap stays manual" "yes" "$(grep -qx libbar "${rec}/packages.manual" && echo yes || echo no)"
check "the bootstrap's own manual mark is not kept" "no" "$(grep -qx git "${rec}/packages.manual" && echo yes || echo no)"
rm -rf "${rec}"; mkdir -p "${rec}"
printf 'apt\nbase-files\ndpkg\ngit\ngnupg\nlibfoo:amd64\n' >"${rec}/packages"; printf 'apt\ngit\n' >"${rec}/packages.manual"
vstacklet::rollback::pre_merge "${rec}" "${pre}" "${tmp}/bashrc-now"
check "a mark the owner removed after the bootstrap stays removed" "no" "$(grep -qx libfoo "${rec}/packages.manual" && echo yes || echo no)"

# bashrc_kept: the function alone; the record's source file says bashrc=kept only when the bootstrap's TERM line stays after a rollback
sed -n '/^vstacklet::rollback::bashrc_kept() {$/,/^}$/p' "${here}/setup/lib/rollback.sh" >"${tmp}/kept.sh"
# shellcheck source=/dev/null
source "${tmp}/kept.sh"
kt="${tmp}/kept-rec" kp="${tmp}/kept-pre"
rm -rf "${kt}" "${kp}"; mkdir -p "${kt}" "${kp}"
printf 'alias ll=ls\nexport TERM=xterm\n' >"${kt}/files_root_.bashrc"
check "no copy of /root/.bashrc from before the bootstrap: bashrc=kept" "bashrc=kept" "$(vstacklet::rollback::bashrc_kept "${kt}" "${kp}")"
printf 'alias ll=ls\n' >"${kp}/files_root_.bashrc"
check "the record keeps the TERM line the copy from before lacks (edited after the bootstrap): bashrc=kept" "bashrc=kept" "$(vstacklet::rollback::bashrc_kept "${kt}" "${kp}")"
printf 'alias ll=ls\n' >"${kt}/files_root_.bashrc"
check "an unedited file, restored from before the bootstrap: nothing" "" "$(vstacklet::rollback::bashrc_kept "${kt}" "${kp}")"
printf 'alias ll=ls\nexport TERM=xterm\n' >"${kt}/files_root_.bashrc"; cp "${kt}/files_root_.bashrc" "${kp}/files_root_.bashrc"
check "a TERM line that was already there before the bootstrap: nothing" "" "$(vstacklet::rollback::bashrc_kept "${kt}" "${kp}")"

# the branch guard: the bootstrap reads the chosen branch's installer version before installing anything, and checks the checkout again after the clone
for fn in version_of is_v4 branch_gate clone_ok; do sed -n "/^vstacklet::setup::${fn}() {\$/,/^}\$/p" "${here}/setup/vstacklet.sh"; done >"${tmp}/guard.sh"
# shellcheck source=/dev/null
source "${tmp}/guard.sh"
fx="${tmp}/fixtures" && mkdir -p "${fx}"
printf '#!/bin/bash\n# <START METADATA>\n# @file_name: vstacklet-server-stack.sh\n# @version: 3.1.1897\n' >"${fx}/three"
printf '#!/bin/bash\n# <START METADATA>\n# @file_name: vstacklet-server-stack.sh\n# @version: 4.0.0\n' >"${fx}/four"
printf '#!/bin/bash\n# no version here\n' >"${fx}/none"
printf '#!/bin/bash\n# @version: 4.0.0; rm -rf /\n' >"${fx}/odd"
# a stand-in curl: writes the fixture named by the branch in the URL to -o, or fails like curl -f on a missing branch
curl() { local out="" a; while [[ $# -gt 0 ]]; do a="${1}"; shift; [[ ${a} == "-o" ]] && out="${1}" && shift; done; local b="${a#https://raw.githubusercontent.com/JMSDOnline/vstacklet/}"; b="${b%%/*}"; [[ -f ${fx}/${b} ]] || return 22; cp "${fx}/${b}" "${out}"; }
gate() { local o rc; o="$(TMPDIR="${tmp}/gt" vstacklet::setup::branch_gate "${1}" 2>&1)" && rc=0 || rc=$?; printf '%s\nrc=%s' "${o}" "${rc}"; }
mkdir -p "${tmp}/gt"
check "the guard reads a plain version line" "4.0.0" "$(vstacklet::setup::version_of "${fx}/four")"
check "the guard refuses a version line with anything after the number" "none" "$(vstacklet::setup::version_of "${fx}/odd" || echo none)"
check "a branch holding vStacklet 4 passes the guard before anything is installed" $'\nrc=0' "$(gate four)"
check "a branch holding vStacklet 3 is refused before anything is installed" "Error: Branch 'three' holds vStacklet 3.1.1897; this bootstrap installs vStacklet 4 only. Run it without -b to install from main. Nothing was changed."$'\nrc=1' "$(gate three)"
check "a branch with no version line is refused" "Error: Branch 'none' holds vStacklet an unknown version; this bootstrap installs vStacklet 4 only. Run it without -b to install from main. Nothing was changed."$'\nrc=1' "$(gate none)"
check "a branch that can't be read is refused" "Error: Unable to read branch 'missing' from GitHub (it may not exist, or this server can't reach GitHub). Nothing was changed."$'\nrc=1' "$(gate missing)"
cp "${fx}/three" "${fx}/main"
check "main holding vStacklet 3 is refused with its own line" "Error: Branch 'main' holds vStacklet 3.1.1897; this bootstrap installs vStacklet 4 only, which is not on main yet. Nothing was changed."$'\nrc=1' "$(gate main)"
check "the guard leaves no temporary file behind" "0" "$(find "${tmp}/gt" -type f | wc -l | tr -d ' ')"
co="${tmp}/checkout" && mkdir -p "${co}/setup" && cp "${fx}/four" "${co}/setup/vstacklet-server-stack.sh"
vstacklet::setup::clone_ok "${co}" devops >/dev/null && r=kept || r=refused
check "after the clone, a vStacklet 4 checkout is kept" "kept $([[ -d ${co} ]] && echo there)" "${r} $([[ -d ${co} ]] && echo there)"
cp "${fx}/three" "${co}/setup/vstacklet-server-stack.sh"
o="$(vstacklet::setup::clone_ok "${co}" devops)" && r=kept || r=refused
check "after the clone, a branch that moved to vStacklet 3 is refused and its checkout removed" "refused gone Error: Branch 'devops' changed while installing and now holds vStacklet 3.1.1897; this bootstrap installs vStacklet 4 only, so the new checkout was removed. Run the bootstrap again." "${r} $([[ -d ${co} ]] && echo there || echo gone) ${o}"
mkdir -p "${co}/setup"
vstacklet::setup::clone_ok "${co}" devops >/dev/null && r=kept || r=refused
check "after the clone, a checkout with no installer is refused and removed" "refused gone" "${r} $([[ -d ${co} ]] && echo there || echo gone)"
unset -f curl
mainfn="$(sed -n '/^vstacklet::setup::main() {$/,/^}$/p' "${here}/setup/vstacklet.sh")"
gl="$(grep -n 'vstacklet::setup::branch_gate' <<<"${mainfn}" | head -1 | cut -d: -f1)" dl="$(grep -n 'vstacklet::setup::download' <<<"${mainfn}" | head -1 | cut -d: -f1)"
check "the bootstrap runs the guard before its download step" "yes" "$([[ -n ${gl} && -n ${dl} && ${gl} -lt ${dl} ]] && echo yes || echo no)"
check "both clone paths check the checkout after the clone" "2" "$(grep -c 'vstacklet::setup::clone_ok "' "${here}/setup/vstacklet.sh")"

printf '%s passed, %s failed\n' "${pass}" "${fail}"
[[ ${fail} -eq 0 ]]
