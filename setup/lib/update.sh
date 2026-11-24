#!/usr/bin/env bash
# vStacklet installer module: update. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

################################################################################
# @name: vstacklet::update::check
# @description: Checks the branch this server was installed from for a newer 4.x release tag and, on a yes, moves /opt/vstacklet to that tag and installs its installer as /usr/local/bin/vstacklet. Runs only on a server with a completed 4.x install; the 3.x tools are never installed.
#
# @nooptions
# @noargs
# @break
################################################################################
vstacklet::update::check() {
	local branch current latest input
	[[ -f ${VSTACKLET_MARKER} ]] || { vstacklet::shell::text::error "no completed vStacklet 4 install was found on this server (${VSTACKLET_MARKER}); --check_update works on 4.x installs only." && exit 1; }
	[[ -d ${vstacklet_base_path}/.git ]] || { vstacklet::shell::text::error "${vstacklet_base_path} is not a git checkout of vStacklet; rerun the bootstrap to restore it." && exit 1; }
	branch="$(cat "${vstacklet_base_path}/config/system/branch" 2>/dev/null || true)"
	[[ ${branch} =~ ^[A-Za-z0-9][A-Za-z0-9._/-]{0,99}$ && ${branch} != *..* ]] || { vstacklet::shell::text::error "the stored branch name in ${vstacklet_base_path}/config/system/branch is missing or not valid." && exit 1; }
	vstacklet::shell::text::yellow "Checking branch ${branch} for a newer vStacklet 4 release ..."
	git -C "${vstacklet_base_path}" fetch --quiet --tags origin "refs/heads/${branch}" || { vstacklet::shell::text::error "could not fetch branch ${branch} from the vStacklet repository." && exit 1; }
	current="$(git -C "${vstacklet_base_path}" describe --tags --match 'v4.*' --abbrev=0 HEAD 2>/dev/null || true)"
	latest="$(git -C "${vstacklet_base_path}" describe --tags --match 'v4.*' --abbrev=0 FETCH_HEAD 2>/dev/null || true)"
	if [[ -z ${latest} ]]; then
		vstacklet::shell::text::white "No vStacklet 4 release is tagged on branch ${branch} yet; nothing to update."
		exit 0
	fi
	if [[ ${latest} == "${current}" ]]; then
		vstacklet::shell::text::green "vStacklet is up to date (${current}, branch ${branch})."
		exit 0
	fi
	vstacklet::shell::text::yellow "A newer release is available on branch ${branch}: ${latest} (installed: ${current:-untagged})."
	vstacklet::shell::text::yellow "Type yes to update the vStacklet scripts. The update changes nothing else on this server."
	vstacklet::shell::icon::arrow::white && read -r input
	[[ ${input,,} == "yes" || ${input,,} == "y" ]] || { vstacklet::shell::text::yellow "Update cancelled." && exit 0; }
	git -C "${vstacklet_base_path}" checkout --quiet --detach "refs/tags/${latest}" || { vstacklet::shell::text::error "could not switch ${vstacklet_base_path} to ${latest}; local changes there may block it (see git -C ${vstacklet_base_path} status)." && exit 1; }
	install -m 0755 "${vstacklet_base_path}/setup/vstacklet-server-stack.sh" /usr/local/bin/vstacklet || { vstacklet::shell::text::error "could not install the ${latest} installer as /usr/local/bin/vstacklet." && exit 1; }
	vstacklet::shell::text::success "vStacklet scripts updated to ${latest}."
	exit 0
}
