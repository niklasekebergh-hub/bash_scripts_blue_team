#!/usr/bin/env bash

set -euo pipefail

# Try to detect main auth log
AUTH_LOG=""
for f in /var/log/auth.log /var/log/secure; do
  if [[ -f "$f" ]]; then
    AUTH_LOG="$f"
    break
  fi
done

if [[ -z "$AUTH_LOG" ]]; then
  echo "[-] No /var/log/auth.log or /var/log/secure found. Maybe use journalctl."
  exit 1
fi

echo "Using auth log: $AUTH_LOG"
echo

echo "=== Failed SSH logins (invalid users) ==="
grep -Ei 'sshd.*(Failed password|Invalid user)' "$AUTH_LOG" || echo "  none found"

echo
echo "=== Successful SSH logins ==="
grep -Ei 'sshd.*Accepted password' "$AUTH_LOG" || echo "  none found"

echo
echo "=== Sudo activity ==="
grep -Ei 'sudo: .*TTY=' "$AUTH_LOG" || echo "  none found"

echo
echo "=== Possible brute-force patterns (multiple failures from same IP) ==="
grep -Ei 'Failed password' "$AUTH_LOG" | awk '{for(i=1;i<=NF;i++){if($i ~ /rhost=|from=/){gsub("rhost=","",$i); gsub("from=","",$i); print $i}}}' \
  | sort | uniq -c | sort -nr | head

echo
