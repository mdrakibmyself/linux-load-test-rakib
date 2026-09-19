#!/bin/bash
# Part 3 — Now, break it (on purpose)
# Usage: export SVC_NAME=bgdsvc_<yourname> ; ./03_stress_and_populate.sh --cpu|--mem|--disk|--all
set -uo pipefail

if [[ -z "${SVC_NAME:-}" ]]; then
  echo "Error: SVC_NAME is not set. Run: export SVC_NAME=bgdsvc_<yourname>"
  exit 1
fi

TMPDIR="/mnt/${SVC_NAME}_tmp"
USAGE="Usage: $0 [--cpu|--mem|--disk|--all]"

if [[ $# -ne 1 ]]; then
  echo "$USAGE"
  exit 1
fi

fill_disk() {
  echo ">>> 3.1 Filling the disk (writing up to 20x 10M files into $TMPDIR)"
  df -h "$TMPDIR"
  for i in $(seq 1 20); do
    dd if=/dev/urandom of="$TMPDIR/file_$i.dat" bs=1M count=10 2>/dev/null
    df -h "$TMPDIR"
  done
}

push_cpu() {
  echo ">>> 3.2 Pushing the CPU"
  if command -v stress-ng &>/dev/null; then
    sudo -u "$SVC_NAME" stress-ng --cpu 2 --timeout 30s
  else
    echo "stress-ng not available — improvising:"
    yes > /dev/null &
    p1=$!
    yes > /dev/null &
    p2=$!
    sleep 30
    kill "$p1" "$p2" 2>/dev/null
  fi
}

squeeze_memory() {
  echo ">>> 3.3 Squeezing the memory"
  sudo apt install -y stress-ng &>/dev/null || true
  sudo -u "$SVC_NAME" stress-ng --vm 1 --vm-bytes 200M --timeout 30s
}

case "$1" in
  --disk) fill_disk ;;
  --cpu)  push_cpu ;;
  --mem)  squeeze_memory ;;
  --all)
    echo ">>> 3.4 All at once — run 'free -h; top; dmesg | grep -i oom' in a second terminal now."
    fill_disk &
    push_cpu &
    squeeze_memory &
    wait
    ;;
  *) echo "$USAGE"; exit 1 ;;
esac