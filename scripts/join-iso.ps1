$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$parts = @(Get-ChildItem 'DolphinOS-x86_64.iso.part-*' | Sort-Object Name)
if ($parts.Count -eq 0) { throw 'No ISO parts found' }
foreach ($line in Get-Content 'parts.sha256') {
    $hash, $name = $line -split '\s+', 2
    $name = $name -replace '^\./', ''
    if ((Get-FileHash $name -Algorithm SHA256).Hash.ToLower() -ne $hash) { throw "Bad part: $name" }
}
$out = [System.IO.File]::Create((Join-Path $PWD 'DolphinOS-x86_64.iso'))
try {
    foreach ($part in $parts) {
        $inputStream = [System.IO.File]::OpenRead($part.FullName)
        try { $inputStream.CopyTo($out) } finally { $inputStream.Dispose() }
    }
} finally { $out.Dispose() }
$expected = ((Get-Content 'DolphinOS-x86_64.iso.sha256') -split '\s+')[0]
if ((Get-FileHash 'DolphinOS-x86_64.iso' -Algorithm SHA256).Hash.ToLower() -ne $expected) { throw 'ISO checksum failed' }
Write-Host 'ISO joined and checksum verified'
