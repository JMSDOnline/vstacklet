# www-permissions.sh - v3.1.1018


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



### vstacklet::www::args()

Process the options passed to the script. [see function](

notes:
- This script function is responsible for processing the options passed to the
script.

#### parameters:

-  $1 (string) - The option to process.
-  $2 (string) - The value of the option to process.

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L538-L671)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L764-L766)

#### return codes:

- 1 = you must be root to run this script.

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/setup/vstacklet-server-stack.sh#L796-L820)

---

### vstacklet::wwwdata::adjust()

Adds a new www-data group and sets permissions for ${www_root:-/var/www/html}. [see function]()

#### options:

-  ${www_user:-www-data} -wwwU | --www_user - The user to add to the www-data group. (default: www-data)
-  ${www_group:-www-data} -wwwG | --www_group - The group to create. (default: www-data) (optional)
-  $3 -wwwR | --www_root - The root directory to set permissions for.
-  $4 -wwwH | --www_help - Prints the help message.
-  $5 -wwwV | --www_version

#### arguments:

-  ${www_user:-www-data} - The username to add to the www-data group.
-  ${www_group:-www-data} - The groupname to add to the www-data group.
-  $3 - The web root directory to set permissions for.
-  $4 - Prints the help message.
-  $5 - Prints the version number.

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

### vstacklet::wwwdata::help()

Prints the help message for the www-data group.

*function has no options*

*function has no arguments*

---

### vstacklet::wwwdata::version()

Prints the version of the www-permissions script.

*function has no options*

*function has no arguments*

---


