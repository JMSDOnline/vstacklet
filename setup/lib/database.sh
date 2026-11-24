#!/usr/bin/env bash
# vStacklet installer module: database. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::mariadb::install (29)
# @description: Install mariaDB and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1935-L2057)
#
# notes:
# - if `-mysql | --mysql` is specified, then mariadb will not be installed. choose either mariadb or mysql.
# - actual mariadb version installed is 10.11.+ LTS.
# @option: $1 - `-mariadb | --mariadb` (optional) (takes no arguments)
# @option: $2 - `-mariadbP | --mariadb_port` (optional) (takes one argument)
# @option: $3 - `-mariadbU | --mariadb_user` (optional) (takes one argument)
# @option: $4 - `-mariadbPw | --mariadb_password` (optional) (takes one argument)
# @arg: $2 - `[port]` (optional) (default: 3306)
# @arg: $3 - `[user]` (optional) (default: admin)
# @arg: $4 - `[password]` (optional) (default: password auto-generated)
# @example: vstacklet -mariadb -mariadbP 3306 -mariadbU admin -mariadbPw password
# @example: vstacklet --mariadb --mariadb_port 3306 --mariadb_user admin --mariadb_password password
# @example: vstacklet -mariadb -mariadbP 3306 -mariadbU admin
# @example: vstacklet --mariadb --mariadb_port 3306 --mariadb_user admin
# @example: vstacklet -mariadb -mariadbP 3306
# @example: vstacklet --mariadb --mariadb_port 3306
# @example: vstacklet -mariadb
# @example: vstacklet --mariadb
# @null
# @return_code: 36 - failed to install MariaDB dependencies.
# @return_code: 37 - failed to initialize MariaDB secure installation.
# @return_code: 38 - failed to set MariaDB client and server configuration.
# @return_code: 39 - failed to set MariaDB .my.cnf configuration.
# @return_code: 40 - failed to create MariaDB user.
# @return_code: 41 - failed to create MariaDB user privileges.
# @return_code: 42 - failed to flush privileges.
# @break
##################################################################################
vstacklet::mariadb::install() {
	if [[ -n ${mariadb} ]]; then
		declare mariadb_autoPw
		mariadb_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring MariaDB ... "
		# @script-note: install mariadb dependencies
		for depend in "${mariadb_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") != "1" ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing MariaDB dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 36
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${mariadb_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend depend_list install
		# @script-note: configure mariadb
		vstacklet::shell::text::yellow::sl "configuring MariaDB ... " &
		vs::stat::progress::start # start progress status
		(
			prog=/usr/bin/mysql_secure_installation
			/usr/bin/expect <<DOD
spawn "${prog}"
send "\r"
expect "(y/n)?\r"
send "n\r"
expect "(y/n)?\r"
send "n\r"
expect "(y/n)?\r"
send "y\r"
expect "(y/n)?\r"
send "y\r"
expect "(y/n)?\r"
send "y\r"
expect "(y/n)?\r"
send "y\r"
expect dof
exit
DOD
		) >>"${vslog}" 2>&1 || vstacklet::error::display 37
		# @script-note: set mariadb client and server configuration
		{
			echo -e "[client]"
			echo -e "user = ${mariadb_user:-admin}"
			echo -e "password = ${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo -e "[mysqld]"
			echo -e "port = ${mariadb_port:-3306}"
			echo -e "socket = /run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"
			echo -e "datadir = /var/lib/mysql"
			echo -e "log-error = /var/log/mysql/error.log"
			echo -e "pid-file = /var/run/mysqld/mysqld.pid"
			echo -e "max_allowed_packet = 16M"
			echo -e "max_heap_table_size = 16M"
			echo -e "max_sp_recursion_depth = 255"
			echo -e "max_binlog_size = 100M"
			echo -e "max_binlog_cache_size = 1M"
			echo -e "max_binlog_stmt_cache_size = 1M"
			echo -e "max_sort_length = 1024"
			echo -e "max_join_size = 1000000"
			echo -e "max_length_for_sort_data = 1024"
			echo -e "max_seeks_for_key = 4294967295"
			echo -e "max_write_lock_count = 4294967295"
			echo -e "max_tmp_tables = 32"
			echo -e "max_prepared_stmt_count = 16382"
			echo -e "max_delayed_threads = 20"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::error::display 38
		# @script-note: set .my.cnf
		{
			echo "[client]"
			echo "user=${mariadb_user:-admin}"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo "[mysql]"
			echo "user=root"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo "[mysqldump]"
			echo "user=root"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
			echo "[mysqldiff]"
			echo "user=root"
			echo "password=${mariadb_password:-${mariadb_autoPw}}"
			echo
		} >/root/.my.cnf || vstacklet::error::display 39
		vstacklet::log systemctl daemon-reload
		vstacklet::log systemctl restart mariadb
		#mysqladmin -u root -h localhost password "${mariadb_password:-${mariadb_autoPw}}"
		# @script-note: create mariadb user
		mysql -u root -e "CREATE USER '${mariadb_user:-admin}'@'localhost' IDENTIFIED BY '${mariadb_password:-${mariadb_autoPw}}';" >>"${vslog}" 2>&1 || vstacklet::error::display 40
		mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${mariadb_user:-admin}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || vstacklet::error::display 41
		mysql -u root -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::error::display 42
		vs::stat::progress::stop # stop progress status
		# @script-note: mariadb installation complete
		vstacklet::shell::text::green "mariaDB installed and configured. see details below:"
		vstacklet::shell::text::white::sl "mariaDB password: "
		vstacklet::shell::text::green "${mariadb_password:-${mariadb_autoPw}}"
		vstacklet::shell::text::white::sl "mariaDB user: "
		vstacklet::shell::text::green "${mariadb_user:-admin}"
		vstacklet::shell::text::white::sl "mariaDB port: "
		vstacklet::shell::text::green "${mariadb_port:-3306}"
		vstacklet::shell::text::white::sl "mariaDB socket: "
		vstacklet::shell::text::green "/var/run/mysqld/mysqld.sock"
		vstacklet::shell::text::white::sl "mariaDB configuration file: "
		vstacklet::shell::text::green "/etc/mysql/conf.d/vstacklet.cnf"
		declare -g pma_password
		pma_password="${mariadb_password:-${mariadb_autoPw}}"
	fi
}

##################################################################################
# @name: vstacklet::mysql::install (30)
# @description: Install mySQL and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2088-L2211)
#
# notes:
# - if `-mariadb | --mariadb` is specified, then mysql will not be installed. choose either mysql or mariadb.
# - apt-deb mysql version is 0.8.29-1_all.deb
# - actual mysql version installed is 8.0.+
# @option: $1 - `-mysql | --mysql` (optional) (takes no arguments)
# @option: $2 - `-mysqlP | --mysql_port` (optional) (takes one argument)
# @option: $3 - `-mysqlU | --mysql_user` (optional) (takes one argument)
# @option: $4 - `-mysqlPw | --mysql_password` (optional) (takes one argument)
# @arg: $2 - `[mysql_port]` (optional) (default: 3306)
# @arg: $3 - `[mysql_user]` (optional) (default: admin)
# @arg: $4 - `[mysql_password]` (optional) (default: password auto-generated)
# @example: vstacklet -mysql -mysqlP 3306 -mysqlU admin -mysqlPw password
# @example: vstacklet --mysql --mysql_port 3306 --mysql_user admin --mysql_password password
# @null
# @return_code: 43 - failed to download MySQL deb package.
# @return_code: 44 - failed to install MySQL deb package.
# @return_code: 45 - failed to install MySQL dependencies.
# @return_code: 46 - failed to set MySQL client and server configuration.
# @return_code: 47 - failed to set MySQL .my.cnf file.
# @return_code: 48 - failed to create MySQL user.
# @return_code: 49 - failed to grant MySQL user privileges.
# @return_code: 50 - failed to flush MySQL privileges.
# @break
# shellcheck disable=SC2034,SC2155
##################################################################################
vstacklet::mysql::install() {
	if [[ -n ${mysql} ]]; then
		declare mysql_autoPw
		mysql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		local mysql_deb_version=$(curl -s4 "https://dev.mysql.com/downloads/repo/apt/" | grep -Eo "mysql-apt-config_[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" | head -n 1)
		[[ -f "/tmp/${mysql_deb_version}_all.deb" ]] && rm -f "/tmp/${mysql_deb_version}.*"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring MySQL ... "
		# @script-note: install mysql deb
		vstacklet::log wget "https://dev.mysql.com/get/${mysql_deb_version}_all.deb" -O "/tmp/${mysql_deb_version}_all.deb" || vstacklet::error::display 43
		declare DEBIAN_FRONTEND=noninteractive
		yes | DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install "/tmp/${mysql_deb_version}_all.deb" --allow-change-held-packages >>"${vslog}" 2>&1 || vstacklet::error::display 44
		# @script-note: run apt maintenance to ensure environment is up-to-date
		DEBIAN_FRONTEND=noninteractive apt-get -y update
		apt-get -y upgrade
		apt-get -y autoremove
		apt-get -y autoclean >>"${vslog}" 2>&1
		# @script-note: install mysql dependencies
		declare -a depend_list install_list
		for depend in "${mysql_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing MySQL dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 45
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${mysql_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		vstacklet::log systemctl enable mysql
		vstacklet::log systemctl start mysql
		# @script-note: configure mysql
		vstacklet::shell::text::yellow::sl "configuring MySQL ... " &
		vs::stat::progress::start # start progress status
		# @script-note: set mysql client and server configuration
		{
			echo -e "[client]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysqld]"
			echo -e "port = ${mysql_port:-3306}"
			echo -e "socket = /run/mysqld/mysqld.sock"
			echo -e "bind-address = 127.0.0.1"
			echo -e "mysqlx-bind-address = 127.0.0.1"
			echo -e "datadir = /var/lib/mysql"
			echo -e "log-error = /var/log/mysql/error.log"
			echo -e "pid-file = /var/run/mysqld/mysqld.pid"
			echo -e "key_buffer_size = 16M"
			echo -e "myisam-recover-options = BACKUP"
			echo -e "max_allowed_packet = 16M"
			echo -e "max_heap_table_size = 16M"
			echo -e "max_sp_recursion_depth = 255"
			echo -e "max_binlog_size = 100M"
			echo -e "max_binlog_cache_size = 1M"
			echo -e "max_binlog_stmt_cache_size = 1M"
			echo -e "max_sort_length = 1024"
			echo -e "max_join_size = 1000000"
			echo -e "max_length_for_sort_data = 1024"
			echo -e "max_seeks_for_key = 4294967295"
			echo -e "max_write_lock_count = 4294967295"
			echo -e "max_prepared_stmt_count = 16382"
			echo -e "max_delayed_threads = 20"
		} >/etc/mysql/conf.d/vstacklet.cnf || vstacklet::error::display 46
		# @script-note: set mysql privileges
		{
			echo -e "########################################################################"
			echo -e "# MySQL database privileges"
			echo -e "# Uncomment the following lines to disable MySQL database privileges"
			echo -e "########################################################################"
			echo -e ""
			echo -e "#[mysqld]"
			echo -e "#skip-grant-tables"
			echo -e ""
		} >/etc/mysql/conf.d/vstacklet-grant.cnf >>"${vslog}" 2>&1
		# @script-note: set ~/.my.cnf
		{
			echo -e "[client]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysql]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
			echo
			echo -e "[mysqldump]"
			echo -e "user = ${mysql_user:-admin}"
			echo -e "password = ${mysql_password:-${mysql_autoPw}}"
		} >"${HOME}/.my.cnf" || vstacklet::error::display 47
		vstacklet::log systemctl daemon-reload
		vstacklet::log systemctl enable mysql
		vstacklet::log systemctl restart mysql
		#mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_password:-${mysql_autoPw}}';\"" || vstacklet::error::display 79
		mysql -u root -e "CREATE USER '${mysql_user:-admin}'@'localhost' IDENTIFIED BY '${mysql_password:-${mysql_autoPw}}';" >>"${vslog}" 2>&1 || vstacklet::error::display 48
		mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${mysql_user:-admin}'@'localhost' WITH GRANT OPTION;" >>"${vslog}" 2>&1 || vstacklet::error::display 49
		mysql -u root -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::error::display 50
		vs::stat::progress::stop # stop progress status
		# @script-note: mysql installation complete
		vstacklet::shell::text::green "MySQL installed and configured. see details below:"
		vstacklet::shell::text::white::sl "MySQL password: "
		vstacklet::shell::text::green "${mysql_password:-${mysql_autoPw}}"
		vstacklet::shell::text::white::sl "MySQL user: "
		vstacklet::shell::text::green "${mysql_user:-admin}"
		vstacklet::shell::text::white::sl "MySQL port: "
		vstacklet::shell::text::green "${mysql_port:-3306}"
		vstacklet::shell::text::white::sl "MySQL socket: "
		vstacklet::shell::text::green "/var/run/mysqld/mysqld.sock"
		vstacklet::shell::text::white::sl "MySQL configuration file: "
		vstacklet::shell::text::green "/etc/mysql/conf.d/vstacklet.cnf"
		declare -g pma_password
		pma_password="${mysql_password:-${mysql_autoPw}}"
	fi
}

##################################################################################
# @name: vstacklet::postgre::install (31)
# @description: Install and configure PostgreSQL. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2235-L2322)
#
# note: postgresql is not installed by default and is currently untested.
# this function is a work in progress. it is intended as a future feature.
#
# @option: $1 - `-postgre | --postgresql` (optional)
# @arg: $2 - `[postgresql_port]` (optional) (default: 5432)
# @arg: $3 - `[postgresql_user]` (optional) (default: admin)
# @arg: $4 - `[postgresql_password]` (optional) (default: password auto-generated)
# @example: vstacklet -postgre -postgreP 5432 -postgreU admin -postgrePw password
# @example: vstacklet --postgresql --postgresql_port 5432 --postgresql_user admin --postgresql_password password
# @return_code: 51 - failed to install PostgreSQL dependencies.
# @return_code: 52 - failed to switch to /etc/postgresql/${postgre_version}/main directory.
# @return_code: 53 - failed to set PostgreSQL password.
# @return_code: 54 - failed to create PostgreSQL user.
# @return_code: 55 - failed to grant PostgreSQL user privileges.
# @return_code: 56 - failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file.
# @return_code: 57 - failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file.
# @break
##################################################################################
vstacklet::postgre::install() {
	if [[ -n ${postgresql} ]]; then
		declare postgresql_autoPw
		postgresql_autoPw="$(perl -e 'print map +(A..Z,a..z,0..9)[rand 62], 0..15')"
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "installing and configuring PostgreSQL ... "
		# @script-note: install postgre dependencies
		declare -a depend_list install_list
		for depend in "${postgresql_dependencies[@]}"; do
			if [[ $(dpkg-query -W -f='${Status}' "${depend}" 2>/dev/null | grep -c "ok installed") -eq 0 ]]; then
				depend_list+=("${depend}")
			fi
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::text::white::sl "installing PostgreSQL dependencies: "
		for install in "${depend_list[@]}"; do
			if [[ ${install} == "${depend_list[0]}" ]]; then
				vstacklet::shell::text::white::sl "${install} "
			else
				vstacklet::shell::text::white::sl "| ${install} "
			fi
			# shellcheck disable=SC2015
			DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${install}" "${install}" >>"${vslog}" 2>&1 && sleep 2 || vstacklet::error::display 51
			install_list+=("${install}")
		done
		[[ -n ${depend_list[*]} ]] && vstacklet::shell::misc::nl
		for depend in "${postgresql_dependencies[@]}"; do
			echo "${depend}" >>"${vstacklet_base_path}/config/system/dependencies"
		done
		unset depend_list install_list
		# @script-note: configure postgre
		vstacklet::shell::text::yellow::sl "configuring PostgreSQL ... " &
		vs::stat::progress::start # start progress status
		# @script-note: scrape the version from the output of `apt-cache policy postgresql`
		# since the `psql --version` could return blank if ran too soon after the installation.
		# this also allows a faster installation as no sleep is required.
		#postgre_version="$(psql --version | awk '{print $3}' | awk -F. '{print $1"."$2}')"
		declare postgre_version
		postgre_version="$(apt-cache policy postgresql | grep -A1 "Installed:" | grep -v "Installed:" | awk '{print $2}' | awk -F. '{print $1"."$2}' | cut -d'+' -f1)"
		# @script-note: to make alterations to postgresql, we must first switch to a directory that postgresql has access to
		cd "/etc/postgresql/${postgre_version}/main" || vstacklet::error::display 52
		# @script-note: set postgresql root password
		(
			sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';"
			sleep 2
		) >>"${vslog}" 2>&1 || vstacklet::error::display 53
		# @script-note: create postgresql user
		(
			sudo -u postgres psql -c "CREATE USER ${postgresql_user:-admin} WITH PASSWORD '${postgresql_password:-${postgresql_autoPw}}';"
			sleep 2
		) >>"${vslog}" 2>&1 || vstacklet::error::display 54
		# @script-note: grant postgresql user privileges
		(
			sudo -u postgres psql -c "ALTER USER ${postgresql_user:-admin} WITH SUPERUSER;"
			sleep 2
		) >>"${vslog}" 2>&1 || vstacklet::error::display 55
		# @script-note: set postgre client and server configuration
		cp -f "/etc/postgresql/${postgre_version}/main/postgresql.conf" "/etc/postgresql/${postgre_version}/main/postgresql.conf.default-bak"
		{
			echo -e "port = ${postgresql_port:-5432}"
			echo -e "listen_addresses = 'localhost'"
		} >"/etc/postgresql/${postgre_version}/main/postgresql.conf" || vstacklet::error::display 56
		cp -f "/etc/postgresql/${postgre_version}/main/pg_hba.conf" "/etc/postgresql/${postgre_version}/main/pg_hba.conf.default-bak"
		{
			echo -e "# Database administrative login by Unix domain socket"
			echo -e "local   all             postgres                                peer"
			echo
			echo -e "# TYPE  DATABASE        USER            ADDRESS                 METHOD"
			echo
			echo -e "# \"local\" is for Unix domain socket connections only"
			echo -e "local   all             all                                     md5"
		} >"/etc/postgresql/${postgre_version}/main/pg_hba.conf" || vstacklet::error::display 57
		vs::stat::progress::stop # stop progress status
		# @script-note: postgresql installation complete
		vstacklet::shell::text::green "PostgreSQL installed and configured. see details below:"
		vstacklet::shell::text::white::sl "PostgreSQL password: "
		vstacklet::shell::text::green "${postgresql_password:-${postgresql_autoPw}}"
		vstacklet::shell::text::white::sl "PostgreSQL user: "
		vstacklet::shell::text::green "${postgresql_user:-admin}"
		vstacklet::shell::text::white::sl "PostgreSQL port: "
		vstacklet::shell::text::green "${postgresql_port:-5432}"
		vstacklet::shell::text::white::sl "PostgreSQL socket: "
		vstacklet::shell::text::green "/var/run/postgresql"
		vstacklet::shell::text::white::sl "PostgreSQL configuration file: "
		vstacklet::shell::text::green "/etc/postgresql/${postgre_version}/main/postgresql.conf"
		vstacklet::shell::text::white::sl "PostgreSQL hba file: "
		vstacklet::shell::text::green "/etc/postgresql/${postgre_version}/main/pg_hba.conf"
	fi
}
