#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack
#
# shellcheck disable=SC2068,1090,1091,2034,2312
#################################################################################
#server_ip=$(ip addr show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1);
#hostname1=$(hostname -s);
#################################################################################
#Script Console Colors
green=$(tput setaf 2)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
standout=$(tput smso)
normal=$(tput sgr0)
title=${standout}
#################################################################################
if [[ -f /usr/bin/lsb_release ]]; then
	DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
elif [[ -f "/etc/debian_version" ]]; then
	DISTRO='Debian'
fi
#################################################################################

# Set TERM to ~/.bashrc
if ! grep -q "export TERM=xterm" /root/.bashrc; then
	echo "export TERM=xterm" >>/root/.bashrc
	source /root/.bashrc
fi

# Create vstacklet & backup directory strucutre
mkdir -p /backup/{directories,databases}

# Download VStacklet System Backup Executable
chmod +x /etc/vstacklet/packages/backup/*
mv vs-backup /usr/local/bin

function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15; }

function _askvstacklet() {
	echo
	echo
	echo "${title} Welcome to the VStacklet LEMP stack install kit! ${normal}"
	echo " version: ${VERSION}"
	echo
	echo "${bold} Enjoy the simplicity one script can provide to deliver ${normal}"
	echo "${bold} you the essentials of a finely tuned server environment.${normal}"
	echo "${bold} Nginx, Varnish, CSF, MariaDB w/ phpMyAdmin to name a few.${normal}"
	echo "${bold} Actively maintained and quality controlled.${normal}"
	echo
	echo
	echo -n "${bold}${yellow}Are you ready to install VStacklet for Ubuntu 18.04/20.04 & Debian 9/10/11 ?${normal} (${bold}${green}Y${normal}/n): "
	read -r responce
	case ${responce} in
	[yY] | [yY][Ee][Ss] | "") vstacklet=yes ;;
	[nN] | [nN][Oo]) vstacklet=no ;;
	*)
		echo "Please answer yes or no."
		_askvstacklet
		;;
	esac
}

clear

function _vstacklet() {
	if [[ ${vstacklet} == "yes" ]]; then
		DIR="/etc/vstacklet/setup/"
		if [[ ! -d ${DIR} ]]; then DIR="${PWD}"; fi
		. "${DIR}vstacklet-server-stack.sh"
	fi
}

function _novstacklet() {
	if [[ ${vstacklet} == "no" ]]; then
		echo "${bold}${cyan}Cancelling install. If you would like to run this installer in the future${normal}"
		echo "${bold}${cyan}type${normal} ${green}${bold}cd /etc/vstacklet/setup && ./vstacklet.sh${normal}"
		echo "${bold}${cyan}followed by tapping Enter on your keyboard.${normal}"
	fi
}

VERSION="3.1.0"

_askvstacklet
if [[ ${vstacklet} == "yes" ]]; then
	echo -n "${bold}Installing VStacklet Kit for Ubuntu 18.04, 20.04 & Debian 9, 10, and 11 support${normal} ... " && _vstacklet
elif [[ ${vstacklet} == "no" ]]; then
	_novstacklet
fi
