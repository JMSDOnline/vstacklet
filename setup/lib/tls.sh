#!/usr/bin/env bash
# vStacklet installer module: tls. Sourced by setup/vstacklet-server-stack.sh through its loader; defines functions only, nothing runs at load time.
# shellcheck shell=bash disable=1091,2034,2068,2119,2154,2249,2312,2317

##################################################################################
# @name: vstacklet::cloudflare::token::setup (37)
# @description: Setup CloudFlare API token for DNS verification. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3145-L3175)
#
# notes:
# - This function prompts the user for their CloudFlare API token
# - Stores the token in the acme.sh account configuration
# - Required for DNS-based SSL certificate verification with CloudFlare
# - Must be called AFTER acme.sh installation to prevent account.conf overwrite
#
# @nooptions
# @noargs
# @return_code: 121 - failed to write CloudFlare token to account.conf.
# @break
##################################################################################
vstacklet::cloudflare::token::setup() {
	if [[ -n ${cf_token_required} ]]; then
		vstacklet::shell::misc::nl
		vstacklet::shell::text::yellow "CloudFlare DNS verification requires an API token."
		vstacklet::shell::text::white "Please create a CloudFlare API token with the following permissions:"
		vstacklet::shell::text::white "  - Zone:Zone:Read"
		vstacklet::shell::text::white "  - Zone:DNS:Edit"
		vstacklet::shell::text::white "Visit: https://dash.cloudflare.com/profile/api-tokens"
		vstacklet::shell::misc::nl

		read -rp "Enter your CloudFlare API Token: " CF_Token
		[[ -z ${CF_Token} ]] && vstacklet::shell::text::error "CloudFlare API token is required for DNS verification." && exit 1

		# Verify acme.sh config directory exists (should be created by acme.sh installation)
		if [[ ! -d "/root/.acme.sh" ]]; then
			vstacklet::shell::text::error "acme.sh configuration directory not found. This should not happen." && exit 1
		fi

		# Store the CloudFlare token in account.conf
		echo "CF_Token='${CF_Token}'" >>"/root/.acme.sh/account.conf" || vstacklet::error::display 121

		vstacklet::shell::text::success "CloudFlare API token configured successfully."
		vstacklet::shell::misc::nl
	fi
}

