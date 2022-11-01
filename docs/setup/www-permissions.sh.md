# www-permissions.sh - v3.1.1042


---

This script is designed to be run on a fresh Ubuntu 18.04/20.04 or
Debian 9/10/11 server. I have done my best to keep it tidy and with as much
error checking as possible. Couple this with loads of comments and you should
have a pretty good idea of what is going on. If you have any questions,
comments, or suggestions, please feel free to open an issue on GitHub.

---

[vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)

---

This script will do the following:
- Checks the www-data group exists, if not, create it.
- Checks the user group exists, if not, create it.
- Checks the user exists, if not, create it.
- Checks the user is a member of the www-data group, if not, add them.
- Set the correct permissions for the web root directory.

---

#### examples:
```bash
 vstacklet -www-perms -wwwR "/var/www/html"
 vstacklet -www-perms -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html"
```

---

#### or as a standalone script:
```bash
 /opt/vstacklet/setup/www-permissions.sh -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html"
```

---



### vstacklet::wwwperms::args()

Process the options passed to the script. [see function](

notes:
- This script function is responsible for processing the options passed to the
script.

#### parameters:

-  $1 (string) - The option to process.
-  $2 (string) - The value of the option to process.

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function]()

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function]()

---

### vstacklet::intro()

Prints the intro message. [see function]()

---

### vstacklet::wwwdata::adjust()

Adds a new www-data group and sets permissions for ${www_root:-/var/www/html}. [see function]()

#### options:

-  $1 --wwwU | --www_user - The user to add to the www-data group. (default: www-data)
-  $2 -wwwG | --www_group - The group to create. (default: www-data) (optional)
-  $3 -wwwR | --www_root - The root directory to set permissions for.
-  $4 -wwwH | --www_help - Prints the help message.
-  $5 -wwwV | --www_version - Prints the version number.

#### arguments:

-  $1 - The username to add to the www-data group.
-  $2 - The groupname to add to the www-data group.
-  $3 - The web root directory to set permissions for.
-  $4 - (no args) - Prints the help message.
-  $5 - (no args) - Prints the version number.

---

### vstacklet::permissions::adjust()

Adjust permissions for the web root. [see function]()

notes:
- Permissions are adjusted based the following variables:
  - adjustments are made to the assigned web root on the `-wwwR | --www_root`
   option
  - adjustments are made to the default web root of `/var/www/html`
  if the `-wwwR | --www_root` option is not used.
- permissions are adjusted to the following:
  - `www-data:www-data` (user:group)
  - `755` (directory)
  - `644` (file)
  - `g+rw` (group read/write)
  - `g+s` (group sticky)

*function has no options*

*function has no arguments*

---

### vstacklet::permissions::complete()

Complete the permissions adjustment process. [see function]()

*function has no options*

*function has no arguments*

---

### vstacklet::wwwperms::help()

Prints the help message for the www-data group.

*function has no options*

*function has no arguments*

---

### vstacklet::wwwperms::version()

Prints the version of the www-permissions script.

*function has no options*

*function has no arguments*

---


