#!/usr/bin/env bash
#REQUIRES GETENT
set -euo pipefail

echo "=== Non-system users (UID >= 1000, except nobody) ==="
awk -F: '$3 >= 1000 && $1 != "nobody" {printf "%-20s uid=%-6s home=%-30s shell=%s\n", $1, $3, $6, $7}' /etc/passwd

echo
echo "=== Users in admin groups (sudo, wheel, adm, docker, lxd, etc.) ==="

PRIV_GROUPS=(sudo wheel adm admin docker lxd libvirt)

for g in "${PRIV_GROUPS[@]}"; do
  if getent group "$g" >/dev/null 2>&1; then
    echo
    echo "-> Group: $g"
    getent group "$g" | awk -F: '{print "  members:", $4}'
  fi
done

echo
echo "=== /etc/sudoers and sudoers.d ==="
if [[ -f /etc/sudoers ]]; then
  echo "-- /etc/sudoers --"
  # show non-comment lines
  grep -Ev '^\s*#' /etc/sudoers | sed '/^\s*$/d' || true
fi

if [[ -d /etc/sudoers.d ]]; then
  echo
  echo "-- /etc/sudoers.d --"
  for f in /etc/sudoers.d/*; do
    [[ -f "$f" ]] || continue
    echo
    echo "File: $f"
    grep -Ev '^\s*#' "$f" | sed '/^\s*$/d' || true
  done
fi