##################################################################################
# @name: vstacklet::domain::ssl (38)
# @description: The following function installs the SSL certificate
#   for the domain. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet-server-stack.sh#L3173-L3236)
#
# notes:
# - This function is only called under the following conditions:
#   - the option for `-d` is used (optional)
# - The following options are required for this function:
#   - `-d` or `--domain`
#   - `-e` or `--email`
# - The following options are optional for this function:
#   - `-http` or `--http`
#   - `-https` or `--https`
# - If you are using a custom port for HTTP and/or HTTPS, you can specify the port(s) using the `-http` and `-https` options.
# > [!TIP]
# > this is especially useful if you are using a reverse proxy like Varnish with Nginx.
# - The `-http` option is used to specify the custom port for HTTP.
# - The `-https` option is used to specify the custom port for HTTPS.
# @option: $1 - `-d | --domain` - The domain to install the SSL certificate for.
# @arg: $1 - `[domain]` (required)
# @option: $1 - `-e | --email` - The email address to use for the SSL certificate.
# @arg: $1 - `[email]` (required)
# @option: $1 - `--dns` - DNS provider for DNS-based verification (optional)
# @arg: $1 - `[dns_provider]` (optional, currently supports 'cloudflare')
# @option: $1 - `-http` (optional)
# @arg: $1 - `[http_port]` (optional)
# @option: $1 - `-https` (optional)
# @arg: $1 - `[https_port]` (optional)
# @example: vstacklet -nginx -d "example.com" -e "your@email.com"
# vstacklet --nginx --domain example.com --email "your@email.com"
# vstacklet -d "example.com" -e "your@email.com" -http "8080"
# vstacklet -d "example.com" -e "your@email.com" --dns "cloudflare"
# @null
# @return_code: 109 - failed to change directory to /root.
# @return_code: 110 - failed to create directory ${web_root}/.well-known/acme-challenge.
# @return_code: 111 - failed to clone acme.sh.
# @return_code: 112 - failed to switch to /root/acme.sh directory.
# @return_code: 113 - failed to install acme.sh.
# @return_code: 114 - failed to reload nginx.
# @return_code: 115 - failed to register the account with Let's Encrypt.
# @return_code: 116 - failed to set the default CA to Let's Encrypt.
# @return_code: 117 - failed to issue the certificate.
# @return_code: 118 - failed to install the certificate.
# @return_code: 119 - failed to edit /etc/nginx/sites-available/${domain}.conf.
# @return_code: 121 - failed to write CloudFlare token to account.conf.
# @break
##################################################################################
vstacklet::domain::ssl() {
	if [[ -n ${domain_ssl} ]]; then
		# @script-note: signal a service daemon reload and restart nginx
		[[ -f /run/nginx.pid ]] && rm -f /run/nginx.pid
		systemctl daemon-reload >>"${vslog}" 2>&1
		[[ -n ${varnish} ]] && systemctl restart varnish >>"${vslog}" 2>&1
		systemctl restart nginx >>"${vslog}" 2>&1
		# @script-note: testing:
		systemctl status nginx >>"${vslog}" 2>&1
		sleep 3
		vstacklet::shell::misc::nl
		if [[ -n ${dns_verification} ]]; then
			vstacklet::shell::text::white "installing SSL certificate for ${domain} using DNS verification ... "
		else
			vstacklet::shell::text::white "installing SSL certificate for ${domain} using HTTP verification ... "
		fi

		# @script-note: build acme.sh for Let's Encrypt SSL
		cd "/root" || vstacklet::error::display 109
		[[ -d "/root/.acme.sh" ]] && rm -rf "/root/.acme.sh" >>"${vslog}" 2>&1

		# @script-note: Only create webroot directories for HTTP verification
		if [[ -z ${dns_verification} ]]; then
			mkdir -p "${web_root:-/var/www/html/vsapp}/.well-known/acme-challenge" || vstacklet::error::display 110
			chown -R root:www-data "${web_root:-/var/www/html/vsapp}/.well-known" >>"${vslog}" 2>&1
			chmod -R 755 "${web_root:-/var/www/html/vsapp}/.well-known" >>"${vslog}" 2>&1
		fi

		if [[ ! -d "/root/acme.sh" ]]; then
			git clone "https://github.com/Neilpang/acme.sh.git" >>"${vslog}" 2>&1 || vstacklet::error::display 111
			cd "/root/acme.sh" || vstacklet::error::display 112
			./acme.sh --install --home "/root/.acme.sh" >>"${vslog}" 2>&1 || vstacklet::error::display 113
		else
			cd "/root/acme.sh" || vstacklet::error::display 112
		fi

		# @script-note: Setup CloudFlare token AFTER acme.sh installation to prevent overwriting
		[[ -n ${dns_verification} ]] && vstacklet::cloudflare::token::setup

		# @script-note: create nginx directory for SSL
		mkdir -p "/etc/nginx/ssl/${domain:?}"

		# @script-note: Only create nginx acme config for HTTP verification
		if [[ -z ${dns_verification} ]]; then
			# @script-note: create SSL certificate
			cp -f "${local_setup_dir}/templates/nginx/acme" "/etc/nginx/sites-enabled/"
			# @script-note: post necessary edits to nginx acme file
			wr_sanitize=$(echo "${web_root:-/var/www/html/vsapp}" | sed 's/\//\\\//g')
			sed -i -e "s|{{domain}}|${domain}|g" -e "s|{{http_port}}|${http_port:-80}|g" -e "s|{{https_port}}|${https_port:-443}|g" -e "s|{{webroot}}|${wr_sanitize}|g" -e "s|{{php}}|${php:-${DEFAULT_PHP}}|g" /etc/nginx/sites-enabled/acme
			systemctl reload nginx.service >>"${vslog}" 2>&1 || vstacklet::error::display 114
		fi

		./acme.sh --register-account -m "${email:?}" >>"${vslog}" 2>&1 || vstacklet::error::display 115
		./acme.sh --set-default-ca --server letsencrypt >>"${vslog}" 2>&1 || vstacklet::error::display 116

		# @script-note: Issue certificate using appropriate verification method
		if [[ -n ${dns_verification} && ${dns_provider} == "cloudflare" ]]; then
			# DNS verification with CloudFlare
			./acme.sh --issue -d "${domain}" --dns dns_cf --server letsencrypt --debug >>"${vslog}" 2>&1 || vstacklet::error::display 117
		else
			# HTTP verification (default)
			./acme.sh --issue -d "${domain}" -w "${web_root:-/var/www/html/vsapp}" --server letsencrypt --debug >>"${vslog}" 2>&1 || vstacklet::error::display 117
		fi

		./acme.sh --install-cert -d "${domain}" --keylength ec-256 --cert-file "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" --key-file "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" --fullchain-file "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" --log "/var/log/vstacklet/${domain}.log" --reloadcmd "systemctl reload nginx.service" >>"${vslog}" 2>&1 || vstacklet::error::display 118
		# @script-note: post necessary edits to nginx config file
		crt_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" | sed 's/\//\\\//g')
		key_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-privkey.pem" | sed 's/\//\\\//g')
		#chn_sanitize=$(echo "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem" | sed 's/\//\\\//g')
		[[ -f "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" ]] && cp -f "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" "${vstacklet_base_path:?}/config/system/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1
		# @script-note: place generated ssl to nginx config file
		sed -i.bak -e "/ssl_certificate .*/c\        ssl_certificate ${crt_sanitize};" -e "/ssl_certificate_key .*/c\        ssl_certificate_key ${key_sanitize};" "/etc/nginx/sites-available/${domain:-${hostname:-vs-site1}}.conf" >>"${vslog}" 2>&1 || vstacklet::error::display 119
		# @script-note: remove acme ssl template (only if HTTP verification was used)
		[[ -f "/etc/nginx/sites-enabled/acme" ]] && rm -f "/etc/nginx/sites-enabled/acme" >>"${vslog}" 2>&1
		# @script-note: ssl installation complete
		if [[ -n ${dns_verification} ]]; then
			vstacklet::shell::text::green "Let's Encrypt SSL certificate installed for ${domain} using DNS verification! see details below:"
		else
			vstacklet::shell::text::green "Let's Encrypt SSL certificate installed for ${domain} using HTTP verification! see details below:"
		fi
		vstacklet::shell::text::white::sl "SSL certificate location: "
		vstacklet::shell::text::green "/etc/nginx/ssl/${domain}/${domain}-ssl.pem"
		vstacklet::shell::text::white::sl "SSL certificate key location: "
		vstacklet::shell::text::green "/etc/nginx/ssl/${domain}/${domain}-privkey.pem"
		vstacklet::shell::text::white::sl "SSL certificate chain location: "
		vstacklet::shell::text::green "/etc/nginx/ssl/${domain}/${domain}-fullchain.pem"
		vstacklet::shell::text::white::sl "SSL certificate log location: "
		vstacklet::shell::text::green "/var/log/vstacklet/${domain}.log"
		vstacklet::shell::text::white::sl "SSL certificate renewal command: "
		vstacklet::shell::text::green "/root/.acme.sh/acme.sh --renew -d ${domain} --force"
		vstacklet::shell::text::white::sl "SSL certificate renewal cronjob: "
		vstacklet::shell::text::green "0 0 * * * /root/.acme.sh/acme.sh --cron --home /root/.acme.sh >> /var/log/vstacklet/${domain}.log"
		vstacklet::shell::text::white::sl "SSL certificate expiration date: "
		vstacklet::shell::text::green "$(openssl x509 -in "/etc/nginx/ssl/${domain}/${domain}-ssl.pem" -noout -enddate | cut -d= -f2)"
	fi
}
