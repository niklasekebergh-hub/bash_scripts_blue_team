#!/usr/bin/env bash

set -euo pipefail

OUT_DIR="/root"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
HOSTNAME=$(hostname -s)
OUT_FILE="${OUT_DIR}/blue_summary-${HOSTNAME}-${TIMESTAMP}.txt"

{
  echo "=== MACHINE SUMMARY: ${HOSTNAME} ==="
  echo "Generated: ${TIMESTAMP}"
  echo

  echo "=== OS / KERNEL ==="
  if [[ -f /etc/os-release ]]; then
    cat /etc/os-release
  fi
  echo
  uname -a
  echo

  echo "=== IP ADDRESSES ==="
  ip addr show || ifconfig -a || true
  echo

  echo "=== LISTENING PORTS (short) ==="
  if command -v ss >/dev/null 2>&1; then
    ss -tulpen
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tulpen
  fi
  echo

  echo "=== NON-SYSTEM USERS (UID >= 1000) ==="
  awk -F: '$3 >= 1000 && $1 != "nobody" {printf "%-20s uid=%-6s home=%-30s shell=%s\n", $1, $3, $6, $7}' /etc/passwd
  echo

  echo "=== SUDOERS (non-comment lines) ==="
  if [[ -f /etc/sudoers ]]; then
    echo "-- /etc/sudoers --"
    grep -Ev '^\s*#' /etc/sudoers | sed '/^\s*$/d' || true
  fi
  if [[ -d /etc/sudoers.d ]]; then
    echo
    echo "-- /etc/sudoers.d --"
    for f in /etc/sudoers.d/*; do
      [[ -f "$f" ]] || continue
      echo "File: $f"
      grep -Ev '^\s*#' "$f" | sed '/^\s*$/d' || true
      echo
    done
  fi
  echo

  echo "=== CRON JOBS (root + users) ==="
  echo "-- /etc/crontab --"
  [[ -f /etc/crontab ]] && cat /etc/crontab || echo "not present"
  echo

  echo "-- /etc/cron.* dirs --"
  for d in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.d; do
    [[ -d "$d" ]] || continue
    echo "Dir: $d"
    ls -l "$d"
    echo
  done

  echo "-- Per-user crontabs (UID >= 1000) --"
  if command -v getent >/dev/null 2>&1; then
    users=$(getent passwd | cut -d: -f1)
  else
    users=$(cut -d: -f1 /etc/passwd)
  fi
  for u in $users; do
    uid=$(id -u "$u" 2>/dev/null || echo 0)
    if (( uid < 1000 )) && [[ "$u" != "root" ]]; then
      continue
    fi
    if crontab -u "$u" -l &>/dev/null; then
      echo "crontab for $u:"
      crontab -u "$u" -l
      echo
    fi
  done

} | tee "$OUT_FILE"

echo
echo "[+] Summary written to: $OUT_FILE"
