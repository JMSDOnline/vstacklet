# directory-backup.sh - v3.1.1118


---

Create a backup of specified directories

---

This script will do the following:
- Create a backup of specified directories

---

#### options:
| Short | Long                       | Description
| ----- | -------------------------- | ------------------------------------------
|  `-t` | `--temporary_directory`    | Path to temporary directory (default: /tmp/vstacklet/backup/directories/) [optional]
|  `-d` | `--destination_directory`  | Path to backup directories (default: /backup/directories/) [optional]
|  `-f` | `--file`                   | File/Directory to backup (default: /var/www/html)
|  `-a` | `--all`                    | Backup all files in directory (default: false)
|  `-ec`| `--example_cron`           | Display example cron entry
|  `-h` | `--help`                   | Display this help message
|  `-V` | `--version`                | Display version information

---

#### examples:
```bash
 /opt/vstacklet/bin/backup/directory-backup.sh -f /var/www/html -d /backup/directories/ -t /tmp/directories/ -a
```

---

notes:
- This script is intended to be used with the vstacklet backup script.
- When using the `-a` option, the script will backup all files in the directory
specified with the `-f` option.
- When using the `-f` option, the script will backup the specified file only.

---



### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/directory-backup.sh#L63-L142)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/directory-backup.sh#L149-L154)

---

### vstacklet::backup::main()

The main function of the backup script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/directory-backup.sh#L161-L272)

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


