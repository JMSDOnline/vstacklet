#!/usr/bin/env bash
# vStacklet installer module: nginx. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::nginx::install (25)
# @description: Install NGinx and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L1601-L1709)
#
# notes:
# - The following profiles are included:
#   - Location profiles
#     - cache-busting
#     - cross-domain-fonts
#     - expires
#     - protect-system-files
#     - letsencrypt
#   - Security profiles
#     - ssl
#     - cloudflare-real-ip
#     - common-exploit-prevention
#     - mime-type-security
#     - reflected-xss-prevention
#     - sec-bad-bots
#     - sec-file-injection
#     - sec-php-easter-eggs
#     - server-security-options
#     - socket-settings
# - These config can be found at [/etc/nginx/server.configs/](https://github.com/JMSDOnline/vstacklet/tree/main/config/nginx/server.configs)
# @option: $1 - `-nginx | --nginx` (optional) (takes no arguments)
# @example: vstacklet -nginx
# @example: vstacklet --nginx
# @example: vstacklet -nginx -php 8.4 -varnish -varnishP 80 -http 8080 -https 443
# @example: vstacklet --nginx --php 8.4 --varnish --varnishP 80 --http 8080 --https 443
# @null
# @return_code: 21 - failed to edit NGINX configuration file.
# @return_code: 22 - failed to enable NGINX configuration file.
# @return_code: 23 - failed to generate dhparam file.
# @return_code: 24 - failed to generate self-signed certificate.
# @return_code: 25 - failed to create the web root's public folder.
# @break
##################################################################################
vstacklet::nginx::install() {
	if [[ -n ${nginx} ]]; then
		vstacklet::shell::misc::nl
		vstacklet::shell::text::white "configuring nginx ... "
		# @script-note: install nginx dependencies
		# @script-note: nginx (from nginx.org) is installed by vstacklet::packages::install
		vstacklet::log systemctl stop nginx
		mkdir -p "${local_setup_dir}/nginx/temp"
		[[ -f /etc/nginx/nginx.conf ]] && mv -f /etc/nginx/nginx.conf "${local_setup_dir}/nginx/temp/nginx.conf"
		[[ -f /etc/nginx/sites-enabled/default ]] && mv -f /etc/nginx/sites-enabled/default "${local_setup_dir}/nginx/temp/default"
		mv /etc/nginx /etc/nginx-pre-vstacklet
		mkdir -p /etc/nginx/{conf.d,cache,ssl,sites-enabled,sites-available}
		sed -i "s|{{server_ip}}|${server_ip}|g" "${local_nginx_dir}/server.configs/directives/cloudflare-real-ip.conf"
		wr_sanitize=$(echo "${web_root:-/var/www/html/vsapp}" | sed 's/\//\\\//g')
		sed -i "s|{{webroot}}|${wr_sanitize}|g" "${local_nginx_dir}/server.configs/location/letsencrypt.conf"
		sleep 3
		rsync -aP --exclude=LICENSE --exclude=README --exclude=.git "${local_nginx_dir}"/* /etc/nginx/ >/dev/null 2>&1
		\cp -rf /etc/nginx-pre-vstacklet/uwsgi_params /etc/nginx-pre-vstacklet/fastcgi_params /etc/nginx/
		chown -R www-data:www-data /etc/nginx/cache
		chmod -R 755 /etc/nginx/cache
		sh -c 'find /etc/nginx -type f -exec chmod 644 {} \;'
		chmod -R g+rw /etc/nginx/cache
		sh -c 'find /etc/nginx/cache -type d -print0 | sudo xargs -0 chmod g+s'
		# @script-note: import nginx reverse config files from vStacklet
		if [[ ${php} == *"8"* ]]; then
			[[ -z ${varnish} ]] && cp -f "${local_php8_dir}/nginx/default.php8.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
			# @script-note: import nginx reverse modified for varnish and nginx ssl termination
			[[ -n ${varnish} ]] && cp -f "${local_php8_dir}/nginx/varnish/default.php8.conf" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		fi
		vstacklet::shell::text::yellow::sl "configuring NGinx and generating self-signed certificates ... " &
		vs::stat::progress::start # start progress status
		# @script-note: post necessary edits to nginx config files
		sed -i "s|{{php}}|${php:-${DEFAULT_PHP}}|g" "/etc/nginx/wordpress.conf" >/dev/null 2>&1
		if [[ -z ${varnish} ]]; then
			sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{domain}}|${domain:-${hostname:-vs-site1}}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-${DEFAULT_PHP}}|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" || vstacklet::error::display 21
		fi
		if [[ -n ${varnish} ]]; then
			sed -i.bak -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{varnish_port}}|${varnish_port:-6081}|g" -e "s|{{domain}}|${domain:-${hostname:-vs-site1}}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-${DEFAULT_PHP}}|g" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" || vstacklet::error::display 21
		fi
		# @script-note: enable site
		ln -sf "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" "/etc/nginx/sites-enabled/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1 || vstacklet::error::display 22
		# @script-note: generate Diffie-Hellman parameters file and self-signed ssl cert
		if [[ ! -f /etc/nginx/ssl/dhparam.pem ]]; then
			openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 >>"${vslog}" 2>&1 || vstacklet::error::display 23
		fi
		if [[ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]]; then
			openssl req -config "${vstacklet_base_path}/setup/templates/ssl/openssl.conf" -x509 -nodes -days 720 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem >>"${vslog}" 2>&1 || vstacklet::error::display 24
		fi
		vs::stat::progress::stop # stop progress status
		vstacklet::shell::text::yellow::sl "adjusting permissions on ${web_root:-/var/www/html/vsapp} ... " &
		vs::stat::progress::start # start progress status
		# Create the public directory if it doesn't exist
		mkdir -p "${web_root:-/var/www/html/vsapp}/public" || vstacklet::error::display 25
		# @script-note: no public phpinfo() page: it showed the server's full PHP and environment details to anyone
		chown -R www-data:www-data "${web_root:-/var/www/html/vsapp}"
		chmod -R 755 "${web_root:-/var/www/html/vsapp}"
		chmod -R g+rw "${web_root:-/var/www/html/vsapp}"
		sh -c "find ${web_root:-/var/www/html/vsapp} -type d -print0 | sudo xargs -0 chmod g+s"
		# @script-note: if wordpress option is enabled, edit nginx config file to include wordpress specific directives
		# no need to log this one as it's not a critical step (helpful, but not critical)
		[[ -n ${wordpress} && -z ${varnish} ]] && sed -i -e '/# include wordpress.conf;/s/#//' -e '/# include restrictions.conf;/s/#//' "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		# @dev-note: if varnish option is enabled, comment out location / block from /etc/nginx/wordpress.conf file (archived for reference)
		#[[ -n ${varnish} ]] && sed -i '/location \/ {/,/}/s/^/#/' /etc/nginx/wordpress.conf
		# @dev-note: if varnish option is disabled, remove location / block from /etc/nginx/wordpress.conf file (archived for reference)
		#[[ -n ${varnish} ]] && sed -i '/location \/ {/,/}/d' /etc/nginx/wordpress.conf
		# @script-note: set override for nginx pid file
		mkdir -p /etc/systemd/system/nginx.service.d >/dev/null 2>&1
		printf "[Service]\nExecStartPost=/bin/sleep 1\n" >"/etc/systemd/system/nginx.service.d/override.conf"
		vstacklet::log systemctl daemon-reload && vstacklet::log systemctl restart nginx
		vs::stat::progress::stop # stop progress status
		# @script-note: nginx installation complete
		vstacklet::shell::text::green "NGinx and self-signed certificates installed and configured. see details below:"
		vstacklet::shell::text::white::sl "NGinx config file: "
		vstacklet::shell::text::green "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf"
		vstacklet::shell::text::white::sl "self-signed ssl cert: "
		vstacklet::shell::text::green "/etc/ssl/certs/ssl-cert-snakeoil.pem"
		vstacklet::shell::text::white::sl "self-signed ssl key: "
		vstacklet::shell::text::green "/etc/ssl/private/ssl-cert-snakeoil.key"
		vstacklet::shell::text::white::sl "Diffie-Hellman parameters file: "
		vstacklet::shell::text::green "/etc/nginx/ssl/dhparam.pem"
	fi
}
