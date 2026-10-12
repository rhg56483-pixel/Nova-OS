# Windows PowerShell: .\create-vbox-vm.ps1 -Iso C:\path\NovaOS-x86_64.iso [-Firmware efi64|bios]
param([Parameter(Mandatory=$true)][string]$Iso, [string]$Firmware = "efi64")
$vb = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"; $vm = "NovaOS"
$disk = "$env:USERPROFILE\VirtualBox VMs\$vm\$vm.vdi"
& $vb createvm --name $vm --ostype Debian_64 --register
& $vb modifyvm $vm --memory 4096 --cpus 2 --vram 128 --graphicscontroller vmsvga --firmware $Firmware `
  --mouse usbtablet --keyboard usb --audio-enabled on --audio-controller hda --nic1 nat `
  --clipboard-mode bidirectional --draganddrop bidirectional --boot1 dvd --boot2 disk
& $vb createmedium disk --filename $disk --size 40960
& $vb storagectl $vm --name SATA --add sata --controller IntelAhci
& $vb storageattach $vm --storagectl SATA --port 0 --device 0 --type hdd --medium $disk
& $vb storageattach $vm --storagectl SATA --port 1 --device 0 --type dvddrive --medium $Iso
Write-Host "Created. Start with: & `"$vb`" startvm $vm"
