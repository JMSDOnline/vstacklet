#!/bin/bash
server_ip=$(ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1);
sitename=$(hostname -s);

echo '[vstacklet] Varnish LEMP Stack Installation'
echo 'Configured for Ubuntu 14.04.'
echo 'Installs Nginx, Varnish, MariaDB, PHP-FPM, Sendmail, and CSF.'
echo
read -p 'Do you want to continue? [y/N] ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo 'Exiting...'
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo 'This script must be run with root privileges.' 1>&2
   exit 1
fi

# Update packages and add MariaDB repository
echo -e '\n[Package Updates]'
apt-get install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main'
echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx-mainline-trusty.list
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx-mainline-trusty.list
curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -
curl http://nginx.org/keys/nginx_signing.key | apt-key add -
apt-get update
apt-get -y upgrade

# Depencies and pip
echo -e '\n[Dependencies]'
apt-get -y install build-essential debconf-utils python-dev libpcre3-dev libssl-dev python-pip libwww-perl

# Nginx
echo -e '\n[Nginx]'
apt-get -y install nginx
service nginx stop
mv /etc/nginx /etc/nginx-previous
curl -L https://github.com/JMSDOnline/server-configs-nginx/archive/1.0.0.tar.gz | tar -xz
mv server-configs-nginx-1.0.0 /etc/nginx
cp /etc/nginx-previous/uwsgi_params /etc/nginx-previous/fastcgi_params /etc/nginx
sed -i.bak -e
sed -i.bak -e "s/www www/www-data www-data/" \
  -e "s/logs\/error.log/\/var\/log\/nginx\/error.log/" \
  -e "s/logs\/access.log/\/var\/log\/nginx\/access.log/" /etc/nginx/nginx.conf
sed -i.bak -e "s/logs\/static.log/\/var\/log\/nginx\/static.log/" /etc/nginx/h5bp/location/expires.conf

echo
read -p 'Do you want to create a self-signed SSL cert and configure HTTPS? [y/N] ' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  conf1="  listen [::]:443 ssl http2;\n  listen *:443 ssl http2;\n"
  conf2="  include h5bp/directive-only/ssl.conf;\n  ssl_certificate /etc/ssl/certs/$sitename.crt;\n  ssl_certificate_key /etc/ssl/private/$sitename.key;"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/private/$sitename.key -out /etc/ssl/nginx/certs/$sitename.crt
  chmod 400 /etc/ssl/nginx/private/$sitename.key
else
  conf1=
  conf2=
  conf3=
fi

echo -e "server {
    listen *:8080;
    $conf1
    server_name $sitename;

    access_log /srv/www/$sitename_access.log;
    error_log /srv/www/$sitename_error.log;

    $conf2
    root /var/www/$sitename/public;
    index index.html index.htm index.php;

location ~ [^/]\.php(/|$) {
    # Zero-day exploit defense.
    # http://forum.nginx.org/read.php?2,88845,page=3
    # Won't work properly (404 error) if the file is not stored on this server, which is entirely possible with php-fpm/php-fcgi.
    # Comment the 'try_files' line out if you set up php-fpm/php-fcgi on another machine.  And then cross your fingers that you won't get hacked.
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_index index.php;
    include fcgi.conf;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    # WordPress Specific
    # include wordpress.conf;
    # include restrictions.conf;
    # We only enable this option if W3TC is in effect on a WordPress install
    # include /srv/www/$sitename/public/nginx.conf;

}" > /etc/nginx/conf.d/$sitename.conf

mkdir -p /srv/www/$sitename/app/static
mkdir -p /srv/www/$sitename/app/templates
mkdir -p /srv/www/$sitename/public
# In NginX 1.9.x the use of conf.d seems appropriate
# ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename

# Varnish
echo -e '\n[Varnish]'
apt-get install varnish
sed -i "s/127.0.0.1/$server_ip/" /etc/varnish/default.vcl
sed -i "s/6081/80/" /etc/default/varnish

# PHP
echo -e '\n[PHP-FPM]'
apt-get -y install php5-common php5-mysqlnd php5-curl php5-gd php5-cli php5-fpm php-pear php5-dev php5-imap php5-mcrypt
echo '<?php phpinfo(); ?>' > /srv/www/$sitename/public/checkinfo.php

# Permissions
echo -e '\n[Adjusting Permissions]'
chgrp -R www-data /srv/www/*
chmod -R g+rw /srv/www/*
sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'

# MariaDB
echo -e '\n[MariaDB]'
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mariadb-server
echo
service nginx restart
service varnish restart
service php5-fpm restart
echo
echo '[quick-lemp] LEMP Stack Installation Complete'

exit 0
