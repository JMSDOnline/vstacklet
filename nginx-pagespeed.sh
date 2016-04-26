#!/bin/bash
#
# [VStacklet Nginx+Pagespeed (nginx_1.9.15-1~wily~vstacklet) Installation Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack
#
#################################################################################
#Script Console Colors
black=$(tput setaf 0); red=$(tput setaf 1); green=$(tput setaf 2); yellow=$(tput setaf 3);
blue=$(tput setaf 4); magenta=$(tput setaf 5); cyan=$(tput setaf 6); white=$(tput setaf 7);
on_red=$(tput setab 1); on_green=$(tput setab 2); on_yellow=$(tput setab 3); on_blue=$(tput setab 4);
on_magenta=$(tput setab 5); on_cyan=$(tput setab 6); on_white=$(tput setab 7); bold=$(tput bold);
dim=$(tput dim); underline=$(tput smul); reset_underline=$(tput rmul); standout=$(tput smso);
reset_standout=$(tput rmso); normal=$(tput sgr0); alert=${white}${on_red}; title=${standout};
sub_title=${bold}${yellow}; repo_title=${black}${on_green};
#################################################################################
if [[ -f /usr/bin/lsb_release ]]; then
    DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
elif [ -f "/etc/redhat-release" ]; then
    DISTRO=$(egrep -o 'Fedora|CentOS|Red.Hat' /etc/redhat-release)
elif [ -f "/etc/debian_version" ]; then
    DISTRO=='Debian'
fi
#################################################################################
function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

# intro function (1)
function _intro() {
  echo
  echo
  echo "  [${repo_title}vstacklet${normal}] ${title} VStacklet Nginx+Pagespeed (nginx_1.9.15-1~wily~vstacklet) ${normal}  "
  echo "${alert} Configured and tested for Ubuntu 15.04, 15.10 & 16.04 ${normal}"
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
elif [[ ! "${rel}" =~ ("15.04"|"15.10"|"16.04") ]]; then
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

function _nginxenial() {
	mkdir -p ~/nginx/xenial/
	cd ~/nginx/xenial/
}

function _nginxdeb() {
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx_1.9.15-1~wily~vstacklet_amd64.deb > /dev/null 2>&1;
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-dbg_1.9.15-1~wily~vstacklet_amd64.deb > /dev/null 2>&1;
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-geoip_1.9.15-1~wily~vstacklet_amd64.deb > /dev/null 2>&1;
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-image-filter_1.9.15-1~wily~vstacklet_amd64.deb > /dev/null 2>&1;
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-njs_0.0.20160414.1c50334fbea6-1~xenial_amd64.deb > /dev/null 2>&1;
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-perl_1.9.15-1~wily~vstacklet_amd64.deb > /dev/null 2>&1;
	wget https://github.com/JMSDOnline/vstacklet/blob/master/nginx/xenial/nginx-module-xslt_1.9.15-1~wily~vstacklet_amd64.deb > /dev/null 2>&1;
	  echo "${OK}"
}

function _buildnginx() {
	dpkg -i nginx_*amd64.deb > /dev/null 2>&1;
	mkdir -p /etc/nginx/ngx_pagespeed_cache
	chown -R www-data:www-data /etc/nginx/ngx_pagespeed_cache
	cd /etc/nginx/
	sed -i '68i  pagespeed 	on;' nginx.conf
	sed -i '69i  pagespeed 	FileCachePath /etc/nginx/ngx_pagespeed_cache;' nginx.conf
	  echo "${OK}"
}

function _finish() {
	service nginx restart
  	echo "${OK}"
}

OK=$(echo -e "[ ${bold}${green}DONE${normal} ]")

_intro
_checkroot
_logcheck
_nginxenial
echo -n "${bold}Downloading Nginx Packages${normal} ... ";_nginxdeb
echo -n "${bold}Building Nginx with Pagespeed${normal} ... ";_buildnginx
echo -n "${bold}Restarting Nginx${normal} ... ";_finish
