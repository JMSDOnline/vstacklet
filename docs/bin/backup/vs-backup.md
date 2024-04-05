# vs-backup - v3.1.1239


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
|  -dbdecrypt   | --database_decryption   | Decrypt the selected database backup.
|  -dbextract   | --database_extraction   | Extract the selected database backup.
|  -f   | --files                    | Backup files in the web root directory.
|  -fdbu   | --file_backup_directory   | The files destination backup directory. (default: `/backup/files`)
|  -ftbu   | --file_temporary_directory  | The files temporary backup directory. (default: `/tmp/vstacklet/backup/files`)
|  -r   | --retention                | Retention options. (default: `7`)
|  -frpe   | --file_retention_path_extension  | Retention path extension for the files. (default: `tar.gz`)
|  -dbrpe   | --database_retention_path_extension  | Retention path extension for the database. (default: `enc`)
|  -h   | --help                     | Display the help menu.
|  -V   | --version                  | Display the version.
|  -ec   | --example_cron            | Display an example cron job.
|  -cron   | --cron                  | Run the script in cron mode [ie; only needed when running as a scheduled cron taks].<br>This will skip the intro message, used with cron task.<br>*Not needed if using the `-cc` option.* (default: `false`)
|  -cc   | --cron_create             | Create a cron job. This will create a cron job for the backup script. (default: `false`)

---

#### examples:
```bash
 vs-backup -db "database" -dbuser "root" -dbpass "password" -dbenc -dbtbu "/backup/databases" -dbtbu "/tmp/vstacklet/backup/databases" -f "/var/www/html" -fdbu "/backup/files" -ftbu "/tmp/vstacklet/backup/files" -r "7" -dbrpe "enc" -cc
```

---

```bash
 vs-backup -dbdecrypt
```

---

```bash
 vs-backup -dbextract
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L84-L190)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L197-L202)

---

### vstacklet::backup::updater()

Update the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L209-L226)

---

### vstacklet::backup::variables()

Set the variables for the backup. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L233-L388)

---

### vstacklet::backup::default::variables()

The variables used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L395-L444)

---

### vstacklet::backup::main::checks()

The checks used in the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L451-L486)

---

### vstacklet::intro()

Prints the intro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L493-L510)

---

### vstacklet::backup::files()

Backup the specified files. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L517-L561)

---

### vstacklet::backup::database()

Backup a database. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L581-L614)

note: This function will additionally package the database backup into a tarball
and compress it on the fly, then encrypt it. The tarball will be moved to the
destination directory and the temporary directory will be cleaned up.
- To decrypt the tarball, use the following command example: (decrypt only)
```bash
vs-backup -dbdecrypt
```
- To extract the tarball, use the following command example: (can decrypt and extract)
```bash
vs-backup -dbextract
```

---

### vstacklet::backup::retention()

The retention used in the backup script. This is used to delete
old backups. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L634-L658)

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

### vstacklet::backup::cron::create()

Create a cron job for the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L674-L742)

notes:
- The cron job will run daily at 12:30 AM
- The cron job will be created as /etc/cron.d/vs_backup
- The cron job will use the flags provided
- The cron job will run the script in cron mode
- The cron job will redirect the output to /dev/null
- The cron job will run as root

#### examples:

```
 vs-backup -db "db_name" -dbuser "db_user" -dbpass "db_pass" -f "/var/www/html/" -cc
```

---

### vstacklet::outro()

Prints the outro message. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L749-L754)

---

### vstacklet::backup::usage()

Display the usage of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L761-L820)

---

### vstacklet::backup::example_cron()

Example cron job for the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L828-L848)

#### examples:

```
 vs-backup -ec
```

---

### vstacklet::backup::version()

Display the version of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L855-L861)

---

### vstacklet::backup::database_decrypt()

List the files in the backup directory and decrypt selected options. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L878-L937)

notes:
- This function will allow you to decrypt a database backup file.
- You can use the `-dbextract` option instead if you want to decrypt **and** extract the file.

#### examples:

```
 vs-backup -dbdecrypt
```

---

### vstacklet::backup::database_extract()

List the files in the backup directory and extract selected options. [see function](https://github.com/JMSDOnline/vstacklet/blob/main/bin/backup/vs-backup#L949-L1061)

notes:
- This function will allow you to extract a database backup file.
- This function will also decrypt the file if it is encrypted.

#### examples:

```
 vs-backup -dbextract
```

---


