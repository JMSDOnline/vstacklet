# vstacklet-server-stack.sh - v3.1.1078


### vstacklet::environment::init()

setup the environment and set variables

### vstacklet::args::process()

process the arguments passed to the script

#### arguments:

-  $1 - the argument to process
-  $2 - the value of the argument

#### parameters:

-  `--help` - show help
-  `--version` - show version
-  `--non-interactive` - run in non-interactive mode
-   `-e | --email` - mail address to use for the Let's Encrypt SSL certificate
-   `-p | --password` - assword to use for the MySQL root user
-  `-ftp | --ftp_port` - ort to use for the FTP server
-  `-ssh | --ssh_port` - ort to use for the SSH server
-  `-http | --http_port` - ort to use for the HTTP server
-  `-https | --https_port` - ort to use for the HTTPS server
-  `-mysql | --mysql_port` - ort to use for the MySQL server
-  `-varnishP | --varnish_port` - ort to use for the Varnish server
-  `-hn | --hostname` - ostname to use for the server
-  `-dmn | --domain` - omain name to use for the server
-  `-php | --php` - HP version to install (7.4, 8.1)
-  `-mc | --memcached` - nstall Memcached
-  `-nginx | --nginx` - nstall Nginx
-  `-varnish | --varnish` - nstall Varnish
-  `-hhvm | --hhvm` - nstall HHVM
-  `-mdb | --mariadb` - nstall MariaDB
-  `-rdb | --redis` - nstall Redis
-  `-pma | --phpmyadmin` - nstall phpMyAdmin
-  `-csf | --csf` - nstall CSF firewall
-  `-sendmail | --sendmail` - nstall Sendmail
-  `-wr | --web_root` - he web root directory to use for the server
-  `-wp | --wordpress` - nstall WordPress
-  `--reboot` - eboot the server after the installation

#### examples:

```
 ./vstacklet.sh "-e" "your@email.com" "-php" "8.1" "-nginx" "-mdb" "-pma" "-sendmail" "-wr" "[directory_name]"
```

### vstacklet::environment::functions()

stage various functions for the setup environment

### vstacklet::environment::checkroot()

check if the user is root

### vstacklet::environment::checkdistro()

check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11

### vstacklet::intro()

prints the intro message

### vstacklet::log::check()

check if the log file exists and create it if it doesn't

#### arguments:

- # @args: $1 - log file

### vstacklet::bashrc::set()

set ~/.bashrc and ~/.profile for vstacklet

*function has no parameters*

### vstacklet::hostname::set()

set system hostname

#### parameters:

-  $1 - -hn | --hostname
-  $2 - [hostname]

#### examples:

```
 ./vstacklet.sh -hn myhostname (or) ./vstacklet.sh --hostname myhostname
```

### vstacklet::webroot::set()

setting main web root directory

#### parameters:

-  $1 - -wr | --web_root
-  $2 - [web_root_directory]

#### examples:

```
 ./vstacklet.sh -wr /var/www/mydirectory (or) ./vstacklet.sh --web_root /srv/www/mydirectory
```

### vstacklet::ssh::set()

set ssh port to custom port (if nothing is set, default port is 22)

#### parameters:

-  $1 - -ssh | --ssh_port
-  $2 - [port]

#### examples:

```
 ./vstacklet.sh -ssh 2222 (or) ./vstacklet.sh --ssh_port 2222
##################################################################################
```

### vstacklet::block::ssdp()

blocks an insecure port 1900 that may lead to
DDoS masked attacks. Only remove this function if you absolutely
need port 1900. In most cases, this is a junk port.

*function has no arguments*

*function has no parameters*

### vstacklet::update::packages()

This function updates the package list and upgrades the system.

*function has no parameters*

### vstacklet::locale::set()

This function sets the locale to en_US.UTF-8
and sets the timezone to UTC.

### vstacklet::packages::softcommon()

This function updates the system packages and installs
the required common property packages for the vStacklet software.

*function has no arguments*

*function has no parameters*

### vstacklet::packages::depends()

This function installs the required software packages
for the vStacklet software.

*function has no arguments*

*function has no parameters*

### vstacklet::packages::keys()

This function sets the required software package keys
and sources for the vStacklet software.

*function has no arguments*

*function has no parameters*

### vstacklet::apt::update()

update apt sources and packages - this is a wrapper for apt-get update

*function has no arguments*

*function has no parameters*

### vstacklet::php::install()

install php and php modules (optional) (default: not installed)

#### parameters:

-  $1 - `-php | --php`
-  $2 - `[version]` - `7.4` | `8.1`

#### examples:

```
 ./vstacklet.sh -php 8.1
./vstacklet.sh --php 7.4
```

### vstacklet::nginx::install()

install nginx (optional) (default: not installed)

#### parameters:

-  $1 - `-nginx | --nginx`

#### examples:

```
 ./vstacklet.sh -nginx
./vstacklet.sh --nginx
##################################################################################
```

### vstacklet::hhvm::install()

install hhvm (optional) (default: not installed)

#### parameters:

-  $1 - `-hhvm | --hhvm`

#### examples:

```
 ./vstacklet.sh -hhvm 
./vstacklet.sh --hhvm
```

### vstacklet::permissions::adjust()

adjust permissions for web root

*function has no arguments*

*function has no parameters*

### vstacklet::varnish::install()

install varnish (optional)

#### parameters:

-  $1 - `-varnish | --varnish`
-  $2 - `-varnishP | --varnish_port`
-  $3 - `-http | --http_port`

#### examples:

```
 ./vstacklet.sh -varnish -varnishP 6081 -http 80
./vstacklet.sh --varnish --varnish_port 6081 --http_port 80
```

### vstacklet::ioncube::install()

install ioncube (optional)

#### parameters:

-  $1 - -ioncube | --ioncube

#### examples:

```
 ./vstacklet.sh -ioncube
(or) ./vstacklet.sh --ioncube
```


