#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Installation Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#
server_ip=$(ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1);
sitename=$(hostname -s);
bold=$(tput bold)
normal=$(tput sgr0)
# intro function (1)
function _intro() {
cat <<!

${bold}[vstacklet] Varnish LEMP Stack Installation${normal}

Configured and tested for Ubuntu 14.04.
Installs and configures LEMP stack with support for PHP Applications.

!
read -p "${bold}Do you want to continue?[y/N]${normal} " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo 'Exiting...'
  exit 1
fi
echo
echo
echo 'Checking distribution ...'
if [ ! -x  /usr/bin/lsb_release ]; then
  echo 'You do not appear to be running Ubuntu.'
  echo 'Exiting...'
  exit 1
fi
echo "$(lsb_release -a)"
echo
dis="$(lsb_release -is)"
rel="$(lsb_release -rs)"
if [[ "${dis}" != "Ubuntu" ]]; then
  echo "${dis}: You do not appear to be running Ubuntu"
  echo 'Exiting...'
  exit 1
elif [[ ! "${rel}" =~ ("14.04") ]]; then #
  echo "${bold}${rel}:${normal} You do not appear to be running a supported Ubuntu release."
  echo 'Exiting...'
  exit 1
fi

echo 'Checking permissions...'
echo
if [[ $EUID -ne 0 ]]; then
  echo 'This script must be run with root privileges.' 1>&2
  echo 'Exiting...'
  exit 1
fi

echo "Press ENTER when you're ready to begin ... " ;read input
echo -ne "Do you wish to write to a log file (Default: \033[1mY\033[0m) "; read input
   case $input in
      [yY] | [yY][Ee][Ss] | "" ) OUTTO="/root/vstacklet.log";echo "Output is being sent to /root/vstacklet.log ... " ;;
      [nN] | [nN][Oo] ) OUTTO="/dev/null 2>&1";echo "NO output will be logged ... " ;;
   *) OUTTO="/root/vstacklet.log";echo "Output is being sent to /root/vstacklet.log ... " ;;
   esac

echo -e '\n[Starting VStacklet installation Process ...]'
echo
echo
echo
echo '                                /\                 '
echo '                               /  \                '
echo '                          ||  /    \               '
echo '                          || /______\              '
echo '                          |||        |             '
echo '                         |  |        |             '
echo '                         |  |        |             '
echo '                         |__|________|             '
echo '                         |___________|             '
echo '                         |  |        |             '
echo '                         |__|   ||   |\            '
echo '                          |||   ||   | \           '
echo '                         /|||   ||   |  \          '
echo '                        /_|||...||...|___\         '
echo '                          |||::::::::|             '
echo '                          || \::::::/              '
echo '                o /       ||  ||__||               '
echo '               /|         ||    ||                 '
echo '               / \        ||     \\_______________ '
echo '           _______________||______`--------------- '
echo

}

# system packages and repos function (2)
function _update() {
# Update packages and add MariaDB, Varnish 4, and Nginx 1.9.9 (mainline) repositories
echo -e '\n[Installing and Running System Package Updates]'
# package and repo addition (a) _install common properties_
apt-get install software-properties-common >>"${OUTTO}" 2>&1;
# package and repo addition (b) _add signed keys_
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -
curl http://nginx.org/keys/nginx_signing.key | apt-key add -
# package and repo addition (c) _add respo sources_
cat >/etc/apt/sources.list<<EOF
deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main
EOF
cat >/etc/apt/sources.list.d/varnish-cache.list<<EOF
deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0
EOF
cat >/etc/apt/sources.list.d/nginx-mainline-trusty.list<<EOF
deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx
EOF
# package and repo addition (d) _update and upgrade_
apt-get update >>"${OUTTO}" 2>&1;
apt-get -y upgrade >>"${OUTTO}" 2>&1;
echo -e '\n[... System Package Updates Completed ...]'
echo
}

# depencies and pip function (3)
function _dependencies() {
echo -e '\n[Installing & adding Dependencies]'
apt-get -y install build-essential debconf-utils python-dev libpcre3-dev libssl-dev python-pip >>"${OUTTO}" 2>&1;
echo -e '\n[... Installing & adding Dependencies Completed ...]'
echo
}

