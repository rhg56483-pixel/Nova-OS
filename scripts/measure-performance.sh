#!/usr/bin/env bash
set -Eeuo pipefail
# Run after login, desktop idle, as your user. Never substitute these for boot/install QA.
OUT=${1:-"$PWD/dolphin-performance-$(date +%Y%m%d-%H%M%S).txt"}
{
 date --iso-8601=seconds
 cat /etc/os-release
 uname -a
 systemd-detect-virt || :
 printf '\nRAM (MemTotal-MemAvailable accounts for reclaimable cache)\n'
 awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {printf "total_MiB=%.1f available_MiB=%.1f used_MiB=%.1f\n",total/1024,available/1024,(total-available)/1024}' /proc/meminfo
 free -m
 printf '\nCPU: 10 one-second samples; skip first cumulative sample\n'
 mpstat 1 10
 printf '\nBoot timing (firmware may be absent in a VM)\n'
 systemd-analyze time
 systemd-analyze critical-chain
 printf '\nActive services and highest resident processes\n'
 systemctl --no-pager --type=service --state=running
 ps -eo pid,comm,rss,%cpu --sort=-rss | awk 'NR <= 21'
} > "$OUT" 2>&1
echo "Measured report: $OUT"
