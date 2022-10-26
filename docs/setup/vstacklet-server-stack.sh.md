# vstacklet-server-stack.sh - v3.1.1171


### vstacklet::environment::init()

setup the environment and set variables

---

### vstacklet::args::process()

process the options and values passed to the script

#### options:

-  $1 - the option/flag to process
-  `--help` - show help
-  `--version` - show version
-  `--non-interactive` - run in non-interactive mode
-  `-e | --email` - mail address to use for the Let's Encrypt SSL certificate
-  `-p | --password` - password to use for the MySQL root user
-  `-ftp | --ftp_port` - port to use for the FTP server
-  `-ssh | --ssh_port` - port to use for the SSH server
-  `-http | --http_port` - port to use for the HTTP server
-  `-https | --https_port` - port to use for the HTTPS server
-  `-h | --hostname` - hostname to use for the server
-  `-d | --domain` - domain name to use for the server
-  `-php | --php` - PHP version to install (7.4, 8.1)
-  `-mc | --memcached` - install Memcached
-  `-hhvm | --hhvm` - install HHVM
-  `-nginx | --nginx` - install Nginx
-  `-varnish | --varnish` - install Varnish
-  `-varnishP | --varnish_port` - port to use for the Varnish server
-  `-mariadb | --mariadb` - install MariaDB
-  `-mariadbP | --mariadb_port` - port to use for the MariaDB server
-  `-mariadbU | --mariadb_user` - user to use for the MariaDB server
-  `-mariadbPw | --mariadb-password` - password to use for the MariaDB root user
-  `-redis | --redis` - install Redis
-  `-postgre | --postgre` - install PostgreSQL
-  `-pma | --phpmyadmin` - install phpMyAdmin
-  `-csf | --csf` - install CSF firewall
-  `-sendmail | --sendmail` - install Sendmail
-  `-wr | --web_root` - the web root directory to use for the server
-  `-wp | --wordpress` - install WordPress
-  `--reboot` - reboot the server after the installation

#### arguments:

-  $2 - the value of the option/flag

#### examples:

```
 ./vstacklet.sh "-e" "your@email.com" "-php" "8.1" "-nginx" "-mdb" "-pma" "-sendmail" "-wr" "[directory_name]"
```

---

### vstacklet::environment::functions()

stage various functions for the setup environment

---

### vstacklet::environment::checkroot()

check if the user is root

---

### vstacklet::environment::checkdistro()

check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11

---

### vstacklet::intro()

prints the intro message

---

### vstacklet::log::check()

check if the log file exists and create it if it doesn't

*function has no options*

*function has no arguments*

---

### vstacklet::bashrc::set()

set ~/.bashrc and ~/.profile for vstacklet

*function has no options*

*function has no arguments*

---

### vstacklet::hostname::set()

set system hostname
- hostname must be a valid hostname.
  - It can contain only letters, numbers, and hyphens.
  - It must start with a letter and end with a letter or number.
  - It must not contain consecutive hyphens.
  - If hostname is not provided, it will be set to the domain name if provided.
  - If domain name is not provided, it will be set to the server hostname.

#### options:

-  $1 - `-h | --hostname` (optional) (takes one argument)

#### arguments:

-  $2 - `[hostname]` - the hostname to set for the system (optional) 

#### examples:

```
 ./vstacklet.sh -h myhostname 
 ./vstacklet.sh --hostname myhostname
```

---

### vstacklet::webroot::set()

set main web root directory
- if the directory already exists, it will be used.
- if the directory does not exist, it will be created.
- if `-wr | --web_root` is not set, the default directory will be used.
  e.g. `/var/www/html/{public,logs,ssl}`

#### options:

-  $1 - `-wr | --web_root` (optional) (takes one argument)

#### arguments:

-  $2 - `[web_root_directory]` - (optional) (default: /var/www/html)

#### examples:

```
 ./vstacklet.sh -wr /var/www/mydirectory
 ./vstacklet.sh --web_root /srv/www/mydirectory
```

---

### vstacklet::ssh::set()

set ssh port to custom port (if nothing is set, default port is 22)

#### options:

-  $1 - `-ssh | --ssh_port` (optional) (takes one argument)

#### arguments:

-  $2 - `[port]` (default: 22) - the port to set for ssh

#### examples:

