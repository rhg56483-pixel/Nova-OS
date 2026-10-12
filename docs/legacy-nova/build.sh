#!/usr/bin/env bash
# Nova OS ISO builder. Run as root on Debian 12/13 (or inside docker via docker-build.sh)
# Output: ./out/NovaOS-x86_64.iso
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo ./build.sh"; exit 1; }
if ! grep -qi '^ID=debian' /etc/os-release; then
  echo "This host is not Debian. Use ./docker-build.sh (Docker) instead." >&2; exit 1
fi

DIST="${NOVA_DIST:-trixie}"
WORK="${NOVA_WORK:-/tmp/nova-build}"   # must be on a native Linux filesystem (not NTFS / vboxsf / 9p)
OUT="$(pwd)/out"

echo "==> Installing build dependencies"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  live-build debootstrap debian-archive-keyring squashfs-tools xorriso mtools \
  dosfstools isolinux syslinux syslinux-common grub-pc-bin grub-efi-amd64-bin \
  grub-common rsync ca-certificates

echo "==> Preparing workspace $WORK"
rm -rf "$WORK"; mkdir -p "$WORK" "$OUT"
cp -a config "$WORK/config"
cd "$WORK"

echo "==> lb config (Debian $DIST, amd64, BIOS+UEFI hybrid ISO)"
lb config \
  --mode debian \
  --distribution "$DIST" \
  --architectures amd64 \
  --linux-flavours amd64 \
  --archive-areas "main contrib non-free-firmware" \
  --parent-archive-areas "main contrib non-free-firmware" \
  --binary-images iso-hybrid \
  --bootloaders "grub-efi,syslinux" \
  --debian-installer none \
  --system live \
  --apt-recommends false \
  --firmware-chroot true \
  --firmware-binary true \
  --security true --updates true \
  --iso-application "Nova OS" \
  --iso-publisher "Nova OS Project" \
  --iso-volume "NOVAOS" \
  --memtest none \
  --checksums sha256 \
  --bootappend-live "boot=live components quiet splash username=novalive user-fullname=Nova-Live hostname=novaos locales=en_US.UTF-8 keyboard-layouts=us,ara"

echo "==> lb build (this takes 20-60 minutes and ~15 GB disk)"
lb build 2>&1 | tee "$OUT/build.log"

ISO="$(ls -1 ./*.iso | head -n1)"
cp "$ISO" "$OUT/NovaOS-x86_64.iso"
( cd "$OUT" && sha256sum NovaOS-x86_64.iso > NovaOS-x86_64.iso.sha256 )
echo "==> Done: $OUT/NovaOS-x86_64.iso"
