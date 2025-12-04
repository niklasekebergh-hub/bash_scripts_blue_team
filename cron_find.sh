#!/usr/bin/env bash

set -euo pipefail

echo "=== System crontab (/etc/crontab) ==="
if [[ -f /etc/crontab ]]; then
  cat /etc/crontab
else
  echo "[-] /etc/crontab not found."
fi

echo
echo "=== /etc/cron.* directories ==="
for d in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.d; do
  if [[ -d "$d" ]]; then
    echo
    echo "-> $d"
    ls -l "$d"
  fi
done

echo
echo "=== Per-user crontabs ==="
if command -v getent >/dev/null 2>&1; then
  users=$(getent passwd | cut -d: -f1)
else
  users=$(cut -d: -f1 /etc/passwd)
fi

for u in $users; do
  # Skip system/daemon accounts
  uid=$(id -u "$u" 2>/dev/null || echo 0)
  if (( uid < 1000 )) && [[ "$u" != "root" ]]; then
    continue
  fi

  if crontab -u "$u" -l &>/dev/null; then
    echo
    echo "--- crontab for user: $u ---"
    crontab -u "$u" -l
  fi
done