# install nginx function
function _nginx() {
echo -e '\n[Installing Nginx]'
apt-get -y install nginx >>"${OUTTO}" 2>&1;
service nginx stop >>"${OUTTO}" 2>&1;
mv /etc/nginx /etc/nginx-previous
echo '[VSC] VStacklet Server Configuration'
echo 'Currently being tested.'
echo 'Installs Optimized Nginx configurations and 1.9.9 directory structures. This is mainline and not stable.'
echo
read -p 'Do you want to continue? [y/N] ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo 'Exiting...'
  exit 1
fi
curl -L https://github.com/JMSDOnline/vstacklet-server-configs/archive/v0.1-alpha.tar.gz | tar -xz >>"${OUTTO}" 2>&1;
mv vstacklet-server-configs /etc/nginx
cp /etc/nginx-previous/uwsgi_params /etc/nginx-previous/fastcgi_params /etc/nginx
sed -i.bak -e
sed -i.bak -e "s/www www/www-data www-data/" \
  -e "s/logs\/error.log/\/var\/log\/nginx\/error.log/" \
  -e "s/logs\/access.log/\/var\/log\/nginx\/access.log/" /etc/nginx/nginx.conf
sed -i.bak -e "s/logs\/static.log/\/var\/log\/nginx\/static.log/" /etc/nginx/vstacklet/location/expires.conf

echo
read -p 'Do you want to create a self-signed SSL cert and configure HTTPS? [y/N] ' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  conf1="  listen [::]:443 ssl http2;\n  listen *:443 ssl http2;\n"
  conf2="  include vstacklet/directive-only/ssl.conf;\n  ssl_certificate /etc/ssl/certs/$sitename.crt;\n  ssl_certificate_key /etc/ssl/private/$sitename.key;"
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

mkdir -p /srv/www/$sitename/app/static >/dev/null 2>&1
mkdir -p /srv/www/$sitename/app/templates >/dev/null 2>&1
mkdir -p /srv/www/$sitename/public >/dev/null 2>&1
# In NginX 1.9.x the use of conf.d seems appropriate
# ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
echo -e '\n[... Installing Nginx Completed ...]'
echo
}

# install varnish function
function _varnish() {
echo -e '\n[Installing Varnish]'
apt-get install varnish >>"${OUTTO}" 2>&1;
sed -i "s/127.0.0.1/$server_ip/" /etc/varnish/default.vcl
sed -i "s/6081/80/" /etc/default/varnish
echo -e '\n[... Installing Nginx Completed ...]'
echo
}

# install php function
function _php() {
echo -e '\n[Installing PHP-FPM]'
apt-get -y install php5-common php5-mysqlnd php5-curl php5-gd php5-cli php5-fpm php-pear php5-dev php5-imap php5-mcrypt >>"${OUTTO}" 2>&1;
echo '<?php phpinfo(); ?>' > /srv/www/$sitename/public/checkinfo.php
echo -e '\n[... Installing Nginx Completed ...]'
echo
}

# adjust permissions function
function _perms() {
echo -e '\n[Adjusting Permissions]'
chgrp -R www-data /srv/www/*
chmod -R g+rw /srv/www/*
sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'
echo -e '\n[... Permissions Adjusted ...]'
echo
}

# install mariadb function
function _mariadb() {
echo -e '\n[Installing MariaDB]'
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mariadb-server >>"${OUTTO}" 2>&1;
echo -e '\n[... Installing MariaDB Completed ...]'
echo
}

# install sendmail function
function _sendmail() {
echo -e '\n[Installing Sendmail]'
apt-get -y install sendmail >>"${OUTTO}" 2>&1;
sendmailconfig -y
# install aliases
echo -e "mailer-daemon: postmaster
postmaster: root
nobody: root
hostmaster: root
usenet: root
news: root
webmaster: root
www: root
ftp: root
abuse: root
root: $admin_email" > /etc/aliases
newaliases >>"${OUTTO}" 2>&1;
echo -e '\n[... Installing Sendmail Completed ...]'
echo
}

# finalize and restart services function
function _services() {
echo
service nginx restart >>"${OUTTO}" 2>&1;
service varnish restart >>"${OUTTO}" 2>&1;
service php5-fpm restart >>"${OUTTO}" 2>&1;
service sendmail restart >>"${OUTTO}" 2>&1;
echo
}

echo "${bold}[vstacklet] Varnish LEMP Stack Installation Complet${normal}"
date

exit 0
