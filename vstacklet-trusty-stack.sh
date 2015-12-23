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

#Script Console Colors
black=$(tput setaf 0);
red=$(tput setaf 1);
green=$(tput setaf 2);
yellow=$(tput setaf 3);
blue=$(tput setaf 4);
magenta=$(tput setaf 5);
cyan=$(tput setaf 6);
white=$(tput setaf 7);
on_red=$(tput setab 1);
on_green=$(tput setab 2);
on_yellow=$(tput setab 3);
on_blue=$(tput setab 4);
on_magenta=$(tput setab 5);
on_cyan=$(tput setab 6);
on_white=$(tput setab 7);

bold=$(tput bold);    # Select bold mode
dim=$(tput dim);     # Select dim (half-bright) mode
underline=$(tput smul);    # Enable underline mode
reset_underline=$(tput rmul);    # Disable underline mode
standout=$(tput smso);    # Enter standout (bold) mode
reset_standout=$(tput rmso);    # Exit standout mode

normal=$(tput sgr0);

alert=${white}${on_red};
title=${standout};
sub_title=${bold}${yellow};
repo_title=${black}${on_green};

# Color Prompt
sed -i.bak -e 's/^#force_color/force_color/' \
 -e 's/1;34m/1;35m/g' \
 -e "\$aLS_COLORS=\$LS_COLORS:'di=0;35:' ; export LS_COLORS" /etc/skel/.bashrc


function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

# intro function (1)
function _intro() {
  echo
  echo
  echo "  [${repo_title}vstacklet${normal}] ${standout} Varnish LEMP Stack Installation ${reset_standout}  "
  echo "${alert}      Configured and tested for Ubuntu 14.04.      ${normal}"
  echo
  echo "${bold}Installs and configures LEMP stack with Varnish support for PHP Applications.${normal}"
  echo
  echo

  echo "${green}Checking distribution ...${normal}"
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
  elif [[ ! "${rel}" =~ ("14.04"|"15.04"|"15.10") ]]; then
    echo "${bold}${rel}:${normal} You do not appear to be running a supported Ubuntu release."
    echo 'Exiting...'
    exit 1
  fi
}

# check if root function (2)
function _checkroot() {
  if [[ $EUID != 0 ]]; then
    echo 'This script must be run with root privileges.'
    echo 'Exiting...'
    exit 1
  fi
  echo "${green}Congrats! You're running as root. Let's continue${normal} ... "
  echo
}

# check if create log function (3)
function _logcheck() {
  echo -ne "${bold}${yellow}Do you wish to write to a log file?${normal} (Default: ${green}${bold}Y${normal}) "; read input
    case $input in
      [yY] | [yY][Ee][Ss] | "" ) OUTTO="vstacklet.log";echo "${bold}Output is being sent to /root/vstacklet.log${normal}" ;;
      [nN] | [nN][Oo] ) OUTTO="/dev/null 2>&1";echo "${cyan}NO output will be logged${normal}" ;;
    *) OUTTO="vstacklet.log";echo "${bold}Output is being sent to /root/vstacklet.log${normal}" ;;
    esac
  echo
  echo "Press ${standout}${green}ENTER${normal} when you're ready to begin" ;read input
  echo
}

