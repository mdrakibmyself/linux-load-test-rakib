#!/bin/bash
# Part 2 — Give it somewhere fast to work (tmpfs scratch space)
set -euo pipefail

if [[ -z "${SVC_NAME:-}" ]]; then
  echo "Error: SVC_NAME is not set. Run: export SVC_NAME=bgdsvc_<yourname>"
  exit 1
fi

MOUNT_POINT="/mnt/${SVC_NAME}_tmp"

sudo mkdir -p "$MOUNT_POINT"

if mountpoint -q "$MOUNT_POINT"; then
  echo ">>> $MOUNT_POINT already mounted — skipping mount (idempotent)."
else
  sudo mount -t tmpfs -o size=256M tmpfs "$MOUNT_POINT"
  echo ">>> $MOUNT_POINT mounted as tmpfs, capped at 256M."
fi

sudo chown "$SVC_NAME:$SVC_NAME" "$MOUNT_POINT"

echo "---- Verification ----"
df -h "$MOUNT_POINT"