#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PACMAN_FILE="$ROOT/packages/pacman.txt"
AUR_FILE="$ROOT/packages/aur.txt"

read_manifest() {
  local file="$1"
  grep -Ev '^[[:space:]]*(#|$)' "$file" || true
}

mapfile -t packages < <(read_manifest "$PACMAN_FILE")

if ((${#packages[@]})); then
  echo "== Updating system and installing repository packages =="
  sudo pacman -Syu --needed "${packages[@]}"
fi

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi

  echo "== Installing yay because AUR packages are listed =="
  local tmp
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (
    cd "$tmp/yay-bin"
    makepkg -si --needed
  )
  rm -rf "$tmp"
}

mapfile -t aur_packages < <(read_manifest "$AUR_FILE")
if ((${#aur_packages[@]})); then
  install_yay
  echo "== Installing AUR packages =="
  yay -S --needed "${aur_packages[@]}"
fi

# Add the appropriate Mesa/Vulkan userspace pieces without making assumptions
# about NVIDIA generations or proprietary/open kernel module choices.
if command -v lspci >/dev/null 2>&1; then
  gpu_info="$(lspci | grep -Ei 'VGA|3D|Display' || true)"

  if grep -qi 'AMD\|ATI' <<<"$gpu_info"; then
    echo "== AMD GPU detected: installing Vulkan userspace =="
    sudo pacman -S --needed mesa vulkan-radeon libva-mesa-driver
  fi

  if grep -qi 'Intel' <<<"$gpu_info"; then
    echo "== Intel GPU detected: installing Vulkan/media userspace =="
    sudo pacman -S --needed mesa vulkan-intel intel-media-driver
  fi

  if grep -qi 'NVIDIA' <<<"$gpu_info"; then
    cat <<'MSG'

NOTE: NVIDIA GPU detected.
The script deliberately does not choose an NVIDIA driver package automatically.
Check your GPU generation and Arch's current NVIDIA guidance before installing
nvidia/open-kernel-module packages. Both linux and linux-lts are installed, so
ensure the NVIDIA package you choose supports the kernels you intend to boot.
MSG
  fi
fi
