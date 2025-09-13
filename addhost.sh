#!/usr/bin/env bash
# Simple Hosts File Manager
# - Removed decorative icons
# - Adds input validation, backup, and safer updates

set -euo pipefail

HOSTS_FILE="/etc/hosts"
BACKUP_DIR="$HOME/.hosts_backups"

echo "=== addhost - Hosts Manager ==="

usage() {
    cat <<EOF
Usage: addhost.sh
This script interactively adds one or more domains for an IP to $HOSTS_FILE.
You will be prompted for the IP and space-separated domains.
EOF
}

# Prompt for IP
read -r -p "Enter the IP address: " IP
if [[ -z "${IP// /}" ]]; then
    echo "Error: IP address cannot be empty." >&2
    usage
    exit 1
fi

# Prompt for domains
read -r -p "Enter the domain(s) (separated by space): " DOMAINS
if [[ -z "${DOMAINS// /}" ]]; then
    echo "Error: At least one domain is required." >&2
    usage
    exit 1
fi

ENTRY="$IP $DOMAINS"

# Create backup directory and a timestamped backup of /etc/hosts
mkdir -p "$BACKUP_DIR"
timestamp=$(date +%Y%m%d-%H%M%S)
backup_file="$BACKUP_DIR/hosts.$timestamp.bak"
echo "Creating backup of $HOSTS_FILE at $backup_file"
sudo cp "$HOSTS_FILE" "$backup_file"

# If the exact entry exists, inform the user and exit
if sudo grep -Fxq "$ENTRY" "$HOSTS_FILE"; then
    echo "This exact entry already exists in $HOSTS_FILE: $ENTRY"
    exit 0
fi

# If there is an existing line for the IP, ask whether to append domains or replace
if sudo grep -Eq "^\s*${IP//./\.}\b" "$HOSTS_FILE"; then
    existing_line=$(sudo grep -E "^\s*${IP//./\.}\b.*" "$HOSTS_FILE" | head -n1)
    echo "Found existing entry for IP $IP: $existing_line"
    read -r -p "Do you want to (a)ppend domains, (r)eplace the line, or (c)ancel? [a/r/c]: " CHOICE
    case "$CHOICE" in
        a|A)
            # Append domains (avoid duplicates)
            sudo sed -n "/^\s*${IP//./\.}\b/ { s/^\s*${IP//./\.}\\s*//; p }" "$HOSTS_FILE" | \
                { read -r existing_domains || true; true; }
            # build new domain list avoiding duplicates
            new_domains="$(tr ' ' '\n' <<<"$existing_domains $DOMAINS" | awk '!seen[$0]++' | tr '\n' ' ' | sed 's/ $//')"
            new_entry="$IP $new_domains"
            sudo sed -i "s/^\s*${IP//./\.}.*$/${new_entry//\/\/\/}/" "$HOSTS_FILE" || true
            echo "Updated entry: $new_entry"
            ;;
        r|R)
            # Replace the entire line for the IP
            sudo sed -i"" -e "/^\s*${IP//./\.}\b/ d" "$HOSTS_FILE" || true
            echo "$ENTRY" | sudo tee -a "$HOSTS_FILE" > /dev/null
            echo "Replaced entry with: $ENTRY"
            ;;
        *)
            echo "Operation cancelled. No changes were made. Backup is at: $backup_file"
            exit 1
            ;;
    esac
else
    # No existing IP entry: append new entry
    echo "$ENTRY" | sudo tee -a "$HOSTS_FILE" > /dev/null
    echo "Added: $ENTRY"
fi

echo "Current entries (last 10 lines):"
tail -n 10 "$HOSTS_FILE"
