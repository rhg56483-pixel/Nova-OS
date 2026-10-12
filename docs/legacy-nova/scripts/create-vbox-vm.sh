#!/usr/bin/env bash
# Creates a VirtualBox VM for Nova OS. Usage: ./create-vbox-vm.sh path/to/NovaOS-x86_64.iso [efi|bios]
set -euo pipefail
ISO="${1:?ISO path required}"; FW="${2:-efi}"; VM=NovaOS
VBoxManage createvm --name $VM --ostype Debian_64 --register
VBoxManage modifyvm $VM --memory 4096 --cpus 2 --vram 128 --graphicscontroller vmsvga \
  --firmware $([[ $FW == efi ]] && echo efi64 || echo bios) --mouse usbtablet --keyboard usb \
  --audio-enabled on --audio-controller hda --nic1 nat \
  --clipboard-mode bidirectional --draganddrop bidirectional --boot1 dvd --boot2 disk
VBoxManage createmedium disk --filename "$HOME/VirtualBox VMs/$VM/$VM.vdi" --size 40960
VBoxManage storagectl $VM --name SATA --add sata --controller IntelAhci
VBoxManage storageattach $VM --storagectl SATA --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$VM/$VM.vdi"
VBoxManage storageattach $VM --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$ISO"
echo "VM '$VM' created. Start with: VBoxManage startvm $VM"
