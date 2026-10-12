param([Parameter(Mandatory=$true)][string]$Iso, [ValidateSet('efi64','bios')][string]$Firmware = 'efi64')
$ErrorActionPreference = 'Stop'
$Iso = (Resolve-Path $Iso).Path
if ((Get-Item $Iso).Length -eq 0) { throw 'ISO is empty' }
$vb = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
if (-not (Test-Path $vb)) { throw 'Install VirtualBox first' }
$vm = 'DolphinOS'
& $vb showvminfo $vm 2>$null
if ($LASTEXITCODE -eq 0) { throw 'VM already exists; use the manual guide' }
function Invoke-VBox {
    & $vb @args
    if ($LASTEXITCODE -ne 0) { throw "VBoxManage failed: $args" }
}
$disk = "$env:USERPROFILE\VirtualBox VMs\$vm\$vm.vdi"
Invoke-VBox createvm --name $vm --ostype Debian_64 --register
Invoke-VBox modifyvm $vm --memory 4096 --cpus 2 --vram 128 --graphicscontroller vmsvga --firmware $Firmware `
  --mouse usbtablet --keyboard usb --audio-enabled on --audio-controller hda --nic1 nat `
  --clipboard-mode bidirectional --draganddrop bidirectional --boot1 dvd --boot2 disk
Invoke-VBox createmedium disk --filename $disk --size 40960
Invoke-VBox storagectl $vm --name SATA --add sata --controller IntelAhci
Invoke-VBox storageattach $vm --storagectl SATA --port 0 --device 0 --type hdd --medium $disk
Invoke-VBox storageattach $vm --storagectl SATA --port 1 --device 0 --type dvddrive --medium $Iso
Write-Host 'Created DolphinOS VM'
