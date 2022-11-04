# vstacklet-server-stack.sh - v3.1.1835


---

This script is designed to be run on a fresh Ubuntu 18.04/20.04 or
Debian 9/10/11 server. I have done my best to keep it tidy and with as much
error checking as possible. Couple this with loads of comments and you should
have a pretty good idea of what is going on. If you have any questions,
comments, or suggestions, please feel free to open an issue on GitHub.

---

vStacklet will install and configure the following:
- NGinx 1.23.+ (HTTP Server)
- PHP 7.4 (FPM) with common extensions
- PHP 8.1 (FPM) with common extensions
- MariaDB 10.6.+ (MySQL Database)
- Varnish 7.2.+ (HTTP Cache)
- CSF 14.+ (Config Server Firewall)
- and more!

---

Important Links:
- :pencil: GITHUB REPO:   https://github.com/JMSDOnline/vstacklet
- :bug: ISSUE TRACKER: https://github.com/JMSDOnline/vstacklet/issues

---

:book: vStacklet Function Documentation:
- [vstacklet::environment::init()](#vstackletenvironmentinit)
- [vstacklet::args::process()](#vstackletargsprocess)
  - [options](#options)
  - [arguments](#arguments)
  - [return codes](#return-codes)
  - [examples](#examples)
- [vstacklet::environment::functions()](#vstackletenvironmentfunctions)
- [vstacklet::log::check()](#vstackletlogcheck)
- [vstacklet::apt::update()](#vstackletaptupdate)
- [vstacklet::dependencies::install()](#vstackletdependenciesinstall)
   - [return codes](#return-codes-1)
- [vstacklet::environment::checkroot()](#vstackletenvironmentcheckroot)
   - [return codes](#return-codes-2)
- [vstacklet::environment::checkdistro()](#vstackletenvironmentcheckdistro)
   - [return codes](#return-codes-3)
- [vstacklet::intro()](#vstackletintro)
- [vstacklet::dependencies::array()](#vstackletdependenciesarray)
- [vstacklet::base::dependencies()](#vstackletbasedependencies)
   - [return codes](#return-codes-4)
- [vstacklet::source::dependencies()](#vstackletsourcedependencies)
   - [return codes](#return-codes-5)
- [vstacklet::bashrc::set()](#vstackletbashrcset)
- [vstacklet::hostname::set()](#vstacklethostnameset)
  - [options](#options-1)
  - [arguments](#arguments-1)
  - [examples](#examples-1)
- [vstacklet::webroot::set()](#vstackletwebrootset)
  - [options](#options-2)
  - [arguments](#arguments-2)
  - [examples](#examples-2)
- [vstacklet::ssh::set()](#vstackletsshset)
  - [options](#options-3)
  - [arguments](#arguments-3)
  - [return codes](#return-codes-6)
  - [examples](#examples-3)
- [vstacklet::ftp::set()](#vstackletftpset)
  - [options](#options-4)
  - [arguments](#arguments-4)
  - [return codes](#return-codes-7)
  - [examples](#examples-4)
- [vstacklet::block::ssdp()](#vstackletblockssdp)
  - [return codes](#return-codes-8)
- [vstacklet::sources::update()](#vstackletsourcesupdate)
- [vstacklet::gpg::keys()](#vstackletgpgkeys)
- [vstacklet::locale::set()](#vstackletlocaleset)
  - [return codes](#return-codes-9)
- [vstacklet::php::install()](#vstackletphpinstall)
  - [options](#options-5)
  - [arguments](#arguments-5)
  - [return codes](#return-codes-10)
  - [examples](#examples-5)
- [vstacklet::hhvm::install()](#vstacklethhvminstall)
  - [options](#options-6)
  - [return codes](#return-codes-11)
  - [examples](#examples-6)
- [vstacklet::nginx::install()](#vstackletnginxinstall)
  - [options](#options-7)
  - [return codes](#return-codes-12)
  - [examples](#examples-7)
- [vstacklet::varnish::install()](#vstackletvarnishinstall)
  - [options](#options-8)
  - [arguments](#arguments-6)
  - [return codes](#return-codes-13)
  - [examples](#examples-8)
- [vstacklet::permissions::adjust()](#vstackletpermissionsadjust)
- [vstacklet::ioncube::install()](#vstackletioncubeinstall)
  - [options](#options-9)
  - [return codes](#return-codes-14)
  - [examples](#examples-9)
- [vstacklet::mariadb::install()](#vstackletmariadbinstall)
  - [options](#options-10)
  - [arguments](#arguments-7)
  - [return codes](#return-codes-15)
  - [examples](#examples-10)
- [vstacklet::mysql::install()](#vstackletmysqlinstall)
  - [options](#options-11)
  - [arguments](#arguments-8)
  - [return codes](#return-codes-16)
  - [examples](#examples-11)
- [vstacklet::postgre::install()](#vstackletpostgreinstall)
  - [options](#options-12)
  - [arguments](#arguments-9)
  - [return codes](#return-codes-17)
  - [examples](#examples-12)
- [vstacklet::redis::install()](vstackletredisinstall)
  - [options](#options-13)
  - [arguments](#arguments-10)
  - [return codes](#return-codes-18)
  - [examples](#examples-13)
- [vstacklet::phpmyadmin::install()](#vstackletphpmyadmininstall)
  - [options](#options-14)
  - [arguments](#arguments-11)
  - [return codes](#return-codes-19)
  - [examples](#examples-14)
- [vstacklet::csf::install()](#vstackletcsfinstall)
  - [options](#options-15)
  - [arguments](#arguments-12)
  - [return codes](#return-codes-20)
  - [examples](#examples-15)
- [vstacklet::cloudflare::csf()](#vstackletcloudflarecsf)
  - [options](#options-16)
  - [return codes](#return-codes-21)
  - [examples](#examples-16)
- [vstacklet::sendmail::install()](#vstackletsendmailinstall)
  - [options](#options-17)
  - [parameters](#parameters)
  - [return codes](#return-codes-22)
  - [examples](#examples-17)
- [vstacklet::wordpress::install()](#vstackletwordpressinstall)
  - [options](#options-18)
  - [return codes](#return-codes-23)
  - [examples](#examples-18)
- [vstacklet::domain::ssl()](#vstackletdomainssl)
  - [options](#options-19)
  - [arguments](#arguments-13)
  - [return codes](#return-codes-24)
  - [examples](#examples-19)
- [vstacklet::clean::complete()](#vstackletcleancomplete)
- [vstacklet::message::complete()](#vstackletmessagecomplete)
- [vstacklet::clean::rollback()](#vstackletcleanrollback)

---



### vstacklet::environment::init()

Setup the environment and set variables. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L178-L198)

---

### vstacklet::args::process()

Process the options and values passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L287-L529)

#### options:

-  $1 - the option/flag to process
-  `--help` - show help
-  `--version` - show version
-  `--non-interactive` - run in non-interactive mode
-  `-e | --email` - mail address to use for the Let's Encrypt SSL certificate
-  `-ftp | --ftp_port` - port to use for the FTP server
-  `-ssh | --ssh_port` - port to use for the SSH server
-  `-http | --http_port` - port to use for the HTTP server
-  `-https | --https_port` - port to use for the HTTPS server
-  `-hn | --hostname` - hostname to use for the server
-  `-d | --domain` - domain name to use for the server
-  `-php | --php` - PHP version to install (7.4, 8.1)
-  `-hhvm | --hhvm` - install HHVM
-  `-nginx | --nginx` - install Nginx
-  `-varnish | --varnish` - install Varnish
-  `-varnishP | --varnish_port` - port to use for the Varnish server
-  `-mariadb | --mariadb` - install MariaDB
-  `-mariadbP | --mariadb_port` - port to use for the MariaDB server
-  `-mariadbU | --mariadb_user` - user to use for the MariaDB server
-  `-mariadbPw | --mariadb-password` - password to use for the MariaDB user
-  `-redis | --redis` - install Redis
-  `-postgre | --postgre` - install PostgreSQL
-  `-pma | --phpmyadmin` - install phpMyAdmin
-  `-csf | --csf` - install CSF firewall
-  `-csfCf | --csf_cloudflare` - enable Cloudflare support in CSF
-  `-sendmail | --sendmail` - install Sendmail
-  `-sendmailP | --sendmail_port` - port to use for the Sendmail server
-  `-wr | --web_root` - the web root directory to use for the server
-  `-wp | --wordpress` - install WordPress
-  `--reboot` - reboot the server after the installation

#### arguments:

-  $2 - the value of the option/flag

#### return codes:

- 3 - please provide a valid email address. (required for -csf, -sendmail, and -csfCf)
- 4 - `-csfCf` requires `-csf`.
- 5 - please provide a valid domain name.
- 6 - please provide a valid port number for the FTP server.
- 7 - invalid FTP port number. please enter a number between 1 and 65535.
- 8 - the MariaDB password must be at least 8 characters long.
- 9 - please provide a valid port number for the MariaDB server.
- 10 - invalid MariaDB port number. please enter a number between 1 and 65535.
- 11 - the MySQL password must be at least 8 characters long.
- 12 - the MySQL port must be a number.
- 13 - invalid MySQL port number. please enter a number between 1 and 65535.
- 14 - the postgreSQL password must be at least 8 characters long.
- 15 - please provide a valid port number for the postgreSQL server.
- 16 - invalid postgreSQL port number. please enter a number between 1 and 65535.
- 17 - invalid PHP version. please enter either 7 (7.4), or 8 (8.1).
- 18 - the HTTPS port must be a number.
- 19 - invalid HTTPS port number. please enter a number between 1 and 65535.
- 20 - the HTTP port must be a number.
- 21 - invalid HTTP port number. please enter a number between 1 and 65535.
- 22 - invalid hostname. please enter a valid hostname.
- 23 - the Redis password must be at least 8 characters long.
- 24 - please provide a valid port number for the Redis server.
- 25 - invalid Redis port number. please enter a number between 1 and 65535.
- 26 - an email is needed to register the server aliases. please set an email with `-e your@email.com`.
- 27 - the Sendmail port must be a number.
- 28 - invalid Sendmail port number. please enter a number between 1 and 65535.
- 29 - the SSH port must be a number.
- 30 - invalid SSH port number. please enter a number between 1 and 65535.
- 31 - the Varnish port must be a number.
- 32 - invalid Varnish port number. please enter a number between 1 and 65535.
- 33 - invalid web root. please enter a valid path. (e.g. /var/www/html)
- 34 - invalid option(s): ${invalid_option[*]}

#### examples:

```
 vstacklet --help
 vstacklet -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -hn "yourhostname" -php 8.1 -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -csf -sendmail -wr "/var/www/html" -wp
 vstacklet -e "youremail.com" -ftp 2133 -ssh 2244 -http 8080 -https 443 -d "yourdomain.com" -hhvm -nginx -varnish -varnishP 80 -mariadb -mariadbU "user" -mariadbPw "mariadbpasswd" -sendmail -wr "/var/www/html" -wp --reboot
```

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L538-L671)

---

### vstacklet::log::check()

Check if the log file exists and create it if it doesn't. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L685-L705)

notes:
- the log file is located at /var/log/vstacklet/vstacklet.${PPID}.log

*function has no options*

*function has no arguments*

---

### vstacklet::apt::update()

Updates server via apt-get. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L714-L723)

*function has no options*

*function has no arguments*

---

### vstacklet::dependencies::install()

Installs dependencies for vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L733-L754)

*function has no options*

*function has no arguments*

#### return codes:

- 35 - failed to install script dependencies.

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L764-L766)

#### return codes:

- 1 = you must be root to run this script.

---

### vstacklet::environment::checkdistro()

Check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11 [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L776-L787)

#### return codes:

- 2 = this script only supports Ubuntu 18.04/20.04 | Debian 9/10/11

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L796-L820)

---

### vstacklet::dependencies::array()

Handles various dependencies for the vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L847-L878)

*function has no options*

*function has no arguments*

---

### vstacklet::base::dependencies()

Handles base dependencies for the vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L886-L910)

#### return codes:

- 36 - failed to install base dependencies.

---

### vstacklet::source::dependencies()

Installs required sources for vStacklet software. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L920-L947)

*function has no options*

*function has no arguments*

#### return codes:

- 37 - failed to install source dependencies.

---

### vstacklet::bashrc::set()

Set ~/.bashrc and ~/.profile for vstacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L959-L967)

*function has no options*

*function has no arguments*

---

### vstacklet::hostname::set()

Set system hostname. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L988-L992)

notes:
- hostname must be a valid hostname.
  - It can contain only letters, numbers, and hyphens.
  - It must start with a letter and end with a letter or number.
  - It must not contain consecutive hyphens.
  - If hostname is not provided, it will be set to the domain name if provided.
  - If domain name is not provided, it will be set to the server hostname.

#### options:

-  $1 - `-hn | --hostname` (optional) (takes one argument)

#### arguments:

-  $2 - `[hostname]` - the hostname to set for the system (optional)

#### examples:

```
 vstacklet -hn myhostname
 vstacklet --hostname myhostname
```

---

### vstacklet::webroot::set()

Set main web root directory. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1014-L1021)

notes:
- if the directory already exists, it will be used.
- if the directory does not exist, it will be created.
- the addition of subdirectories will be handled by the vStacklet software.
  the subdirectories created in the web root directory will be:
  - ~/public
  - ~/logs
  - ~/ssl
- if `-wr | --web_root` is not set, the default directory will be used.
  e.g. `/var/www/html/{public,logs,ssl}`

#### options:

-  $1 - `-wr | --web_root` (optional) (takes one argument)

#### arguments:

-  $2 - `[web_root_directory]` - (optional) (default: /var/www/html)

#### examples:

```
 vstacklet -wr /var/www/mydirectory
 vstacklet --web_root /srv/www/mydirectory
```

---

### vstacklet::ssh::set()

Set ssh port to custom port (if nothing is set, default port is 22) [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1035-L1042)

#### options:

-  $1 - `-ssh | --ssh_port` (optional) (takes one argument)

#### arguments:

-  $2 - `[port]` (default: 22) - the port to set for ssh

#### return codes:

- 39 - failed to set SSH port.
- 40 - failed to restart SSH daemon service.

#### examples:

```
 vstacklet -ssh 2222
 vstacklet --ssh_port 2222
```

---

### vstacklet::ftp::set()

Set ftp port to custom port (if nothing is set, default port is 21) [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1056-L1067)

#### options:

-  $1 - `-ftp | --ftp_port` (optional) (takes one argument)

#### arguments:

-  $2 - `[port]` (default: 21) - the port to set for ftp

#### return codes:

- 41 - failed to set FTP port.
- 42 - failed to restart FTP service.

#### examples:

```
 vstacklet -ftp 2121
 vstacklet --ftp_port 2121
```

---

### vstacklet::block::ssdp()

Blocks an insecure port 1900 that may lead to
DDoS masked attacks. Only remove this function if you absolutely
need port 1900. In most cases, this is a junk port. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1082-L1091)

*function has no options*

*function has no arguments*

#### return codes:

- 43 - failed to block SSDP port.
- 44 - failed to save iptables rules.

---

### vstacklet::sources::update()

This function updates the package list and upgrades the system. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1102-L1160)

*function has no options*

*function has no arguments*

---

### vstacklet::gpg::keys()

This function sets the required software package keys
required by added sources. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1183-L1232)

notes:
- keys and sources are set for the following software packages:
  - hhvm (only if option `-hhvm|--hhvm` is set)
  - nginx (only if option `-nginx|--nginx` is set)
  - varnish (only if option `-varnish|--varnish` is set)
  - php (only if option `-php|--php` is set)
  - mariadb (only if option `-mariadb|--mariadb` is set)
  - redis (only if option `-redis|--redis` is set)
  - postgresql (only if option `-postgre|--postgresql` is set)
- apt-key is being deprecated, using gpg instead

*function has no options*

*function has no arguments*

---

### vstacklet::locale::set()

This function sets the locale to en_US.UTF-8
and sets the timezone to UTC. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1249-L1267)

todo: This function is still a work in progress.
- [ ] implement arguments to set the locale
- [ ] implement arguments to set the timezone (or a seperate function)

*function has no options*

*function has no arguments*

#### return codes:

- 45 - failed to set locale.

---

### vstacklet::php::install()

Install PHP and PHP modules. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1304-L1355)

notes:
- versioning:
  - php < "7.4" - not supported, deprecated
  - php = "7.4" - supported
  - php = "8.0" - superceded by php="8.1"
  - php = "8.1" - supported
- chose either php or hhvm, not both
- php modules are installed based on the following variables:
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

#### return codes:

- 46 - php and hhvm cannot be installed at the same time, please choose one.
- 47 - failed to install php dependencies.
- 48 - failed to enable php memcached extension.
- 49 - failed to enable php redis extension.

#### examples:

```
 vstacklet -php 8.1
 vstacklet --php 7.4
```

---

### vstacklet::hhvm::install()

Install HHVM and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1384-L1421)

notes:
- not familiar with HHMV?
  - https://docs.hhvm.com/hhvm/FAQ/faq
  - https://docs.hhvm.com/hhvm/configuration/INI-settings
- this is a very basic install, it is recommended to use the official HHVM
  documentation to configure HHVM
- HHVM is not compatible with PHP, so choose one or the other. HHVM is
  not a drop-in replacement for PHP, so you will need to rewrite your
  PHP code to work with HHVM accordingly. HHVM is a dialect of PHP, not PHP itself.
- unless you are familiar with HHVM, it is recommended to use `-php "8.1"` or `-php "7.4"` instead.
- there may be numerous issues when using with `--wordpress` (e.g. plugins, themes, etc.)
- phpMyAdmin is not compatible with HHVM, so if you choose HHVM,
  you will not be able to install phpMyAdmin.

#### options:

-  $1 - `-hhvm | --hhvm` (optional) (takes no arguments)

#### return codes:

- 50 - HHVM and PHP cannot be installed at the same time, please choose one.
- 51 - failed to install HHVM dependencies.
- 52 - failed to install HHVM.
- 53 - failed to update PHP alternatives.

#### examples:

```
 vstacklet -hhvm
 vstacklet --hhvm
```

---

### vstacklet::nginx::install()

Install NGinx and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1460-L1528)

notes:
- The following profiles are included:
  - Location profiles
    - cache-busting
    - cross-domain-fonts
    - expires
    - protect-system-files
    - letsencrypt
  - Security profiles
    - ssl
    - cloudflare-real-ip
    - common-exploit-prevention
    - mime-type-security
    - reflected-xss-prevention
    - sec-bad-bots
    - sec-file-injection
    - sec-php-easter-eggs
    - server-security-options
    - socket-settings
- These config can be found at /etc/nginx/server.configs/

#### options:

-  $1 - `-nginx | --nginx` (optional) (takes no arguments)

#### return codes:

- 54 - failed to install NGINX dependencies.
- 55 - failed to edit NGINX configuration file.
- 56 - failed to enable NGINX configuration file.
- 57 - failed to generate dhparam file.
- 58 - failed to stage checkinfo.php verification file.

#### examples:

```
 vstacklet -nginx
 vstacklet --nginx
 vstacklet -nginx -php 8.1 -varnish -varnishP 80 -http 8080 -https 443
vstacklet --nginx --php 8.1 --varnish --varnishP 80 --http 8080 --https 443
```

---

### vstacklet::varnish::install()

Install Varnish and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1559-L1598)

notes:
- varnish is installed based on the following variables:
  - `-varnish` (optional)
  - `-varnishP|--varnish_port` (optional) (default: 6081)
  - `-http|--http_port` (optional) (default: 80)
 - if you are not familiar with Varnish, please read the following:
  - https://www.varnish-cache.org/

#### options:

-  $1 - `-varnish | --varnish` (optional) (takes no arguments)
-  $2 - `-varnishP | --varnish_port` (optional) (takes one argument)
-  $3 - `-http | --http_port` (optional) (takes one argument)
-  $4 - `-https | --https_port` (optional) (takes one argument)

#### arguments:

-  $2 - `[varnish_port_number]` (optional) (default: 6081)
-  $3 - `[http_port_number]` (optional) (default: 80)
-  $4 - `[https_port_number]` (optional) (default: 443)

#### return codes:

- 59 - failed to install Varnish dependencies.
- 60 - could not switch to /etc/varnish directory.
- 61 - failed to reload the systemd daemon.
- 62 - failed to switch to ~/

#### examples:

```
 vstacklet -varnish -varnishP 6081 -http 80
 vstacklet --varnish --varnish_port 6081 --http_port 80
 vstacklet -varnish -varnishP 80 -http 8080 -https 443
 vstacklet -varnish -varnishP 80 -nginx -http 8080 --https_port 443
```

---

### vstacklet::permissions::adjust()

Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1620-L1627)

notes:
- Permissions are adjusted based the following variables:
  - adjustments are made to the assigned web root on the `-wr | --web-root`
   option
  - adjustments are made to the default web root of `/var/www/html`
  if the `-wr | --web-root` option is not used
- permissions are adjusted to the following:
  - `www-data:www-data` (user:group)
  - `755` (directory)
  - `644` (file)
  - `g+rw` (group read/write)
  - `g+s` (group sticky)

*function has no options*

*function has no arguments*

---

### vstacklet::ioncube::install()

Install ionCube loader. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1650-L1678)

notes:
- the ioncube loader will be available for the php version specified
  from the `-php | --php` option.

#### options:

-  $1 - `-ioncube | --ioncube` (optional) (takes no arguments)

#### return codes:

- 63 - failed to switch to /tmp directory.
- 64 - failed to download ionCube loader.
- 65 - failed to extract ionCube loader.
- 66 - failed to switch to /tmp/ioncube directory.
- 67 - failed to copy ionCube loader to /usr/lib/php/ directory.
- 68 - failed to enable ionCube loader php extension.

#### examples:

```
 vstacklet -ioncube -php 8.1
 vstacklet --ioncube --php 8.1
 vstacklet -ioncube -php 7.4
 vstacklet --ioncube --php 7.4
```

---

### vstacklet::mariadb::install()

Install mariaDB and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1712-L1774)

notes:
- if `-mysql | --mysql` is specified, then mariadb will not be installed. choose either mariadb or mysql.
- actual mariadb version installed is 10.6.+ LTS.

#### options:

-  $1 - `-mariadb | --mariadb` (optional) (takes no arguments)
-  $2 - `-mariadbP | --mariadb_port` (optional) (takes one argument)
-  $3 - `-mariadbU | --mariadb_user` (optional) (takes one argument)
-  $4 - `-mariadbPw | --mariadb_password` (optional) (takes one argument)

#### arguments:

-  $2 - `[port]` (optional) (default: 3306)
-  $3 - `[user]` (optional) (default: admin)
-  $4 - `[password]` (optional) (default: password auto-generated)

#### return codes:

- 69 - failed to install MariaDB dependencies.
- 70 - failed to initialize MariaDB secure installation.
- 71 - failed to create MariaDB user.
- 72 - failed to create MariaDB user password.
- 73 - failed to create MariaDB user privileges.
- 74 - failed to flush privileges.
- 75 - failed to set MariaDB client and server configuration.

#### examples:

```
 vstacklet -mariadb -mariadbP 3306 -mariadbU admin -mariadbPw password
 vstacklet --mariadb --mariadb_port 3306 --mariadb_user admin --mariadb_password password
 vstacklet -mariadb -mariadbP 3306 -mariadbU admin
 vstacklet --mariadb --mariadb_port 3306 --mariadb_user admin
 vstacklet -mariadb -mariadbP 3306
 vstacklet --mariadb --mariadb_port 3306
 vstacklet -mariadb
 vstacklet --mariadb
```

---

### vstacklet::mysql::install()

Install mySQL and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1804-L1869)

notes:
- if `-mariadb | --mariadb` is specified, then mysql will not be installed. choose either mysql or mariadb.
- apt-deb mysql version is 0.8.24-1_all.deb
- actual mysql version installed is 8.0.+

#### options:

-  $1 - `-mysql | --mysql` (optional) (takes no arguments)
-  $2 - `-mysqlP | --mysql_port` (optional) (takes one argument)
-  $3 - `-mysqlU | --mysql_user` (optional) (takes one argument)
-  $4 - `-mysqlPw | --mysql_password` (optional) (takes one argument)

#### arguments:

-  $2 - `[mysql_port]` (optional) (default: 3306)
-  $3 - `[mysql_user]` (optional) (default: admin)
-  $4 - `[mysql_password]` (optional) (default: password auto-generated)

#### return codes:

- 76 - failed to download MySQL deb package.
- 77 - failed to install MySQL deb package.
- 78 - failed to install MySQL dependencies.
- 79 - failed to set MySQL password.
- 80 - failed to create MySQL user.
- 81 - failed to grant MySQL user privileges.
- 82 - failed to flush MySQL privileges.
- 83 - failed to set MySQL client and server configuration.

#### examples:

```
 vstacklet -mysql -mysqlP 3306 -mysqlU admin -mysqlPw password
 vstacklet --mysql --mysql_port 3306 --mysql_user admin --mysql_password password
```

---

### vstacklet::postgre::install()

Install and configure PostgreSQL. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1889-L1969)

#### options:

-  $1 - `-postgre | --postgresql` (optional)

#### arguments:

-  $2 - `[postgresql_port]` (optional) (default: 5432)
-  $3 - `[postgresql_user]` (optional) (default: admin)
-  $4 - `[postgresql_password]` (optional) (default: password auto-generated)

#### return codes:

- 84 - failed to install PostgreSQL dependencies.
- 85 - failed to switch to /etc/postgresql/${postgre_version}/main directory.
- 86 - failed to set PostgreSQL password.
- 87 - failed to create PostgreSQL user.
- 88 - failed to grant PostgreSQL user privileges.
- 89 - failed to edit /etc/postgresql/${postgre_version}/main/postgresql.conf file.
- 90 - failed to edit /etc/postgresql/${postgre_version}/main/pg_hba.conf file.

#### examples:

```
 vstacklet -postgre -postgreP 5432 -postgreU admin -postgrePw password
 vstacklet --postgresql --postgresql_port 5432 --postgresql_user admin --postgresql_password password
```

---

### vstacklet::redis::install()

Install and configure Redis. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L1992-L2044)

#### options:

-  $1 - `-redis | --redis` (optional)
-  $2 - `-redisP | --redis_port` (optional)
-  $3 - `-redisPw | --redis_password` (optional)

#### arguments:

-  $2 - `[redis_port]` (optional) (default: 6379)
-  $3 - `[redis_password]` (optional) (default: password auto-generated)

#### return codes:

- 91 - failed to install Redis dependencies.
- 92 - failed to backup the Redis configuration file.
- 93 - failed to import the Redis configuration file.
- 94 - failed to modify the Redis configuration file.
- 95 - failed to restart the Redis service.
- 96 - failed to set the Redis password.

#### examples:

```
 vstacklet -redis -redisP 6379 -redisPw password
 vstacklet --redis --redis_port 6379 --redis_password password
 vstacklet -redis
 vstacklet --redis
```

---

### vstacklet::phpmyadmin::install()

Install phpMyAdmin and configure. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2099-L2200)

notes:
- phpMyAdmin no longer supports HHVM due to the project now just focusing on
  their own Hack language rather than PHP compatibility.
- phpMyAdmin requires a web server to run. You must select a web server from the list below.
  - nginx
  - varnish
- phpMyAdmin requires a database server to run. You must select a database server from the list below.
  - mariadb
  - mysql
- phpMyAdmin requires php to run. You must select a php version from the list below.
  - 8.1
  - 7.4
- phpMyAdmin requires a web port to run. This argmuent is supplied by the `-http | --http_port` option.
- phpMyAdmin will use the following options to configure itself:
  - web server: nginx, varnish
    - Nginx usage: `-nginx | --nginx`
    - Varnish usage: `-varnish | --varnish`
  - database server: mariadb, mysql
    - mariaDB usage: `-mariadbU [user] | --mariadb_user [user]` & `-mariadbPw [password] | --mariadb_password [password]`
    - mysql usage: `-mysqlU [user] | --mysql_user [user]` & `-mysqlPw [password] | --mysql_password [password]`
    - note: if no user or password is provided, the default user and password will be used. (admin, auto-generated password)
  - php version: php7.4, php8.1
    - PHP usage: `-php [version] | --php [version]`
  - port: http
    - usage: `-http [port] | --http [port]`
    - note: if no port is provided, the default port will be used. (80)

#### options:

-  $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments) (default: not installed)

#### arguments:

-  `-phpmyadmin | --phpmyadmin` does not take any arguments. However, it requires the options as expressed above.

#### return codes:

- 97 - a database server was not selected.
- 98 - a web server was not selected.
- 99 - a php version was not selected.
- 100 - phpMyAdmin does not support HHVM.
- 101 - failed to install phpMyAdmin dependencies.
- 102 - failed to switch to /usr/share directory.
- 103 - failed to remove existing phpMyAdmin directory.
- 104 - failed to download phpMyAdmin.
- 105 - failed to extract phpMyAdmin.
- 106 - failed to move phpMyAdmin to /usr/share directory.
- 107 - failed to remove phpMyAdmin .tar.gz file.
- 108 - failed to set ownership of phpMyAdmin directory.
- 109 - failed to set permissions of phpMyAdmin directory.
- 110 - failed to create /usr/share/phpmyadmin/tmp directory.
- 111 - failed to set symlink of ./phpmyadmin to ${web_root}/public/phpmyadmin.
- 112 - failed to create phpMyAdmin configuration file.

#### examples:

```
 vstacklet -phpmyadmin -nginx -mariadbU admin -mariadbPw password -php 8.1 -http 80
 vstacklet --phpmyadmin --nginx --mariadb_user admin --mariadb_password password --php 8.1 --http 80
```

---

### vstacklet::csf::install()

Install CSF firewall. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2237-L2313)

notes:
- https://configserver.com/cp/csf.html
- installing CSF will also install LFD (Linux Firewall Daemon)
- CSF will be configured to allow SSH, FTP, HTTP, HTTPS, MySQL, Redis,
  Postgres, and Varnish.
- CSF will be configured to block all other ports.
- CSF requires sendmail to be installed. if the `-sendmail` option is not
  specified, sendmail will be automatically installed and configured to use the
  specified email address from the `-email` option.
- (`-e`|`--email` required) As expressed above, CSF will also require the `-email` option to be
  specified. this is the email address that will be used to send CSF alerts.
- if your domain is routing through Cloudflare, you will need to use the
  `-csfCf | --csf_cloudflare` option in order to allow Cloudflare IPs through CSF.

#### options:

-  $1 - `-csf | --csf` (optional) (takes no argument)

#### arguments:

-  `-csf | --csf` does not take any arguments. However, it requires the options as expressed above.

#### return codes:

- 113 - failed to install CSF firewall dependencies.
- 114 - failed to download CSF firewall.
- 115 - failed to switch to /usr/local/src/csf directory.
- 116 - failed to install CSF firewall.
- 117 - failed to initialize CSF firewall.
- 118 - failed to modify CSF blocklist.
- 119 - failed to modify CSF ignore list.
- 120 - failed to modify CSF allow list.
- 121 - failed to modify CSF allow ports (inbound).
- 122 - failed to modify CSF allow ports (outbound).
- 123 - failed to modify CSF configuration file (csf.conf).

#### examples:

```
 vstacklet -csf -e "your@email.com" -csfCf -sendmail
 vstacklet --csf --email "your@email.com" --csf_cloudflare --sendmail
```

---

### vstacklet::cloudflare::csf()

Configure Cloudflare IP addresses in CSF. This is to be used
when Cloudflare is used as a CDN. This will allow CSF to
recognize Cloudflare IPs as trusted. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2338-L2356)

notes:
- This function is only called under the following conditions:
  - the option `-csf` is used (required)
  - the option `-csfCf` is used directly
- This function is only utilized if the option for `-csf` is used.
- This function adds the Cloudflare IP addresses to the CSF allow list. This
  is done to ensure that the server can be accessed by Cloudflare. The list
  is located in /etc/csf/csf.allow.

#### options:

-  $1 - `-csfCf | --csf_cloudflare` (optional)

*function has no arguments*

#### return codes:

- 124 - CSF has not been enabled ' -csf ' (required). this is a component
- 125 - CSF allow file does not exist.

#### examples:

```
 vstacklet -csfCf -csf -e "your@email.com"
```

---

### vstacklet::sendmail::install()

Install and configure sendmail. This is a required component for
CSF to function properly. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2387-L2443)

notes:
- The `-e | --email` option is required for this function to run properly.
  the email address provided will be used to configure sendmail.
- If installing CSF, this function will be called automatically. As such, it
  is not necessary to call this function manually with the `-csf | --csf` option.

#### options:

-  $1 - `-sendmail | --sendmail` (optional) (takes no arguments)

*function has no arguments*

#### parameters:

-  $1 - sendmail_skip installation (this is siliently passed if `-csf` is used)

#### return codes:

- 126 - an email address was not provided ' -e "your@email.com" '.
- 127 - failed to install sendmail dependencies.
- 128 - failed to edit aliases file.
- 129 - failed to edit sendmail.cf file.
- 130 - failed to edit main.cf file.
- 131 - failed to edit master.cf file.
- 132 - failed to create sasl_passwd file.
- 133 - postmap failed.
- 134 - failed to source new aliases.

#### examples:

```
 vstacklet -sendmail -e "your@email.com"
 vstacklet --sendmail --email "your@email.com"
 vstacklet -csf -e "your@email.com"
```

---

### vstacklet::wordpress::install()

Install WordPress. This will also configure WordPress to use
the database that was created during the installation process. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2490-L2550)

notes:
- this function is only called under the following conditions:
  - the option `-wordpress` is used directly
- this function will install wordpress and configure the database.
- wordpress is an active build option and requires active intput from the user (for now).
these arguments are:
  - wordpress database name
  - wordpress database user
  - wordpress database password
- this function requires the following options to be used:
  - database: `-mariadb | --mariadb`, `-mysql | --mysql`, or `-postgresql | --postgresql` (only one can be used)
  - webserver: `-nginx | --nginx` or `-varnish | --varnish` (both can be used)
  - php: `-php | --php` or `-hhvm | --hhvm` (only one can be used)
- this function will optionally use the following options:
  - web root: `-wr | --web_root` (default: /var/www/html)

#### options:

-  $1 - `-wordpress | --wordpress` (optional)

*function has no arguments*

#### return codes:

- 135 - WordPress requires a database to be installed.
- 136 - WordPress requires a webserver to be installed.
- 137 - WordPress requires a php version to be installed.
- 138 - failed to download WordPress.
- 139 - failed to extract WordPress.
- 140 - failed to move WordPress to the web root.
- 141 - failed to create WordPress upload directory.
- 142 - failed to create WordPress configuration file.
- 143 - failed to modify WordPress configuration file.
- 144 - failed to create WordPress database.
- 145 - failed to create WordPress database user.
- 146 - failed to grant WordPress database user privileges.
- 147 - failed to flush WordPress database privileges.
- 148 - failed to remove WordPress installation files.

#### examples:

```
 vstacklet -wp -mariadb -nginx -php "8.1" -wr "/var/www/html"
 vstacklet -wp -mysql -nginx -php "8.1"
 vstacklet -wp -postgresql -nginx -php "8.1"
 vstacklet -wp -mariadb -nginx -php "8.1" -varnish -varnishP 80 -http 8080 -https 443
 vstacklet -wp -mariadb -nginx -hhvm -wr "/var/www/html"
```

---

### vstacklet::domain::ssl()

The following function installs the SSL certificate
  for the domain. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2584-L2638)

notes:
- This function is only called under the following conditions:
  - the option for `-domain` is used (optional)
- The following options are required for this function:
  - `-domain` or `--domain`
  - `-e` or `--email`
  - `-nginx` or `--nginx`

#### options:

-  $1 - `-domain | --domain` - The domain to install the SSL certificate for.

#### arguments:

-  $1 - `[domain]` (required)

#### return codes:

- 149 - the `-nginx|--nginx` option is required.
- 150 - the `-e|--email` option is required.
- 151 - failed to change directory to /root.
- 152 - failed to create directory ${web_root}/.well-known/acme-challenge.
- 153 - failed to clone acme.sh.
- 154 - failed to switch to /root/acme.sh directory.
- 155 - failed to install acme.sh.
- 156 - failed to reload nginx.
- 157 - failed to register the account with Let's Encrypt.
- 158 - failed to set the default CA to Let's Encrypt.
- 159 - failed to issue the certificate.
- 160 - failed to install the certificate.
- 161 - failed to edit /etc/nginx/sites-available/${domain}.conf.

#### examples:

```
 vstacklet -nginx -domain example.com -e "your@email.com"
 vstacklet --nginx --domain example.com --email "your@email.com"
```

---

### vstacklet::clean::complete()

Cleans up the system after a successful installation. This
  function is called after the installation is complete. It removes the
  temporary files and directories created during the installation process.
  This function will also enable and start services that were installed. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2650-L2678)

*function has no options*

*function has no arguments*

---

### vstacklet::message::complete()

Outputs success message on completion of setup. This function
  is called after the installation is complete. It outputs a success message
  to the user and provides them with the necessary information to access their
  new server. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2690-L2726)

*function has no options*

*function has no arguments*

---

### vstacklet::clean::rollback()

This function is called when a rollback is required. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L2745-L2970)

notes:
- it will remove the temporary files and directories created during the installation
  process.
- it will remove the vStacklet log file.
- it will remove any dependencies installed during the installation process.
 (only dependencies installed by vStacklet will be removed)

notes:
  - this function is currently a work in progress

*function has no options*

*function has no arguments*

---