# system packages and repos function (4)
# Update packages and add MariaDB, Varnish 4, and Nginx 1.9.9 (mainline) repositories
function _softcommon() {
  # package and repo addition (a) _install common properties_
  apt-get -y install software-properties-common >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (b) _install softwares and packages_
function _depends() {
  apt-get -y install nano unzip dos2unix htop iotop libwww-perl >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (c) _add signed keys_
function _keys() {
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db >>"${OUTTO}" 2>&1;
  curl -s https://repo.varnish-cache.org/GPG-key.txt | apt-key add - > /dev/null 2>&1;
  curl -s http://nginx.org/keys/nginx_signing.key | apt-key add - > /dev/null 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (d) _add respo sources_
function _repos() {
  cat >/etc/apt/sources.list.d/mariadb.list<<EOF
deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu $(lsb_release -sc) main
EOF
  if [[ ${rel} =~ ("14.04") ]]; then
    cat >/etc/apt/sources.list.d/varnish-cache.list<<EOF
    deb https://repo.varnish-cache.org/ubuntu/ $(lsb_release -sc) varnish-4.1
EOF
  elif [[ ${rel} =~ ("15.04"|"15.10") ]]; then
    cat >/etc/apt/sources.list.d/varnish-cache.list<<EOF
    deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0
EOF
  fi
  cat >/etc/apt/sources.list.d/nginx-mainline-$(lsb_release -sc).list<<EOF
  deb http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx
  deb-src http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx
EOF
  echo "${OK}"
  echo
}

# package and repo addition (e) _update and upgrade_
function _updates() {
  export DEBIAN_FRONTEND=noninteractive &&
  apt-get -y update >>"${OUTTO}" 2>&1;
  apt-get -y upgrade >>"${OUTTO}" 2>&1;
# apt-get -y autoremove >>"${OUTTO}" 2>&1; ### I'll let you decide
  echo "${OK}"
  echo
}

# install nginx function (5)
function _nginx() {
  apt-get -y install nginx >>"${OUTTO}" 2>&1;
  update-rc.d nginx defaults >>"${OUTTO}" 2>&1;
  service nginx stop >>"${OUTTO}" 2>&1;
  mv /etc/nginx /etc/nginx-previous >>"${OUTTO}" 2>&1;
  wget https://github.com/JMSDOnline/vstacklet/raw/master/vstacklet-server-configs.tar.gz >/dev/null 2>&1;
  tar -zxvf vstacklet-server-configs.tar.gz >/dev/null 2>&1;
  mv vstacklet-server-configs /etc/nginx >>"${OUTTO}" 2>&1;
  rm -rf vstacklet-server-configs*
  cp /etc/nginx-previous/uwsgi_params /etc/nginx-previous/fastcgi_params /etc/nginx >>"${OUTTO}" 2>&1;
  sed -i.bak -e "s/www www/www-data www-data/" \
    -e "s/logs\/error.log/\/var\/log\/nginx\/error.log/" \
    -e "s/logs\/access.log/\/var\/log\/nginx\/access.log/" /etc/nginx/nginx.conf
  sed -i.bak -e "s/logs\/static.log/\/var\/log\/nginx\/static.log/" /etc/nginx/vstacklet/location/expires.conf
  # rename default.conf template
  cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/$sitename.conf
  # build applications directory
  mkdir -p /srv/www/$sitename/app/static >/dev/null 2>&1;
  mkdir -p /srv/www/$sitename/app/templates >/dev/null 2>&1;
  mkdir -p /srv/www/$sitename/public >/dev/null 2>&1;
  # In NginX 1.9.x the use of conf.d seems appropriate
  # ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
  echo "${OK}"
  echo
}

# install varnish function (6)
function _varnish() {
  apt-get -y install varnish >>"${OUTTO}" 2>&1;
  sed -i "s/127.0.0.1/$server_ip/" /etc/varnish/default.vcl
  sed -i "s/6081/80/" /etc/default/varnish
  echo "${OK}"
  echo
}

# install php function (7)
function _php() {
  apt-get -y install php5-common php5-mysqlnd php5-curl php5-gd php5-cli php5-fpm php-pear php5-dev php5-imap php5-mcrypt >>"${OUTTO}" 2>&1;
  sed -i.bak -e "s/post_max_size = 8M/post_max_size = 32M/" \
    -e "s/upload_max_filesize = 2M/upload_max_filesize = 64M/" \
    -e "s/expose_php = On/expose_php = Off/" \
    -e "s/128M/512M/" \
    -e "s/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" \
    -e "s/;opcache.enable=0/opcache.enable=1/" \
    -e "s/;opcache.memory_consumption=64/opcache.memory_consumption=128/" \
    -e "s/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=4000/" \
    -e "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=240/" /etc/php5/fpm/php.ini
  # ensure opcache module is activated
  php5enmod opcache
  # write checkinfo for php verification
  echo '<?php phpinfo(); ?>' > /srv/www/$sitename/public/checkinfo.php
  echo "${OK}"
  echo
}

# install ioncube loader function (8)
function _askioncube() {
  echo -n "${bold}${yellow}Do you want to install IonCube Loader?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) ioncube=yes ;;
    [nN] | [nN][Oo] ) ioncube=no ;;
  esac
}

function _ioncube() {
  if [[ ${ioncube} == "yes" ]]; then
    echo -n "${green}Installing IonCube Loader${normal} ... "
    mkdir tmp 2>&1;
    cd tmp 2>&1;
    wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz >/dev/null 2>&1;
    tar xvfz ioncube_loaders_lin_x86-64.tar.gz >/dev/null 2>&1;
    cd ioncube >/dev/null 2>&1;
    cp ioncube_loader_lin_5.5.so /usr/lib/php5/20121212/ >/dev/null 2>&1;
    echo -e "zend_extension = /usr/lib/php5/20121212/ioncube_loader_lin_5.5.so" > /etc/php5/fpm/conf.d/20-ioncube.ini
    echo "zend_extension = /usr/lib/php5/20121212/ioncube_loader_lin_5.5.so" >> /etc/php5/fpm/php.ini
    cd
    rm -rf tmp*
    echo "${OK}"
    echo
  fi
}

# adjust permissions function (9)
function _perms() {
  chgrp -R www-data /srv/www/*
  chmod -R g+rw /srv/www/*
  sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'
  echo "${OK}"
  echo
}

# install mariadb function (10)
function _mariadb() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get -q -y install mariadb-server >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# install sendmail function (11)
function _asksendmail() {
  echo -n "${bold}${yellow}Do you want to install Sendmail?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) sendmail=yes ;;
    [nN] | [nN][Oo] ) sendmail=no ;;
  esac
}

function _sendmail() {
  if [[ ${sendmail} == "yes" ]]; then
    echo -n "${green}Installing Sendmail ... ${normal}"
    apt-get -y install sendmail >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1;
    # add administrator email
    echo "${blue}Add an Administrator Email Below for Aliases Inclusion${normal}"
    read -p "Email: " admin_email
    echo "${bold}The email ${green}${bold}$admin_email${normal} ${bold}is now the forwarding email for root mail${normal}"
    echo -n "${green}finalizing sendmail installation${normal} ... "
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
    echo "${OK}"
    echo
  fi
}

#################################################################
# The following security & enhancements cover basic security
# measures to protect against common exploits.
# Enhancements covered are adding cache busting, cross domain
# font support, expires tags and protecting system files.
# 
# You can find the included files at the following directory...
# /etc/nginx/vstacklet/
# 
# Not all profiles are included, review your $sitename.conf
# for additions made by the script & adjust accordingly.
#################################################################

# Round 1 - Location
# enhance configuration function (12)
function _locenhance() {
  locconf1="include vstacklet\/location\/cache-busting.conf;"
  sed -i "s/locconf1/$locconf1/" /etc/nginx/conf.d/$sitename.conf
  locconf2="include vstacklet\/location\/cross-domain-fonts.conf;"
  sed -i "s/locconf2/$locconf2/" /etc/nginx/conf.d/$sitename.conf
  locconf3="include vstacklet\/location\/expires.conf;"
  sed -i "s/locconf3/$locconf3/" /etc/nginx/conf.d/$sitename.conf
# locconf4="include vstacklet\/location\/extensionless-uri.conf;"
# sed -i "s/locconf4/$locconf4/" /etc/nginx/conf.d/$sitename.conf
  locconf5="include vstacklet\/location\/protect-system-files.conf;"
  sed -i "s/locconf5/$locconf5/" /etc/nginx/conf.d/$sitename.conf
  echo "${OK}"
  echo 
}

# Round 2 - Security
# create self-signed certificate function (13)
function _askcert() {
  echo -n "${yellow}Do you want to create a self-signed SSL cert and configure HTTPS?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) cert=yes ;;
    [nN] | [nN][Oo] ) cert=no ;;
  esac
}

function _cert() {
  if [[ ${cert} == "yes" ]]; then
    insert1="listen [::]:443 ssl http2;\n    listen *:443 ssl http2;"
    insert2="include vstacklet\/directive-only\/ssl.conf;\n    ssl_certificate \/etc\/ssl\/certs\/$sitename.crt;\n    ssl_certificate_key \/etc\/ssl\/private\/$sitename.key;"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$sitename.key -out /etc/ssl/certs/$sitename.crt
    chmod 400 /etc/ssl/private/$sitename.key
    sed -i "s/insert1/$insert1/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/insert2/$insert2/" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    echo "${OK}"
    echo
  fi
}

function _nocert() {
  if [[ ${cert} == "no" ]]; then
    sed -i "s/insert1/ /" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/insert2/ /" /etc/nginx/conf.d/$sitename.conf
    sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    echo "${cyan}Skipping SSL Certificate Creation...${normal}"
    echo 
  fi
}

# optimize security configuration function (12)
function _security() {
  secconf1="include vstacklet\/directive-only\/sec-bad-bots.conf;"
  sed -i "s/secconf1/$secconf1/" /etc/nginx/conf.d/$sitename.conf
  secconf2="include vstacklet\/directive-only\/sec-file-injection.conf;"
  sed -i "s/secconf2/$secconf2/" /etc/nginx/conf.d/$sitename.conf
  secconf3="include vstacklet\/directive-only\/sec-php-easter-eggs.conf;"
  sed -i "s/secconf3/$secconf3/" /etc/nginx/conf.d/$sitename.conf
  echo "${OK}"
  echo
}

# finalize and restart services function (13)
function _services() {
  service nginx restart >>"${OUTTO}" 2>&1;
  service varnish restart >>"${OUTTO}" 2>&1;
  service php5-fpm restart >>"${OUTTO}" 2>&1;
  service sendmail restart >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# function to show finished data (14)
function _finished() {
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
echo "                ${standout}ENJOY${reset_standout}     || \::::::/              "
echo '                o /       ||  ||__||               '
echo '               /|         ||    ||                 '
echo '               / \        ||     \\_______________ '
echo '           _______________||______`--------------- '
echo
echo
echo "${black}${on_green}    [vstacklet] Varnish LEMP Stack Installation Completed    ${normal}"
echo
echo "${bold}Visit ${green}http://${server_ip}/checkinfo.php${normal} ${bold}to verify your install. ${normal}"
echo "${bold}Remember to remove the checkinfo.php file after verification. ${normal}"
echo
echo
echo "${standout}INSTALLATION COMPLETED in ${FIN}/min ${normal}"
echo
}

clear

S=$(date +%s)
OK=$(echo -e "[ ${bold}${green}DONE${normal} ]")

# VSTACKLET STRUCTURE
_intro
_checkroot
_logcheck
echo -n "${bold}Installing Common Software Properties${normal} ... ";_softcommon
echo -n "${bold}Installing: nano, unzip, dos2unix, htop, iotop, libwww-perl${normal} ... ";_depends
echo -n "${bold}Installing signed keys for MariaDB, Nginx, and Varnish${normal} ... ";_keys
echo -n "${bold}Adding trusted repositories${normal} ... ";_repos
echo -n "${bold}Applying Updates${normal} ... ";_updates
echo -n "${bold}Installing and Configuring Nginx${normal} ... ";_nginx
echo -n "${bold}Installing and Configuring Varnish${normal} ... ";_varnish
echo -n "${bold}Installing and Adjusting PHP-FPM w/ OPCode Cache${normal} ... ";_php
_askioncube;if [[ ${ioncube} == "yes" ]]; then _ioncube; fi
echo -n "${bold}Adjusting Permissions${normal} ... ";_perms
echo -n "${bold}Installing MariaDB Drop-in Replacement${normal} ... ";_mariadb
_asksendmail;if [[ ${sendmail} == "yes" ]]; then _sendmail; fi
echo "${bold}Addressing Location Edits: cache busting, cross domain font support,${normal}";
echo -n "${bold}expires tags, and system file protection${normal} ... ";_locenhance
_askcert;if [[ ${cert} == "yes" ]]; then _cert; elif [[ ${cert} == "no" ]]; then _nocert;  fi
echo "${bold}Performing Security Enhancements: protecting against bad bots,${normal}"; 
echo -n "${bold}file injection, and php easter eggs${normal} ... ";_security
echo -n "${bold}Completing Installation & Restarting Services${normal} ... ";_services

E=$(date +%s)
DIFF=$(echo "$E" - "$S"|bc)
FIN=$(echo "$DIFF" / 60|bc)
_finished