#!/usr/bin/env bash
# Rewrites the VSTACKLET_MODULE_SHA256 line in setup/vstacklet-server-stack.sh from the modules in setup/lib/, so the installer's loader accepts exactly these files. Run it in the same commit as any module change; --check only reports whether the list is current.
set -euo pipefail
main() {
	local root entry line m sums="" mode="${1:-write}"
	root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
	entry="${root}/setup/vstacklet-server-stack.sh"
	line="$(grep -E '^declare -gar VSTACKLET_MODULES=\(' "${entry}")"
	local -a names
	read -ra names <<<"$(sed -E 's/^declare -gar VSTACKLET_MODULES=\((.*)\)$/\1/; s/"//g' <<<"${line}")"
	for m in "${names[@]}"; do
		[[ ${m} =~ ^[a-z]+$ && -f ${root}/setup/lib/${m}.sh ]] || { printf 'pin-modules: module %s missing\n' "${m}" >&2; exit 1; }
		sums+="[${m}]=\"$(sha256sum "${root}/setup/lib/${m}.sh" | cut -d' ' -f1)\" "
	done
	local new="declare -gA VSTACKLET_MODULE_SHA256=(${sums% })"
	if [[ ${mode} == --check ]]; then
		grep -qxF -- "${new}" "${entry}" && { echo "pin-modules: current"; exit 0; }
		echo "pin-modules: the module list in setup/vstacklet-server-stack.sh is stale; run developer_resources/pin-modules.sh" >&2
		exit 1
	fi
	NEW="${new}" perl -i -pe 's/^declare -gA VSTACKLET_MODULE_SHA256=\(.*\)$/$ENV{NEW}/' "${entry}"
	echo "pin-modules: $(grep -c . <<<"${sums// /$'\n'}") module hashes written"
}
main "$@"
