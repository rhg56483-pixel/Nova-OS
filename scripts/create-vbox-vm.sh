#!/usr/bin/env bash
set -Eeuo pipefail
ISO=$(realpath "${1:?ISO path required}")
FW=${2:-efi}
VM=DolphinOS
[[ -s $ISO ]] || { echo 'ISO missing'; exit 1; }
[[ $FW == efi || $FW == bios ]] || { echo 'Firmware must be efi or bios'; exit 1; }
command -v VBoxManage >/dev/null
if VBoxManage showvminfo "$VM" >/dev/null 2>&1; then echo 'VM already exists; use a different name or the manual guide'; exit 1; fi
firmware=bios
[[ $FW == bios ]] || firmware=efi64
VBoxManage createvm --name "$VM" --ostype Debian_64 --register
VBoxManage modifyvm "$VM" --memory 4096 --cpus 2 --vram 128 --graphicscontroller vmsvga \
  --firmware "$firmware" --mouse usbtablet --keyboard usb \
  --audio-enabled on --audio-controller hda --nic1 nat \
  --clipboard-mode bidirectional --draganddrop bidirectional --boot1 dvd --boot2 disk
VBoxManage createmedium disk --filename "$HOME/VirtualBox VMs/$VM/$VM.vdi" --size 40960
VBoxManage storagectl "$VM" --name SATA --add sata --controller IntelAhci
VBoxManage storageattach "$VM" --storagectl SATA --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$VM/$VM.vdi"
VBoxManage storageattach "$VM" --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$ISO"
echo "VM '$VM' created. Start with: VBoxManage startvm $VM"
