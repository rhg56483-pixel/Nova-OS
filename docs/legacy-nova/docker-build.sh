#!/usr/bin/env bash
# Build the ISO inside a privileged Debian container (works from any Linux/WSL2 with Docker).
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
docker run --rm --privileged -v "$PWD":/src -w /src debian:trixie \
  bash -c 'apt-get update && apt-get install -y ca-certificates && ./build.sh'
