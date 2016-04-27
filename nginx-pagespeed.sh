#!/bin/bash
#
# [VStacklet Nginx+Pagespeed Compilation & Installation Script]
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
function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

# intro function (1)
function _intro() {
  echo
  echo
  echo "	[${repo_title}vstacklet${normal}] ${title} Nginx+Pagespeed Compilation & Installation Script ${normal}  "
  echo "	   ${alert} Configured and tested for Ubuntu 14.04, 15.10 & 16.04 ${normal}"
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
elif [[ ! "${rel}" =~ ("14.04"|"15.10"|"16.04") ]]; then
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

function _aupdate() {
	apt-get -y update
}

# package and repo addition (a) _install common properties_
function _softcommon() {
	apt-get -y install software-properties-common python-software-properties apt-transport-https >>"${OUTTO}" 2>&1;
	echo "${OK}"
	echo
}

# package and repo addition (b) _install softwares and packages_
function _depends() {
	apt-get -y install dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev unzip curl
}

# package and repo addition (c) _add signed keys_
function _keys() {
	curl -s http://nginx.org/keys/nginx_signing.key | apt-key add - > /dev/null 2>&1;
	echo "${OK}"
	echo
}

# package and repo addition (d) _add respo sources_
function _repos() {
if [[ ${rel} =~ ("15.04"|"15.10"|"16.04") ]]; then
  cat >/etc/apt/sources.list.d/nginx-vstacklet.list<<EOF
deb http://nginx.org/packages/mainline/ubuntu/ wily nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ wily nginx
EOF
fi
if [[ ${rel} = "14.04" ]]; then
    cat >/etc/apt/sources.list.d/nginx-vstacklet.list<<EOF
deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx
EOF
fi
}

function _bupdate() {
	apt-get -y update
}

function _buildnginx() {
	mkdir -p ~/new/nginx_source/
	cd ~/new/nginx_source/
	apt-get -y source nginx
	apt-get -y build-dep nginx
}

function _buildpagespeed() {
	mkdir -p ~/new/ngx_pagespeed/
	cd ~/new/ngx_pagespeed/
	wget --no-check-certificate https://github.com/pagespeed/ngx_pagespeed/archive/master.zip
	unzip master.zip
	cd ngx_pagespeed-master/
	echo '#!/bin/bash' >> bush.sh
	grep wget config > bush.sh
	sed -i 's/echo "     $ w/w/' bush.sh
	sed -i 's/gz"/gz/' bush.sh
	bash bush.sh
	tar -xzf *.tar.gz
	cd ~/new/nginx_source/nginx-*/debian/
    sed -i '22 a \ \ \ \ \ \--add-module=../../ngx_pagespeed/ngx_pagespeed-master \\' rules
    if [[ "${rel}" = "14.04" ]]; then
    	sed -i '61 a \ \ \ \ \ \--add-module=../../ngx_pagespeed/ngx_pagespeed-master \\' rules
    fi
    if [[ "${rel}" =~ ("15.04"|"15.10") ]]; then
        curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/development/nginx/wily/changelog
    	curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/development/nginx/wily/rules
    fi
    if [[ "${rel}" = "16.04" ]]; then
        curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/development/nginx/xenial/changelog
    	curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/development/nginx/xenial/rules
        cd ~/new/nginx_source/nginx-*/src/core
        sed -i 's/"nginx\/\" NGINX_VERSION/"nginx\/\" NGINX_VERSION ~ vstacklet/g' nginx.h
        cd
    fi
}

function _compnginx() {
	cd ~/new/nginx_source/nginx-*/
	dpkg-buildpackage -b
	cd ~/new/nginx_source/
	dpkg -i nginx_*amd64.deb
}

function _setpsng() {
	mkdir -p /etc/nginx/ngx_pagespeed_cache
	chown -R www-data:www-data /etc/nginx/ngx_pagespeed_cache
	cd /etc/nginx/
	sed -i '30i \ \ \ \ \pagespeed on;' nginx.conf
	sed -i '31i \ \ \ \ \pagespeed FileCachePath /etc/nginx/ngx_pagespeed_cache;' nginx.conf
}

function _restartservice() {
	service nginx restart
}

function _psngprooftest() {
	curl -I -p http://localhost|grep X-Page-Speed
}


clear

S=$(date +%s)
OK=$(echo -e "[ ${bold}${green}DONE${normal} ]")

_intro
_checkroot
_logcheck
_aupdate
_softcommon
_depends
_keys
_repos
_bupdate
_buildnginx
_buildpagespeed
_compnginx
_setpsng
_restartservice
_psngprooftest

exit
