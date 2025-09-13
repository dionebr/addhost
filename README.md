# addhost

addhost - Simple Hosts File Manager

Overview

addhost is a small interactive Bash helper to add one or more hostnames to an IP address in /etc/hosts. It is intended for local development and small administrative tasks. The script creates a timestamped backup of /etc/hosts before making changes and provides safe handling when an entry for the same IP already exists.

Key features

- Interactive prompts for IP and space-separated domain names.
- Creates a timestamped backup of /etc/hosts in ~/.hosts_backups/ before modifying.
- Detects existing entries for the same IP and offers to append domains, replace the line, or cancel.
- Avoids adding duplicate exact entries.
- Outputs the last 10 lines of /etc/hosts after changes.

Usage

Run the script from a terminal:

bash /home/dione/tools/addhost.sh

Follow the prompts:
- Enter the IP address (e.g. 127.0.0.1)
- Enter one or more domain names separated by spaces (e.g. example.local myapp.test)

Examples

1) Add a fresh entry for 127.0.0.1:

$ bash /home/dione/tools/addhost.sh
Enter the IP address: 127.0.0.1
Enter the domain(s) (separated by space): example.local myapp.test

2) When an IP already exists, choose behavior:
- a: append new domains (duplicates are filtered)
- r: replace the existing line with the new entry
- c: cancel and leave /etc/hosts untouched

Backup and rollback

Backups are stored at ~/.hosts_backups/hosts.YYYYMMDD-HHMMSS.bak. To roll back a change, copy the desired backup over /etc/hosts using sudo:

sudo cp ~/.hosts_backups/hosts.YYYYMMDD-HHMMSS.bak /etc/hosts

Notes and suggestions

- This script is designed for interactive use. If you need non-interactive behavior, I can add command-line flags (for example, --ip, --domains, --append, --replace, --dry-run).
- For stricter validation, consider adding IPv4/IPv6 format checks or using external tools like ipcalc.
- Running a static analyzer like shellcheck will improve robustness and surface common shell pitfalls.

Security

The script uses sudo for operations that modify /etc/hosts. Ensure you trust the script and review the backup files before restoring.

License

No license specified. Use at your own risk.

