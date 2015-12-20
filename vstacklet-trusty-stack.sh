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
S=$(date +%Y-%m-%d);
OK=$(echo -e "[ \e[0;32mDONE\e[00m ]");
E=$(date +%Y-%m-%d);
DIFF=$(echo "$E" - "$S"|bc);
FIN=$(echo "$DIFF" / 60|bc);

#Console Colors
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



# intro function (1)
# function _intro() {
echo
echo
echo "  [${repo_title}vstacklet${normal}] ${standout} Varnish LEMP Stack Installation ${reset_standout}  "
echo "${alert}      Configured and tested for Ubuntu 14.04.      ${normal}"
echo
echo "${bold}Installs and configures LEMP stack with Varnish support for PHP Applications.${normal}"
echo
echo

echo -ne "Do you want to continue?  (Default: ${green}${bold}Y${normal}) "; read input
   case $input in
      [yY] | [yY][Ee][Ss] | "" ) true ;;
      [nN] | [nN][Oo] ) echo "${red}Exiting...${normal}"
      exit 1;;
   *) ;;
   esac
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
elif [[ ! "${rel}" =~ ("14.04") ]]; then
  echo "${bold}${rel}:${normal} You do not appear to be running a supported Ubuntu release."
  echo 'Exiting...'
  exit 1
fi

echo "${green}Checking permissions...${normal}"
if [[ $EUID -ne 0 ]]; then
  echo 'This script must be run with root privileges.' 1>&2
  echo 'Exiting...'
  exit 1
fi
echo "${OK}"
echo

echo -ne "Do you wish to write to a log file (Default: ${green}${bold}Y${normal}) "; read input
   case $input in
      [yY] | [yY][Ee][Ss] | "" ) OUTTO="vstacklet.log";echo "${bold}Output is being sent to /root/vstacklet.log${normal} ... " ;;
      [nN] | [nN][Oo] ) OUTTO="/dev/null 2>&1";echo "${cyan}NO output will be logged${normal}" ;;
   *) OUTTO="vstacklet.log";echo "${bold}Output is being sent to /root/vstacklet.log${normal} ... " ;;
   esac
echo
echo "Press ${standout}${green}ENTER${normal} when you're ready to begin ... " ;read input
echo

# Color Prompt
sed -i.bak -e 's/^#force_color/force_color/' \
 -e 's/1;34m/1;35m/g' \
 -e "\$aLS_COLORS=\$LS_COLORS:'di=0;35:' ; export LS_COLORS" /etc/skel/.bashrc
# }

# system packages and repos function (2)
# function _update() {
# Update packages and add MariaDB, Varnish 4, and Nginx 1.9.9 (mainline) repositories
# package and repo addition (a) _install common properties_
echo "${sub_title}Installing Common Software Properties ... ${normal}"
apt-get -y install software-properties-common >>"${OUTTO}" 2>&1;
echo "${OK}"
echo

# package and repo addition (b) _install softwares and packages_
echo "${sub_title}Installing Additional Packages & Dependencies ... ${normal}"
apt-get -y install unzip dos2unix htop iotop >>"${OUTTO}" 2>&1;
# install ioncube loader
echo
read -p "Do you want to install IonCube Loader?  (Default: ${green}${bold}Y${normal})  " -n 1 -r
echo

if [[ $REPLY =~ ^[nN]$ ]]; then
  echo "${cyan}Skipping IonCube Loader Installation...${normal}"
else
  echo "${green}Installing IonCube Loader...${normal}"
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
fi

echo "${OK}"
echo

# package and repo addition (c) _add signed keys_
echo "${sub_title}Installing signed keys ... ${normal}"
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db >>"${OUTTO}" 2>&1;
echo "${bold}${green} ... applying varnish key ... ${normal}"
curl -s https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add - 
echo "${bold}${green} ... applying nginx key ... ${normal}"
curl -s http://nginx.org/keys/nginx_signing.key | apt-key add - 
echo "${OK}"
echo

# package and repo addition (d) _add respo sources_
echo "${sub_title}Adding trusted repositories ... ${normal}"
cat >/etc/apt/sources.list.d/mariadb.list<<EOF
deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main
EOF
cat >/etc/apt/sources.list.d/varnish-cache.list<<EOF
deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0
EOF
cat >/etc/apt/sources.list.d/nginx-mainline-trusty.list<<EOF
deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx
EOF
echo "${OK}"
echo

# package and repo addition (e) _update and upgrade_
echo "${sub_title}Applying Updates ... please hold ... ${normal}"
apt-get -y update >>"${OUTTO}" 2>&1;
apt-get -y upgrade >>"${OUTTO}" 2>&1;
# apt-get -y autoremove >>"${OUTTO}" 2>&1;
echo "${OK}"
echo
# }

# depencies and pip function (3)
# function _dependencies() {
# echo "${sub_title}Installing and Building Essential Python ... ${normal}"
# apt-get -y install build-essential debconf-utils python-dev libpcre3-dev libssl-dev python-pip >>"${OUTTO}" 2>&1;
# echo "${OK}"
# echo
# }

