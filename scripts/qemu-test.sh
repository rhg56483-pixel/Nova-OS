#!/usr/bin/env bash
set -Eeuo pipefail
ISO=$(realpath "${1:?ISO required}")
MODE=${2:-bios}
RAM=${3:-2048}
[[ -s $ISO && ( $MODE == bios || $MODE == uefi ) ]] || exit 1
mkdir -p out/qemu
DISK="out/qemu/dolphin-${MODE}.qcow2"
[[ -e $DISK ]] || qemu-img create -f qcow2 "$DISK" 32G
args=(-m "$RAM" -smp 2 -accel tcg -device virtio-vga -device qemu-xhci -device usb-tablet -nic "user,model=virtio-net-pci" -audiodev "driver=none,id=sound" -device intel-hda -device "hda-duplex,audiodev=sound" -drive "file=$DISK,if=virtio,format=qcow2" -cdrom "$ISO" -boot d)
if [[ $MODE == uefi ]]; then
 code=/usr/share/OVMF/OVMF_CODE_4M.fd
 vars=/usr/share/OVMF/OVMF_VARS_4M.fd
 [[ -s $code && -s $vars ]] || { echo 'Install ovmf'; exit 1; }
 [[ -e out/qemu/vars.fd ]] || cp "$vars" out/qemu/vars.fd
 args+=(-drive "if=pflash,format=raw,readonly=on,file=$code" -drive 'if=pflash,format=raw,file=out/qemu/vars.fd')
fi
exec qemu-system-x86_64 "${args[@]}"
