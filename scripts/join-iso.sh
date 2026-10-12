#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
sha256sum -c parts.sha256
cat DolphinOS-x86_64.iso.part-* > DolphinOS-x86_64.iso
sha256sum -c DolphinOS-x86_64.iso.sha256
