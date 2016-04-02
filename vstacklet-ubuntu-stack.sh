#!/bin/bash
#
# [VStacklet Varnish LEMP Stack Installation Script]
#
# GitHub:   https://github.com/JMSDOnline/vstacklet
# Author:   Jason Matthews
# URL:      https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack
#
# find server IP and server hostname for nginx configuration
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
function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

function _bashrc() {
cat >/root/.bashrc<<'EOF'
case $- in
    *i*) ;;
      *) return;;
esac

BASHRCVERSION="23.2"
EDITOR=nano; export EDITOR=nano
USER=`whoami`
TMPDIR=$HOME/.tmp/
HOSTNAME=`hostname -s`
IDUSER=`id -u`
PROMPT_COMMAND='echo -ne "\033]0;${USER}(${IDUSER})@${HOSTNAME}: ${PWD}\007"'
export LS_COLORS='rs=0:di=01;33:ln=00;36:mh=00:pi=40;33:so=00;35:do=00;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.log=02;34:*.torrent=02;37:*.conf=02;34:*.sh=00;32:*.tar=00;31:*.tgz=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.tlz=00;31:*.txz=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.lz=00;31:*.xz=00;31:*.bz2=00;31:*.tbz=00;31:*.tbz2=00;31:*.bz=00;31:*.tz=00;31:*.tcl=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.rar=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.jpg=00;35:*.jpeg=00;35:*.gif=00;35:*.bmp=00;35:*.pbm=00;35:*.pgm=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.tiff=00;35:*.png=00;35:*.svg=00;35:*.svgz=00;35:*.mng=00;35:*.pcx=00;35:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.cgm=00;35:*.emf=00;35:*.axv=00;35:*.anx=00;35:*.ogv=00;35:*.ogx=00;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
export TERM=xterm;TERM=xterm
export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/vstacklet/.bin/
TPUT=`which tput`
BC=`which bc`
if [ ! -e $TPUT ]; then echo "tput is missing, please install it (yum install tput/apt-get install tput)";fi
if [ ! -e $BC ]; then echo "bc is missing, please install it (yum install bc/apt-get install bc)";fi
DFSCRIPT="${HOME}/.du.sh"
if [ ! -e $DFSCRIPT ]; then
cat >"$DFSCRIPT"<<'DS'
#!/bin/bash
ALERT=${BWhite}${On_Red};RED='\e[0;31m';YELLOW='\e[1;33m'
GREEN='\e[0;32m';RESET="\e[00m";BWhite='\e[1;37m';On_Red='\e[41m'
NCPU=$(grep -c 'processor' /proc/cpuinfo)
SLOAD=$(( 100*${NCPU} ));MLOAD=$(( 200*${NCPU} ));XLOAD=$(( 400*${NCPU} ))
function load() { SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.'); echo -n $((10#$SYSLOAD)); }
SYSLOAD=$(load)
if [ ${SYSLOAD} -gt ${XLOAD} ]; then echo -en ${ALERT}
elif [ ${SYSLOAD} -gt ${MLOAD} ]; then echo -en ${RED}
elif [ ${SYSLOAD} -gt ${SLOAD} ]; then echo -en ${YELLOW}
else echo -en ${GREEN} ;fi
let TotalBytes=0
for Bytes in $(ls -l | grep "^-" | awk '{ print $5 }')
do
   let TotalBytes=$TotalBytes+$Bytes
done
if [ $TotalBytes -lt 1024 ]; then
     TotalSize=$(echo -e "scale=1 \n$TotalBytes \nquit" | bc)
     suffix="b"
else if [ $TotalBytes -lt 1048576 ]; then
     TotalSize=$(echo -e "scale=1 \n$TotalBytes/1024 \nquit" | bc)
     suffix="kb"
  else if [ $TotalBytes -lt 1073741824 ]; then
     TotalSize=$(echo -e "scale=1 \n$TotalBytes/1048576 \nquit" | bc)
     suffix="Mb"
else
     TotalSize=$(echo -e "scale=1 \n$TotalBytes/1073741824 \nquit" | bc)
     suffix="Gb"
fi
fi
fi
echo $TotalSize$suffix
DS
chmod u+x $DFSCRIPT
fi

alias ls='ls --color=auto'
alias dir='ls --color=auto'
alias vdir='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

function normal {
if [ `id -u` == 0 ] ; then
  DG="$(tput bold ; tput setaf 7)";LG="$(tput bold;tput setaf 7)";NC="$(tput sgr0)"
  export PS1='[\[$LG\]\u\[$NC\]@\[$LG\]\h\[$NC\]]:(\[$LG\]\[$BN\]$($DFSCRIPT)\[$NC\])\w\$ '
else
  DG="$(tput bold;tput setaf 0)"
  LG="$(tput setaf 7)"
  NC="$(tput sgr0)"
  export PS1='[\[$LG\]\u\[$NC\]@\[$LG\]\h\[$NC\]]:(\[$LG\]\[$BN\]$($DFSCRIPT)\[$NC\])\w\$ '
fi
}

case $TERM in
  rxvt*|screen*|cygwin)
    export PS1='\u\@\h\w'
  ;;
  xterm*|linux*|*vt100*|cons25)
    normal
  ;;
  *)
    normal
        ;;
