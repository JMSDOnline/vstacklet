# vs-backup - v3.1.1124


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
|  -r   | --retention                | Retention options. (default: 7)
|  -frpe   | --file_retention_path_extension  | Retention path extension for the files. (default: `tar.gz`)
|  -dbrpe   | --database_retention_path_extension  | Retention path extension for the database. (default: `enc`)
|  -h   | --help                     | Display the help menu.
|  -V   | --version                  | Display the version.

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/vs-backup -dbuser "root" -dbpass "password" -db "database" -f "/var/www/html"
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L71-L150)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L157-L162)

---

### vstacklet::backup::variables()

Set the variables for the backup. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L169-L294)

---

### vstacklet::backup::default::variables()

The variables used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L301-L347)

---

### vstacklet::backup::main::checks()

The checks used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L354-L395)

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L402-L419)

---

### vstacklet::backup::files()

Backup the specified files. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L426-L483)

---

### vstacklet::backup::database()

Backup a database. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L503-L553)

note: This function will additionally package the database backup into a tarball
and compress it on the fly, then encrypt it. The tarball will be moved to the
destination directory and the temporary directory will be cleaned up.
- To decrypt the tarball, use the following command example: (replace the variables)
```
openssl enc -d -pbkdf2 -in "${DB_DIR_DEST:-/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}.enc" -out "${DB_TMP_DIR_DEST:-/tmp/vstacklet/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}" -k "${DB_PASS}"
```
- To extract the tarball, use the following command example: (replace the variables)
```
tar -xzf "${DB_TMP_DIR_DEST:-/tmp/vstacklet/backup/databases/}${DB}.sql.${DATE_STAMP}${COMPRESSION_EXTENSION}" -C "${DB_TMP_DIR_DEST:-/tmp/vstacklet/backup/databases/}"
```

---

### vstacklet::backup::retention()

The retention used in the backup script. This is used to delete
old backups. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L573-L599)

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

Prints the outro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L606-L611)

---

### vstacklet::backup::usage()

Display the usage of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L618-L659)

---

### vstacklet::backup::example_cron()

Example cron job for the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L666-L674)

---

### vstacklet::backup::version()

Display the version of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/vs-backup#L681-L687)

---


