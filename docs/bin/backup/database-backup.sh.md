# database-backup.sh - v3.1.1122


---

Create a backup of specified databases

---

This script will do the following:
- Create necessary directories
- Create a backup of all databases
- Compress the backup file
- Encrypt the backup file

---

#### options:
| Short | Long                       | Description
| ----- | -------------------------- | ------------------------------------------
|  -tmp_dir | --tmp_dir             | Path to temporary directory
|  -backup_dir | --backup_dir       | Path to backup directory
|  -db | --database                 | Database name
|  -db_user | --database_user       | Database user
|  -db_pwd | --database_password    | Database password
|  -h | --help                      | Display this help message
|  -V | --version                   | Display version information

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/database-backup.sh -tmp_dir /tmp/backup/databases/ -backup_dir /backup/databases/ -db database_name -db_user database_user -db_pwd database_password
```

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L57-L136)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L143-L148)

---

### vstacklet::backup::main()

The main function of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/database-backup.sh#L160-L361)

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


