#!/usr/bin/env bash

set -euo pipefail
# add more paths as needed
SEARCH_PATHS=(
  /
)

echo "=== SUID/SGID binaries (excluding virtual filesystems) ==="
for p in "${SEARCH_PATHS[@]}"; do
  if [[ -d "$p" ]]; then
    echo
    echo "-> Scanning $p"
    find "$p" \
      -xdev \
      \( -perm -4000 -o -perm -2000 \) \
      -type f \
      -printf '%m %u %g %p\n' 2>/dev/null
  fi
done

echo
echo "Look for: /tmp, /home, /var/www or other web roots, or random app directories like: /opt/someapp/bin
