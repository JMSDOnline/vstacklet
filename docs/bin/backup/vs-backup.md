# vs-backup - v3.1.1096


---

vStacklet Backup Script

---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/development/docs/setup/vstacklet-server-stack.sh.md)

---

This script will do the following:
- Backup your database.
- Backup your files.
- Compress the backup files. (default: tar.gz - for files and sql.gz - for database)
- Automatically encrypt the backup files. (password: set to your database password by default - `-dbpass`)
- Retain the backup files based on the retention options. (default: 7 days)

---

#### options:
| Short | Long                       | Description
| ----- | -------------------------- | ------------------------------------------
|  -db   | --database                 | Backup the database.
|  -dbuser   | --database_user          | The database user.
|  -dbpass   | --database_password      | The database password.
|  -dbdbu   | --database_backup_directory   | The database destination backup directory. (default: /backup/databases)
|  -dbtbu   | --database_temporary_directory  | The database temporary backup directory. (default: /tmp/vstacklet/backup/databases)
|  -f   | --files                    | Backup files in the web root directory.
|  -fdbu   | --file_backup_directory   | The files destination backup directory. (default: /backup/files)
|  -ftbu   | --file_temporary_directory  | The files temporary backup directory. (default: /tmp/vstacklet/backup/files)
|  -a   | --all                      | Backup all files in the web root directory.
|  -r   | --retention                | Retention options. (default: 7)
|  -frpo   | --file_retention_path_options  | Retention path options for the files. (default: `-type f -name '*.tar.gz'`)
|  -dbrpo   | --database_retention_path_options  | Retention path options for the database. (default: `-type f -name '*.sql.gz'`)
|  -h   | --help                     | Display the help menu.
|  -V   | --version                  | Display the version.

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/vs-backup -dbuser "root" -dbpass "password" -db "database" -f "/var/www/html" -a"
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L72-L151)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L158-L163)

---

### vstacklet::backup::variables()

Set the variables for the backup. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L170-L288)

---

### vstacklet::backup::default::variables()

The variables used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L295-L346)

---

### vstacklet::backup::main::checks()

The checks used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L353-L402)

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L409-L427)

---

### vstacklet::backup::files()

Backup the specified files. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L435-L493)

---

### vstacklet::backup::database()


---

### vstacklet::backup::retention()

The retention used in the backup script. This is used to delete
old backups. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L561-L587)

note:
- The retention is based on the modification time of the file.
- Default retention is 7 days. This can be changed by setting the `-r` variable.
  - example: `-r 14` would set the retention to 14 days.
- The retention path options are used to exclude directories from the retention.
- Default retention paths are /backup/files/ and /backup/databases/. These can
be changed by setting the `-fdbu` and `-dbdbu` variables.
  - example: `-fdbu /backup/files/backup/` would create and set the file retention
path to /backup/files/backup/.

---

### vstacklet::outro()

Prints the outro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L594-L599)

---

### vstacklet::backup::usage()

Display the usage of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L606-L650)

---

### vstacklet::backup::example_cron()

Example cron job for the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L657-L665)

---

### vstacklet::backup::version()

Display the version of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L672-L678)

---


