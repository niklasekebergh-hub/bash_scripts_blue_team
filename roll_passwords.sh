#!/usr/bin/env bash

set -euo pipefail

UID_MIN=1000

OUTPUT_DIR="/root/ccdc_passwords"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
HOSTNAME=$(hostname -s)
OUTPUT_FILE="${OUTPUT_DIR}/passwords-${HOSTNAME}-${TIMESTAMP}.txt"

# Set to 1 if you ALSO want to echo username:password pairs to the terminal.
# Think about who is physically watching the screen + loging to stdout
ECHO_TO_SCREEN=0

gen_password() {
  # Generate a 16-char random password with a decent charset.
  # /dev/urandom + tr + head is fine for competition use.
  tr -dc 'A-Za-z0-9!@#$%^&*()-_=+' < /dev/urandom | head -c16
}

if [[ $EUID -ne 0 ]]; then
  echo "[!] Must be run as root."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
chmod 700 "$OUTPUT_DIR"

# Prevent accidental overwrite
if [[ -e "$OUTPUT_FILE" ]]; then
  echo "[!] Output file already exists: $OUTPUT_FILE"
  echo "    Refusing to overwrite. Move or rename it and rerun."
  exit 1
fi

touch "$OUTPUT_FILE"
chmod 600 "$OUTPUT_FILE"

echo "=== PASSWORD ROLLER ==="
echo "Host: $HOSTNAME"
echo "Output file: $OUTPUT_FILE"
echo


echo "[*] Collecting target users..."

USER_LIST=()

# Always include root
if grep -q '^root:' /etc/passwd; then
  USER_LIST+=("root")
fi

# Add non-system users with real shells
# Fields: name:...:uid:gid:gecos:home:shell
while IFS=: read -r name _ uid _ _ _ shell; do
  if [[ "$name" == "root" ]]; then
    continue
  fi

  if (( uid < UID_MIN )); then
    continue
  fi

  if [[ "$shell" =~ (nologin|false)$ ]]; then
    continue
  fi

  USER_LIST+=("$name")
done < /etc/passwd

if [[ ${#USER_LIST[@]} -eq 0 ]]; then
  echo "[!] No users found to roll. Check UID_MIN or /etc/passwd."
  exit 1
fi

echo "[*] Users to roll passwords for:"
for u in "${USER_LIST[@]}"; do
  echo "  - $u"
done

echo
read -r -p "Are you SURE you want to rotate passwords for these users? (type YES): " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo
echo "[*] Rolling passwords..."

# --- ROLL PASSWORDS ---

for u in "${USER_LIST[@]}"; do
  pw=$(gen_password)

  # Apply password
  echo "${u}:${pw}" | chpasswd

  # Log to output file
  echo "${u}:${pw}" >> "$OUTPUT_FILE"

  # Optional screen echo
  if [[ "$ECHO_TO_SCREEN" -eq 1 ]]; then
    echo "${u}:${pw}"
  fi
done

echo
echo "[+] Done."
echo "[+] New passwords stored in: $OUTPUT_FILE"
echo "    Make sure this file stays root-only (600) and gets into your team docs."
echo "    After the competition, securely delete it (shred or rm in lab env)."
