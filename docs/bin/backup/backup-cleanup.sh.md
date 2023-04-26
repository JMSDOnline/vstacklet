# www-permissions.sh - v3.1.1074


---

Cleanup old backups

---

This script will do the following:
1. Remove backups older than X days
2. Remove backups older than X weeks

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

Stage various functions for the setup environment. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L121)

---

### vstacklet::environment::checkroot()

Check if the user is root. [see function](https://github.com/JMSDOnline/vstacklet/blob/development/bin/backup/backup-cleanup.sh#L208)

---


