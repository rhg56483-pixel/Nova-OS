#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mapfile -t packages < <(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' "$ROOT"/config/package-lists/*.list.chroot)
# Resolve against the image's archive areas with an empty dpkg status, not the host's
# possibly main-only APT sources or already-installed packages. Do not modify host sources.
state=$(mktemp -d)
trap 'rm -rf "$state"' EXIT
chmod 755 "$state"
mkdir -p "$state/lists/partial" "$state/cache" "$state/preferences.d"
: > "$state/status"
: > "$state/preferences"
cat > "$state/sources.list" <<'SOURCES'
deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://deb.debian.org/debian trixie main contrib non-free-firmware
deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://deb.debian.org/debian trixie-updates main contrib non-free-firmware
deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://security.debian.org/debian-security trixie-security main contrib non-free-firmware
SOURCES
opts=(-o "Dir::State::lists=$state/lists" -o "Dir::State::status=$state/status"
      -o "Dir::Cache=$state/cache" -o "Dir::Etc::sourcelist=$state/sources.list"
      -o 'Dir::Etc::sourceparts=-' -o "Dir::Etc::preferences=$state/preferences"
      -o "Dir::Etc::preferencesparts=$state/preferences.d")
apt-get "${opts[@]}" update
missing=()
for p in "${packages[@]}"; do
  candidate=$(apt-cache "${opts[@]}" policy "$p" | awk '/Candidate:/ {print $2}')
  [[ -n $candidate && $candidate != '(none)' ]] || missing+=("$p")
done
if ((${#missing[@]})); then printf 'Unavailable package: %s\n' "${missing[@]}" >&2; exit 1; fi
apt-get "${opts[@]}" --simulate --no-install-recommends install "${packages[@]}"
echo 'APT names and clean-system dependency resolution passed for image archives.'
