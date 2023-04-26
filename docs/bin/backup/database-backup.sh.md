# database-backup.sh - v3.1.1131


---

Create a backup of specified databases

---

This script will do the following:
- Create necessary directories
- Create a backup of all databases
- Compress the backup file
- Encrypt the backup file
  - e.g. database_name-2016-01-01-00-00-00.sql.gz.enc
  - encryption password is the same as the database password

---

#### options:
| Short | Long                       | Description
| ----- | -------------------------- | ------------------------------------------
|  -t | --temporary_directory             | Path to temporary directory
|  -b | --backup_directory       | Path to backup directory
|  -db | --database                 | Database name
|  -dbuser | --database_user       | Database user
|  -dbpass | --database_password    | Database password
|  -h | --help                      | Display this help message
|  -V | --version                   | Display version information

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/database-backup.sh -t "/tmp/backup/databases/" -b "/backup/databases/" -db "database_name" -dbuser "database_user" -dbpass "database_password"
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L59-L138)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L145-L150)

---

### vstacklet::backup::main()

The main function of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L162-L363)

notes:
- The retention variables are only used if the backup file compression is set to gzip.
These values are currently not in use with this script. They are here for future use.

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


