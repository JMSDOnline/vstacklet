# vStacklet - A Buff LEMP Stack Kit

---

<div align="center">

| ![vStacklet - A Buff LEMP Stack Kit](https://github.com/JMSDOnline/vstacklet/blob/main/developer_resources/images/vstacklet-lemp-kit.png "vStacklet") |
| ----------------------------------------------------------------------------------------------------------------------------------- |
| **vStacklet - A Buff LEMP Stack Kit**                                                                                               |

## Script status

  Version: v4.0.0.948
  Build: 948

[![MIT License](https://img.shields.io/badge/license-MIT%20License-blue.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet/blob/main/LICENSE)

### Supported OS/Distro

| Debian | [![Debian 12 Supported](https://img.shields.io/badge/Debian%2012-supported-green.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Debian 13 Supported](https://img.shields.io/badge/Debian%2013-supported-green.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) |
|--------------|--|--|
| Ubuntu | [![Ubuntu 24.04 Not yet](https://img.shields.io/badge/Ubuntu%2024.04-not%20yet-lightgrey.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) | [![Ubuntu 26.04 Not yet](https://img.shields.io/badge/Ubuntu%2026.04-not%20yet-lightgrey.svg?style=flat-square)](https://github.com/JMSDOnline/vstacklet) |

</div>

---

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#what-is-vstacklet-back-to-top">What is vStacklet?</a></li>
    <li><a href="#script-features-back-to-top">Script Features</a></li>
    <li><a href="#not-offered-in-vstacklet-40-back-to-top">Not offered in vStacklet 4.0</a></li>
    <li><a href="#getting-started-back-to-top">Getting Started</a>
          <ul>
            <li><a href="#prerequisites-back-to-top">Prerequisites</a></li>
            <li><a href="#installation-back-to-top">Installation</a></li>
            <li><a href="#example-back-to-top">Example</a></li>
            <li><a href="#rolling-back-back-to-top">Rolling back</a></li>
            <li><a href="#additional-options--usage-back-to-top">Additional Options & Usage</a></li>
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
> vStacklet 4.0 installs on Debian 12 (bookworm) and Debian 13 (trixie) only. Ubuntu 24.04 and 26.04 are not supported yet; the installer refuses them before making any change. Older releases (Ubuntu 16.04 to 22.04, Debian 8 to 11) are not supported.
>
> vStacklet is a utility for quickly getting a server with WordPress deployed. It is a full kit that installs what a WordPress server needs in one run, not a tool for installing components one at a time. If you are looking for a modular script, [Quick LEMP](https://github.com/jbradach/quick-lemp/) is the script that inspired vStacklet. Do note that Quick LEMP is not actively maintained and I wouldn't recommend using it for production use.

## What is vStacklet? <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

vStacklet is a kit to quickly install a [LEMP Stack](https://lemp.io) and perform basic configurations of new Debian 12 and Debian 13 servers.

vStacklet 4.0 installs Nginx from nginx.org, your choice of PHP 8.3, 8.4 or 8.5 (on Debian 13, PHP 8.4 only for now), MariaDB from the release's own archive (10.11 on Debian 12, 11.8 on Debian 13) and WordPress. Varnish, phpMyAdmin, Sendmail, CSF, ionCube Loader, an FTP server, MySQL, PostgreSQL, Redis and Let's Encrypt certificates are not offered in vStacklet 4.0 (see [Not offered in vStacklet 4.0](#not-offered-in-vstacklet-40-back-to-top)).

---

## Script Features <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- Easy to use - just run the script with your needed arguments and follow the prompts.
- Fast and lightweight install - no bloatware, just the essentials.
- Thoroughly documented - each script has its own documentation for easy reference. The code is also heavily commented, making it easier to understand what's going on.
- Quiet installer - no more long scrolling text vomit, just see what's important; when it's presented.
- Each run writes its own log to `/var/log/vstacklet/` for additional observations; earlier logs are kept.
- Color Coding for emphasis on install processes.
- Nginx from nginx.org, with HTTP/2 and IPv6, and a self-signed certificate on 443 to start with.
- Your choice of PHP 8.3, 8.4 or 8.5 (on Debian 13, PHP 8.4 only for now), with OPcache, and the Memcached, igbinary and Imagick PHP extensions where the release offers them.
- MariaDB from the release's own archive, with a database and user staged for WordPress.
- WordPress installed and staged in your web root (`-wp`).
- Vendor packages only with repository keys whose fingerprints vStacklet pins.
- No Apache - Full throttle!
- Dynamic rollback built-in should the install fail: run `vstacklet --rollback` on its own. It removes the packages and directories the installer added. On the first install on a fresh server, run within six hours of the bootstrap, it also removes the tools the bootstrap installed for itself (git, gpg and the like), while tools that were already on the server, and anything you installed between the bootstrap and the installer, stay. These always stay: sudo, the vStacklet command and its folders (/opt/vstacklet, /usr/local/bin/vstacklet, /root/vstacklet) and the empty /backup folders. It also works after a release leaves regular support, while its packages are still on the Debian mirrors; once a release has moved to archive.debian.org, the rollback cannot restore its package sources and the server must be rebuilt from a fresh image. A server upgraded to a new release since its install cannot be rolled back and must be rebuilt from a fresh image.
- Actively maintained w/ updates added when stable.

---

## Not offered in vStacklet 4.0 <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

These options are not offered in vStacklet 4.0. Passing one stops the installer before it changes anything:

- Varnish (`-varnish`, `-varnishP`)
- phpMyAdmin (`-pma`)
- Sendmail (`-sendmail`, `-sendmailP`)
- CSF (`-csf`, `-csfCf`)
- ionCube Loader (`-ioncube`)
- An FTP server (`-ftp`)
- MySQL (`-mysql`, `-mysqlU`, `-mysqlPw`, `-mysqlP`), PostgreSQL (`-postgre` and its options) and Redis (`-redis` and its options)
- Let's Encrypt certificates (`-d`, `--dns`) and the email they registered with (`-e`)
- HHVM (`-hhvm`)

The 3.x helper tools `vs-backup` and `vs-perms` are not installed by vStacklet 4.0.

---

## Getting Started <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

### Prerequisites <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

*You should read these scripts before running them so you know what they're doing.* Changes may be necessary to meet your needs.

**You can review the setup script documentation [here](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)**

**Setup** must be run as **root** on a fresh **Debian 12** or **Debian 13** installation. **Stack** should be run on a server without any existing LEMP or LAMP components.

---

### Installation <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

**vStacklet FULL Kit - Installs and configures the vStacklet LEMP kit stack**

**This script is to be ran first**. First you will need to download the vStacklet installation script and make it executable. You can do this by running the following command:

> [!IMPORTANT]
>
> - This script will only download the vStacklet kit and install the `vstacklet` command.
> - Install from the main branch. The `-b` option names another branch (default: main); other branches are for development and may hold older or unfinished code, so do not use them on a server you depend on. The bootstrap reads the branch's version first and refuses one that doesn't hold vStacklet 4, before anything is installed.
> - The `-b` option is only available for the vStacklet installer script.
> - The `-h` option will display the help menu for the vStacklet installer script.
> - The `-V` option will display the version of the vStacklet installer script.

Run these as **root**. On a server where you log in as a user with sudo, become root first with `sudo -i`.

**Grab the latest *`stable`* release**
```bash
apt update && apt -y install curl &&
bash <(curl -s https://raw.githubusercontent.com/JMSDOnline/vstacklet/main/setup/vstacklet.sh)
```

Once the script has been downloaded and made executable, you can then run the script to install the vStacklet kit, as seen in the example below.

---

#### Example <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

> [!TIP]
>
> The following example will:
> - set the server's hostname (`-hn`),
> - install Nginx (`-nginx`),
> - install PHP 8.4 (`-php '8.4'`),
> - install MariaDB and create the WordPress database user (`-mariadb` | `-mariadbU` | `-mariadbPw`),
> - set the web root (`-wr`),
> - install WordPress (`-wp`).
>
> The `-mariadbU` flag sets the MariaDB database username. (**When setting the username for the database, do not use `root` as the username.** The database is installed with a `root` user by default bound to the localhost.) The `-mariadbPw` flag sets the MariaDB database password. On Debian 12 you can choose `-php '8.3'`, `-php '8.4'` or `-php '8.5'`; on Debian 13, `-php '8.4'` for now.

```bash
vstacklet -hn 'server.example.com' -nginx -php '8.4' -mariadb -mariadbU 'db_username' -mariadbPw 'db_password' -wr '/var/www/html/vsapp' -wp
```

---

#### Rolling back <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

If the install fails, run `vstacklet --rollback` on its own. It lists what it will do and asks before changing anything. See the rollback item under [Script Features](#script-features-back-to-top) for what it removes and what stays.

---

#### Additional Options & Usage <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

To view the available options, run the script with the `-h` option (`vstacklet -h`) or better yet, view the documentation [here](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)!


---

## F.A.Q. <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

**Q:** What is the purpose of vStacklet?<br>
**A:** vStacklet is a utility for quickly getting a server with WordPress deployed. It is a full kit that installs what a WordPress server needs in one run, not a tool for installing components one at a time.

**Q:** Which releases does vStacklet 4.0 support?<br>
**A:** Debian 12 (bookworm) and Debian 13 (trixie). Ubuntu 24.04 and 26.04 are not supported yet; the installer refuses them before making any change. Older releases (Ubuntu 16.04 to 22.04, Debian 8 to 11) are not supported.
> [!CAUTION]
> Installing vStacklet on a release that has reached end of life is not recommended and may cause issues.

**Q:** Which PHP versions can I choose?<br>
**A:** PHP 8.3, 8.4 or 8.5 on Debian 12, and PHP 8.4 on Debian 13 for now. The installer refuses any other version before making any change.

**Q:** Why is there no option to install Apache?<br>
**A:** vStacklet is designed to be a lightweight and fast install. Apache is not included in the script as it is not needed. Nginx is a high-performance web server that is designed to be lightweight and fast. It is a better choice for most web applications. If you are having reservations about using Nginx due to the lack of familiarity, I would recommend using the script on a test server to get a feel for it. vStacklet will handle the setting up of the necessary configurations for you.

**Q:** Did you say the script is actively maintained?<br>
**A:** Yes, the script is actively maintained. Updates are added when stable and when I have time to sit down and test. vStacklet 4.0 is tested on Debian 12 and Debian 13 amd64 lab servers; arm64 installs but has not had the same test run yet. If you have any issues with the script, please let me know and I will do my best to fix them. If you have any suggestions for improvements, please let me know and I will do my best to implement them.

**Q:** What happens when a vendor's repository key (nginx.org, Sury PHP) expires or changes?<br>
**A:** vStacklet 4.0 installs vendor packages only with keys whose fingerprints it pins. When a pinned key is within 90 days of expiring, the installer says so during the package check and again in the end summary; after the vendor renews it, run `vstacklet --refresh-keys` to fetch the renewed key, which is accepted only if its fingerprint still matches. When a vendor replaces its key with a new one, vStacklet refuses it on purpose: update vStacklet to a version that pins the new key, then run `vstacklet --refresh-keys`.

**Q:** Can I upgrade a server that runs vStacklet 3.x?<br>
**A:** No. vStacklet 4 installs on fresh servers only. On a server with a 3.x install, the bootstrap stops before it changes anything and leaves the 3.x install as it is.

**Q:** What happened to vs-backup and vs-perms?<br>
**A:** They are 3.x tools and vStacklet 4.0 does not install them.

**Q:** Are you maintaining vStacklet on your own?<br>
**A:** Yes, I am maintaining vStacklet on my own. I am a web developer and I proudly eat my own dog food (have been using vStacklet for a while now for use with client projects). I have found it to be a very useful tool for quickly getting a server up and running. I have made some modifications to the script to better suit my needs, and I am continuing to work on it to make it even better. I am always looking for ways to improve the script, so if you have any suggestions, please let me know.

**Q:** Do you take donations?<br>
**A:** I do not take donations. I am happy to provide this script for free and I am happy to help you with any issues you may have (as I find the time). If you have any suggestions for improvements, please let me know and I will do my best to implement them. If you have any issues with the script, please let me know and I will do my best to fix them. I am always looking for ways to improve the script, so if you have any suggestions, please let me know. If you really want to donate, I would recommend donating to a charity of your choice, or to an open source project that you use and love. You can also donate contributions to improve the code! :smile:

---

## The TO-DO List <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

- [x] OPcache, and the PHP Memcached extension (the Memcached server itself is not installed)
- [x] Your choice of PHP 8.3, 8.4 or 8.5
- [x] Debian 12 and Debian 13
- [x] Vendor repository keys pinned by fingerprint
- [x] Rollback of a failed install
- [x] Automagically build and setup a WordPress site
- [ ] Ubuntu 24.04 and 26.04
- [ ] PHP 8.3 and 8.5 on Debian 13
- [ ] Let's Encrypt certificates, with DNS-based verification
- [ ] Varnish
- [ ] phpMyAdmin
- [ ] Sendmail
- [ ] A firewall
- [ ] ionCube Loader
- [ ] FTP server

---

## Additional Notes and honorable mentions <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

This is a modification of it's original branch provided by <a href="https://github.com/jbradach/quick-lemp/" target="_blank">quick-lemp</a>. The scripts within vStacklet LEMP Kit come with heavy modifications to the origianl quick-lemp script... in this regards, these two scripts are entirely separate and not similar to one another. Quick-LEMP is mentioned as it started the vStacklet Kit Project... what was to be a simple pull request to it's original repository, took on a new scope and thus became a new project. The 3.x series ushered in **CSF**, **Varnish** as well as installing and configuring **Sendmail** and **phpMyAdmin** for ease of use... and many other changes. The original quick-lemp script is still available and can be found at the link above. Although, it is no longer being maintained.

Quick-Lemp is geared towards python based application installs and using default Boilerplate templates on Nginx/stable versions of no higher than 1.8. This limits the use of new functions and features in Nginx, nothing wrong with that, but some of us are sticklers for a recent version.

My focus was and is to provide a modified version for CMS and typical website server i.e;(WordPress, Joomla!, Drupal, Ghost, Magento ... etc ... ) installations, Updated/Modified/Customized Boilerplate templates to be more 'Nginx mainline' friendly; i.e http/2, as well as the ongoing use of static websites (which the original still handles splendidly!)

vStacklet 4.0 installs on Debian 12 (bookworm) and Debian 13 (trixie). Ubuntu 24.04 (noble) and 26.04 (resolute) are not supported yet; the installer refuses them before making any change.

---

## Contributing <sup><sub>([Back to top](#vstacklet---a-buff-lemp-stack-kit))</sub></sup>

As per any contributions, be it suggestions, critiques, alterations and on and on are all welcome! You can view more on that in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

<div align="center">

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=917d3ff0e1c8&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

</div>
