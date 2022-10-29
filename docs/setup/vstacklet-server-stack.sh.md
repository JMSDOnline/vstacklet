# vstacklet-server-stack.sh - v3.1.1488


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
  - [examples](#examples)
- [vstacklet::environment::functions()](#vstackletenvironmentfunctions)
- [vstacklet::environment::checkroot()](#vstackletenvironmentcheckroot)
- [vstacklet::environment::checkdistro()](#vstackletenvironmentcheckdistro)
- [vstacklet::intro()](#vstackletintro)
- [vstacklet::log::check()](#vstackletlogcheck)
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
  - [examples](#examples-3)
- [vstacklet::block::ssdp()](#vstackletblockssdp)
- [vstacklet::update::packages()](#vstackletupdatepackages)
- [vstacklet::locale::set()](#vstackletlocaleset)
- [vstacklet::packages::softcommon()](#vstackletpackagessoftcommon)
- [vstacklet::packages::depends()](#vstackletpackagesdepends)
- [vstacklet::packages::keys()](#vstackletpackageskeys)
- [vstacklet::apt::update()](#vstackletaptupdate)
- [vstacklet::php::install()](#vstackletphpinstall)
  - [options](#options-4)
  - [arguments](#arguments-4)
  - [examples](#examples-4)
- [vstacklet::nginx::install()](#vstackletnginxinstall)
  - [options](#options-5)
  - [examples](#examples-5)
- [vstacklet::hhvm::install()](#vstacklethhvminstall)
  - [options](#options-6)
  - [examples](#examples-6)
- [vstacklet::permissions::adjust()](#vstackletpermissionsadjust)
- [vstacklet::varnish::install()](#vstackletvarnishinstall)
  - [options](#options-7)
  - [arguments](#arguments-5)
  - [examples](#examples-7)
- [vstacklet::ioncube::install()](#vstackletioncubeinstall)
  - [options](#options-8)
  - [examples](#examples-8)
- [vstacklet::mariadb::install()](#vstackletmariadbinstall)
  - [options](#options-9)
  - [arguments](#arguments-6)
  - [examples](#examples-9)
- [vstacklet::mysql::install()](#vstackletmysqlinstall)
  - [options](#options10)
  - [arguments](#arguments-7)
  - [examples](#examples-10)
- [vstacklet::phpmyadmin::install()](#vstackletphpmyadmininstall)
  - [options](#options-11)
  - [arguments](#arguments-8)
  - [examples](#examples-11)
- [vstacklet::csf::install()](#vstackletcsfinstall)
  - [options](#options-12)
  - [arguments](#arguments-9)
  - [examples](#examples-12)
- [vstacklet::sendmail::install()](#vstackletsendmailinstall)
  - [options](#options-13)
  - [parameters](#parameters)
  - [examples](#examples-13)
- [vstacklet::cloudflare::csf()](#vstackletcloudflarecsf)
  - [options](#options-14)
  - [examples](#examples-14)
- [vstacklet::nginx::location()](#vstackletnginxlocation)
- [vstacklet::nginx::security()](#vstackletnginxsecurity)

---



### vstacklet::environment::init()

Setup the environment and set variables.

---

### vstacklet::log::check()

Check if the log file exists and create it if it doesn't.

*function has no options*

*function has no arguments*

---

### vstacklet::environment::checkroot()

Check if the user is root.

#### return codes:

- 1 = You must be root to run this script.

---

### vstacklet::environment::checkdistro()

Check if the distro is Ubuntu 18.04/20.04 | Debian 9/10/11

#### return codes:

- 2 = This script only supports Ubuntu 18.04/20.04 | Debian 9/10/11

---

### vstacklet::args::process()

Process the options and values passed to the script.

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
-  `-sendmailP | --sendmail_port` - port to use for the Sendmail server
-  `-wr | --web_root` - the web root directory to use for the server
-  `-wp | --wordpress` - install WordPress
-  `--reboot` - reboot the server after the installation

#### arguments:

-  $2 - the value of the option/flag

#### return codes:

- 3 - Please provide a valid email address to use. (required for -csf, -sendmail, and -cloudflare)
- 4 - Please provide a valid domain name.
- 5 - Please provide a valid port number for the FTP server.
- 6 - Invalid FTP port number. Please enter a number between 1 and 65535.
- 7 - The MariaDB password must be at least 8 characters long.
- 8 - Please provide a valid port number for the MariaDB server.
- 9 - Invalid MariaDB port number. Please enter a number between 1 and 65535.
- 10 - The MySQL password must be at least 8 characters long.
- 11 - The MySQL port must be a number.
- 12 - Invalid MySQL port number. Please enter a number between 1 and 65535.
- 13 - Invalid PHP version. Please enter either 7 (7.4), or 8 (8.1).
- 14 - The HTTPS port must be a number.
- 15 - Invalid HTTPS port number. Please enter a number between 1 and 65535.
- 16 - The HTTP port must be a number.
- 17 - Invalid HTTP port number. Please enter a number between 1 and 65535.
- 18 - Invalid hostname. Please enter a valid hostname.
- 19 - An email is needed to register the server aliases. Please set an email with ' -e your@email.com '
- 20 - The Sendmail port must be a number.
- 21 - Invalid Sendmail port number. Please enter a number between 1 and 65535.
- 22 - The SSH port must be a number.
- 23 - Invalid SSH port number. Please enter a number between 1 and 65535.
- 24 - The Varnish port must be a number.
- 25 - Invalid Varnish port number. Please enter a number between 1 and 65535.
- 26 - Invalid web root. Please enter a valid path. (e.g. /var/www/html)
- 27 - Invalid option(s): ${invalid_option[*]}

#### examples:

```
 ./vstacklet.sh --help
 ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -h "yourhostname" -d "yourdomain.com" -php 8.1 -mc -ioncube -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -csf -sendmail -wr "/var/www/html" -wp
 ./vstacklet.sh -e "youremail.com" -ftp 2133 -ssh 2244 -http 80 -https 443 -h "yourhostname" -d "yourdomain.com" -hhvm -nginx -mariadb -mariadbP "3309" -mariadbU "user" -mariadbPw "mariadbpasswd" -pma -sendmail -wr "/var/www/html" -wp --reboot
```

---

### vstacklet::environment::functions()

Stage various functions for the setup environment.

---

### vstacklet::apt::update()

updates server via apt-get

*function has no options*

*function has no arguments*

---

### vstacklet::dependencies::install()

installs dependencies for vStacklet software

*function has no options*

*function has no arguments*

#### return codes:

- 28 - failed to install dependencies - [${install}]

---

### vstacklet::intro()

Prints the intro message

---

### vstacklet::dependencies::array()

Handles various dependencies for the vStacklet software.

*function has no options*

*function has no arguments*

---

### vstacklet::log::dependencies()

logs dependencies to file

*function has no arguments*

### vstacklet::base::dependencies()

Handles base dependencies for the vStacklet software.

#### return codes:

- 29 - failed to install base dependencies - [${install}]

---

### vstacklet::sources::install()

installs required sources for vStacklet software

*function has no options*

*function has no arguments*

#### return codes:

- 30 - failed to install source dependencies - [${depend}]

---

### vstacklet::bashrc::set()

Set ~/.bashrc and ~/.profile for vstacklet.

*function has no options*

*function has no arguments*

---

### vstacklet::hostname::set()

Set system hostname.

notes:
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

Set main web root directory.

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
 ./vstacklet.sh -wr /var/www/mydirectory
 ./vstacklet.sh --web_root /srv/www/mydirectory
```

---

### vstacklet::ssh::set()

Set ssh port to custom port (if nothing is set, default port is 22)

#### options:

-  $1 - `-ssh | --ssh_port` (optional) (takes one argument)

#### arguments:

-  $2 - `[port]` (default: 22) - the port to set for ssh

#### return codes:

- 32 - failed to set ssh port
- 33 - failed to restart ssh service

#### examples:

```
 ./vstacklet.sh -ssh 2222
 ./vstacklet.sh --ssh_port 2222
```

---

### vstacklet::block::ssdp()

Blocks an insecure port 1900 that may lead to
DDoS masked attacks. Only remove this function if you absolutely
need port 1900. In most cases, this is a junk port.

*function has no options*

*function has no arguments*

#### return codes:

- 34 - failed to block ssdp port
- 35 - failed to save iptables rules

---

### vstacklet::sources::update()

This function updates the package list and upgrades the system.

*function has no options*

*function has no arguments*

---

### vstacklet::packages::keys()

This function sets the required software package keys
and sources for the vStacklet software.

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

### vstacklet::apt::update()

Update apt sources and packages - this is a wrapper for apt-get update

*function has no options*

*function has no arguments*

#### return codes:

- 36 - apt-get update failed
- 37 - apt-get upgrade failed

---

### vstacklet::locale::set()

This function sets the locale to en_US.UTF-8
and sets the timezone to UTC.

todo: This function is still a work in progress.
- [ ] implement arguments to set the locale
- [ ] implement arguments to set the timezone (or a seperate function)

*function has no options*

*function has no arguments*

#### return codes:

- 38 - locale-gen failed

---

### vstacklet::php::install()

Install PHP and PHP modules.

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

- 39 - php and hhvm cannot be installed at the same time, please choose one
- 40 - failed to install php dependencies
- 41 - failed to install php memcached extension
- 42 - failed to install php redis extension

#### examples:

```
 ./vstacklet.sh -php 8.1
 ./vstacklet.sh --php 7.4
```

---

### vstacklet::hhvm::install()

Install HHVM and configure.

notes:
- HHVM is not compatible with PHP, so choose one or the other.

#### options:

-  $1 - `-hhvm | --hhvm` (optional) (takes no arguments)

#### return codes:

- 43 - hhvm and php cannot be installed at the same time, please choose one
- 44 - failed to install hhvm dependencies
- 45 - failed to install hhvm
- 46 - failed to update php alternatives

#### examples:

```
 ./vstacklet.sh -hhvm
 ./vstacklet.sh --hhvm
```

---

### vstacklet::nginx::install()

Install NGinx and configure.

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

- 47 - failed to install nginx dependencies
- 48 - missing required option for nginx configuration - ${e}
- 49 - failed to edit nginx configuration
- 50 - failed to enable nginx configuration
- 51 - failed to generate dhparam file
- 52 - failed to stage checkinfo.php verification file

#### examples:

```
 ./vstacklet.sh -nginx
 ./vstacklet.sh --nginx
 ./vstacklet.sh -nginx -php 8.1 -varnish -varnishP 80 -http 8080 -https 443
 ./vstacklet.sh --nginx --php 8.1 --varnish --varnishP 80 --http 8080 --https 443
```

---

### vstacklet::varnish::install()

Install Varnish and configure.

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

- 53 - failed to install varnish package
- 54 - could not switch to /etc/varnish directory
- 55 - failed to reload the systemd daemon
- 56 - failed to switch to ~/

#### examples:

```
 ./vstacklet.sh -varnish -varnishP 6081 -http 80
 ./vstacklet.sh --varnish --varnish_port 6081 --http_port 80
 ./vstacklet.sh -varnish -varnishP 6081 -http 80 -https 443
 ./vstacklet.sh -varnish -varnishP 80 -nginx -http 8080 --https_port 443
```

---

### vstacklet::permissions::adjust()

Adjust permissions for the web root.

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

Install ioncube loader.

notes:
- the ioncube loader will be available for the php version specified
  from the `-php | --php` option.

#### options:

-  $1 - `-ioncube | --ioncube` (optional) (takes no arguments)

#### return codes:

- 57 - failed to switch to /tmp directory
- 58 - failed to download ioncube loader
- 59 - failed to extract ioncube loader
- 60 - failed to switch to /tmp/ioncube directory
- 61 - failed to copy ioncube loader to /usr/lib/php/ directory
- 62 - failed to enable ioncube loader php extension

#### examples:

```
 ./vstacklet.sh -ioncube -php 8.1
 ./vstacklet.sh --ioncube --php 8.1
 ./vstacklet.sh -ioncube -php 7.4
 ./vstacklet.sh --ioncube --php 7.4
```

---

### vstacklet::mariadb::install()

Install mariaDB and configure.

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
-  $3 - `[user]` (optional) (default: root)
-  $4 - `[password]` (optional) (default: password auto-generated)

#### return codes:

- 63 - failed to install mariadb
- 64 - failed to initialize mariadb secure installation
- 65 - failed to create mariadb root user
- 66 - failed to create mariadb root user password
- 67 - failed to create mariadb root user host
- 68 - failed to flush privileges
- 69 - failed to set mariadb client and server configuration

#### examples:

```
 ./vstacklet.sh -mariadb -mariadbP 3306 -mariadbU root -mariadbPw password
 ./vstacklet.sh --mariadb --mariadb_port 3306 --mariadb_user root --mariadb_password password
 ./vstacklet.sh -mariadb -mariadbP 3306 -mariadbU root
 ./vstacklet.sh --mariadb --mariadb_port 3306 --mariadb_user root
 ./vstacklet.sh -mariadb -mariadbP 3306
 ./vstacklet.sh --mariadb --mariadb_port 3306
 ./vstacklet.sh -mariadb
 ./vstacklet.sh --mariadb
```

---

### vstacklet::mysql::install()

Install mySQL and configure.

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
-  $3 - `[mysql_user]` (optional) (default: root)
-  $4 - `[mysql_password]` (optional) (default: password auto-generated)

#### return codes:

- 70 - failed to get mysql deb package
- 71 - failed to install mysql deb package
- 72 - failed to install mysql dependencies
- 73 - failed to set mysql root password
- 74 - failed to create mysql user
- 75 - failed to grant mysql user privileges
- 76 - failed to flush mysql privileges
- 77 - failed to set mysql client and server configuration

#### examples:

```
 ./vstacklet.sh -mysql -mysqlP 3306 -mysqlU root -mysqlPw password
 ./vstacklet.sh --mysql --mysql_port 3306 --mysql_user root --mysql_password password
```

---

### vstacklet::phpmyadmin::install()

Install phpMyAdmin and configure.

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
    - note: if no user or password is provided, the default user and password will be used. (root, auto-generated password)
  - php version: php7.4, php8.1
    - PHP usage: `-php [version] | --php [version]`
  - port: http
    - usage: `-http [port] | --http [port]`
    - note: if no port is provided, the default port will be used. (80)

#### options:

-  $1 - `-phpmyadmin | --phpmyadmin` (optional) (takes no arguments) (default: not installed)

#### arguments:

-  `-phpmyadmin | --phpmyadmin` does not take any arguments. However, it requires the options as expressed above.

#### examples:

```
 ./vstacklet.sh -phpmyadmin -nginx -mariadbU root -mariadbPw password -php 8.1 -http 80
 ./vstacklet.sh --phpmyadmin --nginx --mariadb_user root --mariadb_password password --php 8.1 --http 80
```

---

### vstacklet::csf::install()

Install CSF firewall.

notes:
- https://configserver.com/cp/csf.html
- installing CSF will also install LFD (Linux Firewall Daemon)
- CSF will be configured to allow SSH, FTP, HTTP, HTTPS, MySQL, Redis,
  Postgres, and Varnish
- CSF will be configured to block all other ports
- CSF requires sendmail to be installed. if the `-sendmail` option is not
  specified, sendmail will automatically be installed and configured to use the
  specified email address from the `-email` option.
- As expressed above, CSF will also require the `-email` option to be
  specified.
- if your domain is routed through Cloudflare, you will need to add use the
  `-cloudflare` option to allow Cloudflare IPs through CSF.

#### options:

-  $1 - `-csf | --csf` (optional) (takes no argument)

#### arguments:

-  `-csf | --csf` does not take any arguments. However, it requires the options as expressed above.

#### return codes:

- 94 - CSF firewall dependencies failed to install
- 95 - CSF firewall failed to download
- 96 - failed to switch to /usr/local/src/csf directory
- 97 - CSF firewall failed to install
- 98 - CSF firewall failed to configure
- 99 - failed to modify CSF blocklist
- 100 - failed to modify CSF ignore list
- 101 - failed to modify CSF allow list
- 102 - failed to modify CSF allow ports (inbound)
- 103 - failed to modify CSF allow ports (outbound)
- 104 - failed to modify CSF configuration file (csf.conf)

#### examples:

```
 ./vstacklet.sh -csf -e "your@email.com" -cloudflare -sendmail
 ./vstacklet.sh --csf --email "your@email.com" --cloudflare --sendmail
```

---

### vstacklet::sendmail::install()

Install and configure sendmail. This is a required component for
CSF to function properly.

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

- 105 - an email address was not provided. this is required for sendmail
- 106 - sendmail dependencies failed to install.
- 107 - failed to edit aliases file.
- 108 - failed to edit sendmail.cf file.
- 109 - failed to edit main.cf file.
- 110 - failed to edit master.cf file.
- 111 - failed to create sasl_passwd file.
- 112 - postmap failed.
- 113 - failed to source new aliases.

#### examples:

```
 ./vstacklet.sh -sendmail -e "your@email.com"
 ./vstacklet.sh --sendmail --email "your@email.com"
 ./vstacklet.sh -csf -e "your@email.com"
```

---

### vstacklet::cloudflare::csf()

Configure Cloudflare IP addresses in CSF. This is to be used
when Cloudflare is used as a CDN. This will allow CSF to
recognize Cloudflare IPs as trusted.

notes:
- This function is only called under the following conditions:
  - the option `-csf` is used (required)
  - the option `-cloudflare` is used directly
- This function is only utilized if the option for `-csf` is used.
- This function adds the Cloudflare IP addresses to the CSF allow list. This
  is done to ensure that the server can be accessed by Cloudflare. The list
  is located in /etc/csf/csf.allow.

#### options:

-  $1 - `-cloudflare | --cloudflare` (optional)

*function has no arguments*

#### return codes:

- 114 - csf has not been enabled ( -csf ). this is a component of the
- 115 - csf allow file does not exist.

#### examples:

```
 ./vstacklet.sh -cloudflare -csf -e "your@email.com"
```

---

### vstacklet::domain::ssl()

The following function installs the SSL certificate
for the domain.

notes:
- This function is only called under the following conditions:
  - the option for `-domain` is used (optional)
- The following options are required for this function:
  - `-domain` or `--domain`
  - `-email` or `--email`
  - `-nginx` or `--nginx`

#### options:

-  $1 - `-domain | --domain` - The domain to install the

#### arguments:

- # @args: $1 - `[domain]` (required)

#### return codes:

- 116 - the -nginx|--nginx option is required.
- 117 - the -e|--email option is required.
- 118 - failed to change directory to /root.
- 119 - failed to create directory ${webroot}/.well-known/acme-challenge.
- 120 - failed to clone acme.sh.
- 121 - failed to change directory to /root/acme.sh.
- 122 - failed to install acme.sh.
- 123 - missing required option(s) - ${e[@]}
- 124 - failed to edit /etc/nginx/sites-available/${domain}.conf.
- 125 - failed to reload nginx.
- 126 - failed to register the account with Let's Encrypt.
- 127 - failed to set the default CA to Let's Encrypt.
- 128 - failed to issue the certificate.
- 129 - failed to install the certificate.

#### examples:

```
 ./vstacklet.sh -nginx -domain example.com -e "your@email.com"
 ./vstacklet.sh --nginx --domain example.com --email "your@email.com"
```

---

### vstacklet::clean::complete()

Cleans up the system after a successful installation. This
  function is called after the installation is complete. It removes the
  temporary files and directories created during the installation process.
  This function will also enable and start services that were installed.

*function has no options*

*function has no arguments*

---

### vstacklet::message::complete()

Outputs success message on completion of setup. This function
  is called after the installation is complete. It outputs a success message
  to the user and provides them with the necessary information to access their
  new server.

*function has no options*

*function has no arguments*

---

### vstacklet::clean::rollback()

This function is called when a rollback is required. It will
  remove the temporary files and directories created during the installation
  process. It will also remove the log file created during the installation
  process.

notes:
  - this function is currently a work in progress

*function has no options*

*function has no arguments*

---


