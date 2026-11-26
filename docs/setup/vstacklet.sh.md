# vstacklet.sh - v4.0.0


---

This script is designed to be run as root on a fresh Debian 12 (bookworm) or Debian 13 (trixie) server. Ubuntu 24.04 and 26.04 are not supported yet. It records the server before adding its own tools, so `vstacklet --rollback` can remove them again. If you have any questions, comments, or suggestions, please feel free to open an issue on GitHub.

---

- Documentation is available at: [/docs/](https://github.com/JMSDOnline/vstacklet/tree/main/docs)
  - :book: [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
  - :book: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)

---

vStacklet 4.0 installs and configures the following:
- Nginx from nginx.org (HTTP server)
- PHP 8.3, 8.4 (default) or 8.5 (FPM) on Debian 12; PHP 8.4 on Debian 13
- MariaDB from the release's own archive (10.11 on Debian 12, 11.8 on Debian 13)
- WordPress

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

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L66-L71)

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L80-L245)

![@dev-note: This function is required](https://img.shields.io/badge/%40dev--note-This%20function%20is%20required-blue)

---

### vstacklet::setup::variables()

Set the variables for the setup. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L254-L312)

notes: this script function is responsible for setting the variables for the setup.

---

### vstacklet::setup::download()

Setup the environment and download vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L337-L396)

notes:
- This script function is responsible for downloading vStacklet from GitHub and setting up the environment for the installation.
  - VStacklet will be downloaded to `/opt/vstacklet`.
  - `vstacklet-server-stack.sh` will be loaded to `/usr/local/bin/vstacklet`. This will allow you to run `vstacklet [options] [args]` from anywhere on the server.
- This script function will also check for the existence of the required packages and install them if they are not found.
  - these include:
    ```bash
    curl sudo wget git gpg lsb-release bind9-dnsutils openssl bc
    ```

---

### vstacklet::setup::help()

Display the help menu for the setup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L403-L424)

---

### vstacklet::version::display()

Display the version of vStacklet. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/setup/vstacklet.sh#L431-L439)

---

### vstacklet::setup::main()

Calls functions in required order.

---


