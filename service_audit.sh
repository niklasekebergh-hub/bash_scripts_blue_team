#!/usr/bin/env bash

set -euo pipefail

echo "=== SERVICE AUDIT ==="

if command -v systemctl >/dev/null 2>&1; then
  echo
  echo "=== systemd detected ==="

  echo
  echo "-- Enabled services (boot) --"
  systemctl list-unit-files --type=service --state=enabled

  echo
  echo "-- Running services --"
  systemctl list-units --type=service --state=running

else
  echo
  echo "=== Non-systemd (sysvinit/upstart style) ==="

  if command -v service >/dev/null 2>&1; then
    echo
    echo "-- All services (service --status-all) --"
    service --status-all 2>&1 || true
  fi

  if command -v chkconfig >/dev/null 2>&1; then
    echo
    echo "-- chkconfig --list --"
    chkconfig --list 2>&1 || true
  fi
fi
