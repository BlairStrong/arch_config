#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f /etc/arch-release ]]; then
  echo "This installer is intended for Arch Linux." >&2
  exit 1
fi

if [[ ${EUID} -eq 0 ]]; then
  echo "Run this as your normal user, not root. The script will use sudo when needed." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required. Install/configure sudo first." >&2
  exit 1
fi

printf '\n== Blair Arch setup ==\n'
printf 'User: %s\n' "$USER"
printf 'Repo: %s\n\n' "$ROOT"

sudo -v

"$ROOT/scripts/install-packages.sh"
"$ROOT/scripts/configure-system.sh"
"$ROOT/scripts/link-dotfiles.sh"

cat <<'MSG'

== Finished ==

Reboot when convenient, then select Hyprland in SDDM.

Useful defaults:
  SUPER + Return       terminal
  SUPER + E            file manager
  SUPER + Space        DMS launcher
  SUPER + V            clipboard
  SUPER + ,            DMS settings
  SUPER + X            power menu
  SUPER + Q            close window
  SUPER + F            fullscreen
  SUPER + 1..9         switch workspace
  SUPER + SHIFT + 1..9 move window to workspace
  SUPER + mouse-left   move window
  SUPER + mouse-right  resize window
  3-finger horizontal  switch workspace

Docker group membership takes effect after you log out/in or reboot.
NVIDIA drivers are intentionally not installed automatically; see the installer output if NVIDIA was detected.
MSG
