#!/usr/bin/env bash

set -euo pipefail

WEBROOTS=(
  /var/www
  /srv/www
  /usr/share/nginx/html
)

echo "=== WEBROOT SCAN ==="

for root in "${WEBROOTS[@]}"; do
  [[ -d "$root" ]] || continue

  echo
  echo "-> Scanning $root"

  echo
  echo "-- PHP & CGI files (non-root owners) --"
  find "$root" -type f \( -name '*.php' -o -name '*.php5' -o -name '*.cgi' \) \
    -printf '%u %g %m %p\n' 2>/dev/null | awk '$1 != "root"'

  echo
  echo "-- World-writable in webroot --"
  find "$root" -type f -perm -0002 -printf '%u %g %m %p\n' 2>/dev/null

  echo
  echo "-- Suspicious names (shell, backdoor, cmd, upload) --"
  find "$root" -type f -iregex '.*\(shell\|backdoor\|cmd\|upload\).*' \
    -printf '%u %g %m %p\n' 2>/dev/null
done
