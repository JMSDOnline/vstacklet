#!/usr/bin/env bash
# vStacklet installer module: wordpress. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::wordpress::install (36)
# @description: Install WordPress. This will also configure WordPress to use
# the database that was created during the installation process. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L2921-L3127)
#
# notes:
# - this function is only called under the following conditions:
#   - the option `-wp` is used directly
# - this function will install wordpress and configure the database.
# - wordpress is an active build option and requires active intput from the user (for now).
# these arguments are:
#   - wordpress database name
#   - wordpress database user
#   - wordpress database password
# - this function requires the following options to be used:
#   - database: `-mariadb | --mariadb` (MySQL is not available in this development build)
#   - webserver: `-nginx | --nginx` or `-varnish | --varnish` (both can be used)
#   - php: `-php | --php`
# - this function will optionally use the following options:
#   - web root: `-wr | --web_root` (default: /var/www/html/vsapp)
#
# @option: $1 - `-wp | --wordpress` (optional)
# @noargs
# @example: vstacklet -wp -mariadb -nginx -php "8.4" -wr "/var/www/html/vsapp"
# @example: vstacklet -wp -mariadb -nginx -php "8.4" -varnish -varnishP 80 -http 8080 -https 443
# @null
# @return_code: 96 - failed to download WordPress.
# @return_code: 97 - failed to extract WordPress.
# @return_code: 98 - failed to move WordPress to the web root.
# @return_code: 99 - failed to create WordPress upload directory.
# @return_code: 100 - failed to create WordPress configuration file.
# @return_code: 101 - failed to modify WordPress configuration file.
# @return_code: 102 - failed to create WordPress database.
# @return_code: 103 - failed to create WordPress database user.
# @return_code: 104 - failed to grant WordPress database user privileges.
# @return_code: 105 - failed to flush WordPress database privileges.
# @return_code: 106 - failed to remove WordPress installation files.
# @return_code: 107 - failed to install WordPress.
# @return_code: 108 - failed to install WordPress plugins [varnish-http-purge].
# @break
##################################################################################
vstacklet::wordpress::install() {
	# @script-note: check if WordPress has been selected
	if [[ -n ${wordpress} ]]; then
		declare wp_db_name wp_db_user wp_db_password wp_sum
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "please enter the following information for WordPress:"
		# @script-note: get WordPress database name
		vstacklet::wp::db() {
			vstacklet::shell::text::white::sl "WordPress database name: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_db_name; do
				[[ ! ${wp_db_name} =~ ^[A-Za-z0-9_]{1,64}$ ]] && vstacklet::shell::text::error "use letters, digits and underscores only (64 at most)." && vstacklet::shell::text::white::sl "WordPress database name: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress database user
		vstacklet::wp::user() {
			vstacklet::shell::text::white::sl "WordPress database user: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_db_user; do
				# @script-note: check if WordPress database user already exists, if so, use current user
				[[ ! ${wp_db_user} =~ ^[a-z_][a-z0-9_]{0,31}$ || ${wp_db_user} == "root" ]] && vstacklet::shell::text::error "use lowercase letters, digits and underscores (32 at most), not root." && vstacklet::shell::text::white::sl "WordPress database user: " && vstacklet::shell::icon::arrow::white && continue
				db_user_present="$(mariadb --protocol=socket -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${wp_db_user}')")"
				if [[ "${db_user_present}" == "1" ]]; then
					vstacklet::shell::text::magenta::sl "Database user already exists: "
					vstacklet::shell::text::white "Using previously created database ${wp_db_user} user."
					[[ -n "${mysql_user}" ]] && wp_db_user="${mysql_user}"
					[[ -n "${mariadb_user}" ]] && wp_db_user="${mariadb_user}"
					#break
				fi
				# @script-note: check if WordPress database user is empty
				[[ -z ${wp_db_user} ]] && vstacklet::shell::text::error "WordPress database user cannot be empty." && vstacklet::shell::text::white::sl "WordPress database user: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress database password
		vstacklet::wp::password() {
			# @script-note: check if user_exists is set, if so, use current password
			if [[ "${db_user_present}" == "1" ]]; then
				vstacklet::shell::text::magenta::sl "Database user already exists: "
				vstacklet::shell::text::white "Using previously created database password for ${wp_db_user}."
				[[ -n "${mysql_password}" ]] && wp_db_password="${mysql_password}"
				[[ -n "${mariadb_password}" ]] && wp_db_password="${mariadb_password}"
			else
				vstacklet::shell::text::white::sl "WordPress database password: "
				vstacklet::shell::icon::arrow::white
				while read -r wp_db_password; do
					[[ ! ${wp_db_password} =~ ^[A-Za-z0-9!#%*+,.:\;=?@^_~-]{8,128}$ ]] && vstacklet::shell::text::error "use 8 to 128 letters, digits or !#%*+,.:;=?@^_~- (no quotes, spaces or slashes)." && vstacklet::shell::text::white::sl "WordPress database password: " && vstacklet::shell::icon::arrow::white && continue
					break
				done
			fi
		}
		# @script-note: get WordPress Site URL
		vstacklet::wp::site_url() {
			if [[ -n ${domain} ]]; then
				wp_site_url="https://${domain}"
			else
				wp_site_url="https://${server_ip}"
			fi
		}
		# @script-note: get WordPress Site Title
		vstacklet::wp::site_title() {
			vstacklet::shell::text::white::sl "WordPress Site Title: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_site_title; do
				[[ -z ${wp_site_title} ]] && vstacklet::shell::text::error "WordPress Site Title cannot be empty." && vstacklet::shell::text::white::sl "WordPress Site Title: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress Admin Username
		vstacklet::wp::admin_user() {
			vstacklet::shell::text::white::sl "WordPress Admin Username: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_admin_user; do
				[[ -z ${wp_admin_user} ]] && vstacklet::shell::text::error "WordPress Admin Username cannot be empty." && vstacklet::shell::text::white::sl "WordPress Admin Username: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress Admin Password
		vstacklet::wp::admin_password() {
			vstacklet::shell::text::white::sl "WordPress Admin Password: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_admin_password; do
				[[ -z ${wp_admin_password} ]] && vstacklet::shell::text::error "WordPress Admin Password cannot be empty." && vstacklet::shell::text::white::sl "WordPress Admin Password: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: get WordPress Admin Email
		vstacklet::wp::admin_email() {
			vstacklet::shell::text::white::sl "WordPress Admin Email: "
			vstacklet::shell::icon::arrow::white
			while read -r wp_admin_email; do
				[[ -z ${wp_admin_email} ]] && vstacklet::shell::text::error "WordPress Admin Email cannot be empty." && vstacklet::shell::text::white::sl "WordPress Admin Email: " && vstacklet::shell::icon::arrow::white && continue
				break
			done
		}
		# @script-note: call Wordpress information functions
		vstacklet::wp::db
		vstacklet::wp::user
		vstacklet::wp::password
		vstacklet::wp::site_url
		vstacklet::wp::site_title
		vstacklet::wp::admin_user
		vstacklet::wp::admin_password
		vstacklet::wp::admin_email
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white::sl "Are the entered details correct? "
		vstacklet::shell::text::green::sl "[y]"
		vstacklet::shell::text::white::sl "es"
		vstacklet::shell::text::white::sl " or "
		vstacklet::shell::text::red::sl "[n]"
		vstacklet::shell::text::white::sl "o: "
		vstacklet::shell::icon::arrow::white
		read -r wp_input
		# @script-note: while loop to check if entered details are correct, if not, repeat
		while [[ ${wp_input,,} =~ ^(no|n)$ ]]; do
			vstacklet::wp::db
			vstacklet::wp::user
			vstacklet::wp::password
			vstacklet::wp::site_url
			vstacklet::wp::site_title
			vstacklet::wp::admin_user
			vstacklet::wp::admin_password
			vstacklet::wp::admin_email
			vstacklet::shell::misc::nl
			vstacklet::shell::text::white::sl "Are the entered details correct? "
			vstacklet::shell::text::green::sl "[y]"
			vstacklet::shell::text::white::sl "es"
			vstacklet::shell::text::white::sl " or "
			vstacklet::shell::text::red::sl "[n]"
			vstacklet::shell::text::white::sl "o: "
			vstacklet::shell::icon::arrow::white
			read -r wp_input
		done
		vstacklet::shell::misc::nl
		[[ ${wp_input,,} =~ ^(yes|y)$ ]] && declare wp_input_continue="true"
		if [[ ${wp_input_continue} == "true" ]]; then
			vstacklet::shell::text::white "installing and configuring WordPress ... "
			# @script-note: download WordPress
			vstacklet::log curl -fsSL --proto '=https' -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz || vstacklet::error::display 96
			wp_sum="$(curl -fsSL --proto '=https' https://wordpress.org/latest.tar.gz.sha1)" || vstacklet::error::display 96
			[[ ${wp_sum} =~ ^[0-9a-f]{40}$ && $(sha1sum /tmp/wordpress.tar.gz | cut -d' ' -f1) == "${wp_sum}" ]] || { declare -g vstacklet_failed_step="the WordPress download does not match wordpress.org's published checksum"; vstacklet::error::display log; }
			# @script-note: extract WordPress
			vstacklet::log tar -xzf /tmp/wordpress.tar.gz -C /tmp || vstacklet::error::display 97
			# @script-note: move WordPress to the web root
			mv /tmp/wordpress/* "${web_root:-/var/www/html/vsapp}/public" || vstacklet::error::display 98
			# @script-note: create the uploads directory
			mkdir -p "${web_root:-/var/www/html/vsapp}/public/wp-content/uploads" || vstacklet::error::display 99
			# @script-note: download the WordPress CLI
			# @script-note: wp-cli 2.12.0, checked against the SHA-512 published with the release (read 2026-11-24)
			vstacklet::log curl -fsSL --proto '=https' -o /usr/local/bin/wp.new https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar
			[[ $(sha512sum /usr/local/bin/wp.new | cut -d' ' -f1) == "be928f6b8ca1e8dfb9d2f4b75a13aa4aee0896f8a9a0a1c45cd5d2c98605e6172e6d014dda2e27f88c98befc16c040cbb2bd1bfa121510ea5cdf5f6a30fe8832" ]] || { rm -f /usr/local/bin/wp.new; declare -g vstacklet_failed_step="the wp-cli download does not match its published SHA-512"; vstacklet::error::display log; }
			vstacklet::log mv -f /usr/local/bin/wp.new /usr/local/bin/wp
			# @script-note: set the correct permissions
			vstacklet::log chmod +x /usr/local/bin/wp
			vstacklet::shell::text::yellow::sl "configuring WordPress ... " &
			vs::stat::progress::start # @script-note: start progress status
			# @script-note: create the wp-config.php file
			vstacklet::log cp -f "${web_root:-/var/www/html/vsapp}/public/wp-config-sample.php" "${web_root:-/var/www/html/vsapp}/public/wp-config.php" || vstacklet::error::display 100
			# @script-note: modify the wp-config.php file
			sed -i \
				-e "s/database_name_here/${wp_db_name}/g" \
				-e "s/username_here/${wp_db_user}/g" \
				-e "s/password_here/${wp_db_password}/g" \
				"${web_root:-/var/www/html/vsapp}/public/wp-config.php" || vstacklet::error::display 101
			# @script-note: remove old salt keys
			sed -i -e "/define( 'AUTH_KEY',/d" -e "/define( 'SECURE_AUTH_KEY',/d" -e "/define( 'LOGGED_IN_KEY',/d" -e "/define( 'NONCE_KEY',/d" -e "/define( 'AUTH_SALT',/d" -e "/define( 'SECURE_AUTH_SALT',/d" -e "/define( 'LOGGED_IN_SALT',/d" -e "/define( 'NONCE_SALT',/d" "${web_root:-/var/www/html/vsapp}/public/wp-config.php"
			# @script-note: import updated salt keys
			wp_salts=$(curl -fsSL --proto '=https' https://api.wordpress.org/secret-key/1.1/salt/)
			[[ $(grep -c "define(" <<<"${wp_salts}") -eq 8 ]] || { declare -g vstacklet_failed_step="could not fetch fresh WordPress salts"; vstacklet::error::display log; }
			sed -i "/#@-/r /dev/stdin" "${web_root:-/var/www/html/vsapp}/public/wp-config.php" <<<"${wp_salts}"
			# @script-note: add security constants to wp-config.php (disable the file editor)
			sed -i "/Add any custom values between this line and the \"stop editing\" line./a \\\n/**\n * The plugins and themes file editor is a very convenient tool because it\n * enables you to make quick changes without the need to use FTP.\n *\n * Unfortunately, it's also a security issue because it not only shows the\n * PHP source code, it also enables attackers to inject malicious code into\n * your site if they manage to gain access to admin.\n * To prevent this, you can disable the file editor.\n *\n * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#disable-the-plugin-and-theme-file-editor\n */\n\ndefine('DISALLOW_FILE_EDIT', true);\n" "${web_root:-/var/www/html/vsapp}/public/wp-config.php"
			# @script-note: create the database
			mariadb --protocol=socket -e "CREATE DATABASE \`${wp_db_name}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >>"${vslog}" 2>&1 || vstacklet::error::display 102
			if [[ "${db_user_present}" != "1" ]]; then
				# @script-note: create the database user
				mariadb --protocol=socket -e "CREATE USER '${wp_db_user}'@'localhost' IDENTIFIED BY '${wp_db_password}';" >>"${vslog}" 2>&1 || vstacklet::error::display 103
			fi
			# @script-note: grant privileges to the database user
			mariadb --protocol=socket -e "GRANT ALL PRIVILEGES ON \`${wp_db_name}\`.* TO '${wp_db_user}'@'localhost';" >>"${vslog}" 2>&1 || vstacklet::error::display 104
			# @script-note: flush privileges
			mariadb --protocol=socket -e "FLUSH PRIVILEGES;" >>"${vslog}" 2>&1 || vstacklet::error::display 105
			# @script-note: remove the WordPress installation files
			vstacklet::log rm -rf /tmp/wordpress /tmp/wordpress.tar.gz || vstacklet::error::display 106
			# @script-note: run wp core install
			wp --path="${web_root:-/var/www/html/vsapp}/public" core install --url="${wp_site_url}" --title="${wp_site_title}" --admin_user="${wp_admin_user}" --admin_password="${wp_admin_password}" --admin_email="${wp_admin_email}" --allow-root >>"${vslog}" 2>&1 || vstacklet::error::display 107
			vs::stat::progress::stop # stop progress status
			if [[ -n ${varnish} ]]; then
				vstacklet::shell::text::yellow::sl "installing Proxy Cache Purge plugin ... " &
				# @script-note: if varnish is installed, install the varnish-http-purge plugin and activate it
				wp --path="${web_root:-/var/www/html/vsapp}/public" plugin install varnish-http-purge --activate --allow-root >>"${vslog}" 2>&1 || vstacklet::error::display 108
				vs::stat::progress::stop # stop progress status
			fi
			# @script-note: wordpress installation complete
			vstacklet::shell::text::green "WordPress installed and configured. see details below:"
			vstacklet::shell::text::white::sl "WordPress Database Name: "
			vstacklet::shell::text::green "${wp_db_name}"
			vstacklet::shell::text::white::sl "WordPress Database User: "
			vstacklet::shell::text::green "${wp_db_user}"
			vstacklet::shell::text::white::sl "WordPress Database Password: "
			vstacklet::shell::text::green "${wp_db_password}"
			vstacklet::shell::text::white::sl "WordPress Admin User: "
			vstacklet::shell::text::green "${wp_admin_user}"
			vstacklet::shell::text::white::sl "WordPress Admin Password: "
			vstacklet::shell::text::green "${wp_admin_password}"
			vstacklet::shell::text::white::sl "WordPress Admin Email: "
			vstacklet::shell::text::green "${wp_admin_email}"
			vstacklet::shell::text::white::sl "Login to your WordPress installation at: "
			vstacklet::shell::text::green "https://${domain:-${server_ip}}/wp-login.php"
			# @script-note: adjust web root permissions
			vstacklet::permissions::adjust
		fi
	fi
}
