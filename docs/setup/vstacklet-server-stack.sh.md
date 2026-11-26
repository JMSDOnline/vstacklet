# vstacklet-server-stack.sh - v4.0.0


---

vStacklet 4.0 installs and configures a LEMP stack and WordPress on a fresh Debian 12 (bookworm) or Debian 13 (trixie) server, run as root. Ubuntu 24.04 and 26.04 are not supported yet; the installer refuses them, and every option it does not offer, before making any change. The bootstrap (setup/vstacklet.sh) installs this script as the `vstacklet` command; its functions live in setup/lib/, one file per area, and the loader accepts only the files whose SHA-256 it pins.

---

vStacklet 4.0 installs and configures the following:
- Nginx from nginx.org, with HTTP/2 and IPv6, and a self-signed certificate on 443 to start with
- PHP 8.3, 8.4 (default) or 8.5 (FPM) on Debian 12; PHP 8.4 on Debian 13; with OPcache, and the Memcached, igbinary and Imagick PHP extensions where the release offers them
- MariaDB from the release's own archive (10.11 on Debian 12, 11.8 on Debian 13), with a database and user staged for WordPress
- WordPress, staged in your web root

---

Options offered in vStacklet 4.0:

---

| Short | Long | Description |
| ----- | ---- | ----------- |
| -h | --help | show the help |
| -V | --version | show the version |
| -hn | --hostname | hostname to use for the server |
| -ssh | --ssh_port | port to use for the SSH server |
| -http | --http_port | port to use for the HTTP server |
| -https | --https_port | port to use for the HTTPS server |
| -nginx | --nginx | install Nginx |
| -php | --php | PHP version to install (8.3, 8.4 or 8.5 on Debian 12; 8.4 on Debian 13; default 8.4) |
| -mariadb | --mariadb | install MariaDB |
| -mariadbP | --mariadb_port | port to use for the MariaDB server |
| -mariadbU | --mariadb_user | the MariaDB admin account to create (do not use root) |
| -mariadbPw | --mariadb_password | password for that account |
| -wr | --web_root | web root, a folder under /var/www/ |
| -wp | --wordpress | install WordPress (needs -nginx and -mariadb) |
| -r | --reboot | reboot the server after the install |
| | --rollback | undo an install: restore the state recorded before its first change; run it on its own |
| | --refresh-keys | re-fetch the vendor repository keys, accepted only if their pinned fingerprints still match |
| | --check_update | check the installed branch for a newer 4.x release |

---

Example:

---

```bash
vstacklet -hn 'server.example.com' -nginx -php '8.4' -mariadb -mariadbU 'db_username' -mariadbPw 'db_password' -wr '/var/www/html/vsapp' -wp
```

---

Not offered in vStacklet 4.0 (refused before any change): -e, --email; -d, --domain; --dns, --dns_provider; -ftp; -ioncube; -mysql, -mysqlU, -mysqlPw, -mysqlP; -postgre and its options; -redis and its options; -pma; -sendmail, -sendmailP; -varnish, -varnishP; -csf, -csfCf; -hhvm.

---

Rollback: `vstacklet --rollback` lists what it will do and asks before changing anything. It also works after a release leaves regular support, while its packages are still on the Debian mirrors; once a release has moved to archive.debian.org, it cannot restore the release's package sources, and the server must be rebuilt from a fresh image. A server upgraded to a new release since its install cannot be rolled back.

---

vStacklet 4.0 is tested on Debian 12 and Debian 13 amd64 lab servers; arm64 installs but has not had the same test run yet.

---

Important Links:
- :pencil: GITHUB REPO:   https://github.com/JMSDOnline/vstacklet
- :bug: ISSUE TRACKER: https://github.com/JMSDOnline/vstacklet/issues

---



### vstacklet::gate::refuse()

Runs before anything on the server is changed: root, the release and its support dates, the architecture.

Support dates come from the vendors' own pages, read 2026-11-23:
- Debian: https://www.debian.org/releases/bookworm/ , https://www.debian.org/releases/trixie/ , https://wiki.debian.org/LTS
- Ubuntu: https://ubuntu.com/about/release-cycle (states a month only; the gate uses the last day of that month)
- PHP:    https://www.php.net/supported-versions.php

A release counts as supported until its free security support ends: for Debian the end of Debian LTS (a Debian project), for Ubuntu the end of standard support. Paid extended support (Freexian ELTS for Debian, Ubuntu ESM) is not counted. A Debian release past its regular security support but inside Debian LTS installs with a notice.

Row: id|version|codename|regular security end|free security end|end as the vendor states it|who supports it until then

---


