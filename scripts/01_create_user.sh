#!/bin/bash
# Part 1 — Give the service an identity
# Usage: export SVC_NAME=bgdsvc_<yourname> ; ./01_create_user.sh
set -euo pipefail
 
if [[ -z "${SVC_NAME:-}" ]]; then
  echo "Error: SVC_NAME is not set. Run: export SVC_NAME=bgdsvc_<yourname>"
  exit 1
fi
 
if id "$SVC_NAME" &>/dev/null; then
  echo ">>> User $SVC_NAME already exists — skipping creation (idempotent)."
else
  sudo useradd -r -m -s /usr/sbin/nologin "$SVC_NAME"
  echo ">>> User $SVC_NAME created."
fi
 
echo "---- Verification ----"
echo "$SVC_NAME"
id "$SVC_NAME"
getent passwd "$SVC_NAME"