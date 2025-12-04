#!/usr/bin/env bash

set -euo pipefail

PATHS=(
  /etc
  /var
  /home
  /opt
  /usr/local
)

echo "=== World-writable directories ==="
for p in "${PATHS[@]}"; do
  if [[ -d "$p" ]]; then
    echo
    echo "-> $p"
    find "$p" -xdev -type d -perm -0002 -printf '%m %u %g %p\n' 2>/dev/null
  fi
done

echo
echo "=== World-writable files ==="
for p in "${PATHS[@]}"; do
  if [[ -d "$p" ]]; then
    echo
    echo "-> $p"
    find "$p" -xdev -type f -perm -0002 -printf '%m %u %g %p\n' 2>/dev/null
  fi
done

echo
echo "Note: /tmp and /var/tmp are normally world-writable; focus on stuff in /etc, web roots, and home dirs."
