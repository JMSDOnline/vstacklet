# database-backup.sh - v3.1.1094


---

Create database backups

---

This script will do the following:
1. Create a backup of all databases

---



### vstacklet::backup::args()

Process the options passed to the script. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L67)

notes:
- This script function is responsible for processing the options passed to the
script.

#### parameters:

-  $1 (string) - The option to process.
-  $2 (string) - The value of the option to process.

---

### vstacklet::environment::functions()

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L123)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/www-permissions.sh#L187-L192)

---

### vstacklet::backup::database()

Backup a database to a file.

---

### vstacklet::backup::usage()

Display the usage of the backup script.

---


