#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../out"
sha256sum -c DolphinOS-x86_64.iso.sha256
mkdir -p download
rm -f download/*
split -b 1900M -d -a 3 DolphinOS-x86_64.iso download/DolphinOS-x86_64.iso.part-
cp DolphinOS-x86_64.iso.sha256 download/
(cd download && sha256sum ./*.part-* > parts.sha256)
cp ../scripts/join-iso.sh ../scripts/join-iso.ps1 download/
