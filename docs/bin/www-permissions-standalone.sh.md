# www-permissions-standalone.sh - v3.1.1004


---

vs-perms can be used on any server to backup files, directories and mysql
databases, but it is designed to work with the vStacklet server stack.
This script will backup your database and files.
Please ensure you have read the documentation before continuing.

---


---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
- [vStacklet www-permissions](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/www-permissions.sh.md)

---

This script will do the following:
- Download the latest version of vs-perms.
- Convert vs-perms shell scripts to executable.
- Move `vs-perms` to /usr/local/bin for system execution.
- From there, you can run `vs-perms` from anywhere on your server to do the following:
  - Check the www-data group exists, if not, create it.
  - Check the user group exists, if not, create it.
  - Check the user exists, if not, create it.
  - Check the user is a member of the www-data group, if not, add them.
  - Set the correct permissions for the web root directory.
  - see `vs-perms -h` for more information.

---



### vstacklet::vsperms::standalone()

This function will download the latest version of vs-perms
and install it on your server. It will also convert vs-perms shell scripts
to executable. From there, you can run vs-perms from anywhere on your server.
[see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions-standalone.sh#L60-L65)

---

### vstacklet::vsperms::outro()

This function will display the outro. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions-standalone.sh#L73-L85)

---


