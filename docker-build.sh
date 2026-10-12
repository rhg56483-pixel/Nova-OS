#!/usr/bin/env bash
set -Eeuo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
command -v docker >/dev/null
# Privileged container required by live-build mounts/chroot. Native Linux filesystem only.
docker run --rm --privileged --platform linux/amd64 -v "$PWD:/src" -w /src debian:13   bash -c 'bash build.sh'
