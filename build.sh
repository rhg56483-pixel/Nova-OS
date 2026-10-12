#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
OUT="$ROOT/out"
mkdir -p "$OUT"
exec > >(tee "$OUT/build.log") 2>&1
on_error() {
  local rc=$1 line=$2 command=$3
  printf 'BUILD FAILED rc=%s line=%s command=%s\n' "$rc" "$line" "$command" >&2
  exit "$rc"
}
trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR
[[ $EUID -eq 0 ]] || { echo 'Run: sudo bash build.sh'; exit 1; }
. /etc/os-release
[[ $ID == debian && $VERSION_ID == 13 ]] || { echo 'Debian 13 required; use bash docker-build.sh'; exit 1; }
[[ $(dpkg --print-architecture) == amd64 ]] || { echo 'amd64 build host required'; exit 1; }
export DEBIAN_FRONTEND=noninteractive
# Allocate only our own fresh workspace. Never rm -rf a caller-supplied path.
WORK=$(mktemp -d /var/tmp/dolphin-build.XXXXXXXX)
echo "Build workspace: $WORK (retained for diagnostics; clean manually after unmounting)"
mkdir -p "$WORK/mount-test"
if ! mount -t tmpfs tmpfs "$WORK/mount-test"; then
  echo 'Mount denied: use a Debian VM or privileged Docker container.' >&2; exit 1
fi
umount "$WORK/mount-test"
FREE=$(df --output=avail -B1 "$WORK" | tail -1)
(( FREE >= 20*1024*1024*1024 )) || { echo 'At least 20 GiB free required'; exit 1; }
rm -f "$OUT/DolphinOS-x86_64.iso" "$OUT/DolphinOS-x86_64.iso.sha256" "$OUT/iso-checks.txt"
apt-get update
apt-get install -y --no-install-recommends live-build debootstrap debian-archive-keyring \
  squashfs-tools xorriso mtools dosfstools isolinux syslinux syslinux-common \
  grub-pc-bin grub-efi-amd64-bin grub-common rsync ca-certificates python3-yaml shellcheck
bash "$ROOT/scripts/validate.sh"
bash "$ROOT/scripts/check-packages.sh"
cp -a "$ROOT/config" "$WORK/config"
# Single source of artwork; hooks render PNGs after package installation.
mkdir -p "$WORK/config/includes.chroot_after_packages/usr/share/dolphin-os/branding"
cp "$ROOT"/branding/*.svg "$WORK/config/includes.chroot_after_packages/usr/share/dolphin-os/branding/"
cd "$WORK"
lb config --mode debian --distribution trixie --architectures amd64 --linux-flavours amd64 \
  --archive-areas 'main contrib non-free-firmware' --parent-archive-areas 'main contrib non-free-firmware' \
  --binary-images iso-hybrid --bootloaders 'grub-efi,syslinux' --debian-installer none \
  --system live --apt-recommends false --firmware-chroot true --firmware-binary true \
  --security true --updates true --initramfs live-boot \
  --iso-application 'Dolphin OS 1.0' --iso-publisher 'Dolphin OS Project' --iso-volume DOLPHINOS \
  --memtest none --checksums sha256 \
  --bootappend-live 'boot=live components quiet splash username=dolphin user-fullname=Dolphin-Live hostname=dolphinos locales=ar_SA.UTF-8 keyboard-layouts=ara,us keyboard-options=grp:alt_shift_toggle timezone=Asia/Riyadh'
lb build
shopt -s nullglob
images=( "$WORK"/*.iso )
[[ ${#images[@]} == 1 && -s ${images[0]} ]] || { echo 'Expected exactly one non-empty ISO'; exit 1; }
cp "${images[0]}" "$OUT/DolphinOS-x86_64.iso"
bash "$ROOT/scripts/verify-iso.sh" "$OUT/DolphinOS-x86_64.iso"
(cd "$OUT" && sha256sum DolphinOS-x86_64.iso > DolphinOS-x86_64.iso.sha256)
echo 'BUILD SUCCESS: ISO exists, structural BIOS/UEFI and filesystem checks passed. VM install testing still required.'
