# vstacklet.sh - v3.1.1059


---

This script is designed to be run on a fresh Ubuntu 18.04/20.04 or
Debian 9/10/11 server. I have done my best to keep it tidy and with as much
error checking as possible. Couple this with loads of comments and you should
have a pretty good idea of what is going on. If you have any questions,
comments, or suggestions, please feel free to open an issue on GitHub.

---

- Documentation is available at: [/docs/](https://github.com/JMSDOnline/vstacklet/tree/development/docs)
  - :book: [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
  - :book: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
  - :book: [vStacklet VS-Perms (www-permissions.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions.sh.md)
    - :book: [vStacklet vs-perms (www-permissions-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions-standalone.sh.md)
  - :book: [vStacklet VS-Backup (vs-backup) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/backup/vs-backup.md)
    - :book: [vStacklet vs-backup (vstacklet-backup-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/backup/vstacklet-backup-standalone.sh.md)

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



### setup::download()

Setup the environment and download vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet.sh#L78-L148)

notes:
- This script function is responsible for downloading vStacklet from GitHub
and setting up the environment for the installation.
  - VStacklet will be downloaded to `/opt/vstacklet`.
  - `vstacklet-server-stack.sh` will be loaded to `/usr/local/bin/vstacklet`. This
will allow you to run `vstacklet [options] [args]` from anywhere on the server.
  - `vs-backup` will be loaded to `/usr/local/bin/vs-backup`. This
will allow you to run `vs-backup` from anywhere on the server.
  - `www-permissions.sh` will be loaded to `/usr/local/bin/vs-perms`. This
will allow you to run `vs-perms` from anywhere on the server.
- This script function will also check for the existence of the required
packages and install them if they are not found.
  - these include:
    ```bash
    curl sudo wget git apt-transport-https lsb-release dnsutils openssl
    ```

---


