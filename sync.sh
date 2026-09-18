#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f /etc/arch-release ]]; then
  echo "This sync script is intended to be run on Arch Linux." >&2
  exit 1
fi

# Native packages explicitly installed by the user. Dependencies are restored
# automatically by pacman, so we do not need every transitive package here.
pacman -Qqen | LC_ALL=C sort -u > "$ROOT/packages/pacman.txt"

# Foreign packages normally means AUR/manual packages.
pacman -Qqem | LC_ALL=C sort -u > "$ROOT/packages/aur.txt"

cat <<EOF2
Package manifests refreshed.

Review changes before committing:
  git -C "$ROOT" diff
  git -C "$ROOT" status

Then, when happy:
  git -C "$ROOT" add .
  git -C "$ROOT" commit -m "Update Arch setup"
  git -C "$ROOT" push
EOF2
