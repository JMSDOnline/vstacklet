# vStacklet 4.0 development build: options and steps

What each installer option and each always-run step does in this build. Every row is one of: **rewritten for 4.0**, **refused until its own step** (the installer stops before any change), or **runs as 3.x code, accepted because ...**. Check a release's opening against this table, and update it in the same commit as any change to an option or step.

## Options

| Option | State in this build |
|---|---|
| `-h`, `-V` | Rewritten for 4.0: print only, before the release gate, no root needed |
| `-nginx` | Rewritten for 4.0: nginx from nginx.org (pinned keys, priority 900 pin) |
| `-php 8.3, 8.4, 8.5` | Rewritten for 4.0: from the release's archive where it ships that version, otherwise packages.sury.org with a pin that keeps every other vendor package below the release; exactly one PHP at the end |
| `-mariadb` | Rewritten for 4.0: from the release's archive; root signs in through the socket |
| `-mariadbU`, `-mariadbPw`, `-mariadbP` | Rewritten for 4.0: the admin account with a stored password only with `-mariadbU` (password in /root/.my.cnf, 0600); `-mariadbPw` needs `-mariadbU` |
| `-wp` | Rewritten for 4.0: WordPress checked against wordpress.org's checksum, wp-cli 2.12.0 pinned by SHA-512, its own database user, strict confirmation |
| `-wr` | Rewritten for 4.0: folders under /var/www only (the rollback covers /var/www) |
| `-hn` | Rewritten for 4.0: sets the hostname and the 127.0.1.1 line only when given |
| `-e` | Accepted: stored for the steps that use it |
| `-http`, `-https` | Accepted: the ports the nginx site listens on, checked free by the gate |
| `-ssh` | Runs as 3.x code on Debian, accepted because it edits one `Port` line the rollback restores and restarts ssh, which keeps open sessions; refused on Ubuntu until ssh.socket is handled |
| `-r` | Accepted: reboots at the end only when given (or on an explicit yes at a terminal) |
| `-d`, `--dns` | Refused until the TLS step (acme.sh pinned at a release at or above 3.1.7) |
| `-ftp` | Refused until its own step |
| `-varnish`, `-varnishP` | Refused until its own step (Varnish 9.1 LTS, version-pinned) |
| `-redis`, `-redisPw`, `-redisP` | Refused until its own step |
| `-mysql`, `-mysqlU`, `-mysqlPw`, `-mysqlP` | Refused until its own step |
| `-postgre`, `-postgreU`, `-postgrePw`, `-postgreP` | Refused until its own step |
| `-pma` | Refused until its own step |
| `-sendmail`, `-sendmailP` | Refused until its own step |
| `-ioncube` | Refused until its own step |
| `-hhvm`, `-csf` | Refused: removed in 4.0 |
| `--rollback` | Rewritten for 4.0: returns the server to its record, keeping the system's own updates |
| `--refresh-keys` | Rewritten for 4.0: replaces a vendor key only when it still matches its pinned fingerprint; a vendor's new key needs an updated vStacklet, and a key expiring within 90 days is repeated in the end summary |
| `--check_update` | Rewritten for 4.0: compares 4.x tags |

## Steps that run on every install

| Step | State in this build |
|---|---|
| Release gate, install gate, package check | Rewritten for 4.0: before any change |
| Intro and "press any key" | Rewritten for 4.0: before any change |
| Install record | Rewritten for 4.0 |
| Package install | Rewritten for 4.0: one apt call for the list the gate checked |
| `bashrc::set` | Runs as 3.x code, accepted because the originals are kept and the rollback restores both files |
| `hostname::set` | Rewritten for 4.0: only with `-hn` or `-d` |
| `webroot::set` | Runs as 3.x code, accepted because it only creates folders under /var/www, which the rollback removes |
| `ssh::set` | See `-ssh` |
| `ftp::set` | Does nothing in this build (`-ftp` is refused) |
| `block::ssdp` | Runs as 3.x code on Debian, accepted because it adds one iptables rule the rollback removes; to be checked before any Ubuntu release opens (ufw) |
| `locale::set` | Rewritten for 4.0 |
| `permissions::adjust` | Runs as 3.x code, accepted because it only changes ownership and modes under the web root |
| Completion message and reboot | Rewritten for 4.0: no reboot without `-r` or an explicit yes |
