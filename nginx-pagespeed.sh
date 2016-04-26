#!/bin/bash
if [[ "$USER" != 'root' ]]; then
	echo "Sorry, you need to run this as root"
	exit
fi

mkdir -p ~/nginx/xenial/
cd ~/nginx/xenial/

wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx_1.9.15-1~wily~vstacklet_amd64.deb
wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-dbg_1.9.15-1~wily~vstacklet_amd64.deb
wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-geoip_1.9.15-1~wily~vstacklet_amd64.deb
wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-image-filter_1.9.15-1~wily~vstacklet_amd64.deb
wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-njs_0.0.20160414.1c50334fbea6-1~xenial_amd64.deb
wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-perl_1.9.15-1~wily~vstacklet_amd64.deb
wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-xslt_1.9.15-1~wily~vstacklet_amd64.deb

dpkg -i nginx_*amd64.deb
mkdir -p /etc/nginx/ngx_pagespeed_cache
chown -R www-data:www-data /etc/nginx/ngx_pagespeed_cache
cd /etc/nginx/
sed -i '68i  pagespeed 	on;' nginx.conf
sed -i '69i  pagespeed 	FileCachePath /etc/nginx/ngx_pagespeed_cache;' nginx.conf

service nginx restart
