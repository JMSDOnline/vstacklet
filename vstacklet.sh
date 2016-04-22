#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack
#
#################################################################################
server_ip=$(ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1);
hostname1=$(hostname -s);
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


# Create vstacklet & backup directory strucutre
mkdir -p vstacklet /backup/{directories,databases}
cd vstacklet

# Download the needed scripts for VStacklet
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/vstacklet-ubuntu-stack.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/files-backup.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/database-backup.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/package-backups.sh >/dev/null 2>&1;
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/backup-cleanup.sh >/dev/null 2>&1;

# Convert all shell scripts to executable
chmod +x *.sh
cd

# Download VStacklet System Backup Executable
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/vs-backup >/dev/null 2>&1;
chmod +x vs-backup
mv vs-backup /usr/local/bin

function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

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
  echo -n "${bold}${yellow}Are you ready to install VStacklet for Ubuntu 14.04 - 16.04?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) vstacklet=yes ;;
    [nN] | [nN][Oo] ) vstacklet=no ;;
  esac
}

clear

function _vstacklet() {
  if [[ ${vstacklet} == "yes" ]]; then
    DIR="vstacklet"
    if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
      . "$DIR/vstacklet-ubuntu-stack.sh"
  fi
}

function _novstacklet() {
  if [[ ${vstacklet} == "no" ]]; then
    echo "${bold}${cyan}Cancelling install. If you would like to run this installer in the future${normal}"
    echo "${bold}${cyan}type${normal} ${green}${bold}./vstacklet.sh${normal} - ${bold}${cyan}followed by tapping Enter on your keyboard.${normal}"
  fi
}

_askvstacklet;if [[ ${vstacklet} == "yes" ]]; then echo -n "${bold}Installing VStacklet Kit for 14.04, 15.04, 15.10 and 16.04 support${normal} ... ";_vstacklet; elif [[ ${vstacklet} == "no" ]]; then _novstacklet;  fi
