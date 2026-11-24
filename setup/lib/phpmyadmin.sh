#!/usr/bin/env bash
# vStacklet installer module: phpmyadmin. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::phpmyadmin::install (33)
# @description: Install phpMyAdmin and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2455-L2549)
#
# notes:
# - phpMyAdmin requires a web server to run. You must select a web server from the list below.
#   - nginx
#   - varnish
# - phpMyAdmin requires a database server to run. You must select a database server from the list below.
#   - mariadb
#   - mysql
# - phpMyAdmin requires php to run. You must select a php version from the list below.
#   - 8.3, 8.4 or 8.5
# - phpMyAdmin requires a web port to run. This argmuent is supplied by the `-http | --http_port` option.
# - phpMyAdmin will use the following options to configure itself:
#   - web server: nginx, varnish
#     - Nginx usage: `-nginx | --nginx`
#     - Varnish usage: `-varnish | --varnish`
#   - database server: mariadb, mysql
#     - mariaDB usage: `-mariadbU [user] | --mariadb_user [user]` & `-mariadbPw [password] | --mariadb_password [password]`
#     - mysql usage: `-mysqlU [user] | --mysql_user [user]` & `-mysqlPw [password] | --mysql_password [password]`
#     - note: if no user or password is provided, the default user and password will be used. (admin, auto-generated password)
#   - php version: 8.3, 8.4 or 8.5
#     - PHP usage: `-php [version] | --php [version]`
#   - port: http
#     - usage: `-http [port] | --http [port]`
#     - note: if no port is provided, the default port will be used. (80)
# @option: $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments) (default: not installed)
# @arg: `-phpmyadmin | --phpmyadmin` does not take any arguments. However, it requires the options as expressed above.
# @example: vstacklet -phpmyadmin -nginx -mariadbU admin -mariadbPw password -php 8.3 -http 80
# @example: vstacklet --phpmyadmin --nginx --mariadb_user admin --mariadb_password password --php 8.3 --http 80
# @null
# @return_code: 64 - failed to install phpMyAdmin dependencies.
# @return_code: 65 - failed to switch to /usr/share directory.
# @return_code: 66 - failed to download phpMyAdmin.
# @return_code: 67 - failed to extract phpMyAdmin.
# @return_code: 68 - failed to move phpMyAdmin to /usr/share directory.
# @return_code: 69 - failed to remove phpMyAdmin .tar.gz file.
# @return_code: 70 - failed to set ownership of phpMyAdmin directory.
# @return_code: 71 - failed to set permissions of phpMyAdmin directory.
# @return_code: 72 - failed to create /usr/share/phpmyadmin/tmp directory.
# @return_code: 73 - failed to set symlink of ./phpmyadmin to ${web_root}/public/phpmyadmin.
# @return_code: 74 - failed to create htpasswd file.
# @return_code: 75 - failed to create phpMyAdmin configuration file.
# @break
##################################################################################
vstacklet::phpmyadmin::install() {
	if [[ -n ${phpmyadmin} ]]; then
		if [[ (-n ${mariadb} || -n ${mysql}) && (-n ${nginx} || -n ${varnish}) && (-n ${php}) ]]; then
			declare pma_version pma_bf
			pma_version=$(curl -s https://www.phpmyadmin.net/home_page/version.json | jq -r '.version')
			pma_bf=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..31')
			# @script-note: install phpmyadmin
			vstacklet::shell::misc::nl
			vstacklet::shell::text::white "installing and configuring phpMyAdmin ... "
			# @script-note: install phpmyadmin dependencies and phpmyadmin
			for depend in "${phpmyadmin_dependencies[@]}"; do
				if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
					depend_list+=("${depend}")
				fi
			done
			[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing phpMyAdmin dependencies: "
			for install in "${depend_list[@]}"; do
				if [[ ${install} == "${depend_list[0]}" ]]; then
					vstacklet::shell::text::white::sl "${install} "
				else
					vstacklet::shell::text::white::sl "| ${install} "
				fi
				# shellcheck disable=SC2015
				DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 64
				install_list+=("${install}")
			done
			[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
			for depend in "${phpmyadmin_dependencies[@]}"; do
				echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
			done
			unset depend depend_list install
			cd /usr/share || vstacklet::error::display 65
			[[ -d phpmyadmin ]] && rm -rf phpmyadmin
			wget -q "https://files.phpmyadmin.net/phpMyAdmin/${pma_version}/phpMyAdmin-${pma_version}-all-languages.tar.gz" || vstacklet::error::display 66
			tar -xzf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::error::display 67
			mv phpMyAdmin-"${pma_version}"-all-languages phpmyadmin || vstacklet::error::display 68
			rm -rf phpMyAdmin-"${pma_version}"-all-languages.tar.gz || vstacklet::error::display 69
			chown -R www-data:www-data phpmyadmin || vstacklet::error::display 70
			chmod -R 755 phpmyadmin || vstacklet::error::display 71
			# trunk-ignore(shellcheck/SC2015)
			if ! (mkdir -p /usr/share/phpmyadmin/tmp && chown -R www-data:www-data /usr/share/phpmyadmin/tmp); then
				vstacklet::error::display 72
			fi
			ln -sf /usr/share/phpmyadmin "${web_root:-/var/www/html/vsapp}/public" || vstacklet::error::display 73
			# @script-note: configure phpmyadmin
			vstacklet::shell::text::yellow::sl "configuring phpMyAdmin ... " &
			vs::stat::progress::start # start progress status
			# @script-note: create phpmyadmin htpasswd file - this is used for basic authentication, not for the database
			# this is only used if/when the user opts to use basic authentication (a post install courtesy)
			htpasswd -b -c /usr/share/phpmyadmin/.htpasswd "${mariadb_user:-${mysql_user:-admin}}" "${pma_password}" >>"${vslog}" 2>&1 || vstacklet::error::display 74
			# @script-note: set phpmyadmin configuration
			# - /etc/phpmyadmin/config.inc.php
			# - /usr/share/phpmyadmin/config.inc.php - this is the default config file
			{
				echo -e "<?php"
				echo -e "/* Servers configuration */"
				echo -e "\$i = 0;"
				echo -e "/* Server: localhost [1] */"
				echo -e "\$i++;"
				echo -e "\$cfg['Servers'][\$i]['verbose'] = 'localhost';"
				echo -e "\$cfg['Servers'][\$i]['host'] = 'localhost';"
				echo -e "\$cfg['Servers'][\$i]['port'] = '${http_port:-80}';"
				echo -e "\$cfg['Servers'][\$i]['socket'] = '';"
				echo -e "\$cfg['Servers'][\$i]['connect_type'] = 'tcp';"
				echo -e "\$cfg['Servers'][\$i]['extension'] = 'mysqli';"
				echo -e "\$cfg['Servers'][\$i]['compress'] = false;"
				echo -e "\$cfg['Servers'][\$i]['auth_type'] = 'cookie';"
				echo -e "\$cfg['Servers'][\$i]['user'] = '${mariadb_user:-${mysql_user:-admin}}';"
				echo -e "\$cfg['Servers'][\$i]['password'] = '${pma_password}';"
				echo -e "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;"
				echo -e "/* End of servers configuration */"
				echo -e "\$cfg['blowfish_secret'] = '${pma_bf}';"
				echo -e "\$cfg['DefaultLang'] = 'en';"
				echo -e "\$cfg['ServerDefault'] = 1;"
				echo -e "\$cfg['UploadDir'] = '';"
				echo -e "\$cfg['SaveDir'] = '';"
				echo -e "?>"
			} >/usr/share/phpmyadmin/config.inc.php || vstacklet::error::display 75
			vs::stat::progress::stop # stop progress status
			# @script-note: phpmyadmin installation complete
			vstacklet::shell::text::green "phpMyAdmin installed and configured. see details below:"
			vstacklet::shell::text::white::sl "phpMyAdmin username: "
			vstacklet::shell::text::green "${mariadb_user:-${mysql_user:-admin}}"
			vstacklet::shell::text::white::sl "phpMyAdmin password: "
			vstacklet::shell::text::green "${pma_password}"
			vstacklet::shell::text::white::sl "phpMyAdmin http port: "
			vstacklet::shell::text::green "${http_port:-80}"
			vstacklet::shell::text::white::sl "phpMyAdmin htpasswd file: "
			vstacklet::shell::text::green "/usr/share/phpmyadmin/.htpasswd"
			vstacklet::shell::text::white::sl "phpMyAdmin configuration file: "
			vstacklet::shell::text::green "/usr/share/phpmyadmin/config.inc.php"
			vstacklet::shell::text::white::sl "phpMyAdmin web root: "
			vstacklet::shell::text::green "${web_root:-/var/www/html/vsapp}/public"
		fi
	fi
}
