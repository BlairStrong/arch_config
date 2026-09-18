#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES="$ROOT/dotfiles"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.local/state/blair-arch/backups/$STAMP"

backup_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    # Leave symlinks that already point inside this repo alone.
    if [[ -L "$path" ]]; then
      local target
      target="$(readlink -f "$path" 2>/dev/null || true)"
      if [[ "$target" == "$ROOT"/* ]]; then
        return
      fi
    fi

    mkdir -p "$BACKUP"
    echo "Backing up $path -> $BACKUP/"
    mv "$path" "$BACKUP/$(basename "$path")"
  fi
}

echo "== Linking managed dotfiles with GNU Stow =="

backup_path "$HOME/.config/hypr"
backup_path "$HOME/.config/kitty"
backup_path "$HOME/.tmux.conf"

mkdir -p "$HOME/.config"

stow --dir "$DOTFILES" --target "$HOME" --restow hypr kitty tmux shell

BASHRC="$HOME/.bashrc"
SOURCE_LINE='[[ -f "$HOME/.config/blair-shell/bashrc" ]] && source "$HOME/.config/blair-shell/bashrc"'

touch "$BASHRC"
if ! grep -Fq '.config/blair-shell/bashrc' "$BASHRC"; then
  printf '\n# Blair Arch managed shell config\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
fi

if [[ -d "$BACKUP" ]]; then
  echo "Previous config backed up under: $BACKUP"
fi
