# These are the current scipts I use in CCDC style competitions
The functionality of each script is usually self-explanatory based on the name, but I will give a brief summary here for clarity:

**config_backup.sh**

Creates a timestamped tarball of critical configuration directories (e.g., /etc, /var/www) and stores it under /root/. Used to preserve the system’s state before making major changes.

**cron_find.sh**

Enumerates system cron jobs from /etc/crontab, /etc/cron.* directories, and all user crontabs. Helpful for identifying malicious or unexpected scheduled tasks.

**file_perms.sh**

Checks critical system files (passwd, shadow, sudoers, SSH config) for unsafe permissions or incorrect ownership. Flags world/group-writable issues and potential privilege-escalation risks.

**log_hunt.sh**

Parses auth logs (auth.log or secure) to report failed logins, successful SSH attempts, sudo activity, and repeated attacker IPs. Used for quick threat hunting and intrusion detection.

**machine_summary.sh**

Generates a full system snapshot including OS info, IP configuration, listening ports, users, sudoers, and cron jobs. Saves output to /root for team documentation.

**net_conn.sh**

Lists all listening ports, owning processes, and active TCP connections. Also identifies “top talker” remote IPs to quickly spot suspicious or unauthorized network activity.

**roll_passwords.sh**

Automatically rotates passwords for root and all non-system users with valid shells. Generates strong passwords, applies them with chpasswd, and stores results in a root-only file.

**service_audit.sh**

Displays all enabled and running services via systemd or sysvinit tools. Useful for catching rogue daemons, persistence, or unexpected services.

**suid_scan.sh**

Searches the filesystem for SUID/SGID binaries, excluding virtual filesystems. Highlights potential privilege-escalation backdoors or dangerous binaries.

**user_group.sh**

Lists non-system users and audits membership in privileged groups such as sudo, adm, docker, and lxd. Also displays non-comment sudoers entries for quick privilege review.

**webroot_scan.sh**

Scans common webroot directories for suspicious PHP/CGI files, world-writable content, and filenames associated with web shells or malicious uploads.

**world_writeable.sh**

Finds world-writable files and directories within sensitive paths (e.g., /etc, /var, /home). Helps identify tampering, persistence, or insecure file permissions.
