VStacklet
==========

Scripts to quickly install a [LEMP Stack](https://lemp.io) and perform basic configuration of new Ubuntu 14.04, and 15.04 [untested] servers.

**NOTE:** This is a modification of it's original branch provided by [quick-lemp](https://github.com/jbradach/quick-lemp/). Installation scripts marked as Ubuntu 14.04 ONLY are those of heavy changes provided by myself (JMSolo Designs). These changes include ushering in CSF, Varnish as well as installing and configuring Sendmail and phpMyAdmin for ease of use. Quick-Lemp is more geared towards python based application installs and using default Boilerplate templates. My focus is to provide a modified version for CMS server installations, Updated/Modified Boilerplate templates to be more 'Nginx mainline' friendly; i.e http/2, as well as the ongoing use of static websites (which the original still handles splendidly!)

Components include a recent mainline version of Nginx (1.9.9) using configurations from the HTML 5 Boilerplate team, and MariaDB 10.0 (drop-in replacement for MySQL), PHP5, Sendmail (PHP mail function), Python, and CSF (Config Server Firewall).

Deploys a proper directory strucutre and creates a PHP page for testing.

 Scripts
--------
__Setup__ - Basic setup for new Ubuntu server.
  * Intended only for new Ubuntu installations.
  * Adds new user with sudo access and disables remote root logins.
  * Changes sshd settings to enhance security.
  * Uses CSF to apply iptables rules to limit traffic to approved ports as well as email alerts to administrator email.

__Stack__ - Installs and configures LEMP stack with support for PHP Applications.
  * Installs and configures Nginx, Varnish and MariaDB.
  * Installs PHP-FPM for PHP5.
  * Includes virtualenv and pip.
  * MariaDB 10.0 can easily switched to 5.5 or substituted for PostgreSQL.
  * Adds repositories for the latest stable versions of MariaDB and mainline (1.9.x) versions of Nginx.
  * Supports IPv6 by default .
  * Optional self-signed SSL cert configuration.

Quick Start
----------------
_You should read these scripts before running them so you know what they're
doing._ Changes may be necessary to meet your needs.

__Setup__ should be run as __root__ on a fresh __Ubuntu__ installation. __Stack__ should be run on a server without any existing LEMP or LAMP components.

If components are already installed, the core packages can be removed with:
```
apt-get purge apache mysql apache2-mpm-prefork apache2-utils apache2.2-bin apache2.2-common \
libapache2-mod-php5 libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libnet-daemon-perl \
libplrpc-perl libpq5 mysql-client-5.5 mysql-common mysql-server mysql-server-5.5 php5-common \ 
php5-mysql
apt-get autoclean
apt-get autoremove
```

### Setup - Basic setup for new Ubuntu server:
#### 14.04 only
```
curl -LO https://raw.github.com/JMSDOnline/vstacklet/master/vstacklet-trusty-setup.sh
chmod +x vstacklet-trusty-setup.sh
./vstacklet-trusty-setup.sh
```

### Stack - Installs and configures LEMP stack:
##### 14.04 only
```
curl -LO https://raw.github.com/JMSDOnline/vstacklet/master/vstacklet-trusty-stack.sh
chmod +x vstacklet-trusty-stack.sh
./vstacklet-trusty-stack.sh
```
