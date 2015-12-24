#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Prep Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com
#

#Script Console Colors
black=$(tput setaf 0);red=$(tput setaf 1);green=$(tput setaf 2);yellow=$(tput setaf 3);blue=$(tput setaf 4);magenta=$(tput setaf 5);cyan=$(tput setaf 6);white=$(tput setaf 7);on_red=$(tput setab 1);on_green=$(tput setab 2);on_yellow=$(tput setab 3);on_blue=$(tput setab 4);on_magenta=$(tput setab 5);on_cyan=$(tput setab 6);on_white=$(tput setab 7);bold=$(tput bold);dim=$(tput dim);underline=$(tput smul);reset_underline=$(tput rmul);standout=$(tput smso);reset_standout=$(tput rmso);normal=$(tput sgr0);alert=${white}${on_red};title=${standout};sub_title=${bold}${yellow};repo_title=${black}${on_green};


# Create vstacklet & backup directory strucutre
mkdir -p vstacklet /backup/{directories,databases}
cd vstacklet

# Download the needed scripts for VStacklet
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet/master/vstacklet-trusty-stack.sh >/dev/null 2>&1;
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

function _askubuntu() {
  echo -n "${bold}${yellow}Do you want to install VStacklet for Ubuntu 15.x ?${normal} (${bold}${green}Y${normal}/n): "
  read responce
  case $responce in
    [yY] | [yY][Ee][Ss] | "" ) ubuntu=yes ;;
    [nN] | [nN][Oo] ) ubuntu=no ;;
  esac
}

function _ubuntu15x() {
  if [[ ${ubuntu} == "yes" ]]; then
    DIR="vstacklet"
    if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
      . "$DIR/vstacklet-ubuntu-stack.sh"
  fi
}

function _ubuntutrusty() {
  if [[ ${ubuntu} == "yes" ]]; then
    DIR="vstacklet"
    if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
      . "$DIR/vstacklet-trusty-stack.sh"
  fi
}

_askubuntu;if [[ ${ubuntu} == "yes" ]]; then echo -n "${bold}Installing VStacklet Kit for 15.04 and 15.10 support${normal} ... ";_ubuntu15x; elif [[ ${ubuntu} == "no" ]]; then  echo -n "${bold}Installing VStacklet Kit for 14.04 support${normal} ... ";_ubuntutrusty;  fi