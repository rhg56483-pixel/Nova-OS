#!/usr/bin/env bash
set -Eeuo pipefail
ISO=$(realpath "${1:?Usage: verify-iso.sh file.iso}")
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$ROOT/out"
exec > >(tee "$ROOT/out/iso-checks.txt") 2>&1
[[ -s $ISO ]] || { echo 'Missing/empty ISO'; exit 1; }
(( $(stat -c %s "$ISO") > 100*1024*1024 )) || { echo 'ISO implausibly small'; exit 1; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
xorriso -indev "$ISO" -report_el_torito plain -report_system_area plain > "$tmp/boot.txt" 2>&1
cat "$tmp/boot.txt"
grep -Eq 'El Torito boot img.*BIOS' "$tmp/boot.txt"
grep -Eq 'El Torito boot img.*UEFI' "$tmp/boot.txt"
grep -q 'MBR' "$tmp/boot.txt"
xorriso -osirrox on -indev "$ISO" -extract /live "$tmp/live"
[[ -s $tmp/live/filesystem.squashfs ]]
compgen -G "$tmp/live/vmlinuz*" >/dev/null
compgen -G "$tmp/live/initrd*" >/dev/null
unsquashfs -s "$tmp/live/filesystem.squashfs"
unsquashfs -d "$tmp/root" "$tmp/live/filesystem.squashfs" \
  etc/os-release etc/calamares/settings.conf usr/share/xsessions/lxqt.desktop
[[ -s $tmp/root/etc/calamares/settings.conf && -s $tmp/root/usr/share/xsessions/lxqt.desktop ]]
grep -q 'ID=dolphinos' "$tmp/root/etc/os-release"
echo 'PASS: hybrid BIOS/UEFI boot entries, kernel/initrd, SquashFS and LXQt/Calamares identity. Not a boot/install test.'
