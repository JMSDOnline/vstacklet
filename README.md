# vStacklet - A Buff LEMP Stack Kit

---

<div align="center">

| ![vStacklet - A Buff LEMP Stack Kit](https://github.com/JMSDOnline/vstacklet/blob/main/developer_resources/images/vstacklet-lemp-kit.png "vStacklet") |
| ----------------------------------------------------------------------------------------------------------------------------------- |
| **vStacklet - A Buff LEMP Stack Kit**                                                                                               |

## Script status

  Version: v3.1.1.882
  Build: 882

[![MIT License](https://img.shields.io/badge/license-MIT%20License-blue.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet/blob/main/LICENSE)

### Supported OS/Distro

| Ubuntu | [![Ubuntu 16.04 EOL](https://img.shields.io/badge/Ubuntu%2016.04-EOL-black.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Ubuntu 18.04 EOL](https://img.shields.io/badge/Ubuntu%2018.04-EOL-black.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Ubuntu 20.04 Passing](https://img.shields.io/badge/Ubuntu%2020.04-passing-green.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Ubuntu 22.04 Passing](https://img.shields.io/badge/Ubuntu%2022.04-passing-green.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) |
|--------------|--|--|--|--|
| Debian | [![Debian 9 EOL](https://img.shields.io/badge/Debian%209-EOL-black.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Debian 10 EOL](https://img.shields.io/badge/Debian%2010-EOL-black.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Debian 11 Passing](https://img.shields.io/badge/Debian%2011-passing-green.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Debian 12 Passing](https://img.shields.io/badge/Debian%2012-passing-green.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) |

</div>

---

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#what-is-vstacklet-back-to-top">What is vStacklet?</a></li>
    <li><a href="#script-features-back-to-top">Script Features</a></li>
    <li><a href="#meet-the-scripts-back-to-top">Meet the Scripts</a>
          <ul>
            <li><a href="#vstacklet---full-kit-installs-and-configures-lemp-stack-with-support-for-website-based-server-environments-back-to-top">vStacklet</a> - (Full Kit) Installs and configures LEMP stack with support for Website-based server environments</li>
            <li><a href="#vs-backup---installs-a-single-script-to-help-manage-and-automate-serversite-backups-back-to-top">VS-Backup</a> - Installs a single script to help manage and automate server/site backups</li>
            <li><a href="#vs-perms---installs-a-single-script-to-help-manage-and-automate-www-directory-permissions-back-to-top">VS-Perms</a> - Installs a single script to help manage and automate www directory permissions</li>
          </ul>
        </li>
     <li><a href="#getting-started-back-to-top">Getting Started</a>
          <ul>
            <li><a href="#prerequisites-back-to-top">Prerequisites</a></li>
            <li><a href="#installation-back-to-top">Installation</a></li>
            <li><a href="#example-back-to-top">Example</a></li>
			<li><a href="#verifications-back-to-top">Verifications</a></li>
            <li><a href="#additional-options--usage-back-to-top">Additional Options & Usage</a></li>
          </ul>
        </li>
        <li><a href="#standalone-scripts-back-to-top">Standalone Scripts</a>
          <ul>
            <li><a href="#vstacklet-vs-backup---installs-needed-script-for-running-directory-and-database-backups-included-in-full-kit-also-back-to-top">VS-Backup</a></li>
            <li><a href="#vstacklet-vs-perms---installs-needed-files-for-running-www-permissions-fix-included-in-full-kit-also-back-to-top">VS-Perms</a></li>
          </ul>
        </li>
	<li><a href="#faq-back-to-top">F.A.Q.</a></li>
    <li><a href="#the-to-do-list-back-to-top">The TO-DO List</a></li>
    <li><a href="#additional-notes-and-honorable-mentions-back-to-top">Additional Notes and honorable mentions</a></li>
    <li><a href="#contributing-back-to-top">Contributing</a></li>
  </ol>
</details>

---

> [!WARNING]
>
> vStacklet for Ubuntu 16.04/18.04 and Debian 8/9/10 has been deprecated (Reached End-Of-Life). This is due to Ubuntu 20.04/22.04 and Debian 11/12 now becoming more common place with at least 90% of the providers on the market. To ease the cost of maintaining the script, only the latest versions (LTS) of Ubuntu and Debian are supported. This is to ensure that the script is as up-to-date as possible.
>
> vStacklet is a utility for quickly getting a server with wordpress installed deployed. As is the nature of this script, it is not intended to be a modular script. It is intended to be a full kit that installs everything you need to get a server up and running (not individual components 1 at a time - though it is in the pipeline). If you are looking for a modular script, I recommend [Quick LEMP](https://github.com/jbradach/quick-lemp/) as it is the script that inspired vStacklet. Do note that Quick LEMP is not actively maintained and I wouldn't recommend using it for production use.

## What is vStacklet? <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

vStacklet is a kit to quickly install a [LEMP Stack](https://lemp.io) w/ Varnish and perform basic configurations of new Ubuntu 20.04/22.04 and Debian 11/12 servers.

Components include a recent mainline version of Nginx (mainline (1.25.x)) using configurations from the HTML 5 Boilerplate team (*and modified/customized for use with mainline*), Varnish 7.4.x, and MariaDB 10.11.x (drop-in replacement for MySQL), PHP8.3, PHP8.1, PHP7.4 or HHVM 4.x **new** (users choice), Sendmail (PHP mail function), CSF (Config Server Firewall), Wordpress and more to be added soon. (see [To-Do List](#the-to-do-list-back-to-top))

Deploys a proper directory structure, optimizes Nginx and Varnish, creates a PHP page for testing and more!

---

## Script Features <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- Easy to use - just run the script with your needed arguments and follow the prompts.
- Fast and lightweight install - no bloatware, just the essentials.
- Thouroughly documented - each script has it's own documentation for easy reference. The code is also heavily commented, making it easier to understand what's going on.
- Quiet installer - no more long scrolling text vomit, just see what's important; when it's presented.
- Script writes output to `/var/log/vstacklet/vstacklet.###.log` for additional observations.
- Color Coding for emphasis on install processes.
- Easy optional parameters make it a set it and forget it script.
- Varnish Cache on port 80 with Nginx port 8080 SSL termination on 443.
- Users choice of php8.3, php8.1, php7.4 or HHVM
- No Apache - Full throttle!
- Full Kit functionality - backup scripts included.
- Dynamic rollback built-in should the install fail. All dependencies and directories placed by vStacklet are removed on the rollback.
- Actively maintained w/ updates added when stable.
- HTTP/2 Nginx ready. To view if your webserver is HTTP/2 after installing the script with SSL, check @ <a href="https://tools.keycdn.com/http2-test" target="_blank">HTTP/2 Test via KeyCDN</a>
- Everything you need to get that Nginx + Varnish server up and running!

Total script install time on a General Shared CPU <a href="https://m.do.co/c/917d3ff0e1c8" target="_blank">Digital Ocean Droplet</a> sits at 12/minutes installing everything; CSF, MariaDB, NGinx, PHP8.3, Sendmail, SSL, Varnish, WordPress. This time assumes you are sitting attentively with the script running. There are a limited interactions to be made with the script and most of the softwares installed I have automated and logged. The most is the script will ask to continue. With the exception of Wordpress, the script will ask for database, database username, and database password (the database and user are to be created for the Wordpress install).

---

## Meet the Scripts <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

### **vStacklet** - (Full Kit) Installs and configures LEMP stack with support for Website-based server environments <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- Adds repositories for the latest stable versions of MariaDB (10.11.x), mainline (1.25.x) versions of Nginx, and Varnish 7.4.x.
- Installs choice of PHP8.3, PHP8.1, PHP7.4 or HHVM 4.x
- Installs NGinx and/or Varnish.
- Installs and enables OPCode Cache and fine-tuning for PHP7.4, PHP8.1 *or* PHP8.3.
- Installs and enables Memcached Cache and fine-tuning for PHP7.4, PHP8.1 *or* PHP8.3.
- Installs and enables IonCube Loader [*optional*] (**PHP8.3 currently has no IonCube Loader support**. This will be updated when support is available).
- Installs and configures phpMyAdmin
- Installs choice of database: MariaDB or MySQL (PostgreSQL, or Redis - experimental) [*optional*]
- Installs and configures CSF (Config Server Firewall) - prepares ports used for vStacklet as well as informing your entered email for security alerts.
- Installs and enables (PHP) Sendmail [*optional*] (default to install if `-csf | --csf` is used)
- Supports IPv6 by default.
- Installs self-signed SSL cert configuration. (default)
- Installs and configures LetsEncrypt SSL cert. [*optional*] (default to install if `-d | --domain` is used)
- Installs and stages database for WordPress. [*optional*] (active build - unlike other options that are passive with the flags used. This will change when the script is updated to be a bit more modular; ie: install wordpress (only), install phpmyadmin (only), etc.)
- Easy backup executable **vs-backup** for data-protection.
- Easy web directory permissions fix with executable **vs-perms** for www directory permissions.

Ready to get started? Check out the [prerequisites](#prerequisites-back-to-top) and [installation](#installation-back-to-top) sections below!

<details>
  <summary><b>vStacklet Script Preview</b></summary>

> *All visible details seen here are purely for preview purposes.*
>
> This is from an actual test install and all associated subdomain and credentials are randomized and retired after verification. The script will require your own information and credentials.

![preview 1](https://github.com/JMSDOnline/vstacklet/blob/main/developer_resources/images/vstacklet_install_preview.png "vstacklet preview 1")

</details>

---

### **VS-Backup** - Installs a single script to help manage and automate server/site backups <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- Backup your files from key locations ( ex: /var/www/html/vsapp ) - with the `-f` flag, you can specify directories to backup.
- Backup your mysql/mariadb databases - with the `-db` flag, you can specify databases to backup.
- Set the retention period for your backups - with the `-r` flag, you can specify the number of days to keep backups. (default is 7 days)
- Cleanup remaining individual archives after the retention period has been reached.
- Simply download the script below to start backing up important directories and databases - cron examples included with the `-ec` flag!

To view the available options, run the script with the `-h` option (`vs-backup -h`) or better yet, view the documentation:
- :book: [docs/bin/backup/vs-backup](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vs-backup.md)
- :book: [docs/bin/backup/vstacklet-backup-standalone.sh](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vstacklet-backup-standalone.sh.md)

<details>
  <summary><b>VS-Backup Script Preview</b></summary>

![VS-Backup](https://github.com/JMSDOnline/vstacklet/blob/main/developer_resources/images/vs-backup-utility-preview.png "vStacklet VS-Backup Utility")

</details>

---

### **VS-Perms** - Installs a single script to help manage and automate www directory permissions <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- Checks the www-data group exists, if not, create it. (default: www-data)
- Checks the user group exists, if not, create it. (default: www-data)
- Checks the user exists, if not, create it. (default: www-data)
- Checks the user is a member of the www-data group, if not, add them.
- Set the correct permissions for the web root directory. (default: /var/www/html/vsapp)

To view the available options, run the script with the `-h` option (`vs-perms -h`) or better yet, view the documentation:
- :book: [docs/bin/backup/www-permissions.sh (aka `vs-perms`)](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions.sh.md)
- :book: [docs/bin/backup/www-permissions-standalone.sh](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions-standalone.sh.md)

<details>
  <summary><b>VS-Perms Script Preview</b></summary>

![VS-Perms](https://github.com/JMSDOnline/vstacklet/blob/main/developer_resources/images/vs-perms-utility-preview.png "vStacklet VS-Perms Utility")

</details>

---

## Getting Started <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

### Prerequisites <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

*You should read these scripts before running them so you know what they're doing.* Changes may be necessary to meet your needs.

**You can review the setup script documentation [here](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)**

**Setup** should be run as **root** on a fresh **Ubuntu** or **Debian** installation.
**Stack** should be run on a server without any existing LEMP or LAMP components.

---

### Installation <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

**vStacklet FULL Kit - Installs and configures the vStacklet LEMP kit stack**

( *includes backup (`vs-backup`) and www-permissions (`vs-perms`) scripts* )

**This script is to be ran first**.
First you will need to download the vStacklet installation script and make it executable. You can do this by running the following command:

> [!IMPORTANT]
>
> - **The development branch is not recommended for production use.**
> - This script will only download the vStacklet kit installer script and make it executable. (contains the `vstacklet` script and `vs-backup` and `vs-perms` scripts)
> - Use the `-b` option to specify the branch you wish to install. (default: main)
> If no branch is specified, the main branch will be used.
> - The `-b` option is only available for the vStacklet installer script.
> - The `-h` option will display the help menu for the vStacklet installer script.
> - The `-V` option will display the version of the vStacklet installer script.

**Grab the latest *`stable`* release**
```bash
sudo apt -y install curl &&
bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh)
```

**Grab the latest *`development`* release**
```bash
sudo apt -y install curl &&
bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh) -b development
```

Once the script has been downloaded and made executable, you can then run the script to install the vStacklet kit, as seen in the example below.

---

#### Example <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

> [!TIP]
>
> The following example will:
> - set the admin email (`-e`),
> - stage a verified Let's Encrypt SSL cert (`-d`) [**`-e` is required for `-d`**],
> - set the http port for NGinx to 8080 (`-http '8080'`),
> - set the http port for Varnish to 80 (`-varnishP '80'`),
> - install PHP8.1 (`-php '8.3'`),
> 	- NGinx (`-nginx`),
> 	- Varnish (`-varnish`),
> 	- MariaDB (`-mariadb` | `-mariadbU` | `-mariadbPw`),
> 	- phpMyAdmin (`-pma`),
> 	- CSF (`-csf`),
> 	- Sendmail (`-sendmail`),
> 	- IonCube Loader (`-ioncube`),
>   - Wordpress (`-wp`).
>
> Where NGinx and Varnish are installed, we will set the standard web port for NGinx to 8080 `-http '8080'` and Varnish to 80 `-varnishP '80'`. This is to allow for SSL termination on port 443 with NGinx and Varnish caching on port 80 (*Varnish is **actually** forwarded to port 443 for proper SSL*).<br>
> You'll notice the `-sendmail` flag is not used below, this is OK as the script will install Sendmail if CSF is installed.<br>
> The `-csf` flag is used to install CSF.<br>
> The `-csfCf` flag is used to set Cloudflare IP's in the CSF allow list.<br>
> The `-ioncube` flag is used to install IonCube Loader. (**PHP8.3 currently has no IonCube Loader support.** This will be updated when support is available.)<br>
> The `-pma` flag is used to install phpMyAdmin.<br>
> The `-mariadb` flag is used to install MariaDB.<br>
> The `-mariadbU` flag is used to set the MariaDB database username. (**When setting the username for the database, do not use `root` as the username.** The database is installed with a `root` user by default bound to the localhost.)
> The `-mariadbPw` flag is used to set the MariaDB database password.<br>
> The `-varnish` flag is used to install Varnish.<br>
> The `-nginx` flag is used to install NGinx.<br>
> The `-php` flag is used to install PHP8.3.<br>
> The `-d` flag is used to stage a verified Let's Encrypt SSL cert.<br>
> The `-e` flag is used to set the admin email.<br>
> The `-wp` flag is used to install Wordpress.

```bash
vstacklet -e 'your@email.com' -d 'yourdomain.com' -php '8.3' -nginx -varnish -http '8080' -varnishP '80' -mariadb -mariadbU 'db_username' -mariadbPw 'db_password' -pma -csf -csfCf -wp
```

---

#### Verifications <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

<details>
  <summary><b>vStacklet PHP8.3 Install Verification</b></summary>

![vStacklet PHP Install Verification](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-php83_install-checkinfo-verification.png "vStacklet PHP Install Verification")

</details>

<details>
  <summary><b>vStacklet PHP8.1 Install Verification</b></summary>

![vStacklet PHP Install Verification](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-php_install-checkinfo-verification.png "vStacklet PHP Install Verification")

</details>

<details>
  <summary><b>vStacklet CSF UI & Service Verification</b></summary>

![vStacklet CSF UI & Service Verification](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-csf_install-ui_service-verification.png "vStacklet CSF UI & Service Verification")

</details>

<details>
  <summary><b>vStacklet phpMyAdmin & MariaDB Verification</b></summary>

![vStacklet phpMyAdmin & MariaDB Verification](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-phpmyadmin_mariadb_install-verification_php83.png "vStacklet phpMyAdmin & MariaDB Verification")

</details>

<details>
  <summary><b>vStacklet Varnish Cache Hit Stat Verification</b></summary>

![vStacklet Varnish Cache Stat Verification](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-varnish_cache_stat-verification.png "vStacklet Varnish Cache Stat Verification")

</details>

<details>
  <summary><b>vStacklet Varnish to NGinx SSL Termination Verification</b></summary>

![vStacklet Varnish to NGinx SSL Termination Verification](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-varnish_nginx_ssl_termination-verification.png "vStacklet Varnish to NGinx SSL Termination Verification")

</details>

<details>
  <summary><b>vStacklet Wordpress Install Verification - Proxy Cache Test</b></summary>

Test the proxy cache via `http://` for proper header output. `https://` may return unknown, but this is not an issue as the proxy cache is working as expected, and varnish terminating SSL properly.

![vStacklet Wordpress Install Verification - Proxy Cache Test](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-wordpress_install-verification-proxy_cache_test.png "vStacklet Wordpress Install Verification - Proxy Cache Test")

</details>

<details>
  <summary><b>vStacklet Wordpress Install Verification - Initial Site Health Test</b></summary>

![vStacklet Wordpress Install Verification - Initial Site Health Test](https://github.com/JMSDOnline/vstacklet/blob/development/developer_resources/images/vstacklet-wordpress_install-site_health_check-verification.png "vStacklet Wordpress Install Verification - Initial Site Health Test")

</details>

---

#### Additional Options & Usage <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

To view the available options, run the script with the `-h` option (`vstacklet -h`) or better yet, view the documentation [here](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)!


---

## Standalone Scripts <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

### vStacklet VS-Backup - Installs needed script for running directory and database backups (included in FULL Kit also) <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

```bash
bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/bin/backup/vstacklet-backup-standalone.sh)
```

---

### vStacklet VS-Perms - Installs needed files for running www permissions fix (included in FULL Kit also) <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

```bash
bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/bin/www-permissions-standalone.sh)
```

---

## F.A.Q. <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

**Q:** What is the purpose of vStacklet?<br>
**A:** vStacklet is a utility for quickly getting a server with wordpress installed deployed. As is the nature of this script, it is not intended to be a modular script. It is intended to be a full kit that installs everything you need to get a server up and running (not individual components 1 at a time - though it is in the pipeline).

**Q:** Why does vStacklet not support Ubuntu 16.04 and Debian 8?<br>
**A:** Ubuntu 20.04/22.04 and Debian 11/12 are now becoming more common place with at least 90% of the providers on the market. This is why I have decided to deprecate support for Ubuntu 16.04/18.04 and Debian 8/9/10. This is to ensure that the script is as up-to-date as possible.
> [!CAUTION]
> Debian 9/10 and Ubuntu 18.04 are no longer supported as they have hit EOL. Keep in mind that installing vStacklet on an EOL OS is not recommended and may cause issues.

**Q:** What is the expected install time for vStacklet?<br>
**A:** Total script install time on a General Shared CPU <a href="https://m.do.co/c/917d3ff0e1c8" target="_blank">Digital Ocean Droplet</a> sits at 12/minutes installing everything; CSF, MariaDB, NGinx, PHP8.1, Sendmail, SSL, Varnish, WordPress. This time assumes you are sitting attentively with the script running. There are a limited interactions to be made with the script and most of the softwares installed I have automated and logged. The most is the script will ask to continue. With the exception of Wordpress, the script will ask for database, database username, and database password (the database and user are to be created for the Wordpress install).

**Q:** Why is there the option to install either mariadb or mysql?<br>
**A:** MariaDB is a drop-in replacement for MySQL. It is a fork of MySQL and is maintained by the original developers of MySQL. It is designed to be a drop-in replacement for MySQL, and it includes all of the major features found in MySQL. Either can be used, but MariaDB is recommended.

**Q:** Why is there the option to install either php8.3, php8.1, php7.4 or HHVM?<br>
**A:** PHP8.3 is the latest stable version of PHP. PHP8.1 is the previous stable version of PHP and some folks are still preferring 7 🤷🏽‍♂️. HHVM is a virtual machine designed to execute programs written in Hack and PHP. It is developed by Facebook. HHVM is no longer actively maintained, but is still available for use. PHP8.3 is recommended.
> [!NOTE]
> PHP8.3 is technically the latest stable release, but PHP8.1 is still supported and is a good choice for those who are not ready to move to PHP8.3. *For instance, at the time of writing this note, ioncube has yet to provide a version compatible with 8.3*. PHP7.4 is also supported, but is not recommended as it is no longer supported by the PHP team. HHVM is a virtual machine designed to execute programs written in Hack and PHP. It is developed by Facebook. HHVM is no longer actively maintained, but is still available for use.

**Q:** Why is there no option to install Apache?<br>
**A:** vStacklet is designed to be a lightweight and fast install. Apache is not included in the script as it is not needed. Nginx is a high-performance web server that is designed to be lightweight and fast. It is a better choice for most web applications. If you are having reservations about using Nginx due to the lack of familiarity, I would recommend using the script on a test server to get a feel for it. vStacklet will handle the setting up of the necessary configurations for you.

**Q:** Did you say the script is actively maintained?<br>
**A:** Yes, the script is actively maintained. Updates are added when stable and when I have time to sit down and test. The script is tested on Ubuntu 20.04/22.04 and Debian 11/12. The script is also tested on a variety of different servers to ensure compatibility. If you have any issues with the script, please let me know and I will do my best to fix them. If you have any suggestions for improvements, please let me know and I will do my best to implement them.

**Q:** What is the purpose of the vStacklet VS-Backup script?<br>
**A:** The vStacklet VS-Backup script is designed to help you manage and automate server/site backups. It allows you to backup your files from key locations, backup your mysql/mariadb databases, set the retention period for your backups, and cleanup remaining individual archives after the retention period has been reached. The script is designed to be easy to use and provides you with the ability to download the script and start backing up important directories and databases. Setting a scheduled cron task is easy, just append your `vs-backup` command arguments with the `-cc` flag.

**Q:** What is the purpose of the vStacklet VS-Perms script?<br>
**A:** The vStacklet VS-Perms script is designed to help you manage and automate www directory permissions. It checks the www-data group exists, if not, creates it. It checks the user group exists, if not, creates it. It checks the user exists, if not, creates it. It checks the user is a member of the www-data group, if not, adds them. It sets the correct permissions for the web root directory. The script is designed to be easy to use and provides you with the ability to manage and automate www directory permissions.

**Q:** Are you maintaining vStacklet on your own?<br>
**A:** Yes, I am maintaining vStacklet on my own. I am a web developer and I proudly eat my own dog food (have been using vStacklet for a while now for use with client projects). I have found it to be a very useful tool for quickly getting a server up and running. I have made some modifications to the script to better suit my needs, and I am continuing to work on it to make it even better. I am always looking for ways to improve the script, so if you have any suggestions, please let me know.

**Q:** Do you take donations?<br>
**A:** I do not take donations. I am happy to provide this script for free and I am happy to help you with any issues you may have (as I find the time). If you have any suggestions for improvements, please let me know and I will do my best to implement them. If you have any issues with the script, please let me know and I will do my best to fix them. I am always looking for ways to improve the script, so if you have any suggestions, please let me know. If you really want to donate, I would recommend donating to a charity of your choice, or to an open source project that you use and love. You can also donate contributions to improve the code! :smile:

---

## The TO-DO List <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- [x] Enable OPCode Caching
- [x] Enable Memcached Caching
- [x] Optional install of php7.4, php8.1, php8.3 or HHVM
- [x] Sendmail
- [x] IonCube Loader (w/ option prompt)
- [x] Improve script structure
- [x] FTP Server (w/ option prompt) `-ftp | --ftp_port` will set the port AND install vsftpd
- [x] phpMyAdmin (w/ option prompt) `-pma | --phpmyadmin`
- [x] CSF (w/ option prompt) `-csf | --csf`
- [x] VS-Backup standalone kit (included in FULL Kit also)
- [x] Full support for Ubuntu 20.04/22.04 & Debian 11/12
- [ ] Nginx with Pagespeed (w/ option prompt) `-pagespeed | --pagespeed`
- [x] Build SSL with LetsEncrypt
- [x] Automagically build and setup a WordPress site

---

## Additional Notes and honorable mentions <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

This is a modification of it's original branch provided by <a href="https://github.com/jbradach/quick-lemp/" target="_blank">quick-lemp</a>. The scripts within vStacklet LEMP Kit come with heavy modifications to the origianl quick-lemp script... in this regards, these two scripts are entirely separate and not similar to one another. Quick-LEMP is mentioned as it started the vStacklet Kit Project... what was to be a simple pull request to it's original repository, took on a new scope and thus became a new project. The changes include ushering in **CSF**, **Varnish** as well as installing and configuring **Sendmail** and **phpMyAdmin** for ease of use... and many other changes. The original quick-lemp script is still available and can be found at the link above. Although, it is no longer being maintained.

Quick-Lemp is geared towards python based application installs and using default Boilerplate templates on Nginx/stable versions of no higher than 1.8. This limits the use of new functions and features in Nginx, nothing wrong with that, but some of us are sticklers for a recent version.

My focus was and is to provide a modified version for CMS and typical website server i.e;(WordPress, Joomla!, Drupal, Ghost, Magento ... etc ... ) installations, Updated/Modified/Customized Boilerplate templates to be more 'Nginx mainline' friendly; i.e http/2, as well as the ongoing use of static websites (which the original still handles splendidly!)

Again, please be advised that I am building/testing this script on Ubuntu 20.04 (focal), Ubuntu 22.04 (jammy), Debian 11 (bullseye) & Debian 12 (bookworm) as these support Nginx versions higher than 1.8.

---

## Contributing <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

As per any contributions, be it suggestions, critiques, alterations and on and on are all welcome! You can view more on that in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

<div align="center">

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=917d3ff0e1c8&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

</div>
