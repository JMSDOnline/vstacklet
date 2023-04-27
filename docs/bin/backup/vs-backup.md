# vs-backup - v3.1.1083


---

vStacklet Backup Script

---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)

---

This script will do the following:
- Backup your database.
- Backup your files.

---

#### options:
| Short | Long                       | Description
| ----- | -------------------------- | ------------------------------------------
|  -db   | --database                 | Backup the database.
|  -dbuser   | --database-user          | The database user.
|  -dbpass   | --database-password      | The database password.
|  -dbdbu   | --database_backup_directory   | The database destination backup directory. (default: /backup/databases)
|  -dbtbu   | --database_temporary_directory  | The database temporary backup directory. (default: /tmp/vstacklet/backup/databases)
|  -f   | --files                    | Backup files in the web root directory.
|  -fdbu   | --file_backup_directory   | The files destination backup directory. (default: /backup/files)
|  -ftbu   | --file_temporary_directory  | The files temporary backup directory. (default: /tmp/vstacklet/backup/files)
|  -a   | --all                      | Backup all files in the web root directory.
|  -h   | --help                     | Display the help menu.
|  -V   | --version                  | Display the version.

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/vs-backup -dbuser "root" -dbpass "password" -db "database" -f "/var/www/html" -a"
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L67-L146)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L153-L158)

---

### vstacklet::backup::variables()

Set the variables for the backup.

---

### vstacklet::backup::default::variables()

The variables used in the backup script.

---

### vstacklet::backup::main::checks()

The checks used in the backup script.

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L201-L212)

---

### vstacklet::backup::files()

Backup the specified files.

---

### vstacklet::backup::database()

---

### vstacklet::backup::retention()

The retention used in the backup script. This is used to delete
old backups.

note:
- The retention is based on the modification time of the file.
- Default retention is 7 days.
- The retention path options are used to exclude directories from the retention.
- Default retention paths are /backup/files/ and /backup/databases/. These can
be changed by setting the `-fdbu` and `-dbdbu` variables.

---

### vstacklet::outro()

Prints the outro message.

---

### vstacklet::backup::usage()

Display the usage of the backup script.

---

### vstacklet::backup::example_cron()

Example cron job for the backup script.

---

### vstacklet::backup::version()

Display the version of the backup script.

---


