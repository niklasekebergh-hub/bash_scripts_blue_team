#!/usr/bin/env bash

set -euo pipefail

CRITICAL_FILES=(
  /etc/passwd
  /etc/shadow
  /etc/group
  /etc/gshadow
  /etc/sudoers
  /etc/ssh/sshd_config
)

echo "=== Critical file permission check ==="
for f in "${CRITICAL_FILES[@]}"; do
  if [[ -e "$f" ]]; then
    perms=$(stat -c '%a' "$f")
    owner=$(stat -c '%U' "$f")
    group=$(stat -c '%G' "$f")

    # Decode perms for quick checks
    o=${perms: -1}        
    g=${perms: -2:1}      
    u=${perms: -3:1}      

    echo
    echo "$f"
    echo "  perms: $perms (u=$u g=$g o=$o) owner: $owner group: $group"

    if (( o >= 2 )); then
      echo "  [!] World-writable – CHANGE IMMEDIATELY."
    fi
    if (( g >= 2 )); then
      echo "  [!] Group-writable – verify if intentional."
    fi

    if [[ "$f" =~ ^/etc/shadow$|^/etc/gshadow$|^/etc/sudoers$|^/etc/ssh/sshd_config$ ]]; then
      if [[ "$owner" != "root" ]]; then
        echo "  [!] Owner is not root on a root-only file – ."
      fi
    fi
  else
    echo
    echo "$f"
    echo "  [-] Missing (may be normal on some systems, but double-check)."
  fi
done
