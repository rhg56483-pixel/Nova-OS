#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
mapfile -d '' files < <(find . -path './docs/legacy-nova' -prune -o -type f \( -name '*.sh' -o -name '*.hook.chroot' \) -print0)
files+=(config/includes.chroot_after_packages/usr/local/bin/* config/includes.chroot_after_packages/usr/local/sbin/*)
for file in "${files[@]}"; do bash -n "$file"; done
command -v shellcheck >/dev/null || { echo 'Install shellcheck to run mandatory validation'; exit 1; }
shellcheck -S warning "${files[@]}"
python3 scripts/validate-config.py
