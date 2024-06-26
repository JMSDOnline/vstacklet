vcl 4.1;

import std;
import proxy;

backend default {
	.host = "127.0.0.1";
	.port = "{{varnish_port}}";
}

# Add hostnames, IP addresses and subnets that are allowed to purge content
acl purge {
	"localhost";
	"127.0.0.1";
	"::1";
}

sub vcl_recv {
	# Set the redirect for http to https
	# This is a workaround for the fact that Varnish doesn't support
	# https redirects. See https://varnish-cache.org/docs/trunk/phk/ssl.html
	# By default, this is commented out. Uncomment if you want to force
	# all traffic to https. Keep in mind the redirect should already be
	# handled by your web server. This is just a fallback should you
	# want to force https at the Varnish level.
	#
	#if ((req.http.X-Forwarded-Proto && req.http.X-Forwarded-Proto != "https") || (req.http.Scheme && req.http.Scheme != "https")) {
	#	return (synth(750));
	#} elseif (!req.http.X-Forwarded-Proto && !req.http.Scheme && !proxy.is_ssl()) {
	#	return (synth(750));
	#}

	# Remove empty query string parameters
	# e.g.: www.example.com/index.html?
	if (req.url ~ "\?$") {
		set req.url = regsub(req.url, "\?$", "");
	}

	# Remove port number from host header
	set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

	# Sorts query string parameters alphabetically for cache normalization purposes
	set req.url = std.querysort(req.url);

	# Remove the proxy header to mitigate the httpoxy vulnerability
	# See https://httpoxy.org/
	unset req.http.proxy;

	# Add X-Forwarded-Proto header when using https
	if (!req.http.X-Forwarded-Proto) {
		if(std.port(server.ip) == 443 || std.port(server.ip) == 8443) {
			set req.http.X-Forwarded-Proto = "https";
		} else {
			set req.http.X-Forwarded-Proto = "http";
		}
	}

	# Purge logic to remove objects from the cache.
	# Tailored to the Proxy Cache Purge WordPress plugin
	# See https://wordpress.org/plugins/varnish-http-purge/
	if(req.method == "PURGE") {
		if(!client.ip ~ purge) {
			return(synth(405,"PURGE not allowed for this IP address"));
		}
		if (req.http.X-Purge-Method == "regex") {
			ban("obj.http.x-url ~ " + req.url + " && obj.http.x-host == " + req.http.host);
			return(synth(200, "Purged"));
		}
		ban("obj.http.x-url == " + req.url + " && obj.http.x-host == " + req.http.host);
		return(synth(200, "Purged"));
	}

	# Only handle relevant HTTP request methods
	if (
		req.method != "GET" &&
		req.method != "HEAD" &&
		req.method != "PUT" &&
		req.method != "POST" &&
		req.method != "PATCH" &&
		req.method != "TRACE" &&
		req.method != "OPTIONS" &&
		req.method != "DELETE"
	) {
		return (pipe);
	}

	# Remove tracking query string parameters used by analytics tools
	if (req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=") {
		set req.url = regsuball(req.url, "&(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "");
		set req.url = regsuball(req.url, "\?(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "?");
		set req.url = regsub(req.url, "\?&", "?");
		set req.url = regsub(req.url, "\?$", "");
	}

	# Only cache GET and HEAD requests
	if (req.method != "GET" && req.method != "HEAD") {
		set req.http.X-Cacheable = "NO:REQUEST-METHOD";
		return(pass);
	}

	# Mark static files with the X-Static-File header, and remove any cookies
	# X-Static-File is also used in vcl_backend_response to identify static files
	if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
		set req.http.X-Static-File = "true";
		unset req.http.Cookie;
		return(hash);
	}

	# No caching of special URLs, logged in users and some plugins
	if (
		req.http.Cookie ~ "wordpress_(?!test_)[a-zA-Z0-9_]+|wp-postpass|comment_author_[a-zA-Z0-9_]+|woocommerce_cart_hash|woocommerce_items_in_cart|wp_woocommerce_session_[a-zA-Z0-9]+|wordpress_logged_in_|comment_author|PHPSESSID" ||
		req.http.Authorization ||
		req.url ~ "add_to_cart" ||
		req.url ~ "edd_action" ||
		req.url ~ "nocache" ||
		req.url ~ "^/account" ||
		req.url ~ "^/addons" ||
		req.url ~ "^/bb-admin" ||
		req.url ~ "^/bb-login.php" ||
		req.url ~ "^/bb-reset-password.php" ||
		req.url ~ "^/cart" ||
		req.url ~ "^/checkout" ||
		req.url ~ "^/control.php" ||
		req.url ~ "^/dashboard" ||
		req.url ~ "^/download" ||
		req.url ~ "^/downloads" ||
		req.url ~ "^/edit-account" ||
		req.url ~ "^/edit-profile" ||
		req.url ~ "^/forgot-password" ||
		req.url ~ "^/forum" ||
		req.url ~ "^/forums" ||
		req.url ~ "^/groups" ||
		req.url ~ "^/login" ||
		req.url ~ "^/logout" ||
		req.url ~ "^/lost-password" ||
		req.url ~ "^/my-account" ||
		req.url ~ "^/my-profile" ||
		req.url ~ "^/orders" ||
		req.url ~ "^/password-reset" ||
		req.url ~ "^/product" ||
		req.url ~ "^/profile" ||
		req.url ~ "^/register" ||
		req.url ~ "^/register.php" ||
		req.url ~ "^/server-status" ||
		req.url ~ "^/signin" ||
		req.url ~ "^/signup" ||
		req.url ~ "^/stats" ||
		req.url ~ "^/wc-api" ||
		req.url ~ "^/wp-admin" ||
		req.url ~ "^/wp-admin/admin-ajax.php" ||
		req.url ~ "^/wp-admin/install.php" ||
		req.url ~ "^/wp-comments-post.php" ||
		req.url ~ "^/wp-cron.php" ||
		req.url ~ "^/wp-login.php" ||
		req.url ~ "^/wp-activate.php" ||
		req.url ~ "^/wp-mail.php" ||
		req.url ~ "^/wp-login.php" ||
		req.url ~ "^\?add-to-cart=" ||
		req.url ~ "^\?wc-api=" ||
		req.url ~ "^/preview=" ||
		req.url ~ "^/\.well-known/acme-challenge/"
	) {
		set req.http.X-Cacheable = "NO:Logged in/Got Sessions";
		if(req.http.X-Requested-With == "XMLHttpRequest") {
			set req.http.X-Cacheable = "NO:Ajax";
		}
		return(pass);
	}

	#set req.backend_hint = default.backend();  ## Set the backend that will receive the request

	if (req.url ~ "(wp-login|wp-admin|wp-json|preview=true)" ||  ## Uncacheable WordPress URLs
	req.url ~ "(cart|my-account/*|checkout|wc-api/*|addons|logout|lost-password)" || ## Uncacheable WooCommerce URLs
	req.url ~ "(remove_item|removed_item)" || ## Uncacheable WooCommerce URLs
	req.url ~ "\\?add-to-cart=" || ## Uncacheable WooCommerce URLs
	req.url ~ "\\?wc-(api|ajax)=" || ## Uncacheable WooCommerce URLs
	req.http.cookie ~ "(comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in)" || ## Uncacheable WordPress cookies
	req.method == "POST") ## Do NOT cache POST requests
	{
		set req.http.X-Send-To-Backend = 1; ## X-Send-To-Backend is a special variable that will force the request to directly go to the backend
		return(pass); ## Now send off the request and stop processing
	}

	unset req.http.Cookie; # Remove all cookies

	# Remove any cookies left
	unset req.http.Cookie; ## Intentionally duplicating this line to ensure all cookies are removed
	return(hash);
}

sub vcl_hash {
	if(req.http.X-Forwarded-Proto) {
		# Create cache variations depending on the request protocol
		hash_data(req.http.X-Forwarded-Proto);
	}
}

sub vcl_backend_response {
	# Inject URL & Host header into the object for asynchronous banning purposes
	set beresp.http.x-url = bereq.url;
	set beresp.http.x-host = bereq.http.host;

	# If we dont get a Cache-Control header from the backend
	# we default to 24h cache for all objects
	if (!beresp.http.Cache-Control) {
		set beresp.ttl = 24h;
		set beresp.grace = 1h;
		set beresp.http.X-Cacheable = "YES:Forced";
	}

	# If the file is marked as static we cache it for 1 day
	if (bereq.http.X-Static-File == "true") {
		unset beresp.http.Set-Cookie;
		set beresp.http.X-Cacheable = "YES:Forced";
		set beresp.ttl = 1d;
	}

	# Remove the Set-Cookie header when a specific Wordfence cookie is set
	if (beresp.http.Set-Cookie ~ "wfvt_|wordfence_verifiedHuman") {
		unset beresp.http.Set-Cookie;
	}

	if (beresp.http.Set-Cookie) {
		set beresp.http.X-Cacheable = "NO:Got Cookies";
	} elseif(beresp.http.Cache-Control ~ "private") {
		set beresp.http.X-Cacheable = "NO:Cache-Control=private";
	}

	# Don't cache 404 responses
	if ( beresp.status == 404 ) {
		set beresp.ttl = 30s;
	}

	if ( beresp.http.Content-Type ~ "text" )
	{
		set beresp.do_esi = true; ## Do ESI processing on text output. Used for geoip plugins etc. ## See https://varnish-cache.org/docs/7.4/users-guide/esi.html
	}

	if ( bereq.http.X-Send-To-Backend ) {
		## Our special variable again. It is here that we stop further processing of the request.
		return (deliver); ## Deliver the response to the user
	}

	unset beresp.http.Cache-Control; ## Remove the Cache-Control header. We control the cache time, not WordPress.
	unset beresp.http.Pragma; ## Yet another cache-control header

	## Set a lower TTL when caching images. HTML costs a lot more processing power than static files.
		if ( beresp.http.Content-Type ~ "image" )
	{
		set beresp.ttl = 1h; ## 1 hour TTL for images
	}
	else {
		set beresp.ttl = 24h; ## 24 hour TTL for everything else
	}
}

sub vcl_deliver {
	# Debug header
	if(req.http.X-Cacheable) {
		set resp.http.X-Cacheable = req.http.X-Cacheable;
	} elseif(obj.uncacheable) {
		if(!resp.http.X-Cacheable) {
			set resp.http.X-Cacheable = "NO:UNCACHEABLE";
		}
	} elseif(!resp.http.X-Cacheable) {
		set resp.http.X-Cacheable = "YES";
	}

	# Add the X-Cache: HIT/MISS/BYPASS header
	if (obj.hits > 0) {
		# If we had a HIT
		set resp.http.X-Cache = "HIT";
	} else {
		# If we had a MISS
		set resp.http.X-Cache = "MISS";
	}

	# Bypass variable. Signifies a hardcoded bypass
	if (req.http.X-Send-To-Backend)
	{
		## If we had a BYPASS
		set resp.http.X-Cache = "BYPASS";
	}

	# Remove the Via: Varnish header for security reasons.
	# We don't want to expose that we run Varnish.
	unset resp.http.Via;
	# Remove the X-Varnish header for security reasons.
	# This would otherwise expose the Varnish version.
	unset resp.http.X-Varnish;

	# Cleanup of headers
	unset resp.http.x-url;
	unset resp.http.x-host;
}

sub vcl_synth {
	if (resp.status == 750) {
		set resp.status = 301;
		set resp.http.location = "https://" + req.http.Host + req.url;
		set resp.reason = "Moved";
		return (deliver);
	}
}