# vs-backup - v3.1.1157


---

vs-backup can be used on any server to backup files, directories and mysql
databases, but it is designed to work with the vStacklet server stack.
This script will backup your database and files.
Please ensure you have read the documentation before continuing.

---

- [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
- [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)

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
|  -dbuser   | --database_user          | The database user. (default: `root`)
|  -dbpass   | --database_password      | The database password. (default: pulled from `/root/.my.cnf`)
|  -dbdbu   | --database_backup_directory   | The database destination backup directory. (default: `/backup/databases`)
|  -dbtbu   | --database_temporary_directory  | The database temporary backup directory. (default: `/tmp/vstacklet/backup/databases`)
|  -dbenc   | --database_encryption     | Encrypt the database backup. (default: `false`)
|  -f   | --files                    | Backup files in the web root directory.
|  -fdbu   | --file_backup_directory   | The files destination backup directory. (default: `/backup/files`)
|  -ftbu   | --file_temporary_directory  | The files temporary backup directory. (default: `/tmp/vstacklet/backup/files`)
|  -r   | --retention                | Retention options. (default: `7`)
|  -frpe   | --file_retention_path_extension  | Retention path extension for the files. (default: `tar.gz`)
|  -dbrpe   | --database_retention_path_extension  | Retention path extension for the database. (default: `enc`)
|  -h   | --help                     | Display the help menu.
|  -V   | --version                  | Display the version.

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/vs-backup -db "database" -f "/var/www/html"
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L70-L149)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L156-L161)

---

### vstacklet::backup::variables()

Set the variables for the backup. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L168-L297)

---

### vstacklet::backup::default::variables()

The variables used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L304-L351)

---

### vstacklet::backup::main::checks()

The checks used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L358-L391)

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L398-L415)

---

### vstacklet::backup::files()

Backup the specified files. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L422-L465)

---

### vstacklet::backup::database()

Backup a database. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L485-L524)

note: This function will additionally package the database backup into a tarball
and compress it on the fly, then encrypt it. The tarball will be moved to the
destination directory and the temporary directory will be cleaned up.
- To decrypt the tarball, use the following command example: (replace the variables)
```
openssl enc -d -pbkdf2 -in "${db_dir_dest:-/backup/databases/}${db}.sql.${date_stamp}.${compression_extension}.enc" -out "${db_tmp_dir_dest:-/tmp/vstacklet/backup/databases/}${db}.sql.${date_stamp}.${compression_extension}" -k "${db_pass}"
```
- To extract the tarball, use the following command example: (replace the variables)
```
tar -xzf "${db_tmp_dir_dest:-/tmp/vstacklet/backup/databases/}${db}.sql.${date_stamp}.${compression_extension}" -C "${db_tmp_dir_dest:-/tmp/vstacklet/backup/databases/}"
```

---

### vstacklet::backup::retention()

The retention used in the backup script. This is used to delete
old backups. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L544-L568)

notes:
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

Prints the outro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L575-L580)

---

### vstacklet::backup::usage()

Display the usage of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L587-L640)

---

### vstacklet::backup::example_cron()

Example cron job for the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L647-L655)

---

### vstacklet::backup::version()

Display the version of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L662-L668)

---


