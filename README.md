VStacklet - A Buff LEMP Stack Kit
==========

| ![VStacklet - A Buff LEMP Stack Kit](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-lemp-kit.png "vstacklet") |
|---|
| **VStacklet - A Buff LEMP Stack Kit** |

#### Script status

[![Version 3.1.0-production](https://img.shields.io/badge/version-3.1.0-674172.svg?style=flat-square)](https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack)
[![MIT License](https://img.shields.io/badge/license-MIT%20License-blue.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet/blob/master/LICENSE)
[![Ubuntu 16.04 Passing](https://img.shields.io/badge/Ubuntu%2016.04-failing-brightred.svg?style=flat-square)](https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack)
[![Debian 8 Passing](https://img.shields.io/badge/Debian%208-failing-brightred.svg?style=flat-square)](https://jmsolodesigns.com/code-projects/vstacklet/varnish-lemp-stack)

--------

> ### HEADS UP!
VStacklet for Ubuntu 14.04 & 15.10 has been deprecated. This is due to 16.04 LTS now becoming more common place with at least 90% of the providers on the market. Additionally, SSL creation and install in the script has been disabled until I have LetsEncrypt fully integrated.

Kit to quickly install a [LEMP Stack](https://lemp.io) w/ Varnish and perform basic configurations of new Ubuntu 14.04, 15.04, 15.10 and 16.04 servers.

Components include a recent mainline version of Nginx (1.11.3 (Wily)) using configurations from the HTML 5 Boilerplate team (_and modified/customized for use with mainline_), Varnish 4.1, and MariaDB 10.2 (drop-in replacement for MySQL), PHP7.0, PHP5.6 or HHVM **new** (users choice), Sendmail (PHP mail function), CSF (Config Server Firewall) and more to be added soon. (see [To-Do List](#the-to-do-list))

Deploys a proper directory structure, optimizes Nginx and Varnish, creates a PHP page for testing and more!

> Please note: that if you are going to use php 7 that ioncube are currently not supported. Additionally, Lets Encrypt will be the standard SSL installer in the coming versions.


Script Features
--------
  * Quiet installer - no more long scrolling text vomit, just see what's important; when it's presented.
  * Script writes output to /root/vstacklet.`###`.log for additional observations.
  * Color Coding for emphasis on install processes.
  * Defaults are set to (Y) - just hit enter if you accept.
  * Varnish Cache on port 80 with Nginx port 8080 SSL termination on 443.
  * Users choice of php5.6, php7.0 or HHVM
  * No Apache - Full throttle!
  * Fast and Lightweight install.
  * Full Kit functionality - backup scripts included.
  * Actively maintained w/ updates added when stable.
  * HTTP/2 Nginx ready. To view if your webserver is HTTP/2 after installing the script with SSL, check @ <a href="http://h2.nix-admin.com/" target="_blank">HTTP/2 Checker</a>
  * Everything you need to get that Nginx + Varnish server up and running!

Total script install time on a $5 <a href="https://www.digitalocean.com/?refcode=917d3ff0e1c8" target="_blank">Digital Ocean Droplet</a> sits at 10:12 installing everything. No Sendmail or Cert script installs at 04:22. This time assumes you are sitting attentively with the script running. There are a limited number of interactions to be made with the script and most of the softwares installed I have automated and logged, however, I feel it is important to have some sort of interaction... at the very least so you are familiar with what is being installed along with the options to tell it to go to hell.

![preview 1](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-script-preview1.png "vstacklet preview 1")

 Meet the Scripts
--------

__VStacklet__ - (Full Kit) Installs and configures LEMP stack with support for Website-based server environments.
  *
  * Adds repositories for the latest stable versions of MariaDB, mainline (1.10.x) versions of Nginx, and Varnish 4.x.
  * Installs and configures Nginx, Varnish and MariaDB.
  * Installs PHP-FPM for PHP5 _or_ PHP7.
  * Installs HHVM [_optional_].
  * Enables OPCode Cache and fine-tuning [_optional_]
  * Installs & Enables Memcached Cache and fine-tuning [_optional_]
  * Installs and Enables IonCube Loader [_optional_]
  * Installs and Auto-Configures phpMyAdmin - MySQL & phpMyAdmin credentials are stored in /root/.my.cnf
  * MariaDB 10.2 can easily switched to 5.5+ or substituted for PostgreSQL.
  * Installs and Adjusts CSF (Config Server Firewall) - prepares ports used for VStacklet as well as informing your entered email for security alerts.
  * Installs and Enables (PHP) Sendmail
  * Supports IPv6 by default.
  * Optional self-signed SSL cert configuration. [*wip*]
  * Easy to configure & run backup executable __vs-backup__ for data-protection.

__VS-Backup__ - Installs scripts to help manage and automate server/site backups
Updated: ~~(_coming soon as a single script_)~~ Added as standalone and included in full kit.
  *
  * Backup your files in key locations (ex: /srv/www /etc /root)
  * Backup your databases
  * Package files & databases to one archive
  * Cleanup remaining individual archives
  * Simply configure and type '__vs-backup__' to backup important directories and databases - cron examples included.

![VS-Backup](https://github.com/JMSDOnline/vstacklet/blob/master/images/vs-backup-utility-preview.png "VStacklets VS-Backup Utility")

Getting Started
----------------
_You should read these scripts before running them so you know what they're
doing._ Changes may be necessary to meet your needs.

__Setup__ should be run as __root__ on a fresh __Ubuntu__ or __Debian__ installation.
__Stack__ should be run on a server without any existing LEMP or LAMP components.

If components are already installed, the core packages can be removed with:
```
apt-get purge -y apache2* mysql apache2-mpm-prefork apache2-utils apache2.2-bin apache2.2-common \
libapache2-mod-php5 libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libnet-daemon-perl \
libplrpc-perl libpq5 mysql-client-5.5 mysql-common mysql-server mysql-server-5.5 php5-common \
php5-mysql
apt-get autoclean
apt-get autoremove
```

### VStacklet FULL Kit - Installs and configures the VStacklet LEMP kit stack:
( _includes backup scripts_ )

```
apt -y install git
```
... then run our main installer ...
```
git clone --recursive https://github.com/JMSDOnline/vstacklet /etc/vstacklet &&
chmod +x /etc/vstacklet/vstacklet_setup/vstacklet.sh
cd /etc/vstacklet/vstacklet_setup && ./vstacklet.sh
```

### To compile Nginx with Pagespeed [standalone - or rebuild] (dev branch)
> Please be advised. Recently Nginx 1.11.3 has been released. This script will run the needed
processes for build, however, compilation may fail due to newer versions etc. etc. being released.
```
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet_nginx_base/master/pagespeed/[wip]nginx-pagespeed.sh
chmod +x nginx-pagespeed.sh
./nginx-pagespeed.sh
```

### VStacklet VS-Backup - Installs needed files for running complete system backups:
```
git clone https://github.com/JMSDOnline/vstacklet_packages.git /etc/vstacklet
chmod +x /etc/vstacklet/packages/backup/vstacklet-backup-standalone.sh
cd /etc/vstacklet/packages/backup && ./vstacklet-backup-standalone.sh
```

### The TO-DO List
- [x] Enable OPCode Caching
- [x] Enable Memcached Caching
- [ ] Optional install of php5.6, php7.0 or HHVM [wip]
- [x] Sendmail
- [x] IonCube Loader (w/ option prompt)
- [x] Improve script structure
- [ ] FTP Server (w/ option prompt)
- [x] phpMyAdmin (w/ option prompt)
- [x] CSF (w/ option prompt)
- [x] VS-Backup standalone kit (included in FULL Kit also)
- [ ] Full support for Ubuntu 16.04 & Debian 8 [wip]
- [ ] Nginx + Page Speed building
- [ ] Build SSL with LetsEncrypt


### Additional Notes and honorable mentions

This is a modification of it's original branch provided by <a href="https://github.com/jbradach/quick-lemp/" target="_blank">quick-lemp</a>. The scripts within VStacklet LEMP Kit come with heavy modifications to  the origianl quick-lemp script... in this regards, these two scripts are entirely separate and not similar to one another. Quick-LEMP is mentioned as it started the VStacklet Kit Project... what was to be a simply pull request to it's original owner, took on a new scope and thus simply became a new project. The changes include ushering in __CSF__, __Varnish__ as well as installing and configuring __Sendmail__ and __phpMyAdmin__ for ease of use.

Quick-Lemp is geared towards python based application installs and using default Boilerplate templates on Nginx/stable versions of no higher than 1.8. This limits the use of new functions and features in Nginx, nothing wrong with that, but some of us are sticklers for a recent version.

My focus was and is to provide a modified version for CMS and typical website server i.e;(WordPress, Joomla!, Drupal, Ghost, Magento ... etc ... ) installations, Updated/Modified/Customized Boilerplate templates to be more 'Nginx mainline' friendly; i.e http/2, as well as the ongoing use of static websites (which the original still handles splendidly!)

Again, please be advised that I am building/testing this script on Ubuntu 16.04 (Wily) as it supports Nginx versions higher than 1.8.

As per any contributions, be it suggestions, critiques, alterations and on and on are all welcome!
