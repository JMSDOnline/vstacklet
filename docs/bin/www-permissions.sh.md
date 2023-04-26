# www-permissions.sh - v3.1.1061


---

Quickly create a new www-data group and set permissions for
${www_root:-/var/www/html}.

---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)

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
 /opt/vstacklet/bin/www-permissions.sh -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html"
```

---



### vstacklet::wwwperms::args()

Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L68-L99)

notes:
- This script function is responsible for processing the options passed to the
script.

#### parameters:

-  $1 (string) - The option to process.
-  $2 (string) - The value of the option to process.

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L108-L178)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L187-L192)

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L201-L212)

---

### vstacklet::wwwdata::create()

Adds a new www-data group and sets permissions for ${www_root:-/var/www/html}. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L229-L260)

#### options:

-  $1 `-wwwU | --www_user` - The user to add to the www-data group. (default: www-data)
-  $2 `-wwwG | --www_group` - The group to create. (default: www-data) (optional)
-  $3 `-wwwR | --www_root` - The root directory to set permissions for. (default: /var/www/html) (optional)
-  $4 `-wwwh | --www_help` - Prints the help message.
-  $5 `-wwwv | --www_version` - Prints the version number.

#### arguments:

-  $1 - The username to add to the www-data group.
-  $2 - The groupname to add to the www-data group.
-  $3 - The web root directory to set permissions for.
-  $4 - (no args) - Prints the help message.
-  $5 - (no args) - Prints the version number.

---

### vstacklet::permissions::adjust()

Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L323-L326)

notes:
- Permissions are adjusted based the following variables:
  - adjustments are made to the assigned web root on the `-wwwR | --www_root`
   option
  - adjustments are made to the default web root of `/var/www/html`
  if the `-wwwR | --www_root` option is not used.
- permissions are adjusted to the following:
  - `root:www-data` (user:group)
  - `755` (directory)
  - `644` (file)
  - `g+rw` (group read/write)
  - `g+s` (group sticky)

*function has no options*

*function has no arguments*

---

### vstacklet::permissions::complete()

Complete the permissions adjustment process. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L326-L329)

*function has no options*

*function has no arguments*

---

### vstacklet::wwwperms::help()

Prints the help message for the www-data group. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L335-L366)

*function has no options*

*function has no arguments*

---

### vstacklet::wwwperms::version()

Prints the version of the www-permissions script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L375-L378)

*function has no options*

*function has no arguments*

---


