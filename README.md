# vStacklet - A Buff LEMP Stack Kit

---

<div align="center">

| ![vStacklet - A Buff LEMP Stack Kit](https://github.com/JMSDOnline/vstacklet/blob/master/images/vstacklet-lemp-kit.png "vstacklet") |
| ----------------------------------------------------------------------------------------------------------------------------------- |
| **vStacklet - A Buff LEMP Stack Kit**                                                                                               |

## Script status

  Version: v3.1.1.652
  Build: 652

[![MIT License](https://img.shields.io/badge/license-MIT%20License-blue.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet/blob/master/LICENSE)

### Supported OS/Distro

Ubuntu:

[![Ubuntu 16.04 Failing](https://img.shields.io/badge/Ubuntu%2016.04-failing-red.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)
[![Ubuntu 18.04 Testing](https://img.shields.io/badge/Ubuntu%2018.04-testing-purple.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)
[![Ubuntu 20.04 Testing](https://img.shields.io/badge/Ubuntu%2020.04-testing-purple.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)

Debian:

[![Debian 8 Failing](https://img.shields.io/badge/Debian%208-failing-red.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)
[![Debian 9 Testing](https://img.shields.io/badge/Debian%209-testing-purple.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)
[![Debian 10 Testing](https://img.shields.io/badge/Debian%2010-testing-purple.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)
[![Debian 11 Testing](https://img.shields.io/badge/Debian%2011-testing-purple.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet)

</div>

---

> ### HEADS UP
>
> vStacklet for Ubuntu 16.04 and Debian 8 has been deprecated. This is due to Ubuntu 20.04 and Debian 11 now becoming more common place with at least 90% of the providers on the market. Additionally, SSL creation and install in the script has been disabled until I have LetsEncrypt fully integrated, which is currently an active WIP.

## What is vStacklet?

vStacklet is a kit to quickly install a [LEMP Stack](https://lemp.io) w/ Varnish and perform basic configurations of new Ubuntu 18.04/20.04 and Debian 9/10/11 servers.

Components include a recent mainline version of Nginx (mainline (1.23.x)) using configurations from the HTML 5 Boilerplate team (*and modified/customized for use with mainline*), Varnish 7.2.x, and MariaDB 10.6.x (drop-in replacement for MySQL), PHP8.1, PHP7.4 or HHVM 4.x **new** (users choice), Sendmail (PHP mail function), CSF (Config Server Firewall), Wordpress and more to be added soon. (see [To-Do List](#the-to-do-list))

Deploys a proper directory structure, optimizes Nginx and Varnish, creates a PHP page for testing and more!

> Lets Encrypt will be the standard SSL installer in the coming versions.

## Script Features

- Quiet installer - no more long scrolling text vomit, just see what's important; when it's presented.
- Script writes output to `/var/log/vstacklet.###.log` for additional observations.
- Color Coding for emphasis on install processes.
- Easy optional parameters make it a set it and forget it script.
- Varnish Cache on port 80 with Nginx port 8080 SSL termination on 443.
- Users choice of php8.1, php7.4 or HHVM
- No Apache - Full throttle!
- Fast and Lightweight install.
- Full Kit functionality - backup scripts included.
- Dynamic rollback built-in should the install fail. All dependencies and directories placed by vStacklet are removed on the rollback.
- Actively maintained w/ updates added when stable.
- HTTP/2 Nginx ready. To view if your webserver is HTTP/2 after installing the script with SSL, check @ <a href="http://h2.nix-admin.com/" target="_blank">HTTP/2 Checker</a>
- Everything you need to get that Nginx + Varnish server up and running!

Total script install time on a $5 <a href="https://www.digitalocean.com/?refcode=917d3ff0e1c8" target="_blank">Digital Ocean Droplet</a> sits at 10:12 installing everything. No Sendmail or Cert script installs at 04:22. This time assumes you are sitting attentively with the script running. There are a limited interactions to be made with the script and most of the softwares installed I have automated and logged. The most is the script will ask to continue.

![preview 1](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet_install_preview.png "vstacklet preview 1")

## Meet the Scripts

**VStacklet** - (Full Kit) Installs and configures LEMP stack with support for Website-based server environments.

- Adds repositories for the latest stable versions of MariaDB (10.6.x), mainline (1.23.x) versions of Nginx, and Varnish 7.2.x.
- Installs choice of PHP8.1, PHP7.4 or HHVM 4.x
- Installs NGinx and/or Varnish.
- Installs and enables OPCode Cache and fine-tuning for PHP7.4 *or* PHP8.1. (default)
- Installs and enables Memcached Cache and fine-tuning for PHP7.4 *or* PHP8.1. (default)
- Installs and enables IonCube Loader [*optional*]
- Installs and configures phpMyAdmin
- Installs choice of database: MariaDB, MySQL, PostgreSQL, or Redis [*optional*]
- Installs and configures CSF (Config Server Firewall) - prepares ports used for vStacklet as well as informing your entered email for security alerts.
- Installs and enables (PHP) Sendmail [*optional*] (default to install if `-csf | --csf` is used)
- Supports IPv6 by default.
- Installs self-signed SSL cert configuration. (default)
- Installs and configures LetsEncrypt SSL cert. [*optional*] (default to install if `-d | --domain` is used)
- Installs and stages database for WordPress. [*optional*] (active build - unlike other options that are passive with the flags used. This will change when the `--non-interactive` flag [WIP] is added.)
- Easy to configure & run backup executable **vs-backup** for data-protection.

**VS-Backup** - Installs scripts to help manage and automate server/site backups
Updated: ~~(*coming soon as a single script*)~~ Added as standalone and included in full kit.

- Backup your files in key locations (ex: /srv/www /etc /root)
- Backup your databases
- Package files & databases to one archive
- Cleanup remaining individual archives
- Simply configure and type '**vs-backup**' to backup important directories and databases - cron examples included.

![VS-Backup](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vs-backup-utility-preview.png "VStacklet VS-Backup Utility")

---

## Getting Started

*You should read these scripts before running them so you know what they're
doing.* Changes may be necessary to meet your needs.

**You can review the setup script documentation [here](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)**

**Setup** should be run as **root** on a fresh **Ubuntu** or **Debian** installation.
**Stack** should be run on a server without any existing LEMP or LAMP components.

If components are already installed, the core packages can be removed with:

```bash
apt-get autoremove -y apache2* mysql* php* \
apt-get autopurge -y apache2* mysql* php* \
apt-get -y autoremove && apt-get -y autoclean
```

---

### VStacklet FULL Kit - Installs and configures the VStacklet LEMP kit stack

( *includes backup scripts* )

#### Install needed dependencies for script grabbing and execution

```bash
apt -y install git wget
```

#### Main branch repository

... then run our main installer ...

```bash
git clone --recursive https://github.com/JMSDOnline/vstacklet /etc/vstacklet &&
chmod +x /etc/vstacklet/setup/vstacklet.sh
cd /etc/vstacklet/setup && ./vstacklet.sh
```

---

#### Development branch repository

```bash
sudo apt -y install wget &&
wget -O vstacklet.sh https://raw.githubusercontent.com/JMSDOnline/vstacklet/development/setup/vstacklet.sh &&
chmod +x vstacklet.sh
```

... then run our main installer ...

> Notes:
>
> - **The development branch is not recommended for production use.**
> - The following example will set the admin email, stage a verified Let's Encrypt SSL cert, install PHP8.1, NGinx, Varnish, MariaDB, phpMyAdmin, CSF, Sendmail, and IonCube Loader. Where NGinx and Varnish are installed, we will set the standard web port for nginx to 8080 and Varnish to 80. This is to allow for SSL termination on port 443 with nginx and Varnish caching on port 80.

###### Example

```bash
./vstacklet.sh -e "your@email.com" -d "yourdomain.com" -php "8.1" -nginx -varnish -http "8080" -varnishP "80" -mariadb -phpmyadmin -csf -ioncube
```

To view the available options, run the script with the -h option or view the documentation [here](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)

---

### To compile Nginx with Pagespeed [standalone - or rebuild] (dev branch) (currently WIP)

> Please be advised. Recently Nginx 1.11.3 has been released. This script will run the needed processes for build, however, compilation may fail due to newer versions etc. etc. being released.

```bash
curl -LO https://raw.githubusercontent.com/JMSDOnline/vstacklet_nginx_base/master/pagespeed/[wip]nginx-pagespeed.sh
chmod +x nginx-pagespeed.sh
./nginx-pagespeed.sh
```

---

### VStacklet VS-Backup - Installs needed files for running complete system backups

```bash
git clone https://github.com/JMSDOnline/vstacklet_packages.git /etc/vstacklet
chmod +x /etc/vstacklet/packages/backup/vstacklet-backup-standalone.sh
cd /etc/vstacklet/packages/backup && ./vstacklet-backup-standalone.sh
```

---

### The TO-DO List

- [x] Enable OPCode Caching
- [x] Enable Memcached Caching
- [ ] Optional install of php7.4, php8.1 or HHVM [wip]
- [x] Sendmail
- [x] IonCube Loader (w/ option prompt)
- [x] Improve script structure
- [ ] FTP Server (w/ option prompt)
- [x] phpMyAdmin (w/ option prompt)
- [x] CSF (w/ option prompt)
- [x] VS-Backup standalone kit (included in FULL Kit also)
- [ ] Full support for Ubuntu 18.04/20.04 & Debian 9/10/11 [wip]
- [ ] Nginx + Page Speed building
- [ ] Build SSL with LetsEncrypt [wip]

---

### Additional Notes and honorable mentions

This is a modification of it's original branch provided by <a href="https://github.com/jbradach/quick-lemp/" target="_blank">quick-lemp</a>. The scripts within VStacklet LEMP Kit come with heavy modifications to the origianl quick-lemp script... in this regards, these two scripts are entirely separate and not similar to one another. Quick-LEMP is mentioned as it started the VStacklet Kit Project... what was to be a simply pull request to it's original owner, took on a new scope and thus simply became a new project. The changes include ushering in **CSF**, **Varnish** as well as installing and configuring **Sendmail** and **phpMyAdmin** for ease of use... and many other changes. The original quick-lemp script is still available and can be found at the link above. Although, it is no longer being maintained.

Quick-Lemp is geared towards python based application installs and using default Boilerplate templates on Nginx/stable versions of no higher than 1.8. This limits the use of new functions and features in Nginx, nothing wrong with that, but some of us are sticklers for a recent version.

My focus was and is to provide a modified version for CMS and typical website server i.e;(WordPress, Joomla!, Drupal, Ghost, Magento ... etc ... ) installations, Updated/Modified/Customized Boilerplate templates to be more 'Nginx mainline' friendly; i.e http/2, as well as the ongoing use of static websites (which the original still handles splendidly!)

Again, please be advised that I am building/testing this script on Debian 11 (bullseye) as it supports Nginx versions higher than 1.8.

As per any contributions, be it suggestions, critiques, alterations and on and on are all welcome!
