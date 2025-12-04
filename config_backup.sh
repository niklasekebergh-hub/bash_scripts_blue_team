#!/usr/bin/env bash

set -euo pipefail

BACKUP_ROOT="/root/ccdc_backups"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
HOSTNAME=$(hostname -s)
BACKUP_FILE="${BACKUP_ROOT}/${HOSTNAME}-backup-${TIMESTAMP}.tar.gz"

INCLUDE_DIRS=(
  /etc
  /var/www
  /srv/www
  /usr/local/etc
)

mkdir -p "$BACKUP_ROOT"

echo "=== CONFIG BACKUP ==="
echo "Backup file: $BACKUP_FILE"
echo

for d in "${INCLUDE_DIRS[@]}"; do
  [[ -d "$d" ]] || continue
  echo "Including: $d"
done

echo
tar -czpf "$BACKUP_FILE" "${INCLUDE_DIRS[@]}" 2>/dev/null || {
  echo "[-] tar failed. Check paths/permissions."
  exit 1
}

echo
echo "[+] Backup complete."
echo "Store this path in your team docs: $BACKUP_FILE"
