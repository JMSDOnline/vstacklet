# www-permissions.sh - v3.1.1093


---

Quickly create a new www-data group and set permissions for
${www_root:-/var/www/html/vsapp}.

---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)

---

This script will do the following:
- Checks the www-data group exists, if not, create it.
- Checks the user group exists, if not, create it.
- Checks the user exists, if not, create it.
- Checks the user is a member of the www-data group, if not, add them.
- Set the correct permissions for the web root directory.

---

#### examples:
Set the correct permissions for the web root directory:
```bash
 vs-perms -wwwU "www-data" -wwwG "www-data" -wwwR "/var/www/html/vsapp"
```
Display the help message:
```bash
 vs-perms -h
```
Display the version number:
```bash
 vs-perms -V
```

---



### vstacklet::vsperms::args()

Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L69-L100)

notes:
- This script function is responsible for processing the options passed to the
script.

#### parameters:

-  $1 (string) - The option to process.
-  $2 (string) - The value of the option to process.

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L107-L186)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L193-L198)

---

### vstacklet::vsperms::updater()

Update the permissions script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L205-L219)

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L226-L243)

---

### vstacklet::vsperms::create()

Adds a new www-data group and sets permissions for ${www_root:-/var/www/html/vsapp}. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L260-L291)

#### options:

-  $1 `-wwwU | --www_user` - The user to add to the www-data group. (default: www-data)
-  $2 `-wwwG | --www_group` - The group to create. (default: www-data) (optional)
-  $3 `-wwwR | --www_root` - The root directory to set permissions for. (default: /var/www/html/vsapp) (optional)
-  $4 `-wwwh | --www_help` - Prints the help message.
-  $5 `-wwwv | --www_version` - Prints the version number.

#### arguments:

-  $1 - The username to add to the www-data group.
-  $2 - The groupname to add to the www-data group.
-  $3 - The web root directory to set permissions for.
-  $4 - (no args) - Prints the help message.
-  $5 - (no args) - Prints the version number.

---

### vstacklet::vsperms::adjust()

Adjust permissions for the web root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L313-L351)

notes:
- Permissions are adjusted based the following variables:
  - adjustments are made to the assigned web root on the `-wwwR | --www_root`
   option
  - adjustments are made to the default web root of `/var/www/html/vsapp`
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

### vstacklet::vsperms::complete()

Prints completion of the permissions adjustment process. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L360-L365)

*function has no options*

*function has no arguments*

---

### vstacklet::vsperms::help()

Prints the help message for the vs-perms script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L374-L419)

*function has no options*

*function has no arguments*

---

### vstacklet::vsperms::version()

Prints the version of the vs-perms (www-permissions) script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/www-permissions.sh#L428-L435)

*function has no options*

*function has no arguments*

---


