# vstacklet-server-stack.sh - v3.1.1044


### vstacklet::environment::init()

setup the environment and set variables

### vstacklet::args::process()

process the arguments passed to the script

#### arguments:

-  --help|-h|-? show help
-  --version: show version
-  --non-interactive: run in non-interactive mode
-   -e|--email: email address to use for the Let's Encrypt SSL certificate
-   -p|--password: password to use for the MySQL root user
-  -ftp|--ftp_port: port to use for the FTP server
-  -ssh|--ssh_port: port to use for the SSH server
-  -http|--http_port: port to use for the HTTP server
-  -https|--https_port: port to use for the HTTPS server
-  -mysql|--mysql_port: port to use for the MySQL server
-  -varnishP|--varnish_port: port to use for the Varnish server
-  -hn|--hostname: hostname to use for the server
-  -dmn|--domain: domain name to use for the server
-  -php|--php: PHP version to install (7.4, 8.1)
-  -mc|--memcached: install Memcached
-  -nginx|--nginx: install Nginx
-  -varnish|--varnish: install Varnish
-  -hhvm|--hhvm: install HHVM
-  -mdb|--mariadb: install MariaDB
-  -rdb|--redis: install Redis
-  -pma|--phpmyadmin: install phpMyAdmin
-  -csf|--csf: install CSF firewall
-  -sendmail|--sendmail: install Sendmail
-  -wr|--web_root: the web root directory to use for the server
-  -wp|--wordpress: install WordPress
-  --reboot: reboot the server after the installation

#### example:

```
# @example: ./vstacklet.sh "-e" "your@email.com" "-php" "8.1" "-nginx" "-mdb" "-pma" "-sendmail" "-wr" "[directory_name]"
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

### vstacklet::hostname::set()

set system hostname

#### example:

```
# @example: ./vstacklet.sh -hn myhostname (or) ./vstacklet.sh --hostname myhostname
```

### vstacklet::webroot::set()

setting main web root directory

#### example:

```
# @example: ./vstacklet.sh -wr /var/www/mydirectory (or) ./vstacklet.sh --web_root /srv/www/mydirectory
```

### vstacklet::ssh::set()

set ssh port to custom port (if nothing is set, default port is 22)

#### example:

```
# @example: ./vstacklet.sh -ssh 2222 (or) ./vstacklet.sh --ssh_port 2222
```

### vstacklet::block::ssdp()

blocks an insecure port 1900 that may lead to
DDoS masked attacks. Only remove this function if you absolutely
need port 1900. In most cases, this is a junk port.

### vstacklet::update::packages()

This function updates the package list and upgrades the system.

### vstacklet::locale::set()

This function sets the locale to en_US.UTF-8
and sets the timezone to UTC.

### vstacklet::packages::softcommon()

This function updates the system packages and installs
the required common property packages for the vStacklet software.

### vstacklet::packages::depends()

This function installs the required software packages
for the vStacklet software.

### vstacklet::packages::keys()

This function sets the required software package keys
and sources for the vStacklet software.

### vstacklet::php::install()

#### example:

```
# @example: ./vstacklet.sh -php 8.1 (or) ./vstacklet.sh --php 7.4
```

### vstacklet::nginx::install()

#### example:

```
# @example: ./vstacklet.sh -nginx (or) ./vstacklet.sh --nginx
```

### vstacklet::hhvm::install()

#### example:

```
# @example: ./vstacklet.sh -hhvm (or) ./vstacklet.sh --hhvm
```

### vstacklet::varnish::install()

#### example:

```
# @example: ./vstacklet.sh -varnish -varnishP 6081 -http 80
```

### vstacklet::ioncube::install()

#### example:

```
# @example: ./vstacklet.sh -ioncube
```