# install nginx function (4)
# function _nginx() {
echo "${sub_title}Installing and Configuring Nginx ... ${normal}"
apt-get -y install nginx >>"${OUTTO}" 2>&1;
update-rc.d nginx defaults >>"${OUTTO}" 2>&1;
service nginx stop >>"${OUTTO}" 2>&1;
mv /etc/nginx /etc/nginx-previous >>"${OUTTO}" 2>&1;
wget https://github.com/JMSDOnline/vstacklet-server-configs/archive/v0.5-beta.zip >/dev/null 2>&1;
unzip -qq v0.5-beta.zip
mv vstacklet-server-configs-0.5-beta /etc/nginx >>"${OUTTO}" 2>&1;
cp /etc/nginx-previous/uwsgi_params /etc/nginx-previous/fastcgi_params /etc/nginx >>"${OUTTO}" 2>&1;
# sed -i.bak -e
sed -i.bak -e "s/www www/www-data www-data/" \
  -e "s/logs\/error.log/\/var\/log\/nginx\/error.log/" \
  -e "s/logs\/access.log/\/var\/log\/nginx\/access.log/" /etc/nginx/nginx.conf
sed -i.bak -e "s/logs\/static.log/\/var\/log\/nginx\/static.log/" /etc/nginx/vstacklet/location/expires.conf

cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/$sitename.conf

echo
read -p "Do you want to create a self-signed SSL cert and configure HTTPS?  (Default: ${red}${bold}N${normal})  " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  conf1="listen [::]:443 ssl http2;\n    listen *:443 ssl http2;"
  conf2="include vstacklet\/directive-only\/ssl.conf;\n    ssl_certificate \/etc\/ssl\/certs\/$sitename.crt;\n    ssl_certificate_key \/etc\/ssl\/private\/$sitename.key;"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$sitename.key -out /etc/ssl/certs/$sitename.crt
  chmod 400 /etc/ssl/private/$sitename.key
  sed -i "s/conf1/$conf1/" /etc/nginx/conf.d/$sitename.conf
  sed -i "s/conf2/$conf2/" /etc/nginx/conf.d/$sitename.conf
  sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
  echo "${bold}${green} ... ssl cert creation completed ... ${normal}"
else
  echo "${cyan}Skipping SSL Certificate Creation...${normal}"
  sed -i "s/conf1/^$/" /etc/nginx/conf.d/$sitename.conf
  sed -i "s/conf2/^$/" /etc/nginx/conf.d/$sitename.conf
  sed -i "s/sitename/$sitename/" /etc/nginx/conf.d/$sitename.conf
fi
echo "${bold}${green}Creating Directory Structure for $sitename ... ${normal}"
mkdir -p /srv/www/$sitename/app/static >/dev/null 2>&1;
mkdir -p /srv/www/$sitename/app/templates >/dev/null 2>&1;
mkdir -p /srv/www/$sitename/public >/dev/null 2>&1;
# In NginX 1.9.x the use of conf.d seems appropriate
# ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
echo "${OK}"
echo
# }

# install varnish function (5)
# function _varnish() {
echo "${sub_title}Installing and Configuring Varnish ... ${normal}"
apt-get -y install varnish >>"${OUTTO}" 2>&1;
sed -i "s/127.0.0.1/$server_ip/" /etc/varnish/default.vcl
sed -i "s/6081/80/" /etc/default/varnish
echo "${OK}"
echo
# }

# install php function (6)
# function _php() {
echo "${sub_title}Installing and Adjusting PHP-FPM ... ${normal}"
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
# }

# adjust permissions function (7)
# function _perms() {
echo "${sub_title}Adjusting Permissions ... ${normal}"
chgrp -R www-data /srv/www/*
chmod -R g+rw /srv/www/*
sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'
echo "${OK}"
echo
# }

# install mariadb function (8)
# function _mariadb() {
echo "${sub_title}Installing MariaDB Drop-in Replacement ... ${normal}"
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mariadb-server >>"${OUTTO}" 2>&1;
echo "${OK}"
echo
# }

# install sendmail function (9)
# function _sendmail() {
echo "${sub_title}Preparing Sendmail Installation ... ${normal}"
apt-get -y install sendmail >>"${OUTTO}" 2>&1;
export DEBIAN_FRONTEND=noninteractive | /usr/sbin/sendmailconfig >>"${OUTTO}" 2>&1;
# add administrator email
echo "${bold}Add Administrator Email for Aliases Inclusion${normal}"
read -p "Email: " admin_email
echo "${green}${bold}$admin_email${normal} ${bold}is now the forwarding email for root mail${normal}"
echo
echo "${bold}${green} ... finalizing sendmail installation ... ${normal}"
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
# }

# finalize and restart services function (10)
# function _services() {
echo "${sub_title}Completing Installation & Restarting Services ... ${normal}"
echo
service nginx restart >>"${OUTTO}" 2>&1;
service varnish restart >>"${OUTTO}" 2>&1;
service php5-fpm restart >>"${OUTTO}" 2>&1;
service sendmail restart >>"${OUTTO}" 2>&1;
echo
# }

# function to show finished data (11)
# function _finished() {
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
echo
echo "${white}${on_green}    [vstacklet] Varnish LEMP Stack Installation Completed    ${normal}"
echo
echo "${bold}Visit ${green}http://${server_ip}/checkinfo.php${normal} ${bold}to verify your install. ${normal}"
echo "${bold}Remember to remove the checkinfo.php file after verification. ${normal}"
echo
date
# }

exit 0