```
 ./vstacklet.sh -ssh 2222
 ./vstacklet.sh --ssh_port 2222
```

---

### vstacklet::block::ssdp()

blocks an insecure port 1900 that may lead to
DDoS masked attacks. Only remove this function if you absolutely
need port 1900. In most cases, this is a junk port.

*function has no options*

*function has no arguments*

---

### vstacklet::update::packages()

This function updates the package list and upgrades the system.

*function has no options*

*function has no arguments*

---

### vstacklet::locale::set()

This function sets the locale to en_US.UTF-8
and sets the timezone to UTC.

---

### vstacklet::packages::softcommon()

This function updates the system packages and installs
the required common property packages for the vStacklet software.

*function has no options*

*function has no arguments*

---

### vstacklet::packages::depends()

This function installs the required software packages
for the vStacklet software.

*function has no options*

*function has no arguments*

---

### vstacklet::packages::keys()

This function sets the required software package keys
and sources for the vStacklet software.
keys and sources are set for the following software packages:
- hhvm
- nginx
- varnish
- php
- mariadb

*function has no options*

*function has no arguments*

---

### vstacklet::apt::update()

update apt sources and packages - this is a wrapper for apt-get update

*function has no options*

*function has no arguments*

---

### vstacklet::php::install()

install php and php modules (optional) (default: not installed)
versioning
- php < "7.4" - not supported, deprecated
- php = "7.4" - supported
- php = "8.0" - superceded by php="8.1"
- php = "8.1" - supported
- chose either php or hhvm, not both
php modules are installed based on the following variables:
- `-php [php version]` (default: 8.1) - php version to install
- php_modules are installed based on the php version and neccessity
- the php_modules installed/enabled on vstacklet are:
  - "opcache"
  - "xml"
  - "igbinary"
  - "imagick"
  - "intl"
  - "mbstring"
  - "gmp"
  - "bcmath"
  - "msgpack"

#### options:

-  $1 - `-php | --php`

#### arguments:

-  $2 - `[version]` - `7.4` | `8.1`

#### examples:

```
 ./vstacklet.sh -php 8.1
 ./vstacklet.sh --php 7.4
```

---

### vstacklet::nginx::install()

install nginx (optional) (default: not installed)

#### options:

-  $1 - `-nginx | --nginx` (optional) (takes no arguments)

#### examples:

```
 ./vstacklet.sh -nginx
 ./vstacklet.sh --nginx
```

---

### vstacklet::hhvm::install()

install hhvm

#### options:

-  $1 - `-hhvm | --hhvm` (optional) (takes no arguments)

#### examples:

```
 ./vstacklet.sh -hhvm 
 ./vstacklet.sh --hhvm
```

---

### vstacklet::permissions::adjust()

adjust permissions for web root

*function has no options*

*function has no arguments*

---

### vstacklet::varnish::install()

install varnish and configure

#### options:

-  $1 - `-varnish | --varnish` (optional) (takes no arguments)
-  $2 - `-varnishP | --varnish_port` (optional) (takes one argument)
-  $3 - `-http | --http_port` (optional) (takes one argument)

#### examples:

```
 ./vstacklet.sh -varnish -varnishP 6081 -http 80
 ./vstacklet.sh --varnish --varnish_port 6081 --http_port 80
```

---

### vstacklet::ioncube::install()

install ioncube (optional)

#### options:

-  $1 - `-ioncube | --ioncube` (optional) (takes no arguments)

#### examples:

```
 ./vstacklet.sh -ioncube
 ./vstacklet.sh --ioncube
```

---

### vstacklet::mariadb::install()

install mariadb and configure

#### options:

-  $1 - -mariadb | --mariadb (optional) (takes no arguments)
-  $2 - -mariadbP | --mariadb_port (optional) (takes one argument)
-  $3 - -mariadbU | --mariadb_user (optional) (takes one argument)
-  $4 - -mariadbPw | --mariadb_password (optional) (takes one argument)

#### arguments:

-  $1 - [port] (optional) (default: 3306)
-  $2 - [user] (optional) (default: root)
-  $3 - [password] (optional) (default: password auto-generated)

#### examples:

```
 ./vstacklet.sh -mariadb -mariadbP 3306 -mariadbU root -mariadbPw password
 ./vstacklet.sh --mariadb --mariadb_port 3306 --mariadb_user root --mariadb_password password
```

---


