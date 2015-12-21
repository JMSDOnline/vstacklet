VStacklet
==========

Scripts to quickly install a [LEMP Stack](https://lemp.io) and perform basic configuration of new Ubuntu 14.04, and 15.04 [untested] servers.

**NOTE:** This is a modification of it's original branch provided by <a href="https://github.com/jbradach/quick-lemp/" target="_blank">quick-lemp</a>. Installation scripts marked as Ubuntu 14.04 ONLY are those of heavy changes provided by myself (JMSolo Designs). These changes include ushering in CSF, Varnish as well as installing and configuring Sendmail and phpMyAdmin **To be added soon** for ease of use. 

Quick-Lemp is geared towards python based application installs and using default Boilerplate templates on Nginx/stable versions of no higher than 1.8. This limits the use of new functions and features in Nginx, nothing wrong with that, but some of us are sticklers for recent version. 

My focus is to provide a modified version for CMS and typical website server installations, Updated/Modified Boilerplate templates to be more 'Nginx mainline' friendly; i.e http/2, as well as the ongoing use of static websites (which the original still handles splendidly!)

Again, please be advised that I am building/testing this script on Ubuntu 14.04 (Trusty) as it does support Nginx versions higher than 1.8.

Components include a recent mainline version of Nginx (1.9.9) using configurations from the HTML 5 Boilerplate team (_and modified for use with mainline_), and MariaDB 10.0 (drop-in replacement for MySQL), PHP5, Sendmail (PHP mail function), ~~Python~~, and CSF (Config Server Firewall) **To be added soon**.

Deploys a proper directory strucutre and creates a PHP page for testing.

Script Features
--------
  * Quiet installer - no more long scrolling text vomit, just see what's important; when it's presented.
  * Script writes output to /root/vstacklet.log for additional observations.
  * Color Coding for emphasis on install processes.
  * Defaults are set to (Y) - just hit enter if you accept.
  * Fast and Lightweight install.
  * HTTP/2 Nginx ready. To view if your webserver is HTTP/2 after installing the script with SSL, check @ <a href="http://h2.nix-admin.com/" target="_blank">HTTP/2 Checker</a>
  * Everything you need to get that Nginx + Varnish server up and running!

Total script install time on a $5 <a href="https://www.digitalocean.com/?refcode=917d3ff0e1c8" target="_blank">Digital Ocean Droplet</a> sits at 09:34. This time assumes you are sitting attentively with the script running. There are a limited number of interactions to be made with the script, however, I feel it is important to have some sort of interaction... at the very least so you are familiar with what is being installed etc.

![preview 1](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-p1.png "vstacklet preview 1")
![preview 2](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-p2.png "vstacklet preview 2")
![preview 3](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-p3.png "vstacklet preview 3")
![preview 4](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-p4.png "vstacklet preview 4")
![preview 5](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-p5.png "vstacklet preview 5")

 Scripts
--------

__Setup__ - Basic setup for new Ubuntu server.
  * Intended only for new Ubuntu installations.
  * Adds new user with sudo access and disables remote root logins.
  * Changes sshd settings to enhance security.
  * Uses CSF to apply iptables rules to limit traffic to approved ports as well as email alerts to administrator email. (_not yet included_)

__Stack__ - Installs and configures LEMP stack with support for Website-based server environments.
  * Adds repositories for the latest stable versions of MariaDB, mainline (1.9.x) versions of Nginx, and Varnish 4.
  * Installs and configures Nginx, Varnish and MariaDB.
  * Installs PHP-FPM for PHP5.
  * Enables OPCode Cache and fine-tuning
  * Installs and Enables IonCube Loader
  * Installs and Enables (PHP) Sendmail
  * ~~Includes virtualenv and pip.~~ **removed** If you need this, visit the original [quick-lemp](https://github.com/jbradach/quick-lemp/)
  * MariaDB 10.0 can easily switched to 5.5 or substituted for PostgreSQL.
  * Supports IPv6 by default .
  * Optional self-signed SSL cert configuration.

__Backups__ - Installs scripts to help manage and automate server/site backups (_coming soon as a single script_).
  * Backup your files in key locations (ex: /srv/www /etc /root)
  * Backup your databases
  * Package files & databases to one archive
  * Cleanup remaining individual archives

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

### VStacklet FULL - Installs and configures VStacklet LEMP stack (includes backup scripts):
#### 14.04 only
```
curl -LO https://raw.github.com/JMSDOnline/vstacklet/master/vstacklet.sh
chmod +x vstacklet.sh
./vstacklet.sh
```

### Setup - Basic setup for new Ubuntu server:
#### 14.04 only
```
curl -LO https://raw.github.com/JMSDOnline/vstacklet/master/vstacklet-trusty-setup.sh
chmod +x vstacklet-trusty-setup.sh
./vstacklet-trusty-setup.sh
```

### The TO-DO List
  1. FTP Server (w/ options prompt)
  2. phpMyAdmin (w/ options prompt)
  3. CSF (w/ options prompt)