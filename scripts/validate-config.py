#!/usr/bin/env python3
"""Static checks only: not proof of a built, bootable or installable image."""
from pathlib import Path
import re, yaml, xml.etree.ElementTree as ET
root = Path(__file__).resolve().parents[1]
files = [p for p in root.rglob('*') if p.is_file() and 'legacy-nova' not in p.parts]
for p in files:
    if p.suffix in ('.yml', '.yaml') or p.name == 'branding.desc' or ('calamares' in p.parts and p.suffix == '.conf'):
        yaml.safe_load(p.read_text())
    if p.suffix in ('.svg', '.xml'):
        ET.parse(p)
wf=yaml.load((root/'.github/workflows/build-iso.yml').read_text(),Loader=yaml.BaseLoader)
assert 'workflow_dispatch' in wf['on'], 'Manual workflow missing'
assert wf['jobs']['build']['steps'][1]['run'] == 'bash docker-build.sh'
assert 'if-no-files-found: error' in (root/'.github/workflows/build-iso.yml').read_text()
packages=[]
for p in (root/'config/package-lists').glob('*.list.chroot'):
    packages += [x.strip() for x in p.read_text().splitlines() if x.strip() and not x.startswith('#')]
assert len(packages) == len(set(packages)), 'Duplicate packages'
for p in packages: assert re.fullmatch(r'[a-z0-9][a-z0-9+.-]*',p), f'Invalid package name: {p}'
for name in ('lxqt-core','openbox','calamares-settings-debian','grub-pc-bin','grub-efi-amd64-bin','rsync'):
    assert name in packages
assert 'kde-plasma-desktop' not in packages
for p in (root/'config/hooks/normal').glob('*.hook.chroot'):
    assert p.stat().st_mode & 0o111, f'Hook not executable: {p}'
    for idx, chunk in enumerate(re.findall(r"<<'PYCODE'\n(.*?)\nPYCODE",p.read_text(),re.S)):
        compile(chunk,str(p)+f':embedded-{idx}','exec')
for p in files:
    if p.suffix == '.desktop':
        s=p.read_text();assert '[Desktop Entry]' in s and 'Type=Application' in s and 'Exec=' in s
print(f'PASS: Bash-independent config checks; {len(packages)} unique package names; YAML/XML/SVG and embedded Python syntax')
