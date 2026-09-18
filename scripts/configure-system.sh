#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_FILE="$ROOT/services/system.txt"

read_manifest() {
  local file="$1"
  grep -Ev '^[[:space:]]*(#|$)' "$file" || true
}

echo "== Enabling system services =="
while IFS= read -r service; do
  [[ -z "$service" ]] && continue
  sudo systemctl enable --now "$service"
done < <(read_manifest "$SERVICE_FILE")

# SDDM is enabled, but not started immediately. Starting a display manager in
# the middle of an existing graphical session is unnecessarily disruptive.
dm_link=/etc/systemd/system/display-manager.service
if [[ -L "$dm_link" ]]; then
  current_dm="$(basename "$(readlink -f "$dm_link")")"
  if [[ "$current_dm" == "sddm.service" ]]; then
    echo "SDDM is already the configured display manager."
  else
    echo "Existing display manager detected: $current_dm"
    echo "Leaving it unchanged. To switch later: disable $current_dm, then enable sddm.service."
  fi
else
  echo "Enabling SDDM for the next boot."
  sudo systemctl enable sddm.service
fi

if getent group docker >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER"
fi

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  xdg-user-dirs-update
fi

mkdir -p "$HOME/Pictures/Wallpapers"
