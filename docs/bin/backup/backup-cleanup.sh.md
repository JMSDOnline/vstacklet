# backup-cleanup.sh - v3.1.1100


---

Cleanup old backups

---

This script will do the following:
- Remove backups older than X days
- Remove backups older than X weeks

---

#### options:
| Short | Long                       | Description
| ----- | -------------------------- | ------------------------------------------
|  -dir | --directories              | Path to backup directories
|  -db  | --databases                | Path to backup databases
|  -d    | --days                    | Number of days to keep backups (default: 3)
|  -w    | --weeks                   | Number of weeks to keep backups (default: 4)
|  -ec   | --example_cron            | Display example cron entry
|  -h    | --help                    | Display this help message
|  -V    | --version                 | Display version information

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/backup-cleanup.sh -dir /backup/directories/ -db /backup/databases/ [ -d 3 ] [ -w 4 ]
```

---



### vstacklet::backup::args()

Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L67-L113)

notes:
- This script function is responsible for processing the options passed to the
script.

#### parameters:

-  $1 (string) - The option to process.
-  $2 (string) - The value of the option to process.

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L121-L200)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L207-L212)

---

### vstacklet::backup::clean()

Main function for cleaning up backups. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L219-L239)

---

### vstacklet::backup::usage()

Display usage information for the script.

---

### vstacklet::backup::example_cron()

Example cron job for the backup script.

---


