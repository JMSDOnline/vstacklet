#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Installation Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#
# find server IP and server hostname for nginx configuration
server_ip=$(ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1);
hostname1=$(hostname -s);

#Script Console Colors
black=$(tput setaf 0);red=$(tput setaf 1);green=$(tput setaf 2);yellow=$(tput setaf 3);blue=$(tput setaf 4);magenta=$(tput setaf 5);cyan=$(tput setaf 6);white=$(tput setaf 7);on_red=$(tput setab 1);on_green=$(tput setab 2);on_yellow=$(tput setab 3);on_blue=$(tput setab 4);on_magenta=$(tput setab 5);on_cyan=$(tput setab 6);on_white=$(tput setab 7);bold=$(tput bold);dim=$(tput dim);underline=$(tput smul);reset_underline=$(tput rmul);standout=$(tput smso);reset_standout=$(tput rmso);normal=$(tput sgr0);alert=${white}${on_red};title=${standout};sub_title=${bold}${yellow};repo_title=${black}${on_green};

# Color Prompt
sed -i.bak -e 's/^#force_color/force_color/' \
 -e 's/1;34m/1;35m/g' \
 -e "\$aLS_COLORS=\$LS_COLORS:'di=0;35:' ; export LS_COLORS" /etc/skel/.bashrc


function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

# intro function (1)
function _intro() {
  echo
  echo
  echo "  [${repo_title}vstacklet${normal}] ${title} Varnish LEMP Stack Installation ${normal}  "
  echo "${alert} Configured and tested for Ubuntu 14.04, 15.04 & 15.10 ${normal}"
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
  apt-get -y install nano unzip dos2unix htop iotop bc libwww-perl >>"${OUTTO}" 2>&1;
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
# what is seen below is merely an attempt at future-proofing the script
# for now we continue to use the trusty branch to install varnish
#  if [[ ${rel} =~ ("14.04") ]]; then
  cat >/etc/apt/sources.list.d/varnish-cache.list<<EOF
deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.1
EOF
#  elif [[ ${rel} =~ ("15.04"|"15.10") ]]; then
#    cat >/etc/apt/sources.list.d/varnish-cache.list<<EOF
#    deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0
#EOF
#  fi
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

# setting main web root directory function (5)
function _asksitename() {
  echo "${bold}You may now optionally name your main web root directory.${normal}"
  echo "${bold}If you choose to not name your main websites root directory,${normal}"
  echo "${bold}then your servers hostname will be used as a default.${normal}"
  echo
  echo -n "${bold}${yellow}Would you like to name your main web root directory?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) sitename=yes ;;
    [nN] | [nN][Oo] ) sitename=no ;;
  esac
}

function _sitename() {
  if [[ ${sitename} == "yes" ]]; then
    read -p "${bold}${yellow}Please enter a name for your main websites root directory ${normal} : " sitename
    echo
    echo "Your website directory has been set to /srv/www/${green}${bold}${sitename}${normal}/public/"
    echo
  fi
}

function _nositename() {
  if [[ ${sitename} == "no" ]]; then
    echo
    echo "Your website directory has been set to /srv/www/${green}${bold}${hostname1}${normal}/public/"
    echo
  fi
}

# install nginx function (6)
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
  if [[ ${sitename} == "yes" ]]; then
    cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/$sitename.conf
    # build applications directory
    mkdir -p /srv/www/$sitename/logs >/dev/null 2>&1;
    mkdir -p /srv/www/$sitename/ssl >/dev/null 2>&1;
    mkdir -p /srv/www/$sitename/public >/dev/null 2>&1;
    # In NginX 1.9.x the use of conf.d seems appropriate
    # ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
  elif [[ ${sitename} == "no" ]]; then
    cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/$hostname1.conf
    # build applications directory
    mkdir -p /srv/www/$hostname1/logs >/dev/null 2>&1;
    mkdir -p /srv/www/$hostname1/ssl >/dev/null 2>&1;
    mkdir -p /srv/www/$hostname1/public >/dev/null 2>&1;
    # In NginX 1.9.x the use of conf.d seems appropriate
    # ln -s /etc/nginx/sites-available/$hostname1 /etc/nginx/sites-enabled/$hostname1
  fi
  echo "${OK}"
  echo
}