esac

function rarit() { rar a -m5 -v1m $1 $1; }
function paste() { $* | curl -F 'sprunge=<-' http://sprunge.us ; }
function disktest() { dd if=/dev/zero of=test bs=64k count=16k conv=fdatasync;rm -rf test ; }
function newpass() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }
function fixhome() { chmod -R u=rwX,g=rX,o= "$HOME" ;}

transfer() {
  if [ $# -eq 0 ]; then
    echo "No arguments specified. Usage: transfer /tmp/test.md OR: cat /tmp/test.md | transfer test.md"
    return 1
  fi
tmpfile=$(mktemp -t transferXXX )
if tty -s
  then
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
  else
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile
fi
cat $tmpfile
rm -f $tmpfile
}

function swap() {
local TMPFILE=tmp.$$
    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1
    mv "$1" $TMPFILE; mv "$2" "$1"; mv $TMPFILE "$2"
}

if [ -e /etc/bash_completion ] ; then source /etc/bash_completion; fi
if [ -e ~/.custom ]; then source ~/.custom; fi
EOF
}

# intro function (1)
function _intro() {
  echo
  echo
  echo "  [${repo_title}vstacklet${normal}] ${title} Varnish LEMP Stack Installation ${normal}  "
  echo "${alert} Configured and tested for Ubuntu 14.04, 15.04 & 15.10 ${normal}"
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

# package and repo addition (4) _update and upgrade_
function _updates() {
  if lsb_release >>"${OUTTO}" 2>&1; then ver=$(lsb_release -c|awk '{print $2}')
  else
    apt-get -y -q install lsb-release >>"${OUTTO}" 2>&1
    if [[ -e /usr/bin/lsb_release ]]; then ver=$(lsb_release -c|awk '{print $2}')
    else echo "failed to install lsb-release from apt-get, please install manually and re-run script"; exit
    fi
  fi

if [[ $DISTRO == Debian ]]; then
cat >/etc/apt/sources.list<<EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL DEBIAN REPOS                             #
#------------------------------------------------------------------------------#


###### Debian Main Repos
deb http://ftp.nl.debian.org/debian testing main contrib non-free
deb-src http://ftp.nl.debian.org/debian testing main contrib non-free

###### Debian Update Repos
deb http://ftp.debian.org/debian/ ${ver}-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ ${ver}-updates main contrib non-free
deb http://security.debian.org/ ${ver}/updates main contrib non-free
deb-src http://security.debian.org/ ${ver}/updates main contrib non-free

#Debian Backports Repos
#http://backports.debian.org/debian-backports squeeze-backports main
EOF

else
cat >/etc/apt/sources.list<<EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#


###### Ubuntu Main Repos
deb http://nl.archive.ubuntu.com/ubuntu/ ${ver} main restricted universe multiverse
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${ver} main restricted universe multiverse

###### Ubuntu Update Repos
deb http://nl.archive.ubuntu.com/ubuntu/ ${ver}-security main restricted universe multiverse
deb http://nl.archive.ubuntu.com/ubuntu/ ${ver}-updates main restricted universe multiverse
deb http://nl.archive.ubuntu.com/ubuntu/ ${ver}-backports main restricted universe multiverse
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${ver}-security main restricted universe multiverse
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${ver}-updates main restricted universe multiverse
deb-src http://nl.archive.ubuntu.com/ubuntu/ ${ver}-backports main restricted universe multiverse

###### Ubuntu Partner Repo
deb http://archive.canonical.com/ubuntu ${ver} partner
deb-src http://archive.canonical.com/ubuntu ${ver} partner
EOF
fi

  echo -n "Updating system ... "

  if [[ $DISTRO == Debian ]]; then
    export DEBIAN_FRONTEND=noninteractive
    yes '' | apt-get update >>"${OUTTO}" 2>&1
    apt-get -y purge samba samba-common >>"${OUTTO}" 2>&1
    yes '' | apt-get upgrade >>"${OUTTO}" 2>&1
  else
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y --force-yes update >>"${OUTTO}" 2>&1
    apt-get -y purge samba samba-common >>"${OUTTO}" 2>&1
    apt-get -y --force-yes upgrade >>"${OUTTO}" 2>&1
  fi
    #if [[ -e /etc/ssh/sshd_config ]]; then
    #  echo "Port 2222" /etc/ssh/sshd_config
    #  sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
    #  service ssh restart >>"${OUTTO}" 2>&1
    #fi
  echo "${OK}"
  clear
}

# setting locale function (5)
function _locale() {
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo "LANGUAGE=en_US.UTF-8">>/etc/default/locale
echo "LC_ALL=en_US.UTF-8" >>/etc/default/locale
  if [[ -e /usr/sbin/locale-gen ]]; then locale-gen >>"${OUTTO}" 2>&1
  else
    apt-get update >>"${OUTTO}" 2>&1
    apt-get install locales locale-gen -y --force-yes >>"${OUTTO}" 2>&1
    locale-gen >>"${OUTTO}" 2>&1
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    export LANGUAGE="en_US.UTF-8"
  fi
}

# system packages and repos function (6)
# Update packages and add MariaDB, Varnish 4, and Nginx 1.9.9 (mainline) repositories
function _softcommon() {
  # package and repo addition (a) _install common properties_
  apt-get -y install software-properties-common python-software-properties apt-transport-https >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# package and repo addition (b) _install softwares and packages_
function _depends() {
  apt-get -y install nano unzip dos2unix htop iotop bc libwww-perl dnsutils sudo >>"${OUTTO}" 2>&1;
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

# setting main web root directory function (7)
function _asksitename() {
#################################################################
# You may now optionally name your main web root directory.
# If you choose to not name your main websites root directory,
# then your servers hostname will be used as a default.
#################################################################
  echo "  You may now optionally name your main web root directory."
  echo "  If you choose to not name your main websites root directory,"
  echo "  then your servers hostname will be used as a default."
  echo "  Default: /srv/www/${green}${hostname1}${normal}/public/"
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
    read -p "${bold}Name for your main websites root directory ${normal} : " sitename
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

# install nginx function (8)
function _nginx() {
  apt-get -y install nginx >>"${OUTTO}" 2>&1;
  update-rc.d nginx defaults >>"${OUTTO}" 2>&1;
  service nginx stop >>"${OUTTO}" 2>&1;
  mv /etc/nginx /etc/nginx-previous >>"${OUTTO}" 2>&1;
  wget https://github.com/JMSDOnline/vstacklet/raw/master/vstacklet-server-configs.zip >/dev/null 2>&1;
  unzip vstacklet-server-configs.zip -d ~/vstacklet-server-configs >/dev/null 2>&1;
  mv vstacklet-server-configs /etc/nginx >>"${OUTTO}" 2>&1;
  rm -rf vstacklet-server-configs*
  cp /etc/nginx-previous/uwsgi_params /etc/nginx-previous/fastcgi_params /etc/nginx >>"${OUTTO}" 2>&1;
  mkdir -p /etc/nginx-cache
  chown -R www-data /etc/nginx-cache
  chgrp -R www-data /etc/nginx-cache
  chmod -R g+rw /etc/nginx-cache
  sh -c 'find /etc/nginx-cache -type d -print0 | sudo xargs -0 chmod g+s'
  # rename default.conf template
  if [[ $sitename -eq yes ]];then
    cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/${sitename}.conf
    # build applications web root directory if sitename is provided
    mkdir -p /srv/www/${sitename}/logs >/dev/null 2>&1;
    mkdir -p /srv/www/${sitename}/ssl >/dev/null 2>&1;
    mkdir -p /srv/www/${sitename}/public >/dev/null 2>&1;
  else
    cp /etc/nginx/conf.d/default.conf.save /etc/nginx/conf.d/${hostname1}.conf
    # build applications web root directory if no sitename is provided
    mkdir -p /srv/www/${hostname1}/logs >/dev/null 2>&1;
    mkdir -p /srv/www/${hostname1}/ssl >/dev/null 2>&1;
    mkdir -p /srv/www/${hostname1}/public >/dev/null 2>&1;
  fi
  echo "${OK}"
  echo
}

# adjust permissions function (9)
function _perms() {
  chgrp -R www-data /srv/www/*
  chmod -R g+rw /srv/www/*
  sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'
  echo "${OK}"
  echo
}

# install varnish function (10)
function _varnish() {
  apt-get -y install varnish >>"${OUTTO}" 2>&1;
  cd /etc/varnish
  mv default.vcl default.vcl.ORIG
  curl -LO https://raw.github.com/JMSDOnline/vstacklet/master/varnish/default.vcl >/dev/null 2>&1;
  cd
  sed -i "s/127.0.0.1/${server_ip}/" /etc/varnish/default.vcl
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

# install php function (11)
function _php() {
  apt-get -y install php5-common php5-mysqlnd php5-curl php5-gd php5-cli php5-fpm php-pear php5-dev php5-imap php5-mcrypt >>"${OUTTO}" 2>&1;
  sed -i.bak -e "s/post_max_size = 8M/post_max_size = 64M/" \
    -e "s/upload_max_filesize = 2M/upload_max_filesize = 92M/" \
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
  if [[ $sitename -eq yes ]];then
    echo '<?php phpinfo(); ?>' > /srv/www/${sitename}/public/checkinfo.php
  else
    echo '<?php phpinfo(); ?>' > /srv/www/${hostname1}/public/checkinfo.php
  fi
  echo "${OK}"
  echo
}

# install ioncube loader function (12)
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

# install mariadb function (13)
function _mariadb() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get -q -y install mariadb-server >>"${OUTTO}" 2>&1;
  echo "${OK}"
  echo
}

# install phpmyadmin function (14)
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
    if [[ $sitename -eq yes ]];then
      # create a sym-link to live directory.
      ln -s /usr/share/phpmyadmin /srv/www/${sitename}/public
    else
      # create a sym-link to live directory.
      ln -s /usr/share/phpmyadmin /srv/www/${hostname1}/public
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

# install and adjust config server firewall function (15)
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
    apt-get -y install e2fsprogs >/dev/null 2>&1;
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
    echo "exe:/usr/sbin/nginx" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/varnishd" >> /etc/csf/csf.pignore;
    echo "exe:/usr/sbin/rsyslogd" >> /etc/csf/csf.pignore;
    echo "exe:/lib/systemd/systemd-timesyncd" >> /etc/csf/csf.pignore;
    echo "exe:/lib/systemd/systemd-resolved" >> /etc/csf/csf.pignore;
    # modify csf conf - make suitable changes for non-cpanel environment
    sed -i.bak -e 's/TESTING = "1"/TESTING = "0"/' \
               -e 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/' \
               -e 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/' \
               -e 's/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,465,587,873,993,995,8080"/' \
               -e 's/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2082,2083,2086,2087,2095,2096"/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,8080"/' \
               -e 's/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP6_OUT = "20,21,22,25,37,43,53,80,110,113,443,465,587,873,993,995,8080"/' \
               -e 's/DENY_TEMP_IP_LIMIT = "100"/DENY_TEMP_IP_LIMIT = "1000"/' \
               -e 's/SMTP_ALLOWUSER = "cpanel"/SMTP_ALLOWUSER = "root"/' \
               -e 's/PT_USERMEM = "200"/PT_USERMEM = "500"/' \
               -e 's/PT_USERTIME = "1800"/PT_USERTIME = "7200"/' /etc/csf/csf.conf;
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
131.0.72.0/22
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

# install sendmail function (16)
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
# enhance configuration function (17)
function _locenhance() {
  if [[ $sitename -eq yes ]];then
    locconf1="include vstacklet\/location\/cache-busting.conf;"
    sed -i "s/locconf1/${locconf1}/" /etc/nginx/conf.d/${sitename}.conf
    locconf2="include vstacklet\/location\/cross-domain-fonts.conf;"
    sed -i "s/locconf2/${locconf2}/" /etc/nginx/conf.d/${sitename}.conf
    locconf3="include vstacklet\/location\/expires.conf;"
    sed -i "s/locconf3/${locconf3}/" /etc/nginx/conf.d/${sitename}.conf
    locconf4="include vstacklet\/location\/protect-system-files.conf;"
    sed -i "s/locconf4/${locconf4}/" /etc/nginx/conf.d/${sitename}.conf
  else
    locconf1="include vstacklet\/location\/cache-busting.conf;"
    sed -i "s/locconf1/${locconf1}/" /etc/nginx/conf.d/${hostname1}.conf
    locconf2="include vstacklet\/location\/cross-domain-fonts.conf;"
    sed -i "s/locconf2/${locconf2}/" /etc/nginx/conf.d/${hostname1}.conf
    locconf3="include vstacklet\/location\/expires.conf;"
    sed -i "s/locconf3/${locconf3}/" /etc/nginx/conf.d/${hostname1}.conf
    locconf4="include vstacklet\/location\/protect-system-files.conf;"
    sed -i "s/locconf4/${locconf4}/" /etc/nginx/conf.d/${hostname1}.conf
  fi
  echo "${OK}"
  echo
}

# Round 2 - Security
# optimize security configuration function (18)
function _security() {
  if [[ $sitename -eq yes ]];then
    secconf1="include vstacklet\/directive-only\/sec-bad-bots.conf;"
    sed -i "s/secconf1/${secconf1}/" /etc/nginx/conf.d/${sitename}.conf
    secconf2="include vstacklet\/directive-only\/sec-file-injection.conf;"
    sed -i "s/secconf2/${secconf2}/" /etc/nginx/conf.d/${sitename}.conf
    secconf3="include vstacklet\/directive-only\/sec-php-easter-eggs.conf;"
    sed -i "s/secconf3/${secconf3}/" /etc/nginx/conf.d/${sitename}.conf
  else
    secconf1="include vstacklet\/directive-only\/sec-bad-bots.conf;"
    sed -i "s/secconf1/${secconf1}/" /etc/nginx/conf.d/${hostname1}.conf
    secconf2="include vstacklet\/directive-only\/sec-file-injection.conf;"
    sed -i "s/secconf2/${secconf2}/" /etc/nginx/conf.d/${hostname1}.conf
    secconf3="include vstacklet\/directive-only\/sec-php-easter-eggs.conf;"
    sed -i "s/secconf3/${secconf3}/" /etc/nginx/conf.d/${hostname1}.conf
  fi
  echo "${OK}"
  echo
}

# create self-signed certificate function (19)
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
    if [[ $sitename -eq yes ]];then
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/${sitename}.key -out /etc/ssl/certs/${sitename}.crt
      chmod 400 /etc/ssl/private/${sitename}.key
      sed -i -e "s/# listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/" \
             -e "s/# listen *:443 ssl http2;/listen *:443 ssl http2;/" \
             -e "s/# include vstacklet\/directive-only\/ssl.conf;/include vstacklet\/directive-only\/ssl.conf;/" \
             -e "s/# ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/" \
             -e "s/# ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/" /etc/nginx/conf.d/${sitename}.conf
      sed -i "s/sitename/${sitename}/" /etc/nginx/conf.d/${sitename}.conf
    else
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /srv/www/${hostname1}/ssl/${hostname1}.key -out /srv/www/${hostname1}/ssl/${hostname1}.crt
      chmod 400 /etc/ssl/private/${hostname1}.key
      sed -i -e "s/# listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/" \
             -e "s/# listen *:443 ssl http2;/listen *:443 ssl http2;/" \
             -e "s/# include vstacklet\/directive-only\/ssl.conf;/include vstacklet\/directive-only\/ssl.conf;/" \
             -e "s/# ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/ssl_certificate \/srv\/www\/sitename\/ssl\/sitename.crt;/" \
             -e "s/# ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/ssl_certificate_key \/srv\/www\/sitename\/ssl\/sitename.key;/" /etc/nginx/conf.d/${hostname1}.conf
      sed -i "s/sitename/${hostname1}/" /etc/nginx/conf.d/${hostname1}.conf
    fi
    echo "${OK}"
    echo
  fi
}

function _nocert() {
  if [[ ${cert} == "no" ]]; then
    if [[ $sitename -eq yes ]];then
      sed -i "s/sitename/${sitename}/" /etc/nginx/conf.d/${sitename}.conf
    else
      sed -i "s/sitename/${hostname1}/" /etc/nginx/conf.d/${hostname1}.conf
    fi
    echo "${cyan}Skipping SSL Certificate Creation...${normal}"
    echo
  fi
}

# finalize and restart services function (20)
function _services() {
  service apache2 stop >>"${OUTTO}" 2>&1;
  service nginx restart >>"${OUTTO}" 2>&1;
  service varnish restart >>"${OUTTO}" 2>&1;
  service php5-fpm restart >>"${OUTTO}" 2>&1;
  if [[ $sendmail -eq yes ]];then
    service sendmail restart >>"${OUTTO}" 2>&1;
  fi
  if [[ $csf -eq yes ]];then
    service lfd restart >>"${OUTTO}" 2>&1;
    csf -r >>"${OUTTO}" 2>&1;
  fi
  echo "${OK}"
  echo
}

# function to show finished data (21)
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
_bashrc
_intro
_checkroot
_logcheck
_updates;
#_locale;
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
