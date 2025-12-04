#!/usr/bin/env bash

set -euo pipefail

echo "=== LISTENING SOCKETS ==="

if command -v ss >/dev/null 2>&1; then
  ss -tulpen
elif command -v netstat >/dev/null 2>&1; then
  netstat -tulpen
else
  echo "[-] Neither ss nor netstat found."
fi

echo
echo "=== ESTABLISHED/CONNECTED SESSIONS (TCP) ==="

if command -v ss >/dev/null 2>&1; then
  ss -tanp | awk 'NR==1 || /ESTAB/'
elif command -v netstat >/dev/null 2>&1; then
  netstat -tanp | awk 'NR==2 || /ESTABLISHED/'
fi

echo
echo "=== TOP TALKERS BY REMOTE IP (TCP) ==="
if command -v ss >/dev/null 2>&1; then
  ss -tanp | awk '/ESTAB/ {print $5}' | sed 's/:.*//' | sort | uniq -c | sort -nr | head
elif command -v netstat >/dev/null 2>&1; then
  netstat -tanp | awk '/ESTABLISHED/ {print $5}' | sed 's/:.*//' | sort | uniq -c | sort -nr | head
fi
