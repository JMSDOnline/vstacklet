# vstacklet-backup-standalone.sh - v3.1.1142


---

vs-backup can be used on any server to backup files, directories and mysql
databases, but it is designed to work with the vStacklet server stack.
This script will backup your database and files.
Please ensure you have read the documentation before continuing.

---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)
- [vStacklet VS-Backup Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/bin/backup/vs-backup.md)

---

This script will do the following:
- Download the latest version of vs-backup.
- Convert vs-backup shell scripts to executable.
- Move `vs-backup` to /usr/local/bin for system execution.
- From there, you can run `vs-backup` from anywhere on your server to do the following:
  - Backup your database.
  - Backup your files.
  - Compress the backup files. (default: tar.gz - for files and sql.gz - for database)
  - Automatically encrypt the backup files. (password: set to your database password by default - `-dbpass`)
  - Retain the backup files based on the retention options. (default: 7 days)
  - see `vs-backup -h` for more information.

---



### vstacklet::vsbackup::standalone()

This function will download the latest version of vs-backup
and install it on your server. It will also convert vs-backup shell scripts
to executable. From there, you can run vs-backup from anywhere on your server.
[see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vstacklet-backup-standalone.sh#L60-L65)

---

### vstacklet::vsbackup::outro()

This function will display the outro. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vstacklet-backup-standalone.sh#L73-L85)

---