# adjust permissions function (7)
function _perms() {
  chgrp -R www-data /srv/www/*
  chmod -R g+rw /srv/www/*
  sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'
  echo "${OK}"
  echo
}

# install varnish function (8)
function _varnish() {
  apt-get -y install varnish >>"${OUTTO}" 2>&1;
  sed -i "s/127.0.0.1/$server_ip/" /etc/varnish/default.vcl
  sed -i "s/6081/80/" /etc/default/varnish
  # then there is varnish with systemd in ubuntu 15.x
  # let us shake that headache now
  if [[ ${rel} =~ ("15.04"|"15.10") ]]; then
    cp /lib/systemd/system/varnishlog.service /etc/systemd/system/
    cp /lib/systemd/system/varnish.service /etc/systemd/system/
    sed -i "s/6081/80/" /etc/systemd/system/varnish.service
    sed -i "s/6081/80/" /lib/systemd/system/varnish.service
    systemctl daemon-reload
  fi
  echo "${OK}"
  echo
}

# install php function (9)
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
  # ensure mcrypt module is activated
  php5enmod mcrypt
  # write checkinfo for php verification
  if [[ ${sitename} == "yes" ]]; then
    echo '<?php phpinfo(); ?>' > /srv/www/$sitename/public/checkinfo.php
  elif [[ ${sitename} == "no" ]]; then
    echo '<?php phpinfo(); ?>' > /srv/www/$hostname1/public/checkinfo.php
  fi
  echo "${OK}"
  echo
}

# install ioncube loader function (10)
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
    if [[ ${rel} =~ ("15.04"|"15.10") ]]; then
      cp ioncube_loader_lin_5.6.so /usr/lib/php5/20131226/ >/dev/null 2>&1;
      echo -e "zend_extension = /usr/lib/php5/20131226/ioncube_loader_lin_5.6.so" > /etc/php5/fpm/conf.d/20-ioncube.ini
      echo "zend_extension = /usr/lib/php5/20131226/ioncube_loader_lin_5.6.so" >> /etc/php5/fpm/php.ini
    elif [[ ${rel} =~ ("14.04") ]]; then
      cp ioncube_loader_lin_5.5.so /usr/lib/php5/20121212/ >/dev/null 2>&1;
      echo -e "zend_extension = /usr/lib/php5/20121212/ioncube_loader_lin_5.5.so" > /etc/php5/fpm/conf.d/20-ioncube.ini
      echo "zend_extension = /usr/lib/php5/20121212/ioncube_loader_lin_5.5.so" >> /etc/php5/fpm/php.ini
    fi
    cd
    rm -rf tmp*
    echo "${OK}"
    echo
  fi
}

function _noioncube() {
  if [[ ${ioncube} == "no" ]]; then
    echo "${cyan}Skipping IonCube Installation...${normal}"
    echo 
  fi
}

# install mariadb function (11)
function _mariadb() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get -q -y install mariadb-server >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# install phpmyadmin function (12)
function _askphpmyadmin() {
  echo -n "${bold}${yellow}Do you want to install phpMyAdmin?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) phpmyadmin=yes ;;
    [nN] | [nN][Oo] ) phpmyadmin=no ;;
  esac
}

function _phpmyadmin() {
  if [[ ${phpmyadmin} == "yes" ]]; then
    # generate random passwords for the MySql root user
    pmapass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15);
    mysqlpass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15);
    mysqladmin -u root -h localhost password "${mysqlpass}"
    echo -n "${bold}Installing MySQL with user:${normal} ${bold}${green}root${normal}${bold} / passwd:${normal} ${bold}${green}${mysqlpass}${normal} ... "
    apt-get -y install debconf-utils >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive
    # silently configure given options and install
    echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${mysqlpass}" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/app-pass password ${pmapass}" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/app-password-confirm password ${pmapass}" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
    apt-get -y install phpmyadmin >>"${OUTTO}" 2>&1;
    if [[ ${sitename} == "yes" ]]; then
      # create a sym-link to live directory.
      ln -s /usr/share/phpmyadmin /srv/www/$sitename/public
      # Void this for now to maintain port 8080 access and avoid 404 error. This will be cleansed in v3
      # add phpmyadmin directive to nginx site configuration at /etc/nginx/conf.d/$sitename.conf.
      # locconf6="include vstacklet\/location\/pma.conf;"
      sed -i "s/locconf6/#locconf6/" /etc/nginx/conf.d/$sitename.conf
    elif [[ ${sitename} == "no" ]]; then
      # create a sym-link to live directory.
      ln -s /usr/share/phpmyadmin /srv/www/$hostname1/public
      # Void this for now to maintain port 8080 access and avoid 404 error. This will be cleansed in v3
      # add phpmyadmin directive to nginx site configuration at /etc/nginx/conf.d/$hostname1.conf.
      # locconf6="include vstacklet\/location\/pma.conf;"
      sed -i "s/locconf6/#locconf6/" /etc/nginx/conf.d/$hostname1.conf
    fi
    echo "${OK}"
    # get phpmyadmin directory
    DIR="/etc/phpmyadmin";
    # show phpmyadmin creds
    echo '[phpMyAdmin Login]' > ~/.my.cnf;
    echo " - pmadbuser='phpmyadmin'" >> ~/.my.cnf;
    echo " - pmadbpass='${pmapass}'" >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    echo "   Access phpMyAdmin at: " >> ~/.my.cnf;
    echo "   http://$server_ip:8080/phpmyadmin/" >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    # show mysql creds
    echo '[MySQL Login]' >> ~/.my.cnf;
    echo " - sqldbuser='root'" >> ~/.my.cnf;
    echo " - sqldbpass='${mysqlpass}'" >> ~/.my.cnf;
    echo '' >> ~/.my.cnf;
    # closing statement
    echo
    echo "${bold}Below are your phpMyAdmin and MySQL details.${normal}"
    echo "${bold}Details are logged in the${normal} ${bold}${green}/root/.my.cnf${normal} ${bold}file.${normal}"
    echo "Best practice is to copy this file locally then rm ~/.my.cnf"
    echo
    # show contents of .my.cnf file
    cat ~/.my.cnf
    echo
  fi
}

function _nophpmyadmin() {
  if [[ ${phpmyadmin} == "no" ]]; then
    echo "${cyan}Skipping phpMyAdmin Installation...${normal}"
    echo 
  fi
}

# install and adjust config server firewall function (13)
function _askcsf() {
  echo -n "${bold}${yellow}Do you want to install CSF (Config Server Firewall)?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) csf=yes ;;
    [nN] | [nN][Oo] ) csf=no ;;
  esac
}

function _csf() {
  if [[ ${csf} == "yes" ]]; then
    echo -n "${green}Installing and Adjusting CSF${normal} ... "
    wget http://www.configserver.com/free/csf.tgz >/dev/null 2>&1;
    tar -xzf csf.tgz >/dev/null 2>&1;
    ufw disable >>"${OUTTO}" 2>&1;
    cd csf
    sh install.sh >>"${OUTTO}" 2>&1;
    perl /usr/local/csf/bin/csftest.pl >>"${OUTTO}" 2>&1;
    # modify csf blocklists - essentially like CloudFlare, but on your machine
    sed -i.bak -e "s/#SPAMDROP|86400|0|/SPAMDROP|86400|100|/" \
               -e "s/#SPAMEDROP|86400|0|/SPAMEDROP|86400|100|/" \
               -e "s/#DSHIELD|86400|0|/DSHIELD|86400|100|/" \
               -e "s/#TOR|86400|0|/TOR|86400|100|/" \
               -e "s/#ALTTOR|86400|0|/ALTTOR|86400|100|/" \
               -e "s/#BOGON|86400|0|/BOGON|86400|100|/" \
               -e "s/#HONEYPOT|86400|0|/HONEYPOT|86400|100|/" \
               -e "s/#CIARMY|86400|0|/CIARMY|86400|100|/" \
               -e "s/#BFB|86400|0|/BFB|86400|100|/" \
               -e "s/#OPENBL|86400|0|/OPENBL|86400|100|/" \
               -e "s/#AUTOSHUN|86400|0|/AUTOSHUN|86400|100|/" \
               -e "s/#MAXMIND|86400|0|/MAXMIND|86400|100|/" \
               -e "s/#BDE|3600|0|/BDE|3600|100|/" \
               -e "s/#BDEALL|86400|0|/BDEALL|86400|100|/" /etc/csf/csf.blocklists;
    # modify csf process ignore - ignore nginx, varnish & mysql
    echo >> /etc/csf/csf.pignore;
    echo "[ VStacklet Additions - These are necessary to avoid noisy emails ]" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/mysqld" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/ngninx" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/varnishd" >> /etc/csf/csf.pignore;
    # modify csf conf - make suitable changes for non-cpanel environment
    sed -i.bak -e 's/TESTING = "1"/TESTING = "0"/' \
               -e 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/' \
               -e 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/' \
               -e 's/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,8080"/' \
               -e 's/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/' \
               -e 's/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,8080"/' \
               -e 's/DENY_TEMP_IP_LIMIT = "100"/DENY_TEMP_IP_LIMIT = "1000"/' \
               -e 's/SMTP_ALLOWUSER = "cpanel"/SMTP_ALLOWUSER = "root"/' \
               -e 's/PT_USERMEM = "200"/PT_USERMEM = "500"/' \
               -e 's/PT_USERTIME = "1800"/PT_USERTIME = "3600"/' /etc/csf/csf.conf;
    echo "${OK}"
    echo
    # install sendmail as it's binary is required by CSF
    echo "${green}Installing Sendmail${normal} ... "
    apt-get -y install sendmail >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1;
    # add administrator email
    echo "${magenta}${bold}Add an Administrator Email Below for Aliases Inclusion${normal}"
    read -p "${bold}Email: ${normal}" admin_email
    echo
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

function _nocsf() {
  if [[ ${csf} == "no" ]]; then
    echo "${cyan}Skipping Config Server Firewall Installation${normal} ... "
    echo 
  fi
}

# if you're using cloudlfare as a protection and/or cdn - this next bit is important
function _askcloudflare() {
  echo -n "${bold}${yellow}Would you like to whitelist CloudFlare IPs?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) cloudflare=yes ;;
    [nN] | [nN][Oo] ) cloudflare=no ;;
  esac
}

function _cloudflare() {
  if [[ ${cloudflare} == "yes" ]]; then
    echo -n "${green}Whitelisting Cloudflare IPs-v4 and -v6${normal} ... "
    echo -e "# BEGIN CLOUDFLARE WHITELIST
# ips-v4
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
104.16.0.0/12
108.162.192.0/18
141.101.64.0/18
162.158.0.0/15
172.64.0.0/13
173.245.48.0/20
188.114.96.0/20
190.93.240.0/20
197.234.240.0/22
198.41.128.0/17
199.27.128.0/21
# ips-v6
2400:cb00::/32
2405:8100::/32
2405:b500::/32
2606:4700::/32
2803:f800::/32
# END CLOUDFLARE WHITELIST
" >> /etc/csf/csf.allow
    echo "${OK}"
    echo
  fi
}

# install sendmail function (14)
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
    echo "${green}Installing Sendmail ... ${normal}"
    apt-get -y install sendmail >>"${OUTTO}" 2>&1;
    export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1;
    # add administrator email
    echo "${magenta}Add an Administrator Email Below for Aliases Inclusion${normal}"
    read -p "${bold}Email: ${normal}" admin_email
    echo
    echo "${bold}The email ${green}${bold}$admin_email${normal} ${bold}is now the forwarding address for root mail${normal}"
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

function _nosendmail() {
  if [[ ${sendmail} == "no" ]]; then
    echo "${cyan}Skipping Sendmail Installation...${normal}"
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
# enhance configuration function (15)
function _locenhance() {
  if [[ ${sitename} == "yes" ]]; then
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
  elif [[ ${sitename} == "no" ]]; then
    locconf1="include vstacklet\/location\/cache-busting.conf;"
    sed -i "s/locconf1/$locconf1/" /etc/nginx/conf.d/$hostname1.conf
    locconf2="include vstacklet\/location\/cross-domain-fonts.conf;"
    sed -i "s/locconf2/$locconf2/" /etc/nginx/conf.d/$hostname1.conf
    locconf3="include vstacklet\/location\/expires.conf;"
    sed -i "s/locconf3/$locconf3/" /etc/nginx/conf.d/$hostname1.conf
  # locconf4="include vstacklet\/location\/extensionless-uri.conf;"
  # sed -i "s/locconf4/$locconf4/" /etc/nginx/conf.d/$hostname1.conf
    locconf5="include vstacklet\/location\/protect-system-files.conf;"
    sed -i "s/locconf5/$locconf5/" /etc/nginx/conf.d/$hostname1.conf
  fi
  echo "${OK}"
  echo 
}

# Round 2 - Security
# optimize security configuration function (16)
function _security() {
  if [[ ${sitename} == "yes" ]]; then
    secconf1="include vstacklet\/directive-only\/sec-bad-bots.conf;"
    sed -i "s/secconf1/$secconf1/" /etc/nginx/conf.d/$sitename.conf
    secconf2="include vstacklet\/directive-only\/sec-file-injection.conf;"
    sed -i "s/secconf2/$secconf2/" /etc/nginx/conf.d/$sitename.conf
    secconf3="include vstacklet\/directive-only\/sec-php-easter-eggs.conf;"
    sed -i "s/secconf3/$secconf3/" /etc/nginx/conf.d/$sitename.conf
  elif [[ ${sitename} == "no" ]]; then
    secconf1="include vstacklet\/directive-only\/sec-bad-bots.conf;"
    sed -i "s/secconf1/$secconf1/" /etc/nginx/conf.d/$hostname1.conf
    secconf2="include vstacklet\/directive-only\/sec-file-injection.conf;"
    sed -i "s/secconf2/$secconf2/" /etc/nginx/conf.d/$hostname1.conf
    secconf3="include vstacklet\/directive-only\/sec-php-easter-eggs.conf;"
    sed -i "s/secconf3/$secconf3/" /etc/nginx/conf.d/$hostname1.conf
  fi
  echo "${OK}"
  echo
}

# create self-signed certificate function (17)
function _askcert() {
  echo -n "${bold}${yellow}Do you want to create a self-signed SSL cert and configure HTTPS?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) cert=yes ;;
    [nN] | [nN][Oo] ) cert=no ;;
  esac
}

function _cert() {
  if [[ ${cert} == "yes" ]]; then
    insert1="listen [::]:443 ssl http2;\n    listen *:443 ssl http2;"
    if [[ ${sitename} == "yes" ]]; then
      insert2="include vstacklet\/directive-only\/ssl.conf;\n    ssl_certificate \/srv\/www\/$sitename\/ssl\/$sitename.crt;\n    ssl_certificate_key \/srv\/www\/$sitename\/ssl\/$sitename.key;"
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$sitename.key -out /etc/ssl/certs/$sitename.crt
      chmod 400 /etc/ssl/private/$sitename.key
      sed -i "s/insert1/$insert1/" /etc/nginx/conf.d/$sitename.conf
      sed -i "s/insert2/$insert2/" /etc/nginx/conf.d/$sitename.conf
      sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    elif [[ ${sitename} == "no" ]]; then
      insert2="include vstacklet\/directive-only\/ssl.conf;\n    ssl_certificate \/srv\/www\/$hostname1\/ssl\/$hostname1.crt;\n    ssl_certificate_key \/srv\/www\/$hostname1\/ssl\/$hostname1.key;"
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /srv/www/$hostname1/ssl/$hostname1.key -out /srv/www/$hostname1/ssl/$hostname1.crt
      chmod 400 /etc/ssl/private/$hostname1.key
      sed -i "s/insert1/$insert1/" /etc/nginx/conf.d/$hostname1.conf
      sed -i "s/insert2/$insert2/" /etc/nginx/conf.d/$hostname1.conf
      sed -i "s/sitename/$hostname1/" /etc/nginx/conf.d/$hostname1.conf
    fi
    echo "${OK}"
    echo
  fi
}

function _nocert() {
  if [[ ${cert} == "no" ]]; then
    if [[ ${sitename} == "yes" ]]; then
      sed -i "s/insert1/ /" /etc/nginx/conf.d/$sitename.conf
      sed -i "s/insert2/ /" /etc/nginx/conf.d/$sitename.conf
      sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
    elif [[ ${sitename} == "no" ]]; then
      sed -i "s/insert1/ /" /etc/nginx/conf.d/$hostname1.conf
      sed -i "s/insert2/ /" /etc/nginx/conf.d/$hostname1.conf
      sed -i "s/sitename/$hostname1/" /etc/nginx/conf.d/$hostname1.conf
    fi
    echo "${cyan}Skipping SSL Certificate Creation...${normal}"
    echo 
  fi
}

# finalize and restart services function (18)
function _services() {
  service nginx restart >>"${OUTTO}" 2>&1;
  service varnish restart >>"${OUTTO}" 2>&1;
  service php5-fpm restart >>"${OUTTO}" 2>&1;
  service sendmail restart >>"${OUTTO}" 2>&1;
  service lfd restart >>"${OUTTO}" 2>&1;
  csf -r >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# function to show finished data (19)
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
_asksitename;if [[ ${sitename} == "yes" ]]; then _sitename; elif [[ ${sitename} == "no" ]]; then _nositename;  fi
echo -n "${bold}Installing and Configuring Nginx${normal} ... ";_nginx
echo -n "${bold}Adjusting Permissions${normal} ... ";_perms
echo -n "${bold}Installing and Configuring Varnish${normal} ... ";_varnish
echo -n "${bold}Installing and Adjusting PHP-FPM w/ OPCode Cache${normal} ... ";_php
_askioncube;if [[ ${ioncube} == "yes" ]]; then _ioncube; elif [[ ${ioncube} == "no" ]]; then _noioncube;  fi
echo -n "${bold}Installing MariaDB Drop-in Replacement${normal} ... ";_mariadb
_askphpmyadmin;if [[ ${phpmyadmin} == "yes" ]]; then _phpmyadmin; elif [[ ${phpmyadmin} == "no" ]]; then _nophpmyadmin;  fi
_askcsf;if [[ ${csf} == "yes" ]]; then _csf; elif [[ ${csf} == "no" ]]; then _nocsf;  fi
if [[ ${csf} == "yes" ]]; then 
  _askcloudflare;if [[ ${cloudflare} == "yes" ]]; then _cloudflare;  fi
fi
if [[ ${csf} == "no" ]]; then 
  _asksendmail;if [[ ${sendmail} == "yes" ]]; then _sendmail; elif [[ ${sendmail} == "no" ]]; then _nosendmail;  fi
fi
echo "${bold}Addressing Location Edits: cache busting, cross domain font support,${normal}";
echo -n "${bold}expires tags, and system file protection${normal} ... ";_locenhance
echo "${bold}Performing Security Enhancements: protecting against bad bots,${normal}";
echo -n "${bold}file injection, and php easter eggs${normal} ... ";_security
_askcert;if [[ ${cert} == "yes" ]]; then _cert; elif [[ ${cert} == "no" ]]; then _nocert;  fi
echo -n "${bold}Completing Installation & Restarting Services${normal} ... ";_services

E=$(date +%s)
DIFF=$(echo "$E" - "$S"|bc)
FIN=$(echo "$DIFF" / 60|bc)
_finished